#!/usr/bin/env bash
# Exports one Oracle SQL assertion from its spooled DEFINITION_SQL to src/ext/<owner>/assertions/<name>.sql.
# Run from the project root with bash (Git Bash on Windows):
#
#   bash <skill>/scripts/export-assertion.sh --prepare <OWNER> [--clean]
#       Creates src/ext/<owner>/assertions/tmp/ for spool-assertion.sql. With --clean, first empties the
#       schema's assertions directory (the "export all assertions for a schema" scope).
#
#   bash <skill>/scripts/export-assertion.sh --finish <OWNER>
#       Run once per schema after the export loop. Removes an empty tmp/ directory and prints DONE, or lists the
#       leftover files of failed exports and exits non-zero.
#
#   bash <skill>/scripts/export-assertion.sh <OWNER> <NAME> <STATUS> <DEFERRABLE> <DEFERRED> <VALIDATED>
#       Arguments are the dictionary values from the metadata query, for example:
#       CLA_APEX CLA_AIRCRAFT_ASSERTION_PROBE ENABLED "NOT DEFERRABLE" IMMEDIATE VALIDATED
#       Reads src/ext/<owner>/assertions/tmp/<name>-raw.sql (spooled by spool-assertion.sql), writes the
#       destination file with the sqlcl_snapshot trailer, and prints: OK <file> <hash> <state>
#
# Deletes the destination file before it starts, so success means exit code 0 and an existing destination file.
# Every failure writes the reason to stderr, keeps the raw file for diagnosis, and exits non-zero.
set -u
. "$(dirname "$0")/lib.sh"
preflight

if [ "${1:-}" = "--prepare" ]; then
  owner=${2:-}
  [ -n "$owner" ] || die "usage: export-assertion.sh --prepare <OWNER> [--clean]"
  check_name "$owner"
  dir="src/ext/$(lower "$owner")/assertions"
  if [ "${3:-}" = "--clean" ]; then
    case $dir in src/ext/*/assertions) ;; *) die "refusing to clean unexpected directory: $dir" ;; esac
    if [ -d "$dir" ]; then find "$dir" -mindepth 1 -delete || die "could not empty $dir"; fi
  fi
  mkdir -p "$dir/tmp" || die "could not create $dir/tmp"
  echo "READY $dir/tmp"
  exit 0
fi

if [ "${1:-}" = "--finish" ]; then
  owner=${2:-}
  [ -n "$owner" ] || die "usage: export-assertion.sh --finish <OWNER>"
  check_name "$owner"
  tmpdir="src/ext/$(lower "$owner")/assertions/tmp"
  if [ -d "$tmpdir" ]; then
    rmdir "$tmpdir" 2>/dev/null || die "failed exports left files in $tmpdir: $(ls -A "$tmpdir" | tr '\n' ' ')"
  fi
  echo "DONE $(dirname "$tmpdir")"
  exit 0
fi

[ $# -eq 6 ] || die "usage: export-assertion.sh <OWNER> <NAME> <STATUS> <DEFERRABLE> <DEFERRED> <VALIDATED> (got $# arguments)"
owner=$1 name=$2 status=$3 deferrable=$4 deferred=$5 validated=$6
check_name "$owner"
check_name "$name"

dir="src/ext/$(lower "$owner")/assertions"
dest="$dir/$(lower "$name").sql"
raw="$dir/tmp/$(lower "$name")-raw.sql"
work="$dir/tmp/$(lower "$name")-final.sql"

rm -f "$dest" || die "could not delete the previous destination file $dest"

case $status in ENABLED) s1=ENABLE ;; DISABLED) s1=DISABLE ;; *) die "unexpected STATUS '$status' (expected ENABLED or DISABLED)" ;; esac
case $deferrable in DEFERRABLE | "NOT DEFERRABLE") s2=$deferrable ;; *) die "unexpected DEFERRABLE '$deferrable'" ;; esac
case $deferred in IMMEDIATE) s3="INITIALLY IMMEDIATE" ;; DEFERRED) s3="INITIALLY DEFERRED" ;; *) die "unexpected DEFERRED '$deferred'" ;; esac
case $validated in VALIDATED) s4=VALIDATE ;; "NOT VALIDATED") s4=NOVALIDATE ;; *) die "unexpected VALIDATED '$validated'" ;; esac
expected_state=$(printf '%s\n' "$s1" "$s2" "$s3" "$s4")

[ -f "$raw" ] || die "spooled file not found: $raw (did spool-assertion.sql run for $owner.$name?)"
first=$(tr -d '\r' < "$raw" | grep -v '^[[:space:]]*$' | head -n 1)
[ -n "$first" ] || die "spooled file is empty: $raw (assertion $owner.$name not found in the selected dictionary view?)"
case $first in
  'CREATE ASSERTION '*) ;;
  *) die "spooled file does not start with CREATE ASSERTION (CSV quoting or SQLcl output leaked?): $raw" ;;
esac

# Normalize: strip CR and trailing whitespace, drop leading/trailing blank lines, add IF NOT EXISTS,
# drop blank lines and ';' after the CHECK close, then terminate with '/' and two blank lines.
tr -d '\r' < "$raw" | sed 's/[[:space:]]*$//' |
  awk '{l[NR]=$(0)} /\)/{last=NR} END{
      s=1; while (s<=NR && l[s]=="") s++
      if (l[s] !~ /^CREATE ASSERTION IF NOT EXISTS /) sub(/^CREATE ASSERTION /, "CREATE ASSERTION IF NOT EXISTS ", l[s])
      for (i=s; i<=last; i++) print l[i]
      for (i=last+1; i<=NR; i++) { sub(/;$/, "", l[i]); if (l[i]!="") print l[i] }
      print "/"; print ""; print ""
    }' > "$work" || die "normalization failed for $raw"

header=$(head -n 1 "$work")
case $header in
  "CREATE ASSERTION IF NOT EXISTS \"$owner\".\"$name\"" | "CREATE ASSERTION IF NOT EXISTS \"$owner\".\"$name\" "*) ;;
  *) die "header does not name \"$owner\".\"$name\": $header" ;;
esac
[ "$(grep -c '^CREATE ASSERTION ' "$work")" -eq 1 ] || die "expected exactly one CREATE ASSERTION statement in $raw"
grep -q ')' "$work" || die "no closing parenthesis found in $raw"
[ "$(grep -c '^/$' "$work")" -eq 1 ] || die "expected exactly one '/' terminator line"
state=$(state_lines < "$work")
[ "$state" = "$expected_state" ] ||
  die "state clauses in DEFINITION_SQL [$(echo "$state" | tr '\n' '|')] do not match the dictionary row [$(echo "$expected_state" | tr '\n' '|')]"
case $(immutable_block < "$work" | tail -n 1) in *')') ;; *) die "the last line containing ')' does not end the CHECK condition" ;; esac

hash=$(block_hash < "$work")
printf '%s' "$TRAILER_PREFIX{\"hash\":\"$hash\",\"type\":\"ASSERTION\",\"name\":\"$name\",\"schemaName\":\"$owner\",\"sxml\":\"\"}" >> "$work"
[ "$(block_hash < "$work")" = "$hash" ] || die "hash verification failed for $work"

mv "$work" "$dest" || die "could not write $dest"
rm -f "$raw"
rmdir "$dir/tmp" 2>/dev/null || true
echo "OK $dest $hash $(echo "$state" | tr '\n' '|' | sed 's/|$//')"
