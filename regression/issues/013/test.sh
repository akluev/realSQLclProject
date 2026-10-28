#!/usr/bin/env bash
# 013: project export must not append a semicolon to a view's trailing line comment.
# Before the fix, "... from dept -- comment" was exported as "-- comment;" plus a terminator.
source "$(dirname "$0")/../../lib/common.sh"

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
view=REG_013_V
comment='-- reg_013 trailing line comment'
work="$RUN_DIR/013"
mkdir -p "$work"

cleanup() {
  echo "drop view if exists $schema.$view;" | sqlcl_script "$work/cleanup.log" \
    || warn "could not drop $schema.$view, see $work/cleanup.log"
  restore_from_baseline src
  rm -f "$RUN_DIR/apex-export.done"
}
trap cleanup EXIT

printf 'create or replace view %s.%s as\nselect deptno, dname\n  from %s.dept %s\n/\n' \
  "$schema" "$view" "$schema" "$comment" | sqlcl_script "$work/setup.log" \
  || error "could not create $schema.$view, see $work/setup.log"
echo "project export -o $view" | sqlcl_script "$work/export.log" \
  || error "project export -o $view failed, see $work/export.log"

file=$(find "$TEST_REPO/src/database/$APEX_SCHEMA" -iname "$view.sql" | head -1)
[[ -n $file ]] || error "project export -o $view wrote no file, see $work/export.log"
line=$(grep -F -- "$comment" "$file" | tr -d '\r' | sed 's/^ *//')
[[ -n $line ]] || error "exported view lost the comment: ${file#"$TEST_REPO/"}"
[[ $line == *"$comment;" ]] && fail "semicolon appended to the comment: '$line'"
pass "comment kept as '$line', terminator on its own line"
