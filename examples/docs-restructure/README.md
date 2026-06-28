# Example: docs-restructure

Demonstrates the agents-manager pipeline on pure markdown work — no code, no tests.

## User task
Move and split `api.md` into `docs/api/`. See [`user-task.md`](./user-task.md).

## Layout
```
docs-restructure/
├── README.md
├── user-task.md
├── original/
│   ├── README.md           ← links to api.md
│   ├── api.md              ← all 4 endpoints in one file
│   └── CONTRIBUTING.md
└── expected-output/
    ├── README.md           ← links to docs/api/README.md
    ├── CONTRIBUTING.md     ← unchanged
    └── docs/
        └── api/
            ├── README.md   ← index linking to users.md + products.md
            ├── users.md    ← 3 user endpoints
            └── products.md ← 1 product endpoint
```

## What this example demonstrates
- **Pipeline works without Phase 3 (coder) modifying source code.** am-coder's "Files expected" list is all `.md` files.
- **No test command** — am-coder marks `no test command found` and proceeds (per plan-critical-start rule).
- **Review still works** — am-review checks for broken links, missing files, content parity (no endpoints lost in the split).
- **Pure refactor task** — no new logic, no new deps. Risk = high (easy to lose content); reward = clear structure.

## Replay
```bash
cd examples/docs-restructure
# In OpenCode: "Implement user-task.md against the project in original/"
```
