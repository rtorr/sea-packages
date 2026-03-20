#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

mkdir -p "$SEA_PROJECT_DIR/_build" && cd "$SEA_PROJECT_DIR/_build"
cmake "$SRCDIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build . --config Release -j4

mkdir -p "$SEA_INSTALL_DIR/include/double-conversion" "$SEA_INSTALL_DIR/lib"
cp "$SRCDIR/src/"*.h "$SEA_INSTALL_DIR/include/double-conversion/"

# Copy library — handle platform differences
for dir in . Release lib; do
    for ext in a lib dylib so; do
        for f in "$dir/"*double*."$ext" "$dir/"*double*."$ext"; do
            if [ -f "$f" ]; then
                cp "$f" "$SEA_INSTALL_DIR/lib/"
            fi
        done
    done
done
echo "double-conversion 1.1.6 built"
