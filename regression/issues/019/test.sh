#!/usr/bin/env bash
# 019: connected as the schema, project export must export the schema's ORDS definitions, and
# project stage must not stage them when they did not change. ORDS is not changed and nothing
# is deployed. FAIL when ORDS is not exported, exported differently, or staged.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/019"
mkdir -p "$work"
ords_src="src/database/$APEX_SCHEMA/ords"
isolate_branch 019
trap leave_branch EXIT

# 1. Export: the ORDS folder is removed first, so it is there only if this export wrote it
rm -rf "${TEST_REPO:?}/$ords_src"
echo "project export" | as_schema sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"
[[ -d $TEST_REPO/$ords_src ]] || fail "project export as $SCHEMA_CONN did not export ORDS to $ords_src"
changed=$(git -C "$TEST_REPO" status --porcelain -- "$ords_src" | awk '{print $2}' | paste -sd, - | sed 's/,/, /g')
[[ -z $changed ]] || fail "ORDS did not change, but the export differs from the baseline: $changed"

# 2. Stage whatever else the export changed; the application is not part of this test
restore_from_baseline "src/database/$APEX_SCHEMA/apex_apps"
commit_all "Full export as $SCHEMA_CONN" || note="nothing but ORDS exported, nothing to stage"
log="$work/stage.log"
if as_schema project_stage "$log"; then
  stage="stage completed"
elif grep -q 'changelog is empty' "$log"; then
  stage="stage ended with 'changelog is empty'"   # also when there is nothing to stage
else
  error "project stage failed: $(first_error "$log")"
fi
ords_dist=$(git -C "$TEST_REPO" status --porcelain -- dist | grep -i ords | awk '{print $2}' | paste -sd, - | sed 's/,/, /g')
[[ -n $ords_dist ]] && fail "ORDS did not change, but stage wrote: $ords_dist"
pass "ORDS exported unchanged and not staged ($stage${note:+; $note})"
