#!/usr/bin/env bash
# 014: with apex.apexlang=true, project export must still write the APEXlang source to the
# documented f<app_id>/<app-alias>/ folder. (SQLcl 26.1 has no such setting: no effect.)
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/014"
mkdir -p "$work"
cleanup() {
  restore_from_baseline .dbtools/project.config.json
  restore_apex_app_dir
}
trap cleanup EXIT

alias=$(apex_alias)
[[ -n $alias ]] || error "application $APEX_APP_ID not found"
echo "project config set -name apex.apexlang -value true" | sqlcl_script "$work/config.log" || true
if grep -q '"apexlang" *: *true' "$TEST_REPO/.dbtools/project.config.json"; then
  mode="apex.apexlang=true"
else
  mode="apex.apexlang not supported by this version"
fi
fresh_apex_export "$work/export.log"

expected="$(apex_app_path)/$alias"
app=$(find "$TEST_REPO/src/database/$APEX_SCHEMA/apex_apps" -name application.apx | head -1)
rel=$(dirname "${app#"$TEST_REPO/"}")
[[ $rel == "$expected" ]] && pass "$mode: APEXlang in $rel"
fail "$mode: APEXlang in $rel, documented $expected"
