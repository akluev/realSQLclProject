#!/usr/bin/env bash
# 015: project stage must handle an application with a supporting object (upgrade script).
# Fails with "The hash value of the file <script>.sql is incorrect ... (hard object)" and
# "Unrecoverable hash issues present" when the script is analysed as a database object.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/015"
mkdir -p "$work"
cleanup() { leave_branch; restore_apex_app "$work"; }
isolate_branch 015
trap cleanup EXIT

# Add the supporting object (fixture/) to the application in APEX
baseline_apexlang_copy "$work/app" || error "no application.apx in the baseline export"
mkdir -p "$work/app/supporting-objects"
cp -R "$(dirname "$0")/fixture/." "$work/app/supporting-objects/"
apex_import "$work/app" "$work/import.log" \
  || error "apex import of the app with a supporting object failed, see $work/import.log"

fresh_apex_export "$work/export.log"
find "$TEST_REPO/src/database/$APEX_SCHEMA/apex_apps" -path '*supporting-objects*' -name '*.sql' | grep -q . \
  || error "the export has no supporting object script, see $work/export.log"
keep_only_apex_export
commit_all "Application $APEX_APP_ID with a supporting object" || error "nothing to commit after export"

# Separate issue (008): let stage regenerate a controller written by an earlier version
rm -f "$TEST_REPO/dist/releases/apex/f$APEX_APP_ID/f$APEX_APP_ID.xml"

log="$work/stage.log"
project_stage "$log" && pass "project stage completed with a supporting object"
# 26.1: hash error on the script; 26.2.2: hash auto-adjusted, then a NullPointerException
problems=$(sed 's/\x1b\[[0-9;]*m//g' "$log" | tr -d '\r' \
  | grep -E 'hash value of the file|Unrecoverable|Cannot invoke|Exception' | paste -sd'|' - | sed 's/|/; /g')
[[ -n $problems ]] && fail "project stage failed: $problems"
error "project stage failed: $(first_error "$log")"
