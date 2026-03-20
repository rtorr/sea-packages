#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

# Find JAVA_HOME — GitHub Actions sets JAVA_HOME_11_X64 etc.
if [ -z "$JAVA_HOME" ]; then
    for jhome in \
        "$JAVA_HOME_21_X64" \
        "$JAVA_HOME_17_X64" \
        "$JAVA_HOME_11_X64" \
        "/usr/lib/jvm/default-java" \
        "/usr/lib/jvm/java-17-openjdk-amd64" \
        "/usr/lib/jvm/java-11-openjdk-amd64" \
        "$(/usr/libexec/java_home 2>/dev/null)" \
    ; do
        if [ -n "$jhome" ] && [ -d "$jhome" ]; then
            export JAVA_HOME="$jhome"
            break
        fi
    done
fi

if [ -z "$JAVA_HOME" ]; then
    echo "Error: JAVA_HOME not found. Install a JDK to build fbjni."
    exit 1
fi

echo "Using JAVA_HOME=$JAVA_HOME"

mkdir -p "$SEA_PROJECT_DIR/_build" && cd "$SEA_PROJECT_DIR/_build"

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$SEA_INSTALL_DIR -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DBUILD_SHARED_LIBS=ON -DFBJNI_SKIP_TESTS=ON"

cmake "$SRCDIR" $CMAKE_ARGS
cmake --build . --config Release -j4
cmake --install . --config Release
echo "fbjni 0.7.0 built"
