#!/usr/bin/env bash
# 006: in readable mode (apex.apexlang not set), project export must write the APEXlang source
# to the documented f<app_id>/<app-alias>/ folder, beside f<app_id>.sql.
source "$(dirname "$0")/../../lib/common.sh"

alias=$(apex_alias)
[[ -n $alias ]] || error "application $APEX_APP_ID not found"
export_apex_app

expected="$(apex_app_path)/$alias"
app=$(find "$TEST_REPO/src/database/$APEX_SCHEMA/apex_apps" -name application.apx | head -1)
rel=$(dirname "${app#"$TEST_REPO/"}")
[[ $rel == "$expected" ]] && pass "APEXlang in $rel"
fail "APEXlang in $rel, documented $expected"
