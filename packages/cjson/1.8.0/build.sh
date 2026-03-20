#!/bin/sh
set -e
VERSION="1.7.17"
SRCDIR="$SEA_PROJECT_DIR/_src"

if [ ! -d "$SRCDIR/cJSON-${VERSION}" ]; then
    mkdir -p "$SRCDIR"
    curl -sL "https://github.com/DaveGamble/cJSON/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xz -C "$SRCDIR"
fi

cd "$SRCDIR/cJSON-${VERSION}"

# Use CMake (works on Linux, macOS, and Windows)
mkdir -p _build && cd _build
cmake .. \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${CC:-cc}" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_CJSON_TEST=OFF \
    2>&1
cmake --build . --config Release -j4 2>&1
cmake --install . --config Release 2>&1
echo "cJSON ${VERSION} built"
