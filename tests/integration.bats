#!/usr/bin/env bats

# Integration tests that require passwordless SSH to localhost.
# All tests skip gracefully if SSH is not available.

load test_helper/common

_ssh_available() {
    ssh -o BatchMode=yes -o ConnectTimeout=5 localhost "echo ok" &>/dev/null
}

setup() {
    if ! _ssh_available; then
        skip "SSH to localhost not available (passwordless)"
    fi
    load_uft
    TMPDIR_INT=$(mktemp -d)
    SRC_DIR="${TMPDIR_INT}/src"
    DST_DIR="${TMPDIR_INT}/dst"
    mkdir -p "$SRC_DIR" "$DST_DIR"
}

teardown() {
    rm -rf "$TMPDIR_INT" 2>/dev/null || true
}

# --- tar-stream: 100 small files ---

@test "integration: tar-stream transfers 100 files" {
    # create 100 small files in source
    for i in $(seq 1 100); do
        echo "file-$i" > "${SRC_DIR}/file_${i}.txt"
    done

    local src_count
    src_count=$(find "$SRC_DIR" -type f | wc -l | tr -d ' ')

    # run uft via bash in a subshell; use tar-stream mode
    run bash "$UFT_BIN" \
        -H localhost \
        -u "$USER" \
        -r "$SRC_DIR" \
        -l "$DST_DIR" \
        -m tar-stream \
        -c none \
        -y \
        --skip-scan \
        --no-verify \
        --config /dev/null

    local dst_count
    dst_count=$(find "$DST_DIR" -type f | wc -l | tr -d ' ')
    [[ "$dst_count" -eq "$src_count" ]]
}

# --- parallel-rsync: verify count ---

@test "integration: parallel-rsync transfers files" {
    # create files in subdirectories so rsync has entries to partition
    mkdir -p "${SRC_DIR}/a" "${SRC_DIR}/b" "${SRC_DIR}/c"
    for i in $(seq 1 10); do
        echo "a-$i" > "${SRC_DIR}/a/file_${i}.txt"
        echo "b-$i" > "${SRC_DIR}/b/file_${i}.txt"
        echo "c-$i" > "${SRC_DIR}/c/file_${i}.txt"
    done

    local src_count
    src_count=$(find "$SRC_DIR" -type f | wc -l | tr -d ' ')

    run bash "$UFT_BIN" \
        -H localhost \
        -u "$USER" \
        -r "$SRC_DIR" \
        -l "$DST_DIR" \
        -m parallel-rsync \
        -j 2 \
        -y \
        --skip-scan \
        --no-verify \
        --config /dev/null

    local dst_count
    dst_count=$(find "$DST_DIR" -type f | wc -l | tr -d ' ')
    [[ "$dst_count" -eq "$src_count" ]]
}

# --- exclude pattern ---

@test "integration: exclude pattern removes matching files" {
    # create a mix of .txt and .tmp files
    for i in $(seq 1 5); do
        echo "keep-$i" > "${SRC_DIR}/file_${i}.txt"
        echo "skip-$i" > "${SRC_DIR}/file_${i}.tmp"
    done

    local src_txt
    src_txt=$(find "$SRC_DIR" -name '*.txt' -type f | wc -l | tr -d ' ')

    run bash "$UFT_BIN" \
        -H localhost \
        -u "$USER" \
        -r "$SRC_DIR" \
        -l "$DST_DIR" \
        -m tar-stream \
        -c none \
        -y \
        --skip-scan \
        --no-verify \
        --exclude '*.tmp' \
        --config /dev/null

    # no .tmp files should be present in destination
    local dst_tmp
    dst_tmp=$(find "$DST_DIR" -name '*.tmp' -type f | wc -l | tr -d ' ')
    [[ "$dst_tmp" -eq 0 ]]

    # .txt files should be present
    local dst_txt
    dst_txt=$(find "$DST_DIR" -name '*.txt' -type f | wc -l | tr -d ' ')
    [[ "$dst_txt" -eq "$src_txt" ]]
}

# --- path normalization: trailing slash ---

@test "integration: trailing slash does not create nested dir" {
    echo "hello" > "${SRC_DIR}/test.txt"

    # pass source with trailing slash
    run bash "$UFT_BIN" \
        -H localhost \
        -u "$USER" \
        -r "${SRC_DIR}/" \
        -l "${DST_DIR}/" \
        -m tar-stream \
        -c none \
        -y \
        --skip-scan \
        --no-verify \
        --config /dev/null

    # test.txt should be directly in DST_DIR, not in a nested subdir
    [[ -f "${DST_DIR}/test.txt" ]]
}

# --- config file loading ---

@test "integration: config file sets host and user" {
    local cfg="${TMPDIR_INT}/test.uftrc"
    cat > "$cfg" <<CONF
host = localhost
user = ${USER}
mode = tar-stream
compress = none
skip_scan = true
CONF

    echo "data" > "${SRC_DIR}/cfg_test.txt"

    run bash "$UFT_BIN" \
        -r "$SRC_DIR" \
        -l "$DST_DIR" \
        -y \
        --no-verify \
        --config "$cfg"

    [[ -f "${DST_DIR}/cfg_test.txt" ]]
}
