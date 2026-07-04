# 07 · Reduced-motion — the a11y floor — USE THIS WHEN: shipping animation, transitions, or scroll-driven effects that need reduced-motion gating

The cinematic-landing template honors `prefers-reduced-motion: reduce` at three layers:
CSS, JS, and markup.

## Layer 1 — CSS media query

```css
@media (prefers-reduced-motion: reduce) {
  /* Disable all CSS-driven motion */
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
  /* Hide decorative-only layers */
  .motes, .sheen, #grain { display: none; }
  /* Make scrollcues static */
  .scrollcue::after { content: "↓" }
}
```

## Layer 2 — JS matchMedia listener

```js
const motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
const reducedMotion = motionQuery.matches;

if (!reducedMotion) {
  // Init Lenis
  // Init GSAP ScrollTrigger
  // Init pointer tilt
  // Init sheen animation
  // Init CTA click handler
}

// Listen for mid-session change (user toggles system setting)
motionQuery.addEventListener('change', (e) => {
  if (e.matches) {
    // Teardown: stop Lenis, kill ScrollTriggers, remove tilt
    // Reset to native scroll
  } else {
    // Re-init the above
    location.reload(); // simplest correct behavior
  }
});
```

## Layer 3 — Markup

- `<html lang="en" dir="ltr">` (default; flips via `04-locale-handoff.md`)
- `<canvas role="img" aria-label="...">` (when canvas is used in Branch A)
- Hidden `<ol>` transcript synced to scrub (Branch A only; provides alt-text equivalent
  for screen readers)
- Skip-link `<a href="#main" class="skip-link">Skip to content</a>` as the first focusable
  element

## Hard rules

- **ALWAYS** include the CSS media query AND the JS matchMedia listener. CSS-only is
  insufficient because GSAP-driven motion is JS.
- **ALWAYS** include the mid-session `change` listener. Users toggle this setting live.
- **NEVER** make the reduced-motion path slower than the regular path. If anything, it
  should be faster (no animation overhead).

## Why this matters

The cinematic-landing aesthetic is heavy on motion. Without `prefers-reduced-motion`,
users with vestibular disorders, ADHD, or migraine triggers cannot use the site. The
a11y floor is non-negotiable per the v1 hard rules.