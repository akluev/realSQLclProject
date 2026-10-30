#!/usr/bin/env bash
# 017: after an install, every APEX changeset (id INSTALL_<app_id>) recorded in DATABASECHANGELOG
# must have its DATABASECHANGELOG_ACTIONS row with the same id, author and filename, and
# lb status must not list it as still to deploy. On Windows SQLcl 25.4.1 records the filename
# with "/" in one table and "\" in the other, so the changeset is never seen as run and is
# deployed again every time.
# Nothing is deployed here: the reset at the start of the run installed the baseline from
# dist with the SQLcl under test, and this test only reads what that install recorded.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/017"
mkdir -p "$work"

# 1. The two tables, one line per APEX changeset: id | changelog filename | actions filenames
cat <<'SQL' | sqlcl_script "$work/tables.log" || error "could not read the changelog tables, see $work/tables.log"
set heading off feedback off pagesize 0 linesize 400 trimspool on
select 'ROW|' || c.id || '|' || c.author || '|' || c.filename || '|'
       || (select listagg(distinct a.filename || ' (' || a.status || ')', ', ')
                  within group (order by a.filename || ' (' || a.status || ')')
             from databasechangelog_actions a where a.id = c.id) || '|'
       || (select count(*) from databasechangelog_actions a
            where a.id = c.id and a.author = c.author and a.filename = c.filename)
  from databasechangelog c
 where c.id like 'INSTALL%'
 order by c.id;
SQL
rows=$(grep '^ROW|' "$work/tables.log" | tr -d '\r')
[[ -n $rows ]] || error "no INSTALL% changeset in DATABASECHANGELOG: the baseline install deployed no APEX application, see $work/tables.log"

mismatches=()
while IFS='|' read -r _ id author file actions matching; do
  [[ $matching -gt 0 ]] || mismatches+=("$id: DATABASECHANGELOG $file, DATABASECHANGELOG_ACTIONS ${actions:-none}")
done <<<"$rows"

# 2. lb status right after the install must not list the APEX changeset as still to deploy.
# It must use the install's own parameters (-def properties): with other values, every changeset
# with ${...} substitutions gets another checksum. So the lb update line of dist/install.sql is
# reused with update -> status (and without -log, an update option).
update=$(tr -d '\r' <"$TEST_REPO/dist/install.sql" | grep -m1 -E '^[[:space:]]*lb update ')
[[ -n $update ]] || error "no lb update line in dist/install.sql"
status=$(sed -E 's/^[[:space:]]*lb update /lb status /; s/ -log( |$)/ /' <<<"$update")
printf 'cd dist\n%s\n' "$status" | sqlcl_script "$work/lb-status.log" \
  || error "$status failed: $(first_error "$work/lb-status.log")"
pending=$(sed 's/\x1b\[[0-9;]*m//g' "$work/lb-status.log" | tr -d '\r' \
  | grep -oE "INSTALL_$APEX_APP_ID|f$APEX_APP_ID\.xml" | sort -u | paste -sd, - | sed 's/,/, /g')

checked=$(wc -l <<<"$rows" | tr -d ' ')
problems=()
((${#mismatches[@]})) && problems+=("filename differs: $(printf '%s; ' "${mismatches[@]}" | sed 's/; $//')")
[[ -n $pending ]] && problems+=("lb status lists as not deployed: $pending")
((${#problems[@]})) && fail "$(printf '%s / ' "${problems[@]}" | sed 's| / $||')"
pass "$checked APEX changeset(s) recorded with the same filename in both tables; lb status lists none as pending"
