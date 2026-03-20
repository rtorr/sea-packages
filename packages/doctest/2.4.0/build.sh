#!/bin/sh
set -e
VERSION="2.4.11"
SRCDIR="$SEA_PROJECT_DIR/_src"

# Use Windows system curl if available (Git Bash curl has SSL issues)
CURL="curl"
if [ -f "/c/Windows/System32/curl.exe" ]; then
    CURL="/c/Windows/System32/curl.exe"
fi

if [ ! -d "$SRCDIR/doctest-${VERSION}" ]; then
    mkdir -p "$SRCDIR"
    $CURL -sL "https://github.com/doctest/doctest/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xz -C "$SRCDIR"
fi
mkdir -p "$SEA_INSTALL_DIR/include/doctest"
cp "$SRCDIR/doctest-${VERSION}/doctest/doctest.h" "$SEA_INSTALL_DIR/include/doctest/"
echo "doctest ${VERSION} installed (header-only)"
