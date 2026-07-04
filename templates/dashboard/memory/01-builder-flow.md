# 01 · Builder flow — what to build, in what order — USE THIS WHEN: scaffolding a new dashboard and need the stage-based build order

The dashboard build proceeds in 5 stages. Each stage produces one decision +
one artifact. The skeleton in `skeleton/index.html` is the running target;
stages 2–4 are net-additive customizations on top of it.

## Stage 1 — Data shape

Define what the data is (users, orders, MRR, sessions — anything). Write the
shape to `skeleton/data.js` (Branch A) or to `assets/MANIFEST.json` (Branch B
or C). This is the source of truth for every shape concern downstream.

If no project data exists, fall back to: 25 users + 3 hand-curated metrics
(see Atlas Admin recipe for the worked trace).

## Stage 2 — Section structure

Seven sections. Order is locked:

1. `<body data-section="app-shell">` — top-level wrapper; mounts theme toggle,
   reduced-motion listener, focus skip link.
2. `<header data-section="topbar">` — product name + global search input + user
   menu stub. Per `memory/08-keyboard-nav.md`, `/` focuses the search input.
3. `<nav data-section="sidebar">` — route-aware; active link carries
   `aria-current="page"`. Per `memory/02-routing-and-layout.md`.
4. `<section data-section="data-table">` — sortable, filterable, paginated;
   `data-state="empty|loading|ready|error"` per `memory/05`.
5. `<section data-section="metrics">` — 3-cell metrics row; no chart in v0.1.0
   (deferred to v0.2.0).
6. `<section data-section="form">` — invite-teammate; field-level validation,
   aria-describedby errors per `memory/10`.
7. `<footer data-section="footer">` — placeholder; copyright stays fictitious.

## Stage 3 — Hash routing + URL state

One `routes = [{ hash, section }]` table at the top of the script. On
`hashchange`, toggle the matching section's visibility. Sort/filter/page live
in URL query params; refresh persists; back button works. Per `memory/02`
rule 2 (URL is the source of truth).

## Stage 4 — Theme + reduced-motion bootstrap

`<html data-theme="light|dark">` set from `localStorage.theme` (default
`dark` per Atlas Admin). One CSS `@media (prefers-reduced-motion: reduce)`
block + one JS `matchMedia` listener that gate: route fade, hover bg tween,
form-error pulse, focus ring animation.

## Stage 5 — Quality bar

Run `bash tests/verify.sh` (exit 0). Run axe-core on light + dark variants
(0 critical). Manual pass: toggle theme, toggle reduced-motion, submit
invalid form, sort by every column, paginate to the last page, refresh mid-
filter-state, hit back. Per `memory/12-quality-bar.md`.

## Order matters

Stages 1–2 may run in parallel. Stages 3–4 are sequential; each consumes the
previous stage's output. Stage 5 is the gate; nothing ships without it.

## Worked trace

Atlas Admin: Stage 1 shipped `data.js` with 25 users + 3 metrics. Stage 2
shipped the 7 sections. Stage 3 wired hash routing + URL state. Stage 4
wired dark + reduced-motion. Stage 5 (verify.sh) cleared T1–T8 on first run.
