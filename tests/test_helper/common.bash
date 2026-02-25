#!/usr/bin/env bash

# source the main script without running main()
UFT_BIN="${BATS_TEST_DIRNAME}/../bin/uft"

load_uft() {
    # override colors to empty for clean test output
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; MAGENTA=''
    BOLD=''; DIM=''; NC=''

    # stub _log_file so log functions don't fail
    _log_file="/dev/null"

    # reset v3 arrays that may persist between tests
    EXCLUDES=()
    EXCLUDE_FROM=""

    source "$UFT_BIN"
}
