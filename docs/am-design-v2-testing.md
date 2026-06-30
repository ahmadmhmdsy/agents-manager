# am-design v2.0 — Testing Guide

> **Audience:** The owner reviewing or maintaining am-design v2.0.

Five tests, ordered from fast to slow. Run them after applying the changeset. If any fails, do not merge until the failure is diagnosed.

---

## Test 1 — Controller sanity (5 seconds)

**What it checks:** The standard `bin/check.sh` / `bin/check.ps1` validator still passes after am-design is added. This confirms:
- `opencode.jsonc` parses
- All required controller files exist
- `agents_manager/SKILL.md` frontmatter is valid
- No accidental deletion of upstream files

**How to run:**
```bash
bash bin/check.sh .
# or
.\bin\check.ps1 .
```

**Expected:** `Result: PASS=6 FAIL=0` (matches v0.8.0 baseline).

**If it fails:** Read the failing file path. Most common cause: missing directory in the changeset (e.g. `bin/lint-design.sh` not copied). Re-apply the steps in `am-design-v2-migration.md`.

---

## Test 2 — Lint worked examples (10 seconds)

**What it checks:** The new `bin/lint-design.sh` script reports no untokened colors or emoji in the worked example mockups.

**How to run:**
```bash
bash bin/lint-design.sh examples/
```

**Expected:** `OK: 4 mockup files passed lint.` (or similar — script reports per-file).

**If it fails:** A worked example uses raw hex or emoji somewhere. Inspect the reported file:line, decide whether to fix the example (preferred — keep the contract tight) or document an exception.

---

## Test 3 — Mode coverage spot-check (manual, 5 minutes)

**What it checks:** Each of the 12 modes has at least one worked example or the SKILL.md documents how to handle it.

**How to run:**
1. Open `agents_manager/design/SKILL.md`.
2. Read the modes table.
3. For each mode, verify it has a worked example OR clear "what you produce" guidance in the SKILL.md.
4. Coverage map:

| Mode | Worked example | Documented in SKILL.md |
|---|---|---|
| RESEARCH | (none — use `output-skeleton.md` template) | ✓ |
| CONCEIVE | `design-brand-identity` (Atlas) | ✓ |
| BRAND | `design-brand-identity` (Atlas) | ✓ |
| SYSTEMIZE | `design-onboarding` (Strides) + `design-responsive-web` (Lumio) | ✓ |
| MOCK | all 4 examples | ✓ |
| PROTOTYPE | (none — use the static mockup as starting point) | ✓ |
| EXTEND | (use existing examples as base) | ✓ |
| WRITE | (in Atlas color-palette.md has sample phrases) | ✓ |
| AUDIT | `design-audit` (Stride) | ✓ |
| EVALUATE | (see `design-audit` — accessibility focus) | ✓ |
| ILLUSTRATE | (none — would produce SVG icon set) | ✓ |
| TRANSLATE | (in `multi-locale-checklist.md`) | ✓ |

**Expected:** Every mode has at least one of the two columns checked.

**If a mode has neither:** That's a gap. Either add a worked example, or expand the SKILL.md "What you must produce" section to cover it.

---

## Test 4 — End-to-end dry run (manual, 30 minutes)

**What it checks:** Master can spawn am-design on a real-looking dispatch, am-design produces the expected artifacts, handoff reaches the right audience.

**How to run:**
1. Create a tiny sandbox project (any directory).
2. Install agents-manager from this branch.
3. Open OpenCode in that directory.
4. Run a master task with a UI-bearing brief, e.g.:
   > "Design a landing page for a meditation app. 3 breakpoints. Tokens in CSS variables. Audience: am-coder will implement in React."
5. Observe master's preflight, then dispatch to am-design.
6. Verify `share/design/<task-id>/00_brief.md` answers all 7 discovery questions.
7. Verify `04_mockups/web-responsive/index.html` exists if mode set includes MOCK.
8. Verify `99_handoff.md` ends with `STATUS: DONE` (or `DONE_WITH_CONCERNS`).
9. Verify `share/messages/design-to-coder-<task-id>-handoff.md` exists.

**Expected:** All 9 files exist and are well-formed.

**If am-design reports `NEEDS_CONTEXT`:** That's correct behavior for an ambiguous brief. Add clarity and re-dispatch.

**If am-design produces untokened mockups:** Bug — should have triggered anti-pattern refusal. File as a defect.

**If handoff doesn't reach the right audience:** Check the `audience:` field in the dispatch prompt. Master should declare this.

---

## Test 5 — Visual verification of one example (5 minutes)

**What it checks:** A worked example actually renders correctly when opened in a browser.

**How to run:**
1. Pick any worked example, e.g. `examples/design-responsive-web/share/design/T-2026-07-20-002/04_mockups/web-responsive/index.html`.
2. Open it in Chrome (or any modern browser).
3. Verify:
   - Phone, tablet, desktop frames render side-by-side at distinct sizes
   - Text is readable; no overflow
   - Colors match the token system
   - No console errors (open DevTools → Console tab)

**Expected:** Clean render. Three distinct viewports visible. No errors.

**If mockup looks broken:** Inspect the file — most likely cause is a missing Google Font or a syntax error in the inline CSS. Fix in the example (which is a teaching artifact, not production code).

---

## What these tests don't cover

- **Real browser interaction testing** — out of scope for static HTML mockups.
- **Design quality review** — these tests check the contract, not whether the design is good.
- **Performance** — mockup files are tiny (< 200KB), no real perf concern.
- **Accessibility of the mockups themselves** — visual mockups may not be screen-reader-accessible by design. The accessibility evaluation lives in `05_audit/` mode.

---

## Regression detection

If a future change to am-design breaks one of these tests:

1. Re-run the failing test.
2. If it fails, check `agents_manager/CHANGELOG.md` for the relevant v0.9.x entry.
3. Revert the specific change.
4. File the failure in the WARN register (`share/notes/04_warns_register_<task-id>.md`).

---

## Continuous integration (suggested for v3)

Future versions of `bin/check.sh` should:
1. Run tests 1 and 2 automatically (already does for test 1).
2. Optionally run `bash bin/lint-design.sh examples/` in a `lint-examples` CI job.
3. Optionally run test 4 as a smoke test if API keys are provided.

For now, tests 3 and 5 are manual review steps.