# Project stage

Use this workflow only when the user explicitly asks to run `project stage`, consolidate project changesets, or an equivalent operation. Read [changeset-splitting.md](changeset-splitting.md) as well because splitting follows a successful stage automatically.

## Prerequisites

1. Verify through the SQLcl MCP command tool that SQLcl is 26.1 or later (`_sqlplus_release >= 2601000000`). If the version is older or cannot be established, stop and report the requirement.
2. Read the project configuration and filters so the default branch and object scope are known.
3. Check the Git state under `src/`.

All relevant source work must be committed before `project stage`. SQLcl Project compares committed Git revisions and does not stage uncommitted source changes. This prerequisite cannot be waived for ordinary `project stage`.

If relevant `src/` changes are staged, unstaged, or untracked, stop and ask the user to commit them first. Do not run `git add` or create a commit unless the user separately requests those Git operations.

An assertion-staging workflow may define its own explicit testing override because it computes assertion differences itself and uses `project stage add-custom`; that exception never applies to ordinary `project stage`.

## SQLcl 26.3: APEX application changes use `prj_apex_stage`

SQLcl 26.3 has a stage bug ([forum post](https://forums.oracle.com/ords/apexds/post/sqlcl-26-3-projects-not-updating-the-apex-xml-sqlcl-checksu-8305)): when it regenerates `dist/releases/apex/f<app_id>/f<app_id>.sql`, it leaves the old `-- sqlcl_checksum` line in the matching `f<app_id>.xml`. A corrected XML then looks "edited" to the next stage, which refuses to overwrite it.

Use the workaround instead of plain `project stage` when **both** are true:

- SQLcl is 26.3 or later (`_sqlplus_release >= 2603000000`) and the bug is not yet fixed.
- APEX application source changed on the branch: `git diff --name-only <default-branch>...HEAD -- 'src/database/*/apex_apps/'` is not empty.

Workaround, in this exact order (the `prj_apex_stage` alias in the bundled `sqlcl-project-aliases.xml` does all three):

1. Delete `dist/releases/apex/f*` (the generated application folders only; keep `apex.changelog.xml`).
2. Run `project stage`.
3. Run `scripts/bash/fix-apex-checksums.sh` from the project root. It copies the hash from each `f<app_id>.sql` `-- sqlcl_snapshot` trailer into the `-- sqlcl_checksum` line of `f<app_id>.xml`. Expect `errors=0`; report any `ERROR` line.

Run `prj_apex_stage` through the SQLcl MCP command tool when the alias is loaded. Otherwise perform the three steps yourself, step 2 through MCP. If `scripts/bash/fix-apex-checksums.sh` is missing, stop and report it. Then continue with step 2 of **Run stage** below.

## Run stage

1. From the project root, run `project stage` through the SQLcl MCP command tool (or `prj_apex_stage`, see above).
2. Review the complete output, including compared branches, exported-object summary, generated paths, and changelog updates.
3. Inspect generated files under `dist/releases/next/changes/<branch>/`.
4. Apply [changeset-splitting.md](changeset-splitting.md) sequentially to applicable files.
5. Inspect the final Git diff and leave all results uncommitted for review.

Stage is idempotent and may be rerun after filter adjustments, but never use reruns to conceal an unresolved failure.
