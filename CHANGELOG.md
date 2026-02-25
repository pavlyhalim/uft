# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-02-26

### Added
- Config file support (`~/.uftrc`) with key=value format; override with `--config`
- `--exclude PATTERN` flag (repeatable) to skip files matching glob patterns
- `--exclude-from FILE` to read exclude patterns from a file
- `--copy-links` to dereference/follow symbolic links during transfer
- `--newer DATE` to transfer only files newer than a given date (incremental)
- `--skip-scan` to bypass remote file count/size scan on huge directories
- `--keep-logs N` to control session log rotation (default: 20)
- `-J`/`--jump HOST` for SSH jump/bastion host (ProxyJump) support
- `--version` flag
- `-y`/`--yes` flag to skip confirmation prompts
- `--local-ip` flag to override auto-detected local IP for tar-nc mode
- Environment variables for all new options: `UFT_JUMP`, `UFT_NEWER`, `UFT_EXCLUDE_FROM`, `UFT_SKIP_SCAN`, `UFT_KEEP_LOGS`, `UFT_COPY_LINKS`, `UFT_CONFIG`
- Log rotation (auto-prunes old session logs based on `--keep-logs`)
- Transfer locking (prevents concurrent writes to the same destination)
- Size-based bin-packing for parallel-rsync worker assignment
- Automatic tar-nc to tar-stream fallback when a jump host is configured
- Dry-run time estimation via quick throughput probe

### Changed
- Tar modes now respect exclude patterns and `--newer` filters
- Parallel-rsync uses balanced partitioning instead of round-robin
- Bandwidth limiting extended to tar modes (requires `pv`)
- Symlink handling is now configurable (preserve vs dereference)

## [2.0.0] - 2025-02-26

### Added
- Three transfer modes: `tar-stream`, `tar-nc`, `parallel-rsync`
- Auto mode that picks the fastest available method
- Benchmark mode for SSH ciphers, raw throughput, and compression
- Resume support for `parallel-rsync` mode
- Post-transfer verification (file count, size, optional checksums)
- SSH multiplexing across all parallel rsync jobs
- Parallel netcat streams for `tar-nc` mode
- Compression auto-detection (lz4 > pigz > zstd > gzip)
- Dry-run mode
- Session logging
- Shell completions for bash, zsh, and fish
- Man page
- Homebrew-compatible install

## [1.0.0] - 2025-02-26

### Added
- Initial release
- Basic tar-over-SSH transfer
