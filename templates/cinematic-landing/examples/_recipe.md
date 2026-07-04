# Maison Lumen — Apothecary Light · Recipe

> Worked example for the `cinematic-landing` template. The skeleton at
> `templates/cinematic-landing/skeleton/index.html` is Maison Lumen rendered
> with full apothecary aesthetic + RTL-aware numerals. This file is the
> *recipe* — the procedure you can repeat for a different brand.

## 1 · Brand brief

- **Domain** — hand-poured candles (luxury apothecary niche)
- **Audience** — gift-shoppers, ritual-object collectors, design-conscious 30–55
- **Voice** — sensory, second-person, no marketing adjectives
- **Constraints** — public-domain stills only (no Higgsfield pipeline available);
  late-PM lighting; warm palette; small-edition scarcity trope

**Voice vocabulary (chosen):**
light, hush, ritual, breath, hand-poured, small batch, three editions.

**Forbidden adjectives:** luxurious, premium, artisanal, curated.

## 2 · Memory files consulted, in order

The 14 memory files were read in monotonic order (01 → 14). Trigger lines
that fired at each step (per `templates/AUTHORING.md` Rule 6):

| # | File | Trigger | What fired |
|---|---|---|---|
| 01 | `01-builder-flow.md` | "scaffolding a new template and need the stage-based build order" | stage ordering |
| 02 | `02-scroll-film-canvas.md` | "shipping a scroll-driven `<canvas>` and need film-strip pacing rules" | Branch C chosen (stills only) |
| 03 | `03-scroll-ticker.md` | "implementing the single-ticker scroll system (Lenis + GSAP)" | ticker pattern |
| 04 | `04-cinematic-hero.md` | "designing the hero canvas with cutout/aura coordination" | aura/cutout distinct IDs |
| 05 | `05-theming.md` | "defining light-mode brand tokens and theme-attribute switching" | token palette swap |
| 06 | `06-asset-pipeline.md` | "sourcing assets through the 4-branch runtime tree" | Branch C decision |
| 07 | `07-reduced-motion.md` | "shipping animation, transitions, or scroll-driven effects that need reduced-motion gating" | CSS + JS gating |
| 08 | `08-cta-frames.md` | "composing CTA section copy + frame layout" | 3-frame click-advance |
| 09 | `09-quality-bar.md` | "running the pre-merge quality bar (visual + a11y + perf)" | PASS gate |
| 10 | `10-locale-handoff.md` | "shipping a non-English locale and need to flip `<html lang dir>`" | LTR default |
| 11 | `11-canvas-a11y.md` | "shipping a `<canvas>` that conveys meaning and needs a screen-reader fallback" | `role="img"` + transcript |
| 12 | `12-reduced-motion-listener.md` | "implementing the mid-session prefers-reduced-motion toggle" | `change` listener + reload |
| 13 | `13-keyboard-nav.md` | "shipping focus-visible, Tab order, or scroll-snap keyboard handling" | section-snap keys |
| 14 | `14-dark-theme.md` | "defining or auditing dark-mode tokens" | `--gold-text-top` + K2 audit |

## 3 · Overrides applied

- **Palette swap** — Apothecary Light set: warmer `--paper` (#FBF6EE), deeper `--gold`
  (#B07A2E), `--gold-deep` (#8B5E22) capped to AA ≥ 4.5 in both modes.
- **Section list unchanged.** The skeleton's 8 sections (header, hero, film, reveal,
  ritual, cta, editions, footer) are reused as-is; only the contents are brand-specific.
- **RTL-aware numerals** — branch locale override would supply `٠١ ٠٢ ٠٣` for the
  `.idx` markers; the LTR/Latin reference implementation skips this override.
- **Hero cutout subject** — apothecary vessel on white background; pair with
  a candle-warm aura for the "ritual moment" effect (memory/04 layer recipe).

## 4 · Result

Skeleton at `templates/cinematic-landing/skeleton/index.html` (~1100 lines).
Use `python3 -m http.server` from the template root and visit
`http://localhost:8000/skeleton/` to render.

## 5 · What you would change for a different brand

- **Token palette.** Pick from the 14-token table; `--paper` for the surface,
  `--ink` for body text, `--gold-deep` for accents. Re-run `tests/verify.sh`
  for `--ink-faint` contrast (T6).
- **Voice in CTA frames** — replace the three CTA copy frames in `memory/08-cta-frames.md`
  with three brand-specific imperatives; the click-advance pattern stays the same.
- **Locale override.** To ship Arabic / Hebrew / Persian / Urdu, set
  `<html lang="ar" dir="rtl">` and follow `memory/10-locale-handoff.md`'s checklist
  (logical properties, hero cutout mirror, motion easing review).
- **Hero cutout.** Keep the aura/cutout pair distinct. If you only have one
  image, see `memory/04` hard rule 1 — soften via decision-log entry, never silently.

## 6 · Companion examples

- `examples/_neutral/` — minimal neutral-aesthetic application (Latin LTR,
  Inter, slate-on-white, one ambient color shift). Shows that the template's
  apothecary aesthetic is *optional*. Pair with this recipe to read
  "template range" before drawing conclusions.

Recipe is the procedure; the worked example is one application.
