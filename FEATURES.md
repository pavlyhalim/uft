# Features Roadmap

What's done, what's next, and what's planned.

## Shipped (v3.0.0)

- Three transfer modes: tar-stream, tar-nc, parallel-rsync
- Auto-detection of fastest mode, cipher, and compressor
- Config file (~/.uftrc) with CLI override
- Exclude patterns (--exclude, --exclude-from)
- Jump/bastion host support (-J)
- Incremental transfers (--newer)
- Symlink control (--copy-links)
- Resume for parallel-rsync mode
- Post-transfer verification (file count, size, optional md5)
- SSH multiplexing across all parallel workers
- Size-based bin-packing for balanced parallel-rsync
- Partial transfer detection with forced verification
- Scan spinner, skip-scan for huge directories
- Log rotation (--keep-logs)
- Lock files to prevent concurrent writes
- Bandwidth limiting for all modes (--bwlimit)
- Bash/zsh/fish completions, man page
- Interactive dependency installer (--setup)
- Dry-run with time estimation
- Homebrew tap, Dockerfile, GitHub Pages docs

## Next (v3.1.0)

### Must-have

- [ ] `--quiet` flag. Suppress all output except errors. For cron jobs, scripts, piping.
- [ ] `--verbose` / `--debug` flag. Print every command being run, SSH options, tar flags. For troubleshooting when things break on someone's weird server.
- [ ] `--retries N` flag. Auto-retry the transfer N times on failure before giving up. Networks drop. This is expected. Default: 0 (no retry).
- [ ] Atomic writes. Tar-stream currently extracts directly into the destination. If it fails mid-transfer, you get a mix of complete and truncated files. Fix: write to a temp directory (`$LOCAL_PATH/.uft-tmp/`), verify, then rename into place. On failure, the temp dir is left for inspection.
- [ ] `--delete` flag. For parallel-rsync mode, pass `--delete` to rsync so local files that no longer exist on the remote are removed. Brings uft closer to a real sync tool.
- [ ] Document SSH config host aliases. uft already supports `uft -H myserver` where `myserver` is defined in `~/.ssh/config`. SSH handles it. But nobody knows this because it's not in the docs.

### Should-have

- [ ] `--on-complete CMD` flag. Run a command after transfer finishes. Use cases: `notify-send "done"`, `curl webhook`, `say "transfer complete"`, `slack-notify`. No file transfer tool does this.
- [ ] `uft history` subcommand. Parse log files and show a table of past transfers: date, source, dest, file count, size, speed, status (ok/fail). Useful for auditing.
- [ ] `--json` output flag. Print structured JSON instead of human text. For scripting and automation. People pipe output into jq.
- [ ] `--include PATTERN` flag. rsync has include patterns. Right now we only have exclude. Include is the inverse: transfer ONLY files matching the pattern.
- [ ] `--min-size SIZE` / `--max-size SIZE` flags. Filter files by size. rsync has this. Use case: skip huge video files, only transfer small frames.
- [ ] Progress percentage for tar-stream. We have TOTAL_BYTES from the scan but don't pass it to pv. For compressed streams the exact percentage is off, but an approximate ETA is better than nothing.
- [ ] `--profile NAME` flag. Load a named section from the config file. Use case: `uft --profile staging` reads `[staging]` section from ~/.uftrc with different host/user/path.

### Nice-to-have

- [ ] `uft clean` subcommand. Remove old logs, manifests, resume state, and lock files. With `--dry-run` to preview.
- [ ] Notification on completion. Desktop notification via `osascript` (macOS) or `notify-send` (Linux) when transfer finishes. Opt-in via `--notify`.
- [ ] `--checksum-full` flag. Verify ALL files with checksums, not just 100 random samples. Slow but thorough.
- [ ] `--dry-run` file list. Show exactly which files would be transferred without transferring them.
- [ ] Bandwidth auto-detection. Run a quick throughput test and automatically set bwlimit to avoid saturating shared links.

## Infrastructure (v3.1.0)

- [ ] Docker-based CI with real SSH. Spin up an sshd container, run integration tests against it. Eliminates the "5 tests skipped" problem.
- [ ] macOS CI runner. Test on both Ubuntu and macOS in the matrix. Catches macOS-specific bugs (du -sb, rsync version, homebrew PATH).
- [ ] Published Docker image on GHCR. `docker run ghcr.io/pavlyhalim/uft` instead of building from Dockerfile.
- [ ] AUR package (PKGBUILD). Arch users are early adopters for CLI tools.
- [ ] Nix flake. Nix users expect this.
- [ ] GitHub Actions workflow for auto-updating homebrew formula on release.

## Not planned

Things that are out of scope. uft is a one-directional bulk transfer tool over SSH. It is not:

- A bidirectional sync tool (use rsync --delete or rclone bisync)
- A cloud storage client (use rclone)
- An ad-hoc file sharing tool (use croc or magic-wormhole)
- A backup tool (use restic or borg)
- A GUI application

uft does one thing: move a directory tree from a remote server to your local machine, as fast as possible, over SSH.
