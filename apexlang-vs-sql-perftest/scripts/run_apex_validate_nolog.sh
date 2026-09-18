#!/usr/bin/env bash
# Runs disconnected APEXlang validation timing via SQLcl, capturing everything (including
# `!` shell-out output that `spool` misses) by piping the whole process's
# stdout/stderr through `tee`, so it's visible live and saved to a log file
# in the same terminal. Run from the project root.
#
# Usage from the project root:
#   scripts/run_apex_validate_nolog.sh <extra_pages_1> <extra_pages_2> <extra_pages_3>
#   scripts/run_apex_validate_nolog.sh 0 300 600

set -euo pipefail

log_dir="var/apex_validate_nolog_test"
log_file="$log_dir/apex_validate_nolog-$1-$2-$3.log"

mkdir -p "$log_dir"

# Clean up any untracked files in the APEX application directories to ensure a fresh start
git clean -fd -- src/database/demo1/apex_apps/ 

sql -nolog 2>&1 <<EOF | tee "$log_file"
@scripts/sql/apex_validate_nolog.sql $1 $2 $3
exit
EOF
