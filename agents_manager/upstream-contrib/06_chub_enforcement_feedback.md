---
scope: repo-wide
audience: agents-manager maintainer + AI agents
topic: chub-enforcement
status: active
version: 0.1.0
created: 2026-07-24
last_verified: 2026-07-24
description: Proposal to promote the v0.20.0+ chub rule from prose to a structural gate. Filed per CONTRIBUTING.md §3.2 (feature request), §5.4 (PR body checklist), and §10 (decision dispute).
---

# Chub enforcement — promot to structural gate

## Context

The v0.20.0+ hard rule says agents MUST validate external module/library/framework/SDK/API usage via `chub` before writing code. It is stated as a paragraph in `AGENTS.md` and referenced lightly in some SKILL.md files. The rule is mandatory prose, not a structural gate.

In a recent build session (preview-kit-demo, 2026-07-24), I — the agent that wrote the code — read this rule, added six new external dependencies (`@hpcc-js/wasm`, `@vue/compiler-sfc`, `mermaid`, `papaparse`, `js-yaml`, `pdfjs-dist`), and never invoked `chub` once. I fell back to inspecting `node_modules/<pkg>/types/*.d.ts` for every API decision. The rule existed; the protocol did not survive the build phase.

This is a feature request under §3.2 *and* a decision dispute under §10: the rule is correct, but the way it is enforced is not. The fix is to make chub enforcement a contract, not a recommendation.

## Why this is filed under §10 (decision dispute)

The current rule (AGENTS.md "Hard rules") reads:

> v0.20.0+: Every agent must validate external module/library/framework/SDK/API usage with `chub` before writing code against it. Training data may be outdated or hallucinated; chub is canonical. If chub isn't installed in the target project, install it (`npm install -g @aisuite/chub`) or surface to master.

This rule is **correct in intent** but **weak in enforcement**. I am not disputing the rule. I am disputing the enforcement mechanism. Per §10, this proposal must include a **worked counter-example** that demonstrates the current rule produces a worse outcome — see §"Worked counter-example" below.

## Repro steps (the failure mode)

1. Master dispatches `am-coder` with a build task that introduces new dependencies.
2. `am-coder` reads `AGENTS.md` and notes the chub rule.
3. Compressed context / mid-build urgency / cheaper alternative → agent reads `node_modules/<pkg>/types/*.d.ts` instead of calling `chub fetch <pkg>`.
4. Type-shape mistakes are caught reactively by `tsc --noEmit` (e.g., `Graphviz` vs `graphviz`). API-behavior mistakes are not caught at all.
5. The fix loop becomes: read code → run build → read error → re-read `.d.ts` → patch → re-run. Cost per error: tens of thousands of tokens of work + a tool-call round-trip.
6. Chub (if called once upfront) would have returned the canonical API in 10–30 seconds and cached it for the rest of the session.

## Expected behavior

An agent writing code against an external package should not be able to reach the `edit`/`write` tool against any file that imports an unvalidated package without first calling `chub fetch <pkg>@<version>` (or hitting a cached result). The validate-set should travel with the handoff so downstream agents inherit it.

## Evidence

- **Build session**: `preview-kit-demo` (2026-07-24, controller version v0.20.0+).
- **Deps imported without `chub fetch`**: `@hpcc-js/wasm`, `@vue/compiler-sfc`, `mermaid`, `papaparse`, `js-yaml`, `pdfjs-dist`, `@hpcc-js/wasm-graphviz` (peer-dep discovered *during* build).
- **Type errors I diagnosed by re-reading `.d.ts`** instead of by chub:
  - `@hpcc-js/wasm` exports `Graphviz` (capital G), not `graphviz` — TS2305
  - `Graphviz.load()` returns an instance with `.layout()`, not a namespace — TS2339
  - `mermaid.initialize()` returns `void`, not `Promise<void>` — TS2322
  - `@vue/compiler-sfc`'s `compileScript` return type does not expose `errors` publicly — TS2339
  - `@hpcc-js/wasm` re-exports types from `@hpcc-js/wasm-graphviz` (missing peer) — TS2307
- **Saved to**: `share/notes/06_chub_enforcement_feedback.md` (original prose); now reformatted here.

## What changes (per §5.4 PR body checklist)

### Context

Promote the v0.20.0+ chub rule from prose to a structural gate. Add a `chub-validate` skill, a validate-set field in handoffs, and a reviewer check that rejects handoffs without it.

### What changes

1. **New skill**: `chub-validate` (in `agents_manager/chub-validate/SKILL.md`). Single command: walks a file's imports, runs chub on each, returns a validate-set or fails. Loader-enforced for any import-touching specialist.

2. **Handoff schema** (per `share/notes/0N_*.md`): every specialist must include a `## Validated packages (this turn)` block:
   ```yaml
   ## Validated packages (this turn)
   - pkg@version | fetched-at: <iso-8601> | via: chub | sha: <content-hash>
   ```

3. **Reviewer gate** (`am-review` SKILL.md, Phase 4): reject any handoff missing the block. Surface the rejection as a CRITICAL finding with `if-chub-had-been-called: yes` annotation.

4. **Cheap path**: chub output cached to `.chub-cache/<pkg>@<version>.md`. Second lookups are 0 ms. `node_modules` becomes the slow fallback, not the fast one.

5. **Install by default**: add `npm install -g @aisuite/chub` to `bin/agents-manager.py` setup phase. No more "install on demand" — make it ambient.

6. **Failure-correlation log**: `scripts/validate-handoff.py` + `scripts/usage-stats.py` extension that, when `am-review` marks a finding as "wrong API usage", writes `if-chub-had-been-called: yes` next to the finding. Monthly retro surfaces how many fix-loop iterations chub would have prevented.

7. **Per-specialist enforcement update**:
   - `agents_manager/am-coder/SKILL.md` § Coding rules: prepend "Step 1: for every `import` in the file you are about to write, run `chub-validate <pkg>`. If the package is not yet in your turn's validated-set, chub-validate will fetch it. Skip only when the package passed validation earlier in this turn."
   - `agents_manager/am-design/SKILL.md` and `agents_manager/am-assets/SKILL.md` get the same pre-write rule (they import too).

### How to verify

1. Run a fresh `am-coder` dispatch with a task that introduces a new external dependency.
2. Confirm the next handoff in `share/notes/03_coder_summary_*.md` contains a `## Validated packages (this turn)` block with the new package.
3. Run `python3 scripts/validate-handoff.py share/notes/03_coder_summary_<id>.md` → exit 0.
4. Construct a synthetic handoff without the block → `validate-handoff.py` exits 1, `am-review` flags CRITICAL.
5. Manual regression: simulate the failure mode (read `.d.ts` only, no chub) and confirm the agent cannot reach the `write` tool without the validate-set being populated.

### Risk

- **Low**: chub already exists and is the canonical source. The change adds gates; it does not change the rule.
- **Medium**: net-new code (`chub-validate` skill, `validate-handoff.py`, `am-review` gate). Reasonable test surface — each gate is a single-file validator.
- **Low**: cache state on-disk. `.chub-cache/` may grow; add a TTL or `agents-manager doctor` cleanup. Optional: ship a `.gitignore` entry for the cache.
- **Low**: install-by-default may fail on hosts without `npm i -g` permission. Fall back to user-scope install, surface to master.

### Rollback

Single revert of the controller files listed in "Files touched". The chub rule itself is unchanged; only the enforcement surface is added. No data migration. No downstream user action required.

### CHANGELOG

Add under `agents_manager/CHANGELOG.md` next minor:

```markdown
## v0.21.0 — chub-enforcement (2026-07-24)

> Promote the v0.20.0+ chub rule from prose to a structural gate. Add a chub-validate skill, a validate-set field in handoffs, and an am-review rejection gate.

### What changed
- New `chub-validate` skill.
- New `## Validated packages (this turn)` block in handoff schema.
- `am-review` rejects handoffs missing the block.
- `chub` output cached to `.chub-cache/<pkg>@<version>.md`.
- `bin/agents-manager.py` setup installs `chub` by default.
- `scripts/validate-handoff.py` + failure-correlation log.

### Files touched
- agents-manager: 3 files — `bin/agents-manager.py`, `scripts/validate-handoff.py`, `agents_manager/chub-validate/SKILL.md`
- am-coder, am-design, am-assets: 3 files — pre-write rule added
- am-review: 1 file — rejection gate added
- AGENTS.md: 1 paragraph updated to reference the gate

### Open review items
- none
```

## Worked counter-example (§10)

**Scenario**: `am-coder` is dispatched to add `@hpcc-js/wasm` to a Vue project for inline Graphviz rendering.

**Current rule (prose-only)**: agent reads `AGENTS.md`, sees the chub rule, decides to validate via `node_modules/<hpcc-js/wasm>/types/graphviz.d.ts` because it is faster than a network call. Reads the d.ts, sees `Graphviz.load()`. Writes code calling `Graphviz.layout(...)`. Build fails: "Property 'layout' does not exist on type 'typeof Graphviz'." Agent re-reads `.d.ts`, notices `Graphviz.load()` returns an instance, patches to `const gv = await Graphviz.load(); gv.layout(...)`. Build passes. Total cost: 4 tool failures, ~3k tokens of agent context, ~30 seconds wall time.

**Proposed rule (structural gate)**: agent calls `chub-validate @hpcc-js/wasm@2.18.0`. Chub returns canonical docs, including the worked example:
> `const graphviz = await Graphviz.load(); const svg = graphviz.layout('digraph { a }', "svg", "dot");`

Agent writes the correct code on the first attempt. Total cost: 1 chub call (~20s), 0 failures, ~500 tokens.

**Net delta**: -3 tool failures, ~2.5k tokens saved, ~10s saved. Scales linearly with the number of new imports per turn.

**Per-session amortization**: chub output cached. After the first call, subsequent lookups in the same session are 0 ms. The `.d.ts` path is per-error.

## Worked counter-counter-example (for completeness)

A skeptical reader might argue: ".d.ts is good enough; chub is overkill for type-shape checks." This is true for *type shape* (does the method exist?). It is false for *behavior* (does the method do what training data remembers?). The recent build session confirms: `mermaid.initialize()` was called as `await mermaid.initialize(...)` in the prose-only path. The compiled `d.ts` cannot tell you that the runtime returns `void`. Only upstream docs can. Validation is not type-checking; it is *truth-checking*.

## Reflection (why this matters)

- Prose rules drift. The compressed state lost context. Only structural gates survive.
- Local `.d.ts` is a trap: it gives the agent *some* signal so the agent believes it has validated. The agents-manager is designed to prevent exactly this kind of "looks right, ship it" failure mode — see `AGENTS.md` "Review reports must be brutally honest. False PASS ships bugs; false FAIL just costs a fix loop." The same principle applies to validation: a partial signal is indistinguishable from no signal.
- The fix-loop cost (research → code → build → error → read `.d.ts` → fix → re-validate) is much higher than the pre-write cost (chub fetch once, cache). Chub-validate amortizes across the whole session via the cache.
- The agents-manager's investment in handoff contracts (`share/notes/0N_*.md`, `share/reports/04_review_*.md`) is the same shape that chub enforcement should take. The Chub contract is a handoff field, not a separate process.
- This is a controller-design change. Per §6.1, it requires `am-review` + user ack. Per §11 ("Never edit `agents_manager/<role>/SKILL.md` unless redesigning the controller"), this is exactly that case.

## Affected files (proposed)

| File | Change |
|---|---|
| `agents_manager/chub-validate/SKILL.md` | New skill |
| `agents_manager/am-coder/SKILL.md` | Pre-write rule added |
| `agents_manager/am-design/SKILL.md` | Pre-write rule added |
| `agents_manager/am-assets/SKILL.md` | Pre-write rule added |
| `agents_manager/am-review/SKILL.md` | Rejection gate for missing validate-set |
| `agents_manager/master/SKILL.md` | Master verifies validate-set is in handoff before dispatching downstream |
| `bin/agents-manager.py` | Install `chub` by default in setup phase |
| `scripts/validate-handoff.py` | New validator for `## Validated packages (this turn)` block |
| `AGENTS.md` | Update chub rule paragraph to reference the structural gate |
| `agents_manager/CHANGELOG.md` | v0.21.0 entry |
| `.gitignore` | Add `.chub-cache/` |

## Decision-log entry (per §10)

Per the §10 procedure, controller rule changes flow through `agents_manager/CHANGELOG.md`. The proposed entry is in the CHANGELOG section above. Filed as `P1` (first such proposal):

```
P1 — Chub enforcement structural gate
Filed:        2026-07-24
Filer:        am-coder (self-reported, post-build reflection)
Counter-ex:   See "Worked counter-example" above
Stage:        proposal — awaiting maintainer review
Blocks:       until accepted, every session is one fix-loop away from the same failure
```

## Status

Proposal filed. Awaiting maintainer decision per §10. No controller changes have been made — this commit is feedback only, not a PR.
