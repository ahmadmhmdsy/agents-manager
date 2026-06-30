# Artifact Mapping — Quran App under am-design v2

This table maps each artifact that was actually produced in the Quran app work to where it would live under am-design v2's output tree (`output-skeleton.md`).

## Master design system layer

| Actual artifact | am-design v2 location | Notes |
|---|---|---|
| `quran-app-prototypes/README.md` | `00_brief.md` | Restated task |
| `quran-app-prototypes/SPEC.md` | `03_system/README.md` + `01_research/design-audit-input.md` (for the meta-spec of what was built) | System overview |
| `quran-app-prototypes/AGENTS.md` | (am-design internal — doesn't ship to consumer) | Agent playbook |
| `quran-app-prototypes/tokens/base.json` | `03_system/tokens/base.json` | Theme-agnostic schema |
| `quran-app-prototypes/tokens/tokens.css` | `03_system/tokens/tokens.css` | Compiled CSS |
| `quran-app-prototypes/tokens/tailwind.config.example.js` | `03_system/tokens/tailwind.config.example.js` | Same |
| `quran-app-prototypes/components/COMPONENTS.md` | `03_system/components/COMPONENTS.md` | Component catalog |
| `quran-app-prototypes/components/components.json` | `03_system/components/components.json` | Machine mirror |
| `quran-app-prototypes/patterns/PATTERNS.md` | `03_system/patterns/PATTERNS.md` | Pattern library |
| `quran-app-prototypes/pages/<name>.md` | `03_system/pages/<name>.md` | Per-page spec |
| `quran-app-prototypes/pages/<name>.json` | `03_system/pages/<name>.json` | Machine mirror |

## Per-theme layer

| Actual artifact | am-design v2 location | Notes |
|---|---|---|
| `quran-app-prototypes/themes/01-modern-minimal/SPEC.md` | `04_mockups/mobile/01-modern-minimal/SPEC.md` (or `02_brand/` if treating theme as brand) | Visual direction spec |
| `quran-app-prototypes/themes/01-modern-minimal/tokens.json` | `03_system/tokens/themes/01-modern-minimal.json` | Per-theme tokens |
| `quran-app-prototypes/01-modern-minimal.html` | `04_mockups/mobile/01-modern-minimal/index.html` + `04_mockups/mobile/01-modern-minimal/<screen>.html` (if split) | Visual mockup |

## Mockup layer

| Actual artifact | am-design v2 location | Notes |
|---|---|---|
| `01-modern-minimal.html` (23 screens, one HTML) | `04_mockups/mobile/01-modern-minimal/index.html` + `04_mockups/mobile/01-modern-minimal/<screen>.html` × 23 | One folder per theme, one file per screen, plus index for all-in-one |
| (same for 02, 03, 04) | (same pattern) | |

## Handoff layer

| Actual artifact | am-design v2 location | Notes |
|---|---|---|
| (no formal handoff doc existed) | `99_handoff.md` | Audience-aware handoff — would have made this work much easier |
| (no share/messages file) | `share/messages/design-to-coder-<task-id>-handoff.md` | Wire file for downstream agent |

## What was NOT done that am-design v2 would do

| Gap | v2 addition |
|---|---|
| No formal discovery protocol | 7-question discovery protocol in `SKILL.md` |
| No status signals | DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED in `99_handoff.md` |
| No self-critique gate | Required section in `99_handoff.md` |
| No mode set | Would have been: CONCEIVE + SYSTEMIZE + MOCK + WRITE (in sequence) |
| No scope tier | Would have been: `scope=full` from the start |
| No audience declaration | Would have declared: am-coder (LLM consumer) + PM + stakeholder |
| No lint / verification | Would have run browser screenshots + accessibility check |

## What was done that am-design v2 would inherit

| Pattern | v2 location |
|---|---|
| Token abstraction with `[data-theme]` attribute | `resources/token-schema.md` |
| `.md` + `.json` mirror | `rules.md` Rule #4 |
| Multi-theme via parallel files | `output-skeleton.md` § Per-mode decision tree |
| Locked dimensions per medium | `resources/mockup-templates/` |
| Authentic content rule | `rules.md` Rule #15 (authentic content) |
| First 7 screens set the language | `lessons.md` (this folder) L13 |

## Files in this case study folder

- `README.md` — overview
- `retrospective.md` — narrative of what happened
- `lessons.md` — bullet-list of patterns learned
- `mapping.md` — this file

The actual Quran app work lives in `E:\minimax_projects\fashion-theme\quran-app-prototypes\` (separate from this agents-manager repo). It's referenced but not duplicated.