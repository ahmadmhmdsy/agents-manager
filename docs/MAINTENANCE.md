# Maintenance

How to maintain agents-manager across releases, including the quarterly sync with upstream `obra/superpowers` skills.

## Quarterly obra/superpowers sync

Nine skills from `obra/superpowers` are referenced by agents-manager. Upstream evolves; we need to stay current.

**Cadence:** 1st of January, April, July, October (automated reminder via `.github/workflows/obra-sync-reminder.yml`).

### Procedure

1. **Check for updates.** For each skill, visit the upstream repo or run:
   ```bash
   npx --yes skills check
   ```
   List of skills to check:
   - `dispatching-parallel-agents`
   - `subagent-driven-development`
   - `verification-before-completion`
   - `systematic-debugging`
   - `test-driven-development`
   - `requesting-code-review`
   - `writing-plans`
   - `executing-plans`
   - `brainstorming`

2. **Read the diffs.** For any updated skill:
   - Read the upstream `SKILL.md`
   - Note new iron laws, new rules, deprecated patterns
   - Compare against our integration in `agents_manager/SKILL.md` and `agents_manager/<role>/rules.md`

3. **Update overrides if needed.** Our intentional deviations are documented in `agents_manager/SKILL.md` under `## Overrides`:
   - `max_fix_loops = 3` (kept)
   - Pause for user confirmation at Phase 2 (kept)
   - Per-phase review (not per-task — kept)
   - No per-agent model selection (OpenCode limitation — kept)
   - 5-agent roster is fixed (not user-customizable — kept)

   If upstream changes conflict with these, decide: follow upstream (and update overrides section) or keep our way (and document why).

4. **Update CHANGELOG.md.** Add an entry under `## Unreleased`:
   ```markdown
   ### obra/superpowers sync — YYYY-MM-DD
   - skill-name: short description of relevant change
   - ...
   ```

5. **Tag a patch release if user-facing.** If any skill change affects our prompts, tag `v0.x.Y` and push.

### When to skip the sync

- No upstream updates → no work, just close the reminder issue.
- Upstream update is purely cosmetic (typo fix, doc tweak) → no action.

## Release cadence (suggested)

| Change scope | Bump | Example |
|---|---|---|
| New user-facing feature (new section in SKILL.md, new example) | minor | v0.1.0 → v0.2.0 |
| obra sync that changes our prompts | patch | v0.2.0 → v0.2.1 |
| Bug fix in controller / installer | patch | v0.2.0 → v0.2.1 |
| Breaking change to opencode.jsonc schema | major | v0.x.0 → v1.0.0 |

Until v1.0.0, even minor versions may include breaking changes (per the README status banner).

## Pre-release checklist

Before tagging a new version:

- [ ] All CI jobs green on master
- [ ] `agents_manager/CHANGELOG.md` updated with a `## Unreleased` entry that becomes the release notes
- [ ] `agents_manager/README.md` mentions the new version in the status banner (if changed)
- [ ] Any new file is covered by `.gitignore` rules or explicitly tracked
- [ ] If a new agent or skill was added: `bin/check.sh` updated to list it

## When upstream skills are removed

If `obra/superpowers` deprecates or removes a skill we depend on:

1. Identify which agent relies on it (see the `Source:` lines in `agents_manager/SKILL.md` and `agents_manager/<role>/rules.md`)
2. Replace with another skill or inline the relevant protocol directly
3. Document the substitution in CHANGELOG + `## Overrides` section
4. If no good replacement: remove the integration and adjust the agent's prompt accordingly

## When a downstream project needs help

- Open an issue at https://github.com/ahmadmhmdsy/agents-manager/issues
- Include: target project type, the user task, the failing phase, the share/ artifacts, the relevant error log
- Reproducing locally is preferred over vague "it doesn't work" reports
