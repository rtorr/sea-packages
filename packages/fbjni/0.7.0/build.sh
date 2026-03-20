#!/bin/sh
set -e
SRCDIR="$SEA_PROJECT_DIR/_src/src"

# Find JAVA_HOME
JAVA_HOME_FOUND=""
for jhome in \
    "$JAVA_HOME" \
    "$JAVA_HOME_21_X64" \
    "$JAVA_HOME_17_X64" \
    "$JAVA_HOME_11_X64" \
    "/usr/lib/jvm/temurin-17-jdk-amd64" \
    "/usr/lib/jvm/temurin-21-jdk-amd64" \
    "/usr/lib/jvm/default-java" \
    "/usr/lib/jvm/java-17-openjdk-amd64" \
    "/usr/lib/jvm/java-11-openjdk-amd64" \
; do
    if [ -n "$jhome" ] && [ -d "$jhome/include" ]; then
        JAVA_HOME_FOUND="$jhome"
        break
    fi
done

# macOS
if [ -z "$JAVA_HOME_FOUND" ] && command -v /usr/libexec/java_home >/dev/null 2>&1; then
    JAVA_HOME_FOUND=$(/usr/libexec/java_home 2>/dev/null || true)
fi

if [ -z "$JAVA_HOME_FOUND" ]; then
    echo "Error: Cannot find JAVA_HOME with JNI headers. Install a JDK."
    exit 1
fi

echo "Using JAVA_HOME=$JAVA_HOME_FOUND"

mkdir -p "$SEA_PROJECT_DIR/_build" && cd "$SEA_PROJECT_DIR/_build"

cmake "$SRCDIR" \
    -DCMAKE_INSTALL_PREFIX="$SEA_INSTALL_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DBUILD_SHARED_LIBS=ON \
    -DFBJNI_SKIP_TESTS=ON \
    -DJAVA_HOME="$JAVA_HOME_FOUND" \
    -DCMAKE_FIND_ROOT_PATH="$JAVA_HOME_FOUND"

cmake --build . --config Release -j4
cmake --install . --config Release
echo "fbjni 0.7.0 built"
