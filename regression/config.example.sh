# Regression test configuration for this workstation.
# Copy to config.sh (gitignored) and edit. Sourced by bash.

# Test project repository (the unpacked test project) and its pre-test state
TEST_REPO=/c/repo/tests/sqlcl-regression-demo
BASE_BRANCH=main
BASELINE_TAG=baseline

# Saved SQLcl connections (conn -name ...): the installer, used by most tests and the reset,
# and the project schema itself (needed to export ORDS, see tests 011 and 012)
SQLCL_CONN=proj_vm26
SCHEMA_CONN=demo_vm26

# Optional: your own reset command, run inside TEST_REPO instead of regression/reset/reset.sh.
# It must put BASE_BRANCH on BASELINE_TAG and rebuild the database objects.
# RESET_CMD='sql -nolog @scripts/sql/rebuild.sql'

# Project schema, APEX workspace and application in the baseline
APEX_SCHEMA=demo1
APEX_WORKSPACE=DEMO1
APEX_APP_ID=106
# A page the baseline app can lose without breaking validation (test 003)
APEX_SPARE_PAGE=100

# One SQLcl home per version label passed to run.sh (dots become underscores)
SQLCL_HOME_26_1=/c/Install/sqlcl-26.1/sqlcl
SQLCL_HOME_26_2=/c/Install/sqlcl-26.2/sqlcl
SQLCL_HOME_26_3=/c/Install/sqlcl-26.3/sqlcl

