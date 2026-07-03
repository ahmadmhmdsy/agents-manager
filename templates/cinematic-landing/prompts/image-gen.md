# Image generation prompts

Copy-paste these into Midjourney, DALL-E 3, Sora (image mode), Stable Diffusion XL,
or any compatible image generator. Each prompt is structured to produce an image
that matches the cinematic-landing template's hero / film / ritual slots.

## Hero cutout

```
A single object on a transparent background, lit from above by warm golden light.
Soft shadow beneath. Product-photography style, NOT illustrated.
Aspect ratio: 3:4 (portrait).
Style: editorial, calm, ritual-moment.
Avoid: text, logos, multiple objects, busy backgrounds.
[USER: replace "object" with their product — e.g. "a small ceramic candle"]
```

## Hero aura source

```
The same object as the hero, but soft-focus, in a warm dim room with candle-light
bokeh in the background. Aspect ratio: 16:9.
Style: lifestyle, atmospheric, intimate.
Avoid: hard edges, text, logos.
```

## Film still (×5–6)

```
A moment from a slow, deliberate ritual involving [USER: their product].
Hands visible. Warm golden-hour lighting. Soft depth of field.
Aspect ratio: 3:2 landscape.
Style: cinematic still, editorial.
Avoid: text, logos, multiple competing subjects.
[USER: produce 5–6 variants — different angles, different moments]
```

## Ritual still (×2)

```
A quiet tabletop scene: [USER: their product] beside raw materials (dried herbs,
small jars, linen cloth). Natural window light. Aspect ratio: 3:2.
Style: lifestyle, calm, intimate.
Avoid: people, clutter, text.
```

## Editions card (×3)

```
A single product on a neutral background, evenly lit, soft shadow.
Aspect ratio: 4:5.
Style: e-commerce, clean, true-to-color.
Avoid: lifestyle context, hands, multiple products.
[USER: produce 3 variants — one per edition]
```

## CTA backdrop

```
An atmospheric blur of [USER: their product category] — abstract enough to be a
background, evocative enough to set mood. Aspect ratio: 16:9.
Style: painterly, soft-focus, warm tones.
Avoid: hard edges, text, recognizable product silhouettes.
```

## How to use

1. Replace `[USER: ...]` placeholders with the user's product.
2. Paste the prompt into the image generator of choice.
3. Save outputs as PNGs (transparent for hero cutout) at the resolutions listed in
   `prompts/asset-spec.md`.
4. Add to `assets/MANIFEST.json` per branch.