#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

# Patch: CMP0026 OLD is removed in modern cmake. Since we build with
# HERMES_BUILD_APPLE_FRAMEWORK=OFF, this policy is not needed.
sed -i.bak 's/cmake_policy(SET CMP0026 OLD)/cmake_policy(SET CMP0026 NEW)/' "$SRCDIR/CMakeLists.txt"

mkdir -p "$SEA_PROJECT_DIR/_hbuild" && cd "$SEA_PROJECT_DIR/_hbuild"

cmake "$SRCDIR" \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_CXX_STANDARD=17 \
    -DHERMES_BUILD_APPLE_FRAMEWORK=OFF \
    -DHERMES_ENABLE_TEST_SUITE=OFF

cmake --build . --config Release -j2
cmake --install . --config Release
echo "hermes built"
