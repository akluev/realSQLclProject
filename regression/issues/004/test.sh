#!/usr/bin/env bash
# 004: project export -o <synonym> must export that synonym.
# Control: exporting the synonym's table brings the synonym along, which shows the
# synonym itself is exportable and only the -o selection misses it.
source "$(dirname "$0")/../../lib/common.sh"

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
tab=REG_004_T syn=REG_004_SYN
work="$RUN_DIR/004"
mkdir -p "$work"

cleanup() {
  printf 'drop synonym if exists %s.%s;\ndrop table if exists %s.%s purge;\n' \
    "$schema" "$syn" "$schema" "$tab" | sqlcl_script "$work/cleanup.log" \
    || warn "could not drop $schema.$syn / $schema.$tab, see $work/cleanup.log"
  restore_from_baseline src
  rm -f "$RUN_DIR/apex-export.done"
}
trap cleanup EXIT

printf 'create table %s.%s (id number);\ncreate synonym %s.%s for %s.%s;\n' \
  "$schema" "$tab" "$schema" "$syn" "$schema" "$tab" | sqlcl_script "$work/setup.log" \
  || error "could not create the test table and synonym, see $work/setup.log"

synonym_file() { find "$TEST_REPO/src/database/$APEX_SCHEMA" -iname "$syn.sql" | head -1; }

echo "project export -o $syn" | sqlcl_script "$work/export.log" \
  || error "project export -o $syn failed, see $work/export.log"
file=$(synonym_file)
[[ -n $file ]] && pass "synonym exported to ${file#"$TEST_REPO/"}"

echo "project export -o $tab" | sqlcl_script "$work/control.log" \
  || error "project export -o $tab failed, see $work/control.log"
[[ -n $(synonym_file) ]] || error "synonym not exported with its table either (filters?), see $work/control.log"
fail "project export -o $syn exported nothing; the synonym is exported only together with its table"
