#!/usr/bin/env bash
# 022: after moving the application to APEXlang deployment the documented way (legacy f<id>
# source, dist folder and apex.changelog.xml entry removed; project export; project stage),
# stage must add only the APEXlang controller to apex.changelog.xml, not regenerate the
# legacy f<id>/f<id>.xml and f<id>.sql.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/022"
mkdir -p "$work"
isolate_branch 022
trap leave_branch EXIT

apexlang_migration "$work"

includes=$(apex_includes)
legacy=$(cd "$TEST_REPO" && find "dist/releases/apex/f$APEX_APP_ID" -type f 2>/dev/null | sort | paste -sd, - | sed 's/,/, /g')
count=$(grep -c '^[[:space:]]*<include ' "$TEST_REPO/dist/releases/apex/apex.changelog.xml" || true)
[[ $count == 1 && -z $legacy ]] && pass "apex.changelog.xml includes only $includes"
fail "stage wrote $count include(s) to apex.changelog.xml instead of 1: $includes${legacy:+; legacy files regenerated: $legacy}"
