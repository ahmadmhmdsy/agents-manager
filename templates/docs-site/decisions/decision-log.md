# docs-site · decision log

> Append-only build-time log. Newest first. Format: `D-YYYY-MM-DD-NNN`.
> Continue numbering from sibling templates (dashboard shipped D-001…D-005).

---

## D-2026-07-04-010 — `_neutral/` worked variant deferred

**Status:** proposed

**Context.** `AUTHORING.md` lists `examples/_neutral/` as the neutral-aesthetic
variant of the recipe. The reference recipe (`_recipe.md`, Acme SDK docs) already
ships in v0.1.0 with one concrete brand. Standing up a second, contrast-by-design
variant at the same version is duplicative: every token + rule edit has to be made
in two places.

**Decision.** Ship `_recipe.md` only in v0.1.0. Add `_neutral/` in v0.2.0 once a
seventh memory file is needed and the contrast surface grows.

**Consequence.** Authors wanting a no-brand preview fork the current `_recipe.md`
and rename + recolour by hand — that's 12 token edits, ~5 minutes, more useful
than mirroring a prebuilt variant.

---

## D-2026-07-04-009 — Client-side search, no search library

**Status:** proposed

**Context.** A docs site without search is half a docs site; with search it becomes
a 200KB+ dependency problem (Pagefind ships its own index, Algolia needs a backend,
Fuse.js index build can dominate main thread on >500 pages).

**Decision.** v0.1.0 ships a **client-side inverted index** built in ~30 lines:
`{ token → [pageId] }`. Built on load from the manifest, queried on every keystroke.
No library. ~1KB additional JS.

**Consequence.** Up to ~200 pages the index lives in memory comfortably.
v0.2.0 may add fuzzy matching + ranking if real usage shows naive AND match is wrong
half the time. Tracked as D-… follow-up only after evidence, not preemptively.

---

## D-2026-07-04-008 — Multi-version selector deferred

**Status:** proposed

**Context.** Most public docs sites expose a version dropdown. With v0.1.0 we ship
one canonical version of every page; the dropdown would always read "current".

**Decision.** v0.1.0 omits the version selector from `topbar`. Add in v0.2.0 once
we know whether the consumer wants semver tags or date snapshots.

**Consequence.** Topbar slot reserved; `<button data-version-slot>` placeholder lives
in markup as a comment so v0.2.0 can replace it without a search.

---

## D-2026-07-04-007 — Syntax-highlighting library deferred

**Status:** proposed

**Context.** The point of `docs-site` is good code presentation. Highlighters
(Prism, Shiki, highlight.js) solve "fairly" colouring automatically but each is
~30-300KB and each is brittle on long custom DSLs.

**Decision.** v0.1.0 ships `<pre><code>` monospace styling only — no lexer, no
colour spans. Authors who want colour hand-markup with `<span class="k">` and
document the classes in their style sheet.

**Consequence.** `/assets/MANIFEST.txt` ships **zero** external scripts.
The framework-free promise of `dashboard/` carries to `docs-site/`. A v0.2.0
follow-up may adopt Shiki (server-prebuilt HTML, no client runtime) if evidence
shows manual `<span>` colouring is the common pain.

---

## D-2026-07-04-006 — Initial v0.1.0 cut

**Status:** proposed

**Context.** First version of `docs-site`. Authored against `AUTHORING.md` v1.0.0.

**Decision.** Ship v0.1.0 with **6 sections**, **12 memory files**, **14 tokens**,
**5 hard rules**, **8 verify.sh tests**, **1 worked recipe** (Acme SDK docs).

**Consequence.** All seven cut-list items (D-007 through D-010 + examples/_neutral
+ multi-version) carry into v0.2.0 planning. See INDEX.md for the section list and
`memory/01-builder-flow.md` for the author flow.
