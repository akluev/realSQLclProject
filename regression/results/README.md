# SQLcl regression report

Generated 2026-11-06 from tests.json and the results of SQLcl 26.1.2, 26.2.2, 26.3.0, 26.3.1. Tests that depend on the APEX export mode are listed per mode: `readable` (apex.apexlang not set) and `apexlang` (apex.apexlang=true).

## SQLcl 26.3.1: what needs attention

**Regressions** (passed in the prior version, failing now):

- none

**New issues** (failing, not tested in the prior version):

- none

**Fixed** (failed in the prior version, passes now; check and set `fixedIn`):

- 001 (apexlang) P2 [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571): all 1 mixed-case name(s) kept
- 002 (apexlang) P0 [project export corrupts binary APEX static files](https://forums.oracle.com/ords/apexds/post/sqlcl-corrupts-apex-static-files-during-export-apexlang-7800): all 6 binary file(s) byte-identical
- 005 (apexlang) P1 [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571): apex validate succeeded on src/database/demo1/apex_apps/demo1

**Errors** (test could not decide; check the logs):

- none

## Open issues in SQLcl 26.3.1, by severity

| Severity | ID | Mode | Area | Issue | Since | Workaround | Workaround tested |
|---|---|---|---|---|---|---|---|
| P0 | 023 | apexlang | deploy | APEX deployment with the schema in two workspaces: APEXlang fails ("Multiple workspaces available") and records the failed changeset as run; readable must deploy once | ? | None known for the generated APEXlang install. | – |
| P1 | 005 | readable | export | [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | 26.1.2 | Run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after `project export`. | – |
| P1 | 006 | apexlang | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | 26.2.2 | None; do not enable apex.apexlang. | – |
| P1 | 006 | readable | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | 26.2.2 | None; stay on SQLcl 26.1. | – |
| P1 | 007 | apexlang | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) | 26.2 | Add `export_type != 'TABLES_DML'` and `export_type != 'ALL_USERS'` to .dbtools/filters/project.filters (the test project keeps them between --TEST-007 BEGIN and --TEST-007 END). | works: the TEST-007 filters prevent it |
| P1 | 007 | readable | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) | 26.2 | Add `export_type != 'TABLES_DML'` and `export_type != 'ALL_USERS'` to .dbtools/filters/project.filters (the test project keeps them between --TEST-007 BEGIN and --TEST-007 END). | works: the TEST-007 filters prevent it |
| P1 | 010 | apexlang | stage | [Switching to APEXlang mode leaves the legacy SQL controller in apex.changelog.xml](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#apexlang-mode-export-and-stage-deep-dive) | 26.2.2 | Remove the legacy dist/releases/apex/f&lt;id> folder and its &lt;include> from apex.changelog.xml by hand. | – |
| P1 | 011 | – | export | [project export exports ORDS of the connected user instead of the project schemas](https://forums.oracle.com/ords/apexds/post/sqlcl-project-ords-export-should-use-configured-project-sch-9778) | 26.1.2 | Export ORDS while connected as the schema itself (SCHEMA_CONN). The undocumented setting export.ords.ordsAdmin=true does not help: no code reads it in 26.1 or 26.2. | – |
| P1 | 022 | apexlang | stage | After the application deployment is regenerated from scratch, project stage writes more than the controller of the APEX mode (APEXlang: legacy f&lt;app_id> entries come back) | ? | APEXlang mode: comment out the legacy f&lt;app_id> entries in apex.changelog.xml after every stage. | – |
| P2 | 001 | readable | export | [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | 26.1.2 | Run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after `project export`. | does not work: apex export -f leaves 1 of 1 name(s) wrong where project export put them |
| P2 | 003 | readable | export | [project export keeps files of APEX components deleted in APEX](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#the-old-export-defects-remain) | ? | Delete src/database/&lt;schema>/apex_apps/f&lt;id> before `project export`, or run `apex export -applicationid &lt;id> -exptype APEXLANG -dir src/database/&lt;schema>/apex_apps/f&lt;id> -f` after it. | does not work: apex export -f leaves the page file too |
| P2 | 008 | readable | stage | [project stage refuses the APEX controller generated by an earlier SQLcl version](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#staging-changes-the-controller-and-removes-deployment-properties) | 26.2.2 | Delete dist/releases/apex/f&lt;id>/f&lt;id>.xml before `project stage`. | – |
| P2 | 021 | apexlang | export | A second project export of an APEX application, with nothing changed, fails in APEXlang mode | ? | Commit the application folder after each export, before exporting again. | – |

## Results by version

| ID | Mode | Severity | Area | Issue | 26.1.2 | 26.2.2 | 26.3.0 | 26.3.1 |
|---|---|---|---|---|---|---|---|---|
| 001 | apexlang | P2 | export | [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | n/a | **FAIL: new** | FAIL | **PASS: fixed** |
| 001 | readable | P2 | export | [project export lowercases APEXlang file and folder names](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | **FAIL: new** | FAIL | FAIL | FAIL |
| 002 | apexlang | P0 | export | [project export corrupts binary APEX static files](https://forums.oracle.com/ords/apexds/post/sqlcl-corrupts-apex-static-files-during-export-apexlang-7800) | n/a | **FAIL: new** | FAIL | **PASS: fixed** |
| 002 | readable | P0 | export | [project export corrupts binary APEX static files](https://forums.oracle.com/ords/apexds/post/sqlcl-corrupts-apex-static-files-during-export-apexlang-7800) | **FAIL: new** | **PASS: fixed** | PASS | PASS |
| 003 | apexlang | P2 | export | [project export keeps files of APEX components deleted in APEX](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#the-old-export-defects-remain) | n/a | PASS | PASS | PASS |
| 003 | readable | P2 | export | [project export keeps files of APEX components deleted in APEX](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#the-old-export-defects-remain) | **FAIL: new** | FAIL | FAIL | FAIL |
| 004 | – | P2 | export | [project export -o does not export synonyms](https://forums.oracle.com/ords/apexds/post/sqlcl-project-synonyms-are-not-exported-with-o-switch-0194) | **FAIL: new** | FAIL | **PASS: fixed** | PASS |
| 005 | apexlang | P1 | export | [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | n/a | **FAIL: new** | FAIL | **PASS: fixed** |
| 005 | readable | P1 | export | [APEXlang source written by project export fails apex validate](https://forums.oracle.com/ords/apexds/post/sqlcl-project-export-lowercases-apexlang-file-and-folder-na-5571) | **FAIL: new** | FAIL | FAIL | FAIL |
| 006 | apexlang | P1 | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | n/a | **FAIL: new** | FAIL | FAIL |
| 006 | readable | P1 | export | [project export does not use the documented f&lt;app_id>/&lt;app-alias>/ folder](https://forums.oracle.com/ords/apexds/post/bug-sqlcl-26-2-2-project-export-apexlang-structure-is-incon-9777) | PASS | **FAIL: regression** | FAIL | FAIL |
| 007 | apexlang | P1 | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) | n/a | **FAIL: new** | FAIL | FAIL |
| 007 | readable | P1 | export | [project export -o APEX.&lt;id> exports users and data that were not requested](https://forums.oracle.com/ords/apexds/post/apex-app-project-export-is-exporting-application-dml-data-a-4157) | n/a | **FAIL: new** | FAIL | FAIL |
| 008 | readable | P2 | stage | [project stage refuses the APEX controller generated by an earlier SQLcl version](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#staging-changes-the-controller-and-removes-deployment-properties) | n/a | **FAIL: new** | FAIL | FAIL |
| 010 | apexlang | P1 | stage | [Switching to APEXlang mode leaves the legacy SQL controller in apex.changelog.xml](https://alexonapex.com/blog/2026/09/11/sqlcl-project-26-2-2-two-apexlang-directory-structures-one-migration-blocker/#apexlang-mode-export-and-stage-deep-dive) | n/a | **FAIL: new** | FAIL | FAIL |
| 011 | – | P1 | export | [project export exports ORDS of the connected user instead of the project schemas](https://forums.oracle.com/ords/apexds/post/sqlcl-project-ords-export-should-use-configured-project-sch-9778) | **FAIL: new** | FAIL | FAIL | FAIL |
| 012 | – | P2 | stage | [project stage regenerates ORDS changesets even when ORDS did not change](https://forums.oracle.com/ords/apexds/post/sqlcl-project-stage-command-always-regenerates-ords-changes-1990) | PASS | PASS | PASS | PASS |
| 013 | – | P2 | export | [project export appends a semicolon to a view's trailing line comment](https://forums.oracle.com/ords/apexds/post/sqlcl-project-extra-semicolon-added-by-project-export-when-1644) | PASS | PASS | PASS | PASS |
| 015 | apexlang | P1 | stage | [project stage fails with hash errors on APEX supporting object scripts](https://forums.oracle.com/ords/apexds/post/export-to-apexlang-ignores-p-with-supporting-objects-and-al-9749) | n/a | PASS | PASS | PASS |
| 015 | readable | P1 | stage | [project stage fails with hash errors on APEX supporting object scripts](https://forums.oracle.com/ords/apexds/post/export-to-apexlang-ignores-p-with-supporting-objects-and-al-9749) | **FAIL: new** | FAIL | **PASS: fixed** | PASS |
| 016 | – | P2 | stage | [stage.change.changeStyle=multiple puts each staged statement in its own changeset](https://forums.oracle.com/ords/apexds/post/sqlcl-project-please-split-ddl-statements-in-a-file-into-lo-8780) | PASS | PASS | PASS | PASS |
| 017 | – | P2 | project | [Deployed APEX changesets are recorded with different filename separators in DATABASECHANGELOG and DATABASECHANGELOG_ACTIONS on Windows, so they redeploy every time](https://forums.oracle.com/ords/apexds/post/sqlcl-25-4-1-project-windows-apex-changesets-redeployed-eve-3997) | PASS | PASS | PASS | PASS |
| 019 | – | P1 | stage | [Connected as the schema, project export exports ORDS and project stage leaves unchanged ORDS alone](https://forums.oracle.com/ords/apexds/post/sqlcl-project-ords-export-should-use-configured-project-sch-9778) | PASS | PASS | PASS | PASS |
| 020 | – | P0 | stage | project stage fails with "Unable to save changelog, changelog is empty" for a change of more than one statement | PASS | PASS | PASS | PASS |
| 021 | apexlang | P2 | export | A second project export of an APEX application, with nothing changed, fails in APEXlang mode | n/a | **FAIL: new** | FAIL | FAIL |
| 021 | readable | P2 | export | A second project export of an APEX application, with nothing changed, fails in APEXlang mode | PASS | PASS | PASS | PASS |
| 022 | apexlang | P1 | stage | After the application deployment is regenerated from scratch, project stage writes more than the controller of the APEX mode (APEXlang: legacy f&lt;app_id> entries come back) | n/a | PASS | **FAIL: regression** | FAIL |
| 022 | readable | P1 | stage | After the application deployment is regenerated from scratch, project stage writes more than the controller of the APEX mode (APEXlang: legacy f&lt;app_id> entries come back) | PASS | PASS | PASS | PASS |
| 023 | apexlang | P0 | deploy | APEX deployment with the schema in two workspaces: APEXlang fails ("Multiple workspaces available") and records the failed changeset as run; readable must deploy once | n/a | **FAIL: new** | FAIL | FAIL |
| 023 | readable | P0 | deploy | APEX deployment with the schema in two workspaces: APEXlang fails ("Multiple workspaces available") and records the failed changeset as run; readable must deploy once | PASS | PASS | PASS | PASS |
