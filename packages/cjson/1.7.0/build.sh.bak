#!/bin/sh
set -e
VERSION="1.7.17"
SRCDIR="$SEA_PROJECT_DIR/_src"

download() {
    URL="$1"; DEST="$2"
    if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '$URL' -OutFile '$DEST'"
    else
        curl -fSL --retry 3 -o "$DEST" "$URL"
    fi
}

if [ ! -d "$SRCDIR/cJSON-${VERSION}" ]; then
    mkdir -p "$SRCDIR"
    download "https://github.com/DaveGamble/cJSON/archive/refs/tags/v${VERSION}.tar.gz" "$SRCDIR/cjson.tar.gz"
    tar xzf "$SRCDIR/cjson.tar.gz" -C "$SRCDIR"
fi

cd "$SRCDIR/cJSON-${VERSION}"
rm -rf _build && mkdir _build && cd _build

CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_PREFIX=$SEA_INSTALL_DIR -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DENABLE_CJSON_TEST=OFF"
[ -n "$CC" ] && CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_C_COMPILER=$CC"

cmake .. $CMAKE_ARGS 2>&1
cmake --build . --config Release -j4 2>&1
cmake --install . --config Release 2>&1
echo "cJSON ${VERSION} built"
