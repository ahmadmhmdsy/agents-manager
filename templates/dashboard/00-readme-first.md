# dashboard — Task Template v0.1.0

**Read this file first.** This is the human orientation for the dashboard template.

A vendor-neutral task template for building a multi-section internal-tooling
dashboard: sortable data tables, faceted filters, forms with field-level
validation, a metrics row, dark-theme tokens, and an empty-state pattern.
Hash-routed, single-HTML-file, framework-free.

## What works out of the box

- **`memory/`** — 12 prose contracts governing how `am-research` / `am-planning` /
  `am-coder` / `am-review` approach a dashboard task. Each file is a soft rule,
  not a hard constraint — adapt per project.
- **`skeleton/`** — a reference implementation (~600 lines, vanilla HTML/CSS/JS)
  showing the engine wired up: hash routing, sortable table, faceted filter,
  form validation, focus management, dark-theme toggle.
- **`prompts/`** — copy-paste prompt for code-gen LLMs that produce per-page scaffolds.
- **`decisions/`** — append-only log that build-time agents write into at every branch decision.
- **`assets/MANIFEST.txt`** — verify-list of every file the skeleton references.

## How to discover this template

A specialist finds this template by grepping any of:

- `data-section="data-table"` (matches the skeleton)
- `.is-empty` (matches the empty-state hard rule)
- `<table>` `<caption>` + `<th scope="col">` (table a11y floor)

If a user task includes any of these phrases, this template applies:

- "admin panel", "internal tool", "ops dashboard"
- "user list with sort + filter + search"
- "invite teammate form", "MRR overview", "metrics overview"
- "table-driven CRUD UI", "internal SaaS dashboard"

If unsure, `am-planning` reads `memory/01-builder-flow.md` and decides.

## How to apply

1. **`am-planning` reads `memory/01-builder-flow.md`** to scaffold the build stages.
2. **`am-coder` reads `skeleton/index.html`** as the structural baseline,
   customizes for the user's data shape + brand, preserves all 5 hard rules.
3. **`am-review` reads `memory/12-quality-bar.md`** before review — it codifies
   the 5 hard rules + acceptance checklist.

## What this template is NOT

- **NOT** a no-code platform. The user (or am-coder) still writes HTML/CSS/JS.
- **NOT** a hosted template engine. It's a folder of memory + skeleton + prompts
  the agents_manager pipeline reads.
- **NOT** vendor-locked. Default is plain HTML/CSS/JS; opt into any framework per
  `memory/02-routing-and-layout.md`.
- **NOT** opinionated about authentication. Login / role-based gating is out of
  scope (`auth-shell` will be a separate template, deferred).
- **NOT** chart-heavy. v0.1.0 ships a metrics row (3 big numbers), not charts.
  Charts are v0.2.0.

## Cut for v0.1.0 (deferred, not missing)

These would expand the template's surface area but were cut to ship lean:

- Charts (canvas/SVG). Memory file 05-charts.md, library decision deferred.
- `motion/` and `locales/` folders (none required by worked example).
- `_neutral/` worked example (defer to v0.2.0; skeleton + `_recipe.md` covers acceptance).
- History API routing (hash routing is the v0.1.0 default; switchable per memory/02).
- `auth-shell` companion (login flow is its own template).

See `decisions/decision-log.md` for proposed entries on each.

---

**Status:** active · **Version:** v0.1.0 · **Authored:** see decisions/decision-log.md
