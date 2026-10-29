#!/usr/bin/env bash
# Build the cross-version report regression/results/README.md from tests.json and
# every regression/results/<version>/results.json. Tests that depend on the APEX export
# mode have one row per mode.
# Usage: regression/report.sh
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
require_tools

versions=$(find "$REG_ROOT/results" -mindepth 2 -maxdepth 2 -name results.json 2>/dev/null \
  | awk -F/ '{print $(NF-1)}' | sort -V)
[[ -n $versions ]] || die "no results yet; run regression/run.sh first"
files=()
for v in $versions; do files+=("$REG_ROOT/results/$v/results.json"); done
latest=$(tail -1 <<<"$versions")

jq -rn --slurpfile tests "$REG_ROOT/tests.json" --arg versions "$(paste -sd' ' - <<<"$versions")" \
  --arg latest "$latest" --arg date "$(date '+%Y-%m-%d')" '
def sevrank: {"P0": 0, "P1": 1, "P2": 2, "P3": 3}[.] // 9;
def cell: {"OK": "PASS", "KNOWN ISSUE": "FAIL", "REGRESSION": "**FAIL: regression**",
           "NEWLY FIXED": "**PASS: newly fixed**", "N/A": "n/a", "ERROR": "ERROR"}[.] // .;
def esc: gsub("\\|"; "\\|") | gsub("<"; "&lt;");
def key: "\(.id)/\(.mode // "")";
def name: if .mode == "" then .id else "\(.id) (\(.mode))" end;
def link: (.forumUrl // .articleUrl) as $u
  | (if .kind == "enhancement" then " (enhancement)" else "" end) as $k
  | (.title | esc) as $title
  | if $u then "[\($title)](\($u))\($k)" else "\($title)\($k)" end;
# one entry per test and APEX mode, with the mode fields applied ("" = mode-independent)
def variants: if .modes then . as $t | .modes | to_entries[] | $t + .value + {mode: .key}
              else . + {mode: ""} end;

[inputs] as $runs
| ($runs | map({key: .version, value: (.results | map({key: key, value: .}) | from_entries)})
         | from_entries) as $by
| ($versions | split(" ")) as $vs
| ([$tests[0][] | select(.active) | variants]
   | sort_by((.severity | sevrank), .id, ({"": 0, "readable": 1, "apexlang": 2}[.mode] // 9))) as $t
| $by[$latest] as $L
| def items(o): [$t[] | select($L[key].outcome == o)
                | "- \(name) \(.severity) \(link): \($L[key].comment | esc)"]
                | if length == 0 then ["- none"] else . end;
[
  "# SQLcl regression report",
  "",
  "Generated \($date) from tests.json and the results of SQLcl \($vs | join(", ")). Tests that depend on the APEX export mode are listed per mode: `readable` (apex.apexlang not set) and `apexlang` (apex.apexlang=true).",
  "",
  "## SQLcl \($latest): what needs attention",
  "",
  "**Regressions** (fixed earlier, failing again):", "", items("REGRESSION")[], "",
  "**Newly fixed** (expected to fail, passed; check and set `fixedIn`):", "", items("NEWLY FIXED")[], "",
  "**Errors** (test could not decide; check the logs):", "", items("ERROR")[], "",
  "## Open issues in SQLcl \($latest), by severity",
  "",
  "| Severity | ID | Mode | Area | Issue | Since | Workaround |",
  "|---|---|---|---|---|---|---|",
  ($t[] | select($L[key].result == "FAIL")
   | "| \(.severity) | \(.id) | \(if .mode == "" then "–" else .mode end) | \(.area) | \(link) | \(.introducedIn // "?") | \((.workaround // "") | esc) |"),
  "",
  "## Results by version",
  "",
  "| ID | Mode | Severity | Area | Issue | \($vs | join(" | ")) |",
  "|---|---|---|---|---|\($vs | map("---") | join("|"))|",
  ($t[] | . as $i
   | "| \(.id) | \(if .mode == "" then "–" else .mode end) | \(.severity) | \(.area) | \(link) | \($vs | map($by[.][$i | key].outcome // "" | cell) | join(" | ")) |")
] | .[]
' "${files[@]}" >"$REG_ROOT/results/README.md"

echo "Report: $REG_ROOT/results/README.md"
