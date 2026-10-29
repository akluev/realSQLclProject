#!/usr/bin/env bash
# Shared helpers for run.sh and the issue tests (issues/<id>/test.sh).
# Issue tests end with pass/fail/error (exit 0/1/2); the message is the result comment,
# written to COMMENT_FILE (set by run.sh) so cleanup output after it does not replace it.

REG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() { echo "ERROR: $*" >&2; exit 2; }

# require_tools: stop at once when a command the suite relies on is missing
require_tools() {
  local tool missing=()
  for tool in git jq sed awk grep find sort tar tr paste cut wc xargs; do
    type -P "$tool" >/dev/null || missing+=("$tool")   # -P: executables only, not the jq wrapper
  done
  ((${#missing[@]} == 0)) || die "missing required command(s): ${missing[*]}"
  printf '1.10\n1.9\n' | sort -V >/dev/null 2>&1 || die "sort does not support -V (version sort)"
}

# jq without the carriage returns that Windows builds put at the end of every line
jq() { command jq "$@" | tr -d '\r'; }

# The first verdict wins: a helper failing later in an EXIT trap must not replace it
comment() { echo "$*"; [[ -z ${COMMENT_FILE:-} || -s $COMMENT_FILE ]] || echo "$*" >"$COMMENT_FILE"; }
pass()  { comment "$*"; exit 0; }
fail()  { comment "$*"; exit 1; }
error() { comment "$*"; exit 2; }
# workaround <works|"does not work"> <detail>: the test's check of the issue's workaround. Reported
# in its own column; the verdict comes only from the documented command.
workaround() {
  echo "workaround $1: $2"
  [[ -z ${WORKAROUND_FILE:-} ]] || echo "$1: $2" >"$WORKAROUND_FILE"
}
# warn: add a note to the comment, e.g. from cleanup that runs after the verdict
warn()  { echo "WARNING: $*" >&2; [[ -z ${COMMENT_FILE:-} ]] || echo "WARNING: $*" >>"$COMMENT_FILE"; }

load_config() {
  local cfg="${REG_CONFIG:-$REG_ROOT/config.sh}"
  [[ -f $cfg ]] || die "missing $cfg (copy config.example.sh and edit it)"
  # shellcheck source=/dev/null
  source "$cfg"
  local v
  for v in TEST_REPO BASE_BRANCH BASELINE_TAG SQLCL_CONN APEX_SCHEMA APEX_WORKSPACE APEX_APP_ID; do
    [[ -n ${!v:-} ]] || die "$v is not set in $cfg"
    export "${v?}"
  done
  for v in SCHEMA_CONN APEX_SPARE_PAGE RESET_CMD KEEP_TEST_BRANCHES SHOW_SQLCL_OUTPUT; do
    [[ -z ${!v:-} ]] || export "${v?}"
  done
}

# use_sqlcl <version-label>: put that SQLcl first on PATH and set SQLCL_VERSION (e.g. 26.1.2)
use_sqlcl() {
  local var="SQLCL_HOME_${1//./_}"
  local home="${!var:-}"
  [[ -n $home && -x $home/bin/sql ]] || die "no SQLcl for $1: set $var in config.sh"
  export PATH="$home/bin:$PATH"
  SQLCL_RELEASE="$(sql -V | tr -d '\r')"
  SQLCL_VERSION="$(sed -n 's/.*Release \([0-9.]*\).*/\1/p' <<<"$SQLCL_RELEASE")"
  SQLCL_VERSION="${SQLCL_VERSION%.0}"
  [[ $SQLCL_VERSION == "$1" || $SQLCL_VERSION == "$1".* ]] \
    || die "$home is SQLcl $SQLCL_VERSION, not $1"
  export SQLCL_RELEASE SQLCL_VERSION
}

# base_ref: the commit tests treat as the baseline. In APEXlang mode run.sh sets MODE_BASE to
# a commit on BASELINE_TAG that only adds apex.apexlang=true; otherwise BASELINE_TAG.
base_ref() { echo "${MODE_BASE:-$BASELINE_TAG}"; }

# APEX export modes. Tests with "modes" in tests.json run once per mode (APEX_MODE):
#   readable  apex.apexlang not set (the baseline)
#   apexlang  apex.apexlang=true
APEX_MODES="readable apexlang"

# set_apex_mode <mode> <log>: configure the test project for an APEX mode; false when this
# SQLcl does not support it (26.1 has no apex.apexlang setting)
set_apex_mode() {
  local cfg="$TEST_REPO/.dbtools/project.config.json"
  case $1 in
    readable) ! grep -q "\"apexlang\" *: *true" "$cfg" ;;
    apexlang)
      echo "project config set -name apex.apexlang -value true" | sqlcl_script "$2" || return 1
      grep -q "\"apexlang\" *: *true" "$cfg" ;;
    *) return 1 ;;
  esac
}

# ver_ge <a> <b>: true when version a >= version b
ver_ge() { [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" == "$2" ]]; }

# sqlcl_script <log>: run SQLcl commands from stdin inside TEST_REPO, connected as SQLCL_CONN
# (connect as the schema instead with: as_schema sqlcl_script <log>)
# With SHOW_SQLCL_OUTPUT=true (config.sh) the output is also shown while it runs.
sqlcl_script() {
  local log=$1
  {
    echo "whenever sqlerror exit failure"
    echo "whenever oserror exit failure"
    echo "conn -name $SQLCL_CONN"
    cat
    echo "exit"
  } | if [[ ${SHOW_SQLCL_OUTPUT:-false} == true ]]; then
    # shown on stderr, so callers that capture stdout (sql_value) are not affected
    (set -o pipefail; cd "$TEST_REPO" && sql -S -nolog 2>&1 | tee "$log" | sed -u 's/^/  sqlcl> /' >&2)
  else
    (cd "$TEST_REPO" && sql -S -nolog) >"$log" 2>&1
  fi
}

# as_schema <command...>: run a helper connected as SCHEMA_CONN instead of SQLCL_CONN
as_schema() {
  [[ -n ${SCHEMA_CONN:-} ]] || error "SCHEMA_CONN is not set in config.sh"
  SQLCL_CONN=$SCHEMA_CONN "$@"
}

# drop_workaround <id> <repo-file>: remove the "--TEST-<id> BEGIN" ... "--TEST-<id> END" block
# the test project keeps in a file (e.g. project.filters), to see the bug without its workaround
drop_workaround() {
  local file="$TEST_REPO/$2"
  grep -q -- "--TEST-$1 BEGIN" "$file" || error "no --TEST-$1 block in $2"
  sed "/--TEST-$1 BEGIN/,/--TEST-$1 END/d" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
}

# outside_apex_changes: src files changed or added since base_ref outside apex_apps
outside_apex_changes() {
  {
    git -C "$TEST_REPO" diff --name-only "$(base_ref)" -- src
    git -C "$TEST_REPO" ls-files --others --exclude-standard -- src
  } | grep -v "^src/database/$APEX_SCHEMA/apex_apps/" | sort -u
}

# apex_app_path: the application folder of the baseline export (readable mode)
apex_app_path() { echo "src/database/$APEX_SCHEMA/apex_apps/f$APEX_APP_ID"; }

# apex_apps_dir: absolute path of the apex_apps folder, where every mode exports to
apex_apps_dir() { echo "$TEST_REPO/src/database/$APEX_SCHEMA/apex_apps"; }

# exported_app_dir: absolute folder holding application.apx after an export; the layout
# depends on the SQLcl version and the APEX mode
exported_app_dir() {
  local app
  app=$(find "$(apex_apps_dir)" -name application.apx 2>/dev/null | head -1)
  [[ -n $app ]] && dirname "$app"
}

# apex_alias: the application alias in lower case, as used for export folders
apex_alias() {
  sql_value "select lower(alias) from apex_applications where application_id = $APEX_APP_ID"
}

# native_path <path>: path as SQLcl (Java) expects it; on Git Bash /c/x becomes C:/x
native_path() {
  if command -v cygpath >/dev/null; then cygpath -m "$1"; else echo "$1"; fi
}

# apex_import <apexlang-dir> <log>: apex validate + apex import into APEX_WORKSPACE.
# SQLcl exits 0 even when they fail, so success is read from the output.
apex_import() {
  local src log=$2
  src=$(native_path "$1")
  printf 'apex validate -input %s -ws %s\napex import -input %s -ws %s\n' \
    "$src" "$APEX_WORKSPACE" "$src" "$APEX_WORKSPACE" | sqlcl_script "$log" || return 1
  grep -q '^Validation successful' "$log" && grep -q '^Import successful' "$log"
}

# sql_value <query>: print the single value a query returns
sql_value() {
  local log="$RUN_DIR/sql_value.log"
  printf 'set heading off feedback off pagesize 0 verify off\n%s;\n' "$1" | sqlcl_script "$log" || return 1
  grep -v '^[[:space:]]*$' "$log" | tail -1 | tr -d '\r '
}

# baseline_app_files: files of the APEX app export at BASELINE_TAG (repo-relative paths)
baseline_app_files() {
  git -C "$TEST_REPO" ls-tree -r --name-only "$BASELINE_TAG" -- "$(apex_app_path)"
}

# fresh_apex_export <log>: `project export -o APEX.<id>` into an empty apex_apps folder.
# The old export is removed first: on a case-insensitive file system an
# overwrite keeps the old file-name case and would hide a lowercasing bug.
fresh_apex_export() {
  local log=$1 apps="$TEST_REPO/src/database/$APEX_SCHEMA/apex_apps"
  rm -rf "$apps"
  echo "project export -o APEX.$APEX_APP_ID" | sqlcl_script "$log" \
    || error "project export failed, see $log"
  [[ -n $(find "$apps" -name application.apx 2>/dev/null | head -1) ]] \
    || error "project export wrote no application.apx under apex_apps, see $log"
}

# export_apex_app: fresh_apex_export, done once per run and shared by the export tests
export_apex_app() {
  local marker="$RUN_DIR/apex-export.done"
  [[ -f $marker ]] && return 0
  fresh_apex_export "$RUN_DIR/apex-export.log"
  touch "$marker"
}

# restore_from_baseline <path>: make a repo path exactly as it is at base_ref
restore_from_baseline() {
  rm -rf "${TEST_REPO:?}/$1"
  if git -C "$TEST_REPO" cat-file -e "$(base_ref):$1" 2>/dev/null; then
    git -C "$TEST_REPO" checkout -q "$(base_ref)" -- "$1"
  fi
}

# restore_apex_app_dir: app export folder back to base_ref; later tests export again
restore_apex_app_dir() {
  restore_from_baseline "src/database/$APEX_SCHEMA/apex_apps"
  rm -f "$RUN_DIR/apex-export.done"
}

# keep_only_apex_export: undo everything an export wrote outside apex_apps
# (e.g. unrequested users), so a following stage sees only the application
keep_only_apex_export() {
  local apps="src/database/$APEX_SCHEMA/apex_apps" keep="$RUN_DIR/apex_apps.keep"
  rm -rf "$keep"
  mv "$TEST_REPO/$apps" "$keep"
  restore_from_baseline src
  rm -rf "${TEST_REPO:?}/$apps"
  mv "$keep" "$TEST_REPO/$apps"
}

# isolate_branch <id>: continue the test on its own branch from base_ref, so its
# commits and stage output do not leak into later tests. leave_branch (run it from an
# EXIT trap) commits what is left there as evidence and returns to the previous branch.
isolate_branch() {
  ISOLATED_FROM=$(git -C "$TEST_REPO" branch --show-current)
  ISOLATED_BRANCH="${TEST_BRANCH:-regression/manual}-$1"
  git -C "$TEST_REPO" branch -q -D "$ISOLATED_BRANCH" 2>/dev/null || true
  git -C "$TEST_REPO" checkout -q -b "$ISOLATED_BRANCH" "$(base_ref)"
}
leave_branch() {
  [[ -n ${ISOLATED_BRANCH:-} ]] || return 0
  git -C "$TEST_REPO" add -A
  git -C "$TEST_REPO" commit -q -m "Evidence" >/dev/null || true
  git -C "$TEST_REPO" checkout -q -f "$ISOLATED_FROM"
  ISOLATED_BRANCH=
}

# commit_all <message>: commit everything in the test repo (on an isolated branch)
commit_all() {
  git -C "$TEST_REPO" add -A
  git -C "$TEST_REPO" commit -q -m "$1" >/dev/null
}

# project_stage <log>: run project stage; true when it completed
project_stage() {
  echo "project stage" | sqlcl_script "$1" || return 1
  grep -q 'Stage processing completed' "$1"
}

# first_error <log>: first ERROR / Error / ORA- line of a log with the two lines after it
# (SQLcl puts the reason there, after "An error has occurred processing your request:"), for comments
first_error() {
  sed 's/\x1b\[[0-9;]*m//g' "$1" | tr -d '\r' \
    | awk '/ERROR|Error|ORA-/ && !n { n = 3 } n && NF { printf "%s%s", (s++ ? " " : ""), $0; n-- } END { print "" }' \
    | sed 's/An error has occurred processing your request: *//' | cut -c1-300
}

# baseline_apexlang_dir: repo-relative folder holding application.apx at BASELINE_TAG
baseline_apexlang_dir() {
  local app
  app=$(baseline_app_files | grep '/application\.apx$' | head -1)
  [[ -n $app ]] && dirname "$app"
}

# apex_page_count <page-id>: 1 when the page exists in the installed application, else 0
apex_page_count() {
  sql_value "select count(*) from apex_application_pages where application_id = $APEX_APP_ID and page_id = $1"
}

# baseline_apexlang_copy <dir>: extract the baseline APEXlang source of the app into dir
baseline_apexlang_copy() {
  local src
  src=$(baseline_apexlang_dir) || return 1
  rm -rf "$1"
  mkdir -p "$1"
  git -C "$TEST_REPO" archive --format=tar "$BASELINE_TAG:$src" | tar -x -C "$1"
}

# remove_page_in_apex <page-id> <workdir>: delete a page from the installed application
# (apex import of the baseline source without it). Gives export/stage a real app change.
remove_page_in_apex() {
  local page=$1 work=$2
  baseline_apexlang_copy "$work/app" || error "no application.apx in the baseline export"
  rm -f "$work/app/pages/"$(printf 'p%05d-*.apx' "$page")
  apex_import "$work/app" "$work/import.log" \
    || error "apex validate/import of the app without page $page failed, see $work/import.log"
  [[ $(apex_page_count "$page") == 0 ]] || error "page $page still installed after apex import"
}

# restore_apex_app <workdir>: re-import the baseline application (for EXIT traps)
restore_apex_app() {
  local work=$1
  baseline_apexlang_copy "$work/baseline-app" \
    && apex_import "$work/baseline-app" "$work/restore.log" \
    || warn "re-import of the baseline app failed, see $work/restore.log"
}

# write_results_md <out-dir>: results.md of one version from its results.json
write_results_md() {
  jq -r '
    def esc: gsub("\\|"; "\\|") | gsub("<"; "&lt;");
    "# SQLcl \(.version) regression results", "",
    "- \(.sqlcl)", "- Last run: \(.date)", "- Baseline: `\(.baseline)`, test branch `\(.testBranch)`",
    "- Mode: APEX export mode the test ran in (`readable`: apex.apexlang not set, `apexlang`: apex.apexlang=true, `–`: does not depend on it)",
    "- Workaround: result of the workaround check, for tests that make one; it never changes the outcome", "",
    "| ID | Mode | Severity | Area | Issue | Expected | Result | Outcome | Workaround | Comment | Run |",
    "|---|---|---|---|---|---|---|---|---|---|---|",
    (.results[]
     | ((.title | esc) as $t | (.url // .forumUrl // "") as $u
        | if $u != "" then "[\($t)](\($u))" else $t end) as $issue
     | (if .kind == "bug" then "" else " (\(.kind))" end) as $kind
     | "| \(.id) | \(if (.mode // "") == "" then "–" else .mode end) | \(.severity) | \(.area) | \($issue)\($kind) | \(.expected) | \(.result) | **\(.outcome)** | \((.workaround // "") | if . == "" then "–" else esc end) | \(.comment | esc) | \(.date // "") |")
  ' "$1/results.json" >"$1/results.md"
}
