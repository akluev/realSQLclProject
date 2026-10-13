# Assertion source format and staging decisions

This is the specification that `scripts/export-assertion.sh` and `scripts/stage-assertion.sh` implement. Agents do not need to read it to export or stage. It exists for reviewers, and for anyone who changes the scripts.

## Why a custom format

SQLcl Project does not export assertions, and `DBMS_METADATA.GET_DDL` / `GET_XML` reject `OBJECT_TYPE => 'ASSERTION'` with `ORA-31600`. So there is no SXML to diff. Instead, each exported file carries a `sqlcl_snapshot` trailer in the same shape SQLcl Project writes for its own objects. Staging compares those trailers instead of parsing SQL.

## File layout

Path: `src/ext/<owner-lowercase>/assertions/<assertion-name-lowercase>.sql`.

The file is `DEFINITION_SQL` **verbatim**, with only these mechanical edits and no SQL formatting:

- carriage returns and trailing whitespace stripped; leading and trailing blank lines dropped;
- `IF NOT EXISTS` inserted after `CREATE ASSERTION` on the first line, unless already present;
- after the last line containing `)`, blank lines (spool artifacts) and any trailing `;` dropped;
- a single `/` line, two blank lines, and the trailer appended, with no final newline (as SQLcl writes it).

```sql
CREATE ASSERTION IF NOT EXISTS "CLA_APEX"."CLA_AIRCRAFT_ASSERTION_PROBE" CHECK
(
    not exists (
        select 1
          from cla_aircraft a
         where a.id is null
    )
)
 ENABLE
 NOT DEFERRABLE
 INITIALLY IMMEDIATE
 VALIDATE
/


-- sqlcl_snapshot {"hash":"4d0554c1c992f5c85973388688328a6c8d119be6","type":"ASSERTION","name":"CLA_AIRCRAFT_ASSERTION_PROBE","schemaName":"CLA_APEX","sxml":""}
```

Oracle generates `DEFINITION_SQL` deterministically: the wrapper (`CREATE ASSERTION "OWNER"."NAME" CHECK`, `(`, the condition as written, `)`), then one state clause per line, each with a leading space. Reformatting a file changes its hash, and staging then treats the assertion as modified (DROP + CREATE).

## Trailer

`-- sqlcl_snapshot {"hash":"<sha1>","type":"ASSERTION","name":"<ASSERTION_NAME>","schemaName":"<OWNER>","sxml":""}`

- Key order `hash`, `type`, `name`, `schemaName`, `sxml`. `type` is always `ASSERTION`; `sxml` is always `""`.
- `name` and `schemaName` come from the dictionary row (`OWNER`, or the session user for `USER_ASSERTIONS`).

## Hash

`hash` covers only the **immutable** part: line 1 through the **last** line containing `)`, with the trailer excluded. The `CHECK` condition may contain many `)` lines (`EXISTS`, `ALL (...)`, `SATISFY (...)`), but nothing after the `CHECK` close contains a parenthesis. The state clauses, `/`, and the trailer are therefore outside the hash, so `ENABLE`/`DISABLE` or `VALIDATE`/`NOVALIDATE` changes do not change it. It is computed with `git hash-object --stdin` after stripping carriage returns. That needs only Git, and it produces the same 40-hex SHA-1 form SQLcl uses.

The state clauses are the non-empty, non-`/` lines after the last `)` line, trimmed of leading whitespace. Export verifies them against the dictionary columns:

| Column | Value | Clause |
|---|---|---|
| `STATUS` | `ENABLED` / `DISABLED` | `ENABLE` / `DISABLE` |
| `DEFERRABLE` | `NOT DEFERRABLE` / `DEFERRABLE` | same |
| `DEFERRED` | `IMMEDIATE` / `DEFERRED` | `INITIALLY IMMEDIATE` / `INITIALLY DEFERRED` |
| `VALIDATED` | `VALIDATED` / `NOT VALIDATED` | `VALIDATE` / `NOVALIDATE` |

## Staging decision

Baseline: the merge base of `git.defaultBranch` (from `.dbtools/project.config.json`) and `HEAD`. Current source: `HEAD` (default), or the working-tree file with `--worktree`.

| Baseline | Current | Condition | Decision |
|---|---|---|---|
| absent | present | — | `CREATE` |
| present | absent | — | `DROP` (qualified name from the baseline trailer) |
| present | present | identical content | `NONE` |
| present | present | `hash`, `name`, or `schemaName` differ, or the `[NOT] DEFERRABLE` / `INITIALLY …` lines differ | `DROP_CREATE` |
| present | present | only `ENABLE`/`DISABLE` or `VALIDATE`/`NOVALIDATE` differ | `ALTER <ENABLE|DISABLE> <VALIDATE|NOVALIDATE>` |
| present | present | otherwise (whitespace outside the hash) | `NONE` |

The script stops (`STOP <reason>`) on:
- a missing trailer;
- a stale hash (the recomputed hash differs from the trailer, meaning the file was edited after export);
- anything other than four state clauses;
- uncommitted changes in committed mode;
- a final state of `DISABLE VALIDATE`, which Oracle rejects with `ORA-08701`.

A rename appears as `DROP` of the old path plus `CREATE` of the new one, because Oracle has no assertion rename.

Deferrability and initial timing are creation properties, so they need DROP + CREATE; `ALTER ASSERTION` changes only enablement and validation. The ALTER is a single final-state statement. Enablement and validation are never split, because Oracle applies defaults during state transitions.

## Custom file shapes

Every statement is fully qualified and terminated by `/` on its own line, never `;`. The trailer is never copied.

- `ALTER`, `DROP`, `CREATE`: the generated header is kept byte-for-byte, and the placeholder body is replaced by one statement.
- `DROP_CREATE`: split per the SQLcl Project changeset-splitting rules. The `-- sqlcl_snapshot …:custom` line moves to line 2, the unsuffixed changeset header is removed, and `<id>.1` holds `DROP ASSERTION IF EXISTS`, then `<id>.2` holds `CREATE ASSERTION IF NOT EXISTS`, with every generated attribute preserved.
