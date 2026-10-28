#!/usr/bin/env bash
# 007: project export -o APEX.<id> must write only that application:
# no users, table data or other objects outside the application folder.
source "$(dirname "$0")/../../lib/common.sh"

restore_from_baseline src
rm -f "$RUN_DIR/apex-export.done"
fresh_apex_export "$RUN_DIR/007-export.log"

apps="src/database/$APEX_SCHEMA/apex_apps/"
outside=$({
  git -C "$TEST_REPO" diff --name-only "$BASELINE_TAG" -- src
  git -C "$TEST_REPO" ls-files --others --exclude-standard -- src
} | grep -v "^$apps" | sort -u)

[[ -z $outside ]] && pass "only $apps changed"
count=$(wc -l <<<"$outside" | tr -d ' ')
schemas=$(awk -F/ '{print $3}' <<<"$outside" | sort -u | paste -sd, - | sed 's/,/, /g')
summary=$(sed -n 's/^\([A-Z_]*\) *\([0-9]*\)$/\1 \2/p' "$RUN_DIR/007-export.log" | paste -sd, - | sed 's/,/, /g')
fail "$count file(s) written outside the application, under: $schemas (export summary: $summary)"
