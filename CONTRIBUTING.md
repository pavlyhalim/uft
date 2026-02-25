# Contributing

Thanks for considering a contribution.

## Setup

```bash
git clone https://github.com/pavlyhalim/uft.git
cd uft
make deps-dev   # installs shellcheck, bats, shfmt
```

## Development loop

```bash
# edit bin/uft
make lint        # shellcheck
make fmt         # shfmt (auto-formats in place)
make test        # bats (85 tests)
make check       # both
```

## Before submitting a PR

1. Run `make check` — must pass clean
2. Add tests for new flags or behavior in `tests/`
3. Update `man/uft.1` if you added flags
4. Update `completions/` (bash, zsh, fish) for new flags
5. Update `CHANGELOG.md` under `[Unreleased]`

## Code style

- `shfmt -i 4 -ci` formatting (enforced in CI)
- No comments that restate the code
- Section headers: `# --- section name ---`
- Functions prefixed with `_` (private convention)
- Use `_rquote` for all remote paths
- Use `_decompress_pipe` instead of `eval` for decompression
- Test with `bats` — unit tests for helpers, integration tests for transfers

## Tests

Unit tests run everywhere. Integration tests (`tests/integration.bats`) need
passwordless SSH to localhost and are skipped in CI.

To run integration tests locally:

```bash
# enable Remote Login in System Settings (macOS)
# or: sudo systemsetup -setremotelogin on
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
bats tests/integration.bats
```

## Reporting bugs

Open an issue with:
- Your OS and bash version (`bash --version`)
- The full command you ran
- The error output
- The remote OS if relevant
