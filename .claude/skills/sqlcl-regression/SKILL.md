---
name: sqlcl-regression
description: 'Run and maintain the SQLcl / SQLcl Project regression tests in regression/: test a SQLcl version (e.g. "run regression for 26.3"), interpret PASS/FAIL results, update the test catalogue (tests.json), add a regression test for a bug, change the test baseline, and generate regression reports. Use when asked to regression-test SQLcl, check whether a SQLcl bug is fixed or has come back, add a bug to the regression suite, or report regression results.'
---

# SQLcl Regression Testing

The suite checks known SQLcl Project bugs and enhancement requests against any installed SQLcl version and produces a PASS/FAIL table. Everything lives in `regression/`:

| Path | What it is |
|---|---|
| `tests.json` | The catalogue: one record per issue (a forum post with two problems is two records). |
| `tests.md` | Readable catalogue for people, generated from `tests.json` by `catalog.sh`. Never edit it by hand. |
| `issues/<id>/test.sh` | Deterministic test script for an issue. |
| `run.sh <version> [--mode readable\|apexlang] [id ...]` | Runs the selected tests once per APEX mode (each pass from a fresh reset), writes `results/<full-version>/results.md` and `results.json`. |
| `report.sh` | Builds the cross-version report `results/README.md`. |
| `lib/common.sh` | Helpers shared by the runner and the tests. |
| `reset/reset.sh [<version>]` | Puts the test project back to its baseline: git (`BASE_BRANCH` at `BASELINE_TAG`, local changes discarded), then `drop_all.sql` and `install.sql` (both take the connection, schema and workspace as parameters). |
| `reset/baseline.sh [<commit>]` | Moves `BASELINE_TAG` (default: tip of `BASE_BRANCH`), then runs the reset. |
| `config.example.sh` | Template for the local, gitignored `config.sh`. |

Tests run against a separate **test project** (shipped as a zip; its README describes it): a SQLcl Project repository with schema DEMO1, APEX application 106 and an ORDS module, installed into a local database you may rebuild. Each run starts with `reset/reset.sh`, or with `RESET_CMD` when a user configured their own reset.

## First-time setup

1. Requirements: bash (Git Bash on Windows), git, jq, one or more SQLcl installs (26.1 or later), a local database you may drop and rebuild objects in, and two saved SQLcl connections (`conn -save`): an installer with rights to create the schema, the APEX workspace and ORDS definitions through `ORDS_ADMIN`, and the project schema itself.
2. Unpack the test project outside any other git repository and confirm it is clean on `main` with tag `baseline`.
3. `cp regression/config.example.sh regression/config.sh` and set `TEST_REPO`, `BASE_BRANCH`, `BASELINE_TAG`, `SQLCL_CONN` (installer), `SCHEMA_CONN` (the project schema), the APEX settings and one `SQLCL_HOME_<version>` per install (`SQLCL_HOME_26_3` for `run.sh 26.3`).
4. Run `bash regression/reset/reset.sh <version>` once and check it ends with `Reset done`.

If `config.sh` is missing or a setting is wrong, the runner stops with a message naming it; fix it with the user rather than guessing paths.

## Running a version

1. Confirm the version label has a `SQLCL_HOME_*` entry. The runner checks `sql -V` matches.
2. To publish results for a release, create a branch in this repo first: `git checkout -b sqlcl-<version>-testing`.
3. Run `bash regression/run.sh <version>` (or with test ids to run a subset). One run takes a few minutes; the reset output is shown live. Run it in the background and wait for it to finish rather than polling.
4. Run `bash regression/report.sh`.
5. Interpret the results (next section), update `tests.json`, and show the user the table from `results/<version>/results.md`.
6. Commit `results/<version>/results.md`, `results.json`, `results/README.md` and catalogue changes on the testing branch. The user merges and publishes; never push or merge yourself.

`results/*/logs/<mode>/` holds every SQLcl log of the run and is gitignored. In the test project, each run commits every test's leftovers to a branch `regression/<version>-<timestamp>` (readable pass), `...-apexlang` (APEXlang pass), and `...-<id>` branches for isolated tests. They are deleted at the end of the run unless `KEEP_TEST_BRANCHES=true` in `config.sh`; when kept, the next run of the same version replaces them. Set it to `true` when a result needs investigating.

`run.sh` updates `lastFailedIn` in `tests.json` and regenerates `tests.md`; commit both with the results.

## APEX export modes

SQLcl exports an APEX application differently depending on `apex.apexlang` in `project.config.json`, and the bugs differ too (e.g. binary files survive a readable-mode export but not an APEXlang-mode one). A test that depends on it has a `modes` object and runs once per mode under the same id:

| Mode | Setting | Pass |
|---|---|---|
| `readable` | `apex.apexlang` not set: the baseline as it is | First: also runs every test without `modes` (shown as `–`). |
| `apexlang` | `apex.apexlang=true` | Second, on its own branch from `BASELINE_TAG` (no database reset in between). `run.sh` commits the setting on top of `BASELINE_TAG` and uses that commit as the tests' baseline (`MODE_BASE`), so `restore_from_baseline` and `isolate_branch` keep the mode. On a SQLcl without the setting (26.1) the pass reports N/A. |

`--mode <mode>` runs only that pass. Tests see the mode in `APEX_MODE`. Tests with `modes` must not assume a folder layout: search `apex_apps_dir`, or use `exported_app_dir` (the folder holding `application.apx`). Results, `lastFailedIn` and the reports are kept per test and mode.

## Which tests run

Only records with `"active": true`, in every mode they list (or the readable pass when they have no `modes`). For each one, the SQLcl version under test decides the expected result:

| Condition | Expected | Why |
|---|---|---|
| version < `introducedIn`, and `testFrom` set and reached | PASS | A regression: the behaviour existed and worked before `introducedIn`. |
| version < `introducedIn` otherwise | not run (N/A) | The feature or bug did not exist yet; never test backwards. |
| `fixedIn` set and version >= `fixedIn` | PASS | Fixed earlier; a FAIL is a regression. |
| otherwise (`introducedIn` empty or reached, not fixed) | FAIL | Known open issue. |

A fixed issue stays active and keeps being tested in every later version; that is what catches regressions. Set `"active": false` only when the user says an issue or the versions it applies to are no longer of interest.

Outcomes: **OK** (as expected, fixed), **KNOWN ISSUE** (as expected, still open), **REGRESSION** (fixed before, failing again), **NEWLY FIXED** (expected to fail, passed), **ERROR** (the test could not decide), **MANUAL** (no script; run the prompt by hand), **N/A**.

## Interpreting results and updating the catalogue

- **REGRESSION**: read `logs/<id>.log` and the SQLcl logs it names, confirm it is the product and not the environment, and report it prominently. Do not change `fixedIn`.
- **NEWLY FIXED**: verify by reading the logs and, if useful, repeating the check by hand. Then propose `fixedIn: "<version>"` to the user; change it only after they agree.
- **KNOWN ISSUE**: set `lastFailedIn` to the version.
- **ERROR**: usually environment or setup (database down, ORA-00257, connection, baseline drift). Fix the cause or report it; do not record it as a product result.
- **MANUAL**: follow the record's `prompt` in the test project with SQLcl, judge against `successCriteria`, and add the result to the run's `results.md` by hand with a comment saying it was manual.

## Test records (`tests.json`)

| Field | Meaning |
|---|---|
| `id` | Three-digit number, also the folder `issues/<id>/`. Never reuse a number. |
| `kind` | `bug`, `enhancement` (requested behaviour), or `feature` (working behaviour guarded against regressions; `fixedIn` = first version that has it). |
| `severity` | `P0` critical/blocker, `P1` high, `P2` medium, `P3` low (same scale as the docs). Reports sort by it. |
| `title` | One line, the issue as a statement. |
| `area` | `project`, `export`, `stage` or `apex`; tests run in this order. |
| `active` | Whether to keep testing it. |
| `introducedIn` / `fixedIn` / `lastFailedIn` | SQLcl versions, e.g. `26.2.2`; `null` when unknown or not yet. |
| `testFrom` | Optional. For regressions: the oldest version to test, where the behaviour still worked (expected PASS below `introducedIn`). Nothing below 26.1 is tested. |
| `oracleStatus` | Free text: not reported, reported, confirmed (who, when), fixed. |
| `forumUrl`, `docRef`, `articleUrl`, `oracleDocUrl` | Where the issue is described: forum post, section in `docs/`, blog post, Oracle's own documentation (e.g. the documented layout the export contradicts). |
| `resetBefore` | Optional, `true` for tests that need the database exactly at the baseline, such as a full schema export (011, 012, 019). The runner resets before them if any test ran since the last reset. |
| `workaround` | How users get around it today (information only; tests never use it). |
| `prompt` | How to test it, in words; enough for an agent to run it without the script. |
| `successCriteria` | What PASS means, checkable from files, output or the database. |
| `script` | `issues/<id>/test.sh`, or `null` for a prompt-only (MANUAL) test. |
| `modes` | Optional, for tests that depend on the APEX export mode: `{"readable": {...}, "apexlang": {...}}`, only the modes the test applies to. Each mode object holds that mode's `testFrom`, `introducedIn`, `fixedIn` and `lastFailedIn` (not at the top level then), and may override any other field, such as `oracleStatus`, `workaround` or `articleUrl`. |

When a bug turns out to differ between modes, add `modes` to its record rather than a new test. A mode-specific bug, like 010 (only in APEXlang mode), lists only that mode.

## Writing a new test

1. Find the issue in `docs/` (bugs list, enhancements, articles) or the forum post. Reproduce it by hand in the test project first, on a scratch branch, with the SQLcl version that has it; note the exact command and output.
2. Add the record to `tests.json` with the next free id, then `issues/<id>/test.sh`. Start the script with a comment saying what must hold, and `source "$(dirname "$0")/../../lib/common.sh"`.
3. End with `pass "<comment>"`, `fail "<comment>"` or `error "<comment>"` (exit 0/1/2). The comment goes into the results table: say what was observed, with names and numbers.
4. Rules:
   - Use only documented SQLcl commands, as a user would. Never the user's personal aliases or scripts.
   - Never deploy (`lb update`, `project deploy`): the suite tests export and stage. Changes a test needs are made directly in the database and undone in its trap.
   - SQLcl often exits 0 on failure: decide from files, query results or output text (`Validation successful`, `Import successful`, `Stage processing completed`).
   - Pass paths to SQLcl through `native_path` (Git Bash paths are not Windows paths). SQLcl runs with the test project as its working directory, so repo-relative paths also work.
   - Name database objects `REG_<id>_*`, and drop them in an `EXIT` trap. Restore files with `restore_from_baseline <path>`.
   - Tests that commit or run `project stage` call `isolate_branch <id>` and `leave_branch` from the `EXIT` trap.
   - To give export or stage a real application change, use `remove_page_in_apex` and restore with `restore_apex_app` in the trap.
   - On Windows the file system ignores case: remove an export folder before exporting into it when names matter (`fresh_apex_export` does).
   - Use `warn` for problems during cleanup; it adds to the comment without changing the verdict.
   - Keep the fix and the workaround apart. The verdict (pass/fail) comes only from the documented command: an issue a workaround avoids is still a FAIL. A test that also checks the workaround calls `workaround works "<detail>"` or `workaround "does not work" "<detail>"`; the runner shows it in the results' own Workaround column (and in the open-issues report), never in the outcome or the comment.
   - Workarounds the test project needs in normal use (e.g. export filters) live in the project between `--TEST-<id> BEGIN` and `--TEST-<id> END`, so other tests are not disturbed by the bug. The test for that issue removes its block with `drop_workaround <id> <file>`, restores the file in its trap, and reports with `workaround` whether the block still works.
   - In APEXlang mode, project export refuses to overwrite uncommitted changes in the application folder (021). A test that exports twice commits the first export in between, on an isolated branch (see 003).
   - Some things only work connected as the schema owner (ORDS export): use `as_schema <helper>` with `SCHEMA_CONN`.
5. Run the new test on a version that has the issue and on one that does not, if available, in each of its modes: `bash regression/run.sh 26.1 <id>`. Both outcomes must come out right before the test counts as done.
6. Keep `tests.md` in sync: after **any** change to `tests.json` (new test, changed fields, `fixedIn` agreed with the user, deactivation), run `bash regression/catalog.sh` and commit `tests.json` and `tests.md` together.

Helpers in `lib/common.sh`: `workaround`, `base_ref`, `apex_apps_dir`, `exported_app_dir`, `set_apex_mode`, `sqlcl_script`, `as_schema`, `sql_value`, `native_path`, `apex_alias`, `drop_workaround`, `outside_apex_changes`, `fresh_apex_export`, `export_apex_app` (shared, once per run), `keep_only_apex_export`, `restore_from_baseline`, `restore_apex_app_dir`, `apex_import`, `apex_page_count`, `remove_page_in_apex`, `restore_apex_app`, `baseline_apexlang_copy`, `isolate_branch` / `leave_branch`, `commit_all`, `project_stage`, `first_error`, `ver_ge`.

## Changing the baseline

Some tests need something the baseline does not have yet (an ORDS module, a property, another object type). Change the test project, never only the database:

1. In the test project, branch from the base branch, make the change in the database, then `project export`, commit, `project stage`, commit (or add a custom changeset with `project stage add-custom` when export cannot produce it, or when installing it as the installer would go wrong, as for ORDS).
2. Merge into the base branch, then `bash regression/reset/baseline.sh <version>`: it moves the tag and rebuilds from it. Check the output ends with `Reset done` and the database contains the change.
3. Re-run the whole suite on the version the baseline was built with to confirm nothing else moved.

Keep the two connection setups apart. The baseline is installed and tested through the installer (`SQLCL_CONN`), like most real deployments. Material that only a schema connection produces (the ORDS export in `src/database/demo1/ords/` and `dist/releases/ords/`) stays in the baseline for the schema-connection tests, but is not installed (commented out in `dist/releases/main.changelog.xml`).

## Reports

Generate them from the saved results; never from memory.

| Report | How |
|---|---|
| One version, full table | `results/<version>/results.md`, written by `run.sh`. |
| What needs attention in the latest version (regressions, newly fixed, errors) | Top of `results/README.md` from `report.sh`. |
| Open issues by severity, with workarounds | `results/README.md`, second section. |
| Test-by-version matrix | `results/README.md`, last section. |
| Anything else (one issue's history, issues fixed between two versions, only P0/P1) | Query `tests.json` and `results/*/results.json` with jq and present a table. |

When the user wants a write-up for a forum post or the blog, start from `results/README.md`: lead with regressions and P0/P1 open issues, link each issue to its forum post, and state the SQLcl build and run date.
