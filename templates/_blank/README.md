# _blank — Template starter

> Copy this folder to start a new template. The rulebook lives at
> `../AUTHORING.md` — read it first.

## Quick start

```bash
# from the templates/ folder
cp -r _blank/ <your-template-name>/
cd <your-template-name>/
# Fill in every placeholder; remove this file when done.
```

Then follow the 9-step recipe in `../AUTHORING.md §For authors`. Do NOT delete
this directory; it is the canonical starter.

## What this folder contains

Every file is a placeholder. Each one points to the rule in `../AUTHORING.md`
that governs it.

| File / folder | Rule | Status |
|---|---|---|
| `README.md` (this file) | — | stays as long as the folder is `_blank/` |
| `00-readme-first.md` | AUTHORING.md §Folder structure | placeholder |
| `INDEX.md` | Rule 8 (acceptance checklist) | placeholder |
| `decision-log.md` | §For maintainers | placeholder |
| `memory/` | Rule 3 (monotonic filenames) | empty + .gitkeep |
| `skeleton/` | Rule 7 (skeleton obeys memory) | empty + .gitkeep |
| `prompts/` | §Folder structure | empty + .gitkeep |
| `assets/MANIFEST.txt` | Rule 5 (manifest only refs real files) | template for entries |
| `assets/README.md` | Rule 5 | placeholder |
| `tests/verify.sh` | Rule 4 (grep-verifiable claims) | placeholder |
| `tests/README.md` | Rule 4 | placeholder |
