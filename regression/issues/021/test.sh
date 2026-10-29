#!/usr/bin/env bash
# 021: project export of an APEX application must be repeatable: a second export straight after
# the first, with nothing changed in APEX and nothing committed, must export the application
# again. To prove it really wrote files, application.apx is deleted between the two exports and
# must come back. In APEXlang mode SQLcl refuses ("APEXlang export target has tracked or
# untracked Git changes", "Exported 0 objects") and leaves the folder as it was.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/021"
mkdir -p "$work"
cleanup() { restore_from_baseline src; rm -f "$RUN_DIR/apex-export.done"; }
trap cleanup EXIT

fresh_apex_export "$work/first-export.log"
app="$(exported_app_dir)/application.apx"
rel=${app#"$TEST_REPO/"}
rm -f "$app"

echo "project export -o APEX.$APEX_APP_ID" | sqlcl_script "$work/second-export.log" || true
[[ -f $app ]] && pass "second project export exported the application again ($rel recreated)"
reason=$(sed 's/\x1b\[[0-9;]*m//g' "$work/second-export.log" | tr -d '\r' \
  | grep -m1 -oE 'Failed to export[^.]*\.[^.]*\.|Exported 0 objects' || true)
fail "second project export did not export the application ($rel not recreated)${reason:+: $reason}"
