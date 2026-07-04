# Atlas Admin — Worked Example · Recipe

> Worked example for the `dashboard` template. The skeleton at
> `templates/dashboard/skeleton/index.html` IS Atlas Admin rendered with
> full ops-dashboard aesthetic + dark mode + reduced-motion gate. This
> file is the *recipe* — the procedure you can repeat for a different brand.

## 1 · Brand brief

- **Domain** — fictional small-SaaS ops dashboard ("Atlas Admin")
- **Audience** — internal teams (support, ops, founders)
- **Voice** — neutral, data-first, no marketing adjectives
- **Constraints** — vanilla HTML/CSS/JS, no framework, no fetch (Branch A
  in-memory mock), dark mode by default, sensible a11y floor

## 2 · Memory files consulted, in order

The 12 memory files were read in monotonic order (01 → 12). Trigger lines
that fired at each step (per `../AUTHORING.md` Rule 6):

| # | File | Trigger | What fired |
|---|---|---|---|
| 01 | `01-builder-flow.md` | "scaffolding a new dashboard and need the stage-based build order" | stage ordering |
| 02 | `02-routing-and-layout.md` | "shipping a multi-section dashboard shell with sidebar/topbar and route-aware state" | hash routing + sidebar active state |
| 03 | `03-data-table.md` | "building a sortable, filterable, paginated table over a JSON array" | sort + filter + paginate |
| 04 | `04-forms-and-validation.md` | "composing a form with field-level validation, error display, and submit gating" | field-level errors + submit gate |
| 05 | `05-loading-empty-error-states.md` | "rendering loading, empty, and error states for a data-driven view" | data-state attribute on data-table |
| 06 | `06-theming.md` | "defining dashboard tokens and switching themes via data-theme attribute" | 13-token palette swap |
| 07 | `07-reduced-motion.md` | "gating transitions, chart draws, and route changes when prefers-reduced-motion: reduce" | CSS + JS gating |
| 08 | `08-keyboard-nav.md` | "wiring Tab order, focus rings, /, Esc, and section-skip links" | `/` focus search, Esc clear, focus skip |
| 09 | `09-table-a11y.md` | "making a sortable <table> accessible: caption, scope, sort announcement" | `<caption>` + `scope="col"` + sort button aria |
| 10 | `10-form-a11y.md` | "labeling fields, associating errors, and managing focus on submit failure" | `<label for>` + `aria-describedby` + focus first error |
| 11 | `11-dark-theme.md` | "defining or auditing dashboard dark-mode tokens" | mode-aware tokens + focus-ring audit |
| 12 | `12-quality-bar.md` | "running the pre-merge quality bar (visual + a11y + perf + empty-state check)" | verify.sh exit 0 + axe-core 0 critical |

## 3 · Overrides applied

- **Branch = A** — in-memory mock only (`skeleton/data.js`). Users list is
  25 rows; metrics row shows 3 hand-curated big numbers (MRR, NRR, active seats).
- **Dark mode by default** — `<html data-theme="dark">` on first paint; toggle
  in topbar flips via `data-theme` attribute. Tokens via `memory/06` (light) +
  `memory/11` (dark).
- **No charts in v0.1.0** — `metrics` section is a 3-cell row of big numbers.
  Charts deferred per `decisions/decision-log.md D-2026-07-04-002`.
- **Hash routing** — `#/dashboard`, `#/users`, `#/settings`. Back button works.
  URL is the source of truth per `memory/02` rule 2.
- **Form: invite teammate** — fields: email (required, email regex), role
  (select with 3 options), message (textarea, optional). Submit calls a mock
  handler; on success, the new row lands at the top of the data-table via
  Branch A mock state mutation.

## 4 · Result

Skeleton at `templates/dashboard/skeleton/index.html` (~600 lines).
Use `python3 -m http.server` from the template root and visit
`http://localhost:8000/skeleton/` to render.

## 5 · What you would change for a different brand

- **Token palette.** Pick from the 13-token table; `--surface` for page bg,
  `--ink` for body text, `--accent` for primary actions. Re-run
  `tests/verify.sh` for `--ink-faint` contrast (T-pending; v0.1.0 only checks
  structural rules, contrast is manual).
- **Data shape.** Replace `skeleton/data.js` with your real schema. The
  `memory/03` rules (sort key, filter keys, page size) generalize.
- **Routing depth.** If you outgrow 3 routes, switch to History API per
  `memory/02` rule 3. URL-as-source-of-truth still applies.
- **Branch choice.** Stay on A (mock) for demos; switch to B (REST) once a
  real backend exists. The `?data=mock` debug toggle from Branch C still
  works.
- **Empty state copy.** Replace Atlas Admin copy with brand-specific.
  `memory/05` empty-state rules (no fake rows, no "—" placeholder) hold.

## 6 · What you would not change

- **7-section shape.** `app-shell` → `topbar` + `sidebar` + `data-table` +
  `metrics` + `form` + `footer`. Reordering or removing sections is a
  template-level change, not a brand-level one. New sections go through
  `prompts/scaffolding.md`.
- **Hard rules.** The 5 hard rules in INDEX are template-level contracts.
  Per-brand overrides belong in `decisions/decision-log.md`, never by
  silently skipping the rule.

Recipe is the procedure; the worked example (skeleton) is one application.
