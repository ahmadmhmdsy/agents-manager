# Worked Example — Responsive Web

**Task ID**: T-2026-07-20-002
**Mode set**: SYSTEMIZE (minimal) + MOCK
**Medium**: Web (responsive: 390 / 768 / 1440)
**Audience**: am-coder (consumes tokens + mockup to build React/Vue/Svelte landing page)
**Scope tier**: Medium (one page, 3 breakpoints, light tokens)

## Files

- `user-task.md` — what master gave am-design
- `share/design/T-2026-07-20-002/00_brief.md`
- `share/design/T-2026-07-20-002/03_system/tokens/`
  - `base.json`
  - `tokens.css`
- `share/design/T-2026-07-20-002/04_mockups/web-responsive/`
  - `index.html` (the 3-breakpoint mockup)
- `share/design/T-2026-07-20-002/99_handoff.md`
- `share/messages/design-to-coder-T-2026-07-20-002-handoff.md`

## Subject

**Lumio** — fictional habit tracker. Landing page that needs to work on mobile, tablet, and desktop. Friendly but professional. Audience: people who want to build small daily habits.

## What this example demonstrates

- MOCK mode (multi-breakpoint)
- SYSTEMIZE mode (tokens, but not full component library — minimal for one page)
- Audience = am-coder (the most common handoff)
- 3 viewports side-by-side in one mockup HTML
- Token wiring instructions in `99_handoff.md`
- Strict separation: no production code, just tokens + visual reference

## What this example does NOT include

- A real backend or signup flow (would be separate dispatches)
- Brand identity work (Lumio's brand is pre-existing — referenced, not designed here)
- Interactive prototype (would be mode=PROTOTYPE)
- Multiple pages (this is one landing page)