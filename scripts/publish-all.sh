#!/bin/bash
# Trigger CI builds for all packages in dependency order.
# Reads dependency information from sea.toml files to compute build tiers.
#
# Usage: ./scripts/publish-all.sh
set -e

REPO="rtorr/sea-packages"
WORKFLOW="build-packages.yml"

# Build dependency graph from sea.toml files
# Output: one line per package, "pkg dep1 dep2 ..." format
build_graph() {
  for toml in packages/*/*/sea.toml; do
    pkg_dir=$(dirname "$toml")
    pkg="${pkg_dir#packages/}"
    deps=$(grep -A1 '^\[dependencies\]' "$toml" 2>/dev/null | grep -v '^\[' | grep '=' | awk -F'=' '{print $1}' | tr -d ' "' | tr '\n' ' ')
    echo "$pkg $deps"
  done
}

# Compute tiers using topological sort
# Tier 0: packages with no deps
# Tier N: packages whose deps are all in tiers < N
compute_tiers() {
  local -A deps
  local -A tier
  local all_pkgs=()

  while IFS= read -r line; do
    local pkg=$(echo "$line" | awk '{print $1}')
    local pkg_deps=$(echo "$line" | cut -d' ' -f2-)
    deps["$pkg"]="$pkg_deps"
    all_pkgs+=("$pkg")
  done < <(build_graph)

  # Find the package directory for each dependency name
  # deps are by name (e.g., "gflags"), packages are name/version (e.g., "gflags/2.2.0")
  local max_tier=0
  local changed=1

  # Initialize all as tier 0
  for pkg in "${all_pkgs[@]}"; do
    tier["$pkg"]=0
  done

  # Iterate until stable
  while [ $changed -ne 0 ]; do
    changed=0
    for pkg in "${all_pkgs[@]}"; do
      local pkg_name="${pkg%%/*}"
      local current_tier=${tier["$pkg"]}
      local needed_tier=0

      for dep in ${deps["$pkg"]}; do
        # Find all packages that match this dep name
        for other in "${all_pkgs[@]}"; do
          local other_name="${other%%/*}"
          if [ "$other_name" = "$dep" ]; then
            local dep_tier=${tier["$other"]}
            local candidate=$((dep_tier + 1))
            if [ $candidate -gt $needed_tier ]; then
              needed_tier=$candidate
            fi
          fi
        done
      done

      if [ $needed_tier -gt $current_tier ]; then
        tier["$pkg"]=$needed_tier
        changed=1
        if [ $needed_tier -gt $max_tier ]; then
          max_tier=$needed_tier
        fi
      fi
    done
  done

  # Output tiers
  for t in $(seq 0 $max_tier); do
    local tier_pkgs=""
    for pkg in "${all_pkgs[@]}"; do
      if [ "${tier[$pkg]}" -eq "$t" ]; then
        tier_pkgs="$tier_pkgs $pkg"
      fi
    done
    if [ -n "$tier_pkgs" ]; then
      echo "TIER $t:$tier_pkgs"
    fi
  done
}

# Parse tiers and trigger
echo "Computing dependency order..."
echo ""

tier_num=0
while IFS= read -r tier_line; do
  tier_label=$(echo "$tier_line" | cut -d: -f1)
  tier_pkgs=$(echo "$tier_line" | cut -d: -f2)

  pkg_count=$(echo "$tier_pkgs" | wc -w | tr -d ' ')
  echo "=== $tier_label ($pkg_count packages) ==="

  for pkg in $tier_pkgs; do
    gh workflow run "$WORKFLOW" -f package="$pkg" 2>/dev/null
    echo "  Triggered: $pkg"
  done

  echo "  Waiting for tier to complete..."
  sleep 10

  # Watch all in-progress runs
  runs=$(gh run list --repo "$REPO" --event workflow_dispatch --limit "$pkg_count" \
    --json databaseId,status --jq '.[] | select(.status != "completed") | .databaseId')

  failed=0
  for run_id in $runs; do
    if ! gh run watch "$run_id" --repo "$REPO" --exit-status 2>/dev/null; then
      failed=$((failed + 1))
    fi
  done

  if [ $failed -gt 0 ]; then
    echo "  WARNING: $failed job(s) failed in $tier_label"
  else
    echo "  $tier_label complete ✓"
  fi
  echo ""
  tier_num=$((tier_num + 1))
done < <(compute_tiers)

echo "=== All tiers complete ==="
echo "Check status: ./scripts/check-status.sh"
