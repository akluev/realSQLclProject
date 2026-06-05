# APEX Select One & Select Many Item Types

## Overview

**Select One** and **Select Many** are modern APEX 24.2 item types that provide a more user-friendly selection experience compared to classic Select List and Popup LOV. They support **search filtering**, **groups**, and most importantly **Value HTML Expression** with template directives — enabling rich rendering of each option with icons, colors, badges, and custom HTML.

**Source:** [Oracle APEX 24.2 — About Item Types](https://docs.oracle.com/en/database/oracle/apex/24.2/htmdb/about-item-types.html#GUID-230136D4-2798-4CD0-910D-BEEE26C9DC41)

---

## Select One

Displays as an item with a list of values icon which supports the **selection of one value** and search filtering. When the end user clicks the field, a popup window appears with a list of suggested values.

**When to use over Select List:**
- When you want search/filtering in the dropdown
- When you need **Value HTML Expression** to render rich options (icons, colors, badges)
- When you want a more modern, user-friendly UI than a plain `<select>` element

**When to use Select List instead:**
- For very small lists (2-5 items) where inline display is faster
- When no custom rendering is needed

### Key Settings

| Setting | Description |
|---|---|
| **Maximum Values in List** | Max options to display (default 250). Helps performance for large LOVs |
| **Fetch on Search** | If enabled, fetches matching values from DB as user types. Recommended for large lists |
| **Value HTML Expression** | HTML/template directives to customize how each option renders (see below) |
| **Match Type** | `Contains` or `Starts With`. Contains prevents column index usage |
| **Case-Sensitive** | Controls if search is case-sensitive |
| **Minimum Characters** | Min characters before search executes |

### LOV Requirement

A List of Values (LOV) is required. The LOV query must return at minimum a display column and a return column. Additional columns can be included and referenced in the **Value HTML Expression**.

---

## Select Many

Displays a drop-down list that supports **multi-select** and search filtering. Functionally similar to Select One but allows selecting multiple values.

**When to use:**
- When a field stores multiple values (e.g., tags, roles, categories)
- When you need rich option rendering with multiple selections
- As a modern replacement for Checkbox Group or Shuttle for LOV-based multi-select

### Additional Settings (beyond Select One)

| Setting | Description |
|---|---|
| **Display Values As** | How selected values appear when not focused: **Chips** or **Comma-separated list** (only when Use Defaults is Off) |
| **Multiple Values, Type** | Whether source column contains multiple values and encoding (No, Delimited List, JSON Array) |
| **Multiple Values, Separator** | Character separating multiple values |

---

## Value HTML Expression (Key Feature)

The **Value HTML Expression** setting is what makes Select One and Select Many powerful. It defines how each option in the dropdown is rendered using HTML and [template directives](https://docs.oracle.com/en/database/oracle/apex/24.2/htmdb/using-template-directives.html).

This allows showing **icons**, **colors**, **badges**, and **custom layouts** directly in the selection dropdown.

### How It Works

1. A Shared Component LOV defines extra columns as **Additional Display Columns**
2. The Value HTML Expression references those columns by name: `&ICON_CLASS.`, `&COLOR_CLASS.`
3. Each option in the dropdown renders using that HTML template

> **Substitution variables depend on LOV type:**
> | LOV Type | Display/Return | Extra Columns |
> |---|---|---|
> | **Shared Component** (recommended) | `&APEX$ITEM%d.` (display), `&APEX$ITEM%r.` (return) | All columns listed as **Additional Display Columns** in the LOV definition are accessible by alias: `&ICON_CLASS.`, `&COLOR_CLASS.`, etc. |
> | **Inline SQL** (SQL Query defined directly on the item) | `&APEX$ITEM%d.` (display), `&APEX$ITEM%r.` (return) | **Not accessible** — extra columns in the query cannot be referenced by name |
>
> **Conclusion:** Use a **Shared Component LOV** when the Value HTML Expression needs to reference icon, color, or any other metadata column. Inline SQL is only useful when just the display and return values are needed.

### LOV Query Pattern

For a Shared Component LOV, include the extra metadata columns in the query and register them as **Additional Display Columns** in the LOV definition:

```sql
-- Shared LOV: JOB_LOV (with Additional Display Columns: ICON_CLASS, COLOR_CLASS)
select job_name   as d,
       job_id     as r,
       icon_class,
       color_class
  from job
 order by job_name
```

**Column Mapping:**
- **Display Column:** `D` (shown as text when item is not focused)
- **Return Column:** `R` (stored value)
- **Additional Display Columns:** `ICON_CLASS`, `COLOR_CLASS` — must be listed in the LOV's Additional Display Columns setting to be accessible in Value HTML Expression

### Basic Value HTML Expression Examples

> All examples below assume a **Shared Component LOV** with `ICON_CLASS` and `COLOR_CLASS` defined as Additional Display Columns. For inline SQL LOVs, only `&APEX$ITEM%d.` and `&APEX$ITEM%r.` are available.

#### Icon + Text
```html
<span class="fa &ICON_CLASS." aria-hidden="true"></span> &APEX$ITEM%d.
```

#### Icon + Text with Color
```html
<span class="&COLOR_CLASS.">
    <span class="fa &ICON_CLASS." aria-hidden="true"></span> &APEX$ITEM%d.
</span>
```

#### Badge in Dropdown

> **Known issue in APEX 24.2:** The `{with/}...{apply THEME$BADGE/}` template directive syntax **does not work** in a Value HTML Expression for Select One / Select Many. Use the direct HTML badge structure below instead. Check whether a future APEX version resolves this before switching to template directives.

Template directive syntax (reference — works in report columns, but **not** in Value HTML Expression in APEX 24.2):

```html
{with/}
    LABEL:=&APEX$ITEM%d.
    VALUE:=&APEX$ITEM%d.
    LABEL_DISPLAY:=N
    ICON:=fa &ICON_CLASS.
    STYLE:=&COLOR_CLASS.
{apply THEME$BADGE/}
```

Direct HTML badge syntax — **use this for Value HTML Expression** (Shared Component LOV with Additional Display Columns):

```html
<span class="t-Badge &COLOR_CLASS." role="status" aria-label="&APEX$ITEM%d." title="&APEX$ITEM%d.">
  <span class="t-Badge-icon fa &ICON_CLASS." aria-hidden="true"></span>
  <span class="t-Badge-value">&APEX$ITEM%d.</span>
</span>
```

Direct HTML badge syntax — Inline SQL LOV (display/return only, no extra columns):

```html
<span class="t-Badge" role="status" aria-label="&APEX$ITEM%d." title="&APEX$ITEM%d.">
  <span class="t-Badge-value">&APEX$ITEM%d.</span>
</span>
```

#### Conditional Icon (only show if present, Shared Component LOV)
```html
{if ?ICON_CLASS/}<span class="fa &ICON_CLASS." aria-hidden="true"></span> {endif/}&APEX$ITEM%d.
```

---

## Complete Setup Checklist

### Step 1: Prepare the Shared LOV

Create a Shared Component LOV with the metadata columns. After creating the LOV query, go to the LOV definition and add `ICON_CLASS` and `COLOR_CLASS` to the **Additional Display Columns** list — this is required for them to be accessible in the Value HTML Expression.

```sql
-- Shared LOV: JOB_LOV
select job_name   as d,
       job_id     as r,
       icon_class,
       color_class
  from job
 order by job_name
```

```sql
-- Shared LOV: DEPT_LOV
select dname       as d,
       deptno      as r,
       icon_class,
       color_class
  from dept
 order by dname
```

> **Critical:** In the Shared LOV definition, set **Additional Display Columns** to include `ICON_CLASS` and `COLOR_CLASS`. Without this, those columns will not be passed to the Value HTML Expression.

### Step 2: Configure the Page Item

In Page Designer:

1. **Item Type:** Select One (single value) or Select Many (multiple values)
2. **List of Values:**
   - **Type:** Shared Component (**recommended** — required for icon/color in Value HTML Expression)
   - **LOV:** Select the shared LOV created in Step 1
   - **Display Extra Values:** Yes
   - **Display Null Value:** Yes (for optional fields)
   - **Null Display Value:** `- Select -`
3. **Settings:**
   - **Value HTML Expression:** (see examples above)
   - **Fetch on Search:** Yes (for large lists)
   - **Maximum Values in List:** 250 (default, adjust as needed)
4. **Source:**
   - **Column:** The FK column (e.g., `JOB_ID`, `DEPTNO`)
   - **Data Type:** NUMBER

### Step 3: Set Value HTML Expression

> **Substitution syntax:**
> - `&APEX$ITEM%d.` — display value (works with both Shared Component and Inline SQL)
> - `&APEX$ITEM%r.` — return value (works with both Shared Component and Inline SQL)
> - `&ICON_CLASS.`, `&COLOR_CLASS.` etc. — **Shared Component LOV only**, columns must be listed in Additional Display Columns

For items with a **Shared Component LOV** with `ICON_CLASS` and `COLOR_CLASS` as Additional Display Columns:

```html
<span class="fa &ICON_CLASS." aria-hidden="true" style="margin-right:4px;"></span> &APEX$ITEM%d.
```

Or with color styling:

```html
<span class="&COLOR_CLASS." style="display:inline-flex;align-items:center;gap:4px;">
    <span class="fa &ICON_CLASS." aria-hidden="true"></span>
    <span>&APEX$ITEM%d.</span>
</span>
```

For items with an **Inline SQL LOV** (display/return only, no extra columns):

```html
&APEX$ITEM%d.
```

Or as a badge (direct HTML — template directives do not work in APEX 24.2, no icon/color available for inline SQL):

```html
<span class="t-Badge" role="status" aria-label="&APEX$ITEM%d." title="&APEX$ITEM%d.">
  <span class="t-Badge-value">&APEX$ITEM%d.</span>
</span>
```

---

## Comparison: Select Item Types

| Feature | Select List | Select One | Select Many | Popup LOV | Combobox |
|---|---|---|---|---|---|
| **Selection** | Single | Single | Multiple | Single/Multi | Single/Multi |
| **Search/Filter** | No | Yes | Yes | Yes | Yes |
| **Value HTML Expression** | No | Yes | Yes | No | Yes |
| **Groups** | No | Yes | Yes | No | No |
| **Free Text Input** | No | No | No | Optional | Yes |
| **Fetch on Search** | No | Yes | Yes | Yes | Yes |
| **Best For** | Small lists, simple selection | Medium lists with rich display | Multi-value with rich display | Large lists | Lists allowing custom entries |
| **Rendering** | Native `<select>` | Custom popup | Custom popup with chips | Popup dialog | Text + dropdown |

### Recommendations

- **Use Select One** when you want a single-value picker with icon/color rendering in the dropdown
- **Use Select Many** when you need multi-value selection with the same rich rendering
- **Use Select List** only for very small lists (2-5 items) where no custom rendering is needed
- **Use Popup LOV** for very large lists where free-text search is critical but HTML rendering is not needed
- **Use Combobox** when users need to enter values not in the LOV

---

## Integration with Lookup Table Metadata

When lookup tables store `color_class` and `icon_class` columns, Select One/Many items can display those visuals directly in the selection dropdown.

### Pattern: LOV with Visual Metadata

```sql
-- LOV query for a lookup table with visual metadata
select display_name  as d,
       id            as r,
       icon_class,
       color_class
  from my_lookup_table
 order by display_name
```

### Value HTML Expression for Visual LOV

> Requires the LOV to be a **Shared Component** with `ICON_CLASS` and `COLOR_CLASS` listed as **Additional Display Columns**.

```html
<span class="&COLOR_CLASS." style="display:inline-flex;align-items:center;gap:4px;">
    <span class="fa &ICON_CLASS." aria-hidden="true"></span>
    <span>&APEX$ITEM%d.</span>
</span>
```

This renders each dropdown option with:
- The Font APEX icon from `icon_class` (e.g., `fa-briefcase`)
- The color from `color_class` (e.g., `u-color-5`)
- The display text

---

## Cascading Select One / Select Many

Select One and Select Many support cascading LOVs, just like Select List and Popup LOV.

To create a cascading pair:

1. Set **Cascading LOV Parent Item(s)** on the child item
2. Reference the parent item in the child LOV query using bind syntax:

```sql
select city_name as d,
       city_id   as r
  from cities
 where country_id = :P1_COUNTRY_ID
 order by city_name
```

See: [Creating a Cascading List of Values](https://docs.oracle.com/en/database/oracle/apex/24.2/htmdb/creating-cascading-list-of-values.html)

---

## Notes and Best Practices

1. **Use `aria-hidden="true"`** on icon spans for accessibility
2. **Fetch on Search = Yes** is recommended for lists larger than ~50 items
3. **Template directives do not work in APEX 24.2** for Value HTML Expression in Select One / Select Many — use direct HTML badge structure (see examples above). Refer to [apex-badges.md](apex-badges.md) for the direct HTML badge pattern.
4. **Substitution syntax:** `&APEX$ITEM%d.` = display value, `&APEX$ITEM%r.` = return value — these work for both Shared Component and Inline SQL LOVs. Additional column aliases (e.g., `&ICON_CLASS.`) are **only available for Shared Component LOVs** where those columns are listed as Additional Display Columns.
5. **Use a Shared Component LOV** (not inline SQL) when the Value HTML Expression needs to reference icon, color, or any metadata column. Inline SQL LOVs only expose display and return values.
6. **Extra columns** beyond display and return are accessible in the Value HTML Expression (for inline SQL LOVs) but are not stored — only the return value is saved to session state
7. **Select One replaces Select List** as the preferred choice for most single-value LOV items in APEX 24.2 when rich rendering is desired
8. **Use Defaults** setting controls whether the item uses application-level Component Settings or custom settings
