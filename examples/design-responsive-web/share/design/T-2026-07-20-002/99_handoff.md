# 99 Handoff — Lumio Responsive Landing

**Audience**: am-coder.
**Status**: DONE.

## Artifacts produced

| Path | Purpose |
|---|---|
| `00_brief.md` | Restated task + discovery answers |
| `03_system/tokens/base.json` | W3C Design Tokens (color, dimension, typography) |
| `03_system/tokens/tokens.css` | Compiled CSS custom properties |
| `04_mockups/web-responsive/index.html` | 3-breakpoint mockup, side-by-side |

## What am-coder does

1. Read `03_system/tokens/tokens.css` first.
2. Open `04_mockups/web-responsive/index.html` in a browser to see the visual reference.
3. Build the landing page in your framework. Use the tokens.
4. Stop when you've matched the layout at all 3 breakpoints.

## How to wire tokens

For **React + Tailwind**:

```js
// tailwind.config.js
import base from './share/design/T-2026-07-20-002/03_system/tokens/base.json' assert { type: 'json' };
const colorMap = Object.fromEntries(
  Object.entries(base.color).map(([k, v]) => [k, v.$value])
);
export default {
  theme: {
    extend: {
      colors: {
        'lumio-primary': colorMap['primary'],
        'lumio-primary-deep': colorMap['primary-deep'],
        'lumio-primary-tint': colorMap['primary-tint'],
        'lumio-warm': colorMap['warm'],
        'lumio-ink': colorMap['ink'],
        'lumio-ink-2': colorMap['ink-2'],
        'lumio-ink-3': colorMap['ink-3'],
        'lumio-line': colorMap['line'],
        'lumio-surface': colorMap['surface']
      },
      spacing: Object.fromEntries(
        Object.entries(base.dimension)
          .filter(([k]) => k.startsWith('space-'))
          .map(([k, v]) => [k.replace('space-', ''), v.$value])
      )
    }
  }
};
```

For **CSS Modules / vanilla CSS**:

Import `tokens.css` once in your root:

```css
/* styles/global.css */
@import "../share/design/T-2026-07-20-002/03_system/tokens/tokens.css";
```

Then reference `var(--color-primary)` etc. in component styles.

For **Style Dictionary** (multi-platform export):

```bash
npm install style-dictionary
npx style-dictionary build --source share/design/T-2026-07-20-002/03_system/tokens/base.json
```

## Top 3 things NOT to do

1. **Don't introduce a new color** outside the tokens. If you need one, escalate to am-design.
2. **Don't hardcode spacing** (e.g. `padding: 13px`). Use `--space-3` or `--space-4`.
3. **Don't add emoji** as UI elements. Use SVG icons or text labels.

## Open questions for am-coder to surface to master

1. **Product screenshot**: shipped as gray placeholder. When the real screenshot is ready, replace `hero-shot` content.
2. **Real copy**: shipped as placeholder text. A follow-up WRITE-mode dispatch will provide final copy.
3. **Hover states**: not shown in static mockup. Implement standard hover darkening on `--color-primary` → `--color-primary-deep`.

## Self-critique

- ✓ All colors are tokens (var() in CSS, named entries in tokens.css).
- ✓ 3 breakpoints locked: 390 / 768 / 1440.
- ✓ Layout adapts: 1 col mobile, 2 col tablet features, 3 col desktop features.
- ✓ Hero shot uses `--color-primary-tint` (token, not raw hex).
- ✓ No emoji used.
- ✓ All text uses `--color-ink` (token).
- ⚠ Hero shot is a placeholder. Real asset is a follow-up.
- ⚠ Hover/focus states not shown in static mockup — am-coder implements standard pattern.

## Visual verification

Browser verification: opened `04_mockups/web-responsive/index.html`. Renders correctly at all 3 viewports. Spacing and color usage match token values. No inline hex outside token system.

## STATUS: DONE