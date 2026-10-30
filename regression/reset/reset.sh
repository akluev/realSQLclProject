#!/usr/bin/env bash
# Reset the test project to its baseline: git first (BASE_BRANCH at BASELINE_TAG, no local
# changes or untracked files), then the database (drop_all.sql, install.sql).
# Uncommitted work in the test project is discarded.
# Usage: regression/reset/reset.sh [<sqlcl-version>]   (default: the sql on PATH)
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

sqlcl_version=${1:-}

require_tools
load_config
[[ -z $sqlcl_version ]] || use_sqlcl "$sqlcl_version"
command -v sql >/dev/null || die "sql is not on PATH; pass a SQLcl version label"

repo() { git -C "$TEST_REPO" "$@"; }
dir=$(native_path "$REG_ROOT/reset")

echo "Resetting git: $BASE_BRANCH at $BASELINE_TAG"
repo checkout -q -f "$BASE_BRANCH"
repo reset -q --hard "$BASELINE_TAG"
repo clean -fdq

# stdin is an empty pipe: SQLcl crashes at startup (yet exits 0) on the Windows NUL device.
# stdout goes through cat: with a terminal as stdout, the Git Bash launcher of SQLcl 26.2+
# re-runs itself through winpty, which refuses a piped stdin ("stdin is not a tty").
echo "Dropping the database objects"
: | (cd "$TEST_REPO" && sql -nolog "@$dir/drop_all.sql" "$SQLCL_CONN" "$APEX_SCHEMA" "$APEX_WORKSPACE") | cat
echo "Installing the baseline"
: | (cd "$TEST_REPO" && sql -nolog "@$dir/install.sql" "$SQLCL_CONN") | cat
echo "Reset done"
