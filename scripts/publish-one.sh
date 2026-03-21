#!/bin/bash
# Build and publish a single package locally, then trigger CI for other platforms.
# Usage: ./scripts/publish-one.sh <name>/<version> [--ci]
#
# Without --ci: builds and publishes for the local platform only.
# With --ci: also triggers GitHub Actions to build for Linux and Windows.
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <name>/<version> [--ci]"
  echo "Example: $0 folly/2024.11.0 --ci"
  exit 1
fi

PKG="$1"
PKG_DIR="packages/$PKG"

if [ ! -f "$PKG_DIR/sea.toml" ]; then
  echo "Error: $PKG_DIR/sea.toml not found"
  exit 1
fi

SEA="${SEA:-sea}"

echo "=== Building $PKG ==="
cd "$PKG_DIR"
$SEA build
echo ""

echo "=== Publishing $PKG ==="
$SEA publish --registry sea-packages --skip-verify
echo ""

if [ "$2" = "--ci" ]; then
  echo "=== Triggering CI for $PKG ==="
  cd - > /dev/null
  gh workflow run "build-packages.yml" -f package="$PKG"
  echo "CI triggered. Watch with:"
  echo "  gh run watch \$(gh run list --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId') --exit-status"
fi
