#!/bin/sh
set -e
VERSION="1.7.17"
SRCDIR="$SEA_PROJECT_DIR/_src"

if [ ! -d "$SRCDIR/cJSON-${VERSION}" ]; then
    mkdir -p "$SRCDIR"
    # Use curl with explicit retry and timeout
    curl -fSL --retry 3 --connect-timeout 30 \
        -o "$SRCDIR/cjson.tar.gz" \
        "https://github.com/DaveGamble/cJSON/archive/refs/tags/v${VERSION}.tar.gz"
    tar xzf "$SRCDIR/cjson.tar.gz" -C "$SRCDIR"
fi

cd "$SRCDIR/cJSON-${VERSION}"
rm -rf _build && mkdir _build && cd _build

CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_PREFIX=$SEA_INSTALL_DIR -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DENABLE_CJSON_TEST=OFF"
[ -n "$CC" ] && CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_C_COMPILER=$CC"

cmake .. $CMAKE_ARGS
cmake --build . --config Release -j4
cmake --install . --config Release
echo "cJSON ${VERSION} built"
