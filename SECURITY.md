# Security Policy

## Scope

uft transfers files over SSH and optionally over raw TCP (tar-nc mode).
Security-relevant areas:

- **SSH connections** — uft uses the system `ssh` binary with standard options.
  It does not implement its own cryptography.
- **tar-nc mode** — sends data unencrypted over TCP. This is opt-in and the
  tool warns before use. Only use on trusted networks.
- **Remote command execution** — uft runs commands on the remote host via SSH.
  All paths are escaped with `printf %q` to prevent injection.
- **Config file** — `~/.uftrc` is read at startup. Protect it with `chmod 600`
  if it contains sensitive values.

## Supported versions

| Version | Supported |
|---------|-----------|
| 3.x     | Yes       |
| < 3.0   | No        |

## Reporting a vulnerability

Email **pavlyhalim@gmail.com** with:

- Description of the issue
- Steps to reproduce
- Impact assessment

You'll get a response within 48 hours. Please do not open a public issue for
security vulnerabilities.
