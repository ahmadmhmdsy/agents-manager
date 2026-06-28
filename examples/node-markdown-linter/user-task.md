Add a rule that flags an H1 (`# ...`) followed immediately by another H1 (i.e., two consecutive `# ` lines with no content between them).

The rule name should be `no-consecutive-h1`. It should report findings with `line` and `col` pointing at the second H1, and a clear message. Add tests under `test/linter.test.js`. Update `src/rules.js` to register the rule.
