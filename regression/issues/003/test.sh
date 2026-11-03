#!/usr/bin/env bash
# 003: project export must remove files of APEX components deleted in APEX.
# On its own branch: exports the app (so the folder has this version's layout) and commits it,
# removes a spare page from the installed app (apex import of a copy without it), exports again
# over the committed folder, and checks the page file is gone. Works in both APEX modes.
# The commit matters in APEXlang mode, where project export refuses to overwrite uncommitted
# changes in the application folder (that is test 021, not this one).
source "$(dirname "$0")/../../lib/common.sh"

page=${APEX_SPARE_PAGE:-100}
page_glob=$(printf 'p%05d-*.apx' "$page")
dir=$(apex_apps_dir)
work="$RUN_DIR/003"

# Always leave the baseline behind: back to the run's branch, page back in the app
cleanup() {
  leave_branch
  rm -f "$RUN_DIR/apex-export.done"
  restore_apex_app "$work"
  [[ $(apex_page_count "$page") == 1 ]] || warn "page $page not back in the app after restore"
}

mkdir -p "$work"
isolate_branch 003
trap cleanup EXIT

# 1. First export, with the page, in the layout of the version under test; committed
fresh_apex_export "$work/first-export.log"
[[ -n $(find "$dir" -name "$page_glob") ]] || error "first export has no page $page file"
keep_only_apex_export
commit_all "Application $APEX_APP_ID exported" || error "first export produced no change to commit"

# 2. Delete the page in APEX
remove_page_in_apex "$page" "$work"

# 3. project export over the existing folder (not cleaned on purpose)
touch "$work/before-export"
echo "project export -o APEX.$APEX_APP_ID" | sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"

# 4. The folder this export wrote pages into must not hold the deleted page.
# Found by write time, so a changed folder layout does not count as a stale file.
written=$(find "$dir" -type f -path '*/pages/*' -newer "$work/before-export" | head -1)
[[ -n $written ]] || error "project export wrote no page files: $(first_error "$work/export.log")"
pages_dir=$(dirname "$written")
stale=$(find "$pages_dir" -maxdepth 1 -name "$page_glob" | head -1)
[[ -z $stale ]] && pass "page $page file removed by project export"

# 5. Only when the bug is there: does the documented workaround (apex export -f into f<id>)
# remove the file? Reported in its own column, never as the verdict.
apex_export_workaround "$work/apex-export.log" || true
if [[ -n $(find "$dir" -name "$page_glob" | head -1) ]]; then
  workaround "does not work" "apex export -f leaves the page file too"
else
  workaround works "apex export -f removes the page file"
fi
fail "deleted page $page left behind: ${stale#"$TEST_REPO/"}"
