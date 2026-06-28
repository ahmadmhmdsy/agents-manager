# Example: node-markdown-linter

Demonstrates the full agents-manager pipeline on a small Node.js project.

## What the user asked
See [`user-task.md`](./user-task.md). Add a `no-consecutive-h1` rule to a tiny markdown linter.

## Layout

```
node-markdown-linter/
├── README.md                 ← this file
├── user-task.md              ← the original user request (verbatim)
├── original/                 ← starting state of the project
│   ├── package.json
│   ├── README.md
│   ├── src/
│   │   ├── linter.js
│   │   └── rules.js          ← no-trailing-h1 only
│   ├── test/
│   │   └── linter.test.js    ← 2 tests
│   └── examples/
│       └── sample.md
├── share/                    ← pipeline artifacts (bus at project root)
│   ├── handoffs/
│   │   └── 00_user_task.md
│   ├── notes/
│   │   ├── 01_research_T-2026-06-28-001.md
│   │   ├── 02_plan_high_T-2026-06-28-001.md
│   │   ├── 02_plan_phases_T-2026-06-28-001.md
│   │   └── 03_coder_summary_T-2026-06-28-001_phase-1.md
│   └── reports/
│       └── 04_review_T-2026-06-28-001_phase-1.md
├── tasks/
│   └── T-2026-06-28-001.md
└── expected-output/          ← files after the pipeline ran
    ├── src/rules.js          ← with no-consecutive-h1 appended
    └── test/linter.test.js   ← with 3 new tests
```

## Pipeline trace

| Phase | Agent | Output | Verdict |
|---|---|---|---|
| 0 | master | Captures task into `share/handoffs/00_user_task.md` | — |
| 1 | am-research | `share/notes/01_research_*.md` — finds 3 risks, feasibility GREEN | — |
| 2 | am-planning | `share/notes/02_plan_high_*.md` + `02_plan_phases_*.md` + tasks row | self-score 4.75/5 |
| 3 | am-coder | Modifies `src/rules.js` + `test/linter.test.js`, writes `03_coder_summary_*.md` | READY_FOR_REVIEW |
| 4 | am-review | Writes `04_review_*.md`, runs `npm test` (5/5 passing) | PASS |

## Replay

To replay this example against a real agents-manager installation:

```bash
# 1. Install agents-manager into this example directory (or run master from here)
cd examples/node-markdown-linter

# 2. Point master at the user task (in OpenCode):
#    "Implement the request in user-task.md against the project in original/"
#    Master will spawn am-research → am-planning → am-coder → am-review in sequence.

# 3. Compare actual pipeline artifacts (in share/ + tasks/) to the expected ones
#    committed in this example. They should match.
```

## What this example demonstrates

1. **Phase boundaries are clean** — each agent writes exactly one artifact.
2. **Bus is at project root** — `share/` and `tasks/` live alongside `original/` and `expected-output/`.
3. **Per-task verdicts are mandatory** — review report has one row per task.
4. **Self-critique is in every artifact** — research, plan, coder summary, review all end with self-critique.
5. **Status signals work** — coder returned `READY_FOR_REVIEW: true`; review returned `Overall verdict: PASS`.
