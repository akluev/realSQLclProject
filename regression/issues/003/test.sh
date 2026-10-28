#!/usr/bin/env bash
# 003: project export must remove files of APEX components deleted in APEX.
# Removes a spare page from the installed app (apex import of a copy without it),
# runs project export over the existing export folder, and checks the page file is gone.
source "$(dirname "$0")/../../lib/common.sh"

page=${APEX_SPARE_PAGE:-100}
page_glob=$(printf 'p%05d-*.apx' "$page")
dir="$TEST_REPO/$(apex_app_path)"
work="$RUN_DIR/003"

# Always leave the baseline behind: export folder from git, page back in the app
restore() {
  restore_apex_app_dir
  echo "apex import -input $TEST_REPO/$src -ws $APEX_WORKSPACE" | sqlcl_script "$work/restore.log" \
    || warn "re-import of the baseline app failed, see $work/restore.log"
  [[ $(apex_page_count "$page") == 1 ]] || warn "page $page not back in the app after restore"
}

# 1. Start from the baseline export
restore_apex_app_dir
src=$(baseline_apexlang_dir) || error "no application.apx in the baseline export"
[[ -n $(find "$TEST_REPO/$src/pages" -name "$page_glob") ]] || error "baseline has no page $page file"
trap restore EXIT

# 2. Copy of the app source without the page
rm -rf "$work"
mkdir -p "$work"
cp -R "$TEST_REPO/$src" "$work/app"
rm -f "$work/app/pages/"$page_glob

# 3. Install the copy, so the page is deleted in APEX
printf 'apex validate -input %s -ws %s\napex import -input %s -ws %s\n' \
  "$work/app" "$APEX_WORKSPACE" "$work/app" "$APEX_WORKSPACE" | sqlcl_script "$work/import.log" \
  || error "apex validate/import of the app without page $page failed, see $work/import.log"
[[ $(apex_page_count "$page") == 0 ]] || error "page $page still installed after apex import"

# 4. project export over the existing folder (not cleaned on purpose)
touch "$work/before-export"
echo "project export -o APEX.$APEX_APP_ID" | sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"

# 5. The folder this export wrote pages into must not hold the deleted page.
# Found by write time, so a changed folder layout does not count as a stale file.
written=$(find "$dir" -type f -path '*/pages/*' -newer "$work/before-export" | head -1)
[[ -n $written ]] || error "project export wrote no page files, see $work/export.log"
pages_dir=$(dirname "$written")
stale=$(find "$pages_dir" -maxdepth 1 -name "$page_glob" | head -1)

# 6. Workaround check: apex export -f should remove it
echo "apex export -applicationid $APEX_APP_ID -exptype APEXLANG -dir $(apex_app_path) -f" \
  | sqlcl_script "$work/apex-export.log" || true
if [[ -n $(find "$dir" -name "$page_glob" | head -1) ]]; then
  workaround="apex export -f does NOT remove it either"
else
  workaround="apex export -f removes it"
fi

[[ -n $stale ]] && fail "deleted page $page left behind: ${stale#"$TEST_REPO/"} ($workaround)"
pass "page $page file removed by project export ($workaround)"
