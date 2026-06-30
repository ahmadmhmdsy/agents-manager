# 99 Handoff — Atlas Brand Identity

**Audience**: Marketing team + external agency.
**Status**: DONE (mockup-level deliverable, awaiting real logo via follow-up ILLUSTRATE dispatch).

## Artifacts produced

| Path | Purpose |
|---|---|
| `00_brief.md` | Restated task + discovery answers |
| `02_brand/color-palette.md` + `.json` | 4-6 color tokens, W3C format |
| `02_brand/typography.md` | Display + body + mono, with Arabic pairing noted for future |
| `02_brand/voice-and-tone.md` | Voice, tone-by-context, vocabulary, sample phrases |
| `02_brand/brand-guidelines.md` | Executive one-pager linking everything |
| `02_brand/logo/logo-placeholder.svg` | Placeholder until real logo arrives |

## What marketing should do with this

1. Read `brand-guidelines.md` first.
2. Use `color-palette.json` to set up Style Dictionary or similar token compiler.
3. Brief the logo designer with `voice-and-tone.md` and `brand-guidelines.md` (no mockups needed — they have the visual reference).
4. Approve or request changes. Re-entry will append, not overwrite.

## What external agency should receive

Send these three files plus any background briefs:
- `brand-guidelines.md`
- `color-palette.json`
- `voice-and-tone.md`

The agency does NOT need the .md files for color and typography (the .json is the source of truth).

## Top 3 things NOT to do

1. **Don't introduce a new color** outside the palette without a refresh task that goes through this agent.
2. **Don't use Inter for Arabic content** when the MENA launch arrives — switch to IBM Plex Sans Arabic.
3. **Don't apply effects to the logo** (rotation, color shifts, drop shadows, glow). When the real logo arrives, follow its rules.

## Open questions for the user

1. **Single accent vs two-tone**: confirmed single accent (gold) for v1. Want to revisit when MENA launch happens?
2. **Tagline**: shipped English-only ("Single-origin coffee, named precisely."). Bilingual from day one, or English-first with Arabic added later?
3. **Logo style direction**: logotype (Playfair "Atlas") or mark (cherry + leaf icon)? Current placeholder leans logotype. Confirm with logo designer.

## Self-critique

- ✓ All colors in mockups reference `--color-*` tokens (placeholder SVG uses var() with hex fallback).
- ✓ Voice examples are concrete, not abstract.
- ✓ Typography scale covers all uses (no orphan sizes).
- ✓ Brand guidelines link to every other artifact.
- ✓ No emoji, no exclamation marks, no hype words.
- ⚠ Placeholder logo is generic. Real logo is a separate follow-up.
- ⚠ Arabic pairing is documented but not yet tested (no Arabic content shipped yet).

## Visual verification

Browser verification: opened `logo/logo-placeholder.svg` in browser. Renders correctly with fallback colors. Will need re-verification when real logo replaces placeholder.

## STATUS: DONE