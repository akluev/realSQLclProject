#!/usr/bin/env bash
# 021: project export of an APEX application must be repeatable: a second export straight after
# the first, with nothing changed in APEX, must succeed and write the same files. In APEXlang
# mode SQLcl refuses to overwrite the (uncommitted) result of the first export.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/021"
mkdir -p "$work"
cleanup() { restore_from_baseline src; rm -f "$RUN_DIR/apex-export.done"; }
trap cleanup EXIT

# snapshot: every file of the export with its content hash
snapshot() {
  (cd "$(apex_apps_dir)" && find . -type f | sort | while IFS= read -r f; do
    printf '%s %s\n' "$(git hash-object --no-filters "$f")" "$f"
  done)
}

fresh_apex_export "$work/first-export.log"
snapshot >"$work/first.txt"

rc=0
echo "project export -o APEX.$APEX_APP_ID" | sqlcl_script "$work/second-export.log" || rc=$?
err=$(first_error "$work/second-export.log")
[[ $rc == 0 && -z $err ]] || fail "second project export failed: ${err:-exit code $rc}"
snapshot >"$work/second.txt"

changed=$(diff "$work/first.txt" "$work/second.txt" | grep -c '^[<>]' || true)
[[ $changed == 0 ]] || fail "second project export, with nothing changed in APEX, changed $changed file entr(ies), see $work/*.txt"
pass "second project export succeeded and wrote the same $(wc -l <"$work/first.txt" | tr -d ' ') files"
