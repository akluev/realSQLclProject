#!/usr/bin/env bash
# 012: project stage must not regenerate ORDS changesets when ORDS did not change.
# Connected as the schema (the only way ORDS is exported, see 011): make a non-ORDS change,
# export everything, commit, stage, and check that nothing ORDS-related is written to dist.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/012"
mkdir -p "$work"
table=REG_012_T
cleanup() {
  leave_branch
  echo "drop table if exists $table purge;" | as_schema sqlcl_script "$work/cleanup.log" \
    || warn "could not drop $table, see $work/cleanup.log"
}
isolate_branch 012
trap cleanup EXIT

echo "create table $table (id number);" | as_schema sqlcl_script "$work/setup.log" \
  || error "could not create $table, see $work/setup.log"
echo "project export" | as_schema sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"

ords_src="src/database/$APEX_SCHEMA/ords"
[[ -z $(git -C "$TEST_REPO" status --porcelain -- "$ords_src") ]] \
  || error "export changed $ords_src although ORDS did not change, see $work/export.log"
[[ -n $(git -C "$TEST_REPO" status --porcelain -- "src/database/$APEX_SCHEMA/tables") ]] \
  || error "export did not write $table, see $work/export.log"
# The application is not part of this test (its export differs between versions)
restore_from_baseline "src/database/$APEX_SCHEMA/apex_apps"
commit_all "Table $table" || error "nothing to commit after export"

as_schema project_stage "$work/stage.log" || error "project stage failed: $(first_error "$work/stage.log")"
ords_dist=$(git -C "$TEST_REPO" status --porcelain -- dist | grep -i ords | awk '{print $2}' | paste -sd, - | sed 's/,/, /g')
[[ -z $ords_dist ]] && pass "stage wrote no ORDS files for a change without ORDS"
fail "stage wrote ORDS files although ORDS did not change: $ords_dist"
