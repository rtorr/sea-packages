#!/bin/bash
# Trigger CI builds for all packages across all platforms.
# Usage: ./scripts/publish-all.sh [--watch]
#
# With --watch, blocks until all runs complete and reports results.
set -e

REPO="rtorr/sea-packages"
WORKFLOW="build-packages.yml"

PACKAGES=$(find packages -name "sea.toml" -exec dirname {} \; | sed 's|packages/||' | sort)

echo "Triggering CI for $(echo "$PACKAGES" | wc -l | tr -d ' ') packages..."

RUN_IDS=""
for pkg in $PACKAGES; do
  gh workflow run "$WORKFLOW" -f package="$pkg" 2>/dev/null
  echo "  ✓ $pkg"
done

echo ""
echo "All workflows triggered."
echo "View at: https://github.com/$REPO/actions"

if [ "$1" = "--watch" ]; then
  echo ""
  echo "Waiting for all runs to complete..."
  sleep 10  # give GitHub time to register the runs

  # Get the run IDs for all workflow_dispatch runs from the last minute
  RUNS=$(gh run list --repo "$REPO" --event workflow_dispatch --limit 50 --json databaseId,status --jq '.[] | select(.status != "completed") | .databaseId')

  if [ -z "$RUNS" ]; then
    echo "All runs already completed (or not yet registered). Check GitHub Actions."
    exit 0
  fi

  FAILED=0
  for run_id in $RUNS; do
    echo "  Watching run $run_id..."
    if ! gh run watch "$run_id" --repo "$REPO" --exit-status 2>/dev/null; then
      FAILED=$((FAILED + 1))
    fi
  done

  echo ""
  if [ $FAILED -eq 0 ]; then
    echo "All runs passed ✓"
  else
    echo "$FAILED run(s) failed ✗"
    exit 1
  fi
fi
