#!/usr/bin/env bash
# 023: with the schema in more than one workspace, an application whose deployment was
# regenerated from scratch (as in 022) must deploy through the controller of the current APEX
# mode, and a second deploy straight after must not run the APEX changeset again.
#   readable  f<id>/f<id>.xml deploys, and is skipped the second time.
#   apexlang  <alias>/<alias>.xml: the generated install does not pass the workspace, so it stops
#             with "Multiple workspaces available, use the workspaceId or the workspace option",
#             and Liquibase still records the changeset as run.
# Deploys into the database: run.sh resets before and after this test.
source "$(dirname "$0")/../../lib/common.sh"

work="$RUN_DIR/023"
mkdir -p "$work"
isolate_branch 023
trap leave_branch EXIT

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
workspaces=$(sql_value "select count(*) from apex_workspace_schemas where schema = '$schema'")
[[ $workspaces -ge 2 ]] \
  || error "the baseline maps $schema to $workspaces workspace(s); this test needs 2 or more"

apex_restage "$work"

# Deploy only the controller of this mode: other entries stage wrote (022) are commented out
controller=$(apex_controller)
changelog="$TEST_REPO/dist/releases/apex/apex.changelog.xml"
grep -q "<include file=\"$controller\"" "$changelog" \
  || error "stage did not include $controller in apex.changelog.xml: $(apex_includes)"
awk -v c="$controller" '/^[[:space:]]*<include / && index($0, "\"" c "\"") == 0 { sub(/<include[^>]*>/, "<!-- & -->") } { print }' \
  "$changelog" >"$changelog.tmp" && mv "$changelog.tmp" "$changelog"
commit_all "Deploy only $controller" || true

# deploy <n>: dist/install.sql as an installer runs it; sets problem (first error) and ran
# (whether the APEX changeset of the controller was run)
deploy() {
  local log="$work/deploy-$1.log" text
  # the project's documented install, no personal aliases: cd dist; @install; cd ..
  printf 'cd dist\n@install\ncd ..\n' | sqlcl_script "$log" || true
  text=$(sed 's/\x1b\[[0-9;]*m//g' "$log" | tr -d '\r')
  problem=$(grep -m1 -E 'Multiple workspaces available|ERROR|Error|ORA-|Failed to' <<<"$text" | cut -c1-200 || true)
  # file name only: on Windows SQLcl prints the path with backslashes (releases\apex\f106\f106.xml)
  grep -qF "${controller##*/}::INSTALL_$APEX_APP_ID::SQLCL-Generated" <<<"$text" && ran=yes || ran=no
}

deploy 1
if [[ -n $problem ]]; then
  recorded=$(sql_value "select count(*) from databasechangelog where id like 'INSTALL%' and filename like '%${controller##*/}'")
  ((recorded >= 1)) \
    && fail "deploy of $controller failed ($workspaces workspaces for $schema): $problem; yet DATABASECHANGELOG records the changeset as run"
  fail "deploy of $controller failed ($workspaces workspaces for $schema): $problem"
fi
[[ $ran == yes ]] || fail "deploy reported no error but did not run the APEX changeset of $controller, see $work/deploy-1.log"

deploy 2
[[ -z $problem ]] || fail "first deploy of $controller succeeded; the second, with nothing changed, failed: $problem"
[[ $ran == no ]] || fail "first deploy of $controller succeeded; the second, with nothing changed, ran the APEX changeset again"
pass "deployed through $controller ($workspaces workspaces for $schema); a second deploy skipped it"
