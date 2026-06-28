# Changelog

All notable changes to the `agents_manager` system. Newest on top.

## v0.4.0 — Agent permissions + Do/Don't boundaries (2026-06-28)

### Permissions model rewrite (`opencode.jsonc`)

All 5 agents now have **broader, more honest write permissions** so each agent can maintain its own persistent memory (notes/, resources/) and so cross-agent coordination has a clear, free-form zone.

**Key changes from v0.3.0:**

- **`share/` zone is now free-form for all agents.** Every agent can write anywhere under `share/**`. Convention (not enforcement) for naming: `share/messages/<from>-to-<to>-<task-id>-<topic>.md` for cross-agent notes (e.g. `research-to-planning-T-001-clarify.md`). Structured artifacts (`01_research_*.md`, `02_plan_*.md`, `03_coder_summary_*.md`, `04_review_*.md`, `99_progress_*.md`, `handoffs/`) retain their prefix conventions.
- **`agents_manager/<role>/**` is now writeable by each specialist** for that specialist only — `am-research` can edit `agents_manager/research/**`, etc. Each specialist can maintain its own `notes/`, `resources/`, `SKILL.md`, and `rules.md` without asking master.
- **Master can edit only `agents_manager/SKILL.md`** (its own orchestration doc) — it cannot edit other specialists' `SKILL.md` or `rules.md`. This enforces separation of concerns: the user (or a dedicated maintenance task) edits the controller.
- **`am-coder`'s allow rule is `agents_manager/coder/**`** — the coder can write to its own `notes/` and `resources/`. Last-match-wins on globs means the explicit allow comes *after* the broader `agents_manager/**` deny, so the coder still can't edit siblings.

### "When blocked" protocol (5 steps)

Every agent's inline prompt + SKILL.md now includes an explicit protocol for when the OpenCode permission layer rejects a write call:

1. **Do NOT retry** — the block is intentional.
2. **Do NOT work around it** — no filename tricks, no copying-and-renaming.
3. **Do NOT pretend it succeeded** — no claiming you wrote a file you didn't.
4. **CONTINUE** with what you CAN do.
5. **SURFACE** the block in your return line: `BLOCKED: tried to <X>, permission denied — route to master`.

This makes the permission layer's enforcement visible to the user and prevents agents from silently failing or, worse, bypassing the wall.

### Can/Can't + When-blocked sections in all 5 SKILL.md files

Every `SKILL.md` now has three new sections (consistent wording across all 5):

- **`## What you can do (your lane)`** — bulleted list of permitted actions with concrete examples.
- **`## What you cannot do (out of lane)`** — bulleted list of forbidden actions with what to do instead (route to master, dispatch a different agent, surface to user).
- **`## When the write tool is blocked`** — the 5-step protocol above.

The SKILL.md sections are read on agent startup, so they reinforce the inline prompt's Can/Can't list. Both layers must agree; if they ever drift, the inline prompt (which sets context first) wins.

### README updates

- Status banner updated to v0.4.0.
- New `## Permissions model` section in `README.md` with the full agent → permissions table.
- The five-agents table's Hard wall column updated to reflect the new walls (e.g. master can now edit its own SKILL.md; am-coder can now edit agents_manager/coder/**).

### `docs/INSTALL.md` updates

- New `## Folder conventions (added in v0.4.0)` section listing all standardized paths (`share/notes/01_*`, `02_*`, `03_*`, `04_*`, `99_*`, `share/messages/*`, `tasks/*`) so downstream users know where to find each artifact.

### CI

- The CI pipeline (7 jobs from v0.3.0) exercises the new permissions via `validate-frontmatter` (which reads each `SKILL.md` and confirms the new sections exist). No CI changes were needed for v0.4.0 — the validation already covers the additions.

**Net effect:** Each agent can now maintain its own persistent memory and coordinate via `share/messages/` without round-tripping through master. Permission walls are now visible (via the "when blocked" protocol) instead of silent. The controller (`agents_manager/SKILL.md` and others) is protected from accidental edits by any agent except the user (or a maintenance task).

## v0.3.0 — Examples directory + obra-sync maintenance (2026-06-28)

### Examples directory (3 worked examples)
- **`examples/node-markdown-linter/`** — full pipeline trace for "add a no-consecutive-h1 rule" task. Includes `original/` (starting state), `user-task.md`, full `share/` artifacts (00–04), `tasks/T-2026-06-28-001.md`, and `expected-output/` (rule + 5 new tests). This is the canonical demonstration of the agents-manager pipeline end-to-end.
- **`examples/python-csv-summarizer/`** — compact example for "add a `mean` aggregation alongside `sum` and `count`". Demonstrates the Python/pytest loop. Compact format (no full share/ trace).
- **`examples/docs-restructure/`** — pure-markdown example (no source code). Demonstrates Phases 1+2+4 without Phase 3 (no code to write). Useful for projects that are documentation-only.
- **`examples/README.md`** — index of all 3 examples with how-to-read and how-to-replay instructions.

### CI: new examples-consistency job
- **`.github/workflows/ci.yml`** now has 7 jobs. The new `examples-consistency` job verifies each of the 3 examples has the required structure (`README.md`, `user-task.md`, `expected-output/`) and that `examples/README.md` exists. Catches example drift as the controller evolves.

### obra/superpowers sync infrastructure
- **`.github/workflows/obra-sync-reminder.yml`** — quarterly cron (1st of Jan/Apr/Jul/Oct at 09:00 UTC) opens a GitHub issue titled "obra/superpowers sync — `<Month>` `<Year>`" with a 10-item checklist. Also manually triggerable via `workflow_dispatch`.
- **`docs/MAINTENANCE.md`** — full procedure for quarterly sync, release-cadence guidance (minor vs patch vs major bumps), pre-release checklist, and contingency procedures (when upstream skills are removed, when downstream projects need help).

**Net effect:** Three runnable examples demonstrate the pipeline for Node, Python, and docs-only projects. CI catches example drift. obra/superpowers updates are surfaced quarterly via an automated issue rather than relying on memory.

## v0.2.0 — Tier 3 skill integrations + CI pipeline (2026-06-28)

### Tier 3 skill integrations
- Installed `finishing-a-development-branch` (113.9K installs) via `npx skills add https://github.com/obra/superpowers --skill finishing-a-development-branch -g -y`.
- `agents_manager/SKILL.md` (master) now includes:
  - **New `## Brainstorming mode (opt-in, high-stakes only)`** — 6-step flow (read context → one question per message → 2-3 approaches → design sections → wait for go → hand off to am-planning). Hard gate: no implementation/plan until user approves. Pattern from `obra/superpowers:brainstorming`. Activation triggers: user says "design", "explore options", "should we", or task ambiguity is high.
  - **New `## Phase 5 (optional): branch close`** — 4-option menu (merge / PR / keep / discard) via `finishing-a-development-branch`. Opt-in via `Phase 5 enabled: true` flag in `tasks/<task-id>.md` row. Skipped if Phase 4 verdict = FAIL.
- `agents_manager/coder/rules.md` now includes:
  - **New `## 15. Plan-critical-start rule`** — before writing any code, re-read the assigned row in `tasks/<id>.md` AND the relevant phase section in `share/notes/02_plan_phases_<id>.md`. 4-item checklist (files / acceptance / test command / dependencies). Any "unclear" → return BLOCKED. Edge case: tiny fixes can skip. Connection to stop-at-blockers (## 13) is the pre-flight analog.

### CI pipeline (added under this release)
- **`.github/workflows/ci.yml`** — 6 jobs on push/PR: validate-config (opencode.jsonc parses), validate-frontmatter (all SKILL.md files), bash-lint (shellcheck on install.sh + check.sh), ps-lint (pwsh syntax check on install.ps1 + check.ps1), install-dryrun (install.sh against /tmp fixture), check-script (check.sh against self).
- **`scripts/validate-frontmatter.py`** — stdlib-only YAML frontmatter validator. Strict mode for OpenCode-discoverable skills (paths containing `/skills/`); lenient mode for internal files (description length only). Underscore names and dir-name mismatches in internal files are allowed; the same in `/skills/` files fail.
- **`.gitattributes`** — enforce LF for shell/yaml/json/md, CRLF for PowerShell.
- **`bin/check.ps1`** — fixed PowerShell variable expansion (`$Var:` → `${Var}:`). Both `bin/*.ps1` and `bin/*.sh` now pass syntax checks locally.
- **`README.md`** — added CI status badge near the top.

**Net effect:** v0.1.0 install is now CI-verifiable across platforms. v0.2.0 adds two new opt-in pipeline modes (brainstorming for high-stakes tasks; branch-close for projects driving to merge) and a hard pre-flight gate on the coder before implementation begins.

## Unreleased

### Migration — Agent-based orchestration (2026-06-28)

**What changed:**
- Created `opencode.jsonc` defining 5 OpenCode agents: `master`, `am-research`, `am-planning`, `am-coder`, `am-review`. Each has its own `permission` block that enforces hard walls at the OpenCode layer.
- Added `CLAUDE.md` at repo root for auto-routing.
- Updated `agents_manager/SKILL.md` master to invoke specialists via the `task` tool (separate agent, own context) instead of the `skill` tool (text loaded into master's context).
- Updated `agents_manager/README.md` to reflect the agent-based architecture.

**What stayed:**
- All sub-agent `SKILL.md` and `rules.md` files are unchanged. They are still read on agent startup as the canonical reference for each role's behavior, output templates, and standing rules.
- `share/` communication bus and `tasks/` tracker are unchanged.
- All programmatic gates, self-critique requirements, and `max_fix_loops = 3` are unchanged.

**New capabilities:**
- **Hard walls by architecture.** `am-research` literally cannot call Write. `am-review` cannot call Edit. Enforced by OpenCode's permission layer, not by prose promises.
- **Context isolation per role.** The research agent reads 200 files and returns a 400-word summary. The master never sees the 200 files. Each agent has its own context window.
- **Permission boundaries per file path.** Coder can edit source but is blocked from `agents_manager/**` (the controller). Master can write `share/handoffs/` and `tasks/` but is blocked from `share/notes/01_*`, `02_*`, `03_*`, and `share/reports/04_*` (specialists' files).

**Why:** The skill-based architecture had soft walls (prose in SKILL.md) and no context isolation. Agent-based orchestration gives hard walls (OpenCode permission layer) and a fresh context window per role. Same orchestration logic, mechanically enforced.

**Followup fixes (post-verification):**
- Moved `agents_manager/share/` and `agents_manager/tasks/` to project root (`share/`, `tasks/`). The design intent in the original docs used root-relative paths, and the JSON config uses root-relative globs. Moving the folders makes the design intent match the on-disk layout.
- Replaced remaining `skill(name="am-research")` reference at `agents_manager/SKILL.md` (parallel-research section) with `task(subagent_type="am-research", prompt=...)`.
- Renamed phase headers `(load `am-X`)` → `(spawn `am-X`)` in `agents_manager/SKILL.md` (PHASE 1–4).
- Added `git status` to `am-research`'s allowed bash commands.
- Added `ls`, `cat`, and `git status` to `am-review`'s allowed bash commands.
- Granted master `write` permission for `share/notes/99_decisions.md` (in addition to existing `edit`), so it can create the decisions log on first write.
- Updated folder-layout diagrams in `agents_manager/SKILL.md` and `agents_manager/README.md` to reflect the new bus location at project root.

**Tier 1 integration with obra/superpowers agent-workflow skills (2026-06-28):**
- Installed three skills via `npx skills add https://github.com/obra/superpowers --skill <name> -g -y`:
  - `dispatching-parallel-agents` (116.5K installs) — formalized the parallel-research decision criteria and prompt structure
  - `subagent-driven-development` (126.4K installs) — adopted the per-task dispatch contract (status signals, prompt structure) with explicit overrides for our design (pause-at-phase-2, per-phase review, no per-task model selection)
  - `verification-before-completion` (124.3K installs) — hardened review verdicts with the 5-step verification gate (identify / run / read / verify / state-with-evidence)
- Also references the already-installed `systematic-debugging` skill (4-phase debug protocol, 3-fix escalation) in `agents_manager/coder/rules.md`.
- `agents_manager/SKILL.md` (master) now includes:
  - Expanded `## Parallel research mode` with the 4 decision criteria and prompt-structure rules
  - New `## Subagent dispatch contract` — status signals, per-task dispatch pattern, and explicit overrides for `subagent-driven-development` recommendations that conflict with our supervised pipeline
  - New `## Progress ledger` — append-only `share/notes/99_progress_<task-id>.md` for compaction safety
- `agents_manager/coder/rules.md` now includes:
  - New `## 12. Debugging protocol` — references systematic-debugging, escalates after 3 failed fixes (aligns with master's `max_fix_loops=3`)
  - New `## 13. Stop-at-blockers rule` — specialists return BLOCKED rather than guess
- `agents_manager/review/rules.md` now includes:
  - New `## 13. Verification gate` — Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE; 5-step gate
  - New `## 14. Evidence requirements` — every per-task verdict must cite `path:line`, command + exit code, git diff SHA range
- `tasks/README.md` now includes `## Progress ledger` section with format, example, and recovery rule.

**Net effect:** Reviews become harder to fake (must cite git diff + run tests fresh); debugging follows a protocol instead of guessing; parallel research has explicit when-not-to-parallelize rules; compaction recovery has a deterministic entry point.

**Tier 2 integration with obra/superpowers + local `.agents/` folder (2026-06-28):**

Installed two additional skills via `npx skills add https://github.com/obra/superpowers --skill <name> -g -y`:
- `test-driven-development` (144.4K installs) — TDD cycle (RED → GREEN → REFACTOR) with heuristic for when to skip
- `requesting-code-review` (145.8K installs) — pre-review self-checklist + severity-classified handoff to reviewer

Tightened the already-installed `writing-plans` skill via:
- `agents_manager/planning/SKILL.md` — new `## No-placeholders rule` section banning vague `Done when` clauses, "implement later", and bite-sized task granularity

`agents_manager/SKILL.md` (master) now includes:
- New `## Multi-agent preflight` section — 5 questions to answer before dispatching any specialist (deliverable, why-needed, dependencies, tools, evidence closure). Pattern from `mavis-team`.
- New `## Deep reflection mode` section — 6 activation triggers (explicit / repeated-failure / drift / handoff / manual) + 5-block condensed reflection protocol. Pattern from `SELF_REFLECTIVE_PROMPT_IMPROVEMENT_AGENT.md`.

`agents_manager/coder/SKILL.md` now includes:
- New `## Review handoff` section — pre-review self-checklist, severity-classify findings yourself, brief the reviewer with the riskiest 3–5 spots.

`agents_manager/coder/rules.md` now includes:
- New `## 14. Test-driven development` — heuristic table for when TDD is required vs. optional (new functions, bug fixes, refactors: required; trivial edits: optional). Banned rationalizations listed.

`agents_manager/review/SKILL.md` now includes:
- New `## Severity rubric` — 4-level classification (CRITICAL / HIGH / MEDIUM / LOW) with action timelines and per-issue severity tag in the issue template. Pattern from `verification-validation-system-prompt.md`.

**Local `.agents/` folder integration:**
- Audited 24 files in `.agents/` (~700KB). Found 2 high-value orchestration docs (`mavis-team.md`, `verification-validation-system-prompt.md`) and 1 moderate-value (`SELF_REFLECTIVE_PROMPT_IMPROVEMENT_AGENT.md`).
- Moved `.agents/agent/mavis-team.md` → `.agents/skills/mavis-team/SKILL.md` for OpenCode skill discoverability. The `.agents/agent/` path was not in OpenCode's loader search paths; `.agents/skills/<name>/SKILL.md` is.
- `.agents/agent/skills_guide&roadmap.md` updated with Part 4 documenting our integration: Tier 1, Tier 2, Tier 3 skips, overrides, local files referenced, quick-decision table, maintenance checklist.

### Added — P0 + P1 enhancements

**P0 — Quality and safety foundations**

- Explicit `## Goal` and `## Backstory` sections in all 5 SKILL.md files (CrewAI role/goal/backstory pattern).
- `## Self-critique` block added to every sub-agent's output template; sub-agents critique their own work before returning (Reflexion pattern, Lilian Weng).
- `max_fix_loops = 3` per chunk enforced by master; exceeding it escalates to the user instead of looping.
- This `CHANGELOG.md`.
- `## Metrics` block in `tasks/<task-id>.md` template — per-phase timestamps, loop counts, files touched, costs.
- Reviewer is allowed — and required — to run the project's documented test/build commands when validating a coder chunk.
- Master now validates sub-agent output before advancing (file exists, required sections present).

**P1 — Operational depth**

- Programmatic gates in master: research must list ≥1 risk with severity; plan must include ≥1 acceptance criterion per phase; coder summary must cover every assigned task; review must give per-task verdict for every assigned task.
- `## Plan self-score` in planning output (testability / scope / dependencies / risks-covered, each 1–5).
- Sub-agent memory split: `notes/episodic/<task-id>.md` (per-task) + `notes/semantic/<topic>.md` (curated).
- `pause_and_ask` hook in master: mid-execution, master may pause and surface a clarifying question to the user.
- Optional parallel research mode: master may issue 2–3 research calls in parallel, scoped to distinct angles, then aggregate.

### Sources informing this revision
- Anthropic — *Building Effective Agents* (workflow patterns: orchestrator-workers, evaluator-optimizer, parallelization).
- Lilian Weng — *LLM Powered Autonomous Agents* (planning, Reflexion self-reflection, memory hierarchy).
- CrewAI — *Agents* documentation (role / goal / backstory, delegation, memory types, context-window handling).

### 2026-06-28 — System created
Initial 4-sub-agent pipeline (research → planning → coder → review) with shared bus and task tracker.
