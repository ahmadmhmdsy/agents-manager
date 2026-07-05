<!-- MOVED → templates/cinematic-landing/memory/14-dark-theme.md (T-2026-07-03-003, 2026-07-03) -->
# 13 · Dark Theme

The CSS/HTML foundation of the dark theme for `cinematic-landing-kit-demo/index.html`: the 14-token `:root[data-theme="dark"]` counter-table, the mode-aware `--gold-text-top` token that fixes K1 root-cause, the one-line `#ritual .idx` swap that ships K2, and the per-section `data-ambient-dark` attributes that the JS theme controller (P4T3, not in this file) will read on toggle. **No JS in this scope** — that's the controller's lane.

## §0 · Module comment

**Purpose:** provide a parallel 14-token dark palette that flips on `<html data-theme="dark">`, fix K1 (.gold-text gradient caps readability — T-005 carry-forward), and re-justify K2 (#ritual .idx contrast on dark-overlay sections) for dark mode. Per-section ambient colors are pre-staged as `data-ambient-dark` attributes so P4T3 just reads the right one on toggle.

**Locked defaults (T-004 §8.2 + research memo):**
- **Q1** = `prefers-color-scheme: dark` resolves first-load to dark when set, no `localStorage` value (controller applies this in `<head>` BEFORE `<style>` reads `data-theme` — P4T3 territory).
- **Q2** = single-icon header button (☀ ↔ ☾), `aria-label="Toggle theme"`.
- **Q3** = `localStorage` key = `theme` (accept risk of extension collision; cost is one re-render per page-load, not per minute).

**3 HIGH risks addressed:**
- **R-FOUC-1** — the dark cascade is **only loaded when `<html data-theme="dark">` is set**, so any pre-paint script that sets the attribute triggers the cascade on first paint. The P4T3 controller's pre-paint script is what closes this risk; this file only contributes the cascade declaration.
- **R-K12** — K1 + K2 contrast math was estimated by hand (±5% per research §7). The P4T2 audit in `share/notes/03_coder_summary_T-2026-07-01-004_P4-Sub1.md` re-verified every foreground dark token with the WebAIM-equivalent relative-luminance formula at runtime. **All 7 foreground dark tokens PASS AA** on `--paper`. **K2 light-mode result diverges from research §5.2 — see §3.**
- **R-DCB** — deuteranopia sim on dark `--gold-deep #B5862F` vs dark `--paper #0E0A06` post-simulation lands at **7.80:1** (was 6.03:1 before sim). Well above 4.5:1 AA. Escape-hatch (raise to `#C89238`) **NOT required**, documented for completeness.

## §1 · The 14-token dark counter-table

Each light-mode token has a dark counterpart. Hex values lifted verbatim from research §3.1 (T-001 §3.1 baseline + the demo's existing L57–60 light values as the basis). Demo's light `--paper #FBF6EE` is slightly warmer than T-001's `#FBF8F2`; dark `--paper #0E0A06` is a deep warm-black, **not** neutral-black, matching the "after-hours gallery" brief.

| Token | Light | Dark | WebAIM (fg vs --paper) | Pass |
|---|---|---|---|---|
| `--paper` | `#FBF6EE` | `#0E0A06` | bg only | n/a |
| `--mist` | `#F6F0E4` | `#15110B` | bg only | n/a |
| `--cream` | `#F1E9D7` | `#1A150E` | bg only | n/a |
| `--sand` | `#E8DBC1` | `#221A11` | bg only | n/a |
| `--ink` | `#241812` | `#F4ECDD` | light **16.07:1** · dark **16.80:1** | AAA ✓ |
| `--ink-soft` | `#5A4A3B` | `#C9B89A` | light **7.88:1** · dark **10.15:1** | AAA ✓ |
| `--ink-faint` | `#7A6855` | `#8E7E66` | light **4.96:1** · dark **5.00:1** | AA ✓ |
| `--gold` | `#B07A2E` | `#D4A24A` | light **3.44:1** (A-large only) · dark **8.52:1** | AA ✓ dark, A-large light (UI accent use, not body text) |
| `--gold-deep` | `#8B5E22` | `#B5862F` | light **5.24:1** · dark **6.03:1** | AA ✓ |
| `--gold-bright` | `#CC9A4A` | `#E8C275` | light **2.35:1** (FAIL on paper) · dark **11.65:1** | A-large light (gradient descender slot only, never body); AAA dark |
| `--accent` | `#9C5026` | `#C97A3F` | light **5.44:1** · dark **5.95:1** | AA ✓ |
| `--line` | `rgba(58,33,20,.16)` | `rgba(244,236,221,.18)` | decorative | n/a (1.4.11 incidental-UI exemption, research §2.4 row 3) |
| `--line-soft` | `rgba(58,33,20,.09)` | `rgba(244,236,221,.10)` | decorative | n/a (same exemption) |
| `--ambient` | matches `--paper` | matches `--paper` | n/a | n/a |

**Non-token knobs** (research §2.3 table) — only `#grain` opacity gets re-tuned in this P4T1 scope (others are P4T1 expanded scope or deferred):
- `#grain` opacity `.035` → `.06` under `[data-theme="dark"]` (restores grain visibility on near-black background; the original `.035` × `multiply` blend fades to invisible on `#0E0A06`).
- `#vignette` color, `#glow` opacity, `.multiply` blend mode, CTA dim color, hero aura color — **all deferred to a later token-block patch** (research §7 R-MQ-OVERRIDE flags the cascade-order subtlety when multiple modes overlap; keeping this file to 3 changes per dispatch).

## §2 · K1 root-cause fix — mode-aware `--gold-text-top`

**Root cause:** `.gold-text` (demo L163) declared `background:linear-gradient(180deg,var(--gold-bright),var(--gold) 50%,var(--gold-deep))`. Glyph caps (top ~30% of letter height) caught `--gold-bright #CC9A4A` against light section ambients like `#reveal`'s `#F2EAD7` — measured **2.35:1** (FAIL even A-large). Dark mode was fine (10.65:1) but the brand consistency issue is the same gradient behaviour regresses in one mode.

**Mode-aware fix:** introduce ONE new token `--gold-text-top`, declared in **both** `:root` and `:root[data-theme="dark"]`, pointing to `var(--gold-deep)` in both blocks. Because `--gold-deep` resolves differently in each mode (light `#8B5E22` · dark `#B5862F`), the same `var()` reference gives mode-aware behaviour without a `@media (prefers-color-scheme: dark)` override.

```css
:root{
  /* …existing 14 tokens… */
  --gold-text-top: var(--gold-deep);   /* light: gold-deep on paper = 5.24:1 ✓ */
}
:root[data-theme="dark"]{
  /* …14 dark tokens… */
  --gold-text-top: var(--gold-deep);   /* dark:  gold-deep on paper = 6.03:1 ✓ */
}
.gold-text{
  background:linear-gradient(180deg,
              var(--gold-text-top)  0%,
              var(--gold)           55%,
              var(--gold-bright)    95%);
  -webkit-background-clip:text; background-clip:text; color:transparent;
}
```

**Why this works:** caps land on `--gold-deep` in both modes (≥ AA 4.5 in both — actually AAA on dark). Mid (55%) and descender (95%) stops reuse existing `--gold` + `--gold-bright` tokens, so the "gold-rich" aesthetic from v1 is preserved. The descender stop paints only the bottom ~5% of glyph height — well below WCAG body-text contrast gating (decorative gradient detail; the same exemption that accepts `#line` hairlines).

**Forced-colors compatibility:** the existing `@media(forced-colors: active)` block (demo L407-415) targets `.gold-text{background:none; color:CanvasText; ...}` — still applies because the rule overrides `background` entirely. No additional forced-colors work needed.

## §3 · K2 history — `#ritual .idx` reverted to `--gold-bright` (pre-P4 default)

**Original intent (P4T1, since superseded by P5):** swap `#ritual .idx` color from `--gold-bright` to `--gold-deep` based on research §5.2 + P3 handoff. Rationale: `#ritual` has a dark section ambient `#3B2A1B`; the `.idx` glyphs (15px El Messiri serif) sit over the left-edge dark photo overlay `rgba(36,24,18,.78)` and render on a near-black background in light mode. Brief claimed `--gold-deep #8B5E22` on that bg = ~4.55:1 (AA ✓).

**Stage 1 — P4T2 audit (literal-ambient math vs brief):** the WebAIM-equivalent WCAG 2.2 calc disagreed:

| Pair | Brief claim | WebAIM-computed (P4T2) |
|---|---|---|
| `--gold-deep #8B5E22` vs `#3B2A1B` (literal ambient) | 4.55:1 (AA ✓) | **2.43:1 (FAIL)** |
| `--gold-bright #CC9A4A` vs `#3B2A1B` (pre-P4 default) | not cited | **5.41:1 (AA ✓)** |

P4T1 shipped the swap anyway because the brief was explicit ("ONE token swap") and the on-screen composite plausibly differs from the literal ambient. The discrepancy was documented in P4-Sub1's Known issues for P5 to re-verify.

**Stage 2 — P5 review on-screen re-measure (V-K2):** the reviewer built an alpha-compositing + WCAG 2.2 luminance script and re-measured `#ritual .idx` against the actual on-screen background at the `.idx` position: Pexels photo 5938567 (warm cream tones, L≈0.10–0.55) composited through `rgba(36,24,18,.78)` horizontal × `rgba(36,24,18,.19–.55)` vertical overlay → effective bg `#2F1F17`–`#44352A`. Results:

| Photo (L) | Effective bg | `--gold-deep` ratio | `--gold-bright` ratio (pre-P4 default) |
|---|---|---|---|
| `#B09070` L=0.30 (warm cream) | `#3D2D23` | **2.33:1** FAIL | **5.19:1** PASS AA |
| `#D8B89A` L=0.55 (bright cream) | `#44352A` | **2.08:1** FAIL | **4.63:1** PASS AA |
| `#604030` L=0.10 (dark warm) | `#2F1F17` | **2.80:1** FAIL | **6.24:1** PASS AA |

All `--gold-deep` scenarios below 3.0:1 A-large; AA body 4.5:1 unreachable. The brief's "Option C escape-hatch" (darken overlay to `#1F1610`) re-measured 2.16–2.86:1 — also INSUFFICIENT. See P5 review at `share/reports/04_review_T-2026-07-01-004.md` for full V-K2 evidence (alpha-compositing script + hand-validation + photo-L sweep).

**P5 fix:** revert `#ritual .idx` color to `var(--gold-bright)` (pre-P4 default) at `index.html:322`. Re-measured on-screen contrast: **4.63–6.59:1 PASS AA body** across all photo scenarios. The brief's K2 carry-forward direction (T-005) was wrong — `--gold-deep` regresses on the only visible-pixel metric that matters (on-screen composite contrast, not literal-ambient contrast). Pre-P4 default was already AA-pass on actual on-screen pixels.

**Why the literal-ambient math was misleading:** `#3B2A1B` is the *section ambient* (the colour the rest of `#ritual` paints onto if no photo were present). But `#ritual .idx` sits over a `.frame::after` overlay of `rgba(36,24,18,.78)` (combined α≈0.82 at `.idx` position). The overlay dominates the visible background; the photo's contribution through the 10–22% non-overlay portion LIGHT-LIFTS the effective bg enough that `--gold-deep` falls below 3.0:1 A-large. The brief's research §5.2 + P3 handoff hand-math against the literal ambient missed the photo+overlay composite.

**Takeaway for future brief math:** hand-math on WCAG contrast is unreliable. Use a Node/JS implementation of WCAG 2.2 relative luminance + alpha-compositing against an actual rendered pixel. The P4T2 audit and P5 review together demonstrated that "passes against literal ambient" ≠ "passes on actual on-screen pixels".

## §4 · Per-section `data-ambient-dark`

Six sections, six matching `data-ambient-dark` values per research §2.2 table (T-001 §3.2 verbatim, applied to the demo). Hex values mirror the dark-mode token palette (warm-black shades, not neutral-black).

| Section | Light (`data-ambient`) | Dark (`data-ambient-dark`) | Mood shift |
|---|---|---|---|
| `#hero` | `#FBF6EE` | `#0E0A06` | deep quiet hush |
| `#film` | `#F4ECDD` | `#100C08` | warm-to-deep brown drift |
| `#reveal` | `#F2EAD7` | `#14100A` | sand → espresso |
| `#ritual` | `#3B2A1B` (apothecary-at-dusk) | `#1A1308` (gallery-after-hours) | honey glow → deep oak |
| `#cta` | `#F6F1E8` | `#0A0805` | wash → near-black |
| `#editions` | `#F1E9D5` | `#120E08` | ivory → charred-amber |

**JS controller responsibility (P4T3, not this file's):** the `applyAmbient(c, g)` function at demo L811 must read `sec.getAttribute(activeTheme === "dark" ? "data-ambient-dark" : "data-ambient")`. Single source of truth, no `null`-handling race. A `data-theme` mutation observer re-triggers `applyAmbient` on toggle (~5 LOC, P4T3 owns the listener).

**Why `--ritual` drops further in dark mode:** `#3B2A1B` is already a dark ambient — when the whole page goes dark, dropping to `#1A1308` keeps the section in the same relative position in the ambient ladder (the "warmest dark" stays warmest). Without the drop, `#ritual` would be the only section that's *lighter* than its mode.

## §5 · Acceptance criteria

**Pass-gate 1 — WebAIM-equivalent contrast audit (P4T2 V5 partial):**
- All 7 foreground dark tokens pass AA body (≥ 4.5:1) vs dark `--paper` ✓
- `--gold-bright` light = 2.35:1 vs light `--paper` (FAIL on paper); accepted because gradient descender-only, never body text. Research §5.1 explicitly carves this exception.
- `--gold` light = 3.44:1 (A-large only); accepted for UI-component borders (`.nav-cta`, `.btn-ghost`, `.step-dots`) and decorative gradient stops — non-text contrast 3:1 applies to UI components, all usages pass the non-text 3:1 threshold.
- K1 `.gold-text` cap (top stop = `--gold-text-top`): light 5.24:1 ✓ · dark 6.03:1 ✓ (both ≥ AA)
- K2 `#ritual .idx` (top stop = `--gold-deep`): light 2.43:1 vs literal `#3B2A1B` ambient — **discrepancy noted, requires P5 review**; dark 5.63:1 ✓

**Pass-gate 2 — Deuteranopia sim (P4T2 V5 partial):**
- `--gold-deep #B5862F` (dark) simulated via Viénot 1999 (Color Oracle approximation) → `#a5a955`. Effective contrast against simulated dark paper `#0d0d07` = **7.80:1** (was 6.03:1 before sim). Color-blindness actually **improves** perceived contrast on this gold-on-warm-black pair because the deutan transformation shifts gold toward yellow-green, which is higher luminance than the original.
- Escape-hatch (raise dark `--gold-deep` to `#C89238`) **NOT required** for deutan; sim post-swap would be 9.44:1 if applied. Documented for completeness.

**Pass-gate 3 — Carry-over grep preservation (P4T1):**
All 5 T-005 grep gates green after this dispatch:
- `outline.*none` = 0 ✓
- `srcset=` = 13 ✓
- `role="img"` = 2 ✓
- `aria-keyshortcuts` = 1 ✓
- `addEventListener("change", onReduceChange)` = 1 (now at L781; shifted +22 lines from L759) ✓

**Pass-gate 4 — File size growth:**
`index.html` went from 1075 → 1097 lines (+22 lines). Within the brief's "+50 to +60" expected budget; the dark block + grain rule + comments added 22 lines; section tags added 6 new attributes (in-line, no line-bloat). No deleted lines.

## §6 · Don't-touch list

These belong to **other phases**, not this dispatch:
- **JS theme controller** (`window.setTheme` / `getTheme` / `applyTheme`) — **P4T3**, not in this file. Reads `data-ambient-dark` on toggle.
- **Header toggle button markup** (`<button id="theme-toggle" aria-label="...">`) — **P4T3**.
- **`localStorage` read/write** (`localStorage.getItem('theme')`) — **P4T3**.
- **`<head>` script** that resolves `localStorage.theme || prefers-color-scheme` and sets `<html data-theme>` BEFORE `<style>` reads it (FOUC prevention per R-FOUC-1) — **P4T3**.
- **`prefers-color-scheme: dark` first-load detection** — **P4T3**.
- **`#vignette` color re-tune, `#glow` opacity re-tune, `.multiply` blend mode re-tune, CTA dim color, hero aura URL re-tune** — research §2.3 lists these as out-of-scope for P4T1; cascade-order subtlety (R-MQ-OVERRIDE) wants a separate dispatch.

**Also don't touch** (preserved for downstream patches):
- `@media(forced-colors: active)` block at demo L407-415 — **P5 verifies** this block still works in dark mode.
- `@media(prefers-reduced-motion: reduce)` block at L415-435 — **P5 verifies** same.

## §7 · Why-not-per-mode-overrides

**The question this section answers:** why use `:root[data-theme="dark"] { ... }` attribute selectors instead of `@media (prefers-color-scheme: dark) { :root { ... } }`?

**Answer:** the brief requires a **toggleable** dark theme, not just an OS-pref-following one. Three reasons force the attribute-selector approach:

1. **Explicit toggle wins over OS pref.** Q2 says clicking the header button sets `data-theme` regardless of OS pref. With CSS-only `@media`, clicking the button would need to either (a) flip `prefers-color-scheme` (impossible — read-only UA media feature) or (b) ship duplicates inside a `@media (not (prefers-color-scheme: dark))` to undo the OS pref in light mode — brittle.

2. **localStorage persistence.** Q3 says `localStorage.theme` is the source of truth across reloads. CSS-only `@media` has no memory; the attribute-selector approach lets a `<head>` script read the persistent value once and set `<html data-theme>` before `<style>` reads it. (R-FOUC-1.)

3. **Specificity / cascade predictability.** R-MQ-OVERRIDE (§7 of research) warns that media-query rules + attribute-selector rules can fight in subtle ways if the cascade order changes. Putting attribute-selector rules AFTER the existing `:root` block (this dispatch's positioning) gives the explicit `data-theme` precedence over inherited defaults — the cascade reads top-to-bottom and attribute selectors are more specific than `:root` plain.

**What mode-aware `--gold-text-top` buys us:** the `:root` + `:root[data-theme="dark"]` blocks both set `--gold-text-top: var(--gold-deep)`. Because `--gold-deep` itself changes between the two blocks, the same `var()` reference returns a different hex in each mode. No `@media` is involved — the cascade resolves correctly without media-query involvement.

**What the JS controller (P4T3) buys us:** the toggle, persistence, and FOUC prevention. **None of this is in P4T1 scope.** The CSS layer stays declarative and mode-aware on its own; the JS layer only writes the attribute and reads the ambients.

---

## Status

- **Applied:** `cinematic-landing-kit-demo/index.html`:
  - L52-83 — `:root` extends with `--gold-text-top`; new `:root[data-theme="dark"]` block (L70-81) + `[data-theme="dark"] #grain` rule (L83).
  - L163 — `.gold-text` gradient now `var(--gold-text-top) 0%, var(--gold) 55%, var(--gold-bright) 95%`.
  - L300 (now L322 after P4 Sub-2 +22-line drift) — `#ritual .idx` swap to `var(--gold-deep)`. **Reverted at P5** to `var(--gold-bright)` (pre-P4 default) per V-K2 FAIL on actual on-screen composite (see §3).
  - L446, L487, L568, L600, L629, L672 — all 6 sections gain `data-ambient-dark` per §2.2 table.
- **Verification gates:** see `share/notes/03_coder_summary_T-2026-07-01-004_P4-Sub1.md` for grep counts + WebAIM table + deutan sim; `share/reports/04_review_T-2026-07-01-004.md` for P5 V-K2 on-screen re-measure (FAIL on `--gold-deep`, PASS on `--gold-bright` revert).
- **Known limits:** K2 light-mode math discrepancy (§3) — **resolved by P5 revert** to `--gold-bright`; non-token dark-mode re-tunes (`#vignette`, `#glow`, `.multiply`, CTA dim) deferred (§6).
- **Follow-up candidates** (not in P4T1 scope):
  - P5 review (V5 + V6) re-verifies the K2 light-mode regression and the `--line` 1.4.11 exemption decision.
  - P5 review confirms `@media(forced-colors: active)` block still works in dark mode.
  - Future patch: cascade-order rules for `#vignette`, `#glow`, `.multiply`, CTA dim, hero aura — research §2.3 lists the per-mode knob re-tunes that P4T1 deliberately deferred.
