#!/usr/bin/env bats

load test_helper/common

setup() {
    load_uft
    LOCK_DIR=$(mktemp -d)
    LOCAL_PATH="/tmp/uft-test-$$"
}

teardown() {
    rm -rf "$LOCK_DIR" "$LOCAL_PATH"
}

@test "acquire_lock creates lock file" {
    _acquire_lock
    [[ -f "$LOCK_FILE" ]]
    [[ "$(cat "$LOCK_FILE")" == "$$" ]]
}

@test "acquire_lock removes stale lock" {
    local lock_key
    lock_key=$(printf '%s' "${LOCAL_PATH}" | tr '/' '_')
    LOCK_FILE="${LOCK_DIR}/uft_${lock_key}.lock"
    echo "99999" > "$LOCK_FILE"
    # pid 99999 shouldn't exist
    _acquire_lock
    [[ "$(cat "$LOCK_FILE")" == "$$" ]]
}
