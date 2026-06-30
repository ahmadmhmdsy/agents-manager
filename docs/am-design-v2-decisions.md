# am-design v2.0 — Decision Log (ADR)

> **Status:** Living document. Add new ADRs as architectural choices are made. Mark superseded ADRs with ~~strikethrough~~ rather than deleting them.

This is the decision record for am-design v2.0. Each ADR captures: context, options considered, decision, consequences.

---

## ADR-001 — 12 modes, not 5

**Context.** v1 of am-design had 5 modes: `CONCEIVE`, `SYSTEMIZE`, `EXTEND`, `MOCK`, `AUDIT`. In real use, the agent kept being asked to do work that didn't fit any of these:

- "Design our brand identity from scratch" → not `CONCEIVE` (already past conception), not `MOCK` (no screens yet), not `SYSTEMIZE` (no system yet). Was brand identity work.
- "Add a notification settings screen" → closer to `EXTEND` + a new mode around UI patterns.
- "Audit our existing app for accessibility" → `AUDIT` covered it but didn't capture the WCAG-specific scope.
- "Translate our design to Arabic" → totally uncovered.
- "Write the microcopy for our onboarding" → uncovered (copy work).
- "Create an icon set for our settings" → uncovered (illustration work).
- "Build an interactive click-through prototype" → `MOCK` was static only; prototypes need a new mode.

**Decision.** Add 7 new modes: `RESEARCH`, `BRAND`, `PROTOTYPE`, `WRITE`, `EVALUATE`, `ILLUSTRATE`, `TRANSLATE`. Total: 12.

**Consequences.**
- (+) Coverage matches real design work patterns. No "this doesn't fit any mode" dispatch.
- (+) Mode set (not single mode) — a single dispatch can carry e.g. `{CONCEIVE, SYSTEMIZE, MOCK}` for a new-project flow.
- (+) Easier to reason about handoffs: each mode produces specific artifacts under specific folders (per `output-skeleton.md`).
- (-) 12 modes is more surface area to document. Mitigated by mode being a SET (most dispatches use 2-4 modes).
- (-) Master must learn which modes go together. Mitigated by `output-skeleton.md` per-mode decision tree.

---

## ADR-002 — Medium-aware, not project-locked

**Context.** v1 was implicitly mobile-only: the mockup template was 390×844 with a phone-frame chrome. Real design work happens across:

- Web (responsive: 390 / 768 / 1440)
- Mobile (iOS, Android)
- Desktop (1440×900)
- Tablet (1024×768)
- Watch, TV, kiosk (deferred to v3)
- Email (600px-safe)
- Print, packaging (deferred to v3)
- Brand identity (no screens)
- Icon set, illustration, motion (non-screen)

**Decision.** Replace the single `mockup-template.html` with `mockup-templates/` containing 6 templates: mobile, tablet, desktop, web-responsive, email, brand. Each template encodes the medium's locked dimensions and chrome.

**Consequences.**
- (+) Designer picks the right template per project, not retrofitting mobile templates.
- (+) Each template's chrome matches platform conventions (dynamic-island for iOS, traffic lights for desktop, table-fallback for email).
- (+) Brand and audit work (no screens) still get a template — brand.html and web-responsive.html cover them.
- (-) 6 templates instead of 1. Mitigated by all 6 being self-contained and short (~150 lines each).
- (-) Future mediums (voice, watch, TV) need new templates. Deferred to v3.

---

## ADR-003 — Tree output structure, not linear

**Context.** v1's output was a linear list: `00_brief.md` → `01_directions/<n>/` → `02_system/` → `03_audit.md` → `99_handoff.md`. This forced every dispatch to pretend all folders mattered. For a brand-only project, `02_system/` is empty. For an audit, `01_directions/` is empty.

**Decision.** Tree with optional folders. Each folder is created only when the corresponding mode is in the mode set:

```
share/design/<task-id>/
├── 00_brief.md                    ← ALWAYS
├── 01_research/                   ← mode includes RESEARCH
├── 02_brand/                      ← mode includes BRAND
├── 03_system/                     ← mode includes SYSTEMIZE
├── 04_mockups/<viewport>/         ← mode includes MOCK
├── 05_audit/                      ← mode includes AUDIT or EVALUATE
├── 06_copy/                       ← mode includes WRITE
├── 07_primitives/                 ← mode includes ILLUSTRATE
├── 08_translations/<locale>/      ← mode includes TRANSLATE
└── 99_handoff.md                  ← ALWAYS
```

**Consequences.**
- (+) Folder presence matches artifact set. No empty `02_system/` for brand work.
- (+) Per-mode deliverables decision tree (`output-skeleton.md` § Per-mode decision tree) makes the contract explicit.
- (+) Future modes (e.g. v3 motion) can add folders without breaking existing ones.
- (-) Owner has to consult `output-skeleton.md` to know what each mode produces. Acceptable — this is a design system contract.

---

## ADR-004 — Audience-aware handoff, not just `am-coder`

**Context.** v1's `99_handoff.md` assumed the next consumer was `am-coder`. Real consumers include:

- Human designer (imports to Figma)
- Frontend dev / engineer (component + token spec)
- PM / Product owner (visual reference deck)
- Stakeholder (executive summary, decision options)
- Marketing team (brand book, copy deck)
- External agency (brief + brand guidelines + assets)
- Accessibility reviewer (audit findings)
- Localizer (translation strings)

**Decision.** `99_handoff.md` declares the audience explicitly, and the per-audience reading list is documented in `output-skeleton.md` § Audience-aware.

**Consequences.**
- (+) Right artifact reaches the right consumer. Stakeholder doesn't have to read token JSON.
- (+) External agency handoff is now first-class.
- (-) Owner needs to know which audience they want before dispatching am-design. Mitigated by master's discovery protocol asking "who is the audience?" up front.

---

## ADR-005 — 7-question discovery before production

**Context.** v1 had no discovery. am-design would dive in based on the brief. In real use, this caused:

- Wrong-medium dispatches (mobile-only design for a web project)
- Wrong-audience artifacts (token JSON for a stakeholder)
- Scope creep (every "small ask" turned into a system design)
- Silent guessing on ambiguous briefs

**Decision.** am-design asks 7 questions before producing anything, writes answers into `00_brief.md`:

1. Medium?
2. Audience?
3. Constraints?
4. Artifact set?
5. Mode set?
6. Scope tier?
7. Success criteria?

If any answer is ambiguous, surface as `NEEDS_CONTEXT` before producing. Do NOT guess.

**Consequences.**
- (+) No more wrong-medium dispatches.
- (+) Scope is bounded up front.
- (+) User can interrupt before any work is done if the answers are wrong.
- (-) One more step before production. Worth it — produces fewer rework loops.

---

## ADR-006 — Strict separation, no carve-outs

**Context.** v1 had strict separation: am-design writes design artifacts, never touches `src/**`. During planning, we considered allowing am-design to produce minimal reference scaffold (a single component in the user's framework) for design-system-as-implementation tasks.

**Decision.** Strict separation only. No scaffold carve-outs. If the user wants a reference implementation, master spawns a small `am-coder` task with `share/design/<task-id>/` as input.

**Consequences.**
- (+) Clean architecture. No blurred lanes.
- (+) am-design's role stays focused on design artifacts.
- (+) Reference implementations stay version-controlled through `am-coder`.
- (-) One extra dispatch when scaffold is wanted. Acceptable — explicit > implicit.

---

## ADR-007 — `.md` + `.json` mirror for every spec

**Context.** v1 had `.md` for human readers, `.json` for machine consumption, mirrored. Both required.

**Decision.** Keep this rule. Every spec ships as both files with identical content (modulo formatting).

**Consequences.**
- (+) LLMs and humans read `.md`; agents and tools read `.json`. One source, two consumers.
- (+) Lint rule catches specs with only one file.
- (-) Two files to maintain per spec. Mitigated by the contract being clear.

---

## ADR-008 — Multi-theme via `var(--xxx)` + `[data-theme]` attribute

**Context.** Inherited from v1 (no override needed). Validated by the Quran app case study (`examples/design-casestudy-quran/`).

**Decision.** Keep. Document the generalization in `output-skeleton.md` § Themes.

**Consequences.**
- (+) Works for any project needing theming.
- (+) Single component code, semantic tokens, theme attribute.
- (+) No component branching per theme.
- (−) Token names must be theme-agnostic (e.g. `--primary`, not `--sage`).

---

## ADR-009 — Anti-patterns as refusal list, not suggestions

**Context.** v1 had 8 anti-patterns framed as "be careful about." In practice, this didn't prevent the patterns from happening.

**Decision.** Frame anti-patterns as refusals. "Refuse to inline hex outside `:root`." Each is binding.

**Consequences.**
- (+) Clearer contract.
- (+) Owner can audit against the refusal list.
- (-) Some refusals are situational (e.g. "no emoji as UI" might be fine for a kids' app). Mitigated by `R3 — Emoji as ornaments` allowing case-by-case decisions when documented.

---

## ADR-010 — Worked examples as proof, not decoration

**Context.** v1 had 1 worked example. v2 ships 4 + 1 case study.

**Decision.** Every mode set should have at least one worked example. Each example must be complete (brief → artifacts → handoff → message).

**Consequences.**
- (+) New agents can study the examples to learn the contract.
- (+) Owners see what "done" looks like per mode.
- (+) Case study (`design-casestudy-quran`) retroactively documents a real project as am-design v0.5 behavior, proving the pattern works.
- (−) More files to maintain. Mitigated by being proof, not exhaustively tested.

---

## ADR-011 — Semantic versioning: v0.9.0 (additive minor)

**Context.** am-design is being added for the first time. v1 was a separate effort. v2 builds on v1. From the owner's perspective:

- v0.8.0 had no am-design
- v0.9.0 adds am-design v2.0 (12 modes, 6 mediums, etc.)

**Decision.** Tag this as **v0.9.0** (minor bump). Add to `agents_manager/CHANGELOG.md` as a new entry, on top of v0.8.0.

**Rationale.** v0.9.0 signals "additive capability, opt-in by default, no breaking change." Owners on v0.8.0 can upgrade without rewriting anything.

**Consequences.**
- (+) Standard semver semantics.
- (+) Clear signal to existing v0.8.0 users: nothing breaks.
- (−) Doesn't communicate the magnitude of the addition (12 modes, 6 mediums, 4 examples + case study). Mitigated by the detailed `CHANGELOG.md` entry and `01-PR_DESCRIPTION.md`.

---

## ADR-012 — bin/lint-design.sh helper script

**Context.** Several anti-patterns in `novel-abstractions-seed-list.md` are detectable by static analysis: inline hex outside `:root`, emoji in UI markup, untokened mockups. A lint script enforces them.

**Decision.** Add `bin/lint-design.sh` as an optional helper. Runs after `bin/check.sh`. Reports violations. Does NOT block commits (lint is advisory, like ESLint without `--max-warnings 0`).

**Consequences.**
- (+) Owners can run it in CI to catch regressions.
- (+) Optional — projects that don't want it can ignore.
- (−) Lint false positives possible (e.g. hex inside SVG color stops is fine). Mitigated by scoping to mockup HTML files only.

---

## Superseded decisions

_None yet._

---

## Open questions (deferred to v3)

- Should `agents_manager/SKILL.md` (master) automatically invoke am-design when `auto_accept_warns` is true and the warn concerns design? Currently master's "Phase 1.5 Design" is opt-in.
- Should the lint script run automatically in `bin/check.sh`, or stay separate? v2 ships them separate. v3 may merge.
- Should `examples/design-casestudy-quran/` move into a separate `case-studies/` folder, or stay under `examples/`? v2 keeps it under `examples/`. v3 may split.