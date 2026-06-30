# 00 Brief — Lumio Responsive Landing

**Restated from master task** (see `../user-task.md`).

## Discovery answers (the 7 questions)

1. **Medium**: Web responsive (3 breakpoints).
2. **Audience**: am-coder (consumes tokens + visual reference to build the page in React).
3. **Constraint set**: Side-by-side viewports for review. All colors as tokens. WCAG AA. No emoji UI.
4. **Artifact set**: Minimal tokens + one mockup.
5. **Mode set**: SYSTEMIZE (minimal) + MOCK.
6. **Scope tier**: Medium (one page, light tokens).
7. **Success criteria**: am-coder ships the landing page in one sprint without design questions.

## What this dispatch produces

- `03_system/tokens/base.json` — color, type, spacing tokens (W3C format)
- `03_system/tokens/tokens.css` — compiled CSS variables
- `04_mockups/web-responsive/index.html` — 3-breakpoint mockup, side-by-side

## What this dispatch does NOT produce

- Component library (one page, ~6 unique elements; inline is fine)
- Page spec (.md/.json) — only one page; the mockup + tokens are the spec
- Brand work (Lumio brand pre-exists)
- Interactive prototype (static mockup sufficient for review)
- Real copy (placeholder copy in mockup; copy refactor is a separate WRITE-mode dispatch)

## Re-entry

If am-coder reports issues, this brief stays as ground truth. Mockup is version-bumped in place; tokens may need a refresh task.