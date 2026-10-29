#!/usr/bin/env bash
# 011: connected as a deployer, project export must export the ORDS definitions of the project
# schema. (SQLcl calls ords_export.export_schema() without a schema, so ORDS exports the
# connected user, fails with ORA-20012 when it is not REST-enabled, and says so only in -debug.)
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/011"
mkdir -p "$work"
ords_dir="src/database/$APEX_SCHEMA/ords"
cleanup() { restore_from_baseline src; rm -f "$RUN_DIR/apex-export.done"; }
trap cleanup EXIT

module=$(sql_value "select m.name from ords_metadata.ords_modules m join ords_metadata.ords_schemas s on s.id = m.schema_id where s.parsing_schema = upper('$APEX_SCHEMA') fetch first 1 row only")
[[ -n $module ]] || error "no ORDS module for schema $APEX_SCHEMA after the reset"

# The baseline already has the schema's ORDS export (made as the schema); remove it first
restore_from_baseline src
rm -rf "${TEST_REPO:?}/$ords_dir"
echo "project export -debug" | sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"

hit=$(grep -rlF "$module" "$TEST_REPO/$ords_dir" 2>/dev/null | head -1)
[[ -n $hit ]] && pass "ORDS module $module exported to ${hit#"$TEST_REPO/"}"
ora=$(sed 's/\x1b\[[0-9;]*m//g' "$work/export.log" | grep -m1 'ORA-20012' | tr -d '\r')
fail "ORDS of $APEX_SCHEMA not exported${ora:+ (debug: $ora)}"
