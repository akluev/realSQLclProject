#!/usr/bin/env bash
# 019: connected as the schema, a changed ORDS module must be exported and staged.
# The counterpart of 012 (nothing staged when ORDS did not change); deploying is not tested.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/019"
mkdir -p "$work"
ords_src="src/database/$APEX_SCHEMA/ords"
module=regression.dept
pattern=reg019/
cleanup() {
  leave_branch
  # Back to the baseline ORDS: re-running its export redefines the module without the template
  echo "@$ords_src/ords.sql" | as_schema sqlcl_script "$work/cleanup.log" \
    || warn "could not restore the baseline ORDS of $APEX_SCHEMA, see $work/cleanup.log"
  [[ $(sql_value "select count(*) from ords_metadata.ords_templates where uri_template = '$pattern'") == 0 ]] \
    || warn "ORDS template $pattern still defined after cleanup"
}
isolate_branch 019
trap cleanup EXIT

# A real ORDS change: one more template and handler in the baseline module
cat <<SQL | as_schema sqlcl_script "$work/setup.log" || error "could not change ORDS, see $work/setup.log"
begin
  ords.define_template(p_module_name => '$module', p_pattern => '$pattern');
  ords.define_handler(p_module_name => '$module', p_pattern => '$pattern', p_method => 'GET',
    p_source_type => 'json/collection', p_source => 'select 1 as reg019 from dual');
  commit;
end;
/
SQL

echo "project export" | as_schema sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"
grep -rqF "$pattern" "$TEST_REPO/$ords_src" 2>/dev/null \
  || fail "project export as $SCHEMA_CONN did not write the changed ORDS module to $ords_src"
# Only the ORDS change goes to stage: the application export differs between versions
restore_from_baseline "src/database/$APEX_SCHEMA/apex_apps"
commit_all "ORDS template $pattern" || error "nothing to commit after export"

as_schema project_stage "$work/stage.log" || error "project stage failed: $(first_error "$work/stage.log")"
staged=$(grep -rlF "$pattern" "$TEST_REPO/dist" 2>/dev/null | head -1)
[[ -n $staged ]] && pass "ORDS change exported and staged to ${staged#"$TEST_REPO/"}"
fail "project stage wrote no changeset with the ORDS change (template $pattern)"
