# tests/

> Every grep-testable claim in `INDEX.md` + `00-readme-first.md` becomes a
> test in `verify.sh`. See `../../AUTHORING.md` Rule 4.

Run from the template root:

```bash
bash tests/verify.sh
```

Exit 0 confirms your changes did not break the skeleton's grep-testable
contracts. Exit non-zero lists the first failure; fix and re-run before
opening any PR.
