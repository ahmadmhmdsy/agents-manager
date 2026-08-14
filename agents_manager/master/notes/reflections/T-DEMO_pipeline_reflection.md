---
scope: role
role: master
topic: pipeline-reflection
status: example
created: 2026-08-14
last_verified: 2026-08-14
---

# Pipeline Reflection — T-DEMO — master

## What surprised me
- Specialists externalize more than expected when given the manifest discipline (v0.23.0). Memory discipline (v0.23.2) compounds this — every dispatch now leaves two short writeable artifacts.

## What to try next time
- Add reflection read-back into Phase 0 preflight. Read last 3 reflections before dispatch to spot drift.

## What I'd change about my approach
- Pause at Phase 2 more often. The user gate is cheap; auto-dispatching Phase 3 on partial consensus costs fix loops later.
