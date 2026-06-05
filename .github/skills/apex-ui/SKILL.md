---
name: apex-ui
description: Helps AI Coding agents to create Oracle APEX UI components, including HTML structure, CSS styling, and JavaScript behavior, following best practices for responsive design and accessibility and using the built-in APEX utility classes and CSS variables.
---

This skill provides guidelines and best practices for creating Oracle APEX UI components, including HTML structure, CSS styling, and JavaScript behavior. It emphasizes responsive design, accessibility, and the use of built-in APEX utility classes and CSS variables.

When asked to create an APEX UI component, use the files below to incorporate the built-in APEX utility classes and CSS variables for consistent styling and behavior. Also take advantage of the APEX grid system for responsive layouts and Font APEX for any iconography needed.

Files to use:
- `apex-badges.md` for badge component implementation patterns (template directives and direct HTML)
- `apex-select-items.md` for Select One and Select Many item types — modern LOV-based items with Value HTML Expression support for rendering icons, colors, and badges in dropdowns
- `apex-html-escaping.md` for APEX HTML escaping and XSS prevention best practices
- `apex-css-vars.md` for available CSS variables to style components
- `apex-utility-classes.md` for utility classes to apply common styles and behaviors
- `font-apex-icons.md` for the complete list of 1,489 available Font APEX icons (with categories and search hints from database)
- Font APEX Icons browser: https://oracleapex.com/ords/r/apex_pm/ut/icons

> **Maintenance tasks** (run only when a new APEX version is released — never during normal development):
> use prompt `/refresh-apex-icons` to update the icon list, or `/refresh-apex-css-vars` to update the CSS variable list.

On top of these files, use the Universal Theme sample app as a reference for best practices in HTML structure, CSS styling, and responsive design: https://oracleapex.com/ords/apex_pm/r/ut/getting-started

When creating the HTML structure of the component, use semantic elements to improve accessibility and SEO. For styling, use external stylesheets and avoid inline styles. Ensure the component is responsive by using media queries and flexible layouts. Prioritize accessibility by using ARIA roles and attributes where appropriate.