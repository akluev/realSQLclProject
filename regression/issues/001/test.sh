#!/usr/bin/env bash
# 001: project export must keep the case of APEXlang file and folder names.
# Every mixed-case name in the baseline export must come back with the same case.
source "$(dirname "$0")/../../lib/common.sh"

export_apex_app

dir="$TEST_REPO/$(apex_app_path)"
names=$(baseline_app_files | sed "s|^$(apex_app_path)/||" | tr '/' '\n' | grep '[A-Z]' | sort -u)
[[ -n $names ]] || error "baseline has no mixed-case names to check"

checked=0 lost=() missing=()
while IFS= read -r name; do
  checked=$((checked + 1))
  found=$(find "$dir" -iname "$name" | head -1)
  if [[ -z $found ]]; then
    missing+=("$name")
  elif [[ ${found##*/} != "$name" ]]; then
    lost+=("$name -> ${found##*/}")
  fi
done <<<"$names"

((${#lost[@]})) && fail "case lost in ${#lost[@]} of $checked name(s): ${lost[*]}"
((${#missing[@]})) && error "not exported at all: ${missing[*]}"
pass "all $checked mixed-case name(s) kept"
