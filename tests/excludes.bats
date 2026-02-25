#!/usr/bin/env bats

load test_helper/common

setup() {
    load_uft
    TMPDIR_EXCL=$(mktemp -d)
}

teardown() {
    rm -rf "$TMPDIR_EXCL"
}

# --- _load_excludes from file ---

@test "load_excludes reads patterns from file" {
    cat > "${TMPDIR_EXCL}/patterns.txt" <<'PAT'
*.tmp
*.log
.git
PAT
    EXCLUDES=()
    EXCLUDE_FROM="${TMPDIR_EXCL}/patterns.txt"
    _load_excludes
    [[ "${#EXCLUDES[@]}" -eq 3 ]]
    [[ "${EXCLUDES[0]}" == "*.tmp" ]]
    [[ "${EXCLUDES[1]}" == "*.log" ]]
    [[ "${EXCLUDES[2]}" == ".git" ]]
}

@test "load_excludes appends to existing EXCLUDES" {
    cat > "${TMPDIR_EXCL}/patterns.txt" <<'PAT'
*.bak
PAT
    EXCLUDES=("*.tmp")
    EXCLUDE_FROM="${TMPDIR_EXCL}/patterns.txt"
    _load_excludes
    [[ "${#EXCLUDES[@]}" -eq 2 ]]
    [[ "${EXCLUDES[0]}" == "*.tmp" ]]
    [[ "${EXCLUDES[1]}" == "*.bak" ]]
}

# --- comments and blank lines ---

@test "load_excludes ignores comments and blank lines" {
    cat > "${TMPDIR_EXCL}/patterns.txt" <<'PAT'
# ignore this
*.tmp

  # another comment

*.log
PAT
    EXCLUDES=()
    EXCLUDE_FROM="${TMPDIR_EXCL}/patterns.txt"
    _load_excludes
    [[ "${#EXCLUDES[@]}" -eq 2 ]]
    [[ "${EXCLUDES[0]}" == "*.tmp" ]]
    [[ "${EXCLUDES[1]}" == "*.log" ]]
}

# --- no-op when EXCLUDE_FROM is empty ---

@test "load_excludes is a no-op when EXCLUDE_FROM is empty" {
    EXCLUDES=("existing")
    EXCLUDE_FROM=""
    _load_excludes
    [[ "${#EXCLUDES[@]}" -eq 1 ]]
    [[ "${EXCLUDES[0]}" == "existing" ]]
}

# --- nonexistent file dies ---

@test "load_excludes dies when exclude-from file missing" {
    EXCLUDE_FROM="${TMPDIR_EXCL}/nonexistent.txt"
    run _load_excludes
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Exclude-from file not found"* ]]
}
