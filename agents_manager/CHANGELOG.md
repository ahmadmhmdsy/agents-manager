# Changelog

All notable changes to the `agents_manager` system. Newest on top.

## v0.7.2 — Install guide + scripts polish (2026-06-29)

Documentation and installer polish. No controller changes. No CI changes (existing `install-dryrun` + `check-script` jobs already exercise the scripts).

### Files changed

- **NEW: `bin/README.md`** — in-folder docs for all 4 scripts (`install.sh`, `install.ps1`, `check.sh`, `check.ps1`). Covers arguments, exit codes, what scripts do NOT do, and shell coverage matrix.
- **`docs/INSTALL.md`** — comprehensive refresh:
  - Folder conventions updated to include v0.6.0 additions (`share/screenshots/`, `share/notes/02_secrets_*.md`, `04_warns_register_*.md`)
  - New "Recommended `.gitignore` additions" section
  - New "First task to try" recipe (smallest viable task to verify pipeline)
  - Expanded "Updating from a previous version" with CHANGELOG-first guidance + 3 update paths (subtree pull / ZIP / fresh install)
  - "What if the install doesn't work" — converted from flat list to decision tree
  - New "CI integration" section with GitHub Actions example
  - New "Shell coverage" matrix (bash 4+, PowerShell 5.1, PowerShell 7+)
- **`bin/install.sh`** — rewritten with:
  - Version stamp (`agents-manager installer v0.7.2`)
  - `--dry-run` flag (print changes without writing)
  - `--uninstall` flag (remove controller files, with confirmation)
  - `--yes` / `-y` flag (skip confirmation prompt)
  - `--help` / `-h` flag (usage info)
  - Auto-write starter `.gitignore` with `share/notes/02_secrets_*.md`, `share/screenshots/`, `share/notes/99_progress_*.md` entries (additive — never overwrites existing `.gitignore`)
  - Marker line `# agents-manager v0.7.2` prevents duplicate appends on re-run
- **`bin/install.ps1`** — PowerShell parity: same flags, same gitignore logic, version stamp.
- **`README.md`** — small pointer to `bin/README.md` for script documentation.

### Usage examples

```bash
# Default install (Unix)
bash bin/install.sh /path/to/project

# Preview changes without writing
bash bin/install.sh /path/to/project --dry-run

# Uninstall (with confirmation)
bash bin/install.sh /path/to/project --uninstall

# CI: verify install is intact
bash bin/check.sh .
```

```powershell
# PowerShell parity
.\bin\install.ps1 -Target C:\path\to\project
.\bin\install.ps1 -Target C:\path\to\project -DryRun
.\bin\install.ps1 -Target C:\path\to\project -Uninstall
```

### Why version stamp + flags

- **Version stamp** lets users see at a glance which `agents-manager` release they're installing. Critical for support / issue triage.
- **`--dry-run`** is the standard safety net for installers. Users running this in CI or in production directories need a way to see what would change.
- **`--uninstall`** is the missing opposite of install. Without it, users have to manually delete 6 paths.
- **Auto-`.gitignore`** solves a real footgun: `share/notes/02_secrets_*.md` contains API keys; without explicit gitignore, users commit secrets. The installer now creates the safe entries by default.

## v0.7.0 — Chunk-size protocol: per-phase complexity estimation + master re-ask (2026-06-29)

**Structural feature.** Catches "Phase 4 looks too big" at plan time, when it's actionable — not at review time, when it's discovered. Composes with v0.6.0's metrics (same `## Metrics` table) and the WARN register (same flag discipline).

### Why

The upstream user's Phase 4 was: 7 tasks, 23 files, ~1500 LOC, 3 novel abstractions (Monaco + iframe + sub-app), 6 issue-WARNs (vs 1-4 elsewhere). Plan agent self-rated Feasibility 4/5 with note "Phase 4 is the heaviest" — master downplayed it. The fix: planner estimates complexity per phase; master re-asks with concrete feedback; metrics surface anomalies at close.

### What changed (3 features)

#### C1 — Per-phase complexity estimation (planner)
- New rule #12 in `agents_manager/planning/rules.md`: schema for `### Complexity` block on every phase.
- New bullet in `agents_manager/planning/SKILL.md` "What you must produce" section.
- Fields: `novel_abstractions` (drawn from seed list), `LOC_estimate`, `files_estimate`, `review_difficulty` (low/medium/high), `split_recommended` (bool), `reason` (one sentence).
- **Trigger logic:** if `LOC > 1200` OR `files > 15` OR `length(novel_abstractions) ≥ 2` → must set `split_recommended: true` (can override with justification).

#### C2 — Master re-ask + dispatch-decision protocol
- New sub-section "Phase 3 dispatch — Complexity check + re-ask protocol (v0.7.0+)" in `agents_manager/SKILL.md` master.
- Master reads Complexity block at dispatch time; can re-ask planner ≤ 2× with concrete feedback; has final say.
- **Loop history template** — each dispatch decision logged to `tasks/<task-id>.md` `## Loop history` block (one line per dispatch with: Planner Complexity estimate, re-asks performed, decision, notes).
- **Hard dispatch gate** — no `### Complexity` block in plan → no am-coder dispatch. Master re-asks planner to add one.

#### C3 — Per-phase LOC + WARN metric extension
- `tasks/README.md` Phase timings table extended with `LOC written` + `WARNs` columns (same table as v0.6.0's H1 fix-loop counter).
- New `## Phase productivity` block in the Completion template — LOC/WARN ratio per phase.
- **Framing:** sanity check at task close, not a quality score. Cross-phase signal: any single phase tripping `(LOC/WARN > 2× project median) OR (LOC > 1200 AND WARNs > 4)` without a documented split decision → user should review whether the chunk-size protocol is working.

### Files touched (6 modified + 1 new)

- **NEW:** `agents_manager/planning/resources/novel-abstractions-seed-list.md` — 8 curated entries + "NOT" list (patterns that look novel but aren't) + how-to-extend guidance.
- `agents_manager/planning/rules.md` — appended Rule 12 (Complexity estimation).
- `agents_manager/planning/SKILL.md` — bullet in "What you must produce" (per-phase complexity block required).
- `agents_manager/SKILL.md` (master) — new sub-section "Phase 3 dispatch — Complexity check + re-ask protocol" + Loop history template.
- `tasks/README.md` — Phase timings table extended + Phase productivity block + Loop history hint + data-collection rule.
- `README.md` + `agents_manager/CHANGELOG.md` — v0.7.0 entry + "What's new" section.

### My modifications to the upstream patch

1. **Seed list as extendable examples** — the 8 curated entries are framed as "extendable examples" with explicit guidance on how to extend. The "NOT" list (Tailwind classes, React context, etc.) prevents the failure mode where planners dump garden-variety patterns to inflate `novel_abstractions`.
2. **Defer "consult am-review" brainstorm** — marked as optional/discouraged in the SKILL.md text. Adds overhead and token cost; the re-ask loop with the planner is the primary mechanism.
3. **C3 as sanity check, not a score** — explicit framing in the Phase productivity block + README. No leaderboard, no automated thresholds, no "quality score" UX.

### Composition with v0.6.0 (Patch-1)

| Patch-1 (v0.6.0) feature | Patch-2 (v0.7.0) interaction |
|---|---|
| H1 per-phase fix-loop counter (tasks/README.md `## Metrics`) | C3 extends the same table with LOC + WARNs columns |
| WARN register (C1) | C3's WARNs column pulls from the same register |
| Browser visual preflight (C2) | C2's re-ask protocol runs at the same Phase 3 → 4 handoff |
| Multi-agent preflight user-visible (G6) | C2's re-ask is a more specialized pre-dispatch version |

**No conflicts.** v0.7.0 is pure additions on top of v0.6.0.

### Hard trigger safety floor

LOC > 1200 OR files > 15 OR ≥2 novel abstractions → `split_recommended: true` mandatory.

### Re-ask limit

≤ 2× per phase. After 2 re-asks, master must accept the planner's recommendation OR override with own reasoning (documented in `## Loop history`).

### Source attribution

- **Generator:** MiniMax-M3 via opencode CLI on Windows pwsh 7+
- **Source project:** google_ai_studio_clone_1 (downstream consumer of `agents_manager v0.5.0`)
- **Source task:** T-2026-06-29-001 (Phase 4 oversized: 23 new files, ~1500 LOC, 3 novel abstractions, 6 issue-WARNs in one chunk)
- **Source date:** 2026-06-29
- **Patch text:** `agents_manager/upstream-contrib/PROPOSED_PATCH_v0.5.x_2026-06-29_part2_chunk-size.md`
- **License:** inherits the agents_manager license. Contribution, not obligation.

## v0.6.0 — Upstream-contribution patch: WARN register, preflights, non-git Phase 5 (2026-06-29)

**Feature release.** Six new features from a real-world end-to-end run by MiniMax-M3 (downstream consumer running google_ai_studio_clone_1). All opt-in by default. See [`docs/UPSTREAM-CONTRIB.md`](../../docs/UPSTREAM-CONTRIB.md) for the upstream attribution + patch source.

### What was applied (7 features)

#### C1 — WARN register protocol (CRITICAL)
- Master creates `share/notes/04_warns_register_<task-id>.md` at the **first** Phase 4 dispatch.
- Every review appends a `## Phase N — <date> — <verdict>` block listing issue-level WARNs.
- Coders check the register before re-flagging; reviewers append to it.
- User is asked once at task close, not once per phase. **Collapses 5 user questions → 1** on a typical 5-phase task.
- Files touched: `agents_manager/SKILL.md` (master), `agents_manager/coder/SKILL.md`, `agents_manager/coder/rules.md` (Rule 16), `agents_manager/review/rules.md` (Rule 15), `share/notes/README.md`.

#### C2 — Browser visual preflight (CRITICAL)
- New "Phase 3 → 4 handoff" section in master SKILL.md.
- Master takes screenshots before dispatching review for UI phases.
- Saves to `share/screenshots/<task-id>_<phase>_<route>.png`.
- Passes screenshot paths to the reviewer.
- Reviewer's Rule 15 now mandates visual verification when screenshots are provided.
- **Modification from patch:** added a third "skip when" clause — "no browser tool is available in this session" — so projects without `browsermcp_*` or `agent-browser` skip gracefully rather than dead-branch.

#### C3 — Git-status + API-key preflight at Phase 0 Ingest (CRITICAL)
- Three new bullets at PHASE 0 — Ingest.
- Git-status check: if "not a git repository", prompt user; default no auto-init.
- API-key preflight: ask during scope clarification; store in gitignored `share/notes/02_secrets_<task-id>.md` or route through project's documented proxy path.
- WARN-register preflight: note the canonical path for downstream agents.
- Files touched: `agents_manager/SKILL.md` (master).

#### H1 — Per-phase fix-loop counter (HIGH)
- `tasks/README.md` schema change: `Fix-loops by phase: {P1: 0, P2: 0, ...}` + `Fix-loops total: 0`.
- Lets master say "1 of 3 used on Phase 3 cosmetic, 0 elsewhere."

#### H2 — Real smoke test delegation (HIGH)
- Implemented via C3's API-key preflight. `run_smoke_at_close: bool` flag in task tracker header.
- When API key was provided in Phase 0 AND `run_smoke_at_close: true`, master runs `npm run smoke` in its own session at Phase 4 review time.

#### H3 — Phase 5 redefined for non-git projects (HIGH)
- Replaces git-only Phase 5 menu with auto-detect git vs non-git.
- Git menu: 4 options (merge / PR / keep / discard) — unchanged.
- **Non-git menu (new):** 4 options (run smoke / polish open WARNs / build follow-up / close out).
- The non-git menu is the common case for sandbox / exploration projects — confirmed by the upstream user's data.

#### H4 — WARN auto-accept (triageable list) (HIGH)
- New section in master SKILL.md with the default triageable list (font subset bloat, emoji vs SVG, lint warnings, npm audit dev-only, etc.).
- `auto_accept_warns: bool` flag in task tracker header — default `false` for safety.
- When `true`, matching WARNs auto-append to register with `[auto-accepted triageable]` tag — no user prompt.

### Gaps also picked up (2 easy ones from G1-G7)

#### G1 — `verification-before-completion` skill invoked at verdict time
- One bullet at start of PHASE 4 in master SKILL.md.
- Before reading the reviewer's report, apply the verification-before-completion skill to your reasoning.

#### G6 — Multi-agent preflight user-visible
- One line in CLAUDE.md "Key conventions".
- Users now see what to expect during the preflight (don't prompt in between).

### What was deferred (M1-M4)

- **M1** Versioned WARNs — each new phase re-triages the same concerns; C1b partial-fixes via "skip near-duplicate" rule. Full fix would require WARN-id assignment.
- **M2** Build-cache invalidation manual — `npm run smoke` as postbuild step is project-specific.
- **M3** Agent performance metrics — per-agent time + cost not tracked. Needs infrastructure.
- **M4** Skill auditing cadence — advanced skills (e.g., simplify-opencode) inaccessible for normal use. OpenCode platform issue.

### Documentation

- **`docs/UPSTREAM-CONTRIB.md`** (new) — attribution + decision log + link to the upstream patch file (`agents_manager/upstream-contrib/PROPOSED_PATCH_v0.5.x_2026-06-29.md`).
- **`README.md`** — "What's new in v0.6.0" section listing the 6 user-visible features.
- **`CLAUDE.md`** — G6 preflight-visibility note.
- **`agents_manager/CHANGELOG.md`** — this entry.

### Files touched (10)

| File | Edits |
|---|---|
| `agents_manager/SKILL.md` (master) | 4 sections (C2, C3, G1+C1a, H3+H4) |
| `agents_manager/coder/SKILL.md` | C1d bullet |
| `agents_manager/coder/rules.md` | C1b Rule 16 |
| `agents_manager/review/rules.md` | C1c Rule 15 |
| `share/notes/README.md` | C1e canonical file entry |
| `tasks/README.md` | H1 schema + H4 optional flags section |
| `CLAUDE.md` | G6 preflight note |
| `README.md` | Status banner + "What's new" section |
| `agents_manager/CHANGELOG.md` | v0.6.0 entry (this) |
| `docs/UPSTREAM-CONTRIB.md` | **NEW** |

**Net effect:** First end-to-end feedback loop with a real downstream consumer. Six new opt-in features address the user's quantitative findings: 5 separate WARN-acceptance questions collapsed to 1, git-status check enabled Phase 5's non-git menu (previously dead-branched), API-key preflight enables real smoke tests in master's own session.

**Source:** Patch generated by MiniMax-M3 via opencode CLI on Windows pwsh 7+ (2026-06-29). Full text: `agents_manager/upstream-contrib/PROPOSED_PATCH_v0.5.x_2026-06-29.md`. License: inherits the agents_manager license.

## v0.5.1 — Tool usage efficiency (2026-06-28)

Both rules reduce wall-clock time and improve context hygiene:

1. **Batch parallel edits** in a single message when independent. Only sequence when later edits depend on earlier (line shifts, shared context).
2. **Batch parallel reads** in a single message when you know what to read and the files fit in the context window. Discovery (grep/glob) goes in its own message, then reads in a follow-up batch.

**Combined pattern:** read once, edit many — two messages, not N.

### Coverage

- All 5 `agents_manager/<role>/SKILL.md` files get a new `## Tool usage efficiency (v0.5.1+)` section with the full text + caveats.
- All 5 inline prompts in `opencode.jsonc` get a 1-line reminder appended.
- `CLAUDE.md` (project root) gets the rules encoded — so future Claude Code / OpenCode sessions loading it apply them to this LLM, not just to the 5 agents.
- `README.md` gets a short note in a new "Operational characteristics" section. Status banner updated to v0.5.1. The "Why" section + agent table are updated to match the v0.5.0 soft-wall reality (the v0.4.0-era "hard permission walls" wording was outdated).

### Caveats documented in each agent's SKILL.md

- **oldString uniqueness within a batch** must be verified before issuing. Silent failure mode if collisions.
- **Read batching only helps when you already know what files you need.** Speculative batching of "files you might need" wastes context.
- **Context window is a hard limit.** Batching 50 files when the window holds 20 is worse than batching 10.

### Why v0.5.1 ships as a minor (not patch)

The new section is a substantive new capability, not a bugfix. Tagged `v0.5.1` to make it easy to bisect if a downstream project finds the rule changes behavior in unexpected ways.

## v0.5.0 — Soft-wall architecture (2026-06-28)

**Architectural change.** All 5 agents in `opencode.jsonc` now have `permission: "allow"`. OpenCode's permission layer is **not used** to enforce walls. Boundaries are now soft contracts — each agent's `SKILL.md` declares what it should/shouldn't do, and the LLM is expected to honor the contract.

### Why

The v0.4.0 → v0.4.1 era exposed three classes of OpenCode permission-layer edge cases (write/edit dual-allow requirement, bash exact-match, silent task cancellation). The v0.4.1 fixes added belt-and-suspenders patterns, but the config grew from ~30 lines to 88 lines and the work felt like patching the layer rather than using it.

This release trades mechanical enforcement for simpler config and LLM-disciplined boundaries. Hard walls are still possible (opt back in per agent, see `docs/PERMISSIONS.md`).

### What changed

- **`opencode.jsonc`**: every agent's permission block became `"permission": "allow"`. The 88-line config with detailed `permission: { edit, write, bash, task, read, grep, glob }` blocks is now ~30 lines (just the prompts). The agent table is trivially auditable.
- **Inline prompts (all 5)**: removed the "When the write tool is blocked" sections (no longer applicable). Added explicit "soft walls — enforced by you reading the boundaries, not by OpenCode" framing in each Boundaries section.
- **Master prompt**: removed the Phase 0 permission preflight (5 probe checks) and the task() retry protocol (3 retries with 5s backoff). If a `task()` dispatch fails now, OpenCode surfaces the error in the chat and master surfaces it to the user. No silent loops.
- **All 4 specialist prompts**: kept the "If tasks/<task-id>.md is missing" fallback but reframed its rationale from "permission might block" to "file might be missing for other reasons" (robustness, not permission).
- **`agents_manager/SKILL.md` (master)**: removed the Phase 0 preflight section + task() retry section + "When blocked — ESCALATE" section. Replaced with a single "When the write tool fails (v0.5.0+)" section that handles real I/O failures (not permission blocks). Added an anti-pattern bullet: "Treating the v0.5.0 soft walls as mechanical guarantees. They are prose contracts."
- **4 specialist SKILL.md files**: replaced "When the write tool is blocked" with "When a write fails (v0.5.0+)" sections. `am-review` SKILL.md adds a CRITICAL reminder: "do not fix source code even though you technically could now. The reviewer's job is to report, not to fix."
- **`docs/PERMISSIONS.md`**: rewritten. The v0.4.0–v0.4.1 era notes are preserved as historical context. New content: trade-off matrix, "what survives" / "what new agents should do" / "when to opt back into hard walls" / "debugging when something goes wrong."
- **`README.md`**: the "Permissions model" section now leads with "All 5 agents have `permission: "allow"`. OpenCode's permission layer is not used to enforce walls." The agent table shows "by convention" instead of specific allowed paths.
- **`CLAUDE.md`**: auto-routing note updated to mention the v0.5.0 architecture.

### What survives (unchanged)

- 5-agent pipeline (research → planning → coder → review) — separation of concerns
- File-based bus (`share/`, `tasks/`) — cross-agent coordination
- Phase gates (PHASE 0–4) — quality control
- "Brutally honest" review standard
- Can/Can't prose in each SKILL.md — now soft guidance instead of redundant with permission layer
- "If tasks/<id>.md is missing" specialist fallback — robustness, not permission

### What was retired

- Phase 0 preflight (5 probe checks)
- task() retry protocol (3 retries with backoff)
- "Both blocks" pattern (every writable path in edit + write)
- Bash prefix globs (both bare `cat` and `cat *`)
- "When the write tool is blocked — ESCALATE" 5-step protocol

These were all mechanical workarounds for the OpenCode permission layer's edge cases. With the layer not used, the workarounds aren't needed.

### Breaking change note

v0.5.0 is a minor version bump but a breaking change: downstream projects that relied on hard walls (e.g., a script that assumed `am-research` literally cannot write code) need to either trust the SKILL.md boundaries or opt back into hard walls per agent. See `docs/PERMISSIONS.md` for opt-in instructions.

**Net effect:** simpler config, easier debugging, less mechanical enforcement. The LLM is now the wall. If a real failure shows the soft walls are insufficient, the architecture supports partial roll-back per agent without a full revert.

## v0.4.1 — Critical permission fixes from real-world test (2026-06-28)

A downstream project tested v0.4.0 and the pipeline delivered **zero work product**. Master hit three classes of failure that the inline prompts and SKILL.md didn't anticipate. This release fixes all three.

### Root causes discovered

1. **OpenCode's `write` tool checks `edit` permissions for new files.** v0.4.0 listed `share/handoffs/**` and `share/messages/**` only in master's `write` block (not `edit`). New file creation was unreachable on those paths.
2. **Bash allow list is exact-match on the full command string.** `"cat": "allow"` matched only the bare `cat`. `cat README.md` was blocked. Same issue for `ls`, `rg`, `git status`, etc.
3. **`task()` cancellation is silent.** Master dispatched `am-research`; OpenCode returned "Task cancelled" with no error code, no reason, no retry guidance. Master had no way to distinguish "sub-agent failed" from "dispatch never started" from "permissions blocked the dispatch".

### Fixes

#### Belt-and-suspenders: every writable path in BOTH `edit` and `write`

Every agent's permission block now lists each writable path in both blocks. For master specifically, `agents_manager/SKILL.md` is now in both `edit` and `write` (was edit-only in v0.4.0).

#### Bash prefix globs (both bare and arg forms)

Master, `am-research`, and `am-review` bash blocks now list both forms of each allowed command:

```jsonc
"bash": {
  "*": "deny",
  "git status": "allow",  "git status *": "allow",
  "git log": "allow",     "git log *": "allow",
  "git diff": "allow",    "git diff *": "allow",
  ...
  "cat": "allow",         "cat *": "allow",
  "mkdir -p": "allow",    "mkdir -p *": "allow"
}
```

Master also gains `mkdir -p` for the preflight. `am-coder` keeps `bash: "allow"` (full trust).

#### Phase 0 permission preflight (master)

Master prompt now includes a **5-check preflight** that runs before any real dispatch:

1. `mkdir -p tasks share/notes` — ensure parent dirs
2. Write `tasks/.preflight` (probe)
3. Write `share/notes/.preflight` (probe)
4. `ls tasks share/notes` (bash probe)
5. Dispatch `am-research` with `prompt="echo READY"` (dispatch probe)

If any check fails, master surfaces `BLOCKED: ...` to the user and stops. After all 5 pass, master deletes the probe files and proceeds. Catches permissions/bash/dispatch failures BEFORE any work begins.

#### task() retry protocol (master)

If a real dispatch (post-preflight) returns "Task cancelled", master retries up to 3 times with 5-second backoff. If all 3 retries fail, master surfaces `BLOCKED: specialist <name> dispatch failed 3 times` to the user. No silent loops.

#### Specialist fallback for missing `tasks/<id>.md` (all 4 specialists)

If a specialist receives a dispatch and `tasks/<task-id>.md` doesn't exist (preflight missed something, or the file was deleted), each specialist now self-heals:

- **am-research**: derives scope from dispatch prompt, creates minimal task row (Phase 1, P1T1).
- **am-planning**: derives scope from research note + dispatch, creates minimal row, appends Phase 2+ rows per normal output.
- **am-coder**: derives scope from plan files + dispatch's assigned task ids, creates minimal row, proceeds with implementation.
- **am-review**: derives scope from coder summary, creates minimal row, proceeds with review.

Each surfaces `TASK-FILE-WAS-MISSING: created minimal task row from <source>` in the return line.

#### ESCALATE (not loop) on permission blocks (master)

Master's "When the write tool is blocked" section now reads **ESCALATE to the user** instead of "surface the block in your return line." The change: master surfaces the BLOCKED signal in the chat response itself, not just in file artifacts the user might not see. **"Task failed silently, see file X" is no longer acceptable.**

#### Do NOT self-edit your own SKILL.md during pipeline (master)

Master's permission still allows editing `agents_manager/SKILL.md` (per user override — we keep this so master CAN update its own orchestration doc via deliberate maintenance). But a new entry in `## Anti-patterns to refuse` warns against silent in-pipeline edits: "Editing `agents_manager/SKILL.md` even though your permission allows it. During an active pipeline, do not silently rewrite the protocol that defines the pipeline. If you find a real gap, surface it as a DEEP REFLECTION finding or call a maintenance phase."

### New documentation

- **`docs/PERMISSIONS.md`** — discovered OpenCode behavior (write/edit dual-allow, bash exact-match, silent task cancellation), the agents-manager workarounds, and a debug checklist for "permission denied" errors. Future debugging should start here.
- **`README.md`** — pointer to `docs/PERMISSIONS.md` from the Permissions model section.
- **`CLAUDE.md`** — note on the Phase 0 preflight (so OpenCode/Claude Code sessions loading CLAUDE.md see the preflight contract).

### Files changed

- `opencode.jsonc` — both-blocks pattern, bash prefix globs (3 agents), master prompt preflight + retry + ESCALATE, all 4 specialist prompts get fallback section
- `agents_manager/SKILL.md` (master) — new "Phase 0 — Permission preflight" section, new "task() retry protocol" section, "When the write tool is blocked" rewritten to ESCALATE, "Anti-patterns" gets self-edit warning
- `agents_manager/research/SKILL.md`, `planning/SKILL.md`, `coder/SKILL.md`, `review/SKILL.md` — each gets "If tasks/<task-id>.md is missing" section
- `README.md` — pointer to `docs/PERMISSIONS.md`
- `CLAUDE.md` — preflight note
- `docs/PERMISSIONS.md` — new file

**Net effect:** The real-world test would now succeed. Permissions, bash, and dispatch failures are caught upfront (preflight) or self-heal (specialist fallback). The BLOCKED signal reaches the user instead of getting lost in file artifacts. Discovered OpenCode behavior is documented for future debugging.

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
