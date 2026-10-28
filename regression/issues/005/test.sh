#!/usr/bin/env bash
# 005: the APEXlang source written by project export must pass apex validate.
# (Fails e.g. when a static file name is lowercased but static-files.apx keeps the original case.)
source "$(dirname "$0")/../../lib/common.sh"

export_apex_app

app=$(find "$TEST_REPO/src/database/$APEX_SCHEMA/apex_apps" -name application.apx | head -1)
src=$(dirname "$app")
log="$RUN_DIR/005-validate.log"
printf 'apex validate -input %s -ws %s\n' "$(native_path "$src")" "$APEX_WORKSPACE" \
  | sqlcl_script "$log" || error "apex validate could not run, see $log"

grep -q '^Validation successful' "$log" && pass "apex validate succeeded on ${src#"$TEST_REPO/"}"
type=$(grep -m1 '^Type:' "$log" | tr -d '\r')
err=$(grep -m1 '^Error:' "$log" | tr -d '\r')
[[ -n $type ]] && fail "apex validate failed: $type; $err"
error "apex validate gave no verdict, see $log"
