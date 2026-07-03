# Changelog

All notable changes to the `agents_manager` system. Newest on top.

## v0.12.0 — cinematic-landing template + am-assets specialist (2026-07-03)

Additive feature. **No controller behavior changes**, **no existing-agent prompt changes**, no breaking changes to the v0.11.0 pipeline. Adds a vendor-neutral cinematic-landing task template under `templates/cinematic-landing/`, registers a new 6th specialist (`am-assets`) as the asset gatekeeper between Planning and Build, and updates the master orchestration doc + controller config to make templates discoverable.

### What's new

- **New specialist: `am-assets`** — asset gatekeeper. Sits between Phase 2 (Planning) and Phase 3 (Build). Runs the 4-branch runtime asset decision tree (Branch A: video pipeline frame-extraction → canvas scrub / Branch B: standalone video file → `<video>` ambient / Branch C: stills only → crossfade / Branch D: nothing yet → graceful fallback + concrete ask-list). Vendor-neutral by design — prompts work for Midjourney / DALL-E / Sora / Runway / Veo / Stable Diffusion XL / Replicate / Higgsfield / local models. Multi-LLM ready — the owner is not locked to Claude.
- **`templates/` convention introduced** — first shipped template is `cinematic-landing/`. Folder layout: `memory/` (9 files, the runtime playbook), `skeleton/` (HTML source-of-truth, cp'd from worked example), `prompts/` (3 files, copy-paste prompts for image/video/spec), `decisions/` (append-only log), `assets/` (MANIFEST.txt verify-list + manifest.schema.json JSON-Schema 2020-12).
- **17 files under `templates/cinematic-landing/`** — `00-readme-first.md` (template orientation), 9 `memory/*.md` (builder-flow, scroll-film-canvas, scroll-ticker, cinematic-hero, theming, asset-pipeline, reduced-motion, cta-frames, quality-bar), `skeleton/index.html` (841-line worked example, Branch C default — light gallery, scroll-driven cinematic hero, all 5 hard rules preserved), 3 `prompts/*.md` (image-gen, video-gen, asset-spec), `decisions/decision-log.md`, `assets/manifest.schema.json` (allOf conditional per branch), `assets/MANIFEST.txt` (17-file verify-list).
- **5 files under `agents_manager/assets/`** — `SKILL.md` (the am-assets role + boundaries + return shape), `rules.md` (7 standing rules including manifest-before-code + multi-LLM neutrality), `notes/branch-decisions.md` (append-only branch-decision log), `resources/landing-review-checklist.md` (am-review's P0 hard rules + verdict format), `README.md` (pipeline position diagram + first-task note).
- **Phase 3a (NEW)** — between Phase 2 (Planning) and Phase 3 (Build), master optionally dispatches am-assets to produce `assets/MANIFEST.json` per the template's JSON schema. Opt-in per template; not required for non-template tasks.

### Why

Before v0.12.0, asset-pipeline decisions for cinematic / scroll-driven landing pages were made ad-hoc — no contract for "video file vs frame sequence vs stills", no manifest schema, no concrete fallback when the user has no assets yet. Real-world landing pages need a reproducible 4-branch runtime decision tree so am-coder has a deterministic asset manifest to build against. v0.12.0:

1. Adds a dedicated specialist (`am-assets`) so am-planning + am-coder stay focused on planning + implementation.
2. Generalizes the asset pipeline into a 4-branch decision tree that works with any video-generation pipeline or still source.
3. Decouples the asset decision from the build step — am-assets runs at Phase 3a, before Phase 3 dispatch, and hands the manifest to am-coder.
4. Ships a worked example (`templates/cinematic-landing/skeleton/index.html`) so the template is shippable on day one and revisable later.

### Scope limits

- `am-assets` does NOT write source code. The manifest is the contract; reference implementations are `am-coder`'s job.
- The 4 branches cover the common cases (Higgsfield/Runway/Replicate/Sora/Veo frame extraction; standalone mp4/webm/mov; Pexels/Unsplash/Midjourney/DALL-E stills; nothing yet). Per-template branches (e.g. Lottie) deferred to per-template extensions.
- Multi-locale handling is documented for Arabic, Hebrew, Persian, Urdu, Latin, CJK. Other scripts (Tamil, Thai, Devanagari) are partially documented; full coverage in v3.
- The worked example (skeleton) is a Branch C default. Branch A and Branch B users swap the asset manifest only — the skeleton structure remains.
- `templates/` is a NEW convention. The existing 5 specialists work unchanged for non-template tasks.

### Hard rules (apply to every cinematic-landing build)

1. No `video.currentTime` write loops (use ScrollTrigger scrub or a `<video>` ambient, not `video.currentTime = scrollY / pageHeight * duration`).
2. No `<video>` element unless Branch B (or `<video>` is the ambient fallback layer).
3. No `mix-blend-mode` on transformed elements (causes repaint storms + jank).
4. `.fallback-host.is-missing` must be wired so Branch D (no assets) is always a valid rendered state.
5. `prefers-reduced-motion` honored at three layers (CSS media query + JS matchMedia + markup). Mid-session `change` listener required.

Verdict format: PASS / PASS-WITH-NOTES / FAIL. P0 violation = FAIL.

### Files touched

| File | Status |
|---|---|
| `opencode.jsonc` | **modified** — added `am-assets` block (2088 chars) with full inline prompt (role + boundaries + return shape + tool usage); updated header comment block: "5 specialists" → "6 specialists", "all 6 agents" → "all 7 agents", added v0.9.0+ ADDED am-assets comment |
| `agents_manager/SKILL.md` (master) | **modified** — appended `## Templates (v0.9.0+)` section after `## Shared communication bus` (anchor per proposal §3.3 fallback clause). Section explains `templates/` convention, first shipped template, how specialists discover templates via grep, and the am-assets mention. ~16 lines added. |
| `agents_manager/CHANGELOG.md` | **modified** — this entry |
| `templates/cinematic-landing/` | **NEW** (17 files: 1 readme + 9 memory + 1 skeleton + 3 prompts + 1 decisions + 2 assets) |
| `agents_manager/assets/` | **NEW** (5 files: SKILL.md + rules.md + README.md + notes/branch-decisions.md + resources/landing-review-checklist.md) |

### Tag / commit

**v0.12.0 — additive minor.** No breaking changes to the 5 existing specialists. Owners on v0.11.0 can apply this PR without rewriting anything else. Existing dispatches to master, am-research, am-planning, am-design, am-coder, am-review work unchanged. `am-assets` is opt-in per template — master spawns it only when (a) the task uses a template that declares am-assets in its frontmatter, AND (b) the asset manifest does not already exist at `templates/<template-name>/assets/MANIFEST.json`.

### Source attribution

- **Generator:** MiniMax-M3 via opencode CLI on Windows PowerShell 7+
- **Source date:** 2026-07-01
- **Source project:** `cinematic-landing-kit-demo` (worked example) + `cinematic-landing-kit` (original v1) at `E:\js_projects\3d_website\1_website_minimax_3`
- **Source task ids:** T-2026-07-01-001 (v2 adaptation, paused at user gate), T-2026-07-01-002 (demo SHIPPED, PASS), T-2026-07-01-003 (this proposal)
- **Source proposal:** `agents_manager/upstream-contrib/PROPOSED_PATCH_v0.5.x_2026-07-01_cinematic-landing-template.md`
- **Apply task id:** T-2026-07-03-001
- **Verification:** 17/17 files match `MANIFEST.txt` (empty diff); opencode.jsonc parses cleanly with 7 agents; all 9 `memory/*.md` start with `# `.

### Apply notes (for downstream consumers)

The proposal's `<apply-with-llm>` block is a literal 6-step procedure + Step 2.5 (cp skeleton). Owner (or any LLM agent) reads the proposal, copies `cinematic-landing-kit-demo/index.html` to `templates/cinematic-landing/skeleton/index.html`, materializes the 22 files from §3, applies the 2 controller edits, and runs the verification block. See the proposal for the full procedure + the `<review-with-llm>` 10-question second-opinion checklist.

### Review-driven fixes (2026-07-03)

Five LOW follow-ups from the am-review verdict (`share/reports/04_review_T-2026-07-03-001.md`) were fixed before commit:

- **W2 — em-dashes restored in `am-assets` prompt.** 4 ASCII hyphens in `opencode.jsonc`'s `am-assets.prompt` were replaced with U+2014 em-dashes (matching the proposal's prose-separator style). Verified: `opencode.jsonc` now contains 28 em-dashes (was 24).
- **W3 — `templates/cinematic-landing/memory/04-locale-handoff.md` created.** The file was referenced in 5 places (`00-readme-first.md`, `decisions/decision-log.md`, `memory/07-reduced-motion.md`, `memory/09-quality-bar.md`, `agents_manager/assets/resources/landing-review-checklist.md`) but missing from §3.1. Created with 26 lines covering default locale, RTL opt-in, RTL-specific guidance, and handoff protocol. References now resolve.
- **W4 — mid-session `prefers-reduced-motion` `change` listener added to skeleton.** Skeleton now matches `memory/07-reduced-motion.md` Layer 2 spec: `matchMedia(...).addEventListener("change", () => location.reload())` after the initial `reduce` check. On user toggle of system reduced-motion, page reloads to re-init Lenis/ScrollTrigger under the new preference.
- **W5 — skip-link added to skeleton.** Inserted as the first focusable element after `<body>`. Markup `<a class="skip-link" href="#main">Skip to content</a>` with offscreen-by-default CSS and visible-on-focus styling. Matches `memory/07-reduced-motion.md` Layer 3 markup spec.
- **W6 — accepted as proposal-text discrepancy (not fixable).** The proposal §3.1 claims 885 lines for the skeleton; the actual `cinematic-landing-kit-demo/index.html` is 841 lines (proposal-text only; the byte-for-byte source remains canonical). After W4+W5, the skeleton is 896 lines. This is a cosmetic deviation in the proposal text, not a patch issue.

Net result: 23 new files (was 22 — added `04-locale-handoff.md`) + 1 modified skeleton (was byte-identical; now +9 lines for accessibility + reduced-motion) + 2 controller edits.

## v0.13.0 — Three-scope memory system for agents_manager (2026-07-03)

Additive feature. **No controller behavior changes for non-substantive tasks**, **no existing specialist prompt rewrites**, no breaking changes to the v0.12.0 pipeline. Adds a three-scope memory tree (global + project + role) for specialist long-term memory, a single canonical schema source-of-truth, a write-on-exit dispatch contract, and a shipped frontmatter validator. Operators and per-task work fill the memory; the scaffold itself ships empty.

### What's new

- **Three-scope memory tree at `agents_manager/memory/`** — `global/` (cross-project facts, master-written), `projects/<slug>/` (per-project knowledge, master-written, default slug = `basename $PWD`, override via `agents_manager/.active-project`), and per-role `notes/{semantic,episodic}/` (specialist-written, owned by each specialist). Read order on re-entry: global → project → role, ≤200 lines per scope.
- **Single canonical schema source-of-truth at `agents_manager/memory/README.md`** — defines the frontmatter keys (`scope`, `topic`, `status`, `superseded_by`, `created`, `last_verified`), the lifecycle (append-only; supersession via `status: superseded` + `superseded_by:` link), the read/write protocol, the durable-insight criteria, the secrets-free rule, and the no-write-to-templates rule. Each per-role `notes/README.md` is a 2-line pointer (no duplication; prevents schema drift across 7 specialists).
- **Master's re-entry reads from 3 sources** — (a) `agents_manager/memory/global/`, (b) `agents_manager/memory/projects/<slug>/`, (c) `share/notes/99_progress_<task-id>.md`. Same 200-line cap per source. Master's own "role-scope" memory collapses into `memory/global/` (master IS the orchestrator; its accumulated lessons are inherently cross-project).
- **Dispatch contract line** — every specialist return summary gains a `Memory written: <path>` (or `No memory write: <reason>`) line. Master only gates on this for **substantive** dispatches (those that hit `tasks/<id>.md` rows); trivial status checks may use `No memory write: trivial`. Durability guardrail: write only if (a) a different agent in 3 months benefits AND (b) NOT derivable from coder summary / source AND (c) you spent >30s or it contradicted prior expectation. Per-entry size cap: ≤20 lines.
- **`scripts/validate-memory.sh` SHIPS in v0.13.0 (REQUIRED)** — ~50 LOC bash, executable, stdlib-only. Walks `agents_manager/memory/{global,projects}/` and `agents_manager/<role>/notes/{semantic,episodic}/`. Checks: frontmatter `--- ... ---` block closes; required keys present (`scope`, `topic`, `status`, `created`, `last_verified`); `scope ∈ {global, project, role}`; `status ∈ {active, superseded}`; `created` and `last_verified` parse as YYYY-MM-DD; when `status: superseded`, `superseded_by:` is present and resolves to a file that exists. Exit codes: 0 = no issues; 1 = at least one issue.
- **90-day sweep at Phase 5 close** — master sweeps memory entries with `last_verified` older than 90 days; flags them in `share/notes/04_warns_register_<task-id>.md` (WARN register); does NOT auto-delete. The sweep runs at master's Phase 5 (next-steps, opt-in via `phase_5_enabled`) when enabled; otherwise at Phase 4 close as part of `## Completion`.
- **20 files touched total** — 17 new + 9 modified (counted via the canonical delivery table below).

### Why

Before v0.13.0, every agent started each task with empty context: no cross-session memory, no project-state retention, no per-role expertise accumulation. Specialists had to rediscover repo conventions, retry already-known gotchas, and re-litigate decisions settled in prior tasks. The existing `notes/{episodic,semantic}/` shape was *declared* in every specialist SKILL.md (e.g., `agents_manager/research/SKILL.md:22-31`) but most folders were physically empty — there was no protocol for reading or writing them, and no validator to enforce schema. v0.13.0:

1. Materializes the existing-but-empty per-role scaffold under a single canonical schema (no new conventions invented — the shape was already declared).
2. Adds two master-managed scopes (`global/` + `projects/<slug>/`) so cross-task and per-project knowledge has a structural home without polluting per-role expertise.
3. Decouples the read protocol (read-on-entry, ≤200 lines/scope) from the write protocol (write-on-exit, 3-question "durable insight" test, ≤20 lines/entry) so trivial status-check dispatches don't pollute memory.
4. Ships a validator as a release blocker for v0.13.0 (not optional) so broken `superseded_by` links get caught mechanically rather than misleading readers.
5. Documents the protocol in 7 SKILL.md updates — 6 specialists + master — so every agent reads the same contract.

### Scope limits

- **No content backfill.** The scaffold ships empty; operators and the first task on each clone write memory as it earns its keep. Worked examples live in fenced code blocks in the canonical README; no `.md` files in `global/` or `projects/` ship with v0.13.0.
- **Co-exist migration stance.** Scaffold is purely additive — it does not move, rename, or delete any existing file. Power users with existing content in `agents_manager/<role>/notes/` are unaffected; their files stay put. The per-role READMEs are **replaced** (research/planning/coder/review) from a verbose 30-line schema-duplicate to a 2-line canonical pointer, enforcing the "no duplication" discipline on day one. The assets specialist's `agents_manager/assets/notes/README.md` is a NEW file documenting BOTH the new tree and the existing `branch-decisions.md` (which has a different append-only-by-task lifecycle and is preserved unchanged).
- **Master's SKILL.md edit goes through am-coder dispatch.** Per `agents_manager/SKILL.md:496` ("Editing `agents_manager/SKILL.md` during pipeline execution ... do not silently rewrite the protocol that defines the pipeline"). Master does not self-edit. This was surfaced at Phase 2 confirmation for explicit user OK before Phase 5 dispatch (T-2026-07-03-001 precedent).
- **No `opencode.jsonc` changes.** The locked design enforces the memory protocol via SKILL.md + dispatch contract, not via a new agent. One fewer wall conflict; matches v0.12.0's surgical-edit ethos.
- **No changes to the controller fence zone.** The 11 files modified + 19 untracked by v0.12.x follow-ups (`git status --short` at task start) are NOT touched by any v0.13.0 phase. A new `agents_manager/.gitignore` (1 line: `.active-project`) is created to scope the project-slug override file locally; the root `.gitignore` is in the fence zone and is NOT modified.
- **No auto-summarization, no auto-pruning.** Deferred to v0.14.x. The 90-day sweep is a manual flag-and-review mechanic, not an automated deletion.
- **No memory search/indexing.** File-based grep is the v1 search; the canonical README documents the keyword hints.
- **All 7 agents share the same 200-lines-per-scope budget** for v0.13.0. Per-agent context tuning requires per-agent model selection, which OpenCode does not currently support (deferred).
- **Token cost on re-entry** is bounded: empty scaffold = 0 cost; 90-day sweep keeps the budget bounded as content grows. v0.13.0 accepts ~2k tokens per dispatch on memory alone as the cost of the value delivered. Revisit at v0.15.x if metrics show re-entry memory growing >5% of total context.

### Read protocol (specialist, on re-entry)

1. `agents_manager/memory/global/*.md` — ≤200 lines; read in date order (newest first).
2. `agents_manager/memory/projects/<active-slug>/*.md` — ≤200 lines; same order.
3. `agents_manager/<this-role>/notes/semantic/*.md` — curated insights, ≤200 lines; read every file or skim the table of contents.
4. `agents_manager/<this-role>/notes/episodic/<task-id>.md` — past notes on the same task id; skim for continuity.

If a scope exceeds 200 lines, grep by `topic:` keyword first, then read up to 200 lines of matches.

### Write protocol (specialist, on exit)

Append to one of:
- `agents_manager/memory/global/<topic>.md` — for cross-project facts only (create new file; entry ≤20 lines).
- `agents_manager/memory/projects/<active-slug>/<topic>.md` — for per-project knowledge (create new file; entry ≤20 lines).
- `agents_manager/<this-role>/notes/{semantic,episodic}/<topic>.md` — for role-specific expertise.

Mandatory filter (skip if ANY criterion fails):
- (a) Would a different agent (or me, in 3 months) benefit from knowing this on re-entry? (Yes → write.)
- (b) Is it derivable from `share/notes/03_coder_summary_*.md` or the source code? (Yes → don't write; cite the source instead.)
- (c) Did you spend >30 seconds figuring it out, or did it contradict your prior expectation? (Yes → write.)

Hard rules:
- ≤20 lines per entry.
- Must NEVER reference `share/notes/02_secrets_*` paths/values. Reference the task id instead.
- Must NOT write into `templates/<name>/memory/` — that's the template author's lane.
- When superseding an old entry, set `status: superseded` + `superseded_by: <new-entry-path>` on the OLD file; do not delete it.

### Files touched

| File | Status |
|---|---|
| `agents_manager/memory/README.md` | **NEW** — canonical schema source-of-truth (~180 lines) |
| `agents_manager/memory/.gitignore` | **NEW** — nested scope `**/*.md` + `!**/.gitkeep` |
| `agents_manager/memory/global/.gitkeep` | **NEW** — empty-scope placeholder |
| `agents_manager/memory/projects/.gitkeep` | **NEW** — empty-scope placeholder |
| `agents_manager/.gitignore` | **NEW** — 1 line: `.active-project` |
| `agents_manager/research/notes/{semantic,episodic}/.gitkeep` | **NEW** ×2 |
| `agents_manager/planning/notes/{semantic,episodic}/.gitkeep` | **NEW** ×2 |
| `agents_manager/coder/notes/{semantic,episodic}/.gitkeep` | **NEW** ×2 |
| `agents_manager/review/notes/{semantic,episodic}/.gitkeep` | **NEW** ×2 |
| `agents_manager/assets/notes/{semantic,episodic}/.gitkeep` | **NEW** ×2 |
| `agents_manager/research/notes/README.md` | **modified** — replaced verbose 30 lines with 2-line canonical pointer |
| `agents_manager/planning/notes/README.md` | **modified** — same |
| `agents_manager/coder/notes/README.md` | **modified** — same |
| `agents_manager/review/notes/README.md` | **modified** — same |
| `agents_manager/assets/notes/README.md` | **NEW** — documents both the new tree and the existing `branch-decisions.md` |
| `scripts/validate-memory.sh` | **NEW** — ~50 LOC bash, executable, stdlib-only |
| `agents_manager/SKILL.md` (master) | **modified** — appended `## Memory protocol (v0.13.0+)` section after `## Templates (v0.9.0+)`. Subsections: project-slug detection; 3-source master's re-entry; dispatch contract line; 90-day sweep hook. ~60 lines added. Edited via am-coder dispatch (deliberate maintenance task — T-2026-07-03-001 precedent). |
| `agents_manager/research/SKILL.md` | **modified** — appended `## On re-entry` + `## On exit` sections. ~25 lines added. (Same applies to all 5 specialists below.) |
| `agents_manager/planning/SKILL.md` | **modified** — same |
| `agents_manager/design/SKILL.md` | **modified** — same (design's `notes/{semantic,episodic}/` folders already existed; only the protocol is new) |
| `agents_manager/coder/SKILL.md` | **modified** — same |
| `agents_manager/review/SKILL.md` | **modified** — same |
| `agents_manager/assets/SKILL.md` | **modified** — same protocol injection + 1 paragraph noting `branch-decisions.md`'s distinct lifecycle is preserved |
| `CLAUDE.md` | **modified** — added Memory row to project structure; new `## Memory` section with 3-scope summary + canonical pointer |
| `agents_manager/CHANGELOG.md` | **modified** — this entry |

### Tag / commit

**v0.13.0 — additive minor.** No breaking changes to existing 7 specialists. Owners on v0.12.0 can apply this PR without rewriting anything else. Existing dispatches to master, am-research, am-planning, am-design, am-coder, am-review, am-assets work unchanged for non-substantive tasks (the dispatch contract is additive; `No memory write: trivial` is the default for status checks). Substantive dispatches gain a single `Memory written:` return line; this is a contract addition, not a behavior change.

### Source attribution

- **Generator:** MiniMax-M3 via opencode CLI on Windows PowerShell 7+
- **Source date:** 2026-07-03
- **Source task id:** T-2026-07-03-002
- **Source project:** `agents-manager` (carry-over from v0.12.0)
- **Source discussion ids (master brainstorming session):** m0002–m0007 (analysis + 3-question design round)
- **Source research note:** `share/notes/01_research_T-2026-07-03-002.md` (16 risks classified, 6 clarifying questions answered)
- **Source plan files:** `share/notes/02_plan_high_T-2026-07-03-002.md`, `share/notes/02_plan_phases_T-2026-07-03-002.md`
- **Source CHANGELOG draft:** `share/notes/02_changelog_draft_T-2026-07-03-002.md` (this file)
- **Precedent:** `research_doc/README.md` (tier-1/2/3 + decisions/ + overrides/ + Status lifecycle) — the existing project's working memory scheme. `agents_manager/design/notes/{semantic,episodic}/.gitkeep` (the only specialist with actual folders before v0.13.0). T-2026-07-03-001 (cinematic-landing template + am-assets) for the soft-wall wall-crossing pattern.
- **Apply notes:** All 30 file ops are purely additive or mechanical text replacement; no schema/codepath behavioral change for non-memory dispatch paths. Migration is co-exist (no rename, no relocate). 90-day sweep begins at the first master's Phase 4 close after this lands, not retroactively.

### Review-driven fixes

_None yet — pending am-review verdict on Phase 5 chunk._

---

## v0.11.0 — Python UX + standalone installer + skills scope override (2026-07-01)

### Review-driven fixes (2026-07-03)

- **Dispatcher `install` accepts `--skills`/`--scope`** — bash `cmd_install` (`bin/agents-manager`) and PowerShell `Parse-InstallFlags` (`bin/agents-manager.ps1`) now accept `--skills {both,global,local,skip}` (and `--scope` alias; PowerShell: `-Skills`/`-Scope` PascalCase) on the `install` subcommand. After the controller files copy, install chains into `cmd_skills add --all --$SKILL_SCOPE` unless `--skills skip` is passed. Resolves the T2 ⟷ T1 integration gap from `share/reports/04_review_T-2026-07-01-001.md`.
- **PowerShell `Parse-InstallFlags` PascalCase parity** — `-Yes`, `-DryRun`, `-Git M`, `-Skills S` now accepted on `install` (previously rejected with `unknown flag` despite help text advertising them). Closes the v0.10.0-era docs/behavior drift.
- **`__pycache__/` gitignored** — added `__pycache__/` and `*.pyc` entries to `.gitignore`. Cleans up the untracked `.pyc` files from `bin/` and `bin/standalone-installer/`.
- **PSScriptAnalyzer +10 acknowledged** — wizard scope-prompt block at `bin/agents-manager.ps1:647-652` adds 6 `PSAvoidUsingWriteHost` warnings, and the new `Skills:` block in `Install-Cmd` adds 4 more (total 151 vs 141 baseline). All consistent with the file's house style (`Write-Host` is used in every other `Install-Cmd` section); accepted.
- **Python floor aligned to 3.7+** — `bin/agents-manager.py` now requires Python 3.7+, matching `bin/standalone-installer/install.py`. Cosmetic em-dash replaced with ASCII `--` to avoid cp1252 console crash.

Additive feature. Controller, agent code, `opencode.jsonc`, and the master orchestrator are unchanged. v0.11.0 layers a cross-platform Python UX on top of the existing bash + PowerShell dispatchers, ships a zero-dependency standalone bootstrap, and lets users choose where skills install.

### What's new

- **Python UX layer** — `bin/agents-manager.py` (full dispatcher, ~380 LOC, stdlib only) + `bin/install.py` (wizard launcher) + four shims: `bin/agents-manager.{sh,cmd}` and `bin/install.{sh,cmd}`. The Python wrapper parses args, prompts for menu choices, then dispatches to the bash or PowerShell dispatcher. The existing dispatcher logic is unchanged.
- **Standalone installer** — `bin/standalone-installer/install.{py,sh,cmd}` + `README.md`. A self-contained bootstrapper that downloads the latest release ZIP, extracts it, runs the bundled installer against the target, and cleans up. One Python file (~250 LOC) plus three 3-line shims covers every OS. No native binaries, no `pip install`.
- **Skills installation scope** — `bin/agents-manager` and `bin/agents-manager.ps1` now accept `--global/--local/--both/--skip` (PowerShell: `-Global/-Local/-Both/-Skip`) on `skills add`. Default remains `both` (matches v0.10.0 implicit behavior — no breaking change for existing users).
- **Wizard prompts for scope** — when the user picks option 4 ("Install all required skills") in the interactive wizard, a 4-option scope prompt appears before dispatching `cmd_skills add --all`.
- **Windows cmd / batch EOL normalization** — `.gitattributes` adds `*.cmd text eol=crlf` and `*.bat text eol=crlf` so the new shims ship with consistent line endings across platforms.
- **Release ZIP validation extended** — `.github/workflows/release.yml` and `bin/release-zip.ps1` now verify the ZIP contains all four new scripts (`bin/agents-manager.py`, `bin/install.py`, `bin/standalone-installer/install.py`, `bin/standalone-installer/install.cmd`) in addition to the existing `bin/install.sh` + `bin/install.ps1` checks.

### One-liner remote install (new in v0.11.0)

| OS | One-liner |
|---|---|
| Windows (PowerShell) | `iwr -useb https://raw.githubusercontent.com/ahmadmhmdsy/agents-manager/main/bin/standalone-installer/install.cmd -OutFile install.cmd; .\install.cmd` |
| Windows (cmd, double-click) | Save <https://raw.githubusercontent.com/ahmadmhmdsy/agents-manager/main/bin/standalone-installer/install.cmd> then double-click |
| macOS / Linux | `curl -fsSL https://raw.githubusercontent.com/ahmadmhmdsy/agents-manager/main/bin/standalone-installer/install.sh \| bash` |

### Skills scope flag

| Flag | Meaning |
|---|---|
| `--skills global` (default for global-source skills) | install via `npx` to `~/.agents/skills/<name>/` (user-level) |
| `--skills local` (default for local-source skills) | install to `<target>/.agents/skills/<name>/` (project-local) |
| `--skills both` (default when no flag) | honor per-skill source — global-source skills go to `~/.agents/`, local-source skills go to `<target>/.agents/` |
| `--skills skip` | skip skills entirely — controller install only |

### Backward compat

- All v0.10.0 invocations still work via the existing dispatcher + shim layer.
- Default scope is `both`, matching v0.10.0's implicit behavior. No user-visible change for existing workflows.
- The Python UX is opt-in — existing bash / PowerShell users don't need to touch it.
- The standalone installer is opt-in — existing git-subtree / ZIP / manual install paths are unchanged.

### Scope limits

- The Python UX dispatches to the bash / PowerShell dispatcher (no logic duplication). It's a UX wrapper, not a parallel implementation.
- `bin/standalone-installer/install.cmd` is a 3-line shim that invokes `python install.py %*`. Requires `python` (or `py`) on PATH — same as every other Python wrapper.
- The standalone installer requires network access to download the release ZIP. Air-gapped users should still use the release-ZIP download path (Option B in `docs/INSTALL.md`).

### Files touched

| File | Status |
|---|---|
| `bin/agents-manager.py` | **NEW** — Python UX dispatcher (~380 LOC, stdlib only) |
| `bin/install.py` | **NEW** — wizard launcher |
| `bin/agents-manager.sh`, `bin/agents-manager.cmd` | **NEW** — shims to `agents-manager.py` |
| `bin/install.sh`, `bin/install.cmd` | **NEW** — shims to `install.py` (replace v0.10.0 dispatcher-invoking versions) |
| `bin/standalone-installer/install.py` | **NEW** — standalone bootstrapper |
| `bin/standalone-installer/install.sh`, `bin/standalone-installer/install.cmd` | **NEW** — shims to standalone `install.py` |
| `bin/standalone-installer/README.md` | **NEW** — usage + OS matrix |
| `bin/agents-manager` | **modified** — `VERSION` bumped to `v0.11.0`; `--global/--local/--both/--skip` accepted on `skills add`; wizard prompts for scope |
| `bin/agents-manager.ps1` | **modified** — `$ScriptVersion` bumped to `v0.11.0`; PowerShell `-Global/-Local/-Both/-Skip` parameter on `skills add`; wizard prompts for scope |
| `.gitattributes` | **modified** — `*.cmd text eol=crlf` + `*.bat text eol=crlf` added |
| `.github/workflows/release.yml` | **modified** — ZIP validation extended with 4 new `grep -q` checks |
| `bin/release-zip.ps1` | **modified** — same 4 validation checks mirrored in PowerShell |
| `README.md` | **modified** — "Quick install" section + Quick-start pointer to `bin\install.cmd` / `bin/install.sh` |
| `bin/README.md` | **modified** — "Python UX (v0.11.0+)" section; dispatcher flag table includes `--skills`; standalone installer pointer |
| `docs/INSTALL.md` | **modified** — new "Option D — Use the standalone installer" (top option); "Skill installation scope (v0.11.0+)" subsection; shell coverage table extended |
| `agents_manager/CHANGELOG.md` | **modified** — this entry |

**v0.11.0 — additive minor.** Safe for all v0.10.0 users. No controller changes, no `opencode.jsonc` changes, no agent behavior changes. Default skills scope `both` matches prior implicit behavior.

## v0.10.0 — Unified CLI: `agents-manager` dispatcher (2026-06-30)

**Additive feature.** Controller, agent code, `opencode.jsonc`, and the master orchestrator are unchanged. v0.10.0 introduces a unified CLI that wraps the existing installers + skill management behind a single dispatcher.

### What's new

- **`bin/agents-manager`** — new bash dispatcher (~500 lines, single file). Subcommands: `install`, `update`, `check`, `doctor`, `uninstall`, `skills {list|add|remove|which|update}`, `release`, `lint`, `version`, `help`. With no args, launches an interactive wizard (7 options). Pass `--yes`/`-y` to skip prompts. Pass `--no-color` to disable ANSI colors.

- **`bin/agents-manager.ps1`** — PowerShell mirror (param-based, `ConvertFrom-Json` for the manifest). Same subcommands; PascalCase flags (`-Git auto`, `-Yes`, `-DryRun`, `-Fix`, `-All`).

- **`bin/skills-manifest.json`** — new declarative file listing all required skills (10 entries: 1 controller-local `mavis-team` + 9 obra/superpowers). Each entry has `id`, `required`, `level` (local|global), `source`, `description`, `install_cmd`, `update_cmd`. The dispatcher reads this manifest at runtime, so adding a new required skill is a 1-line JSON change (no code change needed).

- **`bin/install.sh` / `bin/install.ps1` / `bin/check.sh` / `bin/check.ps1` / `bin/update.sh` / `bin/update.ps1`** — converted to **3-line shims** that `exec` (bash) or `&` invoke (PowerShell) the dispatcher. All v0.9.x invocations still work unchanged.

- **`bin/README.md`** — top section documents the unified `agents-manager` entry point; legacy sections now labeled "shims".

- **`docs/INSTALL.md`** — top callout points users at `agents-manager`. Rest of doc unchanged.

- **`README.md`** — Quick-start callout added. Rest of doc unchanged.

### New commands

```
agents-manager install . --git auto --yes           # install into current dir
agents-manager doctor . --fix                       # diagnose + auto-remediate
agents-manager skills list --missing-only            # show missing skills
agents-manager skills add --all --yes               # install all missing required
agents-manager skills which verification-before-completion
agents-manager skills update --all                  # bulk-update global skills
agents-manager update --check                       # show version drift (delegates to update.sh)
agents-manager release zip v0.10.1                  # build a ZIP (delegates to release-zip.sh)
agents-manager help                                 # full help
```

### `doctor` checks

`agents-manager doctor [TARGET] [--fix]` runs:

- **Controller files** (opencode.jsonc, CLAUDE.md, agents_manager/, share/, tasks/)
- **Required skills** (all 10 manifest entries; reports installed vs missing)
- **Tooling**: git on PATH, python3 on PATH (for JSON parsing), opencode on PATH, npx on PATH
- **Shell version** (bash ≥ 4; PowerShell — on Windows)
- **Target git state** (is `.git` present)
- **Fix mode** (`--fix`): auto-runs `skills add --all` + `install` to remediate failures

Output is colored PASS/WARN/FAIL with a summary line. Exit code 0 = no FAILs; 1 = at least one FAIL.

### `skills` subcommands

- `list [--required-only|--installed-only|--missing-only]` — show every manifest entry's installed status.
- `add <name>...` — run the manifest's `install_cmd` for one skill (uses `npx` for global obra skills).
- `add --all` — install all required + missing skills. `-y` skips prompts.
- `remove <name>` — for global skills only. Generates a matching `npx skills remove` command.
- `which <name>` — show installed path OR "missing" with the install command.
- `update <name|--all>` — run the manifest's `update_cmd`. Local skills have no update (they ship with the controller).

### Why

Before v0.10.0, downstream users had to remember `bin/install.sh`, `bin/check.sh`, `bin/update.sh`, and a separate `npx skills add ...` invocation for each missing skill. The dispatcher collapses all of that into one entry point. The interactive wizard makes zero-knowledge users productive without reading the docs.

### Manifest discoverability

Adding a new required skill is now a 1-line JSON change in `bin/skills-manifest.json`. No code change needed in `bin/agents-manager*`. `skills add --all` and `doctor` pick up the new entry automatically.

### Backward compat

All v0.9.x invocations still work via the shim layer:

```bash
bash bin/install.sh . --git auto --yes   # -> agents-manager install . --git auto --yes
.\bin\install.ps1 -Target . -Git auto -Yes   # -> agents-manager.ps1 install . -Git auto -Yes
bash bin/check.sh .   # -> agents-manager check .
```

### Scope limits

- The bash dispatcher requires **bash 4+** (associative arrays + `select` builtin for wizard). macOS ships bash 3 by default — use Git Bash or WSL there. PowerShell requires 5.1+ / pwsh 7+.
- `python3` is required by the bash dispatcher (for JSON parsing of `bin/skills-manifest.json`). PowerShell uses `ConvertFrom-Json` and does not need python3.
- `update` subcommand **delegates** to the legacy `update.sh`/`update.ps1` (v0.8 logic). A future release will fold update logic into the dispatcher.
- `release` and `lint` subcommands **delegate** to the existing `release-zip*.sh` and `lint-design.sh` scripts.

### Files touched

| File | Status |
|---|---|
| `bin/agents-manager` | **NEW** — bash dispatcher (~500 lines, single file) |
| `bin/agents-manager.ps1` | **NEW** — PowerShell mirror |
| `bin/skills-manifest.json` | **NEW** — 10-skill declarative manifest |
| `bin/install.sh` | **modified** — 3-line shim |
| `bin/install.ps1` | **modified** — 3-line shim |
| `bin/check.sh` | **modified** — 3-line shim |
| `bin/check.ps1` | **modified** — 3-line shim |
| `bin/update.sh` | **modified** — 3-line shim |
| `bin/update.ps1` | **modified** — 3-line shim |
| `bin/README.md` | **modified** — documents new dispatcher + shims |
| `docs/INSTALL.md` | **modified** — top callout for `agents-manager` |
| `README.md` | **modified** — Quick start callout |
| `agents_manager/CHANGELOG.md` | **modified** — this entry |

**v0.10.0 — additive minor.** Safe for all v0.9.x users. No controller logic changes. No permission layer changes.

## v0.9.2 — Release infrastructure (tags + GitHub Releases + auto-release workflow) (2026-06-30)

**Meta release.** The controller is unchanged. This release backfills the missing GitHub infrastructure that was referenced by `docs/INSTALL.md` Option B but never actually existed on the remote.

### What's new

- **14 git tags now on remote.** Previously, the repo had 13 local annotated tags (`v0.1.0` … `v0.9.0`) that were never pushed. Now `v0.1.0` through `v0.9.1` are all on `origin` (28 refs including `^{}` dereferenced form). `git checkout v0.7.2` works for downstream users.

- **14 GitHub Releases published, each with a ZIP.** Previously the Releases page at <https://github.com/ahmadmhmdsy/agents-manager/releases> was empty. Now every tag from `v0.1.0` to `v0.9.1` has a release with the matching `agents-manager-vX.Y.Z.zip` artifact and a body extracted from `agents_manager/CHANGELOG.md` (or the tag subject as fallback for `v0.1.0` and `v0.7.1` which predate the changelog discipline).

- **`.github/workflows/release.yml`** — auto-publishes a GitHub Release when any `v*` tag is pushed. Builds the ZIP via `git archive`, extracts CHANGELOG notes, and creates the release using a 3-step process (create → PATCH title+body → upload asset) to work around a GitHub API bug that returns HTTP 500 when `name` or `body` are included in the initial `POST /releases`. Future flow is now:

  ```bash
  git tag -a v0.9.2 -m "v0.9.2: short description"
  git push origin v0.9.2
  ```

  The release appears in <2 minutes with the ZIP attached.

- **`bin/release-zip.sh`** (new) — `git archive` based ZIP builder. Validates the ZIP contains all 7 expected paths plus `bin/install.sh` + `bin/install.ps1` (Option B users invoke the installer from the extracted folder; without `bin/`, the ZIP is useless).

- **`bin/release-zip.ps1`** (new) — PowerShell mirror using `[System.IO.Compression.ZipFile]` (built into .NET — no external `zip` CLI needed). Same validation logic.

- **`bin/release-zip-all.sh`** (new) — loop helper for the one-time backfill. `bin/release-zip-all.sh --out ./dist` builds ZIPs into `./dist/` for every local `v*` tag.

- **`bin/README.md`** — documents the three new release-* scripts (and notes they are maintainer-only).

- **`README.md`** — release badge `v0.7.0` → `v0.9.1`; Option B points at `releases/latest` with the `v0.9.1` ZIP example.

- **`docs/INSTALL.md`** — Option B now has curl/wget/PowerShell one-liners pinned to a specific version, plus a note that the ZIP includes `bin/` so Option B is fully self-contained.

### Why

Before v0.9.2, the install docs advertised Option B as "download a ZIP, run the installer from inside it." But the Releases page was empty, no tags existed on the remote, and the installer scripts didn't even ship in any artifact. Three dead ends stacked. v0.9.2 closes the loop so Option B actually works.

### Scope limits

- The backfill was done via a one-off PowerShell script (`backfill-via-curl.ps1`) using the same 3-step approach as the new workflow. The script is **not committed** to the repo — it was a one-time use.
- The ZIPs in the Releases page are the controller files only (7 paths from the path allowlist in `bin/release-zip.sh`). They do **not** include the full git history or any CI/test outputs.
- The release workflow is intentionally **not** triggered by `workflow_dispatch` after the backfill — that path had reliability issues in testing. Tag-push is the canonical trigger. If a future need arises for manual release creation, a small `workflow_dispatch` workflow can be added on top.

### GitHub API quirk documented

GitHub's `POST /releases` endpoint returns HTTP 500 for some accounts (including this one) when the payload includes `name` or `body` fields. The bug is not yet fixed as of 2026-06-30. The 3-step workaround used by the release workflow and the backfill script:

1. `POST /releases` with only `{"tag_name": "vX.Y.Z"}` — succeeds.
2. `PATCH /releases/{id}` with `{"name": "...", "body": "..."}` — succeeds.
3. `POST /releases/{id}/assets?name=...` with the ZIP — succeeds.

If GitHub fixes the bug, the workflow can collapse back to a single `gh release create --title ... --notes-file ...` call.

### Files touched

| File | Status |
|---|---|
| `.github/workflows/release.yml` | **modified** — 3-step create/patch/upload (was single `softprops/action-gh-release` call). |
| `bin/release-zip.sh` | **NEW** — `git archive` based ZIP builder with validation. |
| `bin/release-zip.ps1` | **NEW** — PowerShell mirror using `[System.IO.Compression.ZipFile]`. |
| `bin/release-zip-all.sh` | **NEW** — loop helper for the one-time backfill. |
| `bin/README.md` | **modified** — documents the 3 new scripts. |
| `README.md` | **modified** — badge v0.7.0 → v0.9.1; Option B → `releases/latest` with v0.9.1 example. |
| `docs/INSTALL.md` | **modified** — Option B has curl/wget/PowerShell one-liners + note that ZIP includes `bin/`. |
| `agents_manager/CHANGELOG.md` | **modified** — this entry. |

**v0.9.2 — additive meta-release.** No controller changes, no `opencode.jsonc` changes, no agent behavior changes. Only the packaging infrastructure. Existing v0.9.1 users are unaffected.

## v0.9.1 — Installer auto-initializes git for zero-knowledge users (2026-06-30)

Additive installer patch. No controller changes, no opencode.jsonc changes, no agent behavior changes. New users with no git familiarity can install into a fresh folder without an extra "oh no, I forgot to run git init" step.

### What's new

- **`bin/install.sh` and `bin/install.ps1`** — new `--git <auto|prompt|skip>` (PowerShell: `-Git`) flag. Default is **`auto`** for zero-knowledge UX:
  - `auto` — if `TARGET` is not yet a git repo, run `git init` + initial commit automatically. If the `git` CLI is missing, print one warning and continue (don't fail the install).
  - `prompt` — if `TARGET` is not yet a git repo, ask `Initialize git now? [Y/n]` (default yes).
  - `skip` — never touch git. Today's behavior.
- **No-op when `.git` already exists** — regardless of mode, re-running the installer into an already-initialized repo is a no-op for the git step.
- **Local-only identity** — the initial commit uses `agents-manager <agents-manager@local>` so it doesn't depend on the user's global git config.
- **`docs/INSTALL.md`** — new "Git initialization" section in the install guide, with examples for all three modes.
- **`bin/README.md`** — flag documented in the script reference.
- **`README.md`** — one-line callout in the "Quick start" section.

### Why

Master's existing v0.6.0 Phase 0 prompt (`agents_manager/SKILL.md` § PHASE 0) already asks about `git init` at task time. But that prompt fires *after* the controller is installed — so a user who installs into a fresh, non-git folder gets the install to succeed, then sees the git prompt on every single task. Pushing the option into the installer eliminates the surprise entirely and matches "zero knowledge / as easy as possible."

### Scope limits

- The installer only **initializes** git; it does not configure remotes, push, or set up any workflows.
- The starter `.gitignore` (already shipped since v0.7.2) is unchanged. The installer still does not auto-add `node_modules/`, `dist/`, `.env*`, etc. — that's the user's job (or the master agent's Phase 0 prompt if they accept it).
- PowerShell parity uses `$Host.UI.PromptForChoice` for the `[Y/n]` prompt (works headless if `-Yes` is passed).

### Files touched

| File | Status |
|---|---|
| `bin/install.sh` | **modified** — version bump (v0.7.2 → v0.9.1); `--git` flag parsing; new `Git:` block + `git_init_if_needed` step between `Gitignore:` and `Permissions:` |
| `bin/install.ps1` | **modified** — version bump; `-Git` parameter (ValidatedSet: auto/prompt/skip); new `Initialize-GitIfNeeded` function with `$Host.UI.PromptForChoice` |
| `docs/INSTALL.md` | **modified** — new "Git initialization" section after the prerequisites + install options |
| `bin/README.md` | **modified** — flag documented in both `install.sh` and `install.ps1` sections |
| `README.md` | **modified** — one-line callout in "Quick start" |
| `agents_manager/CHANGELOG.md` | **modified** — this entry |

### Tag / commit

**v0.9.1 — additive patch.** Safe for all v0.9.0 users. Re-running install into an existing v0.9.0 project is a no-op for the git step regardless of mode (because `.git` already exists).

### Shell coverage

| Script | Tested on |
|---|---|
| `install.sh` | bash 4+ (Linux, macOS, WSL, Git Bash) |
| `install.ps1` | PowerShell 5.1 (Windows PowerShell) and 7+ (pwsh, cross-platform) |

No changes to test matrix.

## v0.9.0 — am-design v2.0: 12-mode design specialist (2026-07-20)

New: a 6th agent — `am-design` — handling all visual / UX / design / prototype / brand / audit / copy / illustration / translation work. Adds 12 modes (up from 5), 6 mockup templates (up from 1), 7 new resource templates, 4 worked examples + 1 case study, and audience-aware handoff.

### What's new

- **New agent: `am-design`** — visual / UX / design / prototype specialist. Tokenized design system + HTML mockups + brand identity + accessibility audit + microcopy + icon sets + locale adaptation. Strict-separation only — never touches `src/**` or application code.
- **12 modes** (was 5 in v1 of am-design, set not single value):
  `RESEARCH`, `CONCEIVE`, `BRAND`, `SYSTEMIZE`, `MOCK`, `PROTOTYPE`, `EXTEND`, `WRITE`, `AUDIT`, `EVALUATE`, `ILLUSTRATE`, `TRANSLATE`.
- **6 mockup templates** (was 1): `mobile`, `tablet`, `desktop`, `web-responsive`, `email`, `brand`. Each encodes the medium's locked dimensions and chrome.
- **7-question discovery protocol** — before producing anything, am-design asks: medium? audience? constraints? artifact set? mode set? scope tier? success criteria? Answers land in `00_brief.md`.
- **Audience-aware handoff** — `99_handoff.md` declares the next consumer (am-coder / human designer / PM / stakeholder / marketing / agency / accessibility reviewer / localizer) and ships only the artifacts that consumer needs.
- **Tree-structured output** (`share/design/<task-id>/`) — optional folders per mode (`01_research/`, `02_brand/`, `03_system/`, `04_mockups/`, `05_audit/`, `06_copy/`, `07_primitives/`, `08_translations/`, `99_handoff.md`). Folder presence matches artifact set.
- **Strict two-lane separation upheld** — am-design never writes `src/**`. If a reference implementation is wanted, master spawns a small `am-coder` task with `share/design/<task-id>/` as input.
- **4 worked examples + 1 case study**:
  - `examples/design-onboarding/` — fitness app, 2-screen mobile onboarding (carried from am-design v1)
  - `examples/design-brand-identity/` — Atlas coffee roastery, brand + copy (new)
  - `examples/design-responsive-web/` — Lumio habit tracker, 3 breakpoints (new)
  - `examples/design-audit/` — Stride fitness app, 20 findings + severity matrix + remediation plan (new)
  - `examples/design-casestudy-quran/` — retrospective on a real multi-theme, multi-locale Quran app design system built before am-design was formalized; documents what works and what to formalize (new)
- **7 new resource templates** under `agents_manager/design/resources/`:
  - `research-template.md` (competitive analysis, user research synthesis, audit input)
  - `brand-template.md` (color, typography, voice, brand guidelines)
  - `audit-template.md` (findings, severity matrix, remediation plan)
  - `copy-template.md` (microcopy, content strategy)
  - `motion-spec-template.md` (durations, easing, transitions, reduced motion)
  - `icon-template.svg` (24×24 grid placeholder)
  - `multi-locale-checklist.md` (Arabic/Hebrew/Persian/Urdu/Latin/CJK, dual calendar, RTL specifics)
- **Expanded novel-abstractions seed list** (`agents_manager/design/resources/novel-abstractions-seed-list.md`) — 11 accepted (T) + 12 refused (R) patterns, generalized from the original 5 + 5 UI-focused set.
- **Optional `bin/lint-design.sh`** — advisory lint that flags inline hex and emoji in mockup HTML files. Does not block commits.

### Why

Before v0.9.0, design work fell on `am-coder` (who is supposed to focus on implementation) or got invented ad-hoc (no contract for visual deliverables). Real-world design work spans web / mobile / brand / audit / copy / icon / locale — not just mobile-app mockups. v0.9.0:

1. Adds a dedicated agent (`am-design`) so implementation specialists stay focused.
2. Generalizes the scope beyond mobile to web / desktop / brand / email / etc.
3. Decouples the handoff audience (was always `am-coder`; now supports 8 audiences).
4. Documents the patterns that emerged from the Quran app case study as reusable abstractions.

### Scope limits

- `am-design` does not write framework-specific code. Reference implementations are `am-coder`'s job.
- Mediums supported in v0.9.0: web (responsive), mobile, tablet, desktop, email, brand. Watch, TV, kiosk, voice, print, packaging deferred to v3.
- Multi-locale handling is documented for Arabic, Hebrew, Persian, Urdu, Latin, CJK. Other scripts (Tamil, Thai, Devanagari) partially documented; full coverage in v3.
- Case study (`design-casestudy-quran`) is documentation of past work — not a live reference implementation.
- The lint script is advisory; it doesn't fail CI.

### Files touched

| File | Status |
|---|---|
| `opencode.jsonc` | **modified** — added `am-design` block with full inline prompt (boundaries + return shape + tool usage); added comment marker for v2.0; master's task dispatch list expanded to 5 specialists (FIX A) |
| `CLAUDE.md` | **modified** — added `am-design` row to Available agents table; counts updated (5 → 6 agents total, 4 → 5 specialists); stale line 47 rewritten for v0.5.0 soft walls (FIX F) |
| `README.md` | **modified** — counts updated; FAQ "How do I add a 6th agent?" updated with am-design as the worked example; status banner; "The five agents" → "The six agents" |
| `agents_manager/SKILL.md` (master) | **modified** — `## Spawning a specialist` dispatch contract references `am-design` (FIX D); added design routing rule (FIX H); anti-pattern "5 specialists" → "5 specialists" with design included |
| `agents_manager/CHANGELOG.md` | **modified** — this entry |
| `agents_manager/design/` | **NEW** (21 files: SKILL.md + rules.md + 11 resources + notes/) |
| `docs/am-design-v2-migration.md` | **NEW** |
| `docs/am-design-v2-decisions.md` | **NEW** |
| `docs/am-design-v2-testing.md` | **NEW** |
| `bin/lint-design.sh` | **NEW** (optional helper) |
| `examples/design-onboarding/` | carried from am-design v1 |
| `examples/design-brand-identity/` | **NEW** (Atlas) |
| `examples/design-responsive-web/` | **NEW** (Lumio) |
| `examples/design-audit/` | **NEW** (Stride) |
| `examples/design-casestudy-quran/` | **NEW** (retrospective) |
| `bin/install.sh` + `bin/install.ps1` | **modified** — chmod +x on `bin/*.sh` after copy |
| `.github/workflows/ci.yml` | **modified** — added `lint-design` CI job; expanded `validate-frontmatter` to include `agents_manager/design/SKILL.md`; examples-consistency now globs all `examples/*/README.md` |

### Tag / commit

**v0.9.0 — additive minor.** No breaking changes to existing 5 agents. Owners on v0.8.0 can apply this PR without rewriting anything else. Existing dispatches to master, am-research, am-planning, am-coder, am-review work unchanged. am-design is opt-in — master spawns it only when the task touches visible UI AND the user has not yet locked a visual direction.

### Source attribution

- **Generator:** MiniMax-M3 via opencode CLI on Windows PowerShell 7+
- **Source date:** 2026-07-20
- **Source project:** agents-manager v0.8.0 + am-design v1 (carried from `agents-manager-0.8.0` local snapshot) + am-design v2 (12 modes, 6 mediums, 4 examples + case study)
- **License:** inherits the agents_manager license (MIT). Contribution, not obligation.

## v0.8.0 — Auto-updater (2026-06-29)

New: the controller can now check for and apply upstream updates without manual ZIP downloads.

### What's new

- **`bin/update.sh`** (Unix) + **`bin/update.ps1`** (PowerShell) — fetch the latest release from GitHub, compare to the local version (read from `agents_manager/CHANGELOG.md`), and apply the upgrade by overwriting the 6 controller paths after backing up the current install to `.agents-manager-backup-<timestamp>/`.
  - Flags: `--check` (print version + changelog excerpt only), `--yes`/`-y` (apply without prompting), `--from <ver>` (override local detection), `--target <ver>` (pin to specific version).
  - Default behavior: show version diff + new changelog excerpt, prompt `[yes/no]`, on yes back up + overwrite + run `bin/check.sh` + report.
  - Edge cases handled: GitHub unreachable (exit 4), ZIP malformed (exit 4), active pipeline detected (exit 5), first-time install with no CHANGELOG (treated as 0.0.0 → upgrade).
- **Once-per-day auto-prompt** (in master SKILL.md) — master reads `.agents-manager/.last-update-check` (a marker file) on session start. If missing or older than 24 hours, prompts the user ONCE to run `bin/update.sh`. Writes a fresh timestamp after the prompt (regardless of answer) so the cadence is "at most once per day."
- **`bin/README.md`** — added `update.sh` / `update.ps1` sections + 2 new exit codes (4 = network error, 5 = active pipeline).
- **`docs/INSTALL.md`** — "Updating from a previous version" expanded with three update paths (subtree pull / `bin/update.sh` / fresh install), the auto-prompt explanation, and a "what gets backed up" section.
- **`README.md`** — small Usage note pointing to `bin/update.sh` for upgrades.

### Why

Before v0.8.0, updating required either `git subtree pull` (manual) or downloading a release ZIP (also manual). Users on smaller downstream projects (sandbox / non-git / one-off) had no friction-free upgrade path. v0.8.0 makes "check for updates" a single command (`bash bin/update.sh --check`) and surfaces the prompt automatically once per session-day.

### Scope limits

- `update.sh` only updates the 6 controller paths. User-level skills (`~/.agents/skills/`) are NOT updated — run `npx skills add` manually for any new skill requirements.
- The script refuses to run if an active pipeline is detected (any `share/notes/03_coder_summary_*.md` updated within the last hour → exit 5). Run it during a quiet moment.
- Backups go to `.agents-manager-backup-<timestamp>/` at the project root. They are NOT auto-cleaned — delete them once you've verified the upgrade.

### Tag / commit

Backwards compatible. v0.8.0 ships a new script + a new section in master SKILL.md. No controller logic changes.

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
