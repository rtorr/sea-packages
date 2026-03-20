#!/bin/sh
set -e
VERSION="1.10.0"
SRCDIR="$SEA_PROJECT_DIR/_src"

if [ ! -d "$SRCDIR/lz4-${VERSION}" ]; then
    mkdir -p "$SRCDIR"
    curl -sL "https://github.com/lz4/lz4/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xz -C "$SRCDIR"
fi

cd "$SRCDIR/lz4-${VERSION}"

# Use CMake (works on Linux, macOS, and Windows)
mkdir -p _build && cd _build
cmake ../build/cmake \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${CC:-cc}" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=ON \
    -DLZ4_BUILD_CLI=OFF \
    -DLZ4_BUILD_LEGACY_LZ4C=OFF \
    2>&1
cmake --build . --config Release -j4 2>&1
cmake --install . --config Release 2>&1
echo "lz4 ${VERSION} built"
