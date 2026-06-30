# Typography — Atlas

## Families

| Token | Family | Weights | Use |
|---|---|---|---|
| `--font-display` | Playfair Display (Latin) / Noto Naskh Arabic (future Arabic) | 700 | Hero, page titles |
| `--font-body` | Inter (Latin) / IBM Plex Sans Arabic (future Arabic) | 400, 500, 600 | Body, UI |
| `--font-mono` | JetBrains Mono | 400 | Lot numbers, batch IDs, technical |

> **Arabic note**: When the MENA launch happens, pair Inter with IBM Plex Sans Arabic. Do NOT use Inter for Arabic content (it has no Arabic glyphs). Body sizing for Arabic: bump 16px → 17px to match Latin visual weight.

## Scale

| Token | Size / Line-height | Use |
|---|---|---|
| `--text-display` | 48 / 56 | Hero |
| `--text-h1` | 36 / 44 | Page title |
| `--text-h2` | 28 / 36 | Section title |
| `--text-h3` | 22 / 30 | Card title |
| `--text-body` | 16 / 26 | Body |
| `--text-small` | 14 / 22 | Caption |
| `--text-micro` | 12 / 18 | Legal, fine print |

## Rules

- Display family ONLY for display; body family for everything else.
- Body text must hit WCAG AA (4.5:1) on its background.
- Don't use weights outside the loaded family (no synthetic bold).
- Letter-spacing: -0.02em on display, 0 on body, 0.02em on micro.
- Line-height tightens on display, loosens on body, loosest on micro.

## Don't

- Don't center long body copy. Left-aligned in LTR, right-aligned in RTL.
- Don't use display font in body or vice versa.
- Don't use more than 2 type families on a single page.