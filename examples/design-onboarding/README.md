# Example — design-onboarding

A worked example showing a complete `am-design` dispatch, end-to-end, in the smallest reasonable scope.

## What's here

```
design-onboarding/
├── README.md                          ← this file
├── user-task.md                       ← the user task the master captured at Phase 0
└── share/
    ├── design/
    │   └── T-2026-07-15-001/
    │       ├── 00_brief.md            ← design agent restated the task
    │       ├── 01_directions/01/      ← one direction picked by the user
    │       │   ├── SPEC.md            ← visual direction one-pager
    │       │   ├── tokens.json        ← theme-specific token overrides
    │       │   └── mockup.html        ← both screens in one self-contained HTML
    │       └── 99_handoff.md          ← pointer + token wiring snippet + STATUS
    └── messages/
        └── design-to-coder-T-2026-07-15-001-handoff.md  ← wire-format handoff to am-coder
```

## How to replay

In OpenCode, with agents-manager installed:

```
"In the agents-manager project, run the design-onboarding example:
dispatch am-design with task id T-2026-07-15-001, mode set {MOCK},
scope tier small, against the user-task.md in this folder.
Then open share/design/T-2026-07-15-001/01_directions/01/mockup.html
in a browser to verify."
```

The expected output is the file tree above. Compare your output against this expected layout.

## What this example demonstrates

- `scope=small` — one direction, no `02_system/`, two screens.
- Token-only mockup (every screen uses `var(--color-*)`, no inline hex outside `:root`).
- Self-contained `mockup.html` (opens standalone, no project setup).
- RTL on `dir="rtl"` (Arabic in this case — picked because the design system supports it; this isn't a Quran-specific example).
- Two-paragraph "how to wire tokens" snippet in `99_handoff.md` (so `am-coder` can copy-paste).
- `STATUS: DONE` (everything checks out, no concerns).
- No scaffold (`share/design/.../scaffold/`) — strict separation, am-design never writes `src/**`.

## What this example does NOT demonstrate (intentionally)

- `scope=medium` or `scope=full` — those need a bigger sample.
- `CONCEIVE` mode with multiple directions — `user-task.md` already names the direction.
- `SYSTEMIZE` mode — would produce a full `02_system/` tree.
- `AUDIT` mode — would produce a `03_audit.md` review.
- Multi-theme — this example ships one theme; multi-theme is the same pattern with more directions.