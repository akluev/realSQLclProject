# APEX HTML Escaping and Security

## Overview

Oracle APEX provides the **"Escape special characters"** column property to prevent Cross-Site Scripting (XSS) attacks. Understanding when to use this setting is critical for application security.

---

## The "Escape special characters" Property

### What It Does

When set to **YES**, APEX automatically escapes HTML special characters in query result values **before** any template processing:
- `<` becomes `&lt;`
- `>` becomes `&gt;`
- `&` becomes `&amp;`
- `"` becomes `&quot;`
- `'` becomes `&#x27;`

This prevents user-entered content like `<script>alert('XSS')</script>` from being executed as HTML/JavaScript.

### Default Recommendation

**Always set "Escape special characters" to YES unless you have a specific, valid reason not to.**

---

## When to Use Each Setting

### Escape = YES (Recommended Default)

✅ **Use when:**
- Displaying user-entered data (names, descriptions, comments, etc.)
- Using template directives like `{apply THEME$BADGE/}`, `{apply THEME$BUTTON/}`
- Query returns pure data values, not HTML markup
- You want APEX to handle escaping automatically

✅ **Security benefit:**
- Protects against XSS attacks
- APEX escapes data values, but template directives still generate proper HTML
- No manual escaping needed

✅ **Example (badge with template):**
```sql
-- Query returns data values
select job_name, icon, color from job

-- Column expression uses template directive
{with/}
    LABEL:=#JOB_NAME#
    VALUE:=#JOB_NAME#
    LABEL_DISPLAY:=N
    ICON:=fa #ICON#
    STYLE:=#COLOR#
{apply THEME$BADGE/}
```
**Setting:** Escape special characters = **YES**
**Result:** `#JOB_NAME#` values are escaped, template generates safe HTML structure

### Escape = NO (Use with Extreme Caution)

⚠️ **Only use when:**
- Query produces **safe, validated HTML** that you want to render as-is
- Using legacy direct HTML approach (pre-template directives)
- Complex HTML calculated on the server that cannot use templates
- You are **100% certain** the HTML is safe (not from user input)

⚠️ **Security risk:**
- You are responsible for manual escaping of any user content
- One mistake can create an XSS vulnerability
- Should be a rare exception, not the norm

⚠️ **Example (server-calculated HTML):**
```sql
-- PL/SQL function returns pre-built, safe HTML
select generate_complex_chart_html(data_id) as chart_html
  from my_data
```
**Setting:** Escape special characters = **NO**
**Requirement:** The `generate_complex_chart_html` function must escape all user data with `apex_escape.html()`

---

## Common Misconceptions

### ❌ Misconception: "I need to call apex_escape.html() in my queries"
**Reality:** If "Escape special characters" = YES, APEX handles escaping automatically. Manual escaping is only needed when Escape = NO.

### ❌ Misconception: "Template directives need Escape = NO to work"
**Reality:** Template directives work WITH Escape = YES. They generate HTML **after** value escaping, keeping both functionality and security.

### ❌ Misconception: "Escaping breaks my HTML column formatting"
**Reality:** If you're storing HTML in your database column to achieve formatting, you're doing it wrong. Use template directives or APEX components instead.

---

## Best Practices

### 1. Separate Data from Presentation

**❌ Bad approach (HTML in database):**
```sql
-- Storing HTML in database column
update job set display_html = '<span class="badge">' || job_name || '</span>';

-- Requires Escape = NO (security risk)
select display_html from job
```

**✅ Good approach (data + template):**
```sql
-- Store only data
select job_name, icon, color from job

-- Use template directive for presentation (Escape = YES)
{with/}
    VALUE:=#JOB_NAME#
    ICON:=fa #ICON#
    STYLE:=#COLOR#
{apply THEME$BADGE/}
```

### 2. Use APEX_ESCAPE When Building Server-Side HTML

If you must build HTML server-side (complex calculations, legacy code), use `apex_escape.html()`:

```sql
create or replace function build_custom_html(p_user_name varchar2)
return varchar2 is
begin
    return '<div class="user-card">' ||
           '<h3>' || apex_escape.html(p_user_name) || '</h3>' ||
           '</div>';
end;
```

### 3. Audit Your Escape = NO Columns

Periodically review all columns with Escape = NO:
```sql
-- Find columns with escaping disabled (requires APEX data dictionary access)
select application_id, page_id, region_name, column_name
  from apex_application_page_ir_col
 where escape_special_chars = 'N'
 order by application_id, page_id;
```

Each one is a potential security risk - validate that it's necessary.

### 4. Educate Your Team

**Key message:** "Escape special characters = YES" should be the default mindset. Setting it to NO requires justification and security review.

---

## Template Directives and Escaping

### How It Works

1. Query returns data: `job_name = 'Manager <CEO>'`
2. APEX escapes (if Escape = YES): `'Manager &lt;CEO&gt;'`
3. Template directive processes: `{with/} VALUE:=#JOB_NAME# {apply THEME$BADGE/}`
4. Template generates HTML: `<span class="t-Badge-value">Manager &lt;CEO&gt;</span>`
5. Browser displays: "Manager <CEO>" (safe, no script execution)

### Why This is Secure

- User content is escaped (step 2)
- Template generates trusted HTML structure (step 4)
- Result: Data is safe, HTML structure is intact

### Supported Template Directives

All APEX template directives work with Escape = YES:
- `{apply THEME$BADGE/}`
- `{apply THEME$BUTTON/}`
- `{apply THEME$ICON/}`
- `{apply THEME$LINK/}`
- Custom component plugins that follow APEX patterns

---

## Migration Path: Direct HTML → Templates

If you have legacy columns using direct HTML with Escape = NO:

### Before (Escape = NO required)
```sql
select '<span class="t-Badge ' || color || '">' ||
       '<span class="t-Badge-icon fa ' || icon || '"></span>' ||
       '<span class="t-Badge-value">' || job_name || '</span>' ||
       '</span>' as job_badge
  from job
```
**Setting:** Escape = NO (required, or HTML appears as text)
**Risk:** If `job_name`, `icon`, or `color` contain user input, XSS vulnerability

### After (Escape = YES, secure)
```sql
select job_name, icon, color from job
```
```html
{with/}
    LABEL:=#JOB_NAME#
    VALUE:=#JOB_NAME#
    LABEL_DISPLAY:=N
    ICON:=fa #ICON#
    STYLE:=#COLOR#
{apply THEME$BADGE/}
```
**Setting:** Escape = YES (secure)
**Benefit:** Cleaner SQL, secure by default, maintainable

---

## Security Checklist

When reviewing APEX applications for XSS vulnerabilities:

- [ ] All user-entered data columns have Escape = YES
- [ ] Columns with Escape = NO have documented justification
- [ ] Server-side HTML generation uses `apex_escape.html()`
- [ ] Template directives used instead of SQL-generated HTML where possible
- [ ] No SQL concatenation of user data into HTML strings
- [ ] Regular audits of Escape = NO columns
- [ ] Team training on escape settings completed

---

## Additional Resources

- **APEX Security Best Practices:** https://apex.oracle.com/go/security-best-practices
- **Template Directives Documentation:** APEX Application Builder > Shared Components > Component Settings
- **APEX_ESCAPE Package:** https://docs.oracle.com/en/database/oracle/apex/latest/aeapi/APEX_ESCAPE.html

---

## Related Documentation

- [apex-badges.md](apex-badges.md) - Badge component patterns (uses Escape = YES)
- [apex-utility-classes.md](apex-utility-classes.md) - UT styling classes
- Universal Theme Sample App: https://oracleapex.com/ords/apex_pm/r/ut/getting-started
