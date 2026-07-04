# Section scaffolding prompt

Use this prompt when an agent needs to generate the HTML/CSS/JS skeleton for
a new section based on a section spec. The output drops into
`skeleton/<section>.html` and is wired up by the existing section init.

## Prompt

```
You are scaffolding a new section for a dashboard whose layout, tokens,
and routing primitives exist at:
- layout:    skeleton/index.html (read all CSS for tokens)
- tokens:    memory/06-theming.md (light) + memory/11-dark-theme.md (dark)
- routing:   memory/02-routing-and-layout.md (hash routing, routes[] at top)

Spec for the new section:

  Section ID:    <data-section value, e.g. "activity">
  Title:         <one-line section title>
  Route(s):      <hash-routes, e.g. #/activity>
  Required UI:
    - <one bullet per UI element, e.g. "List of recent events (max 20)">
    - <...>
  Data shape:    <JSON shape or "in-memory mock, see data.js">
  States:        empty | loading | ready | error
  a11y notes:    <table caption, scope, label-for, aria-describedby, etc.>

Hard rules (must apply — see /Rules section below):

  1. No fake rows. If data === null, render empty state.
  2. URL is the source of truth (route === section visibility).
  3. Form a11y + table a11y wherever applicable.
  4. Reduced-motion gated.
  5. Dark-theme aware (data-surface + data-surface-dark attrs).

Output format:
  - The <section data-section="..."> block with all sub-elements.
  - The matching <style> additions to the document.
  - The data-state hookup if state matters.
  - A one-paragraph note on what to verify (states + a11y floors).

Self-check before returning:
  - Open the file in headless Chrome with data=null — empty state renders?
  - Tab through — focus order is top-to-bottom, no traps?
  - Toggle dark theme — every --token reference resolves?
  - Toggle reduced-motion — every transition / animation is gated?

Return only the additions. Do not refactor existing sections.
```

## Why a prompt and not a memory file

A memory file is a *contract* (what `am-coder` should do). A prompt is an
*action* (LLM-callable). The line blurs because both are markdown, but the
distinction matters: memory files assert hard rules; prompts hand off work
with a clear input/output shape.

`prompts/` is the lane for the second kind; `memory/` is the lane for the first.
