# Cinematic Landing — Task Template

**cinematic-landing template v0.14.0** — Read this file first.

A vendor-neutral, multi-LLM-aware task template for building a cinematic, scroll-driven
single-page product site. Works whether the user has:

- A video pipeline (Higgsfield / Runway / Replicate) → Branch A
- A standalone video file → Branch B
- Public-domain or self-supplied stills (Pexels / Unsplash / Midjourney) → Branch C
- Nothing at all → Branch D (concrete ask-list generated; graceful fallback shipped)

The template ships with:

- **`memory/`** — 14 memory files governing how am-research, am-planning, am-assets,
  am-coder, and am-review approach a cinematic-landing task. Each file is a prose
  contract, not a hard rule — adapt per project.
- **`skeleton/`** — a reference implementation (~1100 lines) showing the engine wired up
  in vanilla HTML/CSS/JS + Lenis + GSAP + ScrollTrigger. Edit, don't fork.
- **`prompts/`** — copy-paste prompts for Midjourney, DALL-E, Sora, Runway, Veo,
  and a generic image/video gen prompt. Owner picks the LLM they trust.
- **`decisions/`** — decision-log template that am-assets appends to at build time.
- **`assets/`** — `manifest.schema.json` (JSON Schema 2020-12) for the asset manifest
  `am-assets` produces at Branch decision time, plus this MANIFEST.txt.

## How to discover this template

A specialist finds this template by grepping for:
- `data-section="hero"` (matches the skeleton)
- `.fallback-host.is-missing` (matches the hard rules)
- `prefers-reduced-motion: reduce` (matches the a11y floor)

If a user task includes any of these phrases, this template applies:
- "cinematic landing", "scroll-driven hero", "scrolltelling"
- "single-page product site with frame sequence"
- "apothecary / fragrance / candle site with cutout hero"
- "Lenis + GSAP single ticker"

If unsure, `am-planning` reads `memory/01-builder-flow.md` and decides.

## How to apply

1. **`am-assets` reads `memory/06-asset-pipeline.md`** and runs the 4-branch decision tree
   against the user's asset reality. Produces `assets/MANIFEST.json` per branch.
2. **`am-planning` reads `memory/01-builder-flow.md` and `memory/02-scroll-film-canvas.md`**,
   writes the plan referencing this template's skeleton + memory files.
3. **`am-coder` reads `skeleton/index.html`** as the structural baseline, customizes
   for the user's brand + asset manifest, preserves all 5 hard rules.
4. **`am-review` reads `agents_manager/assets/resources/landing-review-checklist.md`** before
   review — it codifies the 5 hard rules + 4-branch runtime verification.

## What this template is NOT

- **NOT** a no-code platform. The user (or am-coder) still writes HTML/CSS/JS.
- **NOT** a hosted template engine. It's a folder of memory + skeleton + prompts the
  agents_manager pipeline reads.
- **NOT** vendor-locked. See Branch A–D above.
- **NOT** opinionated about locale. Default is LTR English; flip via `04-locale-handoff.md`.