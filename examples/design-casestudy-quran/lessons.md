# Lessons Learned — Quran App Design System

Bullet-list of patterns and anti-patterns surfaced by the Quran app work. These informed the design of am-design v2.

## Token patterns

- **L1 — Token abstraction scales**: Every color/spacing/font as a CSS variable in `:root` (or `[data-theme]` block) made theme switching trivial. The cost was zero; the benefit was infinite.
- **L2 — Naming convention matters**: Semantic names (`--bg`, `--ink`, `--primary`, `--line`) beat descriptive names (`--light-gray-1`, `--dark-green-2`). The first is theme-portable; the second is theme-locked.
- **L3 — Tints and shades need separate tokens**: When a theme needs a lighter version of primary (e.g. `--primary-tint` for backgrounds), declare it explicitly. Don't compute it in CSS — that's a refactor risk.
- **L4 — Theme attribute swap is the only sane switching mechanism**: `[data-theme="..."]` on `<html>` cascades cleanly. Other approaches (JS toggling class on body, multiple CSS files) all have edge cases.

## Content patterns

- **L5 — Authentic content > lorem ipsum, always**: Real Surah names, real ayahs, real reciters. The mockups looked like a real product from the first screen.
- **L6 — RTL Arabic is not just flipped English**: Bullet styles, numbering, baseline alignment, line-height, diacritic positioning all differ. Treat RTL as a separate design problem, not a CSS transform.
- **L7 — Eastern vs Western Arabic numerals**: Different glyphs (٠١٢ vs 012), different contexts (Eastern for general use; Western for technical/math). Pick per surface, document the choice.
- **L8 — Hijri + Gregorian dual calendar**: In Muslim-majority markets, both calendars matter. Date display should show both where relevant.
- **L9 — Reciter names are cultural**: Using "Mishary Al-Afasy" instead of "Reciter 1" makes the product feel real. Same principle: real names for real cultural context.

## Process patterns

- **L10 — Locked dimensions first**: Picking 390×844 once and reusing it across 92 screens eliminated a class of design debates. Every medium has a locked dimension.
- **L11 — Phone chrome is consistent**: Status bar + dynamic island/notch + home indicator appear on every phone screen. Should be a snippet, not copy-pasted.
- **L12 — Multi-theme via parallel files**: One HTML per theme, not one HTML with internal theme switching. Easier to review, easier to extract. Theme switching in production is a CSS-layer concern.
- **L13 — First 7 screens set the language**: Splash, Home, List, Detail, Player, Settings, Onboarding. These cover ~80% of recurring UI. Build these first; the rest is composition.
- **L14 — Component library emerges from screens, not the other way around**: Don't try to design a perfect component library in isolation. Build screens, see what repeats, then extract components.

## Failure modes (don't repeat these)

- **F1 — Large-edit truncation**: Edit tool failed on newStrings over ~50KB. Forced batching into smaller chunks. Fix: chunk 4-5 screens per edit.
- **F2 — Encoding pain in tooling**: `Get-Content` decodes as Windows-1252; Arabic showed as `??????`. Files were fine (UTF-8); only the read tool failed. Use `Get-Content -Encoding UTF8` explicitly.
- **F3 — Inline hex in early screens**: First few screens had raw `#FFFFFF`, `#1A1A1A`. Had to refactor to tokens. Fix: tokens first, screens second (now Rule #2 in `rules.md`).
- **F4 — Late discovery of constraints**: User asked "how do I give this to LLMs?" after the design was done. Forced creation of `tokens/`, `components/`, `patterns/` folders late. Fix: discovery protocol (now in `SKILL.md`).
- **F5 — Scope creep across themes**: User kept asking "add dark variant" / "add more screens". Each was a legitimate ask but caused rework. Fix: scope tier discipline (now in `SKILL.md`).

## What didn't work as anti-patterns (the ones to refuse)

These were considered and rejected during the project. Codify as R-patterns in `novel-abstractions-seed-list.md`:

- **R-A — One HTML file with internal theme tabs**: Considered, rejected. Parallel files are easier to review and extract.
- **R-B — Lorem ipsum for "we'll fill in real content later"**: Considered, rejected. Real content forces real design decisions.
- **R-C — Emoji as UI ornaments (🌙 📖 ✨)**: Considered, rejected. Renders inconsistently across OS, fails accessibility.
- **R-D — Pixel-perfect from raster mockup**: Considered, rejected. Token abstraction + responsive behavior matter more.

## Patterns specific to religious / cultural content

These emerged from the Quran work and may generalize to other content-heavy apps:

- **L15 — Sacred text needs typography care**: Arabic Quran text uses dedicated Quran fonts (Amiri Quran, Madinah Mushaf). Don't use general Arabic fonts; the spacing and ligatures matter.
- **L16 — Authenticity is a feature**: Using "Bismillah" glyph, "﷽" symbol, surah headers with ornamentation — these are not decoration; they're how the user recognizes the content as Quran.
- **L17 — Reciter credits matter**: "عبد الباسط عبد الصمد" with proper attribution is more important than UI polish. Users care about who they listen to.
- **L18 — Translation sourcing matters**: Sahih International, Pickthall, Yusuf Ali are different scholarly translations. Let users pick; don't default to one.

## Generalizations beyond Quran apps

These patterns apply to ANY content-heavy, multi-theme, multi-locale app:

- Any religious / cultural content (Bible, Torah, Bhagavad Gita, Tao Te Ching): same authenticity + typography care principles.
- Any educational content (textbooks, course material): real names, real citations, dedicated typography.
- Any government / regulated content (legal documents, medical information): typography precision matters more than visual flair.
- Any multi-language app with RTL support: separate RTL design problem, not CSS transform.

## For am-design maintainers

When updating `novel-abstractions-seed-list.md`, consider adding patterns from this list that aren't already there. Current seed list has 11 T + 12 R; this case study suggests ~5 more T patterns (L1, L3, L4, L13, L15) could be formalized.

When updating `multi-locale-checklist.md`, add the Eastern vs Western Arabic numerals section (currently mentioned but could be deeper) and the dual-calendar pattern.