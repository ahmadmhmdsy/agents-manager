# Examples

Three worked examples demonstrating the agents-manager pipeline end-to-end.

| # | Example | Stack | Demonstrates |
|---|---|---|---|
| 1 | [`node-markdown-linter/`](./node-markdown-linter/) | Node.js + `node --test` | Full pipeline: research → plan → code → review on a real source change with tests. Most detailed example. |
| 2 | [`python-csv-summarizer/`](./python-csv-summarizer/) | Python + pytest | TDD via failing-test-first (pytest loop). Compact. |
| 3 | [`docs-restructure/`](./docs-restructure/) | Markdown only | Pipeline without code/test edits. Pure refactor. |

## How to read these

Each example has:
- `README.md` — what the example demonstrates + how to replay
- `user-task.md` — the verbatim user request
- `original/` — the project before agents-manager ran
- `share/` + `tasks/` — the bus artifacts (only in example 1; examples 2 & 3 inline the key excerpts in their README)
- `expected-output/` — the project after the pipeline ran

## How to replay

For any example:

```bash
cd examples/<name>
# In OpenCode, with agents-manager installed:
# "Implement the request in user-task.md against the project in original/"
```

The master agent will spawn `am-research` → `am-planning` → `am-coder` → `am-review` in sequence and write artifacts to `share/` and `tasks/`.

## Why only example 1 has full `share/` artifacts?

Example 1 ships the complete set of pipeline artifacts because it's the most detailed demo — it shows what every phase produces. Examples 2 and 3 are compact; they describe what each phase produced in their README rather than committing every artifact.

This keeps the repo small while still demonstrating variety. If you want to see what the missing artifacts would look like for examples 2 & 3, run them yourself against the real pipeline.
