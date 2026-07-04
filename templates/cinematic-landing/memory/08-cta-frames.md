# 08 · CTA frames — 3-frame click-advance pattern — USE THIS WHEN: composing CTA section copy + frame layout

The cinematic-landing template's CTA section uses a 3-frame click-advance pattern instead
of autoplay. Three reasons:

1. **No autoplay assumption.** Users with screen readers, low-bandwidth, or reduced-motion
   settings don't get surprised by animation.
2. **Each click is a ritual moment.** The CTA's job is to invite action; manual advance
   reinforces intent.
3. **Vendor-neutral.** No `<video>` dependency; works on Branch A, B, C, D identically.

## The 3 frames (copy skeleton)

```html
<section data-section="cta">
  <div class="cta-backdrop"><!-- blurred still or gradient --></div>
  <div class="cta-stage" data-stage="0">
    <h2 class="cta-copy">Discover the ritual</h2>
    <button class="cta-advance">→</button>
  </div>
  <div class="cta-stage" data-stage="1" hidden>
    <h2 class="cta-copy">Read the journal</h2>
    <button class="cta-advance">→</button>
  </div>
  <div class="cta-stage" data-stage="2" hidden>
    <h2 class="cta-copy">Shop the editions</h2>
    <button class="cta-advance">→</button>
  </div>
</section>
```

## The JS (~12 lines)

```js
let ctaStage = 0;
const stages = document.querySelectorAll('.cta-stage');
document.querySelector('.cta-advance')?.addEventListener('click', () => {
  stages[ctaStage].hidden = true;
  ctaStage = (ctaStage + 1) % stages.length;
  stages[ctaStage].hidden = false;
});
// Also advance on ArrowRight / Space when CTA is in viewport
document.addEventListener('keydown', (e) => {
  if ((e.key === 'ArrowRight' || e.key === ' ') && /* CTA in viewport */) {
    /* same advance logic */
  }
});
```

## Why not video

The v1 skeleton's CTA played a video playlist advanced by `ended` events. This required
a video asset (Branch A or B). The 3-frame pattern works on any branch. The user can
still attach a video if they want; the pattern is a fallback that doesn't depend on one.

## Hard rules

- **ALWAYS** make the advance trigger keyboard-accessible (Tab + Enter/Space).
- **ALWAYS** respect `prefers-reduced-motion: reduce` — disable the slow ken-burns pan
  on the backdrop; keep the click-advance (it's not motion, it's interaction).
- **NEVER** auto-advance on a timer. Manual only.