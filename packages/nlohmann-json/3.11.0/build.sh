#!/bin/sh
set -e
VERSION="3.11.3"
SRCDIR="$SEA_PROJECT_DIR/_src"

# Use Windows system curl if available (Git Bash curl has SSL issues)
CURL="curl"
if [ -f "/c/Windows/System32/curl.exe" ]; then
    CURL="/c/Windows/System32/curl.exe"
fi

if [ ! -d "$SRCDIR/json-${VERSION}" ]; then
    mkdir -p "$SRCDIR"
    $CURL -sL "https://github.com/nlohmann/json/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xz -C "$SRCDIR"
fi
# Header-only — just copy the single-include header
mkdir -p "$SEA_INSTALL_DIR/include/nlohmann"
cp "$SRCDIR/json-${VERSION}/single_include/nlohmann/json.hpp" \
   "$SEA_INSTALL_DIR/include/nlohmann/"
# Also copy the forward declaration header
cp "$SRCDIR/json-${VERSION}/single_include/nlohmann/json_fwd.hpp" \
   "$SEA_INSTALL_DIR/include/nlohmann/" 2>/dev/null || true
echo "nlohmann-json ${VERSION} installed (header-only)"
