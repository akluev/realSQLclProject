# Fragment of ~/.bashrc to support different SQLcl versions in different folders.
# Copy the relevant sections into your own ~/.bashrc and adjust the paths.

alias rmlogs='find . -type f -name "*.log" -delete'

alias rords='git restore --source=main --worktree --staged -- dist/releases/ords'

# ============================================================================
# Project-specific SQL PATH management
# Automatically switch between sqlcl-26.1 (for demo/26.1 folders) and sqlcl-latest (others)
# ============================================================================
update_sql_path() {
    # Set upgrade_sql to your new SQLcl version path, latest_sql to your current production version path.
    local upgrade_sql="/c/Install/sqlcl-26.1/sqlcl/bin"
    local latest_sql="/c/Install/sqlcl-latest/sqlcl/bin"

    # Remove both versions from PATH first (clean base)
    PATH=$(echo "$PATH" | sed -E "s|${upgrade_sql}:?||g" | sed -E "s|${latest_sql}:?||g")

    if [[ "$PWD" == */*demo* || "$PWD" == */*26.1* ]]; then
        # In 26.1 upgrade worktree → use upgrade SQLcl
        export PATH="${upgrade_sql}:${PATH}"
    else
        # All other folders → use production SQLcl
        export PATH="${latest_sql}:${PATH}"
    fi
}

# Hook into prompt
PROMPT_COMMAND="update_sql_path${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# Run once at startup
update_sql_path
