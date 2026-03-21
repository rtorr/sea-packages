#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

PREFIX_PATH=""
for dep in "$SEA_PACKAGES_DIR"/*/; do
    [ -d "$dep" ] && PREFIX_PATH="${PREFIX_PATH:+$PREFIX_PATH;}$dep"
done

# libevent's cmake config files embed absolute build paths (non-relocatable).
# Remove them so folly falls back to find_library() with our explicit hints.
rm -rf "$SEA_PACKAGES_DIR/libevent/lib/cmake" 2>/dev/null || true

# Find sea's libevent library
LIBEVENT_LIB=$(find "$SEA_PACKAGES_DIR/libevent/lib" \
    -name "libevent-2*.dylib" -o -name "libevent-2*.so*" \
    -o -name "libevent_core.lib" -o -name "libevent.a" \
    2>/dev/null | head -1)
LIBEVENT_INC="$SEA_PACKAGES_DIR/libevent/include"

CMAKE_EXTRA=""
if [ -n "$LIBEVENT_LIB" ] && [ -d "$LIBEVENT_INC" ]; then
    CMAKE_EXTRA="-DLIBEVENT_LIB=$LIBEVENT_LIB -DLIBEVENT_INCLUDE_DIR=$LIBEVENT_INC"
fi

mkdir -p "$SEA_PROJECT_DIR/_fbuild" && cd "$SEA_PROJECT_DIR/_fbuild"

# On Windows, force Ninja generator to avoid multi-config issues with
# Visual Studio generator (folly's pkg-config generation breaks with it).
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
    -DCMAKE_PREFIX_PATH="$PREFIX_PATH" \
    -DCMAKE_CXX_STANDARD=17 \
    -DBUILD_TESTS=OFF \
    -DFOLLY_HAVE_LIBUNWIND=OFF \
    -DFOLLY_USE_JEMALLOC=OFF \
    $CMAKE_EXTRA

cmake --build . --config Release -j2
cmake --install . --config Release
echo "folly built"
