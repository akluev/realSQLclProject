#!/usr/bin/env bash
# Move BASELINE_TAG to a new baseline (after a baseline change was merged into BASE_BRANCH),
# then reset the test project to it.
# Usage: regression/reset/baseline.sh [<commit>] [<sqlcl-version>]   (default: tip of BASE_BRANCH)
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

target_commit=${1:-}
sqlcl_version=${2:-}

require_tools
load_config
target=${target_commit:-$BASE_BRANCH}

old=$(git -C "$TEST_REPO" rev-parse --short "$BASELINE_TAG^{commit}" 2>/dev/null || echo none)
new=$(git -C "$TEST_REPO" rev-parse --short "$target^{commit}") || die "no commit $target in $TEST_REPO"
git -C "$TEST_REPO" merge-base --is-ancestor "$new" "$BASE_BRANCH" \
  || die "$target is not on $BASE_BRANCH; merge the baseline change first"
git -C "$TEST_REPO" tag -f "$BASELINE_TAG" "$new" >/dev/null
echo "$BASELINE_TAG moved: $old -> $new"

exec bash "$(dirname "$0")/reset.sh" $sqlcl_version
