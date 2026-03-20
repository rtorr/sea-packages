#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

# Find JAVA_HOME if not set
if [ -z "$JAVA_HOME" ]; then
    if [ -d "/usr/lib/jvm/default-java" ]; then
        export JAVA_HOME="/usr/lib/jvm/default-java"
    elif [ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]; then
        export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
    elif command -v java >/dev/null 2>&1; then
        export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java) 2>/dev/null || which java)))
    fi
fi

mkdir -p _build && cd _build
cmake "$SRCDIR" \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DBUILD_SHARED_LIBS=ON \
    -DFBJNI_SKIP_TESTS=ON \
    -DJAVA_HOME="$JAVA_HOME"
cmake --build . --config Release -j4
cmake --install . --config Release
echo "fbjni 0.7.0 built"
