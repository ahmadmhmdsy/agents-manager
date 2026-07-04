# Decision log — cinematic-landing task

> Append-only log of decisions made during this task's lifecycle. The cinematic-landing
> template's `am-assets` writes here at build time; `am-coder` appends when picking
> implementation paths; `am-review` appends for any deviations accepted.

---

## D-2026-07-04-am-assets-live

**Status:** live (since v0.12.0)
**Context:** v0.12.0 (2026-07-03, commit f07ada5) shipped the
  `am-assets` 6th specialist alongside the `agents_manager/assets/`
  subtree (SKILL.md, rules.md, README.md, notes/branch-decisions.md,
  notes/README.md, resources/landing-review-checklist.md). The
  `cinematic-landing` template's MANIFEST.txt cites 3 of those files
  as cross-tree asset sources.
**Action:** WARN-2 revert restores those 3 MANIFEST entries that a
  prior brief misread as phantom-specialist references.
**Note:** Replaces the prior D-2026-07-04-am-assets-deferred entry,
  which was based on the same misread.

---

## <DATE> — am-assets
**Decision:** Branch <A|B|C|D> selected per user input.
**Why:** <evidence from user prompt>
**Tradeoff:** <what the user gives up vs gains>
**Refs:** `assets/MANIFEST.json`

---

## <DATE> — am-coder
**Decision:** Locale = <en/ar/...> per `04-locale-handoff.md`.
**Why:** <evidence>
**Refs:** `<html lang dir>`

---

## <DATE> — am-review
**Decision:** <Any accepted deviations / WARNs>
**Refs:** `share/reports/04_review_*.md`