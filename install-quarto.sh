#!/usr/bin/env bash
set -euo pipefail

# Quarto version to install
QUARTO_VERSION="1.9.38"

URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"

TMPDIR="$(mktemp -d)"
curl -L "${URL}" -o "${TMPDIR}/quarto.tgz"

# Install into a user-writable location
DEST="$HOME/.local/quarto"
mkdir -p "$DEST"
tar -xzf "${TMPDIR}/quarto.tgz" -C "$DEST" --strip-components=1

# Make Quarto available in the current shell and for subsequent Netlify steps
export PATH="$DEST/bin:$PATH"
echo "export PATH=\"$DEST/bin:\$PATH\"" >> "$BASH_ENV"

# Verify the installation
quarto --version
quarto check install