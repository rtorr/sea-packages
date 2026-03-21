#!/bin/bash
# Check publication status of all packages across all platforms.
# Usage: ./scripts/check-status.sh
set -e

echo "Package publication status:"
echo ""
printf "%-30s %-12s %-12s %-12s\n" "Package" "macOS" "Linux" "Windows"
printf "%-30s %-12s %-12s %-12s\n" "-------" "-----" "-----" "-------"

for release in $(gh release list --limit 50 --json tagName --jq '.[].tagName' | sort); do
  assets=$(gh release view "$release" --json assets --jq '[.assets[].name] | join(" ")' 2>/dev/null)

  macos="—"
  linux="—"
  windows="—"

  if echo "$assets" | grep -q "darwin\|libcxx"; then macos="✓"; fi
  if echo "$assets" | grep -q "linux\|libstdcxx"; then linux="✓"; fi
  if echo "$assets" | grep -q "windows\|msvc"; then windows="✓"; fi
  if echo "$assets" | grep -q "any"; then macos="✓"; linux="✓"; windows="✓"; fi

  printf "%-30s %-12s %-12s %-12s\n" "$release" "$macos" "$linux" "$windows"
done
