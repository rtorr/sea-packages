#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

PREFIX_PATH=""
for dep in "$SEA_PACKAGES_DIR"/*/; do
    [ -d "$dep" ] && PREFIX_PATH="${PREFIX_PATH:+$PREFIX_PATH;}$dep"
done

# Find sea's libevent library (named libevent-2.1.7.dylib/.so, not libevent.dylib)
LIBEVENT_LIB=$(find "$SEA_PACKAGES_DIR/libevent/lib" -name "libevent-2*.dylib" -o -name "libevent.so*" -o -name "libevent.a" -o -name "libevent*.lib" 2>/dev/null | head -1)
LIBEVENT_INC="$SEA_PACKAGES_DIR/libevent/include"

CMAKE_EXTRA=""
if [ -n "$LIBEVENT_LIB" ] && [ -d "$LIBEVENT_INC" ]; then
    CMAKE_EXTRA="-DLIBEVENT_LIB=$LIBEVENT_LIB -DLIBEVENT_INCLUDE_DIR=$LIBEVENT_INC"
fi

mkdir -p "$SEA_PROJECT_DIR/_fbuild" && cd "$SEA_PROJECT_DIR/_fbuild"

cmake "$SRCDIR" \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
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
