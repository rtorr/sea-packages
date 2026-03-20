#!/bin/sh
set -e
VERSION="1.10.0"
SRCDIR="$SEA_PROJECT_DIR/_src"

if [ ! -d "$SRCDIR/lz4-${VERSION}" ]; then
    mkdir -p "$SRCDIR"
    curl -sSfL -o "$SRCDIR/lz4.tar.gz" \
        "https://github.com/lz4/lz4/archive/refs/tags/v${VERSION}.tar.gz"
    tar xzf "$SRCDIR/lz4.tar.gz" -C "$SRCDIR"
fi

cd "$SRCDIR/lz4-${VERSION}"
mkdir -p _build && cd _build

CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_PREFIX=$SEA_INSTALL_DIR -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=ON -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF"
if [ -n "$CC" ]; then
    CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_C_COMPILER=$CC"
fi

cmake ../build/cmake $CMAKE_ARGS 2>&1
cmake --build . --config Release -j4 2>&1
cmake --install . --config Release 2>&1
echo "lz4 ${VERSION} built"
