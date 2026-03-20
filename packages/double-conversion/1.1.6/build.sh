#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

mkdir -p "$SEA_PROJECT_DIR/_build" && cd "$SEA_PROJECT_DIR/_build"
cmake "$SRCDIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build . --config Release -j4

mkdir -p "$SEA_INSTALL_DIR/include/double-conversion" "$SEA_INSTALL_DIR/lib"
cp "$SRCDIR/src/"*.h "$SEA_INSTALL_DIR/include/double-conversion/"

# Copy library — search all subdirectories
find . -name "libdouble-conversion.*" -o -name "double-conversion.lib" | while read f; do
    cp "$f" "$SEA_INSTALL_DIR/lib/"
done
echo "double-conversion 1.1.6 built"
