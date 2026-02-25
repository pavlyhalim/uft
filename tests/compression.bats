#!/usr/bin/env bats

load test_helper/common

setup() {
    load_uft
    LOCAL_TOOLS=()
    REMOTE_TOOLS=()
}

@test "selects lz4 when available on both ends" {
    LOCAL_TOOLS=("lz4" "gzip")
    REMOTE_TOOLS=("lz4" "gzip")
    COMPRESS="auto"
    _select_compressor
    [[ "$COMPRESS" == "lz4" ]]
}

@test "falls back to pigz when lz4 missing" {
    LOCAL_TOOLS=("pigz" "gzip")
    REMOTE_TOOLS=("pigz" "gzip")
    COMPRESS="auto"
    _select_compressor
    [[ "$COMPRESS" == "pigz" ]]
}

@test "falls back to zstd when lz4 and pigz missing" {
    LOCAL_TOOLS=("zstd" "gzip")
    REMOTE_TOOLS=("zstd" "gzip")
    COMPRESS="auto"
    _select_compressor
    [[ "$COMPRESS" == "zstd" ]]
}

@test "falls back to gzip as last resort" {
    LOCAL_TOOLS=("gzip")
    REMOTE_TOOLS=("gzip")
    COMPRESS="auto"
    _select_compressor
    [[ "$COMPRESS" == "gzip" ]]
}

@test "falls back to none when nothing matches" {
    LOCAL_TOOLS=("tar")
    REMOTE_TOOLS=("tar")
    COMPRESS="auto"
    _select_compressor
    [[ "$COMPRESS" == "none" ]]
}

@test "respects user-forced compression" {
    LOCAL_TOOLS=("lz4" "gzip")
    REMOTE_TOOLS=("lz4" "gzip")
    COMPRESS="gzip"
    _select_compressor
    [[ "$COMPRESS" == "gzip" ]]
}

@test "needs both ends to have the tool" {
    LOCAL_TOOLS=("lz4" "gzip")
    REMOTE_TOOLS=("gzip")
    COMPRESS="auto"
    _select_compressor
    [[ "$COMPRESS" == "gzip" ]]
}
