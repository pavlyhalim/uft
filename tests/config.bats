#!/usr/bin/env bats

load test_helper/common

setup() {
    load_uft
    TMPDIR_CFG=$(mktemp -d)
}

teardown() {
    rm -rf "$TMPDIR_CFG"
}

# --- _load_config basic loading ---

@test "load_config reads host from config file" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
host = myserver.lan
user = deploy
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    REMOTE_HOST=""
    REMOTE_USER=""
    _load_config
    [[ "$REMOTE_HOST" == "myserver.lan" ]]
    [[ "$REMOTE_USER" == "deploy" ]]
}

@test "load_config reads all supported keys" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
host = box.lan
user = admin
remote_path = /data/src
local_path = /data/dst
port = 2222
mode = tar-stream
compress = lz4
jobs = 16
streams = 8
nc_port = 20000
bwlimit = 500
local_ip = 10.0.0.5
symlinks = dereference
jump = bastion.example.com
keep_logs = 50
newer = 2025-01-01
skip_scan = true
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    # reset all to defaults so config can fill them
    REMOTE_HOST=""
    REMOTE_USER=""
    REMOTE_PATH=""
    LOCAL_PATH=""
    SSH_PORT="22"
    MODE="auto"
    COMPRESS="auto"
    PARALLEL_JOBS="8"
    NUM_STREAMS="4"
    NC_BASE_PORT="19000"
    BANDWIDTH_LIMIT=""
    LOCAL_IP_OVERRIDE=""
    SYMLINK_MODE="preserve"
    JUMP_HOST=""
    KEEP_LOGS="20"
    NEWER_THAN=""
    SKIP_SCAN="false"

    _load_config

    [[ "$REMOTE_HOST" == "box.lan" ]]
    [[ "$REMOTE_USER" == "admin" ]]
    [[ "$REMOTE_PATH" == "/data/src" ]]
    [[ "$LOCAL_PATH" == "/data/dst" ]]
    [[ "$SSH_PORT" == "2222" ]]
    [[ "$MODE" == "tar-stream" ]]
    [[ "$COMPRESS" == "lz4" ]]
    [[ "$PARALLEL_JOBS" == "16" ]]
    [[ "$NUM_STREAMS" == "8" ]]
    [[ "$NC_BASE_PORT" == "20000" ]]
    [[ "$BANDWIDTH_LIMIT" == "500" ]]
    [[ "$LOCAL_IP_OVERRIDE" == "10.0.0.5" ]]
    [[ "$SYMLINK_MODE" == "dereference" ]]
    [[ "$JUMP_HOST" == "bastion.example.com" ]]
    [[ "$KEEP_LOGS" == "50" ]]
    [[ "$NEWER_THAN" == "2025-01-01" ]]
    [[ "$SKIP_SCAN" == "true" ]]
}

# --- CLI flags override config values ---

@test "CLI flag overrides config: host" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
host = config-server
user = config-user
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    # simulate CLI already set the host
    REMOTE_HOST="cli-server"
    REMOTE_USER=""
    _load_config
    # host should stay as CLI value; user should come from config
    [[ "$REMOTE_HOST" == "cli-server" ]]
    [[ "$REMOTE_USER" == "config-user" ]]
}

@test "CLI flag overrides config: mode" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
mode = tar-nc
compress = zstd
host = fallback-host
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    REMOTE_HOST=""
    MODE="parallel-rsync"
    COMPRESS="lz4"
    _load_config
    # CLI values should not be overwritten
    [[ "$MODE" == "parallel-rsync" ]]
    [[ "$COMPRESS" == "lz4" ]]
    # host was empty so config should fill it (proves config was read)
    [[ "$REMOTE_HOST" == "fallback-host" ]]
}

@test "CLI flag overrides config: port stays if not default" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
port = 2222
host = fallback-host
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    REMOTE_HOST=""
    SSH_PORT="9999"
    _load_config
    # port was already changed from default, config should not override
    [[ "$SSH_PORT" == "9999" ]]
    # host was empty so config fills it (proves file was read)
    [[ "$REMOTE_HOST" == "fallback-host" ]]
}

# --- comments and blank lines ---

@test "load_config ignores comments and blank lines" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
# This is a comment
host = myhost

  # indented comment
user = myuser

CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    REMOTE_HOST=""
    REMOTE_USER=""
    _load_config
    [[ "$REMOTE_HOST" == "myhost" ]]
    [[ "$REMOTE_USER" == "myuser" ]]
}

# --- quoted values ---

@test "load_config strips double quotes from values" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
host = "quoted-server"
user = "quoted-user"
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    REMOTE_HOST=""
    REMOTE_USER=""
    _load_config
    [[ "$REMOTE_HOST" == "quoted-server" ]]
    [[ "$REMOTE_USER" == "quoted-user" ]]
}

@test "load_config strips single quotes from values" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
host = 'single-quoted'
user = 'sq-user'
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    REMOTE_HOST=""
    REMOTE_USER=""
    _load_config
    [[ "$REMOTE_HOST" == "single-quoted" ]]
    [[ "$REMOTE_USER" == "sq-user" ]]
}

# --- unknown keys ---

@test "load_config ignores unknown keys" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
host = myhost
banana = yellow
foobar = 42
user = myuser
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    REMOTE_HOST=""
    REMOTE_USER=""
    _load_config
    [[ "$REMOTE_HOST" == "myhost" ]]
    [[ "$REMOTE_USER" == "myuser" ]]
}

# --- exclude from config ---

@test "load_config appends exclude patterns" {
    cat > "${TMPDIR_CFG}/uftrc" <<'CONF'
exclude = *.tmp
exclude = .git
exclude = node_modules
CONF
    CONFIG_FILE="${TMPDIR_CFG}/uftrc"
    EXCLUDES=()
    _load_config
    [[ "${#EXCLUDES[@]}" -eq 3 ]]
    [[ "${EXCLUDES[0]}" == "*.tmp" ]]
    [[ "${EXCLUDES[1]}" == ".git" ]]
    [[ "${EXCLUDES[2]}" == "node_modules" ]]
}

# --- missing config file ---

@test "load_config is a no-op when config file missing" {
    CONFIG_FILE="${TMPDIR_CFG}/nonexistent"
    REMOTE_HOST=""
    _load_config
    [[ "$REMOTE_HOST" == "" ]]
}
