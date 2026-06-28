# Permissions — Soft-Wall Architecture (v0.5.0+)

> **v0.5.0 architectural change:** all 5 agents have `permission: "allow"`. OpenCode's permission layer is **not used**. Walls are now soft — enforced by each agent reading its `SKILL.md` "Boundaries" section and the inline prompt's "Can/Can't" list. The only enforcement is LLM discipline.

## What this means

- All agents can read any file
- All agents can write/edit any file
- All agents can run any bash command
- All agents can dispatch subagents (those that have the `task` tool)

The walls are now **prose contracts**, not mechanical guarantees. The architecture relies on each specialist reading its own `SKILL.md` boundaries and choosing to honor them.

## Why this design

**v0.4.0 → v0.4.1 era:** OpenCode's permission layer was used to enforce hard walls. A real-world downstream test exposed three classes of failure:
1. `write` tool requires `edit` permission for new file creation (paths only in `write` were unreachable)
2. Bash allow list is exact-match on the full command string (`"cat": "allow"` doesn't match `cat README.md`)
3. `task()` cancellation is silent (no diagnostic, no retry signal)

The v0.4.1 fixes added belt-and-suspenders (both blocks), prefix globs (`cat` AND `cat *`), a 5-check Phase 0 preflight, and a 3-retry task() protocol. The config grew from ~30 lines to 88 lines.

**v0.5.0 decision:** rather than continue patching the permission layer (more configurations, more edge cases, more debugging), accept the trade-off and remove the layer. Trust the SKILL.md prose.

## Trade-offs

| Aspect | v0.4.1 (hard walls) | v0.5.0 (soft walls) |
|---|---|---|
| Config size | 88 lines of `opencode.jsonc` | ~30 lines (just prompts) |
| Debugging permission failures | Common (3 known classes, more likely lurking) | Not applicable |
| Mechanical wall enforcement | Yes (with edge cases) | No |
| am-research can write code | No (blocked) | Yes (only SKILL.md stops it) |
| am-coder can edit the controller | No (blocked) | Yes (only SKILL.md stops it) |
| am-review can fix source code | No (blocked) | Yes (only SKILL.md stops it) |
| Trust model | Mechanical | Prose + LLM discipline |
| "When blocked" protocol | 5-step, mandatory | Retired (no blocks to handle) |
| Phase 0 preflight | Required (5 checks) | Retired (nothing to fail) |
| task() retry protocol | 3 retries with backoff | Retired (OpenCode surfaces errors directly) |
| "Both blocks" pattern | Required (write + edit) | Retired (no glob matching) |
| Bash prefix globs | Required | Retired (no glob matching) |

## What survives

- The 5-agent pipeline (research → planning → coder → review) — still useful as separation of concerns
- The file-based bus (`share/`, `tasks/`) — still useful for cross-agent coordination
- The phase gates (PHASE 0–4) — still useful for quality control
- The "brutally honest" review standard — still useful for review quality
- The Can/Can't prose in each SKILL.md — still useful as soft guidance
- The "If tasks/<id>.md is missing" specialist fallback — still useful as robustness

## What new agents should do

If you add a 6th agent:
1. Add it to `opencode.jsonc` with `"permission": "allow"`
2. Write a SKILL.md with clear `## Boundaries (soft walls)` section
3. Write an inline prompt that includes `## Boundaries (soft walls — enforced by you reading the boundaries, not by OpenCode)`
4. Include a "When a write fails" section modeled on the v0.5.0 wording in the existing 5 SKILL.md files
5. Reference the new agent from the master's prompt + dispatch contract

## When to opt back into hard walls

If your downstream project finds soft walls insufficient (e.g., a real bug where am-research wrote code by mistake), you can opt back in:
1. Set `permission: { ... }` instead of `permission: "allow"` for the offending agent
2. Whitelist only what the agent actually needs
3. Re-introduce the v0.4.1 patterns: both-blocks, bash prefix globs
4. Re-introduce the Phase 0 preflight in the master prompt

The architecture is **soft by default, hard by opt-in** — opposite of v0.4.0.

## Debugging when something goes wrong

Since walls are soft now, "agent did something out of lane" looks like a normal completion, not a blocked tool call. Debug steps:

1. **Re-read the agent's SKILL.md boundaries.** Did the agent follow them?
2. **Check the agent's return line.** Does it surface the boundary choice? (Soft-wall agents should be explicit about out-of-lane actions.)
3. **If the pattern recurs, opt the agent back into hard walls** (see above). Soft walls are an experiment — if they fail in practice, the architecture supports partial roll-back per agent.
4. **Check the master's review of the agent's work.** The review step is now the primary quality gate.

## Historical notes (v0.4.0 → v0.4.1 era)

The v0.4.0 release added broader permissions (each specialist can write to its own `agents_manager/<role>/**`, all agents can write anywhere in `share/**`). v0.4.1 added:

- Belt-and-suspenders: every writable path in BOTH `edit` and `write`
- Bash prefix globs (both bare and arg forms)
- 5-check Phase 0 preflight in master
- 3-retry task() protocol
- Specialist "If tasks/<id>.md missing" fallback
- ESCALATE wording in master When-blocked

The v0.4.1 CHANGELOG entry, the v0.4.1 commit (`8a999f1`), and the original `docs/PERMISSIONS.md` content are preserved in git history if you want to see the full evolution.

## History

- **v0.5.0** (2026-06-28): Soft-wall architecture. All 5 agents have `permission: "allow"`. Permission layer is unused. This document rewritten.
- **v0.4.1** (2026-06-28): Discovered OpenCode behavior (write/edit dual-allow, bash exact-match, silent task cancel) + workarounds. Hard walls with belt-and-suspenders.
- **v0.4.0** (2026-06-28): Initial permission rewrite with broader `share/**` + own-folder writes. Hard walls.
