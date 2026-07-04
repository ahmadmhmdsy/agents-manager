# cinematic-landing — INDEX

> Read this file first. It is the only file you must read end-to-end.

## How to use this template as an agent

1. **Read this file end-to-end.** It is the only INDEX read required.
2. **For each section you implement, grep the trigger line.** Search
   `memory/*.md` for the literal `USE THIS WHEN:` and load only the file(s)
   whose trigger matches your current concern. Do not read all memory files.
3. **After implementing, run `bash tests/verify.sh`** from the template root.
   Exit 0 means your changes did not break the skeleton's grep-testable
   contracts. Exit non-zero lists the first failure; fix and re-run.

If a section's concern matches no trigger line, the section is not yet
documented — flag it and add a memory file at the next monotonic number.

## Section insertion convention

Sections appear in **DOM order = INDEX list order**. When adding a new
section:

1. Append it before `<footer data-section="footer">` and add a row to
   the per-section table at the matching ordinal.
2. **Bump `## Sections (N)` to N+1** in the same commit. verify.sh T1
   enforces the lock-step.
3. The section's `id` must be unique and match its `data-section` value.
4. Add the section's bullet to the `## Sections` description block in
   DOM order (between the preceding section's bullet and the footer
   bullet).

## CSS conventions

When adding a new section, follow these conventions. Real class names
come from the skeleton (see `skeleton/index.html`) — nothing invented.

- **Outer wrapper:** `<section id="<id>" data-section="<id>"
  data-ambient="<hex>" data-ambient-dark="<hex>">` — schema is
  non-negotiable (see `## Hard rules`). `id` and `data-section` must
  match exactly.
- **Inner container:** `<div class="wrap">` for max-width centring
  (`max-width: var(--maxw); margin-inline: auto;`). Reuse; do not
  redefine per section.
- **Cards / articles:** `<article class="<thing>-card">` for any
  repeated card-like content (e.g., `ed-card`). Always semantic HTML
  (`<article>`, `<blockquote>`, `<cite>` for quotes) over `<div>` soup.
- **Headings:** `<h2>` per section. Avoid `<h1>` after the page hero.
- **Ambient color shift:** provided by the JS theme controller that
  reads `data-ambient` / `data-ambient-dark`. Do not hardcode
  `background-color` on the section element.
- **Fictitious content:** when adding demo copy with invented people
  / brands / places, add an HTML comment at the top of the section:
  `<!-- fictitious names; replace before production -->`. Real names
  go through review.
- **Default ambient for new sections:** if your section's `data-ambient`
  is not in the per-section table, pick the closest existing token
  (`--cream`, `--mist`, `--sand`, `--gold-deep`, etc.) by vibe. Document
  the choice in the per-section table row. If no token matches, the
  section needs a new token; consult `memory/05-theming.md` and add the
  token before using it.

### Class naming

- **Cards:** `<X>-card` (e.g., `ed-card`, `testimonial-card`, `press-card`).
- **Layout containers between `.wrap` and cards:** `<X>-grid` for CSS
  grid layouts, `<X>-list` for flex/column flows. Pick one per section.
- **Card-internal elements:** `<X>-card-name`, `<X>-card-body`,
  `<X>-card-meta`. Keep kebab-case.
- **Do not redefine `.wrap`** — it is shared infrastructure.

### Description-block ordering

When adding a section, insert the bullet in the `## Sections`
description block at the matching DOM ordinal (not alphabetically, not
appended). New section between `editions` and `footer` → its bullet
goes between the `editions` bullet and the `footer` bullet.

## Sections (9)

Every section carries a `data-section` attribute on its root element. Grep target: `data-section="<id>"`.

- `header` — `<header data-section="header">` — sticky, hide on scroll-down / show on scroll-up
- `hero` — `<section id="hero" data-section="hero" data-ambient="...">` — cutout + aura + motes + pointer tilt + sheen
- `film` — `<section id="film" data-section="film" data-ambient="...">` — scroll-driven crossfade / canvas scrub / `<video>` ambient / graceful fallback (per Branch in `memory/06`)
- `reveal` — `<section id="reveal" data-section="reveal" data-ambient="...">` — single still + specs list
- `ritual` — `<section id="ritual" data-section="ritual" data-ambient="...">` — two-up lifestyle stills + copy block
- `cta` — `<section id="cta" data-section="cta" data-ambient="...">` — still backdrop + 3-frame click-advance (any branch)
- `editions` — `<section id="editions" data-section="editions" data-ambient="...">` — N-card grid
- `press` — `<section id="press" data-section="press" data-ambient="...">` — N-card grid of editorial mentions (`<article class="press-card">` with `<blockquote>` + `<cite>` + `<time>`)
- `footer` — `<footer data-section="footer">` — placeholder; copyright stays fictitious in demos

## Runtime branches (4)

The template MUST work on every asset state. `memory/06-asset-pipeline.md` picks a branch at build time and records it in `assets/MANIFEST.json`.

- **A** — pipeline (canvas frame-sequence scrub). See `memory/02-scroll-film-canvas.md` Path A.
- **B** — video file (`<video autoplay muted loop>` ambient + CSS parallax). See Path B.
- **C** — stills (5–6 stills, scroll-driven opacity crossfade). See Path C. **The skeleton's current implementation.**
- **D** — nothing yet (`ask-list` from `prompts/image-gen.md` + `prompts/video-gen.md`; `.fallback-host.is-missing` renders a tasteful gradient).

## Hard rules (5)

1. **No `video.currentTime = …` assignment.** See `memory/02-scroll-film-canvas.md` hard rules.
2. **No `mix-blend-mode` on any element GSAP transforms.** See `memory/02` rule 2.
3. **Cutout image ≠ aura image.** See `memory/04-cinematic-hero.md` hard rule 1 (skeleton uses 6045245 + 6195171 — distinct).
4. **`.fallback-host.is-missing` wired.** See `memory/06-asset-pipeline.md` Branch D.
5. **`prefers-reduced-motion: reduce` honored** at three layers: CSS media query + JS matchMedia listener + mid-session `change` listener. See `memory/07-reduced-motion.md` + `memory/12-reduced-motion-listener.md`.

## Tokens (14 + dark-mode override)

The 14 light-mode tokens + 14 dark-mode counter-table live in `memory/05-theming.md` (light) + `memory/14-dark-theme.md` (dark, canonical, WebAIM-audited). One source of truth per concern; `memory/05` references `memory/14` for dark.

| Token | Light | Dark |
|---|---|---|
| `--paper` | `#FBF6EE` | `#0E0A06` |
| `--mist` | `#F6F0E4` | `#15110B` |
| `--cream` | `#F1E9D7` | `#1A150E` |
| `--sand` | `#E8DBC1` | `#221A11` |
| `--ink` | `#241812` | `#F4ECDD` |
| `--ink-soft` | `#6E5C4B` | `#C9B89A` |
| `--ink-faint` | `#7A6855` | `#8E7E66` |
| `--gold` | `#B07A2E` | `#D4A24A` |
| `--gold-deep` | `#8B5E22` | `#B5862F` |
| `--gold-bright` | `#CC9A4A` | `#E8C275` |
| `--accent` | `#9C5026` | `#C97A3F` |
| `--line` | `rgba(58,33,20,.16)` | `rgba(244,236,221,.18)` |
| `--line-soft` | `rgba(58,33,20,.09)` | `rgba(244,236,221,.10)` |
| `--ambient` | `var(--paper)` | `var(--paper)` |

Per-section overrides: every `<section>` carries `data-ambient="#hex"` (light) + `data-ambient-dark="#hex"` (dark). The JS theme controller reads the right one on toggle.

## a11y floor

- **Canvas / film a11y** — `memory/11-canvas-a11y.md` (`role="img"` + dynamic `aria-label` + hidden `<ol>` transcript).
- **Reduced motion (mid-session)** — `memory/12-reduced-motion-listener.md` (handler reloads on `change`).
- **Keyboard nav** — `memory/13-keyboard-nav.md` (section-snap, CTA-frame advance/retreat).
- **Dark theme** — `memory/14-dark-theme.md` (mode-aware `--gold-text-top`, K1 + K2 contrast math).

## Worked example

**Maison Lumen Apothecary Light** — hand-poured candles, made in small editions. Skeleton demo at `templates/cinematic-landing/skeleton/index.html`. Brand brief + memory consultation order in `examples/_recipe.md`. Companion neutral-aesthetic application in `examples/_neutral/` shows the template's range (Latin LTR, Inter, slate-on-white).

Recipe is the procedure; the worked example is one application.

## Per-section cross-reference

Every section's `data-section` value is the canonical key for both the DOM
identity and the ambient palette the JS theme controller reads. Hex values
mirror the skeleton's `data-ambient` / `data-ambient-dark` attributes
exactly — nothing invented. `header` and `footer` carry no `data-ambient`
attributes (they sit on the body's `--paper`), so their row records `n/a`.

| # | id | data-section | ambient (light) | ambient (dark) | role |
|---|----|----|----|----|----|
| 1 | header | header | `n/a` (uses body `--paper` `#FBF6EE`) | `n/a` (uses body `--paper` `#0E0A06`) | sticky nav; hide on scroll-down / show on scroll-up |
| 2 | hero | hero | `#FBF6EE` (--paper) | `#0E0A06` (--paper dark) | cutout + aura + motes + pointer tilt + sheen |
| 3 | film | film | `#F4ECDD` | `#100C08` | 6 stills, scroll-driven opacity crossfade |
| 4 | reveal | reveal | `#F2EAD7` | `#14100A` | editorial product shot + specs list |
| 5 | ritual | ritual | `#3B2A1B` | `#1A1308` | two-up lifestyle stills + copy block |
| 6 | cta | cta | `#F6F1E8` | `#0A0805` | still backdrop + 3 click-to-advance copy frames |
| 7 | editions | editions | `#F1E9D5` | `#120E08` | N-card grid (`<article class="ed-card">`) |
| 8 | press | press | `#F1E9D7` (--cream) | `#1A150E` (--cream) | N-card grid of editorial mentions (`<article class="press-card">`, `<div class="press-grid">`) — picked --cream by vibe (editorial / parchment) |
| 9 | footer | footer | `n/a` (uses body `--paper` `#FBF6EE`) | `n/a` (uses body `--paper` `#0E0A06`) | copyright + nav links |

---

**Status:** active · **Version:** v0.14.0 · **Trigger line format:** per `templates/AUTHORING.md` Rule 6 (`# NN · <topic> — USE THIS WHEN: …`)
