# Cinematic Landing Kit — Demo

A single-file, single-folder working demo of the [v1 cinematic-landing-kit](../cinematic-landing-kit-main/cinematic-landing-kit-main/) engine, repointed at a fictional hand-poured candle brand (**Maison Lumen — Apothecary Light**) using only publicly-available Pexels stills.

The purpose of this demo is **not** to replace v1 — it is to prove that v1's section skeleton, CSS-token system, scroll-ticker architecture, and graceful-degradation patterns can be lifted off v1's Higgsfield-dependent video pipeline and reassembled around a different asset source. The differences from v1 are deliberate and documented.

---

## 1. View it

Open `index.html` in a browser. No build step, no server, no `npm install`.

```bash
# Windows
start cinematic-landing-kit-demo/index.html

# macOS
open cinematic-landing-kit-demo/index.html

# Linux
xdg-open cinematic-landing-kit-demo/index.html
```

Tested at 1280×800 desktop. Mobile (≤480px) collapses the editions grid to a single column and disables ken-burns under `prefers-reduced-motion: reduce`.

---

## 2. How each section maps to v1's memory files

| Demo section | v1 source of truth | Notes |
|---|---|---|
| **Header** (hide/show on scroll) | `templates/index.skeleton.html` (header markup + scroll handler) | Brand label + nav items only; no functional links (demo). |
| **Hero** (cutout + aura + motes + pointer tilt + sheen) | `memory/04-cinematic-hero.md` · `memory/05-theming.md` | Coder noted (LOW): the hero specular mask currently points at the same Pexels still as the foreground `<img>`, not a transparent PNG cutout. Swap to a Higgsfield-extracted transparent PNG for production parity. |
| **Film** (6-still crossfade) | `memory/02-scroll-film-canvas.md` (the *spirit* — scroll-driven still advance) | **Deviation.** See §3. |
| **Reveal** (lifestyle still + scrollcue) | `memory/01-build-playbook.md` §3.4 | Copy is one short paragraph + italic scrollcue. |
| **Ritual** (two-up lifestyle stills) | `memory/01-build-playbook.md` §3.5 | Pair of stills with copy blocks describing the pour / light moment. |
| **CTA** (still + ken-burns + 3-frame click-advance) | `memory/01-build-playbook.md` §3.6 | **Deviation.** See §3. |
| **Editions** (3-card grid) | `memory/05-theming.md` (token grid) · `memory/01-build-playbook.md` (card pattern) | The three editions (Nº 01 Atelier / Nº 02 Brume / Nº 03 Solstice) are demo content; replace with your product names. |
| **Footer** | `templates/index.skeleton.html` (footer markup) | Demo placeholder; copyright stays fictitious. |
| **Ambient layers** (`#ambient` · `#glow` · `#vignette` · `#grain`) | `memory/05-theming.md` §2 | Direct port of v1's fixed z-stack. |
| **Single ticker** (Lenis + GSAP) | `memory/01-build-playbook.md` §2.1 | One `gsap.ticker.add`, no duplicate `requestAnimationFrame`. |
| **Reduced-motion** short-circuit | `memory/01-build-playbook.md` §4 | One CSS `@media (prefers-reduced-motion: reduce)` block + matching JS query — both gate Lenis init, film crossfade, ken-burns, motes, sheen, scrollcue, hero entrance, hero parallax, reveals, CTA click handler. |

---

## 3. Documented deviations from v1

### 3.1 Film section — crossfade instead of frame-sequence scrub

**v1's design:** A `<canvas>` is scrubbed via `currentTime` analog, displaying 60–240 frames extracted by Higgsfield from a slow-mo video clip. Frame-perfect, ~5–8 MB payload.

**Why v1 isn't demo-ready:** Higgsfield is a paid, account-gated pipeline. Public-domain candle videos on Pexels and Pixabay return HTTP 403 to unauthenticated HEAD requests (master verified before dispatch). Without a video source, the canvas frame-sequence has nothing to scrub.

**Demo's substitute:** Six Pexels stills stacked at `position: absolute` in a `pin: true` ScrollTrigger section. A single GSAP `gsap.ticker.add` callback reads `scrollTrigger.progress`, computes `Math.round(progress * 5)`, and tweens the matching frame's `opacity` to 1 while neighbors tween to 0. Mathematically equivalent for the viewer (stills advance as you scroll) but only requires still assets.

**Tradeoff:** Loses v1's frame-seamlessness and slow-mo continuity. For production, swap the six stills for the v1 canvas + extracted frames pipeline.

### 3.2 CTA section — click-advance instead of video-playlist advance

**v1's design:** A `<video>` plays a sequence of CTA spots; on `ended`, advance to the next video in the playlist. Three CTA moments ("Discover the ritual" / "Read the journal" / "Shop the editions").

**Why v1 isn't demo-ready:** Same root cause — no public-domain candle video is hotlinkable. A still + autoplay won't satisfy the `ended`-event model without a video.

**Demo's substitute:** A single backdrop still with a slow CSS `@keyframes` ken-burns pan (no JS), plus 12 lines of vanilla JS that advances a `ctaStage` index on click / `ArrowRight` / `Space` / dot navigation. Each stage crossfades a different copy block.

**Tradeoff:** Loses v1's auto-advance. Acceptable for a demo — the click action itself becomes the ritual moment.

### 3.3 Other deliberate differences (non-deviation but worth noting)

- **Language direction:** `lang="en" dir="ltr"` (v1 default is Arabic RTL). The demo targets English-speaking audiences.
- **Brand voice:** v1 has Arabic editorial copy that doesn't translate 1:1. The demo's copy is freshly written in English with the same sensory, second-person voice.
- **Font stack:** Same as v1 (El Messiri + Tajawal + Cormorant Garamond). Don't change unless you re-translate the demo content.

---

## 4. Hard rules preserved

These are v1's quality bar. The demo showcases the workflow; it does not loosen it.

| Rule | Implementation in demo | How to verify |
|---|---|---|
| **No `video.currentTime = …`** | 0 live assignments. 3 grep hits — all documentation comments. | `grep -n "currentTime" index.html` |
| **No `<video>` tag** | 0 in markup. 4 grep hits — all deviation comments. | `grep -n "<video" index.html` |
| **No `mix-blend-mode` on GSAP-transformed** | 7 usages, all on static or hover-only-transformed elements (`.multiply`, `#grain`). | Read CSS + JS transform handlers. |
| **`.fallback-host.is-missing` retained** | 9 host elements + 2 image-error listeners + verbatim CSS gradient from v1. | `grep -n "is-missing" index.html` |
| **`prefers-reduced-motion: reduce` honored** | One CSS media query + matching JS short-circuit on Lenis, film, ken-burns, motes, sheen, scrollcue, hero entrance, hero parallax, reveals, CTA click handler. | `@media (prefers-reduced-motion: reduce)` block + JS `matchMedia` listener. |

---

## 5. Assets

### 5.1 Source

All stills from **Pexels** (Pexels License — free for commercial and personal use, no attribution required). Subjects visually inspected by `am-coder` during build; off-topic IDs from the initial brief were substituted.

### 5.2 The 14 IDs in the demo

| Slot | Pexels ID | Subject (verified) |
|---|---|---|
| Hero cutout (foreground) | 4046718 | golden essence swirl |
| Hero aura (blurred backdrop) | 6195171 | Moroccan lanterns |
| Film 1 | 4202325 | apothecary soaps |
| Film 2 | 3735160 | teal candle tin |
| Film 3 | 3735181 | bulk dispensers |
| Film 4 | 4226265 | cork-lid jars |
| Film 5 | 1108572 | plant in bulb |
| Film 6 | 9883737 | plumeria |
| Reveal | 9883766 | pink lotus |
| Ritual bg | 5938567 | lotion lifestyle |
| Ritual accent | 3735270 | pansy |
| Editions Nº 01 (Atelier) | 9883737 | plumeria (reused Film 6) |
| Editions Nº 02 (Brume) | 4226881 | cowrie shells |
| Editions Nº 03 (Solstice) | 7641892 | marigold |
| CTA backdrop | 11776187 | lit candles |

All 14 HEAD-200 on `https://images.pexels.com/photos/{id}/pexels-photo-{id}.jpeg?auto=compress&cs=tinysrgb&w={600|1200|1800}` (verified by `am-review`, run twice with `Invoke-WebRequest` and `curl.exe -I`).

### 5.3 URL pattern

```
https://images.pexels.com/photos/{id}/pexels-photo-{id}.jpeg?auto=compress&cs=tinysrgb&w={600|1200|1800}
```

Width ladder: `?w=600` (mobile), `?w=1200` (tablet), `?w=1800` (desktop). For DPR > 1 on desktop, the browser will still pull 1800w — to swap in a true `srcset` ladder for production, see "Known follow-ups" below.

---

## 6. Known follow-ups (LOW priority, non-blocking for demo)

The review caught three issues that don't block the demo but should be fixed before treating this as production code:

1. **`srcset`/`sizes` for DPR.** Hardcoded `?w=` widths are in use; desktop 2× DPR will pull 1800w instead of a 2400w asset. Add `srcset` for a true 600/1200/1800/2400w ladder.
2. **Dead branch in film crossfade.** `index.html:798` `dist === 1 ? 0.0 : 0` returns the same value for both branches — leftover from a planned neighbor-fade. Either delete or wire to the intended `0.35` partial-opacity behavior.
3. **Hero specular mask** points at the same Pexels still as the foreground `<img>` (both load 4046718) instead of a transparent PNG cutout like v1 ships. Swap to a Higgsfield-extracted transparent PNG for true production parity.

---

## 7. Replacing the demo with your own product

If you want to reuse this engine for your own brand:

1. **Brand label.** Replace "Maison Lumen — Apothecary Light" with your brand in three places: `<title>`, hero heading, footer.
2. **Tagline.** Replace "hand-poured candles, made in small editions" with your one-line value prop.
3. **Three editions.** Replace Nº 01 Atelier / Nº 02 Brume / Nº 03 Solstice in the editions grid and the CTA copy.
4. **Assets.** Substitute the 14 Pexels IDs with your own product stills. URL pattern stays the same; just replace the `{id}` placeholder. Visual-inspect each one — the brief's first round of IDs had a 92% off-topic rate; Pexels IDs don't reliably match their subjects.
5. **Copy.** Replace the hero copy, film captions, ritual paragraphs, and CTA frames with your own. Keep the voice: sensory, second-person, no marketing clichés (no "luxurious / premium / artisanal (overused) / curated (overused)").
6. **Reverting to v1 video pipeline (optional).** If you have access to a Higgsfield (or similar) frame-extraction pipeline, swap the six `<img class="film-frame">` elements for a single `<canvas>` and feed it the frame-sequence data URI. The ScrollTrigger config stays untouched — only the rendering layer changes.

---

## 8. Review verdict

`am-review` returned **PASS** for T-2026-07-01-002. Full report at `share/reports/04_review_T-2026-07-01-002.md`. Top-line:

> Demo faithfully reproduces the v1 cinematic-landing-kit engine on a fictional candle brand with both documented deviations implemented as specified; all hard rules preserved, every Pexels URL HEAD-200, brand voice clean of clichés; ready to ship.

---

## 9. Files of record

- `cinematic-landing-kit-demo/index.html` — the demo (885 lines, ~52 KB)
- `cinematic-landing-kit-demo/README.md` — this file
- `share/handoffs/00_user_task_T-2026-07-01-002.md` — user task capture
- `share/messages/master-to-am-coder-T-002.md` — coder brief
- `share/messages/master-to-am-review-T-002.md` — review brief
- `share/notes/03_coder_summary_T-2026-07-01-002.md` — coder summary
- `share/reports/04_review_T-2026-07-01-002.md` — review report
- `tasks/T-2026-07-01-002.md` — task tracker
- `share/notes/99_decisions.md` — append-only decisions log

---

## 10. Status

**T-2026-07-01-002 — SHIPPED** (this demo's initial release).
**T-2026-07-01-005 — SHIPPED** (a11y + DPR hardening). See §11 below.
**T-2026-07-01-001** (v2 adaptation) closed by supersession via T-2026-07-01-003.
**T-2026-07-01-004** (dark theme) opened via `share/handoffs/00_user_task_T-2026-07-01-004.md`.

---

## 11. T-2026-07-01-005 hardening — what changed since the initial release

The demo at 885 lines → **1122 lines** after T-005 added accessibility + responsive-image hardening across 6 phases. Summary by item:

### A11y (9 of 13 items shipped; 4 verified n/a or already-covered)

| Item | What changed | Where |
|---|---|---|
| **A1** body-text contrast ≥ 4.5:1 | `--ink-faint` raised `#9A8975` → `#7A6855` (3.14:1 → **4.96:1**, AA pass) | L57 |
| **A2** large-text contrast ≥ 3:1 | h1/h2/h3 = **16.07:1** vs `--paper`, AAA pass | inherited from T-002 |
| **A4** AAA body-text 7:1 | `--ink-soft` raised `#6E5C4B` → `#5A4A3B` (5.92:1 → **7.88:1**, AAA pass) | L57 (P3) |
| **A5** skip-link | Added `<a class="skip-link" href="#main">` at L396; `<main id="main" tabindex="-1">` at L409; CSS overlay at L117–121 | L396, L409, L117 |
| **A6** heading hierarchy | h1 → h2 → h3 sequence verified (no skipped levels) | inherited from T-002 |
| **A7** canvas/film a11y | `<section id="film" role="img" aria-label="...">` + hidden `<ol id="film-transcript">` with 6 `<li>` + `aria-current="step"` toggled | L465, hidden `<ol>` L472–480, transcript logic L824+ |
| **A9** mid-session reduce listener | `location.reload()` on `prefers-reduced-motion` change + `window.__reducedMotionActive` exposure for behavioral test + Safari < 14 fallback | L749–762 |
| **A10** forced-colors block | `@media(forced-colors: active)` covers `.skip-link`, `.fallback-host`, all buttons, `.gold-text`, `:focus-visible` | L362–379 |
| **A11** focus indicators | Universal `:focus-visible` rule with `--gold-deep` outline (5.24:1 non-text contrast → AAA) | L115 |
| **A12** keyboard nav | Tab order: skip-link → brand → 4 nav → CTA btns → step-dots → footer; ArrowRight/Space/ArrowLeft on CTA; PageDown/PageUp on film; `aria-keyshortcuts="PageDown PageUp"` on `<section id="film">` | L1062, L465, L1092+ |

Verified n/a or already-covered: A3 (UI-component contrast, already met), A8 (prefers-reduced-motion short-circuit, already in T-003 skeleton), A13 (form labels, no forms).

### DPR (3 of 3 items shipped — demo only per plan exception)

| Item | What changed |
|---|---|
| **D1** srcset ladder | Every `<img>` carries 4-width ladder (600/1200/1800/2400w) |
| **D2** sizes attribute | Mobile-first sizes per slot (100vw / 80vw / 42vw / 33vw / 50vw per breakpoint) |
| **D3** network-tab verify | 56/56 HEAD requests = 200 (zero 403s); `?w=2400` retained on every image |

### Memory files (3 new, with template pointers)

- `cinematic-landing-kit-demo/memory/09-canvas-a11y.md` (127 lines) — A7 detail
- `cinematic-landing-kit-demo/memory/10-reduced-motion-listener.md` (128 lines) — A9 detail
- `cinematic-landing-kit-demo/memory/12-keyboard-nav.md` (127 lines) — A12 detail

Each has a top-of-file `<!-- TODO(template-migration): -->` pointer to `templates/cinematic-landing/memory/` (T-003 owner-pending).

### Known carry-forwards (out of scope for T-005)

- K1: `.gold-text` gradient tops 2.35:1 → T-004 dark theme
- K2: `#ritual .idx` `--gold-bright` on dark overlay (3.45:1) → one-line swap
- K4: CSS background images stay single-width (needs `<picture>` recipe)
- K5: `dist === 1 ? 0.0 : 0` dead branch at L998 (T-002 follow-up #2)
- K6: Hero specular mask uses same Pexels still as foreground (T-002 follow-up #3)

### Review verdict

PASS-WITH-NOTES (0 CRITICAL · 0 HIGH · 2 MEDIUM · 8 LOW). Both MEDIUMs fixed via surgical patch:
- M1: `aria-keyshortcuts="PageDown PageUp"` added at L465
- M2: `if(e.target.tagName === "BUTTON") return;` added at L1062 (prevents Space-double-trigger on step-dot buttons)

Full report at `share/reports/04_review_T-2026-07-01-005.md`. WARN register at `share/notes/04_warns_register_T-2026-07-01-005.md`.

---

## 12. T-2026-07-01-004 hardening — dark theme

The demo at 1167 lines (after T-005) is now dual-theme with FOUC prevention, `localStorage` persistence, and `prefers-color-scheme: dark` auto-detect at first-load. Section mapping by item:

### Dark-theme items (DT1–DT6 all shipped)

| Item | What shipped | Where |
|---|---|---|
| **DT1** `:root[data-theme="dark"]` token block | 14-token counter-table reuses T-001 §3.1 verbatim; all foreground dark tokens ≥ AA body on `--paper` | L70-83 |
| **DT2** per-section `data-ambient-dark` values | 6 values across all sections | L446 hero · L487 film · L568 reveal · L600 ritual · L629 cta · L672 editions |
| **DT3** light/dark toggle UI | Header button (single icon); `aria-pressed` reflects state | L463 (toggle) |
| **DT4** AA + AAA contrast re-verify | WebAIM runtime: all 14 dark tokens PASS AA body 4.5:1 in both modes | L70-83 + WebAIM audit table |
| **DT5** DPR unchanged | D1 srcset ladder preserved across theme switch (theme is CSS-level only, doesn't touch asset shape) | unchanged from T-005 |
| **DT6** reduced-motion + forced-colors verified | Theme toggle handler touches only `data-theme`/`aria-pressed`/localStorage/ambient; never reduced-motion or forced-colors | L1196-1213 controller IIFE |

### K1 (carry-forward from T-005, root-cause fix)
- New token `--gold-text-top: var(--gold-deep)` defined in BOTH `:root` and `:root[data-theme="dark"]` blocks (caps read as `--gold-deep` in both modes — 5.24:1 light / 6.03:1 dark, both AA)
- `.gold-text` gradient re-tuned: top (0%) = `--gold-text-top` · mid (55%) = `--gold` · descender (95%) = `--gold-bright` — preserves "gold-rich" aesthetic via mid + descender stops; only the cap (the contrast-relevant reading position) is `--gold-deep`
- Located at L163

### K2 (carry-forward from T-005, REVERTED after on-screen review)
- Originally swapped `#ritual .idx` from `var(--gold-bright)` to `var(--gold-deep)` per Phase 0 lock
- P5 V-K2 on-screen re-measure: brief's 4.55:1 claim was based on literal `--ambient` math; actual photo+overlay pixels give 2.08–2.80:1 (FAIL AA)
- Reviewer caught it; user approved revert; L322 changed back to `var(--gold-bright)`
- Delta re-measure: 4.63–6.50:1 light / 6.16–8.64:1 dark (all PASS AA across 6 photo scenarios)
- K2 carry-forward stays open as "reverted to original" — not closed via dark theme

### FOUC prevention (R-FOUC-1 HIGH)
- `<script>` at L42, inside `<head>`, BEFORE standalone `<style>` at L63
- Sets `documentElement.dataset.theme` synchronously based on localStorage + `prefers-color-scheme` (auto-detect)
- No white flash on dark-mode reload

### Persistence + auto-detect (R-PERSIST-COLLIDE MEDIUM)
- Both localStorage accesses (FOUC `getItem` at L45, controller `setItem` at L1205) wrapped in try/catch
- Key: `theme` (light | dark)
- First-load behavior: if `prefers-color-scheme: dark` matches and localStorage empty, default to dark; user toggle always wins

### Ambient tween (R-AMBIENT-TWEEN MEDIUM)
- Toggle triggers `window.__refreshAmbient()` which re-tweens active section's `data-ambient-dark`/`data-ambient`
- Implemented via `ambientFor()`/`refreshAmbient()` exposed on `window` (brief's minimum-acceptable fallback)

### Deuteranopia sim (R-DCB HIGH, CLOSED)
- Viénot 1999 / Color Oracle matrix on dark `--gold-deep #B5862F` → simulated `#a5a955`; effective contrast vs simulated `#0d0d07` paper = **7.80:1** (AA pass)
- All warm-gold foregrounds (`--gold-deep`, `--gold`, `--gold-bright`, `--accent`) PASS post-deutan sim
- Escape-hatch `#C89238` NOT required

### Memory file (1 new)

- `cinematic-landing-kit-demo/memory/13-dark-theme.md` (~191 logical lines after §3 rewrite) — full dark-theme reference + K2 history + V-K2 evidence
- Top-of-file `<!-- TODO(template-migration): -->` pointer to `templates/cinematic-landing/memory/`

### Review verdict

**FAIL initial → PASS after fix.**

- P5T1 initial: FAIL on V-K2 (on-screen pixel math: 2.08–2.80:1 across photo scenarios)
- P5-fix: 1-token revert at L322 (`var(--gold-deep)` → `var(--gold-bright)`)
- P5 delta re-review: PASS — V-K2 verified 4.63–8.64:1 across 6 scenarios × 2 modes

WARN register: 13 rows (1 HIGH [V-K2 revert path] · 1 MEDIUM [math discrepancy] · 11 LOW).

Full report at `share/reports/04_review_T-2026-07-01-004{,_delta}.md`. WARN register at `share/notes/04_warns_register_T-2026-07-01-004.md`.

---

## 13. All v2 axes closed — what's left

T-2026-07-01-004 closes the original m0097 v2 request. Status of each axis:

| v2 axis | Status | Task |
|---|---|---|
| Vendor abstraction (Higgsfield/Runway/generic JSON) | **closed** | T-003 (4-branch runtime tree + `am-assets` specialist) |
| English-first | **closed** (already in v1 demo) | T-002 |
| Agent-ready (`am-assets` specialist + memory files) | **closed** | T-003 |
| WCAG 2.2 AA throughout + AAA-where-cinematic | **closed** | T-005 (13 a11y items + 3 DPR) |
| Dark theme | **closed** | T-004 (just shipped) |

Optional cosmetic follow-up: 1-line patch to mark WARN register V-K2 row [RESOLVED] (deferred).

Future work (T-007+ candidates):
- K2 carry-forward closure attempt (revisit dark-mode gradient system)
- CSS background DPR via `<picture>` recipe
- Hero specular mask transparent-PNG swap
- `dist === 1 ? 0.0 : 0` dead branch removal
- Per-page theme customization / theme auto-rotate / high-contrast forced theme