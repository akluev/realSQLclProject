#!/usr/bin/env bash
# 011: project export must export the ORDS modules of the project schema, also when the
# connected user is a deployer that is not REST-enabled itself. (SQLcl calls
# ords_export.export_schema() without a schema, so ORDS exports the connected user.)
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/011"
mkdir -p "$work"
cleanup() { restore_from_baseline src; rm -f "$RUN_DIR/apex-export.done"; }
trap cleanup EXIT

module=$(sql_value "select m.name from ords_metadata.ords_modules m join ords_metadata.ords_schemas s on s.id = m.schema_id where s.parsing_schema = upper('$APEX_SCHEMA') fetch first 1 row only")
[[ -n $module ]] || error "baseline has no ORDS module for schema $APEX_SCHEMA"

restore_from_baseline src
echo "project export -debug" | sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"

hit=$(grep -rlF --include='*.sql' "$module" "$TEST_REPO/src/database/$APEX_SCHEMA" | head -1)
[[ -n $hit ]] && pass "ORDS module $module exported to ${hit#"$TEST_REPO/"}"
ora=$(sed 's/\x1b\[[0-9;]*m//g' "$work/export.log" | grep -m1 'ORA-20012' | tr -d '\r')
fail "ORDS module $module of $APEX_SCHEMA not exported${ora:+ (debug: $ora)}"
