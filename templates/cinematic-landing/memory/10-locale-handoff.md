# 10 · Locale handoff — USE THIS WHEN: shipping a non-English locale and need to flip `<html lang dir>` + reverse-test CSS logical properties + reorder am-coder's locale dispatch brief

The cinematic-landing template is locale-aware but locale-opinionated only on opt-in.

## Default

`<html lang="en" dir="ltr">` — see `memory/07-reduced-motion.md` for the reduced-motion context.

## Locale opt-in

To enable Arabic (`ar`), Hebrew (`he`), Persian (`fa`), Urdu (`ur`), or any RTL locale:

1. Set `<html lang="<code>" dir="ltr|rtl">` on the document root.
2. Flip CSS logical properties (`margin-inline-start`, `padding-inline-end`, etc.) — see `agents_manager/design/resources/multi-locale-checklist.md` for the full RTL checklist (project-agnostic; reused across templates).
3. Reverse-test every layout: hero, sections, nav, footer, modal, form inputs.
4. Verify motion respects both `prefers-reduced-motion` AND locale-specific motion preferences (some cultures prefer different easing — `cubic-bezier(0.4, 0, 0.2, 1)` is not universal).
5. Re-render the worked example (`cinematic-landing-kit-demo/`) under the target locale before shipping — surface regressions via `share/reports/04_review_<task-id>.md`.

## When locale = RTL

- Set `dir="rtl"` on `<html>` and re-flow every section.
- Hero cutout layer flips horizontally (mirror the cutout asset in image-gen.md).
- Scroll-driven films may need direction-reversed playback (TBD per film — see `memory/02-scroll-film-canvas.md` for the path that uses the film).
- Type pairing may need to swap (e.g., Arabic-friendly serif replaces the default Latin pairing — see `memory/05-theming.md` for token strategy).
- CTA frame ordering (`memory/08-cta-frames.md`) does not need to flip — the click-advance pattern is locale-agnostic.

## Handoff to am-coder / am-review

When dispatching am-coder on a non-English locale:

- Specify locale code in the dispatch prompt (e.g., `locale: ar-SA`, `locale: he-IL`).
- Reference this file by name so am-coder reads the checklist.
- am-review checks: `<html lang dir>` attributes set per this file + locale consistency across all 8 sections (header, hero, ritual, film, editions, cta, footer) + any RTL layout inversions documented in `decisions/decision-log.md`.

## Out of scope (deferred to a future patch)

- Multi-locale i18n string tables (currently all copy is hard-coded English in the skeleton).
- Per-locale asset generation (the prompts in `prompts/` are English-only; locale-specific re-prompting is the user's job).
- Locale-aware fallback fonts (the skeleton uses system stack; project-agnostic font fallback should live in `agents_manager/design/resources/`).