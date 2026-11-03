#!/usr/bin/env bash
# 016: with stage.change.changeStyle=multiple (set in the baseline project.config.json; not
# exposed by project config yet), project stage must put each generated statement in its own
# changeset. The default (single) keeps them in one.
source "$(dirname "$0")/../../lib/common.sh"

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
work="$RUN_DIR/016"
mkdir -p "$work"
cleanup() {
  leave_branch
  printf 'alter table %s.dept drop (reg_016_a, reg_016_b) cascade constraints;\n' "$schema" \
    | sqlcl_script "$work/cleanup.log" || warn "could not drop the REG_016 columns, see $work/cleanup.log"
}
isolate_branch 016
trap cleanup EXIT

# One table change that stage turns into three statements
printf 'alter table %s.dept add (reg_016_a number, reg_016_b varchar2(10));\nalter table %s.dept add constraint reg_016_ck check (reg_016_a > 0);\nproject export -o DEPT\n' \
  "$schema" "$schema" | sqlcl_script "$work/export.log" \
  || error "could not change and export DEPT, see $work/export.log"
commit_all "DEPT: two columns and a check constraint" || error "nothing to commit after export"

grep -q '"changeStyle" *: *"multiple"' "$TEST_REPO/.dbtools/project.config.json" \
  || error "baseline project.config.json does not set stage.change.changeStyle to multiple"
if ! project_stage "$work/stage.log"; then
  grep -q 'changelog is empty' "$work/stage.log" \
    && fail "project stage cannot stage the change at all: 'Unable to save changelog, changelog is empty' (see 020)"
  error "project stage failed: $(first_error "$work/stage.log")"
fi

file=$(find "$TEST_REPO/dist/releases/next/changes" -path "*$ISOLATED_BRANCH*" -name dept.sql | head -1)
[[ -n $file ]] || error "stage wrote no dept.sql changeset, see $work/stage.log"
grep -q 'dept\.sql' "$(dirname "$(dirname "$(dirname "$file")")")/stage.changelog.xml" 2>/dev/null \
  || error "stage wrote dept.sql but stage.changelog.xml does not include it, see $work/stage.log"
changesets=$(grep -c '^-- changeset' "$file")
statements=$(grep -c -E '^(alter|create|drop) ' "$file")
((changesets == statements)) && pass "$statements statement(s) in $changesets changeset(s)"
fail "$statements statements in $changesets changeset(s) with changeStyle=multiple"
