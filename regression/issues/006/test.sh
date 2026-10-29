#!/usr/bin/env bash
# 006: project export must write the APEXlang source to the documented f<app_id>/<app-alias>/
# folder, beside f<app_id>.sql. Runs in both APEX modes (run.sh sets the mode); in APEXlang
# mode it replaces the former test 014.
source "$(dirname "$0")/../../lib/common.sh"

alias=$(apex_alias)
[[ -n $alias ]] || error "application $APEX_APP_ID not found"
export_apex_app

expected="$(apex_app_path)/$alias"
app=$(exported_app_dir) || error "no application.apx under $(apex_apps_dir)"
rel=${app#"$TEST_REPO/"}
[[ $rel == "$expected" ]] && pass "APEXlang in $rel"
fail "APEXlang in $rel, documented $expected"
