# 03 · Single ticker — Lenis + GSAP co-driven — USE THIS WHEN: implementing the single-ticker scroll system (Lenis + GSAP)

The cinematic-landing template uses ONE `requestAnimationFrame` loop, owned by GSAP. Lenis
attaches as the scroll source. ScrollTrigger watches ScrollTrigger-internal progress
events.

## The pattern (vanilla JS, ~40 lines)

```js
import Lenis from '@studio-freight/lenis';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

const lenis = new Lenis({
  duration: 1.2,
  easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
  smoothWheel: true,
});

gsap.ticker.add((time) => {
  lenis.raf(time * 1000);
});
gsap.ticker.lagSmoothing(0);

// Lenis drives ScrollTrigger
lenis.on('scroll', ScrollTrigger.update);
```

## Why one ticker

Multiple `requestAnimationFrame` loops fight for frame budget. GSAP's ticker is the single
point of coordination. Lenis's RAF is replaced by `gsap.ticker.add(lenis.raf)`.

## Hard rule

- **NEVER** add a separate `requestAnimationFrame` for hero parallax, sheen animation, or
  CTA timer. All motion goes through the GSAP ticker.
- **NEVER** use `setInterval` for scroll-driven motion. Scroll drives the ticker.
- **NEVER** call `lenis.raf()` outside the GSAP ticker callback.

## Reduced-motion

If `(prefers-reduced-motion: reduce)` matches, do NOT init Lenis. Native scroll takes over.
The site remains usable — just less cinematic.