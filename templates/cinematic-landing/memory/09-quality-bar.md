# 09 · Quality bar — what `am-review` checks for

The cinematic-landing template's quality bar is codified in
`agents_manager/assets/resources/landing-review-checklist.md`. The 7 dimensions
`am-review` evaluates:

## 1. Hard rules (P0 — fail-the-build)

- No `video.currentTime = …` assignment
- No `<video>` tag unless Branch B
- No `mix-blend-mode` on GSAP-transformed elements
- `.fallback-host.is-missing` present and wired
- `prefers-reduced-motion: reduce` honored (CSS + JS)

## 2. Asset integrity (P1)

- All asset URLs HEAD-200
- `assets/MANIFEST.json` matches the URLs in the HTML
- Image `srcset` / `sizes` for DPR ladder (or document why not)

## 3. Structure & DNA (P1)

- All 8 sections present (`<header>`, hero, film, reveal, ritual, cta, editions, footer)
- Header hide/show on scroll direction
- Lenis + GSAP single ticker (no duplicate RAFs)
- Per-section `data-ambient` attribute

## 4. Brand voice (P2)

- No marketing clichés (luxurious / premium / artisanal (overused) / curated (overused))
- Copy is sensory, second-person, concrete
- Tagline + brand label consistent across hero, header, footer

## 5. Documented deviations (P3)

- Branch C crossfade implemented as specified (Path C in memory/02)
- Branch B video implemented as specified (Path B in memory/02)
- 3-frame CTA click-advance implemented as specified (memory/08)
- All deviations read from `assets/MANIFEST.json` correctly

## 6. Code quality (P4)

- No console errors at parse time
- No dead code, no commented-out blocks
- No `eval`, no `Function()`, no unsafe patterns
- CSS specificity not exploding (no `!important` chains)

## 7. Locale (P1)

- `lang` and `dir` attributes set per `04-locale-handoff.md`
- No hardcoded English-only strings (use `data-i18n` attributes for any future i18n)
- RTL layout works when `dir="rtl"`

## Verdict format

`am-review` writes one of:
- **PASS** — all P0 + P1 pass, P3 deviations implemented as specified
- **PASS-WITH-NOTES** — all P0 + P1 pass, P2/P3/P4 have minor non-blocking issues
- **FAIL** — any P0 fails, P1 has uncovered 404, P3 deviations silently dropped