#!/usr/bin/env bash
# Reset the test project to its baseline: git first (BASE_BRANCH at BASELINE_TAG, no local
# changes or untracked files), then the database (drop_all.sql, install.sql).
# Uncommitted work in the test project is discarded.
# Usage: regression/reset/reset.sh [<sqlcl-version>]   (default: the sql or sql.exe on PATH)
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

sqlcl_version=${1:-}

require_tools
load_config
[[ -z $sqlcl_version ]] || use_sqlcl "$sqlcl_version"
command -v "$SQL" >/dev/null || die "$SQL is not on PATH; pass a SQLcl version label"

repo() { git -C "$TEST_REPO" "$@"; }
dir=$(native_path "$REG_ROOT/reset")

echo "Resetting git: $BASE_BRANCH at $BASELINE_TAG"
repo checkout -q -f "$BASE_BRANCH"
repo reset -q --hard "$BASELINE_TAG"
repo clean -fdq

# stdin is an empty pipe: SQLcl crashes at startup (yet exits 0) when stdin is the Windows NUL
# device, as in agents, schedulers and CI; and a script without exit ends instead of waiting.
echo "Dropping the database objects"
: | (cd "$TEST_REPO" && "$SQL" -nolog "@$dir/drop_all.sql" "$SQLCL_CONN" "$APEX_SCHEMA" "$APEX_WORKSPACE")
echo "Installing the baseline"
: | (cd "$TEST_REPO" && "$SQL" -nolog "@$dir/install.sql" "$SQLCL_CONN")
echo "Reset done"
