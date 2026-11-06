#!/usr/bin/env bash
# Write regression/tests.md, the readable catalogue of all tests, from tests.json.
# Run it after every change to tests.json (run.sh does, since it updates lastFailedIn).
# Usage: regression/catalog.sh
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
require_tools

jq -r --arg date "$(date '+%Y-%m-%d')" '
def esc: gsub("\\|"; "\\|") | gsub("<"; "&lt;");
def rank: {"project": 1, "export": 2, "stage": 3, "apex": 4, "deploy": 5}[.area] // 9;
def v: . // "–";
def link($text; $url): if $url then "[\($text)](\($url))" else empty end;
# one entry per test and APEX mode, with the mode fields applied ("" = mode-independent)
def variants: if .modes then . as $t | .modes | to_entries | sort_by(.key)[] | $t + .value + {mode: .key}
              else . + {mode: ""} end;
def versions: "Introduced: \(.introducedIn | v); fixed: \(.fixedIn | v); last failed: \(.lastFailedIn | v)\(if .testFrom then "; tested from \(.testFrom)" else "" end)";
sort_by(.id) as $t
| [
  "# SQLcl Regression Tests",
  "",
  "Generated \($date) from [tests.json](tests.json); do not edit by hand, run `regression/catalog.sh`.",
  "",
  "Each test checks one SQLcl Project issue. **Introduced** / **Fixed** are the SQLcl versions where the issue appeared and was fixed; a fixed issue keeps being tested to catch regressions. **Last failed** is the newest version the test failed on. Inactive tests are not run.",
  "",
  "**Mode** is the APEX export mode: tests that depend on it run once per mode, with their own versions. `readable`: apex.apexlang not set (the baseline); `apexlang`: apex.apexlang=true (SQLcl 26.2 and later); `–`: does not depend on it.",
  "",
  "| ID | Mode | Severity | Kind | Area | Issue | Introduced | Fixed | Last failed | Active |",
  "|---|---|---|---|---|---|---|---|---|---|",
  ($t[] | variants
   | "| [\(.id)](#t\(.id)) | \(if .mode == "" then "–" else .mode end) | \(.severity // "") | \(.kind // "bug") | \(.area) | \(.title | esc) | \(.introducedIn | v) | \(.fixedIn | v) | \(.lastFailedIn | v) | \(if .active then "yes" else "no" end) |"),
  "",
  ($t[] |
    "<a id=\"t\(.id)\"></a>",
    "## \(.id). \(.title | esc)",
    "",
    "\(.severity) \(.kind // "bug"), area `\(.area)`\(if .active then "" else "; **inactive**" end).",
    "",
    (if .modes then
       (.modes | to_entries | sort_by(.key)[]
        | "- **\(.key) mode:** \(.value | versions)\(if .value.oracleStatus then ". Oracle status: \(.value.oracleStatus)" else "" end)\(if .value.workaround then ". Workaround: \(.value.workaround)" else "" end)")
     else "- **Versions:** \(versions)" end),
    "- **Oracle status:** \(.oracleStatus // "–")",
    ([link("Forum post"; .forumUrl), link("Article"; .articleUrl), link("Oracle documentation"; .oracleDocUrl), link("Documentation"; (if .docRef then "../" + .docRef else null end))]
     + [.modes // {} | to_entries | sort_by(.key)[] | link("Article (\(.key) mode)"; .value.articleUrl)]
     | if length > 0 then "- **Sources:** " + join(", ") else empty end),
    "- **Workaround:** \(.workaround // "–")",
    "- **How it is tested:** \(.prompt)",
    "- **Passes when:** \(.successCriteria)",
    "- **Script:** \(if .script then "[\(.script)](\(.script))" else "none (manual test: follow the steps above)" end)",
    ""
  )
] | .[]
' "$REG_ROOT/tests.json" >"$REG_ROOT/tests.md"

echo "Catalogue: $REG_ROOT/tests.md"
