#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"
cd "$SRCDIR"

# Detect Windows (Git Bash on CI)
IS_WINDOWS=false
if [ "$SEA_OS" = "windows" ] || [ -n "$WINDIR" ]; then
    IS_WINDOWS=true
fi

# Bootstrap b2
if [ ! -f "./b2" ] && [ ! -f "./b2.exe" ]; then
    if [ "$IS_WINDOWS" = true ]; then
        cmd //c bootstrap.bat
    else
        ./bootstrap.sh
    fi
fi

# Build the specific libraries folly needs
B2="./b2"
[ -f "./b2.exe" ] && B2="./b2.exe"

B2_ARGS=""
if [ "$IS_WINDOWS" = true ]; then
    B2_ARGS="toolset=msvc address-model=64"
fi

$B2 \
    --prefix="$SEA_INSTALL_DIR" \
    --with-context \
    --with-filesystem \
    --with-program_options \
    --with-regex \
    --with-system \
    --with-thread \
    variant=release \
    link=static,shared \
    threading=multi \
    runtime-link=shared \
    install \
    -j4 \
    $B2_ARGS

echo "Boost 1.83.0 compiled libraries built"
