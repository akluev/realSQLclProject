#!/usr/bin/env bash
# Run the SQLcl regression tests against one SQLcl version.
# Usage: regression/run.sh <sqlcl-version> [--mode readable|apexlang] [issue-id ...]
#   e.g. regression/run.sh 26.1                  all active tests, both APEX modes
#        regression/run.sh 26.2 002              one test, in every mode it has
#        regression/run.sh 26.3 --mode apexlang  only the APEXlang-mode pass
# The database is reset once; tests run in passes, one per APEX export mode, each on its own
# branch from BASELINE_TAG (see the isolation note below):
#   readable  the baseline as it is: tests without "modes", and those with modes.readable
#   apexlang  baseline + apex.apexlang=true: tests with modes.apexlang
# Results: regression/results/<version>/results.md and results.json
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

[[ $# -ge 1 ]] || die "usage: $0 <sqlcl-version> [--mode readable|apexlang] [issue-id ...]"
label=$1; shift
modes=$APEX_MODES
partial=false
if [[ ${1:-} == --mode ]]; then
  [[ -n ${2:-} && " $APEX_MODES " == *" $2 "* ]] || die "--mode must be one of: $APEX_MODES"
  modes=$2 partial=true
  shift 2
fi
(($#)) && partial=true
require_tools
load_config
use_sqlcl "$label"

OUT_DIR="$REG_ROOT/results/$SQLCL_VERSION"
LOG_ROOT="$OUT_DIR/logs"
[[ $partial == true ]] || rm -rf "$LOG_ROOT"
mkdir -p "$LOG_ROOT"
echo "SQLcl $SQLCL_VERSION, test repo $TEST_REPO, APEX modes: $modes"

repo() { git -C "$TEST_REPO" "$@"; }

[[ -z $(repo status --porcelain) ]] || die "test repo has uncommitted changes: $TEST_REPO"

# Pre-test state: reset/reset.sh (git + database), or the project's own RESET_CMD,
# run in the test project with the SQLcl version under test on PATH.
# stdin is an empty pipe: SQLcl crashes at startup (yet exits 0) when stdin is the
# Windows NUL device, as it is for many agents and schedulers.
reset_baseline() {
  local log=$1 reset
  if [[ -n ${RESET_CMD:-} ]]; then
    repo checkout -q "$BASE_BRANCH"
    reset=(eval "$RESET_CMD")
  else
    reset=(bash "$REG_ROOT/reset/reset.sh")
  fi
  echo "Resetting baseline: ${RESET_CMD:-reset/reset.sh}"
  if ! : | (cd "$TEST_REPO" && "${reset[@]}") 2>&1 | tee "$log" | sed 's/^/  | /'; then
    die "reset failed, see $log"
  fi
  ! grep -q 'Exception' "$log" || die "reset threw a Java exception, see $log"
  [[ $(repo rev-parse HEAD) == $(repo rev-parse "$BASELINE_TAG^{commit}") ]] \
    || die "reset did not put $BASE_BRANCH on $BASELINE_TAG"
  [[ -z $(repo status --porcelain) ]] || die "test repo not clean after reset"
  [[ $(sql_value "select 'ready' from dual") == ready ]] \
    || die "cannot query as $SQLCL_CONN after reset, see $RUN_DIR/sql_value.log"
  dirty=false
}

# Isolation is by branch: every pass and every isolated test starts from its own branch, and
# an export with -o writes only the objects it names, so leftovers elsewhere in the database
# do not matter. The database is reset once per run, and again only before a test with
# "resetBefore": true (e.g. a full schema export) when another test ran since the last reset.
# app_intact: the baseline application is still installed as it was (tests that change it
# restore it in their trap); if not, the next test gets a reset.
app_intact() {
  [[ $(apex_page_count "${APEX_SPARE_PAGE:-100}") == 1 ]]
}

# Test branches. Only the latest run of a version keeps its branches.
# After each test, what it left behind is committed there as evidence.
repo branch --list "regression/$SQLCL_VERSION-*" --format='%(refname:short)' \
  | xargs -r git -C "$TEST_REPO" branch -q -D
RUN_BRANCH="regression/$SQLCL_VERSION-$(date +%Y%m%d-%H%M%S)"
commit_evidence() {
  [[ $(repo branch --show-current) == "$TEST_BRANCH" ]] || repo checkout -q -f "$TEST_BRANCH"
  repo add -A
  repo commit -q -m "$1" >/dev/null || true
}
finish_branch() {
  commit_evidence "Regression run SQLcl $SQLCL_VERSION (interrupted)"
  repo checkout -q "$BASE_BRANCH"
}

if (($#)); then ids=$(printf '%s\n' "$@" | jq -R . | jq -sc .); else ids='[]'; fi
rows="$LOG_ROOT/rows.txt"
: >"$rows"

export RUN_DIR=$LOG_ROOT
reset_baseline "$LOG_ROOT/reset.log"

for mode in $modes; do
  # Tests of this pass, in area order; a test with modes gets that mode's fields
  tests=$(jq -r --argjson ids "$ids" --arg mode "$mode" '
    def rank: {"project": 1, "export": 2, "stage": 3, "apex": 4}[.area] // 9;
    map(select(.active and (($ids | length) == 0 or (.id as $i | $ids | index($i) != null))))
    | map(if .modes then (if .modes[$mode] then . + .modes[$mode] + {mode: $mode} else empty end)
          elif $mode == "readable" then . + {mode: ""}
          else empty end)
    | sort_by(rank, .id)[]
    | [.id, .mode, .area, .kind // "bug", .severity // "", .testFrom // "", .introducedIn // "",
       .fixedIn // "", .script // "", .title, .forumUrl // .articleUrl // "",
       (.resetBefore // false | tostring)] | join("\u001f")
  ' "$REG_ROOT/tests.json")
  [[ -n $tests ]] || continue

  echo "== APEX mode: $mode"
  export RUN_DIR="$LOG_ROOT/$mode"
  mkdir -p "$RUN_DIR"
  rm -f "$RUN_DIR/apex-export.done"
  unset MODE_BASE

  # Each pass on its own branch from BASELINE_TAG; no database reset between passes
  [[ -z $(repo status --porcelain) ]] || die "test repo not clean before the $mode pass"
  export TEST_BRANCH=$RUN_BRANCH
  [[ $mode == readable ]] || TEST_BRANCH="$RUN_BRANCH-$mode"
  repo checkout -q -b "$TEST_BRANCH" "$BASELINE_TAG"
  trap finish_branch EXIT

  # The mode's own baseline: a commit on BASELINE_TAG with only the mode's settings
  mode_note=
  if [[ $mode == readable ]]; then
    set_apex_mode readable || die "the baseline sets apex.apexlang=true; readable mode needs it unset"
  elif set_apex_mode "$mode" "$RUN_DIR/mode.log"; then
    commit_all "APEX mode $mode: apex.apexlang=true"
    export MODE_BASE
    MODE_BASE=$(repo rev-parse HEAD)
  else
    mode_note="apex.apexlang not supported by SQLcl $SQLCL_VERSION"
    repo checkout -q -- .
    echo "  $mode_note: tests of this mode are not run"
  fi

  # Fields are separated by \x1f: unlike tab, read keeps empty fields between non-blank separators
  while IFS=$'\x1f' read -r id tmode area kind severity test_from introduced fixed script title url reset_before; do
    workaround_result=
    # Before introducedIn: not run, unless testFrom says the behaviour existed and worked then
    if [[ -n $introduced ]] && ! ver_ge "$SQLCL_VERSION" "$introduced"; then
      if [[ -n $test_from ]] && ver_ge "$SQLCL_VERSION" "$test_from"; then expected=PASS; else expected=N/A; fi
    elif [[ -n $fixed ]] && ver_ge "$SQLCL_VERSION" "$fixed"; then
      expected=PASS
    else
      expected=FAIL
    fi

    if [[ -n $mode_note ]]; then
      result=SKIP comment=$mode_note
    elif [[ $expected == N/A ]]; then
      result=SKIP comment="introduced in $introduced"
    elif [[ -z $script ]]; then
      result=MANUAL comment="no script: run the prompt in tests.json by hand"
    else
      if [[ $reset_before == true && $dirty == true ]]; then
        echo "     reset before $id (resetBefore)"
        commit_evidence "Before the reset for test $id"
        reset_baseline "$RUN_DIR/reset-$id.log"
        repo checkout -q -f "$TEST_BRANCH"
      fi
      printf '%-4s %-8s %-6s %-3s running: %s\n' "$id" "${tmode:-–}" "$area" "$severity" "$title"
      export COMMENT_FILE="$RUN_DIR/$id.comment" WORKAROUND_FILE="$RUN_DIR/$id.workaround" APEX_MODE=$mode
      rm -f "$COMMENT_FILE" "$WORKAROUND_FILE"
      # The test's output goes to its log and, indented, to the screen while it runs
      set +e
      bash "$REG_ROOT/$script" 2>&1 </dev/null | tee "$RUN_DIR/$id.log" | sed -u 's/^/     | /'
      rc=${PIPESTATUS[0]}
      set -e
      [[ ! -s $WORKAROUND_FILE ]] || workaround_result=$(tr -d '\r' <"$WORKAROUND_FILE" | head -1)
      if [[ -s $COMMENT_FILE ]]; then
        comment=$(tr -d '\r' <"$COMMENT_FILE" | awk 'NR > 1 { printf "; " } { printf "%s", $0 }')
      else
        comment=$(tail -1 "$RUN_DIR/$id.log" | tr -d '\r')
      fi
      case $rc in 0) result=PASS ;; 1) result=FAIL ;; *) result=ERROR ;; esac
      commit_evidence "Test $id${tmode:+ ($tmode)}: $result"
      dirty=true
      if [[ -n $tmode ]] && ! app_intact; then
        comment+="; WARNING: application $APEX_APP_ID not as in the baseline after the test (page ${APEX_SPARE_PAGE:-100} missing), database reset"
        reset_baseline "$RUN_DIR/reset-after-$id.log"
        repo checkout -q -f "$TEST_BRANCH"
      fi
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
    printf '%-4s %-8s %-6s %-3s %-5s %-12s %s%s\n' "$id" "${tmode:-–}" "$area" "$severity" "$result" "$outcome" \
      "$comment" "${workaround_result:+ [workaround $workaround_result]}"
    printf '%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\n' "$id" "$tmode" "$area" "$kind" \
      "$severity" "$title" "$url" "$expected" "$result" "$outcome" "$comment" "$workaround_result" >>"$rows"
  done <<<"$tests"

  trap - EXIT
  repo checkout -q "$BASE_BRANCH"
done
[[ -s $rows ]] || die "no matching active tests"

# The test branches hold each test's evidence; delete them unless KEEP_TEST_BRANCHES=true
branch_note="$RUN_BRANCH*"
if [[ ${KEEP_TEST_BRANCHES:-false} != true ]]; then
  repo branch --list "$RUN_BRANCH" "$RUN_BRANCH-*" --format='%(refname:short)' \
    | xargs -r git -C "$TEST_REPO" branch -q -D
  branch_note="$RUN_BRANCH* (deleted after the run)"
fi

# Results. A partial run (selected tests or one mode) replaces only its rows in results.json.
baseline=$(repo rev-parse --short "$BASELINE_TAG^{commit}")
run_date=$(date '+%Y-%m-%d %H:%M')
new=$(jq -Rn --arg date "$run_date" '[inputs | split("\u001f")
  | {id: .[0], mode: .[1], area: .[2], kind: .[3], severity: .[4], title: .[5], url: .[6],
     expected: .[7], result: .[8], outcome: .[9], comment: .[10], workaround: (.[11] // ""),
     date: $date}]' <"$rows")
old='[]'
if [[ $partial == true && -f $OUT_DIR/results.json ]]; then old=$(jq '.results' "$OUT_DIR/results.json"); fi
jq -n --argjson old "$old" --argjson new "$new" --arg sqlcl "$SQLCL_RELEASE" \
  --arg version "$SQLCL_VERSION" --arg date "$run_date" \
  --arg baseline "$BASELINE_TAG ($baseline)" --arg branch "$branch_note" '
  def key: "\(.id)/\(.mode // "")";
  ($new | map(key)) as $keys
  | { sqlcl: $sqlcl, version: $version, date: $date, baseline: $baseline, testBranch: $branch,
      results: ($old | map(select(key as $k | $keys | index($k) | not))) + $new
               | sort_by(.id, ({"": 0, "readable": 1, "apexlang": 2}[.mode // ""] // 9)) }
' >"$OUT_DIR/results.json"
write_results_md "$OUT_DIR"

# lastFailedIn in tests.json: the newest version each test (in each mode) has failed on
catalog="$REG_ROOT/tests.json"
while IFS=$'\t' read -r id tmode; do
  [[ -n $id ]] || continue
  path='.lastFailedIn'
  [[ -z $tmode ]] || path=".modes.$tmode.lastFailedIn"
  last=$(jq -r --arg id "$id" ".[] | select(.id == \$id) | $path // \"\"" "$catalog")
  if [[ -z $last ]] || ver_ge "$SQLCL_VERSION" "$last"; then
    jq --indent 2 --arg id "$id" --arg v "$SQLCL_VERSION" \
      "map(if .id == \$id then $path = \$v else . end)" "$catalog" >"$catalog.tmp"
    mv "$catalog.tmp" "$catalog"
  fi
done < <(jq -r '.[] | select(.result == "FAIL") | [.id, .mode] | @tsv' <<<"$new")
bash "$REG_ROOT/catalog.sh" >/dev/null

echo "Results: $OUT_DIR/results.md"
