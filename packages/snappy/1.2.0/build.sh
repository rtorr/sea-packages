#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

# Patch: enable RTTI and default visibility (folly needs typeinfo from snappy)
sed 's/-fno-rtti/-frtti/g; s/-fvisibility=hidden/-fvisibility=default/g' "$SRCDIR/CMakeLists.txt" > "$SRCDIR/CMakeLists.txt.patched"
mv "$SRCDIR/CMakeLists.txt.patched" "$SRCDIR/CMakeLists.txt"

mkdir -p "$SEA_PROJECT_DIR/_build" && cd "$SEA_PROJECT_DIR/_build"
cmake "$SRCDIR" \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DBUILD_SHARED_LIBS=ON \
    -DSNAPPY_BUILD_TESTS=OFF \
    -DSNAPPY_BUILD_BENCHMARKS=OFF

cmake --build . --config Release -j2
cmake --install . --config Release
echo "snappy built"
