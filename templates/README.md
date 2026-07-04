# templates/

> Registry of every reusable template the agents_manager pipeline can load.
> Each template is a self-contained scaffold (memory/ + skeleton/ + prompts/ + tests/)
> an agent clones to produce a complete artifact.

**Rulebook:** [`AUTHORING.md`](AUTHORING.md) — read it before adding a template.
**Onboarding:** [`CONTRIBUTING.md`](CONTRIBUTING.md) — discoverable entry point for new authors.
**Starter:** [`_blank/`](_blank/) — copy with `cp -r _blank/ <your-name>/` and follow the 9-step recipe.

---

## Available templates

| Template | Version | Domain | Status | Use when |
|---|---|---|---|---|
| [`cinematic-landing/`](cinematic-landing/) | v0.14.0 | Scroll-driven single-page product site | active | User wants a cinematic, scroll-driven hero with frame-sequence or stills; tags: "cinematic landing", "scrolltelling", "apothecary", "ritual-style hero", "Lenis + GSAP ticker" |
| [`dashboard/`](dashboard/) | v0.1.0 | Multi-section data dashboard (table + form + filters + theming) | active | User wants an admin/ops dashboard with sortable tables, forms, filters, dark mode; tags: "admin panel", "user list", "invite flow", "MRR/metrics overview", "internal tool" |
| [`docs-site/`](docs-site/) | v0.1.0 | Multi-page documentation site (sidebar + TOC + search + theming) | active | User wants a docs/reference site with sidebar nav, on-this-page TOC, full-text search, code blocks, prev/next paging, dark mode; tags: "developer docs", "API reference", "guide site", "knowledge base", "MD-rendered site" |

`grep` discoverability — if a task brief mentions any of the trigger phrases above, the matching template applies. `am-planning` reads the template's `memory/01-builder-flow.md` to decide.

## Template anatomy (every template ships this)

```
templates/<name>/
  00-readme-first.md        human orientation; trigger phrases
  INDEX.md                  machine-greppable map of every convention
  decision-log.md           (deprecated — see decisions/ folder; kept for compat)
  decisions/
    decision-log.md         build-time append-only log
  memory/
    NN-<topic>.md           prose contracts; monotonic NN; trigger-line H1
  skeleton/
    index.html              reference implementation (the test oracle)
  prompts/
    <stage>.md              LLM-actionable prompts
  assets/
    MANIFEST.txt            every line must resolve in working tree
    manifest.schema.json    (optional) JSON Schema for build-time manifests
  examples/
    _recipe.md              the recipe (procedure)
    _neutral/               (optional) minimal neutral-aesthetic variant
  tests/
    verify.sh               grep-based self-check; exit 0 = PASS
    README.md               pointer to AUTHORING.md Rule 4
```

## Adding a new template

See [`CONTRIBUTING.md` §I want to add a new template](CONTRIBUTING.md) or
[`AUTHORING.md` §For authors](AUTHORING.md) for the 9-step recipe. The short version:

1. Read `AUTHORING.md` end-to-end (binding for every template).
2. `cp -r _blank/ <your-name>/`.
3. Fill INDEX.md first (consumer's entry point).
4. Add memory files in monotonic order as the worked example forces them.
5. Build skeleton last (skeleton obeys; memory asserts).
6. `bash tests/verify.sh` — exit 0 confirms grep-testable claims.
7. Tick the Rule 8 acceptance checklist; open the PR.

Title format: `templates(<name>): v0.1.0 initial cut`.

## Versioning

Per [`AUTHORING.md` §Versioning](AUTHORING.md): patch / minor / major. Bump the
inline version header in the template's `INDEX.md` and add an entry to the
template's `decisions/decision-log.md`.

## Status legend

- **active** — current, follow-on PRs welcome
- **frozen** — no further changes without major-version bump (rare)
- **deprecated** — superseded by another template; cited here for archeology

Last registry refresh: v0.1.0 (docs-site ships).
