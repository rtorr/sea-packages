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

# Pass explicit paths for deps whose cmake Find modules use non-standard variable names.
# Folly ships its own FindDoubleConversion.cmake which doesn't respect CMAKE_PREFIX_PATH.
# Debug: show what's in the double-conversion package
echo "SEA_PACKAGES_DIR=$SEA_PACKAGES_DIR"
echo "double-conversion contents:"
find "$SEA_PACKAGES_DIR/double-conversion" -type f 2>/dev/null | head -20
echo "---"

DC_LIB=$(find "$SEA_PACKAGES_DIR/double-conversion/lib" -name "libdouble-conversion.*" -o -name "double-conversion.lib" 2>/dev/null | head -1)
DC_INC="$SEA_PACKAGES_DIR/double-conversion/include"
echo "DC_LIB=$DC_LIB"
echo "DC_INC=$DC_INC"
if [ -n "$DC_LIB" ]; then
    CMAKE_EXTRA="$CMAKE_EXTRA -DDOUBLE_CONVERSION_LIBRARY=$DC_LIB -DDOUBLE_CONVERSION_INCLUDE_DIR=$DC_INC"
    echo "Passing DOUBLE_CONVERSION paths to cmake"
else
    echo "WARNING: could not find double-conversion library"
fi

mkdir -p "$SEA_PROJECT_DIR/_fbuild" && cd "$SEA_PROJECT_DIR/_fbuild"

# Windows: use VS generator with MSVC, build static (folly lacks dllexport annotations).
CMAKE_PLATFORM=""
BUILD_SHARED="ON"
if [ "$SEA_OS" = "windows" ] || [ -n "$WINDIR" ]; then
    CMAKE_PLATFORM="-A x64 -DBoost_COMPILER=-vc143"
    BUILD_SHARED="OFF"
    # Patch: folly's file(GENERATE) for libfolly.pc breaks with multi-config
    # generators (Visual Studio). Comment out the entire pkgconfig block.
    sed -i.bak 's/gen_pkgconfig_vars(FOLLY_PKGCONFIG folly_deps)/# &/' "$SRCDIR/CMakeLists.txt"
    sed -i.bak '/Generate a pkg-config file/,/DESTINATION.*pkgconfig/s/^/#/' "$SRCDIR/CMakeLists.txt"
    sed -i.bak '/^#.*DESTINATION.*pkgconfig/{n;s/^/#/;n;s/^/#/;}' "$SRCDIR/CMakeLists.txt"
fi

cmake "$SRCDIR" \
    $CMAKE_PLATFORM \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=$BUILD_SHARED \
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
