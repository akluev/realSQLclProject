# APEX Badge Component

## Overview

Badges display a colored pill with optional icon and text, commonly used for status indicators, labels, and visual categorization in Oracle APEX applications.

The Universal Theme provides a built-in **BADGE template component** (static ID: `BADGE`) that should be used for most badge implementations.

**Demo:** https://oracleapex.com/ords/r/apex_pm/ut/badge-component

---

## Template Directive Approach (Recommended)

Use template directives with `THEME$BADGE` in report columns, template components, or regions. This approach leverages the UT theme's built-in component for cleaner code and better maintainability.

### Basic Syntax

```html
{with/}
    LABEL:=#LABEL_COLUMN#
    VALUE:=#VALUE_COLUMN#
    LABEL_DISPLAY:=N
    ICON:=fa #ICON_COLUMN#
    STYLE:=#COLOR_CLASS_COLUMN#
{apply THEME$BADGE/}
```

### Complete Parameter Reference

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `VALUE` | Yes | Main badge text displayed in the badge | `#STATUS_NAME#` or `Active` |
| `LABEL` | Yes | Label text (can be empty string or same as VALUE if no separate label needed) | `#STATUS_DESCRIPTION#` or `` (empty) |
| `LABEL_DISPLAY` | Yes | Show label? `Y` to show, `N` to hide | `Y` or `N` |
| `ICON` | No | Font APEX icon class(es), always include `fa` prefix | `fa fa-check` or `fa #ICON_COLUMN#` |
| `STYLE` | No | Additional CSS classes for styling (color, alignment, size). **Preferred over STATE** for reusability with other components like charts | `u-success` or `#COLOR_CLASS#` |
| `STATE` | No | Predefined state: `success`, `danger`, `warning`, `info`. **Avoid using** — use `STYLE` instead for consistency across components | `success` (not recommended) |
| `SIZE` | No | Size modifier class | `t-Badge--sm`, `t-Badge--lg` |
| `SHAPE` | No | Shape modifier: `t-Badge--circle`, `t-Badge--square` | `t-Badge--circle` |
| `LINK` | No | URL to make badge clickable (renders `<a>` instead of `<span>`) | `#DETAIL_URL#` or `f?p=&APP_ID.:10:&SESSION.` |
| `LINK_ATTR` | No | Additional HTML attributes for link element | `target="_blank"` or `data-id="#ID#"` |

### Common Usage Patterns

#### Basic Badge with Icon and Color
```html
{with/}
    LABEL:=#JOB_NAME#
    VALUE:=#JOB_NAME#
    LABEL_DISPLAY:=N
    ICON:=fa #JOB_ICON#
    STYLE:=#JOB_COLOR_CLASS#
{apply THEME$BADGE/}
```

#### Badge with Label
```html
{with/}
    LABEL:=Status
    VALUE:=#STATUS_NAME#
    LABEL_DISPLAY:=Y
    STYLE:=u-success
{apply THEME$BADGE/}
```

#### Clickable Badge (Link)
```html
{with/}
    LABEL:=#DEPARTMENT_NAME#
    VALUE:=#DEPARTMENT_NAME#
    LABEL_DISPLAY:=N
    ICON:=fa #DEPT_ICON#
    LINK:=f?p=&APP_ID.:10:&SESSION.::NO::P10_DEPT_ID:#DEPT_ID#
    STYLE:=#DEPT_COLOR_CLASS#
{apply THEME$BADGE/}
```

#### Centered Badge in Report Column
```html
{with/}
    LABEL:=#STATUS_NAME#
    VALUE:=#STATUS_NAME#
    LABEL_DISPLAY:=N
    ICON:=fa #STATUS_ICON#
    STYLE:=t-Badge u-justify-content-center #STATUS_COLOR_CLASS#
{apply THEME$BADGE/}
```

#### Small Badge
```html
{with/}
    LABEL:=#PRIORITY#
    VALUE:=#PRIORITY#
    LABEL_DISPLAY:=N
    SIZE:=t-Badge--sm
    STYLE:=u-danger
{apply THEME$BADGE/}
```

#### Circular Badge (Icon Only)
```html
{with/}
    LABEL:=5
    VALUE:=5
    LABEL_DISPLAY:=N
    SHAPE:=t-Badge--circle
    STYLE:=u-warning
{apply THEME$BADGE/}
```

#### Badge with External Link
```html
{with/}
    LABEL:=View Details
    VALUE:=View Details
    LABEL_DISPLAY:=N
    ICON:=fa fa-external-link
    LINK:=https://example.com
    LINK_ATTR:=target="_blank" rel="noopener"
    STYLE:=u-info
{apply THEME$BADGE/}
```

---

## APEX Column Setup

When using badge template directives in APEX reports or Interactive Grids:

**Column Configuration:**
1. **Column Type**: HTML Expression or Display as Text (based on LOV, does not save state)
2. **Escape special characters**: **YES** (always recommended with template directives)

**Why Escape = YES works with templates:**
- APEX escapes the data values for security
- Template directives generate HTML **after** escaping
- Result: Secure, properly formatted badges

**For complete escaping guidance:** See [apex-html-escaping.md](apex-html-escaping.md) for APEX security best practices.

---

## Direct HTML Approach (Legacy)

For contexts where template directives are not supported (older APEX versions, specific column types, or custom rendering):

**⚠️ Security Warning:** When using direct HTML, you must set **Escape special characters: NO**, which means you're responsible for manually escaping any user-entered content to prevent XSS. This is why template directives are strongly preferred.

### Report Columns (using `#COLUMN#` syntax)

```htmlDirect HTML requires **Escape special characters = NO**, which means you're responsible for manually escaping user content with `apex_escape.html()`. This is why template directives are strongly preferred. See [apex-html-escaping.md](apex-html-escaping.md) for details
<span class="t-Badge #COLOR_CLASS_COLUMN#"
      role="status"
      aria-label="#DESCRIPTION_COLUMN#"
      title="#DESCRIPTION_COLUMN#">
  <span class="t-Badge-icon fa #ICON_COLUMN#" aria-hidden="true"></span>
  <span class="t-Badge-value">#NAME_COLUMN#</span>
</span>
```

### Template Components / Static Regions (using `&ITEM.` syntax)

```html
<span class="t-Badge &COLOR_CLASS_ITEM."
      role="status"
      aria-label="&DESCRIPTION_ITEM."
      title="&DESCRIPTION_ITEM.">
  <span class="t-Badge-icon fa &ICON_ITEM." aria-hidden="true"></span>
  <span class="t-Badge-value">&NAME_ITEM.</span>
</span>
```

### Direct HTML Rules

- Icon classes go directly on the `t-Badge-icon` span: `class="t-Badge-icon fa fa-check"` (not in a nested `<span>`)
- Always add `aria-hidden="true"` to the icon span for accessibility
- Color class can be a utility class: `u-color-N`, `u-success`, `u-danger`, `u-warning`, `u-info`
- Omit the icon span entirely if no icon is needed
- Always include `role="status"` on the badge span for screen readers
- Use `aria-label` and `title` for accessibility and hover tooltips

---

## Styling Options

### Color Classes

**Semantic colors (recommended):**
- `u-success` — Green (for active, completed, approved)
- `u-danger` — Red (for error, inactive, rejected)
- `u-warning` — Orange/Yellow (for pending, caution)
- `u-info` — Blue (for informational)

**Numbered palette:**
- `u-color-1` through `u-color-45` — Full color palette

**Custom classes:**
- Add custom CSS classes in the `STYLE` parameter
- Example: `t-Badge u-justify-content-center u-success`

### Alignment

- `u-justify-content-center` — Center badge in container
- `u-justify-content-start` — Left align
- `u-justify-content-end` — Right align

### Size Modifiers

- `t-Badge--sm` — Small badge
- `t-Badge--lg` — Large badge
- (No modifier) — Default size

### Shape Modifiers

- `t-Badge--circle` — Circular badge (good for counts/icons)
- `t-Badge--square` — Square badge
- (No modifier) — Default pill shape

---

## Best Practices

1. **Use template directives** whenever possible for cleaner code and better maintainability
2. **Always include LABEL and LABEL_DISPLAY** — both are required parameters (use same value as VALUE and set LABEL_DISPLAY:=N if no separate label is needed)
3. **Include icons** from Font APEX to enhance visual communication (see [font-apex-icons.md](font-apex-icons.md))
4. **Use STYLE with utility classes** (`u-success`, `u-danger`, etc.) instead of STATE parameter — this ensures color consistency across components (badges, charts, etc.)
5. **Provide aria-label** when using direct HTML for accessibility
6. **Store visual attributes** (icon, color_class) in database tables for consistency
7. **Avoid STATE parameter** — use `STYLE:=u-success` instead for reusability across different UI components
8. **Keep VALUE text short** — badges are meant for concise labels (1-3 words)
9. **Use LINK for navigation** — make badges clickable when they represent actionable items
10. **Avoid nesting badges** — they are standalone components
11. **Test responsive behavior** — ensure badges work well on mobile devices

---

## Database Schema Pattern

Store visual attributes in your reference tables:

```sql
create table demo1.status (
    status_id    number generated by default on null as identity,
    status_name  varchar2(50 byte) not null,
    icon         varchar2(100 byte),  -- e.g., 'fa-check'
    color_class  varchar2(50 byte),   -- e.g., 'u-success'
    description  varchar2(500 byte),
    constraint status_pk primary key (status_id)
);
```

Then reference in your badge query:
```html
{with/}
    LABEL:=#STATUS_NAME#
    VALUE:=#STATUS_NAME#
    LABEL_DISPLAY:=N
    ICON:=fa #ICON#
    STYLE:=#COLOR_CLASS#
{apply THEME$BADGE/}
```

---

## Technical Implementation Details

### Generated HTML Structure

The `THEME$BADGE` template generates this HTML:

```html
<span class="t-Badge [modifiers]" role="status" aria-label="[label] [value]" title="[label] [value]">
  <span class="t-Badge-icon [icon-classes]" aria-hidden="true"></span>
  <span class="t-Badge-label">[label-text]</span>
  <span class="t-Badge-value">[value-text]</span>
</span>
```

Or if `LINK` is provided:
```html
<a href="[link]" [link-attr] class="t-Badge [modifiers]" role="status" aria-label="[label] [value]" title="[label] [value]">
  <span class="t-Badge-icon [icon-classes]" aria-hidden="true"></span>
  <span class="t-Badge-label">[label-text]</span>
  <span class="t-Badge-value">[value-text]</span>
</a>
```

### CSS Variables

Badges respect these Universal Theme CSS variables:
- `--ut-component-badge-background-color`
- `--ut-component-badge-text-color`
- `--ut-component-badge-border-radius`

See [apex-css-vars.md](apex-css-vars.md) for the complete list.

---

## Troubleshooting

### Badge doesn't render
- Check that the column type supports HTML expression/Display HTML
- Verify template directives are supported in your APEX version (24.1+)
- Try direct HTML approach if template directives fail

### Icon doesn't appear
- Ensure `fa` prefix is included: `fa fa-check` not just `fa-check`
- Verify icon name exists in Font APEX (see [font-apex-icons.md](font-apex-icons.md))
- Check for typos in icon column data

### Colors not working
- Verify color class format: `u-success` not `success`
- Check if custom color classes need additional CSS
- Ensure STYLE parameter includes `t-Badge` base class if using modifiers

### Link not clickable
- Verify LINK parameter contains valid URL
- Check that link isn't blocked by other page elements
- Test with simple hardcoded URL first: `LINK:=https://example.com`

---

## Related Documentation

- [font-apex-icons.md](font-apex-icons.md) — Complete Font APEX icon reference
- [apex-utility-classes.md](apex-utility-classes.md) — UT utility classes for styling
- [apex-css-vars.md](apex-css-vars.md) — CSS variables for theming
- Universal Theme Sample App: https://oracleapex.com/ords/apex_pm/r/ut/getting-started
