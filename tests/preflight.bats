#!/usr/bin/env bats

load test_helper/common

setup() {
    load_uft
}

# --- argument validation ---

@test "dies without --host" {
    REMOTE_HOST=""
    REMOTE_USER="test"
    REMOTE_PATH="/tmp"
    LOCAL_PATH="/tmp"
    run _preflight
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Missing --host"* ]]
}

@test "dies without --user" {
    REMOTE_HOST="box"
    REMOTE_USER=""
    REMOTE_PATH="/tmp"
    LOCAL_PATH="/tmp"
    run _preflight
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Missing --user"* ]]
}

@test "dies without --remote-path" {
    REMOTE_HOST="box"
    REMOTE_USER="test"
    REMOTE_PATH=""
    LOCAL_PATH="/tmp"
    run _preflight
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Missing --remote-path"* ]]
}

@test "dies without --local-path" {
    REMOTE_HOST="box"
    REMOTE_USER="test"
    REMOTE_PATH="/tmp"
    LOCAL_PATH=""
    run _preflight
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Missing --local-path"* ]]
}
