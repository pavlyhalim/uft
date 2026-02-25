#!/usr/bin/env bats

UFT_BIN="${BATS_TEST_DIRNAME}/../bin/uft"

# --- basics ---

@test "--help exits 0" {
    run bash "$UFT_BIN" --help
    [[ "$status" -eq 0 ]]
}

@test "--help shows usage" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"--host"* ]]
    [[ "$output" == *"--mode"* ]]
}

@test "no args exits nonzero" {
    run bash "$UFT_BIN"
    [[ "$status" -ne 0 ]]
}

@test "unknown flag exits nonzero" {
    run bash "$UFT_BIN" --bogus
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Unknown flag"* ]]
}

# --- version ---

@test "version string is v3.0.0 in help" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"v3.0.0"* ]]
}

@test "--version prints v3.0.0 and exits 0" {
    run bash "$UFT_BIN" --version
    [[ "$status" -eq 0 ]]
    [[ "$output" == "uft v3.0.0" ]]
}

# --- v2 flags still present ---

@test "--help shows v2 flags" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--yes"* ]]
    [[ "$output" == *"--local-ip"* ]]
    [[ "$output" == *"--resume"* ]]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"--checksum"* ]]
}

# --- v3 new flags in help ---

@test "--help shows --exclude" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--exclude PATTERN"* ]]
}

@test "--help shows --exclude-from" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--exclude-from FILE"* ]]
}

@test "--help shows --copy-links" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--copy-links"* ]]
}

@test "--help shows --newer" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--newer DATE"* ]]
}

@test "--help shows --skip-scan" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--skip-scan"* ]]
}

@test "--help shows --keep-logs" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--keep-logs"* ]]
}

@test "--help shows --config" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--config PATH"* ]]
}

@test "--help shows -J/--jump" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"-J, --jump"* ]]
}

@test "--help shows --version" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"--version"* ]]
}

# --- config file section in help ---

@test "--help shows CONFIG FILE section" {
    run bash "$UFT_BIN" --help
    [[ "$output" == *"CONFIG FILE"* ]]
    [[ "$output" == *".uftrc"* ]]
}
