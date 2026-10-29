#!/usr/bin/env bash
# 010: after switching the project to APEXlang mode (apex.apexlang=true, set by run.sh for the
# apexlang pass, on top of the readable-mode baseline and its dist), project stage
# must not leave the legacy SQL controller (f<id>/f<id>.xml) active beside the APEXlang one.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/010"
mkdir -p "$work"
isolate_branch 010
trap leave_branch EXIT

[[ ${APEX_MODE:-} == apexlang ]] || error "runs in APEXlang mode only (run.sh sets it)"
fresh_apex_export "$work/export.log"
keep_only_apex_export
commit_all "APEXlang mode, application $APEX_APP_ID exported" \
  || error "export produced no change to commit"
project_stage "$work/stage.log" || error "project stage failed: $(first_error "$work/stage.log")"

changelog="$TEST_REPO/dist/releases/apex/apex.changelog.xml"
includes=$(sed -n 's/.*<include file="\([^"]*\)".*/\1/p' "$changelog" | paste -sd, - | sed 's/,/, /g')
grep -q "file=\"f$APEX_APP_ID/f$APEX_APP_ID.xml\"" "$changelog" \
  && fail "apex.changelog.xml still includes the legacy controller: $includes"
pass "apex.changelog.xml includes: $includes"
