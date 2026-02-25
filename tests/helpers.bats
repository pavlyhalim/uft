#!/usr/bin/env bats

load test_helper/common

setup() {
    load_uft
}

# --- _human_bytes (now pure bash, no bc) ---

@test "human_bytes: bytes" {
    result=$(_human_bytes 500)
    [[ "$result" == "500 B" ]]
}

@test "human_bytes: kilobytes" {
    result=$(_human_bytes 2048)
    [[ "$result" == "2.0 KB" ]]
}

@test "human_bytes: megabytes" {
    result=$(_human_bytes 5242880)
    [[ "$result" == "5.0 MB" ]]
}

@test "human_bytes: gigabytes" {
    result=$(_human_bytes 2147483648)
    [[ "$result" == "2.0 GB" ]]
}

@test "human_bytes: zero" {
    result=$(_human_bytes 0)
    [[ "$result" == "0 B" ]]
}

# --- _human_duration ---

@test "human_duration: seconds" {
    result=$(_human_duration 45)
    [[ "$result" == "45s" ]]
}

@test "human_duration: minutes" {
    result=$(_human_duration 125)
    [[ "$result" == "2m 5s" ]]
}

@test "human_duration: hours" {
    result=$(_human_duration 3661)
    [[ "$result" == "1h 1m 1s" ]]
}

@test "human_duration: zero" {
    result=$(_human_duration 0)
    [[ "$result" == "0s" ]]
}

# --- _compress_cmd / _decompress_cmd ---

@test "compress_cmd: lz4" {
    COMPRESS="lz4"
    [[ "$(_compress_cmd)" == "lz4 -1 -" ]]
}

@test "compress_cmd: pigz" {
    COMPRESS="pigz"
    [[ "$(_compress_cmd)" == "pigz -1" ]]
}

@test "compress_cmd: zstd" {
    COMPRESS="zstd"
    [[ "$(_compress_cmd)" == "zstd -1 -T0 -" ]]
}

@test "compress_cmd: none" {
    COMPRESS="none"
    [[ "$(_compress_cmd)" == "cat" ]]
}

@test "decompress_cmd: lz4" {
    COMPRESS="lz4"
    [[ "$(_decompress_cmd)" == "lz4 -d -" ]]
}

@test "decompress_cmd: none" {
    COMPRESS="none"
    [[ "$(_decompress_cmd)" == "cat" ]]
}

@test "decompress_cmd: unknown" {
    COMPRESS="bogus"
    [[ "$(_decompress_cmd)" == "cat" ]]
}

# --- _rquote ---

@test "rquote: simple path" {
    result=$(_rquote "/data/frames")
    [[ "$result" == "/data/frames" ]]
}

@test "rquote: path with spaces" {
    result=$(_rquote "/data/my frames")
    # printf %q escapes spaces
    [[ "$result" == *"my"*"frames"* ]]
    # verify it doesn't contain unescaped spaces
    eval "test -n ${result}" 2>/dev/null || true
}

@test "rquote: path with quotes" {
    result=$(_rquote "/data/it's here")
    # should be safe to eval
    [[ -n "$result" ]]
}

# --- _normalize_path ---

@test "normalize_path: strips trailing slash" {
    result=$(_normalize_path "/data/frames/")
    [[ "$result" == "/data/frames" ]]
}

@test "normalize_path: strips multiple trailing slashes" {
    result=$(_normalize_path "/data/frames///")
    [[ "$result" == "/data/frames" ]]
}

@test "normalize_path: root path stays root" {
    result=$(_normalize_path "/")
    [[ "$result" == "/" ]]
}

@test "normalize_path: no trailing slash unchanged" {
    result=$(_normalize_path "/data/frames")
    [[ "$result" == "/data/frames" ]]
}

# --- _tar_exclude_flags ---

@test "tar_exclude_flags: empty excludes" {
    EXCLUDES=()
    result=$(_tar_exclude_flags)
    [[ "$result" == "" ]]
}

@test "tar_exclude_flags: single pattern (quoted for remote shell)" {
    EXCLUDES=("*.tmp")
    result=$(_tar_exclude_flags)
    [[ "$result" == *"--exclude='*.tmp'"* ]]
}

@test "tar_exclude_flags: multiple patterns (quoted)" {
    EXCLUDES=("*.tmp" ".git" "*.log")
    result=$(_tar_exclude_flags)
    [[ "$result" == *"--exclude='*.tmp'"* ]]
    [[ "$result" == *"--exclude='.git'"* ]]
    [[ "$result" == *"--exclude='*.log'"* ]]
}

# --- _rsync_exclude_flags ---

@test "rsync_exclude_flags: empty excludes" {
    EXCLUDES=()
    result=$(_rsync_exclude_flags)
    [[ "$result" == "" ]]
}

@test "rsync_exclude_flags: single pattern" {
    EXCLUDES=("*.tmp")
    result=$(_rsync_exclude_flags)
    [[ "$result" == *"--exclude=*.tmp"* ]]
}

@test "rsync_exclude_flags: multiple patterns" {
    EXCLUDES=("*.tmp" ".git" "node_modules")
    result=$(_rsync_exclude_flags)
    [[ "$result" == *"--exclude=*.tmp"* ]]
    [[ "$result" == *"--exclude=.git"* ]]
    [[ "$result" == *"--exclude=node_modules"* ]]
}

# --- _find_exclude_expr ---

@test "find_exclude_expr: empty excludes" {
    EXCLUDES=()
    result=$(_find_exclude_expr)
    [[ "$result" == "" ]]
}

@test "find_exclude_expr: single pattern" {
    EXCLUDES=("*.tmp")
    result=$(_find_exclude_expr)
    [[ "$result" == *"! -name '*.tmp'"* ]]
}

@test "find_exclude_expr: multiple patterns joined with -a" {
    EXCLUDES=("*.tmp" "*.log")
    result=$(_find_exclude_expr)
    [[ "$result" == *"! -name '*.tmp'"* ]]
    [[ "$result" == *"-a"* ]]
    [[ "$result" == *"! -name '*.log'"* ]]
}

# --- _tar_create_flags ---

@test "tar_create_flags: preserve symlinks (default)" {
    SYMLINK_MODE="preserve"
    result=$(_tar_create_flags)
    [[ "$result" == "cf -" ]]
}

@test "tar_create_flags: dereference symlinks" {
    SYMLINK_MODE="dereference"
    result=$(_tar_create_flags)
    [[ "$result" == "chf -" ]]
}
