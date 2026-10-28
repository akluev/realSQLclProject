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
command -v jq >/dev/null || die "jq is required"
load_config
use_sqlcl "$label"

OUT_DIR="$REG_ROOT/results/$SQLCL_VERSION"
export RUN_DIR="$OUT_DIR/logs"
rm -rf "$RUN_DIR"
mkdir -p "$RUN_DIR"
echo "SQLcl $SQLCL_VERSION, test repo $TEST_REPO"

repo() { git -C "$TEST_REPO" "$@"; }

[[ -z $(repo status --porcelain) ]] || die "test repo has uncommitted changes: $TEST_REPO"

# 1. Pre-test state: base branch, then the repo's own reset (git + database)
repo checkout -q "$BASE_BRANCH"
echo "Resetting baseline: $RESET_CMD"
if ! (cd "$TEST_REPO" && eval "$RESET_CMD") 2>&1 | tee "$RUN_DIR/reset.log" | sed 's/^/  | /'; then
  die "reset failed, see $RUN_DIR/reset.log"
fi
[[ $(repo rev-parse HEAD) == $(repo rev-parse "$BASELINE_TAG^{commit}") ]] \
  || die "reset did not put $BASE_BRANCH on $BASELINE_TAG"
[[ -z $(repo status --porcelain) ]] || die "test repo not clean after reset"
[[ $(sql_value "select 'ready' from dual") == ready ]] \
  || die "cannot query as $SQLCL_CONN after reset, see $RUN_DIR/sql_value.log"

# 2. Test branch; whatever the tests leave behind is committed there as evidence
test_branch="regression/$SQLCL_VERSION-$(date +%Y%m%d-%H%M%S)"
repo checkout -q -b "$test_branch"
finish_branch() {
  if [[ $(repo branch --show-current) == "$test_branch" ]]; then
    repo add -A
    repo commit -q -m "Regression run SQLcl $SQLCL_VERSION" >/dev/null || true
    repo checkout -q "$BASE_BRANCH"
  fi
}
trap finish_branch EXIT

# 3. Tests, in area order
if (($#)); then ids=$(printf '%s\n' "$@" | jq -R . | jq -sc .); else ids='[]'; fi
tests=$(jq -r --argjson ids "$ids" '
  def rank: {"project": 1, "export": 2, "stage": 3, "apex": 4}[.area] // 9;
  map(select(.active and (($ids | length) == 0 or (.id as $i | $ids | index($i) != null))))
  | sort_by(rank, .id)[]
  | [.id, .area, .introducedIn // "", .fixedIn // "", .script, .title, .forumUrl // ""] | join("\u001f")
' "$REG_ROOT/tests.json")
[[ -n $tests ]] || die "no matching active tests"

# Fields are separated by \x1f: unlike tab, read keeps empty fields between non-blank separators
rows="$RUN_DIR/rows.txt"
: >"$rows"
while IFS=$'\x1f' read -r id area introduced fixed script title url; do
  if [[ -n $introduced ]] && ! ver_ge "$SQLCL_VERSION" "$introduced"; then
    expected=N/A
  elif [[ -n $fixed ]] && ver_ge "$SQLCL_VERSION" "$fixed"; then
    expected=PASS
  else
    expected=FAIL
  fi

  if [[ $expected == N/A ]]; then
    result=SKIP comment="introduced in $introduced"
  else
    rc=0
    export COMMENT_FILE="$RUN_DIR/$id.comment"
    rm -f "$COMMENT_FILE"
    bash "$REG_ROOT/$script" >"$RUN_DIR/$id.log" 2>&1 </dev/null || rc=$?
    if [[ -s $COMMENT_FILE ]]; then
      comment=$(tr -d '\r' <"$COMMENT_FILE" | paste -sd ';' - | sed 's/;/; /g')
    else
      comment=$(tail -1 "$RUN_DIR/$id.log" | tr -d '\r')
    fi
    case $rc in 0) result=PASS ;; 1) result=FAIL ;; *) result=ERROR ;; esac
  fi

  case "$expected/$result" in
    */SKIP)      outcome="N/A" ;;
    */ERROR)     outcome="ERROR" ;;
    PASS/PASS)   outcome="OK" ;;
    PASS/FAIL)   outcome="REGRESSION" ;;
    FAIL/FAIL)   outcome="KNOWN ISSUE" ;;
    FAIL/PASS)   outcome="NEWLY FIXED" ;;
  esac
  printf '%-4s %-6s %-5s %-12s %s\n' "$id" "$area" "$result" "$outcome" "$comment"
  printf '%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\n' \
    "$id" "$area" "$title" "$url" "$expected" "$result" "$outcome" "$comment" >>"$rows"
done <<<"$tests"

finish_branch
trap - EXIT

# 4. Results
baseline=$(repo rev-parse --short "$BASELINE_TAG^{commit}")
run_date=$(date '+%Y-%m-%d %H:%M')
jq -Rn --arg sqlcl "$SQLCL_RELEASE" --arg version "$SQLCL_VERSION" --arg date "$run_date" \
  --arg baseline "$BASELINE_TAG ($baseline)" --arg branch "$test_branch" '
  { sqlcl: $sqlcl, version: $version, date: $date, baseline: $baseline, testBranch: $branch,
    results: [inputs | split("\u001f")
      | {id: .[0], area: .[1], title: .[2], forumUrl: .[3],
         expected: .[4], result: .[5], outcome: .[6], comment: .[7]}] }
' <"$rows" >"$OUT_DIR/results.json"

{
  echo "# SQLcl $SQLCL_VERSION regression results"
  echo
  echo "- $SQLCL_RELEASE"
  echo "- Run: $run_date"
  echo "- Baseline: \`$BASELINE_TAG\` ($baseline), test branch \`$test_branch\`"
  echo
  echo "| ID | Area | Issue | Expected | Result | Outcome | Comment |"
  echo "|---|---|---|---|---|---|---|"
  while IFS=$'\x1f' read -r id area title url expected result outcome comment; do
    [[ -n $url ]] && title="[$title]($url)"
    echo "| $id | $area | $title | $expected | $result | **$outcome** | ${comment//|/\\|} |"
  done <"$rows"
} >"$OUT_DIR/results.md"

echo "Results: $OUT_DIR/results.md"
