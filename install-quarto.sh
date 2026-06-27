#!/usr/bin/env bash
set -euo pipefail

VERSION="1.4.557"
TMPDIR="/tmp"
ARCHIVE="quarto-${VERSION}-linux-amd64.tar.gz"
URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${VERSION}/${ARCHIVE}"

curl -L -o "${TMPDIR}/${ARCHIVE}" "${URL}"
tar -xzf "${TMPDIR}/${ARCHIVE}" -C "${TMPDIR}"

# find the extracted directory (handles suffix like "-linux-amd64")
EXTRACTED_DIR=$(find "${TMPDIR}" -maxdepth 1 -type d -name "quarto-${VERSION}*" | head -n 1)
if [ -z "${EXTRACTED_DIR}" ]; then
  echo "Error: extracted Quarto directory not found in ${TMPDIR}"
  exit 1
fi

# copy contents (adjust destination as needed)
cp -r "${EXTRACTED_DIR}/." /usr/local/