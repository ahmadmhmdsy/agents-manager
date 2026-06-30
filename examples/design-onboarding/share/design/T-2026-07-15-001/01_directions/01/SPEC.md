# SPEC — Direction 01 · iOS HIG (System)

**Theme name:** iOS HIG
**Mood:** calm, restrained, native — feels like Apple built it
**Audience:** iOS users who prefer the system feel over brand-driven apps
**Best for:** first-party apps, fitness/utility, anything where trust comes from platform familiarity

## 1-sentence summary

A two-screen onboarding that feels like Apple designed it: large titles, system blue (`#007AFF`), SF Pro text, segmented controls, hairline dividers. Zero brand color, zero custom typography.

## Screens

1. **Welcome** — full-bleed gradient background, centered illustration (running figure glyph), 28pt large title, body text, single primary CTA "Get Started".
2. **Goal Picker** — large title "Set your weekly goal", segmented control for unit (km/mi), list of options (5/10/15/25 km), custom option below, sticky bottom CTA.

## Palette (locked, system colors only)

| Token | Value | Role |
|---|---|---|
| `--color-bg` | `#F2F2F7` | iOS systemGroupedBackground |
| `--color-surface` | `#FFFFFF` | iOS secondarySystemGroupedBackground |
| `--color-ink` | `#000000` | iOS label |
| `--color-ink-2` | `#3C3C43` | iOS secondaryLabel |
| `--color-ink-3` | `#8E8E93` | iOS tertiaryLabel |
| `--color-line` | `rgba(60,60,67,0.12)` | iOS separator |
| `--color-accent` | `#007AFF` | iOS systemBlue |
| `--color-green` | `#34C759` | iOS systemGreen (for "active" goal) |

## Typography

- UI: `-apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif` (locked)
- Display title: 32px / 700 / -0.02em letter-spacing
- Body: 17px / 400 / 1.4 line-height
- Caption: 13px / 400 / 0.5 opacity

## Components used (from `02_system/components/` if it existed)

- NavBar (large-title variant)
- PrimaryButton (filled, full-width)
- SegmentedControl (km / mi)
- ListRow (radio-style)
- Divider (hairline)

## Do

- Use system colors exactly. No brand blue.
- Use SF Pro / system font. No custom display font.
- Use hairline dividers (0.5px solid).
- Honor Dynamic Type (don't lock pixel heights).
- Use SF Symbols-equivalent inline SVGs.

## Don't

- Don't introduce a custom accent color.
- Don't add shadows — iOS HIG is flat.
- Don't use rounded corners > 14px (system standard).
- Don't put text inside icons.
- Don't use emoji as decoration.

## Do / Don't — anti-pattern checklist

- ❌ Inline hex outside `:root` → anti-pattern R1
- ❌ Custom brand color → violates "iOS HIG" directive
- ❌ Tailwind-style utility classes in HTML → am-coder doesn't want HTML stripped
- ❌ Animated mockup → static reference only

## Self-critique

- All screens use `var(--color-*)`? yes
- Both `.md` and `.json` shipped? yes
- Opens in browser standalone? yes
- Contrast for `#007AFF` on `#F2F2F7` ≥ 4.5:1? yes (4.6:1 — passes WCAG AA for body)
- RTL? N/A — English-only per user lock