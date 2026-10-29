#!/usr/bin/env bash
# 003: project export must remove files of APEX components deleted in APEX.
# Exports the app (so the folder has this version's layout), removes a spare page from
# the installed app (apex import of a copy without it), exports again over the existing
# folder, and checks the page file is gone. Works in both APEX modes (any export layout).
source "$(dirname "$0")/../../lib/common.sh"

page=${APEX_SPARE_PAGE:-100}
page_glob=$(printf 'p%05d-*.apx' "$page")
dir=$(apex_apps_dir)
work="$RUN_DIR/003"

# Always leave the baseline behind: export folder from git, page back in the app
restore() {
  restore_apex_app_dir
  restore_apex_app "$work"
  [[ $(apex_page_count "$page") == 1 ]] || warn "page $page not back in the app after restore"
}

mkdir -p "$work"
trap restore EXIT

# 1. First export, with the page, in the layout of the version under test
fresh_apex_export "$work/first-export.log"
[[ -n $(find "$dir" -name "$page_glob") ]] || error "first export has no page $page file"

# 2. Delete the page in APEX
remove_page_in_apex "$page" "$work"

# 3. project export over the existing folder (not cleaned on purpose)
touch "$work/before-export"
echo "project export -o APEX.$APEX_APP_ID" | sqlcl_script "$work/export.log" \
  || error "project export failed, see $work/export.log"

# 4. The folder this export wrote pages into must not hold the deleted page.
# Found by write time, so a changed folder layout does not count as a stale file.
written=$(find "$dir" -type f -path '*/pages/*' -newer "$work/before-export" | head -1)
[[ -n $written ]] || error "project export wrote no page files, see $work/export.log"
pages_dir=$(dirname "$written")
stale=$(find "$pages_dir" -maxdepth 1 -name "$page_glob" | head -1)

# 5. Workaround check: apex export -f should remove it. Readable mode: into f<id>, as the
# workaround in tests.json says; APEXlang mode: into the folder holding application.apx.
if [[ ${APEX_MODE:-readable} == readable ]]; then
  target=$(apex_app_path)
else
  target=$(exported_app_dir)
  target=${target#"$TEST_REPO/"}
fi
echo "apex export -applicationid $APEX_APP_ID -exptype APEXLANG -dir $target -f" \
  | sqlcl_script "$work/apex-export.log" || true
if [[ -n $(find "$dir" -name "$page_glob" | head -1) ]]; then
  workaround="apex export -f does NOT remove it either"
else
  workaround="apex export -f removes it"
fi

[[ -n $stale ]] && fail "deleted page $page left behind: ${stale#"$TEST_REPO/"} ($workaround)"
pass "page $page file removed by project export ($workaround)"
