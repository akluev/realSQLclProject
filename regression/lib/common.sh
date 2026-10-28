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

# export_apex_app: fresh `project export -o APEX.<id>`, done once per run.
# The old folder is removed first: on a case-insensitive file system an
# overwrite keeps the old file-name case and would hide a lowercasing bug.
export_apex_app() {
  local dir="$TEST_REPO/$(apex_app_path)"
  local marker="$RUN_DIR/apex-export.done" log="$RUN_DIR/apex-export.log"
  [[ -f $marker ]] && return 0
  rm -rf "$dir"
  echo "project export -o APEX.$APEX_APP_ID" | sqlcl_script "$log" \
    || error "project export failed, see $log"
  [[ -n $(find "$dir" -type f 2>/dev/null | head -1) ]] \
    || error "project export wrote nothing to $(apex_app_path), see $log"
  touch "$marker"
}

# restore_apex_app_dir: put the app export folder back to BASELINE_TAG and
# forget the cached export, so later tests export again
restore_apex_app_dir() {
  rm -rf "${TEST_REPO:?}/$(apex_app_path)"
  git -C "$TEST_REPO" checkout -q "$BASELINE_TAG" -- "$(apex_app_path)"
  rm -f "$RUN_DIR/apex-export.done"
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
