# Color Palette — Atlas

**Usage rule**: Always reference as tokens (`var(--color-primary)`), never inline hex.

## Primary

| Token | Hex | Use | Contrast on bg |
|---|---|---|---|
| `--color-primary` | #2D4A2B | Brand surfaces, headlines, primary CTAs | 8.6:1 on bg ✓ |
| `--color-primary-deep` | #1A2F19 | Hover state, footer | 11.4:1 on bg ✓ |

## Accent

| Token | Hex | Use | Contrast |
|---|---|---|---|
| `--color-accent` | #C9851E | Sparingly — single accent, never decorative noise | 4.6:1 on bg ✓ |
| `--color-accent-tint` | #F5E8D2 | Accent backgrounds, badges | n/a |

## Neutral

| Token | Hex | Use |
|---|---|---|
| `--color-ink` | #1A1814 | Primary text, headlines |
| `--color-ink-2` | #4A453D | Secondary text |
| `--color-ink-3` | #8A8278 | Tertiary text, captions |
| `--color-line` | #E2DCCF | Borders, dividers |
| `--color-bg` | #F8F4EC | Page background (warm cream, evokes raw coffee) |
| `--color-surface` | #FFFFFF | Cards, elevated surfaces |

## Semantic

| Token | Hex | Use |
|---|---|---|
| `--color-success` | #4A7A3A | Confirmations, "in stock" |
| `--color-warning` | #C9851E | Cautions (shares hex with accent — intentional) |
| `--color-danger` | #B5483A | Errors, destructive |
| `--color-info` | #2D4A2B | Informational (shares with primary — intentional) |

## Don't

- Don't introduce a color not in this palette.
- Don't use `--color-*` tokens for non-color purposes.
- Don't override contrast ratios.
- Don't use `--color-warning` and `--color-danger` interchangeably — they share hue but differ in message.
- Don't use `--color-accent` for anything more than 5-10% of any layout — it's a punctuation mark.