#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"
cd "$SRCDIR"

# Bootstrap b2
if [ ! -f "./b2" ] && [ ! -f "./b2.exe" ]; then
    if [ -f "./bootstrap.sh" ]; then
        ./bootstrap.sh
    elif [ -f "./bootstrap.bat" ]; then
        cmd /c bootstrap.bat
    fi
fi

# Build the specific libraries folly needs
B2="./b2"
[ -f "./b2.exe" ] && B2="./b2.exe"

$B2 \
    --prefix="$SEA_INSTALL_DIR" \
    --with-context \
    --with-filesystem \
    --with-program_options \
    --with-regex \
    --with-system \
    --with-thread \
    variant=release \
    link=shared \
    threading=multi \
    runtime-link=shared \
    install \
    -j4

echo "Boost 1.83.0 compiled libraries built"
