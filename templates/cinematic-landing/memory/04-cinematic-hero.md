# 04 · Cinematic hero — cutout + aura + motes + pointer tilt + sheen — USE THIS WHEN: designing the hero canvas with cutout/aura coordination

The hero is the cinematic-landing template's most opinionated section. Five layered
elements work together to produce the "ritual moment" effect.

## Layer 1 — Foreground cutout

A transparent PNG of the product (or a CSS-masked image of the product). Receives:
- Pointer-tilt: `transform: rotateX(...) rotateY(...)` driven by mousemove.
- Entrance: GSAP tween from `opacity: 0; scale: 0.92; translateY(40px)` on load.
- Parallax: subtle `translateY` driven by scroll position (≤8px range).

## Layer 2 — Aura

The same (or different) image, heavily blurred (`filter: blur(40px) saturate(0.85)`),
positioned behind the cutout. Provides the warm-halo glow.

**Hard rule:** Use a SECOND image for the aura, NOT the same image with `filter: blur()`
applied. Two images means the cutout can parallax without the aura also moving — better
separation. If only one image is available, use a `<canvas>` blur on a copy.

## Layer 3 — Motes

20–40 SVG `<circle>` particles with `cx`, `cy`, `r`, and per-particle `animation-delay`.
Slow upward drift via `@keyframes`. Opacity 0.05–0.20. Pointer-driven parallax
subtly shifts the mote field.

## Layer 4 — Pointer tilt

`mousemove` listener captures `clientX` and `clientY`, computes normalized
`(-0.5 .. +0.5)`, applies `rotateX(ny * 8deg) rotateY(nx * -8deg)` to the cutout.
`requestAnimationFrame`-throttled. Reduced-motion → disabled.

## Layer 5 — Masked sheen

A diagonal-gradient overlay (`linear-gradient(115deg, transparent 40%, white 50%, transparent 60%)`)
animated across the cutout via `background-position` keyframes. Period 6–8s. Reduced-motion
→ disabled.

## Z-stack

```
z=0   #ambient
z=1   #glow
z=2   #vignette
z=3   .aura (blurred backdrop)
z=4   .motes
z=5   .cutout (foreground)
z=6   .sheen (above cutout)
z=60  #grain (always-on grain texture)
```

## Hard rules

- **NEVER** `mix-blend-mode` on any element with a GSAP transform.
- **NEVER** mask the cutout with a gradient — use the actual transparent PNG.
- **NEVER** animate `width` / `height` for the pointer tilt — animate `transform` only
  (GPU-accelerated, no layout thrash).
- **ALWAYS** disable pointer tilt + sheen + motes drift under `prefers-reduced-motion`.