# assets/README.md

> Listed assets for the `docs-site` template. Entries below match
> `MANIFEST.txt` line-for-line; verify.sh T5 fails if any drift.

This file is the human-readable companion to `MANIFEST.txt` — it adds a one-line
description of each asset's purpose. The machine check reads the manifest; humans
read this. If you add an asset, add it to BOTH files.

## Conventions

- One asset per line in `MANIFEST.txt`.
- Paths are relative to the template root (`templates/docs-site/`).
- Comments start with `#` and are skipped by verify.sh.
- No glob; every entry is an explicit path.

## See also

- `../AUTHORING.md` Rule 5 — MANIFEST may reference only existing files.
- `../tests/verify.sh` T5 — the verifier.
