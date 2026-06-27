#!/usr/bin/env bash
set -euo pipefail

# Pick a Quarto CLI version. Update to the desired released version.
VERSION="1.4.557"
ARCH="linux-amd64"
TMPDIR="${TMPDIR:-/tmp}"

URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${VERSION}/quarto-${VERSION}-${ARCH}.tar.gz"
echo "Downloading Quarto ${VERSION} from ${URL}"
curl -fsSL "$URL" -o "$TMPDIR/quarto.tar.gz"

# ensure destination exists
mkdir -p "$HOME/.local"

# copy all files into ~/.local (preserves permissions)
cp -a "$TMPDIR/quarto-$VERSION/." "$HOME/.local/"

# ensure bin is on PATH for the current shell so the next command finds 'quarto'
export PATH="$HOME/.local/bin:$PATH"

# optionally remove tmp
rm -rf "$TMPDIR/quarto-$VERSION"