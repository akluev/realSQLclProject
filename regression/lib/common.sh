#!/usr/bin/env bash
# Shared helpers for run.sh and the issue tests (issues/<id>/test.sh).
# Issue tests end with pass/fail/error (exit 0/1/2); the message is the result comment,
# written to COMMENT_FILE (set by run.sh) so cleanup output after it does not replace it.

REG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() { echo "ERROR: $*" >&2; exit 2; }

comment() { echo "$*"; [[ -z ${COMMENT_FILE:-} ]] || echo "$*" >"$COMMENT_FILE"; }
pass()  { comment "$*"; exit 0; }
fail()  { comment "$*"; exit 1; }
error() { comment "$*"; exit 2; }
# warn: add a note to the comment, e.g. from cleanup that runs after the verdict
warn()  { echo "WARNING: $*" >&2; [[ -z ${COMMENT_FILE:-} ]] || echo "WARNING: $*" >>"$COMMENT_FILE"; }

load_config() {
  local cfg="${REG_CONFIG:-$REG_ROOT/config.sh}"
  [[ -f $cfg ]] || die "missing $cfg (copy config.example.sh and edit it)"
  # shellcheck source=/dev/null
  source "$cfg"
  local v
  for v in TEST_REPO BASE_BRANCH BASELINE_TAG SQLCL_CONN RESET_CMD APEX_SCHEMA APEX_WORKSPACE APEX_APP_ID; do
    [[ -n ${!v:-} ]] || die "$v is not set in $cfg"
    export "${v?}"
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

# ver_ge <a> <b>: true when version a >= version b
ver_ge() { [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" == "$2" ]]; }

# sqlcl_script <log>: run SQLcl commands from stdin inside TEST_REPO, connected as SQLCL_CONN
sqlcl_script() {
  local log=$1
  { echo "whenever sqlerror exit failure"
    echo "whenever oserror exit failure"
    echo "conn -name $SQLCL_CONN"
    cat
    echo "exit"
  } | (cd "$TEST_REPO" && sql -S -nolog) >"$log" 2>&1
}

apex_app_path() { echo "src/database/$APEX_SCHEMA/apex_apps/f$APEX_APP_ID"; }

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

# restore_from_baseline <path>: make a repo path exactly as it is at BASELINE_TAG
restore_from_baseline() {
  rm -rf "${TEST_REPO:?}/$1"
  if git -C "$TEST_REPO" cat-file -e "$BASELINE_TAG:$1" 2>/dev/null; then
    git -C "$TEST_REPO" checkout -q "$BASELINE_TAG" -- "$1"
  fi
}

# restore_apex_app_dir: app export folder back to BASELINE_TAG; later tests export again
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

# isolate_branch <id>: continue the test on its own branch from BASELINE_TAG, so its
# commits and stage output do not leak into later tests. leave_branch (run it from an
# EXIT trap) commits what is left there as evidence and returns to the previous branch.
isolate_branch() {
  ISOLATED_FROM=$(git -C "$TEST_REPO" branch --show-current)
  ISOLATED_BRANCH="${TEST_BRANCH:-regression/manual}-$1"
  git -C "$TEST_REPO" branch -q -D "$ISOLATED_BRANCH" 2>/dev/null || true
  git -C "$TEST_REPO" checkout -q -b "$ISOLATED_BRANCH" "$BASELINE_TAG"
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

# first_error <log>: first ERROR / Error / ORA- line of a log, for comments
first_error() {
  sed 's/\x1b\[[0-9;]*m//g' "$1" | grep -m1 -E 'ERROR|Error|ORA-' | tr -d '\r' | cut -c1-200
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
