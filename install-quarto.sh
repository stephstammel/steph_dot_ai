#!/usr/bin/env bash
set -euo pipefail

QUARTO_VERSION="1.9.38"

URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"

TMPDIR="$(mktemp -d)"
curl -L "${URL}" -o "${TMPDIR}/quarto.tgz"

DEST="$HOME/.local/quarto"
rm -rf "$DEST"
mkdir -p "$DEST"

tar -xzf "${TMPDIR}/quarto.tgz" -C "$DEST" --strip-components=1

export PATH="$DEST/bin:$PATH"

quarto --version