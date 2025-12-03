#!/bin/bash

set -e
trap 'c=$?; [ $c -ne 0 ] && echo "FAILED with code $c"' EXIT

# Resolve the directory where this script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Move to repo root (script is inside repo_root/confluence/)
repo_root="$(cd "$(git rev-parse --show-toplevel)" && pwd)"
cd "$repo_root"
echo "Changed working directory to repo root: $repo_root"

function show_diffs() {
  echo "----------------------------------------"  
  echo "Found differences: $(git diff --cached --name-only|wc -l)"
  echo "----------------------------------------"  
  
}

function normalize() {   sed '/^-- sqlcl_snapshot/d' "$1" |        # remove snapshot line
  sed 's/[[:space:]]\+$//g'         |        # strip trailing whitespace
  sed '/^$/d'                        |        # drop empty lines
  sed 's/\([^,]\)$/\1,\n/'            |        # add comma if missing
  #tr -d '[:space:]'                 |        # remove remaining spaces/tabs
  sort                              |        # canonicalize order
  uniq                               # dedupe if SQLcl duplicated entries
}

git add -- 'src/database'

echo "Starting drift cleanup script in repo: $repo_root"
show_diffs


echo "Revert ORDS, USERS, and APEX SQL Files"

git restore --staged --worktree -- src/database/*/ords/ords.sql
git restore --staged --worktree -- src/database/*/users/*.sql
git restore --staged --worktree -- src/database/*/apex_apps/f*/f*.sql
show_diffs

echo "Revert white-space-only changes"
for f in $(git diff --cached --name-only --diff-filter=M -- 'src/database') ; do
  if ! git diff --cached -w -- "$f" | grep -q '^diff'; then
    echo "Restoring (white-space only) $f"
    git restore --staged --worktree -- "$f"
  fi
done
show_diffs


echo "Revert Whitespace and Empty Lines"
for f in $(git diff --cached --name-only --diff-filter=M -- 'src/database'); do
  # --cached  = compare index vs HEAD
  # -w        = ignore all whitespace in line comparison
  # -I'^[[:space:]]*$' = ignore hunks where all changed lines are whitespace-only (incl. empty)
  # --quiet   = no output, just exit code (0 = no non-whitespace diff)
  if git diff --cached -w -I'^[[:space:]]*$' --quiet -- "$f"; then
    echo "Restoring $f"
    git restore --staged --worktree -- "$f"
  fi
done
show_diffs

echo Revert files  only differernt in snapshot 

for f in $(git diff --cached --name-only --diff-filter=M -- 'src/database'); do
  # Ignore hunks where ALL changed lines match ^-- sqlcl_snapshot
  if git diff --cached -I'^-- sqlcl_snapshot' --quiet -- "$f"; then
    echo "Restoring ( only differernt in snapshot): $f"
    git restore --staged --worktree -- "$f"
  fi
done
show_diffs


echo Revert files that only different in snapshot, empty lines, and order of columns

for f in $(git diff --cached --name-only --diff-filter=M -- 'src/database'); do
  # write staged version to temp
  git show :$f > /tmp/staged.txt 2>/dev/null || continue
  # write HEAD version to temp
  git show HEAD:$f > /tmp/head.txt 2>/dev/null || continue

  if diff -q <(normalize /tmp/head.txt) <(normalize /tmp/staged.txt) >/dev/null; then
    echo "RESTORE (only ordering/snapshot changed): $f"
    git restore --staged --worktree -- "$f"
  fi
done
show_diffs

echo "APEX Yaml Files differences in version-number only"

for f in $(git diff --cached --name-only --diff-filter=M -- 'src/database/*/apex_apps/*/readable/*'); do
  if git diff --cached -I'version-number:\s*[0-9]+' --quiet -- "$f"; then
    echo "Restoring version-number-only change: $f"
    git restore --staged --worktree -- "$f"
  fi
done

echo "APEX Yaml Files differences in is only"
for f in $(git diff --cached --name-only --diff-filter=M -- 'src/database/*/apex_apps/*/readable/*'); do
  if git diff --cached -I'id:\s*[0-9]+' --quiet -- "$f"; then
    echo "Restoring version-number-only change: $f"
    git restore --staged --worktree -- "$f"
  fi
done
