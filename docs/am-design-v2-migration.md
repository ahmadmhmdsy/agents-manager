# am-design v2.0 — Migrating from v0.8.0

> **Status:** am-design v2.0 is **additive** to agents-manager v0.8.0. No breaking changes to existing 5 agents (master, am-research, am-planning, am-coder, am-review). am-design is the 6th agent and the 5th specialist.

This guide covers two scenarios:
- **Scenario A** — Owner has v0.8.0 installed and wants to add am-design v2.0 (this PR).
- **Scenario B** — Owner is reviewing the PR for merging.

---

## Scenario A — Applying the changeset

### Prerequisites

1. **You have agents-manager v0.8.0 installed.** If you have v0.7.0 or earlier, first upgrade to v0.8.0 via `bash bin/update.sh` (Unix) or `.\bin\update.ps1` (PowerShell).
2. **Working tree is clean.** `git status` shows nothing to commit.
3. **Branch created off master.** `git checkout -b feature/am-design-v2 master`.
4. **Disk space ≥ 5 MB** for the changeset + extracted content.

### Apply steps

```bash
# 1. Extract the changeset
unzip agents-manager-am-design-v2.0.zip
cd changeset-v2.0

# 2. Overwrite modified controller files
cp 04-changes/opencode.jsonc               ../opencode.jsonc
cp 04-changes/CLAUDE.md                    ../CLAUDE.md
cp 04-changes/README.md                    ../README.md
cp 04-changes/agents_manager-SKILL.md      ../agents_manager/SKILL.md

# 3. Add the am-design agent (new files)
cp -r 05-new-files/agents_manager/design/* ../agents_manager/design/

# 4. Add the 4 worked examples
mkdir -p ../examples
cp -r 05-new-files/examples/design-onboarding       ../examples/
cp -r 05-new-files/examples/design-brand-identity   ../examples/
cp -r 05-new-files/examples/design-responsive-web   ../examples/
cp -r 05-new-files/examples/design-audit            ../examples/
cp -r 05-new-files/examples/design-casestudy-quran  ../examples/

# 5. Add the 4 new docs to docs/
cp 03-docs/am-design-v2-migration.md   ../docs/
cp 03-docs/am-design-v2-decisions.md   ../docs/
cp 03-docs/am-design-v2-testing.md     ../docs/

# 6. Add the lint helper script
cp bin/lint-design.sh                 ../bin/

# 7. Append the v0.9.0 CHANGELOG entry
cat 02-CHANGELOG_entry.md >> ../agents_manager/CHANGELOG.md
```

### Commit sequence (9 commits)

Use the messages in `06-commit-msgs.txt`. Suggested order:

```bash
cd ..
git add agents_manager/design/
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 01: am-design base

git add agents_manager/design/SKILL.md
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 02: SKILL.md v2

git add agents_manager/design/rules.md
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 03: rules.md v2

git add agents_manager/design/resources/output-skeleton.md
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 04: output-skeleton

git add agents_manager/design/resources/research-template.md \
        agents_manager/design/resources/brand-template.md \
        agents_manager/design/resources/audit-template.md \
        agents_manager/design/resources/copy-template.md \
        agents_manager/design/resources/motion-spec-template.md \
        agents_manager/design/resources/icon-template.svg \
        agents_manager/design/resources/multi-locale-checklist.md
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 05: new resources

git add agents_manager/design/resources/mockup-templates/
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 06: mockup templates

git add agents_manager/design/resources/novel-abstractions-seed-list.md
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 07: novel-abstractions

git add examples/
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 08: examples

git add opencode.jsonc CLAUDE.md README.md \
        agents_manager/SKILL.md \
        agents_manager/CHANGELOG.md \
        docs/am-design-v2-*.md \
        bin/lint-design.sh
git commit -F ../changeset-v2.0/06-commit-msgs.txt   # 09: config + docs + lint
```

**Note:** `06-commit-msgs.txt` contains all 9 messages separated by `=== COMMIT N ===`. Use `sed -n '/=== COMMIT K ===/,/=== COMMIT K+1 ===/p'` (or your shell's equivalent) to extract the K-th message.

### Validation

```bash
# Unix
bash bin/check.sh .

# PowerShell
.\bin\check.ps1 .
```

Expected: **PASS=N FAIL=0** where N matches the v0.8.0 baseline (6 at last check). The am-design agent and new docs do not require new controller paths beyond what `bin/check.sh` already validates.

Optional lint pass on the worked examples:

```bash
bash bin/lint-design.sh examples/
```

Should report no inline hex violations in `.html` files under `examples/`.

### Push

```bash
git push origin feature/am-design-v2
gh pr create --base master --title "feat(am-design): v2.0 — 12 modes, 6 mediums, audience-aware handoff" --body-file changeset-v2.0/01-PR_DESCRIPTION.md
```

---

## Scenario B — Reviewing the PR

### Read order

1. **`01-PR_DESCRIPTION.md`** — summary, what changed, what to verify.
2. **`docs/am-design-v2-decisions.md`** — ADR-style doc: why these design choices.
3. **`docs/am-design-v2-migration.md`** — this file.
4. **`docs/am-design-v2-testing.md`** — 5 tests to run before approving.
5. **`agents_manager/design/SKILL.md`** — the agent definition.
6. **`agents_manager/design/rules.md`** — standing rules.
7. **`agents_manager/design/resources/output-skeleton.md`** — output folder structure.
8. **`agents_manager/design/resources/novel-abstractions-seed-list.md`** — 11 T + 12 R patterns.
9. **One example** (`examples/design-onboarding/` or `examples/design-brand-identity/`) — see the contract in action.
10. **`agents_manager/CHANGELOG.md`** — confirm v0.9.0 entry is appended correctly.

### Acceptance criteria

- [ ] All 9 commits applied; `git log master..HEAD --oneline` shows the expected series.
- [ ] `bin/check.sh .` returns PASS.
- [ ] `agents_manager/design/SKILL.md` reads as a coherent 12-mode agent (not 5-mode patched into 12).
- [ ] At least one example follows the new `00_brief.md` → mode folders → `99_handoff.md` structure.
- [ ] `99_handoff.md` in each example ends with a STATUS signal.
- [ ] No file under `examples/` references `src/` or production code.
- [ ] `opencode.jsonc` am-design prompt mentions all 12 modes and the 7-question discovery.
- [ ] `agents_manager/CHANGELOG.md` has a v0.9.0 entry that matches `02-CHANGELOG_entry.md`.

---

## Breaking changes

**None.** am-design v2.0 is purely additive. Existing dispatches to master, am-research, am-planning, am-coder, am-review work unchanged. Master only spawns am-design when:

- The task touches visible UI, AND
- The user has not yet locked a visual direction.

No existing dispatch path is altered.

## Safe rollback

```bash
git checkout master
git branch -D feature/am-design-v2
```

The `feature/am-design-v2` branch is independent — discarding it does not affect master.

## Re-applying to a fresh checkout

The changeset is idempotent (file copies overwrite). If you blow away the working tree and re-apply, you get the same result. To re-apply on top of a newer upstream master, rebase carefully:

```bash
git fetch origin
git rebase origin/master
# Resolve any conflicts (most likely in opencode.jsonc or README.md)
bin/check.sh .
```