# Regression test configuration for this workstation.
# Copy to config.sh (gitignored) and edit. Sourced by bash.

# Test project repository and its pre-test state
TEST_REPO=/c/repo/tests/demo-linux
BASE_BRANCH=perftest
BASELINE_TAG=baseline-tag

# Saved SQLcl connection used by the tests (conn -name ...)
SQLCL_CONN=proj_vm26

# Run inside TEST_REPO before the tests: restores git to BASELINE_TAG and
# rebuilds the database objects. Runs with the SQLcl version under test.
RESET_CMD='sql -nolog @scripts/sql/rebuild.sql'

# APEX application in the baseline
APEX_SCHEMA=demo1
APEX_WORKSPACE=DEMO1
APEX_APP_ID=106
# A page the baseline app can lose without breaking validation (test 003)
APEX_SPARE_PAGE=100

# One SQLcl home per version label passed to run.sh (dots become underscores)
SQLCL_HOME_26_1=/c/Install/sqlcl-26.1/sqlcl
SQLCL_HOME_26_2=/c/Install/sqlcl-26.2/sqlcl
