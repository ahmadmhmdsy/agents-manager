# 01 · Builder flow — what to build, in what order

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

Six sections. Order is locked:

1. `<header>` — sticky, hide on scroll-down / show on scroll-up.
2. `<section data-section="hero">` — cutout + aura + motes + pointer tilt + sheen.
3. `<section data-section="film">` — scroll-driven crossfade (Branch C) or frame-sequence
   scrub (Branch A) or `<video>` ambient (Branch B) or graceful fallback (Branch D).
4. `<section data-section="reveal">` — single still + scrollcue.
5. <section data-section="ritual">` — two-up lifestyle stills + copy blocks.
6. `<section data-section="cta">` — still backdrop + 3-frame click-advance (any branch).
7. `<section data-section="editions">` — 3-card grid (or N-card for other counts).
8. `<footer>` — placeholder; copyright stays fictitious in demos.

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