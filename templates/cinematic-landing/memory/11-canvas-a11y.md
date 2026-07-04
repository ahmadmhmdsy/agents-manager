# 11 · Canvas (or Still-Crossfade) A11y — USE THIS WHEN: shipping a `<canvas>` that conveys meaning and needs a screen-reader fallback

How to expose a scroll-driven visual film to screen readers without losing the cinematic experience. Adapted from v1's `<canvas>` + hidden `<ol>` transcript recipe for the demo's 6-still crossfade variant.

## Why this matters

Scroll-driven film sections are visually stunning and **completely opaque** to screen readers unless you deliberately add a parallel text layer. Without it, AT users get nothing while sighted users get a six-beat story. The v1 pattern — `role="img"` + dynamic `aria-label` + hidden ordered-list transcript with `aria-current="step"` — solves this in 30 lines of HTML and 15 lines of JS.

## v1 → demo adaptation

v1's film section is a single `<canvas>` scrubbed by `currentTime`. The demo uses **6 still `<img>` elements** stacked at `position:absolute` in a `pin:true` ScrollTrigger section. The a11y pattern adapts cleanly:

| v1 pattern | Demo adaptation |
|---|---|
| `<canvas role="img" aria-label="...">` | Add `role="img" aria-label="..."` to the **film wrapper** (`<div class="stage">` inside `<section id="film">`). The section itself stays a `section` (programmatic `region`); the inner stage becomes the image. |
| `<canvas>` is the only visible frame | All 6 `<img>` get `aria-hidden="true" alt=""` (decorative — meaning is in the wrapper label + transcript). |
| Hidden `<ol>` transcript synced to scrub | Build a hidden `<ol class="film-transcript">` containing 6 `<li>` items, one per still. Each `<li>` carries a 1–2 sentence sensory description. |
| `aria-label` updates with progress | On each `gsap.ticker.add` callback that computes frame index, set the wrapper's `aria-label` to `"… film still N of 6 advancing with scroll"` AND toggle `aria-current="step"` on the matching `<li>`. |

## Markup recipe (demo, applied)

```html
<section id="film" data-ambient="…" tabindex="-1">
  <div class="stage fallback-host" id="filmStage"
       role="img"
       aria-label="Maison Lumen — Apothecary Light, six film stills advancing with scroll">
    <div class="frame-stack" id="filmStack">
      <img class="film-frame" data-index="0" alt="" aria-hidden="true" … />
      … 6 stills, all alt="" + aria-hidden="true" …
    </div>
    <ol class="film-transcript" id="filmTranscript" aria-label="Film transcript">
      <li data-step="0">Frame 1 of 6 — A tray of hand-cut apothecary soaps …</li>
      … 6 <li>s …
    </ol>
    …
  </div>
</section>
```

The `<ol>` is visually hidden via the standard 1×1 px clipped pattern (NOT `display:none` — that breaks some screen readers).

```css
.film-transcript{position:absolute; width:1px; height:1px; padding:0; margin:-1px;
  overflow:hidden; clip:rect(0 0 0 0); clip-path:inset(50%); white-space:nowrap; border:0}
```

## The 6 still descriptions (sensory, 1–2 sentences each)

| # | Pexels ID | Subject | Description |
|---|---|---|---|
| 1 | 4202325 | apothecary soaps | A tray of hand-cut apothecary soaps in soft pastels rests on a marble counter, each bar labeled in a small serif hand. |
| 2 | 3735160 | teal candle tin | A single teal candle tin sits at the center of a wooden table, an afternoon's light pooling around its base. |
| 3 | 3735181 | bulk dispensers | Glass bulk dispensers hold a row of dried herbs and powders, catching the late light through their amber contents. |
| 4 | 4226265 | cork-lid jars | A line of cork-lid jars holds the day's small measures — each one a different grain, a different scent. |
| 5 | 1108572 | plant in bulb | A single plant grows inside a glass bulb vase, its leaves held still against a soft window-lit background. |
| 6 | 9883737 | plumeria | A plumeria opens, white and waxy, the petals catching a slow side-light before they fall. |

These are the demo's verified subjects (per `cinematic-landing-kit-demo/README.md` §5.2). When porting to a new product, regenerate sensory descriptions from your own frame list — keep voice (second-person optional, no marketing clichés).

## GSAP callback pseudocode

```js
// Inside the existing film init scope:
const stageEl = document.getElementById("filmStage");
const steps   = Array.from(document.querySelectorAll("#filmTranscript li"));

function filmUpdate(p) {
  const target = clamp(Math.round(p * (N - 1)), 0, N - 1);
  // … existing opacity + caption logic …

  // A7 — wrapper aria-label memo'd so we don't setAttribute 60×/sec when unchanged.
  if(stageEl){
    const n = target + 1;
    if(stageEl._lastFilmN !== n){
      stageEl._lastFilmN = n;
      stageEl.setAttribute("aria-label",
        "Maison Lumen — Apothecary Light, film still " + n + " of " + N + " advancing with scroll");
    }
  }
  // A7 — toggle aria-current="step" on the matching transcript <li>.
  if(steps.length){
    steps.forEach((li, i) => {
      if(i === target) li.setAttribute("aria-current", "step");
      else li.removeAttribute("aria-current");
    });
  }
}
```

The memo on `_lastFilmN` avoids a `setAttribute` per scroll tick (60 Hz on most browsers) — only fires when the index actually changes.

## Why `aria-current="step"` and not `"true"`

`aria-current` accepts the enumerated values `page | step | location | date | time | true | false`. For a multi-step transcript where you're advancing through a sequence, `"step"` is the correct semantic — `"true"` would be ambiguous if there are multiple "current" things on the page. JAWS/NVDA/VoiceOver all announce "step N" when they see this attribute.

## How to verify (no axe rule for this — manual)

1. **Tab to the skip-link → Enter.** Land inside `<main>`.
2. **Tab through to the film section.** Screen reader announces "graphic, Maison Lumen — Apothecary Light, six film stills advancing with scroll".
3. **Scroll slowly through the pinned section.** At each crossfade boundary, the wrapper label updates to "… film still N of 6 …" (use a MutationObserver in DevTools to confirm).
4. **Inspect `#filmTranscript li[aria-current]`** at scroll progress 0 / 16 / 50 / 84 / 100 % — exactly one `<li>` has `aria-current="step"` at each sample (index 0, 1, 2, 3, 4, 5).
5. **VoiceOver swipe** (VO→VO↓) through the transcript — each `<li>` is announced with its description. The current step is announced as "Frame N of 6 — description, current step".
6. **`prefers-reduced-motion: reduce` ON.** Film section collapses to height:100vh; only frame 1 visible. Verify the wrapper label is still "… film still 1 of 6 …" and only the first `<li>` has `aria-current` (set on init).

## Why not use `<figure>` + `<figcaption>` for each still

You could, but `<figure>` is a semantic pair (figure + caption as ONE accessible name). For 6 figures stacked at the same coords, the screen reader would announce all 6 captions on focus — noisy. The `role="img"` wrapper with one aria-label + a separate transcript list is the clean pattern for "many sub-frames within one visual region".

## Why the `<li>` descriptions say "Frame N of 6 — …" rather than just "…"

Because the transcript is reachable as a static list (some users navigate it manually). The "Frame N of 6" prefix lets the user know where they are in the sequence without having to track the wrapper label separately. It's the same role as a chapter heading on a sub-section.

## Common pitfalls (caught during build)

- **`display:none` on the transcript** breaks some screen readers — they will not announce elements hidden this way. Use the 1×1 px clip pattern instead.
- **Setting `aria-current` on the wrapper instead of the `<li>`** — AT will announce "current" once on the wrapper but not as "step N" within a sequence. The transcript `<li>`s need their own `aria-current` so the list semantics are intact.
- **Setting `aria-label` every tick** without memoization → browser layout thrash → measurable scroll-jank on low-end hardware. Memo on `_lastFilmN`.
- **Removing the descriptive `<li>` text from the DOM** in reduced-motion mode — keep it; the static list is still useful even when the visual is collapsed.

## Status

Applied to `cinematic-landing-kit-demo/index.html` (film section, lines 463–528, JS callback at lines ~940–960). Verifies on VoiceOver + NVDA 2024.27+. Pattern is template-ready — when T-003 applies, this file moves to `templates/cinematic-landing/memory/09-canvas-a11y.md`.
