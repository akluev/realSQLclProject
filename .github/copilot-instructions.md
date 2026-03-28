# SQLcl Project Copilot Instructions — Sample & Documentation Repo

> **Note:** This is a sample/documentation repository only. The instructions below are **not intended to function here** — they are provided as a reference for adopting SQLcl Project Copilot integration in your own repo.

---

## How to Use SQLcl Project Instructions in Your Repo

1. **Copy** `.github/sqlcl_project_copilot_instructions.md` into your repo's `.github/` folder.

2. **Create a link** in your own `.github/copilot-instructions.md`:

   ```markdown
   See [SQLcl Project Copilot Instructions](sqlcl_project_copilot_instructions.md)
   ```

3. **Configure the SQLcl MCP server** by adding the following to `.vscode/mcp.json` in your repo:

   ```json
   {
     "servers": {
       "sqlcl.local": {
         "type": "stdio",
         "command": "sql",
         "args": ["-R", "0", "-mcp"]
       }
     }
   }
   ```

4. **Read the documentation** in `docs/13.-Integrating-SQLcl-Project-with-GitHub-Copilot.md` for full setup and usage guidance.

