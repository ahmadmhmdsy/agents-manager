---
scope: templates
topic: extraction-standard
status: active
version: 1.0.0
created: 2026-07-04
last_verified: 2026-07-04
---

# Template Extraction Standard (v1)

Extraction turns a **finished** agents-manager project into something reusable:
either (A) a new template at `templates/<slug>/`, or (B) tagged memory entries
under `agents_manager/memory/{global,projects/<slug>}/`. It is an **agent-led**
activity — no CLI script — driven by the `agents_manager/extract/` skill and
gated by this rulebook.

This standard is the **sibling** of `templates/AUTHORING.md`, not its
replacement:

- `AUTHORING.md` governs how you **author** a template from scratch (the
  full 9-step recipe, Rules 1–8, the acceptance checklist).
- `EXTRACTION.md` (this file) governs how you **extract** a starter template
  or core knowledge from an existing project, then **hand the starter to the
  AUTHORING.md recipe** to finish it.

Extraction is additive and one-directional: it **reads** the source project and
**writes** new artifacts. It never edits the source. The scaffold is fast; the
finishing work is the AUTHORING.md recipe, done afterwards by a human or a
follow-up coder pass.

Companion: `templates/CONTRIBUTING.md` (the discoverable entry point),
`agents_manager/memory/README.md` (the memory schema every sub-ask-B write must
satisfy), and `agents_manager/extract/SKILL.md` (the loadable procedure).

Exemplar referenced throughout: `templates/cinematic-landing/`.

---

## TL;DR — 8 rules

1. **Extraction is additive, never destructive.** You read the source project;
   you never modify it. Every write lands on a NEW path (`templates/<slug>/`,
   `agents_manager/memory/**`, or a draft under `share/templates/drafts/`).
2. **Pre-flight gates every write.** No scaffold, no memory entry, no LICENSE
   copy happens until the pre-flight checklist passes: license scan +
   attribution, secrets denylist, Jaccard overlap check, and source
   `04_warns_register_<source>.md` status. A failed gate is a refusal, not a
   warning.
3. **Scaffold from `_blank/`, do not hand-roll.** `cp -r templates/_blank/
   templates/<slug>/`. The starter ships every required file as a placeholder
   pointing back at `AUTHORING.md`. Fill placeholders; do not invent structure.
4. **Never auto-default memory scope.** Every sub-ask-B entry needs a
   user-confirmed `scope` (`global` | `project`) plus `tech_stack:` and/or
   `domain:` tags. `global/` is never the silent default.
5. **The output must pass its own gates.** Run `bash templates/<slug>/tests/verify.sh`
   after scaffolding and `bash scripts/validate-memory.sh` after any memory
   write. Non-zero exit means the artifact is not shipped.
6. **Suffix on collision, never overwrite.** If `templates/<slug>/` exists,
   scaffold `templates/<slug>-v2/` (then `-v3`, …). If a memory topic already
   exists, supersede it per the memory README lifecycle — never clobber.
7. **Extraction is one honest pass, not a wizard.** The scaffold is ~30s
   (placeholder fill only). The template is NOT done until the AUTHORING.md
   9-step recipe is complete. Say so; do not oversell the scaffold as a
   finished template.
8. **Every run emits an audit log.** Write `share/notes/03_extracted_<task-id>.md`
   recording sources read, destinations written, pre-flight verdicts, and the
   `verify.sh` / `validate-memory.sh` results. See end of file.

---

## What extraction produces

Extraction has two output shapes. A single run may do one or both, but each is
gated and logged independently.

### Sub-ask A — a starter template

```
templates/<slug>/              # cp -r from templates/_blank/
  00-readme-first.md           # filled: what this template is, how to discover it
  INDEX.md                     # filled: sections, hard rules, tokens, trigger phrases
  decisions/decision-log.md    # seeded: the extraction decision + AUTHORING TODOs
  memory/                      # SEEDED ONLY — author completes per AUTHORING recipe
  skeleton/                    # copied reference implementation (secrets-scrubbed)
  prompts/                     # optional; carried over if the source had reusable prompts
  assets/MANIFEST.txt          # every line must resolve (Rule 5 / F2)
  tests/verify.sh              # placeholder PASS lines removed (F1)
  LICENSE                      # present + attributed + on whitelist (Rule 3 / F5)
```

The scaffold is a **starting point**. It is handed to `templates/AUTHORING.md`
"For authors" recipe to become a real template. Extraction stops at "the
placeholders are filled and `verify.sh` passes"; AUTHORING.md takes it the rest
of the way.

### Sub-ask B — tagged memory entries

```
agents_manager/memory/global/<topic>.md          # cross-project insight
agents_manager/memory/projects/<slug>/<topic>.md  # project-scoped insight
```

Each entry follows the canonical schema in `agents_manager/memory/README.md`
(≤20 lines, required frontmatter) plus the new filter fields `tech_stack:` and
`domain:`. These entries are how "the most needed/common/core part" of a
finished project becomes reusable knowledge other agents filter on read.

Forbidden output paths (see `agents_manager/extract/rules.md`):

- `templates/<slug>/memory/` written to as a *controller-memory* lane — that
  tree is the template author's runtime playbook, not controller memory
  (Rule R1). Extraction seeds it as template content only.
- Anything inside the **source** project (extraction is read-only on source).
- `opencode.jsonc`, `CLAUDE.md`, or any specialist `SKILL.md`/`rules.md`.

---

## Rule details

Each TL;DR rule, expanded with the failure it prevents. The enforceable form of
these lives in `agents_manager/extract/rules.md` (R1–R8); this section is the
*why*.

### Rule 1 — Additive, never destructive

Bad: an extraction that "cleans up" the source project's `INDEX.md` while
reading it, or deletes a stale file it noticed. Extraction now has side effects
on a project it does not own.

Good: extraction opens every source file read-only. The only writes land on new
paths (`templates/<slug>/`, `agents_manager/memory/**`, `share/templates/drafts/`).
If the source has a defect, log it in the audit log — do not fix it here.

### Rule 2 — Pre-flight gates every write

Bad: scaffold first, scan for secrets afterwards. A `.env` value is already
copied into `skeleton/` and committed before anyone looks.

Good: the pre-flight checklist runs to completion before the first `cp`. A gate
failure is a refusal that returns to master, not a WARN the run scrolls past.

### Rule 3 — Scaffold from `_blank/`, do not hand-roll

Bad: the agent writes `templates/<slug>/INDEX.md` and `tests/verify.sh` from
memory, inventing a structure that drifts from every other template.

Good: `cp -r templates/_blank/ templates/<slug>/` gives you every required file
as a placeholder. You fill placeholders; the folder shape is inherited, not
reinvented. (If `_blank/` lacks a file the source needs, that is an AUTHORING.md
gap — flag it, do not paper over it.)

### Rule 4 — Never auto-default memory scope

Bad: every extracted insight lands in `agents_manager/memory/global/` because
"it might be useful everywhere." Six months later, unrelated projects read
noise.

Good: the agent proposes `scope` + `tech_stack:` / `domain:` per entry; the user
confirms. A React-specific gotcha is `scope: global, tech_stack: react` — a
future Vue project's soft-filter skips it. (See the read-side filter step in
`agents_manager/memory/README.md`.)

### Rule 5 — The output must pass its own gates

Bad: "verify.sh has a couple of failures but they look cosmetic" — ship anyway.

Good: `bash templates/<slug>/tests/verify.sh` exits 0 and
`bash scripts/validate-memory.sh` exits 0 before the scaffold leaves your hands.
A red gate is an incomplete extraction; return BLOCKED rather than ship it.

### Rule 6 — Suffix on collision, never overwrite

Bad: `templates/dashboard/` exists; the extraction `cp -r`'s over it and the
original template is gone.

Good: on collision, scaffold `templates/dashboard-v2/`. For memory, supersede
the existing `topic:` entry (`status: superseded` + `superseded_by:`) per the
memory README lifecycle — the original stays as a tombstone.

### Rule 7 — One honest pass, not a wizard

Bad: the Phase 5 prompt says "Extract to a finished template (~30s)." The user
clicks, gets a placeholder-filled scaffold, and thinks it is done.

Good: the prompt and this rulebook say "scaffold a starter (~30s — fills
placeholders only; complete the `AUTHORING.md` 9-step recipe afterwards)."
Honest framing prevents the scaffold being mistaken for a shippable template.

### Rule 8 — Every run emits an audit log

Bad: an extraction runs, files appear, and nobody can reconstruct what was read,
what was scrubbed, or whether the source WARN register was clean.

Good: `share/notes/03_extracted_<task-id>.md` is the receipt. It is the F8
evidence (source WARN register was clean) and the review's starting point. See
the format at the end of this file.

---

## Pre-flight checklist

Run **all** of these before the first write. Each maps to an
`agents_manager/extract/rules.md` rule and, where relevant, to one of the 8
am-review FAIL conditions (`F1`–`F8`, from
`share/notes/01_research_T-2026-07-04-009_angle-operations.md:178-185`). A
failed gate is a **refusal + surface to master**, never a silent proceed.

The pre-flight is the **forward-looking encoding of F1–F8**: it gates every
future extraction run against the same conditions am-review checks at
promotion time, so the two never disagree.

### PF-1 · License scan + attribution → enforces F5 (rules.md R3)

- [ ] The source project declares a LICENSE, and it is on the whitelist:
      **MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, CC0, CC-BY, or a
      user-declared-equivalent.**
- [ ] `templates/<slug>/LICENSE` will exist and carry an attribution line
      naming the source (`Portions extracted from <source> under <license>`).
- [ ] If the license is unknown, copyleft-incompatible, or unattributed →
      **REFUSE.** Surface: "LICENSE inheritance is a human call — see 'What the
      agent can't decide'."

**F5 verify (at promotion):** `[ -f templates/<slug>/LICENSE ]` and the license
string is on the whitelist. Extraction's PF-1 is the gate that guarantees this
passes.

### PF-2 · Secrets denylist → enforces F6 (rules.md R2)

Scan every candidate file (skeleton, prompts, memory drafts) against the
denylist before it is written:

- [ ] Path denylist: `.env*`, `*.pem`, `*.key`, `id_rsa*`, `02_secrets_*`.
- [ ] Content regexes: `sk-[A-Za-z0-9]{20,}`,
      `-----BEGIN [A-Z ]*PRIVATE KEY-----`.
- [ ] Any hit → **REFUSE the file** (not the whole run); surface the path and
      the matched pattern. A confirmed false positive (e.g. a test fixture
      `sk-test...`) is a `W-extract-secrets-near-miss` WARN, user-confirmed.

**F6 verify:** `rg -l '\.env' templates/<slug>/skeleton/` and the two content
regexes must all return 0 hits in the shipped skeleton.

### PF-3 · Jaccard overlap vs existing templates → enforces the duplicate-template guard (R8 risk)

- [ ] Compute Jaccard token overlap of the proposed `INDEX.md` + `00-readme-first.md`
      against every existing `templates/<other>/`.
- [ ] **> 0.6 → REFUSE.** Surface: "This overlaps `templates/<other>/`
      (Jaccard <score>). Promote via `templates/CONTRIBUTING.md` → 'I want to
      add a memory file' instead of forking a near-duplicate."
- [ ] **0.4–0.6 → WARN** (`W-extract-overlap-with-existing`); proceed only on
      user "fork anyway" confirmation.

A cheap Jaccard: lowercase, split on non-word chars, dedupe to a set per file,
`|A ∩ B| / |A ∪ B|`. Exact algorithm is the agent's call; the thresholds are not.

### PF-4 · Source WARN register status → enforces F8 (rules.md R8)

- [ ] Read `share/notes/04_warns_register_<source-task-id>.md`.
- [ ] **Any `OPEN` entry → REFUSE** by default. Extraction propagates unresolved
      defects into the template. Surface each OPEN entry.
- [ ] User may explicitly accept propagation (`W-extract-source-has-open-warn`,
      NOT auto-acceptable) — record the acceptance in the audit log.
- [ ] `DEFERRED` entries → WARN + ask; they travel with the extraction.

**F8 verify:** `rg -c '^OPEN' share/notes/04_warns_register_<source>.md` must be
`0` at extract time (or a logged, user-accepted exception).

### PF-5 · Manifest resolvability → enforces F2 (rules.md R4)

- [ ] Every path written to `templates/<slug>/assets/MANIFEST.txt` must resolve
      in the working tree at extract time. Cross-tree references to
      non-existent files are forbidden unless marked `(proposed)` and tracked in
      `decisions/decision-log.md` (AUTHORING.md Rule 5).

**F2 verify:** the MANIFEST resolution loop
(`while IFS= read -r p; do [ -e "$p" ] || exit 1; done < MANIFEST.txt`) exits 0.

### PF-6 · Placeholder / trigger hygiene → enforces F1 + F3 + F4 + F7 (rules.md R4)

These four are all caught by `tests/verify.sh` once the scaffold is filled, but
pre-flight names them so the agent fills them deliberately rather than shipping
`_blank/` boilerplate:

- [ ] **F1** — `templates/<slug>/tests/verify.sh` contains no placeholder PASS
      lines (`rg -n 'placeholder' tests/verify.sh` → 0). The `_blank/` starter
      ships stubs; you replace them with real grep-tests per AUTHORING Rule 4.
- [ ] **F3** — every seeded `memory/*.md` H1 carries `USE THIS WHEN:`.
- [ ] **F4** — every seeded `memory/NN-*.md` H1 number equals its filename
      prefix.
- [ ] **F7** — `INDEX.md` carries real trigger phrases (`## Use when` /
      `## Trigger phrases`), not the placeholder "see worked example".

**Verify (all four):** `bash templates/<slug>/tests/verify.sh` exits 0 (it runs
the F1/F3/F4 checks) and `rg -c '^## (Use when|Trigger phrases|Use this template when)'
templates/<slug>/INDEX.md` is ≥1 (F7).

### PF-7 · Memory schema (sub-ask B only) → enforces R5

- [ ] Every extracted memory entry carries required frontmatter (`scope`,
      `topic`, `status`, `created`, `last_verified`) plus `tech_stack:` and/or
      `domain:`.
- [ ] Entry is ≤20 lines including frontmatter (memory README size cap).
- [ ] `scope` is user-confirmed per entry; `global/` is never auto-defaulted
      (rules.md R6).

**Verify:** `bash scripts/validate-memory.sh` exits 0 after the write batch.

### Pre-flight FAIL-condition coverage map

| FAIL | Condition (source) | Pre-flight gate | Rule enforcing |
|------|--------------------|-----------------|----------------|
| F1 | placeholder PASS lines in verify.sh | PF-6 | R4 |
| F2 | manifest references missing files | PF-5 | R4 |
| F3 | memory file missing `USE THIS WHEN:` | PF-6 | R4 |
| F4 | H1 number drifts from filename | PF-6 | R4 |
| F5 | LICENSE missing / off-whitelist / unattributed | PF-1 | R3 |
| F6 | secrets in skeleton | PF-2 | R2 |
| F7 | INDEX trigger phrases empty / boilerplate | PF-6 | R4 |
| F8 | source WARN register has OPEN entries | PF-4 | R8 |

If any pre-flight gate fails and cannot be resolved by the agent, **STOP** and
return to master with the failed gate id + evidence. Do not scaffold around it.

---

## The 9-step extraction recipe

Parallel to the "For authors" recipe in `templates/AUTHORING.md:248-290`. Each
step names the action, the file/folder it touches, and a one-line trace against
the `templates/cinematic-landing/` exemplar. Do not skip steps.

1. **Pre-flight the source.** Run the full pre-flight checklist above (PF-1
   through PF-7 as applicable). Nothing is written until every gate passes.
   *Trace: before cinematic-landing could have been extracted, its source would
   need a whitelisted LICENSE, a clean secrets scan of `skeleton/index.html`,
   and 0 OPEN entries in its WARN register.*

2. **`cp -r templates/_blank/ templates/<slug>/`.** Use the starter, never a
   hand-rolled tree. Pick `<slug>` from the source's dominant domain; suffix
   on collision (Rule 6). *Trace: cinematic-landing's slug is its single domain
   — "scroll-driven product/brand landing". A second extraction of the same
   shape would land at `cinematic-landing-v2/`.*

3. **Fill `INDEX.md` first.** The consumer's entry point: sections, runtime
   branches, hard rules, tokens, and real trigger phrases (F7). *Trace:
   cinematic-landing's INDEX lists 9 sections, 4 runtime branches, 5 hard
   rules, a 14-token palette, and discovery greps (`data-section="hero"`,
   `.fallback-host.is-missing`) — all in ~167 lines.*

4. **Seed memory files in monotonic order (sub-ask A) OR write tagged memory
   entries (sub-ask B).** For A: seed only the memory files the extraction can
   justify from the source; leave the rest for the AUTHORING author. Each H1 is
   `# NN · <topic> — USE THIS WHEN: …` (F3 + F4). For B: one ≤20-line entry per
   durable insight, with `scope` + `tech_stack:`/`domain:` (R6). *Trace:
   cinematic-landing carries 14 memory files, 01–14, each with a `USE THIS
   WHEN:` trigger; 10–14 were review-driven additions, not speculative.*

5. **Scrub + copy the skeleton (sub-ask A).** Copy the source's reference
   implementation into `skeleton/`, running the secrets denylist (PF-2 / F6) on
   every file. Replace real brand/customer content with fictitious placeholders
   and an HTML comment (`<!-- fictitious names; replace before production -->`).
   *Trace: cinematic-landing's skeleton uses the fictitious "Maison Lumen
   Apothecary" brand throughout — no real customer data.*

6. **Fix the manifest + verify.sh placeholders.** Make every `assets/MANIFEST.txt`
   line resolve (PF-5 / F2); remove every placeholder PASS line from
   `tests/verify.sh` (F1) and replace it with a real grep-test per AUTHORING
   Rule 4. *Trace: cinematic-landing's verify.sh ships 8 real tests (T1–T8), no
   placeholder stubs; every acceptance claim has at least one test.*

7. **Run the gates.** `bash templates/<slug>/tests/verify.sh` (exits 0) and, for
   any memory write, `bash scripts/validate-memory.sh` (exits 0). Non-zero exit
   = not shipped; fix and re-run (R4 + R5). *Trace: cinematic-landing's
   verify.sh exits 0 with `OK: 8 / FAIL: 0`.*

8. **Write the audit log.** `share/notes/03_extracted_<task-id>.md` records every
   source read, every destination written, each pre-flight verdict, and the
   gate results (R8). This is the extraction's receipt. *Trace: analogous to how
   every coder chunk writes `share/notes/03_coder_summary_*.md`.*

9. **Hand back to master for promotion.** Extraction stops at a scaffold in
   `templates/<slug>/` (or draft under `share/templates/drafts/<slug>/`) plus
   the audit log. Master routes the scaffold through the `AUTHORING.md` "For
   authors" recipe (which finishes the template) and, for sub-ask A, opens a PR
   titled `templates(<slug>): v0.1.0 extracted cut`. *Trace: the
   cinematic-landing version path was 0.12.0 → 0.13.0 → v0.14.0; a freshly
   extracted template starts at 0.1.0 and climbs through the AUTHORING recipe.*

The first extracted scaffold is deliberately thin. Extraction fills what the
source **proves**; AUTHORING.md adds the rest only when a real consumer needs
it. Resist front-loading speculative memory files (AUTHORING "cut aggressively"
rule applies).

---

## Worked example

A full retroactive trace — reconstructing `templates/cinematic-landing/` from
its own git history to prove the recipe end-to-end — is **deferred to a v0.15.x
patch** (it is a multi-hour lift; see `share/notes/02_plan_phases_T-2026-07-04-009.md`
"Future work"). Until then, read `templates/cinematic-landing/` itself as the
worked example: it is the shape an extraction should converge on.

Read these files, in this order, to see what "done" looks like:

1. **`templates/cinematic-landing/INDEX.md`** — the consumer entry point step 3
   produces. Note the real trigger phrases (F7) under "How to discover this
   template", the 5 hard rules, and the 14-token table with one-source-of-truth
   cross-refs to `memory/05` + `memory/14`.
2. **`templates/cinematic-landing/00-readme-first.md`** — human orientation with
   only greppable claims. Note "What this template is NOT" — extraction should
   write the same honest boundary section.
3. **`templates/cinematic-landing/memory/07-reduced-motion.md`** (any one memory
   file) — the `# NN · <topic> — USE THIS WHEN: …` H1 that F3 + F4 check.
4. **`templates/cinematic-landing/tests/verify.sh`** — 8 real grep-tests, zero
   placeholder PASS lines (F1). This is the bar step 6 clears.

**Reading the exemplar as an extraction target:** if you had extracted
cinematic-landing rather than authored it, step 1 (pre-flight) would confirm the
skeleton has no `.env`/`sk-`/private-key hits (F6), the LICENSE is whitelisted
and attributed (F5), and the source project's WARN register had 0 OPEN entries
(F8). Steps 3–6 would produce exactly the INDEX, memory triggers, manifest, and
verify.sh you see today. Step 7 runs `bash templates/cinematic-landing/tests/verify.sh`
→ exit 0. That is the acceptance bar for any extraction.

**Sub-ask B worked shape:** a single durable insight — say "Lenis + GSAP must
share ONE ticker; a second `requestAnimationFrame` loop desyncs scroll" — becomes
one ≤20-line memory entry:

```markdown
---
scope: global
topic: single-ticker-scroll-engines
status: active
tech_stack: gsap, lenis, javascript
domain: landing-page, animation
created: 2026-07-04
last_verified: 2026-07-04
---

## TL;DR
Drive Lenis + GSAP ScrollTrigger from ONE rAF ticker; a second loop desyncs.

## Insight
Register `gsap.ticker.add((t) => lenis.raf(t * 1000))` and disable Lenis's own
rAF. Two independent loops produce visible scroll jitter under load.

## Source
templates/cinematic-landing/memory/01-builder-flow.md
```

Note the `tech_stack:` + `domain:` tags — that is what a future specialist
greps on read (per the soft-filter step in `agents_manager/memory/README.md`).

---

## What the agent can't decide

Extraction is LLM-assisted, which means the agent proposes and a human confirms
the calls that carry legal, brand, or judgment risk. These are **inherently
human** and must be surfaced, never silently defaulted:

- **LICENSE inheritance.** Whether the source's license permits redistribution
  as a template, and what attribution line to use, is a legal call. The agent
  presents the detected license + whitelist status; the user confirms. Refuse
  if unattributed (PF-1 / F5 / R3).
- **Trigger phrases on memory entries.** Which `tech_stack:` / `domain:` tags a
  durable insight carries — and whether it is `global` or `project` scope — is
  a judgment call the user owns (R6). The agent proposes tags from the source;
  the user confirms. `global/` is never auto-defaulted.
- **Brand generalization.** Deciding which parts of the source are
  brand-specific (must be genericized to fictitious placeholders) vs.
  reusable structure is a taste call. The agent flags candidate brand strings;
  the user confirms the generalization. Over-generalizing strips the template's
  usefulness; under-generalizing ships someone's real brand.
- **Fork vs. promote (Jaccard 0.4–0.6 band).** When a proposed template
  partially overlaps an existing one, whether to fork a new template or promote
  a memory file into the existing one is the user's call (PF-3 /
  `W-extract-overlap-with-existing`).
- **Accepting propagated WARNs.** If the source's WARN register has OPEN or
  DEFERRED entries, whether to accept propagating them into the template is a
  user decision, recorded in the audit log (PF-4 / F8 / R8).

When any of these is ambiguous, the agent's job is to **stop and ask**, not to
pick a plausible default. See `agents_manager/extract/rules.md` for the hard
refusals.

---

## Refusals and WARNs at a glance

Two failure severities. A **refusal** stops the run and returns to master; the
agent does not scaffold around it. A **WARN** proceeds only on recorded user
confirmation. This table is the operational summary of the pre-flight; the
authoritative gates are the `PF-*` sections above.

| Trigger | Severity | Rule / FAIL | Agent action |
|---------|----------|-------------|--------------|
| License unknown / off-whitelist / unattributed | REFUSE | R3 / F5 | Stop; LICENSE is a human call. |
| Secrets denylist hit (real) | REFUSE | R2 / F6 | Refuse the file; surface path + pattern. |
| Secrets hit is a confirmed false positive | WARN | R2 | `W-extract-secrets-near-miss`; user confirms; log it. |
| Jaccard overlap > 0.6 with existing template | REFUSE | PF-3 | Stop; recommend promote via CONTRIBUTING.md. |
| Jaccard overlap 0.4–0.6 | WARN | PF-3 | `W-extract-overlap-with-existing`; user "fork anyway". |
| Source WARN register has OPEN entries | REFUSE | R8 / F8 | Stop; user may explicitly accept propagation. |
| Source WARN register has DEFERRED entries | WARN | PF-4 | `W-extract-source-has-open-warn`; ask; they travel along. |
| Manifest line does not resolve | REFUSE | R4 / F2 | Fix the manifest or mark `(proposed)` + log. |
| `verify.sh` non-zero exit | REFUSE | R4 | Not shipped; fix and re-run or return BLOCKED. |
| `validate-memory.sh` non-zero exit | REFUSE | R5 | Not shipped; fix the frontmatter and re-run. |
| Target `templates/<slug>/` already exists | (not a refusal) | R7 | Suffix `-v2`; never overwrite. |
| Memory scope / tags unclear | (stop-and-ask) | R6 | Propose; user confirms; never default to `global/`. |
| 3+ consecutive skips for this project | WARN | — | `W-extract-skip-fatigue`; auto-disable prompt. |

The `W-extract-*` WARN categories are NOT on the auto-accept triageable list;
they surface to the user every time until a future patch adds them. The extract
skill does not decide their acceptance — master does, per the WARN register
protocol.

---

## For consumers of an extracted template

An extracted template is consumed exactly like an authored one — there is no
"extracted" flavor at consume time. Follow `templates/AUTHORING.md` "For
consumers":

1. Read `templates/<slug>/INDEX.md` end-to-end (the only file you must read
   whole).
2. Grep the `USE THIS WHEN:` trigger lines in `memory/` for the concern you are
   implementing; load only the matching file(s).
3. After implementing, run `bash templates/<slug>/tests/verify.sh` (exit 0).

The one thing to know about an extracted template: its `decisions/decision-log.md`
carries an "extracted from `<source>`" entry and, until the AUTHORING recipe is
complete, a list of `(unfilled — author to complete)` TODOs. Treat an
incompletely-finished extraction as a scaffold, not a contract.

## When extraction is research vs. authoring

Extraction is meta-circular: the guide is itself a research + authoring artifact.

- **Sub-ask B (memory) is closest to research.** "What is the most needed/common/
  core part of this project?" is a research question. The specialist reads the
  source the way `agents_manager/research/SKILL.md` reads a codebase — surfacing
  durable insights, not implementing. The output is knowledge, tagged for reuse.
- **Sub-ask A (template) is closest to authoring.** Once the pre-flight passes,
  the scaffold-and-fill work is the `templates/AUTHORING.md` recipe with a head
  start. The specialist is authoring a template from a known-good example rather
  than from a brief.

Master picks which specialist loads the extract skill based on the shape:
research-heavy (mostly sub-ask B) → am-research; authoring-heavy (mostly
sub-ask A) → am-coder. Either way, this rulebook is the ground truth.

---

## Companion files

- **`templates/CONTRIBUTING.md`** — the discoverable entry point. Read its
  "I want to extract a finished project into a template" section first; it
  routes here and to the skill.
- **`templates/AUTHORING.md`** — the sibling standard. Extraction produces a
  scaffold; AUTHORING.md's "For authors" 9-step recipe finishes it. The Rule 8
  acceptance checklist applies unchanged to extracted templates.
- **`agents_manager/memory/README.md`** — the canonical memory schema. Every
  sub-ask-B write satisfies it, plus the `tech_stack:` / `domain:` filter
  fields.
- **`agents_manager/extract/SKILL.md`** — the loadable procedure any specialist
  picks up to run an extraction. This rulebook is its ground truth.
- **`agents_manager/extract/rules.md`** — the 8 hard rules (R1–R8) the skill
  must obey. The pre-flight checklist above cites which rule enforces each FAIL
  condition.
- **`share/templates/drafts/<slug>/`** — the staging area for an extraction
  proposal before master promotes it to `templates/<slug>/`.

---

## Versioning

This file follows the same bump rules as `templates/AUTHORING.md`:

- **Patch (1.0.x):** typo fixes, pre-flight clarifications, new verify hints.
- **Minor (1.x):** new rules, new pre-flight gates, new companion files, the
  retroactive worked-example trace when it lands.
- **Major (x.0):** renamed rules, retired rules, schema changes to the
  extraction output shape.

Bump the `version:` in this file's frontmatter and add an entry to the repo's
`CHANGELOG.md` referencing the affected templates and the `agents_manager/extract/`
skill. `EXTRACTION.md` and `AUTHORING.md` version independently — a change here
does not force an AUTHORING.md bump.

Target for the initial cut: **v1.0.0** (this file).

---

## Audit-log format (Rule 8 / R8)

Every extraction run writes `share/notes/03_extracted_<task-id>.md`. It is the
receipt: the F8 evidence and the review's starting point. Use this template:

```markdown
# Extraction Audit — <task-id>

**Date:** YYYY-MM-DD HH:MM
**Source project:** <slug or path>
**Source task id:** <T-YYYY-MM-DD-NNN>
**Run by:** <specialist that loaded the extract skill>
**Sub-asks:** A (template) | B (memory) | both

## Pre-flight verdicts
| Gate | Check | Verdict | Evidence |
|------|-------|---------|----------|
| PF-1 | LICENSE scan + attribution (F5) | PASS/REFUSE | <license, whitelist status> |
| PF-2 | Secrets denylist (F6) | PASS/REFUSE | <files scanned, hits> |
| PF-3 | Jaccard overlap (dup guard) | PASS/WARN/REFUSE | <max score, which template> |
| PF-4 | Source WARN register (F8) | PASS/REFUSE | <OPEN count; user acceptance if any> |
| PF-5 | Manifest resolvability (F2) | PASS/REFUSE | <unresolved lines, if any> |
| PF-6 | Placeholder / trigger hygiene (F1,F3,F4,F7) | PASS/FAIL | <verify.sh result> |
| PF-7 | Memory schema (R5) | PASS/N/A | <validate-memory.sh result> |

## Sources read
- <path> — <what was taken from it>

## Destinations written
- <path> — <created | seeded | draft>

## Gate results
- `bash templates/<slug>/tests/verify.sh` — <exit code, OK/FAIL counts>
- `bash scripts/validate-memory.sh` — <exit code> (N/A if no memory write)

## Human decisions recorded
- LICENSE inheritance: <what the user confirmed>
- Memory scope + tags: <per-entry confirmations>
- Brand generalization / WARN propagation: <as applicable>

## Handoff
- Scaffold at: `templates/<slug>/` (or `share/templates/drafts/<slug>/`)
- Next step: master routes through `templates/AUTHORING.md` "For authors" recipe.
- Status: DONE | DONE_WITH_CONCERNS | BLOCKED
```

The audit log is append-only in spirit: a re-extraction of the same source
appends a new dated section rather than overwriting the prior receipt.

