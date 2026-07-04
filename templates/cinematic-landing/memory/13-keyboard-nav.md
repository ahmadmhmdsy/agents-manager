# 13 · Keyboard Navigation for Cinematic Single-Page Sites — USE THIS WHEN: shipping focus-visible, Tab order, or scroll-snap keyboard handling

Three additive key bindings for a scroll-driven single-file page: section-snap (PageDown/PageUp), CTA-frame advance (ArrowRight/Space), CTA-frame retreat (ArrowLeft). Designed to coexist with native scroll and form-field behavior.

## The rule

Scroll-driven cinematic pages must be **fully operable by keyboard alone** — Tab walks the focusable elements in document order, Enter/Space activates, arrow keys do the right thing in context. Sighted users get a "film" — keyboard users get the same story told through focus, scroll position, and section labels. Anything less is a WCAG 2.1.1 (Keyboard) failure.

## Three key bindings (additive — never replace native)

| Key | Scope | Behavior |
|---|---|---|
| **PageDown / PageUp** | document | Scroll-snap to next/previous `<section>`. Each `<section>` becomes keyboard-focusable (`tabindex="-1"`); `el.focus({preventScroll:true})` shifts focus without compounding the scroll jump. |
| **ArrowRight / Space** | CTA section only | Advance to next `ctaStage` index. Reuses the existing click handler's `next()`. |
| **ArrowLeft** | CTA section only | Retreat to previous `ctaStage`. **Wraps** (0→2→0) to match the click handler's modulo arithmetic. |

### Why wrap on ArrowLeft

The brief allowed either wrap or block-at-boundary. **Wrap** wins because the existing `show()` already wraps via modulo — using wrap on keyboard matches click behavior with no surprise for users switching input methods. Block-at-boundary would need a no-op + aria-live "at end" announcement — adds noise, gains little.

## The `<section tabindex="-1">` requirement

Sections aren't natively focusable. `tabindex="-1"` adds them to the programmatic-focus set (`el.focus()` works), keeps them out of the Tab order, and **triggers `:focus-visible`** when focus arrives via keyboard (UA heuristic). The demo's CSS adds a gold-deep ring:

```css
section:focus-visible{outline:3px solid var(--gold-deep); outline-offset:-3px}
```

`outline-offset:-3px` draws the ring **inside** the section so it doesn't spill into the next section's viewport on edge-aligned layouts.

## Markup recipe

```html
<section id="hero"     … tabindex="-1">…</section>
<section id="film"     … tabindex="-1">…</section>
<section id="reveal"   … tabindex="-1">…</section>
<section id="ritual"   … tabindex="-1">…</section>
<section id="cta"      … tabindex="-1">…</section>
<section id="editions" … tabindex="-1">…</section>
```

## JS recipes

```js
/* PageDown / PageUp — section-snap, document-level */
if(!reduce){
  const sectionEls = Array.from(document.querySelectorAll("main section[id]"));
  function currentSectionIdx(){
    const mid = window.innerHeight / 2;
    let idx = 0;
    for(let i = 0; i < sectionEls.length; i++){
      if(sectionEls[i].getBoundingClientRect().top <= mid) idx = i;
    }
    return idx;
  }
  document.addEventListener("keydown", e => {
    if(e.key !== "PageDown" && e.key !== "PageUp") return;
    const t = e.target;
    // Form fields opt out — PageDown inside textarea = page-down-within-text.
    if(t && t.closest && t.closest("input,textarea,select,[contenteditable]")) return;
    const dir = e.key === "PageDown" ? 1 : -1;
    const tgt = sectionEls[Math.max(0, Math.min(sectionEls.length - 1, currentSectionIdx() + dir))];
    if(!tgt) return;
    e.preventDefault();
    try { tgt.focus({preventScroll:true}); } catch(_) {}
    if(lenis) lenis.scrollTo(tgt, {offset:0});                          // Lenis smooth
    else tgt.scrollIntoView({behavior:"smooth", block:"start"});       // native fallback
  });
}

/* CTA-scoped arrow keys (window-level, gated on visibility OR focus) */
if(!reduce){
  let ctaInView = false;
  if("IntersectionObserver" in window){
    new IntersectionObserver(es => { ctaInView = !!es[0] && es[0].isIntersecting; },
      { threshold: 0.35 }).observe(document.getElementById("cta"));
  }
  window.addEventListener("keydown", e => {
    if(e.key !== "ArrowRight" && e.key !== " " && e.key !== "ArrowLeft") return;
    const focusInCta = e.target && e.target.closest && e.target.closest("#cta");
    if(!ctaInView && !focusInCta) return;   // gate FIRST (preserves native arrows elsewhere)
    e.preventDefault();
    if(e.key === "ArrowRight" || e.key === " ") next();
    else show(idx - 1);
  });
}
```

### Why IntersectionObserver for CTA scope (not focus-only)

Two reasons keyboard users trigger arrow keys in the CTA: (1) **focus inside CTA** (most common — tabbed to a step-dot or link), or (2) **CTA visible but focus elsewhere** (clicked a CTA `<a>`, focus moved, but they're still reading the CTA). IntersectionObserver at threshold 0.35 covers case 2; focus-only misses it.

### Why listener is on `window` (not `#cta`)

`window` receives all keydowns, including the ones where focus is on a `<button>` and Space default-activates it. `#cta`-level would miss case 2 above.

### Why `preventDefault()` is inside the gate

Outside the CTA, ArrowLeft/ArrowRight/Space must pass through: SR users browse by arrow keys, Space scrolls the page. The `if(!ctaInView && !focusInCta) return;` short-circuits **before** `preventDefault()`, preserving native behavior.

## Why use `lenis.scrollTo` (not `scrollIntoView({behavior:"smooth"})`)

Calling `scrollIntoView({behavior:"smooth"})` while Lenis is active would fight Lenis — both try to animate the scroll, producing a stutter. The recipe calls `lenis.scrollTo(tgt, {offset:0})` when Lenis is available; falls back to native `scrollIntoView` otherwise. `offset:0` lands at the section's top — for sticky-pinned sections like `#film` (560vh), this is the natural entry point.

## 4-step manual test

1. **Tab → skip-link → Enter.** Land on first focusable inside `<main>`. Verify focus ring is gold-deep with 3px outline.
2. **Press PageDown 6 times.** Cycle through hero → film → reveal → ritual → cta → editions. Each press moves focus AND scrolls. PageDown at editions = no-op.
3. **Tab into CTA** (via step-dots or frame `<a>`s). Press **Space** — next CTA frame appears. **ArrowLeft** — previous frame wraps.
4. **Press PageUp from CTA.** Scrolls to ritual. Press **ArrowLeft** in ritual = no-op (gate blocks). Verify arrow keys do nothing destructive outside CTA.

## Common pitfalls (caught during build)

- **Forgetting `tabindex="-1"` on sections** → `el.focus()` throws or silently no-ops. Add to ALL sections.
- **`preventDefault()` outside the gate** → breaks native arrow-key browsing for AT users. Gate FIRST.
- **`el.focus()` without `{preventScroll:true}`** → focus shifts AND browser jumps → double-jump on top of Lenis scroll.
- **`scrollIntoView({block:"center"})`** → lands mid-section, disorienting for pinned sections. Use `block:"start"`.
- **`tabindex="0"` on sections** → adds them to Tab order, breaking the focus-order contract (sections aren't interactive). Use `tabindex="-1"`.

## Status

Applied to `cinematic-landing-kit-demo/index.html`: `tabindex="-1"` on 6 sections; `section:focus-visible` CSS rule; PageDown/PageUp document-level listener; CTA-scope gate on the existing arrow-key listener. Pattern is template-ready — moves to `templates/cinematic-landing/memory/12-keyboard-nav.md` when T-003 applies.
