# 01 · Builder flow — what to build, in what order — USE THIS WHEN: scaffolding a new template and need the stage-based build order

The cinematic-landing build proceeds in 6 stages. Each stage produces one decision +
one artifact. The skeleton in `skeleton/index.html` is the running target; stages
2–5 are net-additive customizations on top of it.

## Stage 1 — Brand voice

am-design (or master, if am-design is not invoked) reads `02_brand/voice-and-tone.md`
analogues in the project's design subtree. For a cinematic-landing task, the brand voice
governs: hero copy, ritual copy, CTA frames, journal blurbs.

If no project voice doc exists, fall back to: short, sensory, second-person, no marketing
adjectives (no "luxurious", "premium", "artisanal (overused)", "curated (overused)").

## Stage 2 — Asset manifest

`am-assets` runs the 4-branch decision tree (`memory/06-asset-pipeline.md`) and writes
`assets/MANIFEST.json` per branch. This is the source of truth for every image / video URL
the build uses.

## Stage 3 — Section structure

Eight sections. Order is locked:

1. `<header data-section="header">` — sticky; hide on scroll-down / show on scroll-up.
2. `<section id="hero" data-section="hero" data-ambient="...">` — cutout + aura + motes + pointer tilt + sheen.
3. `<section id="film" data-section="film" data-ambient="...">` — scroll-driven crossfade (Branch C) or frame-sequence scrub (Branch A) or `<video>` ambient (Branch B) or graceful fallback (Branch D).
4. `<section id="reveal" data-section="reveal" data-ambient="...">` — single still + specs list.
5. `<section id="ritual" data-section="ritual" data-ambient="...">` — two-up lifestyle stills + copy blocks.
6. `<section id="cta" data-section="cta" data-ambient="...">` — still backdrop + 3-frame click-advance (any branch).
7. `<section id="editions" data-section="editions" data-ambient="...">` — 3-card grid (or N-card for other counts).
8. `<footer data-section="footer">` — placeholder; copyright stays fictitious in demos.

## Stage 4 — Lenis + GSAP single ticker

One `requestAnimationFrame` loop. GSAP ticker advances Lenis. ScrollTrigger watches
scroll progress. No duplicate tickers. Per `memory/03-scroll-ticker.md`.

## Stage 5 — Ambient color tween

Each section gets a `data-ambient="<hex>"` attribute. A single `gsap.ticker.add` callback
reads the current section and tweens `#ambient`'s `background-color` to that section's
hex value. Per `memory/05-theming.md`.

## Stage 6 — Reduced-motion short-circuit

One CSS `@media (prefers-reduced-motion: reduce)` block + one JS `matchMedia` listener
that gates: Lenis init, film crossfade, ken-burns pan, motes, sheen, scrollcue, hero
entrance, hero parallax, reveals, CTA click handler.

## Order matters

Stages 1–2 may run in parallel. Stages 3–6 are sequential; each consumes the previous
stage's output. The plan self-score must hit testability=5 for at least Stages 3 + 6.