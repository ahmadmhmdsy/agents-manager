# Case Study — Quran App Design System (am-design v0.5 retrospective)

## What this is

This is a retrospective case study documenting a real-world design system build — a multi-theme, multi-locale Quran app for iOS — and what it teaches us about how `am-design` should behave.

The work happened **before** `am-design` was formalized. If we had run the work through `am-design` v2 from the start, the artifacts would have landed in the tree structure defined by `output-skeleton.md`. This case study reconstructs that mapping and surfaces the patterns that should generalize.

## The work being studied

**Project**: Quran app design system + 4 visual directions × 23 screens per direction.

**Where the actual files live** (not part of this case study):

```
E:\minimax_projects\fashion-theme\quran-app-prototypes\
├── 01-modern-minimal.html
├── 02-traditional-illuminated.html
├── 03-apple-contemporary.html
├── 04-saudi-arabian-contemporary.html
├── README.md
├── SPEC.md
├── AGENTS.md
├── tokens/
├── components/
├── patterns/
├── pages/
└── themes/
```

**What was built**:
- 4 visual directions (Modern Minimal, Traditional Illuminated, Apple Contemporary, Saudi Arabian Contemporary).
- 23 phone screens per direction (Splash, Home, Surah List, Reader, Ayah Detail, Audio Player, Settings, Onboarding, Search Results, Bookmarks, Prayer Times, Qibla Compass, Hijri Calendar, Tafsir Browser, Reading Plan, Reciter Selection, Translation Selection, Hadith Library, Dua & Dhikr, Streak, Downloads, Notifications, About).
- Design tokens for each direction (color, typography, spacing, radius).
- Component catalog (25 components with full props/states/variants).
- Pattern library (12 recurring compositions).
- Per-page specs in `.md` + `.json` mirror.

## Files in this case study

- `retrospective.md` — narrative: what happened, what am-design v0.5 looked like in practice, what we'd change with v2.
- `lessons.md` — bullet-list of patterns learned. These should inform future dispatches.
- `mapping.md` — for every actual artifact produced, where it would have lived under am-design v2's output tree.

## Why this case study matters

1. **Proves the agent pattern works on a real multi-theme, multi-locale, multi-screen project.**
2. **Surfaces patterns that aren't in the seed lists yet** (e.g. multi-theme color override patterns, Eastern vs Western Arabic numerals).
3. **Surfaces failure modes** (e.g. large-edit truncation, encoding pain with Arabic in PowerShell).
4. **Provides a worked example** for a project that's larger and more complex than any of the 4 example folders shipped with v2.

## Audience for this case study

- Anyone learning am-design: read this to see what real work looks like.
- am-design maintainers: this is the source of patterns to add to `novel-abstractions-seed-list.md` over time.
- A future agent: read `lessons.md` to avoid repeating mistakes.