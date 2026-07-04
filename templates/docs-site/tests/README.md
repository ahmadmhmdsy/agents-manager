# docs-site/tests/README.md

> Self-check runner. See `../AUTHORING.md` Rule 4 (every README claim is
> grep-verifiable via `tests/verify.sh`).

```sh
$ bash tests/verify.sh
```

The script exits **0** on all-PASS, **non-zero** on any FAIL. Eight tests:

| # | Claim | How |
|---|---|---|
| T1 | `INDEX.md § Sections (6)` matches distinct `data-section=` tags in `skeleton/index.html` | grep + awk |
| T2 | Every distinct `data-section` value is named in `INDEX.md` | grep |
| T3 | 12 memory files, each with a `USE THIS WHEN:` trigger line | ls + grep |
| T4 | `:root` declares ≥ 14 `--token` custom properties | awk |
| T5 | Every line in `assets/MANIFEST.txt` resolves in the working tree | test -f/-d |
| T6 | `INDEX.md § Hard rules` lists exactly 5 numbered rules | awk |
| T7 | `skeleton/data.js` `PAGES` array has ≥ 3 page entries | grep |
| T8 | `INDEX.md` carries the version marker `v0.1.0` | grep |

The script auto-selects `rg` if available and falls back to `grep -E` so it
runs unchanged on Windows + macOS + Linux without ripgrep installed.

## When a test fails

| Failure | Likely cause | Fix |
|---|---|---|
| T1 count mismatch | New `data-section` added but INDEX.md § Sections (N) not bumped | Update the (N) in INDEX.md |
| T2 missing name | New section value not mentioned in INDEX.md § Sections | Add a row in INDEX.md |
| T3 trigger line | New memory file without `# NN · topic — USE THIS WHEN: ...` H1 | Add the trigger line |
| T4 token count | :root missing a `--token:` declaration | Declare each token with `--token: value;` |
| T5 unresolved path | `assets/MANIFEST.txt` line points to a file you didn't create | Either create the file or remove the line |
| T6 rule count | Index § Hard rules has <5 / >5 numbered rules | Adjust to exactly 5 |
| T7 page count | `PAGES` array lost entries | Restore the page objects |
| T8 version marker | INDEX.md missing `v0.1.0` string | Re-add the version header |

## Adding a new test

Add a new `tN()` function and call it before the summary. Stay grep-based;
no external tools beyond `rg`/`grep`/`awk`/`sed`. New test bumps the file to
match INDEX.md § Tests (next minor version).
