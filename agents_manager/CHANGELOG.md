# Changelog

All notable changes to the `agents_manager` system. Newest on top.

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
