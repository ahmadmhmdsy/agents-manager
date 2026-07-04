# assets/

> Per `../../AUTHORING.md` Rule 5: every line in `MANIFEST.txt` MUST resolve
> in the working tree.

`MANIFEST.txt` is the canonical source of truth for what ships with this
template. Verify-list semantics:

- One path per line, repo-root-relative.
- Whole-line comments (`#`) and blank lines are skipped by `tests/verify.sh`.
- Inline comments are allowed but the path portion must resolve.

`manifest.schema.json` is reserved for build-time manifests (e.g., a runtime
data-shape manifest at Branch B). v0.1.0 does not ship one; add when a
non-trivial data shape forces it.
