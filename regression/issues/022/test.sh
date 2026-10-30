#!/usr/bin/env bash
# 022: after the application's deployment is regenerated from scratch (f<id> source, dist folder
# and apex.changelog.xml entry removed; project export; project stage), apex.changelog.xml must
# have exactly one include, the controller of the current APEX mode:
#   readable  f<id>/f<id>.xml, with f<id>.sql regenerated where the old one was
#   apexlang  <alias>/<alias>.xml, and no legacy dist/releases/apex/f<id> files regenerated
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/022"
mkdir -p "$work"
isolate_branch 022
trap leave_branch EXIT

apex_restage "$work"

expected=$(apex_controller)
includes=$(apex_includes)
count=$(grep -c '^[[:space:]]*<include ' "$TEST_REPO/dist/releases/apex/apex.changelog.xml" || true)
legacy_dir="dist/releases/apex/f$APEX_APP_ID"
legacy=$(cd "$TEST_REPO" && find "$legacy_dir" -type f 2>/dev/null | sort | paste -sd, - | sed 's/,/, /g')

[[ $count == 1 && $includes == "$expected" ]] \
  || fail "stage wrote $count include(s) to apex.changelog.xml: $includes; expected only $expected${legacy:+; files in $legacy_dir: $legacy}"
if [[ $APEX_MODE == apexlang ]]; then
  [[ -z $legacy ]] || fail "apex.changelog.xml includes only $expected, but stage regenerated the legacy $legacy"
else
  [[ -f $TEST_REPO/$legacy_dir/f$APEX_APP_ID.sql ]] || fail "apex.changelog.xml includes $expected, but stage wrote no $legacy_dir/f$APEX_APP_ID.sql"
fi
pass "apex.changelog.xml includes only $expected${legacy:+ ($legacy)}"
