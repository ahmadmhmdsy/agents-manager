# Video generation prompts

Copy-paste these into Sora, Runway Gen-3, Veo 2, Pika, or any compatible video
generator. Produces a single slow-mo clip that the cinematic-landing template can
use in Branch B (`<video>` ambient) or Branch A (after frame extraction).

## Hero slow-mo (30s)

```
A 30-second slow-motion shot of [USER: their product] being lit / poured /
opened / placed. Camera slowly pushes in. Warm golden-hour lighting.
Style: cinematic, calm, ritual. NOT fast-paced.
Avoid: text, logos, people in focus, jarring cuts.
Aspect ratio: 16:9, 24fps, 1920×1080 minimum.
```

## Film sequence (60–90s)

```
A 60–90 second montage of [USER: their product] in different states: raw material
→ process → finished → in use. Slow dissolves between shots. Warm lighting throughout.
Style: cinematic, editorial, sensory.
Avoid: text, logos, dialogue, fast cuts.
Aspect ratio: 16:9, 24fps, 1920×1080 minimum.
[USER: produce 1 long clip OR 5–6 short clips to be crossfaded]
```

## How to use

1. Replace `[USER: ...]` placeholders.
2. Generate.
3. For Branch A (canvas frame-sequence): use a frame-extraction tool (ffmpeg:
   `ffmpeg -i input.mp4 -vf "fps=24" frames/frame_%04d.png`) to produce 60–240 PNGs.
4. For Branch B (video ambient): drop the mp4 directly into `assets/video/`.
5. Add to `assets/MANIFEST.json` per branch.