#!/usr/bin/env bash
# Decides and writes the SQLcl Project migration for one assertion source file.
# Run from the project root with bash (Git Bash on Windows):
#
#   bash <skill>/scripts/stage-assertion.sh <source-path> [--worktree]
#       Prints the decision only, one line:
#         ALTER <ENABLE|DISABLE> <VALIDATE|NOVALIDATE> | DROP | CREATE | DROP_CREATE | NONE | STOP <reason>
#       Exit code: 0 for a decision (including NONE), 3 for STOP, 1 for an error.
#
#   bash <skill>/scripts/stage-assertion.sh <source-path> [--worktree] --custom <custom-file>
#       Writes the decided DDL into a fresh placeholder created by `project stage add-custom`, and prints
#       FILLED <custom-file> <decision>. Refuses NONE, STOP, and files that are not untouched placeholders.
#
# <source-path> is src/ext/<schema>/assertions/<name>.sql; it may be absent in the current source (a deleted assertion).
# The baseline is the merge base of git.defaultBranch (.dbtools/project.config.json) and HEAD. The current source is HEAD
# (default) or, with --worktree, the working-tree file. The database is never touched.
set -u
. "$(dirname "$0")/lib.sh"
preflight

src='' worktree=0 custom=''
while [ $# -gt 0 ]; do
  case $1 in
    --worktree) worktree=1 ;;
    --custom) shift; custom=${1:-} ; [ -n "$custom" ] || die "--custom needs a file path" ;;
    -*) die "unknown option $1" ;;
    *) [ -z "$src" ] || die "only one source path is allowed"; src=$1 ;;
  esac
  shift
done
[ -n "$src" ] || die "usage: stage-assertion.sh <source-path> [--worktree] [--custom <custom-file>]"
src=$(to_rel "$src")
case $src in src/ext/*/assertions/*.sql) ;; *) die "not an assertion source path: $src" ;; esac
case $src in */tmp/*) die "assertions/tmp/ files are never staged: $src" ;; esac

stop() {
  echo "STOP $*"
  exit 3
}

default_branch=$(tr -d '\r' < .dbtools/project.config.json | sed -n 's/.*"defaultBranch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
[ -n "$default_branch" ] || die "git.defaultBranch is not set in .dbtools/project.config.json"
git rev-parse --verify --quiet "refs/heads/$default_branch" >/dev/null || die "default branch '$default_branch' does not exist locally"
base=$(git merge-base "$default_branch" HEAD) || die "no merge base between $default_branch and HEAD"

base_exists=0
git cat-file -e "$base:$src" 2>/dev/null && base_exists=1
cur_exists=0
if [ $worktree -eq 1 ]; then
  [ -f "$src" ] && cur_exists=1
else
  [ -z "$(git status --porcelain -- "$src")" ] || stop "uncommitted changes in $src; commit them or rerun with --worktree"
  git cat-file -e "HEAD:$src" 2>/dev/null && cur_exists=1
fi

base_content() { git show "$base:$src"; }
cur_content() { if [ $worktree -eq 1 ]; then cat "$src"; else git show "HEAD:$src"; fi; }

# Checks a current source: trailer present, hash not stale, four state lines.
check_current() {
  cur_trailer=$(cur_content | trailer_line)
  [ -n "$cur_trailer" ] || stop "no sqlcl_snapshot trailer in $src; re-export the assertion"
  [ "$(cur_content | block_hash)" = "$(trailer_field "$cur_trailer" hash)" ] ||
    stop "stale hash in $src (edited after export); re-export the assertion"
  cur_state=$(cur_content | state_lines)
  [ "$(printf '%s\n' "$cur_state" | grep -c .)" -eq 4 ] || stop "expected four state clauses in $src; re-export the assertion"
}

if [ $base_exists -eq 0 ] && [ $cur_exists -eq 0 ]; then
  die "$src exists neither in the baseline nor in the current source"
elif [ $base_exists -eq 1 ] && [ $cur_exists -eq 0 ]; then
  base_trailer=$(base_content | trailer_line)
  [ -n "$base_trailer" ] || stop "no sqlcl_snapshot trailer in the baseline of $src; cannot derive the name to drop"
  decision=DROP
  qname="\"$(trailer_field "$base_trailer" schemaName)\".\"$(trailer_field "$base_trailer" name)\""
elif [ $base_exists -eq 0 ]; then
  check_current
  decision=CREATE
else
  if [ "$(base_content | git hash-object --stdin)" = "$(cur_content | git hash-object --stdin)" ]; then
    decision=NONE
  else
    check_current
    base_trailer=$(base_content | trailer_line)
    [ -n "$base_trailer" ] || stop "no sqlcl_snapshot trailer in the baseline of $src; re-export it on the default branch"
    base_state=$(base_content | state_lines)
    creation() { printf '%s\n' "$1" | grep -E '^(NOT )?DEFERRABLE$|^INITIALLY '; }
    mutable() { printf '%s\n' "$1" | grep -E '^(ENABLE|DISABLE|VALIDATE|NOVALIDATE)$'; }
    if [ "$(trailer_field "$base_trailer" hash)" != "$(trailer_field "$cur_trailer" hash)" ] ||
      [ "$(trailer_field "$base_trailer" name)" != "$(trailer_field "$cur_trailer" name)" ] ||
      [ "$(trailer_field "$base_trailer" schemaName)" != "$(trailer_field "$cur_trailer" schemaName)" ] ||
      [ "$(creation "$base_state")" != "$(creation "$cur_state")" ]; then
      decision=DROP_CREATE
    elif [ "$(mutable "$base_state")" != "$(mutable "$cur_state")" ]; then
      en=$(printf '%s\n' "$cur_state" | grep -E '^(ENABLE|DISABLE)$')
      va=$(printf '%s\n' "$cur_state" | grep -E '^(VALIDATE|NOVALIDATE)$')
      [ "$en $va" != "DISABLE VALIDATE" ] || stop "DISABLE VALIDATE is rejected by Oracle (ORA-08701); re-export after fixing the assertion state"
      decision="ALTER $en $va"
    else
      decision=NONE
    fi
  fi
fi

if [ -n "${cur_trailer:-}" ]; then
  qname="\"$(trailer_field "$cur_trailer" schemaName)\".\"$(trailer_field "$cur_trailer" name)\""
fi

if [ -z "$custom" ]; then
  echo "$decision"
  exit 0
fi

# Fill mode.
case $decision in NONE) die "nothing to stage for $src; do not create a custom file" ;; esac
custom=$(to_rel "$custom")
case $custom in dist/releases/next/changes/*/_custom/*.sql) ;; *) die "not a SQLcl Project custom file path: $custom" ;; esac
[ -f "$custom" ] || die "custom file not found: $custom (run project stage add-custom first)"
l1=$(sed -n '1p' "$custom" | tr -d '\r')
header=$(sed -n '2p' "$custom" | tr -d '\r')
snapshot=$(sed -n '3p' "$custom" | tr -d '\r')
rest=$(sed -n '4,$p' "$custom" | tr -d '[:space:]')
[ "$l1" = "-- liquibase formatted sql" ] && [ "${header#-- changeset }" != "$header" ] &&
  [ "${snapshot#-- sqlcl_snapshot }" != "$snapshot" ] && [ -z "$rest" ] ||
  die "$custom is not an untouched add-custom placeholder; refusing to fill it"

create_ddl() { cur_content | tr -d '\r' | awk '{l[NR]=$(0)} /^\/$/{end=NR; exit} END{for(i=1;i<=end;i++) print l[i]}'; }
numbered() { printf '%s\n' "$header" | sed "s/^\(-- changeset[[:space:]]*[^[:space:]]*:[^[:space:]]*\)/\1.$1/"; }

tmp="$custom.tmp"
{
  echo '-- liquibase formatted sql'
  case $decision in
    DROP_CREATE)
      echo "$snapshot"
      echo
      numbered 1
      echo "DROP ASSERTION IF EXISTS $qname"
      echo '/'
      echo
      numbered 2
      create_ddl
      ;;
    *)
      echo "$header"
      echo "$snapshot"
      echo
      case $decision in
        DROP) echo "DROP ASSERTION IF EXISTS $qname"; echo '/' ;;
        CREATE) create_ddl ;;
        ALTER*) echo "ALTER ASSERTION IF EXISTS $qname ${decision#ALTER }"; echo '/' ;;
      esac
      ;;
  esac
} > "$tmp" || die "could not write $tmp"
grep -q "^$TRAILER_PREFIX{" "$tmp" && { rm -f "$tmp"; die "assertion trailer leaked into $custom"; }
mv "$tmp" "$custom" || die "could not write $custom"
echo "FILLED $custom $decision"
