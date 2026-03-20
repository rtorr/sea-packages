#!/bin/sh
set -e
# double-conversion 1.1.6 has cmake but no install() commands.
# Build it and manually copy the outputs.
SRCDIR="$SEA_PROJECT_DIR/_src/src"
mkdir -p _build && cd _build
cmake "$SRCDIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build . --config Release -j4

mkdir -p "$SEA_INSTALL_DIR/include/double-conversion" "$SEA_INSTALL_DIR/lib"
cp "$SRCDIR/src/"*.h "$SEA_INSTALL_DIR/include/double-conversion/"

# Find the built library (different locations on different platforms)
for lib in \
    libdouble-conversion.a \
    Release/double-conversion.lib \
    Debug/double-conversion.lib \
    double-conversion.lib \
    libdouble-conversion.dylib \
    libdouble-conversion.so; do
    if [ -f "$lib" ]; then
        cp "$lib" "$SEA_INSTALL_DIR/lib/"
    fi
done
echo "double-conversion 1.1.6 built"
