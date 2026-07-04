# 02 · Scroll-driven film section — 3 implementation paths — USE THIS WHEN: shipping a scroll-driven `<canvas>` and need film-strip pacing rules

The "film" section is the cinematic-landing template's center-of-gravity moment. Three
implementation paths exist; pick per `memory/06-asset-pipeline.md`.

## Path A — Canvas frame-sequence scrub (Higgsfield-class pipelines)

A `<canvas>` is scrubbed via a `requestAnimationFrame` loop that draws the current frame
based on `scrollTrigger.progress * (frames.length - 1)`. Frames are pre-extracted PNGs
served from the user's CDN or local `assets/frames/`.

**Hard rule:** NEVER scrub `video.currentTime`. The canvas approach does NOT use `<video>`.

**When:** Branch A in the runtime decision tree.

## Path B — `<video>` ambient playback (standalone video files)

A single `<video autoplay muted loop playsinline>` plays continuously. Scroll position
does NOT affect playback time. A second JS layer adds a CSS parallax transform on the
container to create the illusion of scroll-driven motion.

**Hard rule:** NEVER attach `scrollTrigger` to `video.currentTime`. The illusion comes
from CSS transforms, not from video scrubbing.

**When:** Branch B in the runtime decision tree.

## Path C — Still-image crossfade (any pipeline)

5–6 stills stacked at `position: absolute` in a pinned ScrollTrigger section. A single
GSAP ticker callback reads `scrollTrigger.progress`, computes
`Math.round(progress * (N-1))`, and tweens the matching frame's `opacity` to 1 while
neighbors tween to 0. Mathematically equivalent for the viewer.

**Hard rule:** NEVER animate the `<img>` `src` attribute. Animate `opacity` only.

**When:** Branch C in the runtime decision tree (also the demo's actual implementation).

## Path D — Graceful fallback (nothing)

`.fallback-host.is-missing` renders a tasteful gradient. The user knows to supply assets
via `assets/MANIFEST.json` (Branch D's manifest asks for them concretely).

## Hard rules (apply to all paths)

1. **NEVER** `video.currentTime = …` (where `<video>` is used at all).
2. **NEVER** apply `mix-blend-mode` to any element GSAP is transforming.
3. **ALWAYS** use cutouts over blend tricks for the hero aura.
4. **ALWAYS** preserve `.fallback-host.is-missing` so any 404 renders a gradient.
5. **ALWAYS** honor `prefers-reduced-motion: reduce` — skip the Lenis init, skip the
   crossfade / scrub, jump straight to "scroll to read" mode.

## Why three paths

The cinematic-landing template MUST work whether the user has:
- An expensive frame-extraction pipeline (Branch A)
- A simple mp4 file (Branch B)
- Free stock stills (Branch C)
- Nothing yet (Branch D)

The user picks their path at build time. `am-assets` records the choice in
`assets/MANIFEST.json`.