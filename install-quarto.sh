#!/usr/bin/env bash
set -euo pipefail

# Pick a Quarto CLI version. Update to the desired released version.
VERSION="1.4.557"
ARCH="linux-amd64"
TMPDIR="${TMPDIR:-/tmp}"

URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${VERSION}/quarto-${VERSION}-${ARCH}.tar.gz"
echo "Downloading Quarto ${VERSION} from ${URL}"
curl -fsSL "$URL" -o "$TMPDIR/quarto.tar.gz"

# Extract into $HOME/.local so binaries are available without sudo
mkdir -p "$HOME/.local"
tar -xzf "$TMPDIR/quarto.tar.gz" -C "$TMPDIR"
mv "$TMPDIR"/quarto-${VERSION}/* "$HOME/.local/"

# Ensure local bin is on PATH for the rest of the build
export PATH="$HOME/.local/bin:$PATH"
echo "Quarto installed at $HOME/.local. Version:"
quarto --version