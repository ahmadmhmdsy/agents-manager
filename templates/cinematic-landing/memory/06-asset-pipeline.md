# 06 · Asset pipeline — 4-branch runtime decision tree — USE THIS WHEN: sourcing assets through the 4-branch runtime tree

The cinematic-landing template MUST work whether the user has any combination of:
- A video pipeline (Higgsfield / Runway / Replicate / Sora)
- A standalone video file (mp4 / webm / mov)
- Public-domain or self-supplied stills (Pexels / Unsplash / Midjourney / DALL-E)
- Nothing at all

`am-assets` runs this decision tree at build time and records the branch in
`assets/MANIFEST.json`. The branch determines which implementation path the build takes
for each section.

## The 4 branches

```
                ┌──────────────────────────────────────────┐
                │ User has assets?                         │
                └──────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┬─────────────────┐
        ▼                 ▼                 ▼                 ▼
   ┌─────────┐       ┌─────────┐       ┌─────────┐       ┌─────────┐
   │ Branch A│       │ Branch B│       │ Branch C│       │ Branch D│
   │ Video   │       │ Video   │       │ Stills  │       │ Nothing │
   │pipeline │       │ file    │       │ only    │       │ yet     │
   └─────────┘       └─────────┘       └─────────┘       └─────────┘
        │                 │                 │                 │
        ▼                 ▼                 ▼                 ▼
   Path A in         Path B in         Path C in         Path D in
   memory/02         memory/02         memory/02         memory/02
```

## Branch A — Video pipeline (Higgsfield / Runway / Replicate)

The user has access to a frame-extraction pipeline that produces 60–240 PNG frames from a
slow-mo video. Branch A applies when:
- The user mentions Higgsfield / Runway / Replicate by name, OR
- The user provides an mp4 + an API key for a frame-extraction service, OR
- The user already has extracted frames in a folder.

**Implementation path:** Path A in `memory/02-scroll-film-canvas.md` — canvas frame-sequence
scrub. The hero cutout, if supplied as a transparent PNG from the same pipeline, uses it
directly; otherwise falls back to a CSS-masked image.

**Manifest schema:** `assets/MANIFEST.json` populated with `frames[]`, `hero_cutout.png`,
`aura_source.png`, plus `pipeline: "higgsfield" | "runway" | "replicate"`.

## Branch B — Standalone video file

The user has an mp4/webm/mov but no extraction pipeline. Branch B applies when:
- The user provides a single video URL or local file, OR
- The user says "I have a clip but no frames", OR
- The manifest `video_url` field is set.

**Implementation path:** Path B in `memory/02-scroll-film-canvas.md` — `<video>` ambient
playback + CSS parallax illusion.

**Manifest schema:** `assets/MANIFEST.json` populated with `video_url`, `video_poster`,
`video_duration`, `parallax_intensity` (0..1).

**Hard rule:** Do NOT scrub `video.currentTime` with scroll. Use CSS transforms only.

## Branch C — Stills only (Pexels / Unsplash / Midjourney / DALL-E)

The user has 1+ still images but no video. Branch C applies when:
- The user supplies image URLs or local files, OR
- The user says "I have product photos but no video".

**Implementation path:** Path C in `memory/02-scroll-film-canvas.md` — scroll-driven
crossfade of 5–6 stills.

**Manifest schema:** `assets/MANIFEST.json` populated with `still_urls[]` (5–6 entries,
each with `subject`, `aspect_ratio`, `source_license`), plus a hero `cutout_subject` and
`aura_subject`.

**Asset source hint:** if the user has none, point them at `prompts/image-gen.md` for a
Midjourney / DALL-E prompt they can paste.

## Branch D — Nothing yet

The user has no assets. Branch D applies when:
- The user says "I'll add images later" / "I don't have anything yet", OR
- The manifest is empty after `am-assets` runs the discovery ask.

**Implementation path:** Path D in `memory/02-scroll-film-canvas.md` — graceful fallback.
`.fallback-host.is-missing` renders a tasteful gradient on every section. The build ships
without blocking on missing assets.

**Manifest schema:** `assets/MANIFEST.json` populated with `branch: "D"`,
`ask_list: ["..."]`, plus a per-section "to supply" list. The user fills in over time.

**Concrete ask-list generator:** Branch D triggers `prompts/image-gen.md` +
`prompts/video-gen.md` to produce a copy-paste ask list the user can hand to themselves
or to a designer:

```
To complete this build, supply:
  1 hero transparent PNG (3000×4000, no background)
  6 lifestyle stills (1800×1200, vertical 3:2)
  3 product stills (1200×1500, square)
  OR 1 hero mp4 (1920×1080, slow-mo 60fps, ≤30s)
  OR 1 still sequence (5–6 frames, 2400×1600, sequential moments)

Recommended tools: Midjourney v6, DALL-E 3, Sora, Runway Gen-3, Veo 2.
See `prompts/image-gen.md` for ready-to-paste prompts.
```

## Why 4 branches

Cinematic-landing is a popular template. Users will arrive with every possible asset
state. A template that hard-codes "Branch C only" fails on the most common case (user has
nothing yet). A template that hard-codes "Branch A only" excludes the 90% who don't have
Higgsfield. The 4-branch tree handles every input identically.

## The runtime decision (in `am-assets`'s dispatcher)

```js
function pickBranch(manifest) {
  if (manifest.frames?.length || manifest.pipeline) return 'A';
  if (manifest.video_url) return 'B';
  if (manifest.still_urls?.length) return 'C';
  return 'D';
}
```

The branch is recorded in `manifest.branch` and consumed by `am-coder` when reading the
implementation path from `memory/02-scroll-film-canvas.md`.