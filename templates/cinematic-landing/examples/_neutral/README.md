# _neutral — minimal neutral-aesthetic application

> This is a minimal neutral-aesthetic application of the cinematic-landing
> template. It exists to show the template's range. Compare to `../_recipe.md`
> (Maison Lumen — Apothecary Light).

## What's the same as the template

- 8-section skeleton with `data-section` attributes on each element.
- 14-token CSS custom-property palette pattern (a minimal 7-token subset here).
- `<html lang="en" dir="ltr">` baseline (`memory/10-locale-handoff.md` default).
- `prefers-reduced-motion: reduce` semantic via a different (sans) token set.

## What's different

- **Typography** — Inter (Google Fonts) instead of El Messiri + Tajawal +
  Cormorant Garamond (Maison Lumen).
- **Palette** — slate-on-white (`#1f2937` ink on `#ffffff` paper) instead of
  warm cream-on-cream.
- **Numerals** — Latin (no RTL/Arabic-Indic mapping).
- **Motion** — omitted (no Lenis, no GSAP, no ScrollTrigger). The neutral
  sample is intentionally static; the template's motion is opt-in per
  `memory/03-scroll-ticker.md`.

## When to copy this

Use `_neutral/` as a starting point when:

- The brand wants a minimal, functional aesthetic (no cinematic overlay).
- The animation tier is out of scope (CMS-driven content, low-bandwidth users,
  pure information density).
- You need a second reference implementation that proves the template does
  *not* require the apothecary aesthetic.

## When NOT to use this as a base

If the brand brief asks for any of: scroll-driven storytelling, ritual-style
hero, cinematic pacing, ambient color shifts per section — start from the
main `skeleton/` (Maison Lumen) instead. `_neutral/` removes 90% of the
template's value for those briefs.

## How to render

From `templates/cinematic-landing/`:

```bash
python3 -m http.server 8000
# then visit http://localhost:8000/examples/_neutral/
```
