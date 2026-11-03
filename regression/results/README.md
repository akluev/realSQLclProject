# SQLcl regression report

Generated 2026-10-29 from tests.json and the results of SQLcl 26.1.2, 26.2.2, 26.3.0. Tests that depend on the APEX export mode are listed per mode: `readable` (apex.apexlang not set) and `apexlang` (apex.apexlang=true).

## SQLcl 26.3.0: what needs attention

**Regressions** (fixed earlier, failing again):

- 016 P2 [stage.change.changeStyle=multiple puts each staged statement in its own changeset](https://forums.oracle.com/ords/apexds/post/sqlcl-project-please-split-ddl-statements-in-a-file-into-lo-8780): project stage cannot stage the change at all: 'Unable to save changelog, changelog is empty' (see 020)

**Newly fixed** (expected to fail, passed; check and set `fixedIn`):

- 003 (apexlang) P2 [project export keeps files of APEX components deleted in APEX](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#the-old-export-defects-remain): page 100 file removed by project export
- 004 P2 [project export -o does not export synonyms](https://forums.oracle.com/ords/apexds/post/sqlcl-project-synonyms-are-not-exported-with-o-switch-0194): synonym exported to src/database/demo1/synonyms/reg_004_syn.sql

**Errors** (test could not decide; check the logs):

- 012 P2 [project stage regenerates ORDS changesets even when ORDS did not change](https://forums.oracle.com/ords/apexds/post/sqlcl-project-stage-command-always-regenerates-ords-changes-1990): project stage failed: ERROR: An error occured trying to create controller C:\repo\tests\sqlcl-regression-demo\dist\releases\next\changes\regression\26.3.0-20261029-193010-012\stage.changelog.xml Unable to save changelog, changelog is empty;

## Open issues in SQLcl 26.3.0, by severity

| Severity | ID | Mode | Area | Issue | Since | Workaround | Workaround tested |
|---|---|---|---|---|---|---|---|
| P0 | 002 | apexlang | export | [project export corrupts binary APEX static files](https://forums.oracle.com/ords/apexds/post/sqlcl-corrupts-apex-static-files-during-export-apexlang-7800) | ? | Run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after `project export`; it rewrites the binary files correctly. | – |
| P0 | 020 | – | stage | project stage fails with "Unable to save changelog, changelog is empty" for a change of more than one statement | 26.3 | None found: changeStyle single, multiple or not set all fail the same way. | – |
| P1 | 005 | readable | export | [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | 26.1.2 | Run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after `project export`. | – |
| P1 | 005 | apexlang | export | [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | 26.1.2 | Run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after `project export`. | – |
| P1 | 006 | readable | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | 26.2.2 | None; stay on SQLcl 26.1. | – |
| P1 | 006 | apexlang | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | 26.2.2 | None; do not enable apex.apexlang. | – |
| P1 | 007 | readable | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) | 26.2 | Add `export_type != 'TABLES_DML'` and `export_type != 'ALL_USERS'` to .dbtools/filters/project.filters (the test project keeps them between --TEST-007 BEGIN and --TEST-007 END). | works: the TEST-007 filters prevent it |
| P1 | 007 | apexlang | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) | 26.2 | Add `export_type != 'TABLES_DML'` and `export_type != 'ALL_USERS'` to .dbtools/filters/project.filters (the test project keeps them between --TEST-007 BEGIN and --TEST-007 END). | works: the TEST-007 filters prevent it |
| P1 | 010 | apexlang | stage | [Switching to APEXlang mode leaves the legacy SQL controller in apex.changelog.xml](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#apexlang-mode-export-and-stage-deep-dive) | 26.2.2 | Remove the legacy dist/releases/apex/f&lt;id> folder and its &lt;include> from apex.changelog.xml by hand. | – |
| P1 | 011 | – | export | [project export exports ORDS of the connected user instead of the project schemas](https://forums.oracle.com/ords/apexds/post/sqlcl-project-ords-export-should-use-configured-project-sch-9778) | 26.1.2 | Export ORDS while connected as the schema itself (SCHEMA_CONN). The undocumented setting export.ords.ordsAdmin=true does not help: no code reads it in 26.1 or 26.2. | – |
| P2 | 001 | readable | export | [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | 26.1.2 | Run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after `project export`. | – |
| P2 | 001 | apexlang | export | [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | 26.1.2 | Run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after `project export`. | – |
| P2 | 003 | readable | export | [project export keeps files of APEX components deleted in APEX](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#the-old-export-defects-remain) | ? | Delete src/database/&lt;schema>/apex_apps/f&lt;id> before `project export`, or run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after it. | does not work: apex export -f leaves the page file too |
| P2 | 008 | readable | stage | [project stage refuses the APEX controller generated by an earlier SQLcl version](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#staging-changes-the-controller-and-removes-deployment-properties) | 26.2.2 | Delete dist/releases/apex/f&lt;id>/f&lt;id>.xml before `project stage`. | – |
| P2 | 016 | – | stage | [stage.change.changeStyle=multiple puts each staged statement in its own changeset](https://forums.oracle.com/ords/apexds/post/sqlcl-project-please-split-ddl-statements-in-a-file-into-lo-8780) | ? | Add "change": {"changeStyle": "multiple"} to the stage object in .dbtools/project.config.json. | – |
| P2 | 021 | apexlang | export | A second project export of an APEX application, with nothing changed, fails in APEXlang mode | ? | Commit the application folder after each export, before exporting again. | – |

## Results by version

| ID | Mode | Severity | Area | Issue | 26.1.2 | 26.2.2 | 26.3.0 |
|---|---|---|---|---|---|---|---|
| 002 | readable | P0 | export | [project export corrupts binary APEX static files](https://forums.oracle.com/ords/apexds/post/sqlcl-corrupts-apex-static-files-during-export-apexlang-7800) | FAIL | PASS | PASS |
| 002 | apexlang | P0 | export | [project export corrupts binary APEX static files](https://forums.oracle.com/ords/apexds/post/sqlcl-corrupts-apex-static-files-during-export-apexlang-7800) |  |  | FAIL |
| 020 | – | P0 | stage | project stage fails with "Unable to save changelog, changelog is empty" for a change of more than one statement |  |  | FAIL |
| 005 | readable | P1 | export | [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | FAIL | FAIL | FAIL |
| 005 | apexlang | P1 | export | [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) |  |  | FAIL |
| 006 | readable | P1 | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | PASS | FAIL | FAIL |
| 006 | apexlang | P1 | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | n/a | FAIL | FAIL |
| 007 | readable | P1 | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) | n/a | FAIL | FAIL |
| 007 | apexlang | P1 | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) |  |  | FAIL |
| 010 | apexlang | P1 | stage | [Switching to APEXlang mode leaves the legacy SQL controller in apex.changelog.xml](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#apexlang-mode-export-and-stage-deep-dive) | n/a | FAIL | FAIL |
| 011 | – | P1 | export | [project export exports ORDS of the connected user instead of the project schemas](https://forums.oracle.com/ords/apexds/post/sqlcl-project-ords-export-should-use-configured-project-sch-9778) | FAIL | FAIL | FAIL |
| 015 | readable | P1 | stage | [project stage fails with hash errors on APEX supporting object scripts](https://forums.oracle.com/ords/apexds/post/export-to-apexlang-ignores-p-with-supporting-objects-and-al-9749) | FAIL | **FAIL: regression** | PASS |
| 015 | apexlang | P1 | stage | [project stage fails with hash errors on APEX supporting object scripts](https://forums.oracle.com/ords/apexds/post/export-to-apexlang-ignores-p-with-supporting-objects-and-al-9749) |  |  | PASS |
| 019 | – | P1 | stage | [Connected as the schema, project export exports ORDS and project stage leaves unchanged ORDS alone](https://forums.oracle.com/ords/apexds/post/sqlcl-project-ords-export-should-use-configured-project-sch-9778) |  |  | PASS |
| 001 | readable | P2 | export | [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | FAIL | FAIL | FAIL |
| 001 | apexlang | P2 | export | [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) |  |  | FAIL |
| 003 | readable | P2 | export | [project export keeps files of APEX components deleted in APEX](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#the-old-export-defects-remain) | FAIL | FAIL | FAIL |
| 003 | apexlang | P2 | export | [project export keeps files of APEX components deleted in APEX](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#the-old-export-defects-remain) |  |  | **PASS: newly fixed** |
| 004 | – | P2 | export | [project export -o does not export synonyms](https://forums.oracle.com/ords/apexds/post/sqlcl-project-synonyms-are-not-exported-with-o-switch-0194) | FAIL | FAIL | **PASS: newly fixed** |
| 008 | readable | P2 | stage | [project stage refuses the APEX controller generated by an earlier SQLcl version](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#staging-changes-the-controller-and-removes-deployment-properties) | n/a | FAIL | FAIL |
| 012 | – | P2 | stage | [project stage regenerates ORDS changesets even when ORDS did not change](https://forums.oracle.com/ords/apexds/post/sqlcl-project-stage-command-always-regenerates-ords-changes-1990) | PASS | PASS | ERROR |
| 013 | – | P2 | export | [project export appends a semicolon to a view's trailing line comment](https://forums.oracle.com/ords/apexds/post/sqlcl-project-extra-semicolon-added-by-project-export-when-1644) | PASS | PASS | PASS |
| 016 | – | P2 | stage | [stage.change.changeStyle=multiple puts each staged statement in its own changeset](https://forums.oracle.com/ords/apexds/post/sqlcl-project-please-split-ddl-statements-in-a-file-into-lo-8780) | PASS | PASS | **FAIL: regression** |
| 017 | – | P2 | project | [Deployed APEX changesets are recorded with different filename separators in DATABASECHANGELOG and DATABASECHANGELOG_ACTIONS on Windows, so they redeploy every time](https://forums.oracle.com/ords/apexds/post/sqlcl-25-4-1-project-windows-apex-changesets-redeployed-eve-3997) |  |  |  |
| 021 | readable | P2 | export | A second project export of an APEX application, with nothing changed, fails in APEXlang mode |  |  | PASS |
| 021 | apexlang | P2 | export | A second project export of an APEX application, with nothing changed, fails in APEXlang mode |  |  | FAIL |
