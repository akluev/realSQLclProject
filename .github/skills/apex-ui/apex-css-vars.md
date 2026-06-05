---
name: apex-css-vars
description: Returns Oracle APEX CSS custom properties (variables) for styling components
---

When asked about APEX CSS variables or when styling APEX components, return the relevant CSS variables from the data below.

> **Source:** Scraped from the official APEX Universal Theme CSS Variables page:  
> https://oracleapex.com/ords/r/apex_pm/ut/css-variables  
> **Last updated:** June 2, 2026 (APEX 26.1)  
> **⚠️ Do NOT invent variable names.** If a var is not listed here, it does not exist. Common false positives: `--ut-palette-neutral` (does NOT exist), `--ut-palette-*-text` (do NOT exist).
>
> **APEX 26.1 additions:** `--ut-region-body-padding-x`, `--ut-region-body-padding-y` (new region body padding vars). All other variables are unchanged from APEX 24.2.

> **To refresh this list when APEX is upgraded**, use the `/refresh-apex-css-vars` prompt.

## Usage

Use these CSS variables with `var(--variable-name)` in your CSS. For example:

```css
.my-component {
  background-color: var(--ut-component-background-color);
  color: var(--ut-component-text-default-color);
  border-radius: var(--ut-component-border-radius);
}
```

## Available CSS Variables

### Color Palette (`--u-color-N`)

Numbered palette of 45 colors. Each has a base and a contrast version.

```
--u-color-1   --u-color-1-contrast
--u-color-2   --u-color-2-contrast
--u-color-3   --u-color-3-contrast
--u-color-4   --u-color-4-contrast
--u-color-5   --u-color-5-contrast
--u-color-6   --u-color-6-contrast
--u-color-7   --u-color-7-contrast
--u-color-8   --u-color-8-contrast
--u-color-9   --u-color-9-contrast
--u-color-10  --u-color-10-contrast
--u-color-11  --u-color-11-contrast
--u-color-12  --u-color-12-contrast
--u-color-13  --u-color-13-contrast
--u-color-14  --u-color-14-contrast
--u-color-15  --u-color-15-contrast   ← neutral gray (used for Canceled status)
--u-color-16  --u-color-16-contrast
--u-color-17  --u-color-17-contrast
--u-color-18  --u-color-18-contrast
--u-color-19  --u-color-19-contrast
--u-color-20  --u-color-20-contrast
--u-color-21  --u-color-21-contrast
--u-color-22  --u-color-22-contrast
--u-color-23  --u-color-23-contrast
--u-color-24  --u-color-24-contrast
--u-color-25  --u-color-25-contrast
--u-color-26  --u-color-26-contrast
--u-color-27  --u-color-27-contrast
--u-color-28  --u-color-28-contrast
--u-color-29  --u-color-29-contrast
--u-color-30  --u-color-30-contrast
--u-color-31  --u-color-31-contrast
--u-color-32  --u-color-32-contrast
--u-color-33  --u-color-33-contrast
--u-color-34  --u-color-34-contrast
--u-color-35  --u-color-35-contrast
--u-color-36  --u-color-36-contrast
--u-color-37  --u-color-37-contrast
--u-color-38  --u-color-38-contrast
--u-color-39  --u-color-39-contrast
--u-color-40  --u-color-40-contrast
--u-color-41  --u-color-41-contrast
--u-color-42  --u-color-42-contrast
--u-color-43  --u-color-43-contrast
--u-color-44  --u-color-44-contrast
--u-color-45  --u-color-45-contrast
```

### Stateful / Semantic Colors (`--ut-palette-*`)

Each semantic color has exactly **three variants**: base, `-contrast`, `-shade`.  
**There is NO `-text` variant and NO `--ut-palette-neutral`.**

```
--ut-palette-primary          --ut-palette-primary-contrast    --ut-palette-primary-shade
--ut-palette-danger           --ut-palette-danger-contrast     --ut-palette-danger-shade
--ut-palette-warning          --ut-palette-warning-contrast    --ut-palette-warning-shade
--ut-palette-success          --ut-palette-success-contrast    --ut-palette-success-shade
--ut-palette-info             --ut-palette-info-contrast       --ut-palette-info-shade
```

### Component Variables (`--ut-component-*`)

| Variable | Description | Default |
|---|---|---|
| `--ut-component-background-color` | Component Background Color | `#fff` |
| `--ut-component-border-color` | Component Border Color | `rgba(0,0,0,.1)` |
| `--ut-component-border-width` | Component Border Width | `1px` |
| `--ut-component-border-radius` | Component Border Radius | `2px` |
| `--ut-component-box-shadow` | Component Shadow | `var(--ut-shadow-lg)` |
| `--ut-component-highlight-background-color` | Highlight Background (hover state) | `rgba(0,0,0,.025)` |
| `--ut-component-toolbar-background-color` | Toolbar Background Color | `rgba(0,0,0,.025)` |
| `--ut-component-inner-border-width` | Inner Border Width | `1px` |
| `--ut-component-inner-border-color` | Inner Border Color | `rgba(0,0,0,0.05)` |
| `--ut-component-text-default-color` | Default Text Color | `#000` |
| `--ut-component-text-title-color` | Title Text Color | `#000` |
| `--ut-component-text-subtitle-color` | Subtitle Text Color | `rgba(0,0,0,.85)` |
| `--ut-component-text-muted-color` | Muted Text Color (descriptions) | `rgba(0,0,0,.65)` |
| `--ut-component-icon-background-color` | Icon Background Color | `var(--ut-palette-primary)` |
| `--ut-component-icon-color` | Icon Color | `var(--ut-palette-primary-contrast)` |
| `--ut-component-badge-background-color` | Badge Background Color | `rgba(0,0,0,.05)` |
| `--ut-component-badge-text-color` | Badge Text Color | `var(--ut-component-text-default-color)` |
| `--ut-component-badge-border-radius` | Badge Border Radius | `2px` |

### Shadow Variables (`--ut-shadow-*`)

| Variable | Description | Default |
|---|---|---|
| `--ut-shadow-sm` | Shadow Small | `0 2px 4px -2px rgba(0,0,0,0.1)` |
| `--ut-shadow-md` | Shadow Medium | `0 12px 24px -12px rgba(0,0,0,0.3)` |
| `--ut-shadow-lg` | Shadow Large | `0 24px 48px -24px rgba(0,0,0,0.3)` |

### Region Body Padding Variables (`--ut-region-body-padding-*`) — NEW in APEX 26.1

> **Added in APEX 26.1.** Do not use these on APEX 24.2 or below — they will have no effect.

| Variable | Description |
|---|---|
| `--ut-region-body-padding-x` | Horizontal (left/right) padding inside region body content area |
| `--ut-region-body-padding-y` | Vertical (top/bottom) padding inside region body content area |

Use these to override region body spacing without touching the component border or header:
```css
.my-region .t-Region-body {
  --ut-region-body-padding-x: 1rem;
  --ut-region-body-padding-y: 0.5rem;
}
```

## Neutral / Gray Fallback

When you need a neutral color (e.g. for an uncategorized item, a disabled state, or a fallback when no semantic color applies), use:

- **`--u-color-15`** — the Vita neutral gray. This is the same color APEX uses for the "Canceled" timeline status. Prefer this over inventing non-existent variable names.
- `--ut-component-badge-background-color` (`rgba(0,0,0,.05)`) — for a very subtle tint on a white background.

## Categories

### Color Palette

Variables starting with `--u-color-` provide numbered colors (1–45) with matching contrast colors. Use these for category badges, chart series colors, and any decorative UI element where a specific brand or category color is needed. The APEX Theme Roller maps these to actual hex values per theme style.

### Semantic Colors

Variables with `--ut-palette-` prefix provide semantic meaning:

- **primary** — Main brand/action color
- **danger** — Error/destructive actions (red tones)
- **warning** — Caution/attention (amber/yellow tones)
- **success** — Positive/confirmation (green tones)
- **info** — Informational (blue tones)

Each semantic color has exactly three variants: base, `-contrast` (readable text on that color), `-shade` (a lighter tint for backgrounds). There is **no** `-text` variant.

### Component Styles

Variables with `--ut-component-` prefix are used by the Universal Theme as base styles across all components. Plugin developers should hook into these to stay consistent with the active Theme Style. They cover backgrounds, borders, text hierarchy (default → title → subtitle → muted), icons, badges, and shadows.

### Shadows

`--ut-shadow-sm`, `--ut-shadow-md`, `--ut-shadow-lg` provide consistent elevation levels. Cards typically use `--ut-shadow-lg`.

### Region Body Padding (APEX 26.1+)

`--ut-region-body-padding-x` and `--ut-region-body-padding-y` control horizontal and vertical padding inside region body content areas. Use on APEX 26.1+ only.

### Typography

Typography CSS variables (font families etc.) are not part of the official CSS Variables page and should not be referenced from this file. Use standard CSS font stacks or the Theme Roller's font settings instead.