#!/usr/bin/env bash
# 020: project stage must stage a table change that becomes two statements, whatever
# stage.change.changeStyle says. SQLcl 26.3 writes the changeset file but leaves
# stage.changelog.xml without it and stops with "Unable to save changelog, changelog is empty".
# The change is staged three times from the same commit: changeStyle not set, single, multiple.
source "$(dirname "$0")/../../lib/common.sh"

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
work="$RUN_DIR/020"
config=.dbtools/project.config.json
mkdir -p "$work"
cleanup() {
  leave_branch
  printf 'alter table %s.emp drop constraint reg_020_ck;\nalter table %s.emp drop column reg_020_a;\n' "$schema" "$schema" \
    | sqlcl_script "$work/cleanup.log" || warn "could not undo the REG_020 change of EMP, see $work/cleanup.log"
}
isolate_branch 020
trap cleanup EXIT

# One table change: a column and a check constraint (two statements when staged)
printf 'alter table %s.emp add (reg_020_a number);\nalter table %s.emp add constraint reg_020_ck check (empno > 0);\nproject export -o EMP\n' \
  "$schema" "$schema" | sqlcl_script "$work/export.log" \
  || error "could not change and export EMP, see $work/export.log"
commit_all "EMP: a column and a check constraint" || error "nothing to commit after export"
change=$(git -C "$TEST_REPO" rev-parse HEAD)

results=() empty=0 other=0
for style in unset single multiple; do
  git -C "$TEST_REPO" reset -q --hard "$change"
  git -C "$TEST_REPO" clean -fdq
  if [[ $style == unset ]]; then
    jq --indent 2 'del(.stage.change.changeStyle)' "$TEST_REPO/$config" >"$work/config.json"
  else
    jq --indent 2 --arg s "$style" '.stage.change.changeStyle = $s' "$TEST_REPO/$config" >"$work/config.json"
  fi
  cp "$work/config.json" "$TEST_REPO/$config"
  commit_all "changeStyle $style" || true

  log="$work/stage-$style.log"
  project_stage "$log" && staged=yes || staged=no
  dir=$(find "$TEST_REPO/dist/releases/next/changes" -type d -path "*$ISOLATED_BRANCH" 2>/dev/null | head -1)
  file=$(find "${dir:-/nonexistent}" -name emp.sql 2>/dev/null | head -1)
  shape="no emp.sql written"
  if [[ -n $file ]]; then
    shape="emp.sql: $(grep -c -E '^(alter|create|drop) ' "$file") statement(s) in $(grep -c '^-- changeset' "$file") changeset(s)"
  fi
  if [[ $staged == yes ]] && grep -q 'emp\.sql' "$dir/stage.changelog.xml" 2>/dev/null; then
    results+=("$style: staged ($shape)")
  elif grep -q 'changelog is empty' "$log"; then
    results+=("$style: 'changelog is empty' ($shape)")
    empty=$((empty + 1))
  else
    results+=("$style: $(first_error "$log")")
    other=$((other + 1))
  fi
done

summary=$(printf '%s; ' "${results[@]}")
summary=${summary%; }
((empty)) && fail "project stage fails for $empty of 3 changeStyle settings: $summary"
((other)) && error "project stage failed: $summary"
pass "staged with every changeStyle: $summary"
