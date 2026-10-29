#!/usr/bin/env bash
# Run the SQLcl regression tests against one SQLcl version.
# Usage: regression/run.sh <sqlcl-version> [issue-id ...]
#   e.g. regression/run.sh 26.1          all active tests
#        regression/run.sh 26.2 002      one test
# Results: regression/results/<version>/results.md and results.json
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

[[ $# -ge 1 ]] || die "usage: $0 <sqlcl-version> [issue-id ...]"
label=$1; shift
require_tools
load_config
use_sqlcl "$label"

OUT_DIR="$REG_ROOT/results/$SQLCL_VERSION"
export RUN_DIR="$OUT_DIR/logs"
(($#)) || rm -rf "$RUN_DIR"
mkdir -p "$RUN_DIR"
rm -f "$RUN_DIR/apex-export.done"
echo "SQLcl $SQLCL_VERSION, test repo $TEST_REPO"

repo() { git -C "$TEST_REPO" "$@"; }

[[ -z $(repo status --porcelain) ]] || die "test repo has uncommitted changes: $TEST_REPO"

# 1. Pre-test state: reset/reset.sh (git + database), or the project's own RESET_CMD,
# run in the test project with the SQLcl version under test on PATH.
# stdin is an empty pipe: SQLcl crashes at startup (yet exits 0) when stdin is the
# Windows NUL device, as it is for many agents and schedulers.
if [[ -n ${RESET_CMD:-} ]]; then
  repo checkout -q "$BASE_BRANCH"
  reset=(eval "$RESET_CMD")
else
  reset=(bash "$REG_ROOT/reset/reset.sh")
fi
echo "Resetting baseline: ${RESET_CMD:-reset/reset.sh}"
if ! : | (cd "$TEST_REPO" && "${reset[@]}") 2>&1 | tee "$RUN_DIR/reset.log" | sed 's/^/  | /'; then
  die "reset failed, see $RUN_DIR/reset.log"
fi
! grep -q 'Exception' "$RUN_DIR/reset.log" || die "reset threw a Java exception, see $RUN_DIR/reset.log"
[[ $(repo rev-parse HEAD) == $(repo rev-parse "$BASELINE_TAG^{commit}") ]] \
  || die "reset did not put $BASE_BRANCH on $BASELINE_TAG"
[[ -z $(repo status --porcelain) ]] || die "test repo not clean after reset"
[[ $(sql_value "select 'ready' from dual") == ready ]] \
  || die "cannot query as $SQLCL_CONN after reset, see $RUN_DIR/sql_value.log"

# 2. Test branch. Only the latest run of a version keeps its branches.
# After each test, what it left behind is committed there as evidence.
repo branch --list "regression/$SQLCL_VERSION-*" --format='%(refname:short)' \
  | xargs -r git -C "$TEST_REPO" branch -q -D
export TEST_BRANCH="regression/$SQLCL_VERSION-$(date +%Y%m%d-%H%M%S)"
repo checkout -q -b "$TEST_BRANCH"
commit_evidence() {
  [[ $(repo branch --show-current) == "$TEST_BRANCH" ]] || repo checkout -q -f "$TEST_BRANCH"
  repo add -A
  repo commit -q -m "$1" >/dev/null || true
}
finish_branch() {
  commit_evidence "Regression run SQLcl $SQLCL_VERSION (interrupted)"
  repo checkout -q "$BASE_BRANCH"
}
trap finish_branch EXIT

# 3. Tests, in area order
if (($#)); then ids=$(printf '%s\n' "$@" | jq -R . | jq -sc .); else ids='[]'; fi
tests=$(jq -r --argjson ids "$ids" '
  def rank: {"project": 1, "export": 2, "stage": 3, "apex": 4}[.area] // 9;
  map(select(.active and (($ids | length) == 0 or (.id as $i | $ids | index($i) != null))))
  | sort_by(rank, .id)[]
  | [.id, .area, .kind // "bug", .severity // "", .testFrom // "", .introducedIn // "",
     .fixedIn // "", .script // "", .title, .forumUrl // .articleUrl // ""] | join("\u001f")
' "$REG_ROOT/tests.json")
[[ -n $tests ]] || die "no matching active tests"

# Fields are separated by \x1f: unlike tab, read keeps empty fields between non-blank separators
rows="$RUN_DIR/rows.txt"
: >"$rows"
while IFS=$'\x1f' read -r id area kind severity test_from introduced fixed script title url; do
  # Before introducedIn: not run, unless testFrom says the behaviour existed and worked then
  if [[ -n $introduced ]] && ! ver_ge "$SQLCL_VERSION" "$introduced"; then
    if [[ -n $test_from ]] && ver_ge "$SQLCL_VERSION" "$test_from"; then expected=PASS; else expected=N/A; fi
  elif [[ -n $fixed ]] && ver_ge "$SQLCL_VERSION" "$fixed"; then
    expected=PASS
  else
    expected=FAIL
  fi

  if [[ $expected == N/A ]]; then
    result=SKIP comment="introduced in $introduced"
  elif [[ -z $script ]]; then
    result=MANUAL comment="no script: run the prompt in tests.json by hand"
  else
    printf '%-4s %-6s %-3s running: %s\n' "$id" "$area" "$severity" "$title"
    rc=0
    export COMMENT_FILE="$RUN_DIR/$id.comment"
    rm -f "$COMMENT_FILE"
    bash "$REG_ROOT/$script" >"$RUN_DIR/$id.log" 2>&1 </dev/null || rc=$?
    if [[ -s $COMMENT_FILE ]]; then
      comment=$(tr -d '\r' <"$COMMENT_FILE" | awk 'NR > 1 { printf "; " } { printf "%s", $0 }')
    else
      comment=$(tail -1 "$RUN_DIR/$id.log" | tr -d '\r')
    fi
    case $rc in 0) result=PASS ;; 1) result=FAIL ;; *) result=ERROR ;; esac
    commit_evidence "Test $id: $result"
  fi

  case "$expected/$result" in
    */SKIP)      outcome="N/A" ;;
    */MANUAL)    outcome="MANUAL" ;;
    */ERROR)     outcome="ERROR" ;;
    PASS/PASS)   outcome="OK" ;;
    PASS/FAIL)   outcome="REGRESSION" ;;
    FAIL/FAIL)   outcome="KNOWN ISSUE" ;;
    FAIL/PASS)   outcome="NEWLY FIXED" ;;
  esac
  printf '%-4s %-6s %-3s %-5s %-12s %s\n' "$id" "$area" "$severity" "$result" "$outcome" "$comment"
  printf '%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\n' "$id" "$area" "$kind" "$severity" \
    "$title" "$url" "$expected" "$result" "$outcome" "$comment" >>"$rows"
done <<<"$tests"

trap - EXIT
repo checkout -q "$BASE_BRANCH"

# The test branches hold each test's evidence; delete them unless KEEP_TEST_BRANCHES=true
branch_note=$TEST_BRANCH
if [[ ${KEEP_TEST_BRANCHES:-false} != true ]]; then
  repo branch --list "$TEST_BRANCH" "$TEST_BRANCH-*" --format='%(refname:short)' \
    | xargs -r git -C "$TEST_REPO" branch -q -D
  branch_note="$TEST_BRANCH (deleted after the run)"
fi

# 4. Results. A run of selected tests replaces only their rows in results.json.
baseline=$(repo rev-parse --short "$BASELINE_TAG^{commit}")
run_date=$(date '+%Y-%m-%d %H:%M')
new=$(jq -Rn --arg date "$run_date" '[inputs | split("\u001f")
  | {id: .[0], area: .[1], kind: .[2], severity: .[3], title: .[4], url: .[5],
     expected: .[6], result: .[7], outcome: .[8], comment: .[9], date: $date}]' <"$rows")
old='[]'
if (($#)) && [[ -f $OUT_DIR/results.json ]]; then old=$(jq '.results' "$OUT_DIR/results.json"); fi
jq -n --argjson old "$old" --argjson new "$new" --arg sqlcl "$SQLCL_RELEASE" \
  --arg version "$SQLCL_VERSION" --arg date "$run_date" \
  --arg baseline "$BASELINE_TAG ($baseline)" --arg branch "$branch_note" '
  ($new | map(.id)) as $ids
  | { sqlcl: $sqlcl, version: $version, date: $date, baseline: $baseline, testBranch: $branch,
      results: ($old | map(select(.id as $i | $ids | index($i) | not))) + $new | sort_by(.id) }
' >"$OUT_DIR/results.json"

jq -r '
  def esc: gsub("\\|"; "\\|") | gsub("<"; "&lt;");
  "# SQLcl \(.version) regression results", "",
  "- \(.sqlcl)", "- Last run: \(.date)", "- Baseline: `\(.baseline)`, test branch `\(.testBranch)`", "",
  "| ID | Severity | Area | Issue | Expected | Result | Outcome | Comment | Run |",
  "|---|---|---|---|---|---|---|---|---|",
  (.results[]
   | ((.title | esc) as $t | (.url // .forumUrl // "") as $u
      | if $u != "" then "[\($t)](\($u))" else $t end) as $issue
   | (if .kind == "bug" then "" else " (\(.kind))" end) as $kind
   | "| \(.id) | \(.severity) | \(.area) | \($issue)\($kind) | \(.expected) | \(.result) | **\(.outcome)** | \(.comment | esc) | \(.date // "") |")
' "$OUT_DIR/results.json" >"$OUT_DIR/results.md"

# 5. lastFailedIn in tests.json: the newest version each test has failed on
catalog="$REG_ROOT/tests.json"
for id in $(jq -r '.[] | select(.result == "FAIL") | .id' <<<"$new"); do
  last=$(jq -r --arg id "$id" '.[] | select(.id == $id) | .lastFailedIn // ""' "$catalog")
  if [[ -z $last ]] || ver_ge "$SQLCL_VERSION" "$last"; then
    jq --indent 2 --arg id "$id" --arg v "$SQLCL_VERSION" \
      'map(if .id == $id then .lastFailedIn = $v else . end)' "$catalog" >"$catalog.tmp"
    mv "$catalog.tmp" "$catalog"
  fi
done
bash "$REG_ROOT/catalog.sh" >/dev/null

echo "Results: $OUT_DIR/results.md"
