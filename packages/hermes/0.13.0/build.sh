#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

# Patch: CMP0026 OLD is removed in modern cmake. Since we build with
# HERMES_BUILD_APPLE_FRAMEWORK=OFF, this policy is not needed.
sed -i.bak 's/cmake_policy(SET CMP0026 OLD)/cmake_policy(SET CMP0026 NEW)/' "$SRCDIR/CMakeLists.txt"

# Patch: GCC 13+ requires explicit #include <string> in DomainState.cpp
# (std::string is incomplete without it; clang/older GCC include it transitively)
if ! grep -q '#include <string>' "$SRCDIR/API/hermes/cdp/DomainState.cpp" 2>/dev/null; then
    sed -i.bak '1s/^/#include <string>\n/' "$SRCDIR/API/hermes/cdp/DomainState.cpp"
fi

mkdir -p "$SEA_PROJECT_DIR/_hbuild" && cd "$SEA_PROJECT_DIR/_hbuild"

# On Windows, force Ninja to avoid multi-config Visual Studio generator issues
CMAKE_GEN=""
if [ "$SEA_OS" = "windows" ] || [ -n "$WINDIR" ]; then
    CMAKE_GEN="-G Ninja"
fi

cmake "$SRCDIR" \
    $CMAKE_GEN \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_CXX_STANDARD=17 \
    -DHERMES_BUILD_APPLE_FRAMEWORK=OFF \
    -DHERMES_ENABLE_TEST_SUITE=OFF \
    -DHERMES_ENABLE_TOOLS=ON

cmake --build . --config Release -j2
cmake --install . --config Release
echo "hermes built"
