# 12 · quality-bar — USE THIS WHEN: running the Rule 8 acceptance checklist

This is the contract. Every row must tick before the template ships a new
version. `bash tests/verify.sh` enforces the rows the script can check
mechanically; the rest are visual + interactive checks.

## Mechanical (enforced by verify.sh)

| # | Claim | Where checked |
|---|---|---|
| M1 | Six `data-section` values, distinct, defined in `INDEX.md` | T1 |
| M2 | Every `data-section` value has a matching `memory/NN-<slug>.md` | T2 |
| M3 | 12 memory files, all with H1 trigger line | T3 |
| M4 | At least 14 semantic + 9 layout CSS custom properties declared at `:root` | T4 |
| M5 | Every `assets/MANIFEST.txt` line resolves in the working tree | T5 |
| M6 | 5 hard rules are listed numerically | T6 |
| M7 | `data.js` `PAGES` array has ≥ 3 pages | T7 |
| M8 | `INDEX.md` "Sections (N)" matches `data-section` count in `index.html` | T8 |

`tests/README.md` runs the script and explains each row.

## Visual (reviewers must eyeball)

| # | Claim | How to check |
|---|---|---|
| V1 | Skip link visible only on focus | Reload, Tab once. Visible solid box top-left. |
| V2 | No content wider than the viewport at 360px | Resize narrow. No horizontal scroll. |
| V3 | `<pre>` code block scrolls horizontally inside its box, not the page | Add 200-char line. Page stays put. |
| V4 | Dark mode text reads 7:1 against surface | Run a contrast checker on `body` color vs background. |
| V5 | Focus ring visible on every interactive element | Tab through. Never invisible. |

## Interactive (manual flow)

| # | Flow | Pass criterion |
|---|---|---|
| I1 | Tab from address bar to skip link, press Enter | Focus jumps to `#main`, skip link disappears. |
| I2 | Press `/` from anywhere outside an input | Search input gains focus. |
| I3 | Type a query that matches a page title | Result count announces; click → that page loads. |
| I4 | Type a nonsense query | "No matches for '...'" appears. |
| I5 | Click a copy button on a code block | Clipboard contains the code; "Copied" announces. |
| I6 | Toggle theme, reload | Toggle persists. |
| I7 | Navigate to a page mid-doc, reload | That page renders, `aria-current="page"` set, group open. |
| I8 | From any page, click prev/next | Order follows the `PAGES` declaration order. |

## Acceptance

When all mechanical + visual + interactive rows tick AND
`bash tests/verify.sh` exits 0, the template is shippable.

## Common reasons a row fails after a change

- A new `data-section` was added but INDEX.md "Sections (N)" wasn't bumped. **T1**.
- A new memory file was added but its prefix isn't 01–NN monotonic. **T3**.
- A new token was introduced but not declared in `:root`. **M4**.
- A page id collision: two entries in `PAGES` with the same `id`. **T7**.
- A `<pre>` without a copy button. The post-process adds it; if you hand-authored
  raw `<pre>` in a page body, you're on the hook. **V3 + I5**.

## What this checklist is not

It is **not** a substitute for axe / Lighthouse. Run an automated audit before
every PR; this checklist is the shape of what an audit ought to find.
