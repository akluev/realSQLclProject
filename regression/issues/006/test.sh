#!/usr/bin/env bash
# 006: in readable mode (apex.apexlang not set), project export must keep the APEXlang
# source in a subfolder of f<id>: documented f<id>/<alias>/, Oracle's intended f<id>/readable/.
# It must not be flattened into f<id> next to f<id>.sql.
source "$(dirname "$0")/../../lib/common.sh"

export_apex_app

dir="$TEST_REPO/$(apex_app_path)"
app=$(find "$TEST_REPO/src/database/$APEX_SCHEMA/apex_apps" -name application.apx | head -1)
rel=${app#"$TEST_REPO/"}
case $(dirname "$app") in
  "$dir")   fail "APEXlang flattened into $(apex_app_path): $rel" ;;
  "$dir"/*) pass "APEXlang in a subfolder of $(apex_app_path): $rel" ;;
  *)        fail "APEXlang outside $(apex_app_path): $rel" ;;
esac
