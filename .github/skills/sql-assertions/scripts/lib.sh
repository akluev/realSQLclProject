#!/usr/bin/env bash
# Shared helpers for the sql-assertions scripts. Source this file; do not run it.
# Requires only bash, git, awk, sed, grep, and tr (Git Bash on Windows, or macOS/Linux).

TRAILER_PREFIX='-- sqlcl_snapshot '

die() {
  echo "ERROR: $*" >&2
  exit 1
}

# Converts a path (Windows or POSIX, absolute or repository-relative) to a repository-relative path.
to_rel() {
  local p=$1
  p=${p//\\//}
  if command -v cygpath >/dev/null 2>&1; then
    case $p in [A-Za-z]:/*) p=$(cygpath -u "$p") ;; esac
  fi
  case $p in
    "$ROOT"/*) p=${p#"$ROOT"/} ;;
    /*) die "path is outside the repository: $1" ;;
  esac
  printf '%s' "$p"
}

# Verifies git is usable and that the current directory is the root of a SQLcl Project repository, then sets ROOT.
preflight() {
  command -v git >/dev/null 2>&1 ||
    die "git is not on PATH for this shell ($(command -v bash 2>/dev/null || echo 'bash')). Run the script with the bash that ships with Git (Git Bash on Windows) or fix PATH."
  ROOT=$(git rev-parse --show-toplevel 2>/dev/null) ||
    die "not inside a git repository (current directory: $(pwd)). Run the script from the project root."
  if command -v cygpath >/dev/null 2>&1; then ROOT=$(cygpath -u "$ROOT"); fi
  local here
  here=$(pwd)
  if command -v cygpath >/dev/null 2>&1; then here=$(cygpath -u "$here"); fi
  [ "$here" = "$ROOT" ] || die "run the script from the project root ($ROOT), not $here."
  [ -f .dbtools/project.config.json ] || die "missing .dbtools/project.config.json; this is not a SQLcl Project root."
}

# Rejects assertion names that cannot map to a single safe filename.
check_name() {
  case $1 in
    '' | *[/\\:*?\"\<\>\|]*) die "assertion or schema name '$1' contains filesystem-unsafe characters; choose a reversible filename policy." ;;
  esac
}

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# Immutable block: line 1 through the last line containing ')', trailer excluded. Reads stdin.
immutable_block() {
  tr -d '\r' | grep -v "^$TRAILER_PREFIX" | awk '{l[NR]=$(0)} /\)/{last=NR} END{for(i=1;i<=last;i++) print l[i]}'
}

# State clauses: non-empty, non-'/' lines after the last ')' line, leading whitespace trimmed. Reads stdin.
state_lines() {
  tr -d '\r' | grep -v "^$TRAILER_PREFIX" |
    awk '{l[NR]=$(0)} /\)/{last=NR} END{for(i=last+1;i<=NR;i++) if (l[i]!="" && l[i]!="/") print l[i]}' |
    sed 's/^[[:space:]]*//'
}

# Snapshot hash of the immutable block. Reads stdin.
block_hash() { immutable_block | git hash-object --stdin; }

# Prints the last line if it is a snapshot trailer. Reads stdin.
trailer_line() { tr -d '\r' | tail -n 1 | grep "^$TRAILER_PREFIX" || true; }

# Extracts one string field from a trailer line: trailer_field <line> <key>.
trailer_field() { printf '%s' "$1" | sed -n "s/.*\"$2\":\"\([^\"]*\)\".*/\1/p"; }
