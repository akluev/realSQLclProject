# Project stage

Use this workflow only when the user explicitly asks to run `project stage`, consolidate project changesets, or an equivalent operation. Read [changeset-splitting.md](changeset-splitting.md) as well because splitting follows a successful stage automatically.

## Prerequisites

1. Verify through the SQLcl MCP command tool that SQLcl is 26.1 or later (`_sqlplus_release >= 2601000000`). If the version is older or cannot be established, stop and report the requirement.
2. Read the project configuration and filters so the default branch and object scope are known.
3. Check the Git state under `src/`.

All relevant source work must be committed before `project stage`. SQLcl Project compares committed Git revisions and does not stage uncommitted source changes. This prerequisite cannot be waived for ordinary `project stage`.

If relevant `src/` changes are staged, unstaged, or untracked, stop and ask the user to commit them first. Do not run `git add` or create a commit unless the user separately requests those Git operations.

An assertion-staging workflow may define its own explicit testing override because it computes assertion differences itself and uses `project stage add-custom`; that exception never applies to ordinary `project stage`.

## Run stage

1. From the project root, run `project stage` through the SQLcl MCP command tool.
2. Review the complete output, including compared branches, exported-object summary, generated paths, and changelog updates.
3. Inspect generated files under `dist/releases/next/changes/<branch>/`.
4. Apply [changeset-splitting.md](changeset-splitting.md) sequentially to applicable files.
5. Inspect the final Git diff and leave all results uncommitted for review.

Stage is idempotent and may be rerun after filter adjustments, but never use reruns to conceal an unresolved failure.
