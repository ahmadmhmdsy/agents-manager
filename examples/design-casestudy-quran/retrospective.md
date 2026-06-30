# Retrospective — Quran App Design System

## Timeline

- **Pre-project**: User had completed a Swiss-Bauhaus Shopify theme (`fashion-theme`). Pivoted to Quran app design.
- **Phase 0 — Direction brainstorm**: 4 visual directions proposed and approved (Modern Minimal, Traditional Illuminated, Apple Contemporary, Saudi Arabian Contemporary).
- **Phase 1 — Master design system**: Built a master layer that all 4 themes could extend. Files: `README.md`, `SPEC.md`, `AGENTS.md`, `tokens/base.json`, `tokens/tokens.css`, `components/COMPONENTS.md`, `patterns/PATTERNS.md`, 23 page specs in `.md` + `.json`.
- **Phase 2 — Per-theme specs**: For each direction, wrote `SPEC.md` (visual direction) + `tokens.json` (concrete token values).
- **Phase 3 — Mockups**: 4 HTML files, one per direction. Each started with 7 screens (Splash, Home, Surah List, Reader, Ayah Detail, Audio Player, Settings). Then extended with 16 more screens each.
- **Total**: ~92 phone screens across 4 themes, plus ~50 design-system files.

## What am-design v0.5 looked like in practice

There was no formal `am-design` agent yet. The work was done by a single LLM session following the user's brief directly. Patterns emerged organically:

### Patterns that worked (and should formalize)

1. **Token abstraction from day one**. Every color, font, spacing defined as a CSS variable in `:root` (or `[data-theme]` block). Made theme switching trivial.
2. **`.md` + `.json` mirror from day one**. Every spec had two files with identical content. Made machine consumption trivial without losing human readability.
3. **Authentic Arabic content**. Used real Surah names (الفاتحة, البقرة, …), real ayahs (Ayat al-Kursi 2:255, Al-Ikhlas 112:1-4), real reciters (عبد الباسط عبد الصمد, مشاري العفاسي), real Hijri date (12 ربيع الأول 1447). Zero lorem ipsum.
4. **First 7 screens set the language**. Splash, Home, Surah List, Reader, Ayah Detail, Audio Player, Settings — these 7 covered ~80% of recurring UI patterns (cards, lists, settings groups, modals, players, navigation chrome). The next 16 screens reused these primitives.
5. **Mode-set thinking from day one**. Each theme was a self-contained mockup. Adding a new theme meant one new HTML file + token overrides — no component rewrites.
6. **Multi-theme via `[data-theme]` attribute**. Single token map per theme. No component code branching.
7. **Per-direction folder structure**. `01-modern-minimal/`, `02-traditional-illuminated/`, etc. Made review and comparison trivial.

### Patterns that emerged late (should have formalized earlier)

1. **Status bar / phone chrome template**. By screen 30, the same SVG icons (signal/wifi/battery) + 9:41 time were being copy-pasted. Should have been a snippet.
2. **Self-critique became important around screen 50**. Started asking "does this use var(--xxx) tokens? Is RTL correct?" — should have been a gate from screen 1.
3. **Discovery happened implicitly through trial-and-error**. "What does Apple Contemporary look like with a dark variant?" only came up after the first theme was done. Should have been in scope definition.

### Failure modes encountered

1. **Large-edit truncation**: Edit tool failed on newStrings over ~50KB. Forced batching into smaller chunks per theme. Fix: chunk 4-5 screens per edit instead of 16.
2. **PowerShell + UTF-8 + Arabic encoding pain**: `Get-Content` decodes as Windows-1252 by default. Got `??????` in console output. The files themselves were fine (saved as UTF-8); only the read tool was the problem.
3. **Scope creep across themes**: User kept asking "can we add a dark variant?" / "can we add a few more screens?" Each was a legitimate ask but caused late rework on the canvas structure.
4. **Misalignment with framework**: This was a "framework-agnostic" deliverable, but the user later asked "how do I give this to LLMs to build the app?" — which forced the v1 of am-design to exist as a separate deliverable. Should have been part of scope from the start.

## What am-design v2 would do differently

If we ran this same project through `am-design` v2 from day one:

### Dispatch 1 — Discovery + CONCEIVE
- Master asks 7 discovery questions: medium (mobile), audience (multiple — dev team + LLMs), constraints (multi-theme, RTL Arabic, framework-agnostic), artifact set (tokens + 4 mockups + LLM handoff docs), mode set (CONCEIVE + SYSTEMIZE + MOCK + WRITE), scope tier (full), success criteria (LLMs can build the app from the artifacts).
- am-design produces: `00_brief.md` + `01_research/concepts/<n>/SPEC.md` (4 directions proposed, no mockups yet).
- User picks a direction.

### Dispatch 2 — SYSTEMIZE (per direction)
- am-design produces: `03_system/tokens/base.json` (theme-agnostic schema) + `03_system/tokens/tokens.css` (compiled) + `03_system/components/COMPONENTS.md` + `03_system/patterns/PATTERNS.md` + `03_system/pages/<name>.{md,json}` (23 pages).
- Mode set = SYSTEMIZE.

### Dispatch 3 — MOCK (per direction)
- am-design produces: `04_mockups/mobile/<screen>.html` (23 screens) + `04_mockups/mobile/index.html` (all-in-one view).
- Mode set = MOCK.

### Dispatch 4 — BRAND + WRITE (cross-cutting)
- am-design produces: `02_brand/` artifacts (typography, color, voice) + `06_copy/microcopy.md` + `06_copy/content-strategy.md`.
- Mode set = BRAND + WRITE.

### Dispatch 5 — Handoff package
- am-design produces: `99_handoff.md` with audience-aware routing (LLMs consume tokens + mockups; PM consumes executive summary; stakeholder consumes index.html views).
- Mode set = none (consolidation only).

### Re-entry pattern

If user adds a screen (e.g. "add a Notifications page"):

- Dispatch 6 — EXTEND
- am-design produces: append to `03_system/pages/notifications.md` + `.json` + new `<screen>.html` under `04_mockups/mobile/`.
- Mode set = EXTEND.

If user audits (e.g. "review for accessibility"):

- Dispatch 7 — AUDIT
- am-design produces: `05_audit/findings.md` + `severity-matrix.md` + `remediation-plan.md`.
- Mode set = AUDIT.

## Why this matters for am-design v2

This case study validates several v2 design decisions:

1. **Discovery protocol is essential.** Without it, we'd have shipped the same scope-creep pattern.
2. **Mode set must be honored as set, not single.** This project needed CONCEIVE → SYSTEMIZE → MOCK → WRITE in sequence. Treating it as one big "design" task hid the structure.
3. **Scope tier matters.** This was `scope=full`. Folder structure should reflect that (system + multiple directions + brand + copy + handoff). v1's "linear" tree (brief → directions → system → audit → handoff) didn't accommodate this.
4. **Audience-aware handoff is critical.** This project's success criterion was "LLMs can build the app from the artifacts" — which is the `am-coder` audience but with an extra constraint that the consumer is an LLM, not a human dev.
5. **Multi-theme is a first-class concern.** Token abstraction with `[data-theme]` attribute switching worked beautifully. Should be a recognized mode/pattern, not a special case.

## Open improvements for future am-design versions

Based on this case study, things v3 should consider:

- **Dark variant as first-class**: When a theme ships, consider a dark variant in the same dispatch.
- **Motion spec for the player**: Audio Player screen has scrubber + transport controls. Static mockup can't convey feel. v3 should auto-suggest motion mode when player UI is in scope.
- **Brand-guidelines synthesis**: When multiple themes share components (typography, spacing), there should be a `02_brand/` synthesis pass that captures cross-theme invariants.
- **Internationalization metadata per mockup**: Every mockup file should declare its `lang` and `dir` in a comment header, so consumers know what they're looking at.