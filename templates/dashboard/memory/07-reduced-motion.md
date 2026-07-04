# 07 · Reduced motion — CSS + JS gating, mid-session listener — USE THIS WHEN: gating transitions, chart draws, and route changes when prefers-reduced-motion: reduce

Two layers, both required:

1. **CSS** — `@media (prefers-reduced-motion: reduce)` block zeroes
   transitions and animations, replaces infinite tweens with static states.
2. **JS** — `matchMedia('(prefers-reduced-motion: reduce)')` listener
   detects the OS-level toggle mid-session and re-applies the gated behavior
   without a reload.

The cinematic-landing template handles this in two memory files
(`memory/07-reduced-motion.md` + `memory/12-reduced-motion-listener.md`).
Dashboard collapses them into one because the work is shorter — animations
are limited to route fades + form-error pulses + hover bg tweens, not the
long-scroll ambient of cinematic.

## CSS layer

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

The blanket zero is fine for v0.1.0. Per-cubic-bezier overrides can come
later if a specific animation feels wrong under reduced-motion (e.g., a
route fade that's actually useful as a 100ms opacity hint).

## JS layer

```js
const mq = matchMedia('(prefers-reduced-motion: reduce)');
function applyMotion() {
  document.documentElement.dataset.reducedMotion =
    mq.matches ? 'reduce' : 'no-preference';
}
mq.addEventListener('change', applyMotion); // mid-session toggle
applyMotion(); // initial paint
```

`document.documentElement.dataset.reducedMotion` is the JS-readable form.
Component code reads this attribute (not `matchMedia.matches` directly) so
that a future server-side render or test can override it.

## Hard rules

### Rule 1 — Both layers, not either

CSS-only gates break mid-session toggles (page reloads only on refresh).
JS-only gates miss animations that run before script executes (FOUC-style
flicker on first paint). Both.

### Rule 2 — The gated behavior MUST still be functional

Don't disable functionality; disable the *animation*. A reduced-motion user
should still be able to sort a column, submit a form, navigate routes —
they just shouldn't see the column-header tick or the route fade.

### Rule 3 — `scroll-behavior: auto !important` is non-negotiable

Smooth scroll on hash-link clicks is delightful for some users and
disorienting for others with vestibular disorders. Override to auto under
reduced-motion.

## Worked trace

Atlas Admin: route change → 200ms opacity fade. Under reduced-motion
(`matchMedia.matches === true`), the fade is skipped; the section just
becomes visible. Sort-header click → 150ms background tween. Under
reduced-motion, the background snaps instantly. Both layers wired; mid-
session toggle from OS settings re-applies within ~50ms.

If you want to test: Chrome DevTools → Rendering → "Emulate CSS media
feature prefers-reduced-motion". Toggle without reloading.
