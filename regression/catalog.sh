#!/usr/bin/env bash
# Write regression/tests.md, the readable catalogue of all tests, from tests.json.
# Run it after every change to tests.json (run.sh does, since it updates lastFailedIn).
# Usage: regression/catalog.sh
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
require_tools

jq -r --arg date "$(date '+%Y-%m-%d')" '
def esc: gsub("\\|"; "\\|") | gsub("<"; "&lt;");
def rank: {"project": 1, "export": 2, "stage": 3, "apex": 4}[.area] // 9;
def v: . // "–";
def link($text; $url): if $url then "[\($text)](\($url))" else empty end;
sort_by(rank, .id) as $t
| [
  "# SQLcl Regression Tests",
  "",
  "Generated \($date) from [tests.json](tests.json); do not edit by hand, run `regression/catalog.sh`.",
  "",
  "Each test checks one SQLcl Project issue. **Introduced** / **Fixed** are the SQLcl versions where the issue appeared and was fixed; a fixed issue keeps being tested to catch regressions. **Last failed** is the newest version the test failed on. Inactive tests are not run.",
  "",
  "| ID | Severity | Kind | Area | Issue | Introduced | Fixed | Last failed | Active |",
  "|---|---|---|---|---|---|---|---|---|",
  ($t[] | "| [\(.id)](#t\(.id)) | \(.severity // "") | \(.kind // "bug") | \(.area) | \(.title | esc) | \(.introducedIn | v) | \(.fixedIn | v) | \(.lastFailedIn | v) | \(if .active then "yes" else "no" end) |"),
  "",
  ($t[] |
    "<a id=\"t\(.id)\"></a>",
    "## \(.id). \(.title | esc)",
    "",
    "\(.severity) \(.kind // "bug"), area `\(.area)`. Introduced: \(.introducedIn | v); fixed: \(.fixedIn | v); last failed: \(.lastFailedIn | v)\(if .testFrom then "; tested from \(.testFrom)" else "" end)\(if .active then "" else "; **inactive**" end).",
    "",
    "- **Oracle status:** \(.oracleStatus // "–")",
    ([link("Forum post"; .forumUrl), link("Article"; .articleUrl), link("Documentation"; (if .docRef then "../" + .docRef else null end))] | if length > 0 then "- **Sources:** " + join(", ") else empty end),
    "- **Workaround:** \(.workaround // "–")",
    "- **How it is tested:** \(.prompt)",
    "- **Passes when:** \(.successCriteria)",
    "- **Script:** \(if .script then "[\(.script)](\(.script))" else "none (manual test: follow the steps above)" end)",
    ""
  )
] | .[]
' "$REG_ROOT/tests.json" >"$REG_ROOT/tests.md"

echo "Catalogue: $REG_ROOT/tests.md"
