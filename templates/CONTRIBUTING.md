# Contributing — templates/

> How to add a new template, fix a bug in an existing one, add a memory file,
> or bump the authoring standard.

**Read first.** `AUTHORING.md` is the rulebook for everything in this
directory. This file is the discoverable entry point — read the section that
matches your intent, then click through to the rulebook.

## I want to add a new template

1. **Read `AUTHORING.md`** end-to-end. Rules 1–8 + acceptance checklist are
   binding for every template under `templates/`.
2. **Copy the starter.** `cp -r _blank/ <your-template-name>/` from the
   `templates/` root. The starter ships every required file as a placeholder
   pointing back at `AUTHORING.md`.
3. **Follow the "For authors" recipe** in `AUTHORING.md` — 9 steps, each
   with a one-line trace from the cinematic-landing exemplar. Do not skip
   the worked-example step (Step 2); every template ships with at least one.
4. **Tick the Rule 8 acceptance checklist** before opening the PR:
   - INDEX.md exists with every key convention
   - All greppable claims in 00-readme-first.md pass `tests/verify.sh`
   - Every memory file's H1 number matches its filename prefix
   - Filenames are monotonic
   - Every line of `assets/MANIFEST.txt` resolves in the working tree
   - Skeleton obeys every hard rule in `memory/`
   - decision-log.md has at least one entry per phase
   - At least one worked example + abstract recipe
   - Reduced-motion path tested manually
   - a11y floor clean
   - No duplicated token tables
   - Multi-locale (if applicable): `locales/` exists with non-default script
5. **Open a PR.** Title: `templates(<name>): v0.1.0 initial cut`. The
   reviewer is the final tick on the Rule 8 checklist.

## I want to fix a bug in an existing template

1. **Open an issue** describing the symptom + which file(s) reproduce it.
   Reference the memory file's hard rule the skeleton violates (or the
   index/test that catches it).
2. **Propose the fix as a PR.** Include:
   - The skeleton / memory / verify.sh change.
   - A `tests/verify.sh` test that fails before your fix and passes after.
   - A line in `decision-log.md` if the fix changes a hard rule.
3. **Run `bash tests/verify.sh` locally** before review — exit 0 confirms
   your fix didn't break other grep-testable claims.
4. **Cross-check** with `INDEX.md`; if your fix changes a convention
   surfaced there, INDEX.md updates in the same commit (per
   `AUTHORING.md §For maintainers` rule 2).

## I want to add a memory file to an existing template

1. **Identify the next monotonic number.** Run `ls memory/ | sort | tail -1`
   in the template's root. The next file is `<next-num>-<topic>-<role>.md`.
   Do **not** insert between existing numbers — Rule 3 forbids it.
2. **Add the file** with a trigger-line H1:
   ```
   # NN · <topic> — USE THIS WHEN: <imperative one-liner>
   ```
   Format per `AUTHORING.md` Rule 6.
3. **Update `INDEX.md`** to surface the new concern (Rule 8 acceptance).
4. **Add a `tests/verify.sh` test** if the file introduces a hard rule
   (the test greps for the rule's clause in `skeleton/`).
5. **Open a PR.** Title: `templates(<name>): memory: NN-<topic>`.

## I want to bump the authoring standard

1. **Open a PR against `AUTHORING.md`.** State the rule change + rationale.
2. **Follow the Versioning section** at the bottom of `AUTHORING.md`:
   - **Patch (1.0.x)** — typo fixes, verify.sh additions, INDEX clarifications.
   - **Minor (1.x)** — new rules, new sections, new companion files.
   - **Major (x.0)** — renamed rules, retired rules, schema changes.
3. **List affected templates.** Bump requires every template to adopt the
   change. Cite the path each template must take to migrate.
4. **Update `templates/AUTHORING.md` frontmatter** (`version:` line) +
   add an entry to the repo's `CHANGELOG.md`.

## Decision disputes

If you disagree with a rule:

1. **Open a PR citing the rule + affected file(s)** in the rulebook or a
   template's memory.
2. **Propose the change with rationale.** Include a **worked counter-example**
   that demonstrates the rule produces a worse outcome for that case.
3. **Decision-log entry.** All rule changes flow through the affected
   template's `decision-log.md` with a `P<n>` fix reference.

If your dispute is about the standard's overall direction (not a specific
rule), open an issue rather than a PR — rules change by consensus.

## Local sanity

Before opening any PR, run from the template root:

```bash
bash tests/verify.sh
```

Exit 0 means your changes do not break grep-testable claims. Exit non-zero
lists the first failure; fix and re-run.
