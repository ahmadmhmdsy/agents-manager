# Example: python-csv-summarizer

Demonstrates the agents-manager pipeline on a small Python project with pytest.

## User task
Add a `mean` aggregation alongside existing `sum` and `count`. See [`user-task.md`](./user-task.md).

## Layout
```
python-csv-summarizer/
├── README.md
├── user-task.md
├── original/             ← starting state
│   ├── csv_summarizer.py
│   └── test_csv_summarizer.py
└── expected-output/      ← after pipeline
    ├── csv_summarizer.py ← mean added to summarize() + CLI
    └── test_csv_summarizer.py ← test_mean_aggregation added
```

## What the pipeline produces (compact)
- **research**: 1 risk (off-by-one in mean = sum/count when bucket empty) + 1 mitigation (`assert len(vs) > 0`).
- **plan**: 1 phase, 2 tasks. (1) Update `summarize()` + CLI choices. (2) Add `test_mean_aggregation`.
- **coder**: 2 files modified, all tests pass (`pytest` → 2 passing).
- **review**: PASS. Cites line numbers in `csv_summarizer.py:14-19` (mean block) and `test_csv_summarizer.py:14-22` (new test).

## Replay
```bash
cd examples/python-csv-summarizer
# In OpenCode: "Implement user-task.md against the project in original/"
```
