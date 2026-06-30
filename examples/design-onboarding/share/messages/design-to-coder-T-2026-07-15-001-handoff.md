# Handoff: design → coder

**Task id:** T-2026-07-15-001
**Modes executed:** {MOCK}
**Scope tier:** small
**Status:** DONE
**Date:** 2026-07-15

## Artifacts (`am-coder` must read)

- `share/design/T-2026-07-15-001/99_handoff.md` — pointer + token wiring snippet + self-critique
- `share/design/T-2026-07-15-001/01_directions/01/SPEC.md` — visual direction (iOS HIG)
- `share/design/T-2026-07-15-001/01_directions/01/tokens.json` — theme tokens (system colors only)
- `share/design/T-2026-07-15-001/01_directions/01/mockup.html` — visual reference (open in browser)

## How to wire tokens into your framework

1. Copy `01_directions/01/tokens.json` into your project as `src/design/tokens.json`. The `$type` + `$value` shape is W3C Design Tokens — Style Dictionary, Tokens Studio, Tailwind preset, Flutter `ThemeData`, and SwiftUI `Color` extensions all consume it.
2. Theme switching = swap a single attribute (`[data-theme="ios-hig"]` on `<html>`, a `theme` prop on your provider, or a runtime token in your design system). Do **NOT** branch component code per theme — that defeats the entire token layer. One component, semantic tokens, theme attribute.

## Top 3 things `am-coder` MUST NOT do

1. Do not invent a brand color. iOS HIG means `#007AFF` exactly. If you need a non-system color, re-dispatch `am-design` to extend the spec.
2. Do not branch component code per theme. One `PrimaryButton` reads `var(--color-accent)` and re-themes when the attribute swaps.
3. Do not introduce a custom font. iOS HIG means `-apple-system` / SF Pro. Do not import Inter, Roboto, or anything else.

## Top 3 open questions (for `am-coder` to surface to master)

1. Dark mode variant — user said "light only for now". Re-dispatch `am-design` with `EXTEND` when ready.
2. Custom km flow — current list has "Custom…" but no modal/screen spec for it.
3. Sign in with Apple — typical for iOS HIG fitness app onboarding. Flag for `am-planning`.

## Self-critique

- All screens use `var(--xxx)` tokens? yes
- `.md` and `.json` match? yes
- Browser-verified? yes — screenshots in `share/screenshots/`
- Contrast passes WCAG AA? yes
- RTL? N/A (English-only)
- Strict-separation? yes — no `src/**` touched

## Visual verification

- `share/screenshots/T-2026-07-15-001_01_welcome.png`
- `share/screenshots/T-2026-07-15-001_02_goal.png`

## STATUS: DONE