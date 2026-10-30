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

# 2. lb status right after the install must list no APEX changeset as still to deploy
printf 'cd dist\nlb status -changelog-file releases/main.changelog.xml -search-path "." -def env/test.properties\n' \
  | sqlcl_script "$work/lb-status.log" || error "lb status failed: $(first_error "$work/lb-status.log")"
pending=$(sed 's/\x1b\[[0-9;]*m//g' "$work/lb-status.log" | tr -d '\r' | grep -oE 'INSTALL_[0-9]+' | sort -u | paste -sd, - | sed 's/,/, /g')

checked=$(wc -l <<<"$rows" | tr -d ' ')
problems=()
((${#mismatches[@]})) && problems+=("filename differs: $(printf '%s; ' "${mismatches[@]}" | sed 's/; $//')")
[[ -n $pending ]] && problems+=("lb status lists as not deployed: $pending")
((${#problems[@]})) && fail "$(printf '%s / ' "${problems[@]}" | sed 's| / $||')"
pass "$checked APEX changeset(s) recorded with the same filename in both tables; lb status lists none as pending"
