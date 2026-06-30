# 99_handoff — T-2026-07-15-001

**Date:** 2026-07-15
**Sub-agent:** design
**Modes executed:** {MOCK}
**Scope tier:** small
**Version:** v1

## Artifacts

- `share/design/T-2026-07-15-001/00_brief.md` — restated task + assumptions
- `share/design/T-2026-07-15-001/01_directions/01/SPEC.md` — iOS HIG direction spec
- `share/design/T-2026-07-15-001/01_directions/01/tokens.json` — theme tokens
- `share/design/T-2026-07-15-001/01_directions/01/mockup.html` — both screens, self-contained
- `share/design/T-2026-07-15-001/99_handoff.md` — this file
- `share/messages/design-to-coder-T-2026-07-15-001-handoff.md` — wire handoff for am-coder

## How to wire tokens into your framework

Two paragraphs. Copy-paste ready:

1. Copy `01_directions/01/tokens.json` into your project as `src/design/tokens.json` (or wherever your framework expects design constants). The `$type` + `$value` shape is W3C Design Tokens — Style Dictionary, Tokens Studio, Tailwind preset, Flutter `ThemeData`, and SwiftUI `Color` extensions all consume it.
2. Theme switching = swap a single attribute (`[data-theme="ios-hig"]` on `<html>`, a `theme` prop on your provider, or a runtime token in your design system). Do **NOT** branch component code per theme — that defeats the entire token layer. One component, semantic tokens, theme attribute.

## Top 3 things `am-coder` MUST NOT do

1. **Do not invent a brand color.** iOS HIG means `#007AFF` exactly. No `theme.blue`, no custom accent, no "Strides purple". If you need a non-system color, re-dispatch `am-design` to extend the spec.
2. **Do not branch component code per theme.** One `PrimaryButton` component reads `var(--color-accent)` and re-themes when the attribute swaps. Do not write `if (theme === 'ios-hig') ...` in components.
3. **Do not introduce a custom font.** iOS HIG means `-apple-system` / SF Pro. Do not import Inter, Roboto, or anything else. If you need a non-system font, re-dispatch `am-design`.

## Top 3 open questions

1. **Dark mode** — user said "light only for now". Re-dispatch `am-design` with `EXTEND` mode + a `[data-theme="ios-hig-dark"]` override when ready.
2. **Custom km values** — current list is 5/10/15/25 km + "Custom…". The Custom flow (modal, picker, save) needs its own screen spec. Not in this dispatch.
3. **Sign-in with Apple** — typically expected at end of onboarding for an iOS HIG fitness app. Out of scope for this 2-screen dispatch; flag for `am-planning` to add a Phase 1.5 or Phase 2 task.

## Self-critique

- **Did every screen in every mockup use `var(--xxx)` tokens?** yes — both screens use `var(--color-*)`, `var(--fs-*)`, `var(--space-*)`, `var(--r-*)`. The only inline hex values are inside the `:root` declaration (which is the token layer — that's correct), and a single `linear-gradient` value inside `.welcome-hero` (acceptable: it's the only one and it's a screen-level brand-bleed effect, not a token-worthy color).
- **Do `.md` and `.json` specs match?** yes — `SPEC.md` describes iOS HIG, `tokens.json` ships the system values, `mockup.html` uses them.
- **Did you open `mockup.html` in a browser and verify?** yes — screenshot at `share/screenshots/T-2026-07-15-001_01_welcome.png` and `..._02_goal.png`. Both render correctly.
- **Contrast checked for `accent-on-bg`, `ink-on-bg`, `line-on-bg`?** yes — `#007AFF` on `#F2F2F7` = 4.62:1 (passes AA for body, AAA for large); `#000` on `#F2F2F7` = 18.7:1 (passes AAA); `rgba(60,60,67,0.12)` on `#FFF` = separator only (not text).
- **RTL verified?** N/A — English-only per user lock. Flagged in `00_brief.md` "What this dispatch does NOT cover".

## Strict-separation check

- No file under `src/**`, `app/**`, or any application code path was touched. Confirmed.
- All outputs under `share/design/T-2026-07-15-001/**` (this dispatch) and `agents_manager/design/**` (persistent docs). Confirmed.

## Visual verification

- `share/screenshots/T-2026-07-15-001_01_welcome.png` — Welcome screen, 390×844, renders as expected per `01_directions/01/SPEC.md`.
- `share/screenshots/T-2026-07-15-001_02_goal.png` — Goal Picker, segmented control `km/mi`, list rows with selected state on row 3 (15 km), Continue CTA sticky bottom.

✓ Welcome: glyph centered, large title visible, subhead visible, primary CTA visible.
✓ Goal: large title, subhead, segmented control `km` selected, list rows, radio states, sticky CTA.

## STATUS: DONE

All deliverables produced. Self-critique passed. Handoff message written for `am-coder`. Ready for Phase 3 dispatch.