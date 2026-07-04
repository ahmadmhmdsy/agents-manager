# Prompts · scaffolding a new docs site

> LLM-actionable prompt for generating a new docs site from this template.
> Paste into your assistant as-is; replace `<...>` placeholders.

---

You are scaffolding a new **docs site** from the `templates/docs-site/` template.

## Inputs

- Product name: `<name>`
- One-line description: `<one-line>`
- Page taxonomy (groups → pages):
  - `<group 1>`
    - `<page 1.1>`
    - `<page 1.2>`
  - `<group 2>`
    - `<page 2.1>`
- Brand colour (optional): `<#hex for --accent>`
- Edit-on-GitHub URL (optional): `<https://github.com/.../edit/main/docs/>`

## What to produce

1. A populated `skeleton/data.js` whose `PAGES` array contains **one entry per
   page in the taxonomy**, with `id`, `title`, `group`, `order`, `summary`,
   `body`. Use the schema in `memory/02-content-shape.md`.
2. Each page's `body` opens with `# <page title>` (single h1), then 3-6
   sections of real Markdown content following `03-markdown-rendering.md`
   supported syntax. Include at least one ``\`\`\`<lang>\`\`\`` code block per
   reference page.
3. A brand override on `skeleton/index.html` `:root` and
   `:root[data-theme="dark"]` blocks — only `--accent` and `--accent-soft`
   unless the brand demands surface changes. See `memory/07-theming.md` and
   `memory/11-dark-theme.md`.
4. The `<title>` tag updated to `<Product> · docs`.
5. The `meta[name="description"]` filled with the one-line description.
6. The `Edit on GitHub` `<a href>` set to the provided URL.

## What NOT to do

- Do NOT add a new `--token:` CSS custom property. Brand work is overriding
  **values**, not introducing names.
- Do NOT add a syntax-highlighting library. `memory/04-code-blocks.md` rule
  applies; markup colour spans manually only.
- Do NOT replace `<details>` with a custom sidebar that needs JS to open.
  `memory/05-navigation-and-sidebar.md` rule applies.
- Do NOT change `data-section` values or add a new one. `tests/verify.sh` T1
  will fail.
- Do NOT skip the rule that every page has exactly one `# Title` line.
  `memory/10-screen-reader-a11y.md` rule 1.

## Verify

After editing, run from `templates/docs-site/`:

```sh
$ bash tests/verify.sh
```

All eight tests must exit 0. If T1 fails, the section count changed; restore
to six (`app-shell`, `topbar`, `sidebar-nav`, `main`, `toc-aside`, `footer`).
