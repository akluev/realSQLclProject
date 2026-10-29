#!/usr/bin/env bash
# 018: deploying the staged ORDS changeset as the deployer must define ORDS in the project
# schema. The changeset (author <SCHEMA>) calls the ORDS package, which acts on the session's
# current schema, so the module lands in the deployer (or wherever earlier changesets left it).
source "$(dirname "$0")/../../lib/common.sh"

schema=$(tr '[:lower:]' '[:upper:]' <<<"$APEX_SCHEMA")
changelog="releases/ords/ords.changelog.xml"
ords_file="dist/releases/ords/$APEX_SCHEMA/ords.sql"
work="$RUN_DIR/018"
mkdir -p "$work"
[[ -f $TEST_REPO/$ords_file ]] || error "baseline has no staged $ords_file"

deployer=$(sql_value "select user from dual")
drop_rest() {
  printf "begin\n  for s in (select parsing_schema from ords_metadata.ords_schemas where parsing_schema in ('%s', '%s')) loop\n    ords_admin.drop_rest_for_schema(p_schema => s.parsing_schema);\n  end loop;\n  commit;\nend;\n/\n" \
    "$schema" "$deployer"
}
# Put the baseline state back: ORDS only in the schema, installed as the schema
cleanup() {
  { drop_rest; } | sqlcl_script "$work/cleanup-drop.log" || warn "could not drop ORDS, see $work/cleanup-drop.log"
  echo "@$ords_file" | as_schema sqlcl_script "$work/cleanup-replay.log" \
    || warn "could not reinstall ORDS as $schema, see $work/cleanup-replay.log"
}
trap cleanup EXIT

# Remove the ORDS definitions and their changelog row, then deploy only the ORDS changelog
{
  drop_rest
  echo "delete from databasechangelog where filename like '%ords/$APEX_SCHEMA/ords.sql';"
  echo "commit;"
  echo "cd dist"
  echo "lb update -changelog-file $changelog -search-path \".\""
} | sqlcl_script "$work/deploy.log" || error "lb update of $changelog failed, see $work/deploy.log"

owner=$(sql_value "select listagg(s.parsing_schema, ',') from ords_metadata.ords_schemas s join ords_metadata.ords_modules m on m.schema_id = s.id where s.parsing_schema in ('$schema', '$deployer')")
case ",$owner," in
  *",$schema,"*) pass "ORDS module installed in $schema" ;;
  ",,")          error "no ORDS module after lb update, see $work/deploy.log" ;;
  *)             fail "ORDS module installed in $owner instead of $schema (deployed as $deployer)" ;;
esac
