#!/usr/bin/env bash
# 007: project export -o APEX.<id> must write only that application: no users, table data or
# other objects. The test project's filters carry the workaround in a --TEST-007 block; the
# verdict comes from an export without it; whether the workaround works goes to its own column.
source "$(dirname "$0")/../../lib/common.sh"

filters=.dbtools/filters/project.filters
cleanup() {
  restore_from_baseline "$filters"
  restore_from_baseline src
  rm -f "$RUN_DIR/apex-export.done"
}
trap cleanup EXIT

describe() {
  local files=$1 count schemas
  count=$(wc -l <<<"$files" | tr -d ' ')
  schemas=$(awk -F/ '{print $3}' <<<"$files" | sort -u | paste -sd, - | sed 's/,/, /g')
  echo "$count file(s) under $schemas"
}

# 1. With the workaround filters (as in the baseline)
restore_from_baseline src
fresh_apex_export "$RUN_DIR/007-with-workaround.log"
with=$(outside_apex_changes)
if [[ -z $with ]]; then
  workaround works "the TEST-007 filters prevent it"
else
  workaround "does not work" "with the TEST-007 filters still $(describe "$with")"
fi

# 2. Without them
drop_workaround 007 "$filters"
restore_from_baseline src
fresh_apex_export "$RUN_DIR/007-without-workaround.log"
without=$(outside_apex_changes)

[[ -z $without ]] && pass "only the application written, even without the workaround filters"
fail "$(describe "$without") written outside the application"
