# SQLcl Regression Tests

Automated checks for known SQLcl Project bugs and enhancement requests, run against any installed SQLcl version. Each run produces a PASS/FAIL table, and the expected result for every issue depends on the version: a fixed bug that fails again is reported as a **regression**, and an open bug that suddenly passes as **newly fixed**.

Latest results: [results/README.md](results/README.md).

## How it works

- [tests.json](tests.json) lists the issues: severity, area, the SQLcl versions where each was introduced and fixed, links to the forum post and documentation, the workaround, and how to test it.
- `issues/<id>/test.sh` checks one issue using only documented SQLcl commands.
- [run.sh](run.sh) resets a local test project and database to a tagged baseline, runs the tests in order (export, then stage), and writes `results/<version>/`.
- [report.sh](report.sh) combines all versions into [results/README.md](results/README.md).

## Running it

You need bash (Git Bash on Windows), git, jq, SQLcl, a local database you may rebuild, and the test project (a SQLcl Project repository with an APEX application).

```shell
cp regression/config.example.sh regression/config.sh   # then edit it
bash regression/run.sh 26.2          # all active tests against SQLcl 26.2
bash regression/run.sh 26.2 004 007  # selected tests
bash regression/report.sh
```

With Claude Code, the `sqlcl-regression` skill ([.claude/skills/sqlcl-regression/SKILL.md](../.claude/skills/sqlcl-regression/SKILL.md)) drives the whole loop: runs a version, interprets the outcomes, updates the catalogue, writes new tests, and builds reports.
