# Decision log — dashboard template

> Append-only log of decisions made during this template's lifecycle.
> Each entry has: status (proposed / accepted / deprecated), context, action, refs.

---

## D-2026-07-04-001 — initial v0.1.0 cut

**Status:** accepted
**Context:** v0.1.0 ships the minimum structure that satisfies
`../AUTHORING.md` Rule 8 acceptance checklist. 7 sections (app-shell,
topbar, sidebar, data-table, metrics, form, footer), 3 runtime branches,
5 hard rules, 13 tokens + dark override, 12 memory files.
**Action:** Initial cut. `examples/_recipe.md` documents the procedure.
**Refs:** `00-readme-first.md`, `INDEX.md`, `memory/01-builder-flow.md`.

---

## D-2026-07-04-002 — chart-card deferred to v0.2.0

**Status:** accepted (proposed)
**Context:** Original plan called for a `chart-card` section as the
load-bearing 5th section. Charts need a library decision (canvas vs inline
SVG vs uPlot vs Chart.js) which is itself a PR-sized concern.
**Action:** v0.1.0 ships a `metrics` row (3 big numbers, no chart) instead.
v0.2.0 will add `chart-card` as a separate section with `memory/05-charts.md`
appended at the next monotonic slot (after 12). Memory numbers do not shift.
**Refs:** `INDEX.md §Sections`, `00-readme-first.md §Cut for v0.1.0`.

---

## D-2026-07-04-003 — hash routing as v0.1.0 default

**Status:** accepted
**Context:** Skeleton needs zero deps + static-renderable for hand-off.
History API requires server-side fallback (404.html) for deep links.
**Action:** v0.1.0 uses hash routing (`#/dashboard`, `#/users`, `#/settings`).
Branch to History API per `memory/02-routing-and-layout.md` once a static host
is chosen. URL-as-source-of-truth still applies (rule 2).
**Refs:** `memory/02-routing-and-layout.md`.

---

## D-2026-07-04-004 — _neutral example deferred to v0.2.0

**Status:** accepted
**Context:** The cinematic-landing exemplar ships `_neutral/` as a second
reference implementation proving the template's range. For dashboard v0.1.0,
the skeleton + `_recipe.md` already cover acceptance. A neutral example would
require a second skeleton build without driving new acceptance criteria.
**Action:** v0.1.0 ships skeleton + `_recipe.md` only. v0.2.0 adds
`examples/_neutral/index.html` once the dashboard has been validated on one
real brand.
**Refs:** `00-readme-first.md §Cut for v0.1.0`.

---

## D-2026-07-04-005 — auth-shell companion deferred

**Status:** proposed
**Context:** Real dashboards almost always sit behind login. The v0.1.0
skeleton has no auth — it assumes the user is already authenticated and the
session is hydrated.
**Action:** v0.2.0 to add `templates/auth-shell/` companion OR fold into a
v0.3.0 `dashboard-with-auth/` variant. Out of scope for v0.1.0.
**Refs:** `memory/02-routing-and-layout.md`.

---

## <FUTURE ENTRIES — appended at build time, never edited>

When `am-assets` (or future build agent) decides, append a new section here:

```markdown
## <DATE> — <agent>
**Decision:** Branch <A|B|C> selected per user input.
**Why:** <evidence from user prompt>
**Tradeoff:** <what the user gives up vs gains>
**Refs:** `assets/MANIFEST.json`
```
