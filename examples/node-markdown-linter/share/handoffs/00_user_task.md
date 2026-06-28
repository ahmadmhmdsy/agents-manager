# User task capture — T-2026-06-28-001

Captured by master from: `examples/node-markdown-linter/user-task.md`

## Verbatim user request
> Add a rule that flags an H1 (`# ...`) followed immediately by another H1 (i.e., two consecutive `# ` lines with no content between them).
>
> The rule name should be `no-consecutive-h1`. It should report findings with `line` and `col` pointing at the second H1, and a clear message. Add tests under `test/linter.test.js`. Update `src/rules.js` to register the rule.

## Master notes
- Target project: `examples/node-markdown-linter/` (Node.js, test runner: `node --test`)
- Scope: ~30 lines of code, 1 file modified, 1 test file extended
- Estimated complexity: low — clear spec, existing pattern (no-trailing-h1) to copy from
- Should we brainstorm? No — the request is concrete with explicit acceptance criteria.
- Phase 5 enabled: false (this is a demo, not a feature branch)
