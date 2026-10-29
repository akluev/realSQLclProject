#!/usr/bin/env bash
# 017: staged changesets must use "/" in logicalFilePath on every OS. With "\" (Windows) the
# changeset identity differs from one staged on Linux, and Liquibase runs it again.
source "$(dirname "$0")/../../lib/common.sh"

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
table=REG_017_T
work="$RUN_DIR/017"
mkdir -p "$work"
cleanup() {
  leave_branch
  echo "drop table if exists $schema.$table purge;" | sqlcl_script "$work/cleanup.log" \
    || warn "could not drop $schema.$table, see $work/cleanup.log"
}
isolate_branch 017
trap cleanup EXIT

printf 'create table %s.%s (id number);\nproject export -o %s\n' "$schema" "$table" "$table" \
  | sqlcl_script "$work/export.log" || error "could not create and export $table, see $work/export.log"
commit_all "Table $table" || error "nothing to commit after export"
project_stage "$work/stage.log" || error "project stage failed: $(first_error "$work/stage.log")"

staged=$(find "$TEST_REPO/dist/releases/next/changes" -path "*$ISOLATED_BRANCH*" -name '*.sql')
[[ -n $staged ]] || error "stage wrote no changesets, see $work/stage.log"
paths=$(grep -ho 'logicalFilePath:[^ ]*' $staged | sort -u)
[[ -n $paths ]] || error "no logicalFilePath in the staged changesets"
grep -q '\\' <<<"$paths" && fail "backslashes in logicalFilePath: $(head -1 <<<"$paths")"
pass "logicalFilePath uses /: $(head -1 <<<"$paths")"
