---
scope: repo-wide
audience: humans + agents
topic: contribution-guide
status: active
version: 1.0.0
created: 2026-07-04
last_verified: 2026-07-04
description: Repo-wide contribution guide for agents-manager — issues, branching, PR format, file conventions, versioning, and verification for both human and AI-agent contributors.
---

# Contributing to agents-manager

> How to contribute — whether you are a **human user** opening a PR, or an
> **AI agent** running the multi-agent pipeline. Read the section that matches
> your intent, then click through to the rulebook.

This guide is the **single discoverable entry point** that GitHub renders on
the PR/Issue page. It cross-links (does not duplicate) the existing nested
guides for templates, permissions, maintenance, and upstream patches.

## 0. Read first

If you are new to the repo, read these in order before opening a PR or
dispatching an agent:

1. `README.md` — top-level orientation + auto-routing rule.
2. `AGENTS.md` — controller conventions + standing rules.
3. `opencode.jsonc` — the 6 agent definitions.
4. `agents_manager/SKILL.md` — master orchestration protocol.
5. `agents_manager/CHANGELOG.md` (latest entry) — system evolution.
6. `share/notes/02_plan_*.md` + `tasks/<id>.md` — current in-flight work.

## 1. Contributor types

| You are | Your relevant sections |
|---|---|
| Human user filing a bug / opening a PR | §3, §4, §5, §6, §8, §9, §10 |
| Human adding a new specialist agent | §6.1 + `agents_manager/SKILL.md` |
| Human adding a new template | §6.3 → `templates/CONTRIBUTING.md` → `templates/AUTHORING.md` |
| Human submitting an upstream patch (from a downstream fork) | §6.8 → `docs/UPSTREAM-CONTRIB.md` |
| AI agent running the pipeline | §7 (inter-agent file conventions) + §9 (verification) + the dispatcher's own `SKILL.md` |
| Maintainer cutting a release | §8 + `docs/MAINTENANCE.md` |

If you are an AI agent dispatched via `task(subagent_type=...)`: **read your
own `SKILL.md` first**, then read the relevant section of this guide. Do not
write outside the output paths declared in your `SKILL.md` boundaries.

## 2. Code of conduct

Be honest, share evidence, and never silently change a contract. If you find a
bug in someone else's PR, say so with a reproduction. If you disagree with a
rule, follow §10 (decision disputes) — never bypass the rulebook to ship. All
contributions are MIT-licensed (§13).

## 3. Filing issues

### 3.1 Bug report

Use this template verbatim:

```markdown
## Summary
<one sentence — what is wrong>

## Repro steps
1. <step>
2. <step>
3. <observed actual>

## Expected
<what should have happened>

## Environment
- agents-manager version: v0.X.Y
- Agent touched: master / am-research / am-planning / am-design / am-coder / am-review
- Relevant file: agents_manager/<role>/SKILL.md | tasks/<id>.md | share/notes/...
- OS + shell: Windows pwsh 7+ | macOS bash | Linux bash

## Evidence
<command output, share/ artifact path, screenshot>
```

### 3.2 Feature request

State motivation, scope ("controller behavior" vs "template-only" vs "docs-only"),
rollback plan, and which existing rule (if any) it changes. If it adds a 7th
specialist agent, see §6.1.

### 3.3 Question / discussion

Use GitHub Discussions, not Issues. Issues are for actionable items.

## 4. Repository layout at a glance

| Path | Purpose | Owner |
|---|---|---|
| `README.md` | GitHub landing | maintainer |
| `AGENTS.md` | Controller conventions | master |
| `opencode.jsonc` | 6 agent definitions | maintainer |
| `agents_manager/` | Controller (master + 5 specialists) | master |
| `agents_manager/<role>/SKILL.md` | Specialist prompt + boundaries | specialist |
| `agents_manager/<role>/notes/` | Controller memory (frontmatter required) | specialist |
| `share/` | Inter-agent bus (notes/ handoffs/ reports/ design/ messages/) | per agent output paths |
| `tasks/` | Per-task tracker files (`T-YYYY-MM-DD-NNN`) | master |
| `examples/` | Worked pipeline traces (3 code + 5 design) | am-coder + am-design |
| `templates/` | Reusable authoring standard + library | am-design + am-coder |
| `bin/` | Install / check / update / standalone-installer scripts | maintainer |
| `docs/` | INSTALL, PERMISSIONS, MAINTENANCE, UPSTREAM-CONTRIB | maintainer |
| `.agents/skills/` | OpenCode-discoverable skills | master (install-time) |
| `.github/workflows/` | CI, release, obra-sync reminder | maintainer |

## 5. Branching, commits, and pull requests

### 5.1 Branch naming

| Pattern | Used for |
|---|---|
| `feat/<area>-<slug>` | New feature |
| `fix/<area>-<slug>` | Bug fix |
| `docs/<slug>` | Docs-only change |
| `chore/<slug>` | Tooling / refactor / release |
| `template/<name>` | New or updated template |

`<area>` is one of: `agents-manager` (controller), `am-research`, `am-planning`,
`am-design`, `am-coder`, `am-review`, `install`, `ci`, `examples`, `templates`.

Examples: `feat/am-design-v2-mockup-templates`, `fix/am-coder-summary-filename`,
`docs/clarify-permissions`, `chore/release-v0.10.0`, `template/cinematic-landing`.

### 5.2 Commit message format

Conventional Commits. The subject line is the contract; the body explains
*why*, not *what*.

```
<type>(<scope>): <subject, imperative, ≤72 chars>

<body — context, motivation, alternatives considered, links>

Refs: T-2026-07-04-001
Closes: #123
```

`<type>` ∈ {`feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `template`}.
`<scope>` matches the area table in §5.1. Subject line uses imperative mood
("add", "fix", not "added", "fixed").

### 5.3 PR title format

PR title **must** match the commit subject. Required prefixes:

| Prefix | Use for |
|---|---|
| `feat(agents-manager): …` | Controller behavior change |
| `feat(am-<role>): …` | Specialist prompt / SKILL.md / notes/ change |
| `feat(install): …` | Install / update / standalone-installer |
| `docs: …` | Docs-only change |
| `template(<name>): v0.1.0 initial cut` | New template (matches `templates/CONTRIBUTING.md` §5) |
| `template(<name>): memory: NN-<topic>` | New memory file in existing template |
| `template(AUTHORING): …` | Bump to the authoring standard itself |
| `examples(<name>): v0.1.0 initial cut` | New worked example |
| `chore(release): v0.X.0` | Release commit |
| `ci(<workflow>): …` | GitHub workflow change |
| `upstream: <id> — <slug>` | Upstream-contribution patch (see `docs/UPSTREAM-CONTRIB.md`) |

### 5.4 PR body checklist

Every PR must include these sections in the body:

```markdown
## Context
<why this change exists; link to issue, task id, or discussion>

## What changes
<bullet list of user-visible deltas>

## How to verify
<concrete commands + expected output, e.g. `bash templates/<name>/tests/verify.sh` → exit 0>

## Risk
<what could break; who is affected>

## Rollback
<how to revert; one-liner if obvious>

## CHANGELOG
<pointer to the entry in agents_manager/CHANGELOG.md or "docs-only, no entry">
```

### 5.5 Review rules

- `am-review` reports must be **brutally honest**. False PASS ships bugs;
  false FAIL just costs a fix loop.
- Do **not** accept the first review report without reading it.
- **`max_fix_loops = 3`.** Surface to the user after the cap.
- The reviewer is the final tick on `templates/AUTHORING.md` Rule 8 acceptance.
- Master pauses for user confirmation at Phase 2 (planning → build).

## 6. What you can change and where it lands

### 6.1 Controller behavior (`agents_manager/`, `opencode.jsonc`)

This is the highest-risk change area. It touches the orchestration protocol
every downstream user inherits.

| File | Owner | Review gate |
|---|---|---|
| `agents_manager/SKILL.md` | master | am-review + user ack |
| `opencode.jsonc` | maintainer | user ack |
| `agents_manager/CHANGELOG.md` | per change | user ack on version bump |

**To add a 7th specialist agent** (worked example: `am-design` in v0.9.0):

1. Add the agent block to `opencode.jsonc` (use any existing agent as a
   template; match the inline prompt structure: `## Before acting` /
   `## Output` / `## Boundaries` / `## Return` / `## Tool usage (v0.5.1+)`).
2. Create `agents_manager/<role>/SKILL.md` + `rules.md` + `notes/` (episodic
   + semantic) + `resources/`.
3. Reference the agent in `agents_manager/SKILL.md` master prompt:
   - `## Spawning a specialist` dispatch contract
   - `## Your responsibilities` ("Never do a sub-agent's job. … Design →
     design agent. …")
   - `## What you cannot do` (the master never dispatches non-specialist agents)
4. Add the agent row to `AGENTS.md` agents table + update project-structure
   count.
5. Update `README.md` "The six agents" table + FAQ + releases.

Pressure to add a 6th/7th agent is usually a sign that existing rules are
too vague — tighten the rules first.

### 6.2 Specialist prompt / SKILL.md (`agents_manager/<role>/SKILL.md`)

**Hard rule:** do not edit a specialist's `SKILL.md` unless you are
redesigning the controller. PR title pattern: `feat(am-<role>): <slug>`.
Pair with `rules.md` + `notes/` updates in the same commit. Soft walls
(v0.5.0+) mean boundaries are prose, not permission-layer enforced — see
`docs/PERMISSIONS.md`.

### 6.3 Templates (`templates/<name>/`)

Templates are governed by their own rulebook. **Read these two files first**:

- `templates/CONTRIBUTING.md` — discoverable entry point, 4 contributor
  intents with numbered steps.
- `templates/AUTHORING.md` — the binding rulebook (8 rules + acceptance
  checklist).

One-line summary of the binding rule: **one source of truth per concern** —
no duplicated token tables, section lists, or hard rules across files. H1
number on every memory file must match its filename prefix (`02-cinematic-hero.md`
opens with `# 02 · Cinematic hero — USE THIS WHEN: …`). Filenames are
monotonic — append, never insert. Every README claim is grep-verifiable
via `tests/verify.sh`. Every line of `assets/MANIFEST.txt` must resolve.

### 6.4 Examples (`examples/<name>/`)

A worked example ships the full pipeline trace. Required skeleton:

```
examples/<name>/
  user-task.md              ← the original user request
  README.md                 ← replay instructions
  original/                 ← starting state (before any agent touched it)
  expected-output/          ← final artifacts
  share/                    ← 00–04 phase outputs (handoffs, notes, reports)
  tasks/T-YYYY-MM-DD-NNN.md ← per-task tracker
```

PR title `examples(<name>): v0.1.0 initial cut`. Pattern lifted from
`examples/node-markdown-linter/` (canonical end-to-end demo) and
`examples/design-casestudy-quran/` (retrospective-only, no `expected-output/`).

### 6.5 Docs (`docs/*.md`)

Doc-only changes need no `CHANGELOG.md` entry. For release-doc work, follow
`docs/MAINTENANCE.md`. PR title `docs: <slug>`. Verify every cross-link
resolves before submitting.

### 6.6 Installer / CLI scripts (`bin/`, `bin/standalone-installer/`)

PR title `bin(<area>): <slug>`. Re-run the lint commands from §9.2–9.4
before opening the PR. Windows-only `.cmd` scripts cannot be CI-linted
(CI runs on `ubuntu-latest`); use the manual smoke checklist in
`CHANGELOG.md` / plan files instead. Keep all three dialects (`bin/agents-manager`,
`bin/agents-manager.ps1`, `bin/agents-manager.py`) in feature parity.

### 6.7 Workflows (`.github/workflows/`)

PR title `ci(<workflow>): <slug>`. CI must remain green on `ubuntu-latest`.
A workflow change that gates new behavior must also document the behavior
in the matching section of `README.md` or `docs/`.

### 6.8 Upstream patches (`agents_manager/upstream-contrib/`, `docs/UPSTREAM-CONTRIB.md`)

If you ran agents-manager on a downstream project and identified
improvements, write them up as a `PROPOSED_PATCH_v<from>.<to>_<date>.md`
in `agents_manager/upstream-contrib/`, with a corresponding attribution
file at `docs/UPSTREAM-CONTRIB.md` describing what was applied, what was
deferred, and any modifications you made to the patch. Use stable IDs
(C1..C3, H1..H4, G1..G7, M1..M4) so the patch is LLM-actionable. See
`docs/UPSTREAM-CONTRIB.md` for the worked exemplar.

## 7. Inter-agent file conventions (AI agents read this)

### 7.1 Task IDs

Format: `T-YYYY-MM-DD-NNN`. One file per id at `tasks/<id>.md`. Master
allocates at Phase 0 Ingest; sub-agents read-only.

### 7.2 Output paths (the "Owns" column)

| Agent | Primary output destination |
|---|---|
| master | `share/handoffs/`, `share/notes/99_decisions.md`, `tasks/` |
| am-research | `share/notes/01_research_*.md` |
| am-planning | `share/notes/02_plan_*.md`, `tasks/<id>.md` rows |
| am-design | `share/design/<task-id>/**` |
| am-coder | source code, `share/notes/03_coder_summary_*.md` |
| am-review | `share/reports/04_review_*.md` |

In v0.5.0+ any agent can technically read/write anywhere
(`permission: "allow"`); the convention is to write only to the listed
paths unless coordination requires more.

### 7.3 Phase log + handoff filenames

```
share/notes/01_research_<id>.md
share/notes/02_plan_high_<id>.md
share/notes/02_plan_phases_<id>.md
share/notes/03_coder_summary_<id>_<phase>.md
share/notes/04_warns_register_<id>.md      ← v0.6.0+, consolidated WARN log
share/notes/99_progress_<id>.md           ← master recovery ledger
share/handoffs/00_user_task.md            ← master, Phase 0 Ingest
share/reports/04_review_<id>_<phase>.md
share/messages/<from>-to-<to>-<topic>.md  ← free-form, naming carries intent
```

### 7.4 Memory files (controller vs template)

There are two memory trees, and they are not interchangeable.

| Tree | Frontmatter | Trigger-line format | Authority |
|---|---|---|---|
| `agents_manager/<role>/notes/` | **Required** (YAML 6 keys) | `# <topic> — USE THIS WHEN: …` | specialist + master |
| `templates/<name>/memory/` | **Forbidden** | `# NN · <topic> — USE THIS WHEN: …` | template author + template `AUTHORING.md` |

The discriminator: `agents_manager/research/notes/semantic/template-memory-cp-fence.md`.

### 7.5 Frontmatter format

YAML, 6 keys:

```yaml
---
scope: <controller | templates | repo-wide | ...>
topic: <slug>
status: active | draft | deprecated
version: X.Y.Z
created: YYYY-MM-DD
last_verified: YYYY-MM-DD
---
```

Validation: `python3 scripts/validate-frontmatter.py` (stdlib-only; checks
`description` length and, for `skills/` paths, name + parent-dir match).

## 8. Versioning and CHANGELOG

### 8.1 System version (controller)

Semver. Bump rules:

| Bump | When | Worked example |
|---|---|---|
| Patch (0.0.x) | Typos, verify.sh additions, INDEX clarifications, doc-only fixes | v0.5.1 — tool usage efficiency |
| Minor (0.x) | New user-visible feature, new agent, new flag, behavior change | v0.6.0 — WARN register, v0.7.0 — chunk-size, v0.9.0 — am-design |
| Major (x.0) | Renamed rules, retired specialists, schema breaks | (none yet) |

### 8.2 Per-template version (template-internal)

Independent of system version. Mirrored in `templates/AUTHORING.md`
Versioning section. A template can bump without a controller bump.

### 8.3 CHANGELOG entry template

```markdown
## vX.Y.Z — <slug> (YYYY-MM-DD)

> <one-paragraph framing: what this release is and why it ships>

### What changed
- <user-visible delta 1>
- <user-visible delta 2>

### Files touched
- <area>: <count> files — <one-line scope>

### Open review items
- <decision-required> or "none"
```

### 8.4 What triggers a release

User-visible new feature = minor. Controller behavior change = minor.
Rule rename = major. Typos = patch. Doc-only changes = no release
required (commit lands on the next release's branch).

## 9. Local verification before submitting

Run all of these from the repo root unless a path is given:

### 9.1 Frontmatter

```bash
python3 scripts/validate-frontmatter.py
```

### 9.2 Shell scripts

```bash
# Bash (file is CRLF on Windows working tree; convert first)
npx --yes shellcheck <(python3 -c "open('bin/agents-manager','rb').read().replace(b'\r\n',b'\n').decode().encode()")
```

### 9.3 PowerShell

```bash
pwsh -NoProfile -Command "Invoke-ScriptAnalyzer -Path bin/agents-manager.ps1"
```

### 9.4 Python

```bash
python3 -m py_compile bin/agents-manager.py bin/install.py bin/standalone-installer/install.py
```

### 9.5 Templates

```bash
bash templates/<name>/tests/verify.sh   # exit 0 = grep-testable claims hold
```

### 9.6 Doctor

```bash
python3 bin/agents-manager.py doctor    # or: agents-manager doctor (v0.10.0+)
```

### 9.7 Git status + EOL

- `git status` clean (no stray edits).
- `.gitattributes` is the source of truth: `*.sh text eol=lf`,
  `*.ps1 text eol=crlf`, `*.cmd text eol=crlf`, `*.bat text eol=crlf`,
  `*.json/yaml/md text eol=lf`. Windows working trees may show CRLF
  locally; git normalizes on commit.
- `core.autocrlf=true` is the default; do not change it.

## 10. Decision disputes

If you disagree with a rule:

1. **Open a PR** citing the rule + affected file(s), in the rulebook or a
   template's memory.
2. **Propose the change with rationale.** Include a **worked counter-example**
   that demonstrates the rule produces a worse outcome for that case.
3. **Decision-log entry.** Rule changes flow through the affected
   template's `decision-log.md` with a `P<n>` fix reference. Controller
   rule changes flow through `agents_manager/CHANGELOG.md`.

If your dispute is about the standard's overall direction (not a specific
rule), open an Issue rather than a PR — rules change by consensus.

## 11. House rules

- **No commits without explicit user ask.** Project convention.
- **Never skip `am-review`** — even when "it looks fine."
- **Never accept the first review report without reading it.**
- **`max_fix_loops = 3`.** Surface to user after the cap.
- **Never edit `agents_manager/<role>/SKILL.md`** unless redesigning the controller.
- **`am-design` never writes `src/**`** (v0.9.0+).
- **Spec first, code second** for any non-trivial change.
- **Add the test that proves the change** — verification-before-completion.
- **Bugs = root cause, not symptom.** Grep every caller before patching.

## 12. Where to ask

| Question type | Goes to |
|---|---|
| Bug / actionable defect | Issue with §3.1 template |
| Rule dispute (specific) | PR with counter-example (§10) |
| Rule direction (overall) | Issue labeled `discussion` |
| Design direction for a template | PR against `templates/<name>/` |
| Security disclosure | File an Issue labeled `security` (no public exploit details) |
| Urgent pipeline break | Comment in the active `tasks/<id>.md` |

## 13. License

All contributions are MIT, matching `LICENSE`. In-bound contributions are
the same license out-bound. No CLA today; if one is introduced later, it
will be added here with a migration plan.

## 14. Version of this guide

`v1.0.0 — 2026-07-04`. Bump per §8.1 if any rule here changes; update
cross-links in lockstep. Bumps are tracked in `agents_manager/CHANGELOG.md`
under the "Docs" subsection, not as their own release.
