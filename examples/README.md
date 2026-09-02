# Examples

Eight worked examples demonstrating the agents-manager pipeline end-to-end: three code-pipeline + five design-pipeline (v0.9.0+).

| # | Example | Stack | Demonstrates |
|---|---|---|---|
| 1 | [`node-markdown-linter/`](./node-markdown-linter/) | Node.js + `node --test` | Full pipeline: research → plan → code → review on a real source change with tests. Most detailed example. |
| 2 | [`python-csv-summarizer/`](./python-csv-summarizer/) | Python + pytest | TDD via failing-test-first (pytest loop). Compact. |
| 3 | [`docs-restructure/`](./docs-restructure/) | Markdown only | Pipeline without code/test edits. Pure refactor. |
| 4 | [`design-onboarding/`](./design-onboarding/) | am-design v1 | Fitness app, 2-screen mobile onboarding flow. |
| 5 | [`design-brand-identity/`](./design-brand-identity/) | am-design v1 | Atlas coffee roastery, full brand system + copy deck. |
| 6 | [`design-responsive-web/`](./design-responsive-web/) | am-design v1 | Lumio habit tracker, 3 breakpoints (mobile/tablet/desktop). |
| 7 | [`design-audit/`](./design-audit/) | am-design v2 | Stride fitness app, 20 findings + severity matrix + remediation plan. |
| 8 | [`design-casestudy-quran/`](./design-casestudy-quran/) | am-design retrospective | Multi-theme, multi-locale Quran app design system built before am-design was formalized. Lessons captured in `lessons.md`. |

## How to read these

Each example has:
- `README.md` — what the example demonstrates + how to replay
- `user-task.md` — the verbatim user request
- `original/` — the project before agents-manager ran (where applicable)
- `share/` + `tasks/` — the bus artifacts (only in example 1; examples 2–8 inline the key excerpts in their README)
- `expected-output/` — the project after the pipeline ran

## How to replay

For any example:

```bash
cd examples/<name>
# In OpenCode, with agents-manager installed:
# "Implement the request in user-task.md against the project in original/"
```

The master agent will spawn `am-research` → `am-planning` → `am-coder` → `am-review` in sequence and write artifacts to `share/` and `tasks/`. For design examples, `am-design` runs in place of `am-coder` (Phase 3 dispatch differs).

## Why only example 1 has full `share/` artifacts?

Example 1 ships the complete set of pipeline artifacts because it's the most detailed demo — it shows what every phase produces. Examples 2–8 are compact; they describe what each phase produced in their README rather than committing every artifact.

This keeps the repo small while still demonstrating variety. If you want to see what the missing artifacts would look like for examples 2–8, run them yourself against the real pipeline.

## Repo-root demo

The `cinematic-landing-kit-demo/` directory at the repo root is a v0.12.0 worked example (1133-line single-file HTML rendering all 5 cinematic-landing hard rules). It lives outside `examples/` because it doubles as the runtime exemplar + source-of-truth for `templates/cinematic-landing/skeleton/`. See the v0.12.0 CHANGELOG entry.
