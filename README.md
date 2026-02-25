<p align="center">
<pre align="center">
         _____ _____
 _ _ ___|_   _|     |
| | |  _| | | |-   -|
|___|_|   |_| |_____|

 ultrafast transfer
</pre>
</p>

<p align="center">
  Bulk file transfer over SSH. Moves 100K-1M+ files fast.
</p>

<p align="center">
  <a href="https://github.com/pavlyhalim/uft/actions/workflows/ci.yml"><img src="https://github.com/pavlyhalim/uft/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://github.com/pavlyhalim/uft/releases"><img src="https://img.shields.io/badge/release-v3.0.0-green.svg" alt="Release v3.0.0"></a>
</p>

<p align="center">
  <img src="docs/demo.gif" alt="uft demo" width="700">
</p>

---

## Why

`scp` and `rsync` open a separate channel for every file. On a link with
20ms latency, transferring 100K files means 100K round-trips -- **33 minutes
of pure waiting** before a single byte of data moves.

uft bundles everything into one tar stream. One pipe, zero per-file overhead.
Transfer time depends on data size and bandwidth, not file count.

## Install

```bash
# homebrew
brew install pavlyhalim/tap/uft

# or from source
git clone https://github.com/pavlyhalim/uft.git && cd uft && make install

# or one-liner
curl -fsSL https://raw.githubusercontent.com/pavlyhalim/uft/main/install.sh | bash
```

Optional speed tools (auto-detected):

```bash
brew install lz4 pv          # macOS
sudo apt install lz4 pv      # Ubuntu/Debian
uft --setup                   # interactive dependency check
```

## Quick start

```bash
uft -H server.com -u deploy -r /data/frames -l ./frames
```

That's it. uft handles cipher selection, compression, progress, and verification.

```bash
# maximum speed on a trusted network
uft -H 10.0.0.5 -u root -r /data -l ./data -m tar-nc -s 8

# resumable transfer
uft -H server.com -u admin -r /data -l ./data -m parallel-rsync -j 16

# resume after interruption
uft -H server.com -u admin -r /data -l ./data -m parallel-rsync --resume

# through a bastion host
uft -H internal.lan -u deploy -r /data -l ./data -J bastion.example.com

# skip .git and log files
uft -H srv -u deploy -r /data -l ./data --exclude '.git' --exclude '*.log'

# only files changed since last week
uft -H srv -u deploy -r /data -l ./data --newer '2025-06-01'

# benchmark your link
uft -H server.com -u admin -r /data -l ./data -m benchmark

# dry run with time estimate
uft -H server.com -u admin -r /data -l ./data --dry-run
```

## Modes

| Mode | Encrypted | Resumable | Best for |
|------|-----------|-----------|----------|
| `tar-stream` | yes | no | Bulk downloads, high file counts |
| `tar-nc` | no | no | Trusted networks, max throughput |
| `parallel-rsync` | yes | yes | Incremental sync, resumable transfers |

```
tar-stream:  remote: tar | lz4 --> SSH --> lz4 -d | tar :local
tar-nc:      remote: tar | lz4 --> TCP --> lz4 -d | tar :local
rsync:       N workers over one SSH mux, size-balanced bin-packing
```

Speed depends on your network. Run `uft -m benchmark` to measure your link.

## What it does

1. **Preflight** -- SSH check, remote scan, disk space
2. **Tool detection** -- probes both ends for lz4, pv, nc, rsync
3. **Transfer** -- picks the fastest available mode
4. **Verify** -- compares file counts and sizes

## Config file

Create `~/.uftrc` to set defaults. CLI flags always win.

```ini
host = server.com
user = deploy
compress = lz4
jobs = 12
jump = bastion.example.com
exclude = *.log
exclude = .git
keep_logs = 30
```

<details>
<summary>All supported keys</summary>

`host`, `user`, `remote_path`, `local_path`, `port`, `key`, `mode`,
`compress`, `jobs`, `streams`, `nc_port`, `verify`, `bwlimit`, `local_ip`,
`symlinks`, `jump`, `keep_logs`, `exclude` (repeatable), `exclude_from`,
`newer`, `skip_scan`

</details>

## All flags

| Flag | Description | Default |
|------|-------------|---------|
| `-H, --host` | Remote hostname or IP | required |
| `-u, --user` | SSH username | required |
| `-r, --remote-path` | Source directory | required |
| `-l, --local-path` | Local destination | required |
| `-m, --mode` | `auto` `tar-stream` `tar-nc` `parallel-rsync` `benchmark` | `auto` |
| `-c, --compress` | `auto` `lz4` `pigz` `zstd` `gzip` `none` | `auto` |
| `-j, --jobs` | Parallel rsync workers | `8` |
| `-s, --streams` | Parallel netcat streams | `4` |
| `-p, --port` | SSH port | `22` |
| `-k, --key` | SSH key file | |
| `-b, --bwlimit` | Bandwidth cap in KB/s | |
| `-J, --jump` | SSH jump/bastion host | |
| `--exclude` | Exclude pattern (repeatable) | |
| `--exclude-from` | Read excludes from file | |
| `--copy-links` | Follow symlinks | off |
| `--newer` | Only files newer than date | |
| `--skip-scan` | Skip remote file scan | off |
| `--keep-logs` | Session logs to keep | `20` |
| `--config` | Config file path | `~/.uftrc` |
| `--resume` | Resume interrupted transfer | |
| `--checksum` | Spot-check md5 on 100 files | |
| `--dry-run` | Preflight + time estimate | |
| `--setup` | Check and install dependencies | |
| `--tuning` | Print network tuning tips | |
| `-y, --yes` | Skip prompts | |
| `--version` | Print version | |

<details>
<summary>Environment variables</summary>

All flags can be set via `UFT_*` env vars:

```bash
export UFT_HOST=server.com
export UFT_USER=deploy
uft -r /data -l ./data
```

Full list: `UFT_HOST`, `UFT_USER`, `UFT_REMOTE`, `UFT_LOCAL`, `UFT_PORT`,
`UFT_KEY`, `UFT_MODE`, `UFT_COMPRESS`, `UFT_JOBS`, `UFT_STREAMS`,
`UFT_VERIFY`, `UFT_JUMP`, `UFT_NEWER`, `UFT_EXCLUDE_FROM`,
`UFT_SKIP_SCAN`, `UFT_KEEP_LOGS`, `UFT_COPY_LINKS`, `UFT_CONFIG`

</details>

## Requirements

| | |
|---|---|
| **Required** | bash 4+, ssh, tar |
| **Recommended** | lz4 (faster compression), pv (progress bar) |
| **Optional** | zstd, pigz, rsync, nc/ncat |

Run `uft --setup` to check what's installed and optionally install missing tools.

## Contributing

```bash
make deps-dev    # install shellcheck, bats, shfmt
make check       # lint + test
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

[MIT](LICENSE)
