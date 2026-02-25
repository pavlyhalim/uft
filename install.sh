#!/usr/bin/env bash
#
# uft installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/pavly/uft/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/pavly/uft/main/install.sh | bash
#

set -euo pipefail

REPO="https://github.com/pavlyhalim/uft.git"
INSTALL_DIR="${UFT_INSTALL_DIR:-/usr/local}"
CLONE_DIR="${HOME}/.uft-src"

info() { echo "  -> $*"; }
fail() { echo "error: $*" >&2; exit 1; }

echo "uft installer"
echo ""

# check deps
command -v git  >/dev/null 2>&1 || fail "git is required"
command -v bash >/dev/null 2>&1 || fail "bash is required"

# clone or pull
if [[ -d "$CLONE_DIR/.git" ]]; then
    info "updating existing clone..."
    git -C "$CLONE_DIR" pull --quiet
else
    info "cloning $REPO..."
    git clone --quiet --depth 1 "$REPO" "$CLONE_DIR"
fi

# install
info "installing to ${INSTALL_DIR}..."
cd "$CLONE_DIR"

if [[ -w "${INSTALL_DIR}/bin" ]]; then
    make install PREFIX="$INSTALL_DIR"
else
    sudo make install PREFIX="$INSTALL_DIR"
fi

# verify
if command -v uft >/dev/null 2>&1; then
    echo ""
    echo "done. run 'uft --help' to get started."
else
    echo ""
    echo "done. make sure ${INSTALL_DIR}/bin is in your PATH."
fi
