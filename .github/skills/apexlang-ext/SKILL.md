---
name: apexlang-ext
description: 'Extension for APEXlang development workflows. Use when working with APEXlang, validating page components, or looking for specific APEXlang expertise documentation. High-level lessons learned for working with APEXlang effectively.'
---

# APEXlang Extension - Lessons Learned

This skill captures repository-specific lessons and extensions for working with APEXlang faster and more reliably.

## Key Lessons

### 1. Authoritative Documentation
Always refer to the **global skill `apex`** (specifically the `apexlang/` subfolder) for the most up-to-date and authoritative APEXlang documentation. This is where Oracle provides the latest language contracts and workflow guides.

- Path: `~/.copilot/skills/apex/apexlang/`

### 2. Property & Component Validation
When unsure about valid properties or component structures (like `pieSelectionEffect` vs. available properties), use the provided node tools within the global skill to query the compiler-backed truth.

- **Command**: `node ~/.copilot/skills/apex/apexlang/tools/query-valid-props.mjs --component <component_name>`
- *Example*: `node ~/.copilot/skills/apex/apexlang/tools/query-valid-props.mjs --component chart.series`

### 3. Icon Handling (Font APEX)
When providing an icon class from a database column (e.g., `iconSource: iconClassColumn`), you must also provide the `iconCssClasses` property with the value `fa` to ensure Font APEX icons render correctly.

- **Requirement**: Set `iconCssClasses: fa` whenever icons come from a column or are static Font APEX icons.

### 4. MCP Validation Gate
Before considering a task complete and returning it to the user, **always** validate the generated or updated `.apx` files through the **MCP server**.

- **Workflow**:
    1. Update the `.apx` file in the repository.
    2. Run MCP command: `mcp_sqlcl_local_sqlcl_run(sqlcl: "apex validate -input <alias-path> -ws <workspace>")`
    3. Correct any errors reported by the compiler before final delivery.

### 5. Page Alias and Filename Matching
APEXlang page files must keep the page `alias` value synchronized with the page filename slug.

- **Rule**: The filename slug after `pNNNNN-` is lowercase with dash separators; the page `alias` is the same slug in uppercase, preserving dashes.
- **Example**: `pages/p00004-salary-dashboard.apx` must contain `alias: SALARY-DASHBOARD`.
- **Do not** convert dashes to underscores. `alias: SALARY_DASHBOARD` causes `FILENAME_MISMATCH` during `apex validate`.

## Step-by-Step Workflow for New Features

1. **Research**: Consult the global `apex/apexlang` skill for relevant templates and logic.
2. **Draft**: Create the `.apx` files followed by list/breadcrumb updates as needed.
3. **Validate**: Run the `apex validate` command via MCP.
4. **Iterate**: Fix any `INVALID_PROPERTY` or `MISSING_REQUIRED_PROPERTY` errors detected by the compiler.
5. **Import/Export**: Proceed with `apex import` to apply changes to the live application.
