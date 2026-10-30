#!/usr/bin/env bash
# 023: an application moved to APEXlang deployment (as in 022) must deploy through its APEXlang
# controller, however many workspaces the schema belongs to, and a failed APEX changeset must
# not be recorded as run. SQLcl's generated install does not pass the workspace, so with more
# than one workspace it stops with "Multiple workspaces available, use the workspaceId or the
# workspace option", and Liquibase still records the changeset in DATABASECHANGELOG.
# Deploys into the database: run.sh resets after this test ("resetAfter": true).
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/023"
mkdir -p "$work"
isolate_branch 023
trap leave_branch EXIT

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
workspaces=$(sql_value "select count(*) from apex_workspace_schemas where schema = '$schema'")
[[ $workspaces -ge 2 ]] \
  || error "the baseline maps $schema to $workspaces workspace(s); this test needs 2 or more"

apexlang_migration "$work"

# Only the APEXlang controller is deployed: legacy entries stage added back (022) are commented out
changelog="$TEST_REPO/dist/releases/apex/apex.changelog.xml"
sed -E "s#^([[:space:]]*)(<include file=\"f$APEX_APP_ID/[^>]*>)#\1<!-- \2 -->#" "$changelog" >"$changelog.tmp" \
  && mv "$changelog.tmp" "$changelog"
controller=$(apex_includes)
[[ -n $controller ]] || error "no APEXlang controller in apex.changelog.xml after stage, see $work/stage.log"
commit_all "Deploy only the APEXlang controller: $controller" || true

# Deploy as an installer does: dist/install.sql
printf 'cd dist\n@install.sql\ncd ..\n' | sqlcl_script "$work/deploy.log" || true
log=$(sed 's/\x1b\[[0-9;]*m//g' "$work/deploy.log" | tr -d '\r')
problem=$(grep -m1 -E 'Multiple workspaces available|ERROR|Error|ORA-|Failed to' <<<"$log" | cut -c1-200)

# What Liquibase recorded for the APEXlang changeset
recorded=$(sql_value "select count(*) from databasechangelog where id like 'INSTALL%' and filename not like '%f$APEX_APP_ID%'")

[[ -z $problem && $recorded -ge 1 ]] && pass "deployed through $controller ($workspaces workspaces for $schema)"
[[ -n $problem ]] || fail "deploy reported no error, but no APEXlang INSTALL changeset is recorded in DATABASECHANGELOG"
if [[ $recorded -ge 1 ]]; then
  fail "deploy of $controller failed ($workspaces workspaces for $schema): $problem; yet DATABASECHANGELOG records the changeset as run"
fi
fail "deploy of $controller failed ($workspaces workspaces for $schema): $problem"
