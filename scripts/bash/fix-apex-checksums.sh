#!/usr/bin/env bash
# =============================================================================
# fix-apex-checksums.sh
#
# Workaround for SQLcl 26.3 bug: after `project stage`, the APEX changeset
# dist/releases/apex/fNNN/fNNN.xml keeps a stale "-- sqlcl_checksum <hash>"
# line, although fNNN.sql was regenerated with a new
# "-- sqlcl_snapshot {"hash":"<hash>",...}" trailer.
#
# For every application folder under APEX_RELEASE_DIR this script copies the
# hash from the sqlcl_snapshot line of fNNN.sql into the sqlcl_checksum line
# of fNNN.xml.
#
# Usage:
#   scripts/bash/fix-apex-checksums.sh            # fix files in place
#   scripts/bash/fix-apex-checksums.sh --dry-run  # only report differences
#
# Exit codes: 0 = success, 1 = one or more applications could not be processed
# =============================================================================
set -euo pipefail

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
APEX_RELEASE_DIR="$REPO_ROOT/dist/releases/apex"
APP_DIR_GLOB="f*"                         # application folders: f100, f1968, ...
CHECKSUM_PREFIX="-- sqlcl_checksum  "     # note: SQLcl writes two spaces
SNAPSHOT_MARKER="-- sqlcl_snapshot "

# -----------------------------------------------------------------------------
DRY_RUN=false
case "${1:-}" in
  --dry-run|-n) DRY_RUN=true ;;
  "") ;;
  *) echo "Usage: $0 [--dry-run]" >&2; exit 2 ;;
esac

[[ -d "$APEX_RELEASE_DIR" ]] || { echo "ERROR: $APEX_RELEASE_DIR not found" >&2; exit 1; }

fixed=0; ok=0; failed=0

for app_dir in "$APEX_RELEASE_DIR"/$APP_DIR_GLOB/; do
  [[ -d "$app_dir" ]] || continue
  app="$(basename "$app_dir")"
  sql_file="$app_dir$app.sql"
  xml_file="$app_dir$app.xml"

  if [[ ! -f "$sql_file" || ! -f "$xml_file" ]]; then
    echo "SKIP   $app: missing $app.sql or $app.xml"
    continue
  fi

  # Hash from the last sqlcl_snapshot line of the SQL file (it is the trailer).
  snapshot_line="$(tail -n 5 "$sql_file" | grep -F -- "$SNAPSHOT_MARKER" | tail -n 1 || true)"
  new_hash="$(sed -n 's/.*"hash":"\([0-9a-fA-F]\{1,\}\)".*/\1/p' <<<"$snapshot_line")"
  if [[ -z "$new_hash" ]]; then
    echo "ERROR  $app: no sqlcl_snapshot hash at end of $app.sql"
    failed=$((failed + 1)); continue
  fi

  # Current checksum in the changeset XML (must be exactly one line).
  checksum_count="$(grep -c -- "^$CHECKSUM_PREFIX" "$xml_file" || true)"
  if [[ "$checksum_count" -ne 1 ]]; then
    echo "ERROR  $app: expected 1 sqlcl_checksum line in $app.xml, found $checksum_count"
    failed=$((failed + 1)); continue
  fi
  old_hash="$(grep -- "^$CHECKSUM_PREFIX" "$xml_file" | sed "s/^$CHECKSUM_PREFIX//" | tr -d '[:space:]')"

  if [[ "$old_hash" == "$new_hash" ]]; then
    echo "OK     $app: $new_hash"
    ok=$((ok + 1)); continue
  fi

  if $DRY_RUN; then
    echo "DIFF   $app: $old_hash -> $new_hash (dry run)"
  else
    # Replace hash only; keep any trailing CR so line endings are preserved.
    # Portable in-place edit (GNU sed on Git Bash/Linux, BSD sed on macOS).
    sed "s/^\($CHECKSUM_PREFIX\)[0-9a-fA-F]*/\1$new_hash/" "$xml_file" > "$xml_file.tmp" \
      && mv "$xml_file.tmp" "$xml_file"
    echo "FIXED  $app: $old_hash -> $new_hash"
  fi
  fixed=$((fixed + 1))
done

echo "-----------------------------------------------------------------"
echo "ok=$ok  $($DRY_RUN && echo 'to_fix' || echo 'fixed')=$fixed  errors=$failed"
[[ "$failed" -eq 0 ]]
