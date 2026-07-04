# 05 · Theming — CSS custom properties + per-section ambient tween — USE THIS WHEN: defining light-mode brand tokens and theme-attribute switching

> Dark mode is documented in `memory/14-dark-theme.md`. This file covers light-mode mechanics only.

The cinematic-landing template uses CSS custom properties (`:root` + per-section
overrides) for theming. Two layers:

## Layer 1 — Base tokens (`:root`)

```css
:root {
  /* Paper / surface */
  --paper:   #FBF6EE;
  --mist:    #F6F0E4;
  --cream:   #F1E9D7;
  --sand:    #E8DBC1;

  /* Ink (text) */
  --ink:        #241812;
  --ink-soft:   #6E5C4B;
  --ink-faint:  #7A6855;   /* v1 was #9A8975; raised for WCAG AA */

  /* Brand accent */
  --gold:        #B07A2E;
  --gold-deep:   #8B5E22;
  --gold-bright: #CC9A4A;
  --accent:      #9C5026;

  /* Lines */
  --line:      rgba(58, 33, 20, 0.16);
  --line-soft: rgba(58, 33, 20, 0.09);

  /* Motion */
  --ambient: var(--paper);
  --maxw:    1280px;
  --ease:    cubic-bezier(.22, .61, .36, 1);
}
```

## Layer 2 — Per-section ambient override

Every section gets `data-ambient="<hex>"`. A single GSAP ticker callback reads the
currently-visible section and tweens `#ambient`'s `background-color` to that hex.

```js
gsap.ticker.add(() => {
  const sections = document.querySelectorAll('[data-section]');
  const scrollY = window.scrollY;
  for (const s of sections) {
    const rect = s.getBoundingClientRect();
    if (rect.top < window.innerHeight / 2 && rect.bottom > window.innerHeight / 2) {
      const target = s.dataset.ambient || getComputedStyle(s).backgroundColor;
      gsap.to('#ambient', { backgroundColor: target, duration: 0.8, ease: 'power2.out', overwrite: 'auto' });
      break;
    }
  }
});
```

## Dark mode — see [`14-dark-theme.md`](./14-dark-theme.md)

The 14-token dark counter-table, K1 mode-aware `--gold-text-top`, K2 revert story, per-section `data-ambient-dark`, FOUC prevention `<head>` script, localStorage persistence, prefers-color-scheme auto-detect, the theme controller (`set`/`refreshAmbient`/`aria-pressed` toggle), WebAIM contrast audit, and deuteranopia sim live in [`memory/14-dark-theme.md`](./14-dark-theme.md) as the canonical recipe.

## Hard rules

- **ALWAYS** reference colors as tokens (`var(--ink)`), never inline hex.
- **NEVER** introduce a color not in the palette (per `agents_manager/design/resources/brand-template.md`).
- **ALWAYS** verify `--ink-faint` against `--paper` for 4.5:1 contrast (WCAG AA body text).
  The v1 default of `#9A8975` on `#FBF6EE` fails — use `#7A6855` instead.
- **ALWAYS** apply the theme attribute on the root `<html>` element only. Theme is document-wide; per-section overrides go on individual `<section data-ambient="…">` attributes (see `14-dark-theme.md` for the dark-mode ambient twin).