#!/usr/bin/env bash
# 002: project export must not corrupt binary APEX static files.
# Every binary file in the baseline export must come back byte-identical, wherever the export
# puts it (the folder layout depends on the version and the APEX mode).
source "$(dirname "$0")/../../lib/common.sh"

export_apex_app

dir=$(apex_apps_dir)
empty_tree=4b825dc642cb6eb9a060e54bf8d69288fbee4904
# git numstat shows "-" line counts for binary files
binaries=$(git -C "$TEST_REPO" diff --numstat "$empty_tree" "$BASELINE_TAG" -- "$(apex_app_path)" \
  | awk -F'\t' '$1 == "-" { print $3 }')
[[ -n $binaries ]] || error "baseline has no binary files to check"

checked=0 damaged=() damaged_at=() missing=()
while IFS= read -r path; do
  checked=$((checked + 1))
  name=${path##*/}
  found=$(find "$dir" -type f -iname "$name" | head -1)
  if [[ -z $found ]]; then
    missing+=("$name")
    continue
  fi
  want=$(git -C "$TEST_REPO" rev-parse "$BASELINE_TAG:$path")
  got=$(git -C "$TEST_REPO" hash-object --no-filters "$found")
  if [[ $want != "$got" ]]; then
    size_want=$(git -C "$TEST_REPO" cat-file -s "$BASELINE_TAG:$path")
    size_got=$(wc -c <"$found" | tr -d ' ')
    damaged+=("$name ($size_want -> $size_got bytes)")
    damaged_at+=("$found"$'\t'"$want")
  fi
done <<<"$binaries"

if ((${#damaged[@]})); then
  # Only when the bug is there: does the documented workaround rewrite the files correctly
  # where project export put them? Reported in its own column, never as the verdict.
  apex_export_workaround "$RUN_DIR/002-apex-export.log" || true
  still=0
  for entry in "${damaged_at[@]}"; do
    file=${entry%%$'\t'*} want=${entry#*$'\t'}
    got=$(find "$(dirname "$file")" -maxdepth 1 -type f -iname "${file##*/}" 2>/dev/null | head -1)
    [[ -n $got && $(git -C "$TEST_REPO" hash-object --no-filters "$got") == "$want" ]] || still=$((still + 1))
  done
  if ((still)); then
    workaround "does not work" "apex export -f leaves $still of ${#damaged_at[@]} file(s) changed where project export put them"
  else
    workaround works "apex export -f rewrites ${#damaged_at[@]} file(s) byte-identical"
  fi
  fail "${#damaged[@]} of $checked binary file(s) changed: ${damaged[*]}"
fi
((${#missing[@]})) && error "not exported at all: ${missing[*]}"
pass "all $checked binary file(s) byte-identical"
