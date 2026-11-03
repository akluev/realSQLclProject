#!/usr/bin/env bash
# 001: project export must keep the case of APEXlang file and folder names.
# Every mixed-case name in the baseline export must come back with the same case, wherever
# the export puts it (the folder layout depends on the version and the APEX mode).
source "$(dirname "$0")/../../lib/common.sh"

export_apex_app

dir=$(apex_apps_dir)
names=$(baseline_app_files | sed "s|^$(apex_app_path)/||" | tr '/' '\n' | grep '[A-Z]' | sort -u)
[[ -n $names ]] || error "baseline has no mixed-case names to check"

checked=0 lost=() wanted=() missing=()
while IFS= read -r name; do
  checked=$((checked + 1))
  found=$(find "$dir" -iname "$name" | head -1)
  if [[ -z $found ]]; then
    missing+=("$name")
  elif [[ ${found##*/} != "$name" ]]; then
    lost+=("$name -> ${found##*/}")
    wanted+=("$(dirname "$found")/$name")
  fi
done <<<"$names"

if ((${#lost[@]})); then
  # Only when the bug is there: does the documented workaround give the names their case
  # back where project export put them? Reported in its own column, never as the verdict.
  apex_export_workaround "$RUN_DIR/001-apex-export.log" || true
  still=0
  for want in "${wanted[@]}"; do
    got=$(find "$(dirname "$want")" -maxdepth 1 -iname "${want##*/}" 2>/dev/null | head -1)
    [[ ${got##*/} == "${want##*/}" ]] || still=$((still + 1))
  done
  if ((still)); then
    workaround "does not work" "apex export -f leaves $still of ${#wanted[@]} name(s) wrong where project export put them"
  else
    workaround works "apex export -f restores the case of ${#wanted[@]} name(s)"
  fi
  fail "case lost in ${#lost[@]} of $checked name(s): ${lost[*]}"
fi
((${#missing[@]})) && error "not exported at all: ${missing[*]}"
pass "all $checked mixed-case name(s) kept"
