# OpenCode Permissions — Discovered Behavior

> **Why this file exists (v0.4.1):** A downstream project reported that several v0.4.0
> permissions and bash patterns did not behave as written. After investigation, we
> found three OpenCode behaviors not stated explicitly in the docs we read at the
> time. This document records those behaviors and how `agents-manager` works around
> them. Future agents and humans debugging permission failures should start here.

## TL;DR

| Behavior | Impact | agents-manager workaround |
|---|---|---|
| `write` tool checks **edit** permissions for new files | Paths only in `write` (not `edit`) are unreachable | Every writable path is in **both** `edit` and `write` blocks |
| Bash allow list is **exact-match on the full command string** | `cat README.md` ≠ `cat` | Bash blocks list both bare form AND prefix-glob form (`cat` and `cat *`) |
| `task()` cancellation is silent — no diagnostic, no retry signal | Master had to discover this by losing work | Master prompt includes Phase 0 preflight + explicit retry protocol |

---

## 1. The `write` tool checks `edit` permissions for new files

**Symptom (from real-world failure):** A path was listed only in the agent's `write` block. The write tool rejected it.

**Discovery:** OpenCode's write tool requires edit permission for creating new files. Path-only-in-write is unreachable for file creation. Existing files may still be writable through `write` alone — the behavior is per-file.

**Workaround in `agents-manager`:** Every writable path is duplicated in BOTH the `edit` and `write` blocks. For example, master's permission block has:

```jsonc
"edit":  { "*": "deny", "agents_manager/SKILL.md": "allow", "tasks/**": "allow", "share/**": "allow", "share/notes/99_decisions.md": "allow" },
"write": { "*": "deny", "agents_manager/SKILL.md": "allow", "tasks/**": "allow", "share/**": "allow", "share/notes/99_decisions.md": "allow" }
```

The duplication is intentional and belt-and-suspenders. If OpenCode's write semantics change in a future version, the redundant allow still covers us.

**Why we didn't notice before:** In our internal testing the master always wrote to paths that were already in both blocks (`share/handoffs/00_user_task.md`, `tasks/<id>.md`). The path-matcher misconfiguration only surfaced when a downstream project tried to use `share/messages/<from>-to-<to>-<topic>.md` paths that we'd added only to `write` in v0.4.0.

---

## 2. Bash allow list is exact-match on the full command string

**Symptom (from real-world failure):** Master had `"cat": "allow"` in its bash block. `cat README.md` was blocked.

**Discovery:** OpenCode's bash permission matching is exact-match against the full command string. Glob `*` works only when written explicitly: `"cat *"` matches `cat foo`, `cat "My File"`, etc., but does NOT match bare `cat` (no space, no args). Bare `cat` would only be allowed by an explicit `"cat": "allow"` entry.

**Workaround in `agents-manager`:** Each bash allow entry appears in **both** forms:

```jsonc
"bash": {
  "*": "deny",
  "git status": "allow",  "git status *": "allow",
  "git log": "allow",     "git log *": "allow",
  "git diff": "allow",    "git diff *": "allow",
  "git show": "allow",    "git show *": "allow",
  "ls": "allow",          "ls *": "allow",
  "cat": "allow",         "cat *": "allow",
  "rg": "allow",          "rg *": "allow",
  "mkdir -p": "allow",    "mkdir -p *": "allow"
}
```

Same pattern in `am-research` and `am-review` bash blocks. `am-coder` has `bash: "allow"` so it isn't affected.

**Why we didn't notice before:** In our internal dry-runs, `git status` (bare) was the common case — that worked. The first failure was when master needed to read a specific file: `cat share/notes/01_research_T-001.md`.

---

## 3. `task()` cancellation is silent — no diagnostic, no retry signal

**Symptom (from real-world failure):** Master dispatched `am-research`; OpenCode returned "Task cancelled" with no error code, no reason, no retry guidance. Master had no way to distinguish "the sub-agent failed" from "the dispatch never started" from "OpenCode's permissions blocked the dispatch".

**Discovery:** `task()` does not currently surface failure diagnostics. The text "Task cancelled" is the only signal, and it can mean any of several failure modes.

**Workaround in `agents-manager` (two layers):**

### Layer 1 — Phase 0 preflight in master prompt

Before dispatching any specialist, master runs 5 probe checks. If any probe fails, master surfaces the failure to the user and STOPS — does not dispatch the real specialist.

1. `mkdir -p tasks share/notes` — ensure parent dirs exist
2. Write `tasks/.preflight` (probe file)
3. Write `share/notes/.preflight` (probe file)
4. `ls tasks share/notes` (bash probe)
5. `task(subagent_type="am-research", prompt="echo READY")` (dispatch probe)

After all 5 succeed, master deletes the probe files and proceeds.

### Layer 2 — Retry protocol after preflight passes

If a real dispatch (post-preflight) returns "Task cancelled":

1. Retry up to 3 times with 5-second backoff between attempts.
2. If all 3 retries fail, surface `BLOCKED: specialist <name> dispatch failed 3 times` to the user with the last error.

The combination means:
- If permissions or bash are broken, preflight catches it before any work begins.
- If a real dispatch fails mid-pipeline (a more subtle issue), retry catches transient issues and surfaces persistent ones.

---

## Path-matcher behavior — notes

These are observations from v0.4.0/v0.4.1 testing. They may be OpenCode-specific or general; we don't know which without reading more of OpenCode's source.

| Pattern | Matches | Doesn't match |
|---|---|---|
| `share/**` | `share/notes/foo.md`, `share/messages/x/y.md`, `share/anything/deep` | `sharefile/foo` (no slash) |
| `agents_manager/coder/**` | `agents_manager/coder/notes/x.md`, `agents_manager/coder/resources/build.md` | `agents_manager/coder_skills.md` (extra chars after `coder`) |
| `{a,b}` brace expansion | **Not supported.** Each path must be enumerated. | `share/{notes,reports}/**` is treated as a literal path |
| `*` (bare) | Everything | Nothing |
| `*` (in path segment) | Any chars including `/` | Empty (depends — see bash section) |
| Case sensitivity | Case-sensitive (Linux paths) | — |
| Windows-style backslashes | **Not supported.** Forward slashes only. | `share\notes\foo.md` |

For downstream projects on Windows: paths in `opencode.jsonc` use forward slashes regardless of OS. The bash/permission matcher normalizes them.

---

## What to check when permission is denied

If an agent gets "permission denied" unexpectedly:

1. **Check both `edit` AND `write` blocks.** Path only in `write`? Add to `edit`.
2. **Check bash allow list.** Is the exact command string listed? Does the version with args need a separate entry?
3. **Check the path is glob-correct.** No brace expansion. Use `**` for deep matches. Last-match-wins means explicit allows must come AFTER a broader deny.
4. **Re-read `docs/PERMISSIONS.md`.** This file is the source of truth for discovered OpenCode behavior. If the behavior here contradicts what you observe, the discrepancy is a bug — open an issue.

---

## History

- **v0.4.0** (2026-06-28): Initial permission rewrite with broader `share/**` + own-folder writes. Did NOT include the belt-and-suspenders for write/edit, bash prefix globs, or preflight. Real-world test exposed the gaps.
- **v0.4.1** (2026-06-28): This document + the three fixes (both blocks, prefix globs, preflight + retry). All discovered behaviors are now documented and worked around.
