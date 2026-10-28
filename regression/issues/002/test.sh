#!/usr/bin/env bash
# 002: project export must not corrupt binary APEX static files.
# Every binary file in the baseline export must come back byte-identical.
source "$(dirname "$0")/../../lib/common.sh"

export_apex_app

dir="$TEST_REPO/$(apex_app_path)"
empty_tree=4b825dc642cb6eb9a060e54bf8d69288fbee4904
# git numstat shows "-" line counts for binary files
binaries=$(git -C "$TEST_REPO" diff --numstat "$empty_tree" "$BASELINE_TAG" -- "$(apex_app_path)" \
  | awk -F'\t' '$1 == "-" { print $3 }')
[[ -n $binaries ]] || error "baseline has no binary files to check"

checked=0 damaged=() missing=()
while IFS= read -r path; do
  checked=$((checked + 1))
  name=${path##*/}
  found=$(find "$dir" -type f -iname "$name" | head -1)
  if [[ -z $found ]]; then
    missing+=("$name")
    continue
  fi
  want=$(git -C "$TEST_REPO" cat-file blob "$BASELINE_TAG:$path" | sha1sum | cut -d' ' -f1)
  got=$(sha1sum <"$found" | cut -d' ' -f1)
  if [[ $want != "$got" ]]; then
    size_want=$(git -C "$TEST_REPO" cat-file -s "$BASELINE_TAG:$path")
    size_got=$(wc -c <"$found" | tr -d ' ')
    damaged+=("$name ($size_want -> $size_got bytes)")
  fi
done <<<"$binaries"

((${#damaged[@]})) && fail "${#damaged[@]} of $checked binary file(s) changed: ${damaged[*]}"
((${#missing[@]})) && error "not exported at all: ${missing[*]}"
pass "all $checked binary file(s) byte-identical"
