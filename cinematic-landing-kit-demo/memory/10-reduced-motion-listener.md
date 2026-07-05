<!-- MOVED → templates/cinematic-landing/memory/12-reduced-motion-listener.md (T-2026-07-03-003, 2026-07-03) -->
# 10 · Mid-Session `prefers-reduced-motion` Listener

How to handle the user toggling their OS-level "reduce motion" preference (or DevTools → Rendering → "Emulate CSS prefers-reduced-motion") **mid-session** — i.e. after the page has loaded and the init-time `matchMedia(...).matches` read has already happened. Adapted from the v1 T-003 template's `07-reduced-motion.md` recipe to the demo's six-beat-scroll single-file layout.

## Why this matters

A page that reads `prefers-reduced-motion` only at init and then never again is **broken under a single, common, real-world action**: the user toggles their OS reduce-motion preference while the page is already open. Sighted users in this state see continued ken-burns / motes / film crossfade / hero parallax / CTA click animation even though their preference says no. Screen-reader users with vestibular sensitivity are now seeing a layout that doesn't match their declared preference. WCAG 2.3.3 (Animation from Interactions) does not require a runtime listener, but the principle behind 2.2.2 (Pause, Stop, Hide) does — and the v2 plan's `presence-grep` acceptance under-specified the problem.

The P5T1 V5 acceptance is now **behavioral** — Playwright calls `page.emulateMedia({reducedMotion:'reduce'})`, waits `networkidle`, then asserts `window.__reducedMotionActive === true`, `window.scrollY === 0`, and `getComputedStyle(.motes span).animationName === 'none'`. All three pass automatically if the change handler triggers a `location.reload()`, because the init-time gating in `index.html` already reads the new state on the next pass.

## The locked decision: `location.reload()` on change

Per Q1 in research (user-confirmed `proceed` on the default in m0099): the change handler calls `location.reload()`. Smaller bug surface than a teardown-and-rebuild; precedent in `templates/cinematic-landing/memory/07-reduced-motion.md:758–760`.

**Why not soft teardown?** A teardown-and-rebuild alternative would need to:
1. Destroy the Lenis instance, the GSAP ScrollTriggers, the ScrollTrigger `pin` SPAs for the film section, the CTA keyboard listener, the PageDown/PageUp document-level listener, the IntersectionObservers on ambient/glow, the on-error `<img>` listeners, the 13 DPR `srcset` `<img>` loads, the canvas-replacement film crossfade state.
2. Re-init all of the above from a cold start.
3. Reset `window.scrollY` to the user's prior section anchor (or to 0).

That's ~80 lines of brittle code with edge cases around `ScrollTrigger.getAll().forEach(t => t.kill())` ordering, GSAP ticker double-add, and the film `frames.forEach` re-running before the new frames are decoded. `location.reload()` is one line and the browser handles every reset deterministically. Cost: ~200 ms of reflow on a slow connection — acceptable for a content page.

**When would teardown-and-rebuild win?** If the page were a long-lived app with server state, a session-bound form, or a 60fps interactive game where reload-state loss is costly. None of those apply here.

## The module (verbatim — applied at `index.html` L739–763)

```js
/* --- A9 — mid-session prefers-reduced-motion change listener ----------------
   v2 plan under-specified this as a presence-grep; P5T1 V5 makes it behavioral:
   emulateMedia({reducedMotion:'reduce'}) → expect window.__reducedMotionActive
   === true AND scrollY === 0 within 500ms. Q1 lock: location.reload() ... */
const reduceMql = matchMedia("(prefers-reduced-motion: reduce)");
let __lastReduce = reduceMql.matches;
window.__reducedMotionActive = reduceMql.matches;     // exposed for P5 V5 behavioral test
function onReduceChange(e){
  if(e.matches === __lastReduce) return;              // defensive no-op on spurious events
  __lastReduce = e.matches;
  window.__reducedMotionActive = e.matches;            // flip flag pre-reload (visible briefly)
  location.reload();                                   // Q1 lock — user-confirmed m0099
}
if(reduceMql.addEventListener){
  reduceMql.addEventListener("change", onReduceChange);
} else if(reduceMql.addListener){
  /* Safari < 14 fallback (no graceful degrade required for the demo) */
  reduceMql.addListener(onReduceChange);
}
```

The existing init-time `const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;` at `index.html` L736 is **kept untouched** — it gates Lenis init, the reveals ScrollTrigger, the hero entrance + 3D parallax, the ritual parallax, the film ScrollTrigger, the CTA click handler, the CTA arrow keys, and the PageDown/PageUp section snap. All eight `!reduce` branches are now correctly re-evaluated on every reload, which is the desired behavior.

## Why expose `window.__reducedMotionActive` as a global flag

Three reasons:

1. **Test observability** — P5T1 V5 needs a programmatic way to verify "the listener fired AND the new state took effect". The flag is a single-boolean contract; consumers read it without needing to re-call `matchMedia(...).matches` (which would be a second source of truth and could race with the reload).
2. **Future consumers** — any future Playwright / Cypress / manual-DevTools probe that wants to know "is reduce-motion currently honored by the runtime?" should be able to ask. A single global is the smallest correct API.
3. **Novel abstraction** — not present in the v1 recipe or the curated seed list. One LOC on `window`. Documented here so future devs can find the pattern.

The flag is set **before** the listener attaches and **again** inside the handler before `location.reload()` is called (visible for the brief moment between event and reload — then re-read from `reduceMql.matches` after reload completes).

## Defensive guard: `__lastReduce`

The `if (e.matches === __lastReduce) return;` line handles two edge cases:

1. **Test-environment quirks** — Playwright's `emulateMedia()` may emit `change` events with the same value in some browser/test combinations. Without the guard, a spurious event would trigger an unnecessary reload and break the test's "within 500 ms" budget.
2. **Theoretical SPA navigation** — if the page were ever converted to an SPA, the listener could fire on a back/forward cache restore where `e.matches` happens to equal the cached last-known value. Skipping the reload avoids a wasteful full-page refresh.

`__lastReduce` is closure-scoped so it persists across calls. It's updated **after** the guard check, so the next event with the same value still no-ops. It's intentionally not exposed on `window` — it's an internal implementation detail.

## Safari < 14 fallback

`MediaQueryList.addEventListener('change', …)` shipped in Safari 14 (Sep 2020). For pre-14 Safari (rare in 2026), the deprecated `addListener(…)` method is the equivalent. The `if (reduceMql.addEventListener)` feature-detection is the standard pattern — we don't bother with `removeListener` because the listener is page-scoped and the page unloads on `location.reload()` anyway.

For the demo (single-file, modern browsers in the supported list per README §7), the fallback is non-blocking. No graceful-degrade code path — if a hypothetical ancient Safari doesn't fire either listener, the user can refresh manually.

## P5T1 V5 verification (the behavioral acceptance)

Per `02_plan_phases_T-2026-07-01-005.md` P5-T1 §V5, the acceptance is a 4-step Playwright sequence:

```js
test('mid-session reduce toggle re-applies reduce state', async ({ page }) => {
  await page.goto('http://localhost:8123');
  await page.emulateMedia({ reducedMotion: 'no-preference' });
  await page.waitForLoadState('networkidle');
  expect(await page.evaluate(() => window.__reducedMotionActive)).toBe(false);

  // Trigger mid-session reduce (user flips OS pref)
  await page.emulateMedia({ reducedMotion: 'reduce' });

  // Q1 lock: handler calls location.reload()
  await page.waitForLoadState('networkidle');           // reload completes
  expect(await page.evaluate(() => window.__reducedMotionActive))
    .toBe(true);                                         // flag re-read after reload
  expect(await page.evaluate(() => window.scrollY)).toBe(0);
  expect(await page.evaluate(() =>
    getComputedStyle(document.querySelector('.motes span')).animationName
  )).toBe('none');                                      // CSS @media block re-applies
});
```

The three post-reload assertions are satisfied by the demo's existing init-time gating plus the CSS `@media (prefers-reduced-motion: reduce)` block at `index.html` L395–404 (the CSS reads the live `prefers-reduced-motion` value on every reflow, so no JS re-application is needed for it).

**Exit criterion:** `window.__reducedMotionActive === true` within 500 ms of `emulateMedia({reducedMotion:'reduce'})`. Measured by the Playwright `waitForLoadState('networkidle')` + the assertion pair.

## Manual verification (if you can spin a browser)

1. Open `cinematic-landing-kit-demo/index.html` in Chrome/Firefox/Safari.
2. In DevTools → Rendering tab → "Emulate CSS prefers-reduced-motion: reduce".
3. Page reloads within ~100 ms (you'll see a brief flash).
4. `console.log(window.__reducedMotionActive)` → `true`.
5. `console.log(window.scrollY)` → `0`.
6. `getComputedStyle(document.querySelector('.motes span')).animationName` → `'none'`.
7. Hover the hero — the 3D pointer parallax is gone (CSS-driven via the `prefers-reduced-motion` block).
8. Scroll to the CTA — the click-to-advance dots still work (vanilla click handler, not motion-gated), but the auto-advance CSS ken-burns is paused.
9. Flip DevTools back to "no-preference" — another reload; motes re-animate.

## Status

- **Applied:** `index.html` L739–763 (listener module) + L751 (init-time flag exposure).
- **Verification gates:** see `share/notes/03_coder_summary_T-2026-07-01-005_P4T4.md` for the 6 grep gates + `node --check` exit code.
- **Known limits:** no graceful-degrade for Safari < 14 (acceptable per demo scope).
- **Follow-up candidates** (not in P4T4 scope — deferred to future patches):
  - Soft teardown-and-rebuild module (~80 LOC) for long-lived-app scenarios.
  - A `prefers-reduced-motion: no-preference` → `reduce` *transition* state where the page smoothly fades Lenis out and crossfades to instant scroll, instead of hard-reloading. Useful when the page has user state (form fields, scroll anchor, video position) that reload would lose.