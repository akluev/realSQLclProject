#!/usr/bin/env bash
# Runs the APEX import timing test via SQLcl, capturing everything (including
# `!` shell-out output that `spool` misses) by piping the whole process's
# stdout/stderr through `tee`, so it's visible live and saved to a log file
# in the same terminal. Run from the project root.
#
# Usage:
#   scripts/run_apex_timing_test.sh <connection_name>
#   scripts/run_apex_timing_test.sh demo_vm26

set -euo pipefail

conn_name="${1:?Usage: $0 <connection_name>}"
workspace="${2:-}"
log_dir="var/apex_timing_test"
log_file="$log_dir/apex_import_timing_results.log"

mkdir -p "$log_dir"

# Clean up any untracked files in the APEX application directories to ensure a fresh start
git clean -fd -- src/database/demo1/apex_apps/ src/database/apex_apps/

sql -nolog 2>&1 <<EOF | tee "$log_file"
conn -n $conn_name
exec apex_application_install.set_workspace('$workspace');
alias load scripts/xml/stel-timing-aliases.xml
@scripts/sql/apex_timing_test.sql
exit
EOF
