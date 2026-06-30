# Remediation Plan — Stride v3.2

## Phased rollout

### Phase 1 — Release-blocker (this sprint, before v3.3 ships)

P0 Critical — all three must ship.

- [ ] **F-001**: Paywall "No thanks" → 44pt button. Owner: design + iOS + Android dev. Time: S (one screen, ~2 hours per platform). Test: VoiceOver/TalkBack reads new label; accidental-tap test passes.
- [ ] **F-002**: Onboarding step 3 → darken body text to `#718096`. Owner: design system. Time: XS (token update + theme refresh). Test: axe-core + Lighthouse pass WCAG AA on the screen.
- [ ] **F-003**: Workout "End workout" → confirmation sheet. Owner: Workout feature team. Time: S (component already exists in design system; wire it up). Test: simulate accidental tap; confirm data preserved.

### Phase 2 — Current sprint, parallel to Phase 1

P1 Major — fix 5 of 7.

- [ ] **F-004**: Home stats tiles → fixed height. Owner: Home team. Time: S.
- [ ] **F-005**: Activity back button consistency. Owner: Activity team. Time: S.
- [ ] **F-007**: Paywall close button on Android. Owner: Android team. Time: XS.
- [ ] **F-008**: Profile empty state. Owner: Profile team. Time: S (illustrate is design work).
- [ ] **F-010**: Onboarding video mute indicator. Owner: Onboarding team. Time: XS.

Defer to next sprint if resources tight:
- F-006 — Stats chart legend colors (design system update, can wait).
- F-009 — Settings dark mode toggle (larger change; needs design + both platforms).

### Phase 3 — Backlog (next sprint)

P2 Minor — bundle by feature area.

- [ ] **F-011**: Workout stats announcements (M)
- [ ] **F-012**: Stats tooltip persistence (XS)
- [ ] **F-013**: Activity filter chip overflow (XS)
- [ ] **F-014**: Profile name RTL support (S)
- [ ] **F-015**: Settings scroll restoration (S)
- [ ] **F-016**: Paywall price formatting (S)

### Phase 4 — Opportunistic

P3 Info — fold into related work.

- [ ] **F-017**: Home greeting localization → fold into broader localization sprint.
- [ ] **F-018**: Stats date format → fold into localization sprint.
- [ ] **F-019**: Workout toggle ARIA → fold into accessibility pass.
- [ ] **F-020**: Onboarding button loading → fold into button-system refactor.

---

## Verification

After Phase 1 fixes, before declaring v3.3 ready:

- [ ] Run axe-core 4.10 on every screen — zero Critical violations.
- [ ] Run Lighthouse mobile audit — Performance ≥ 90, Accessibility = 100.
- [ ] Run WAVE — zero contrast errors.
- [ ] Manual screen reader walkthrough on iOS VoiceOver + Android TalkBack for every screen.
- [ ] Manual keyboard-only navigation (where applicable; not native iOS/Android scope).
- [ ] Visual regression: side-by-side compare v3.2 vs v3.3 candidate.
- [ ] User test: 5 participants, focus on Paywall accidental-tap and Onboarding step 3.

After Phase 2 (current sprint end):

- [ ] Re-run axe-core — zero Critical AND Major violations.
- [ ] Re-test paywall + onboarding with 5 fresh participants.

After Phase 3 (next sprint):

- [ ] Final audit before declaring v3.4 ready.

## Stop-the-line rules

- **If a P0 fix introduces regression on the affected screen**, revert and re-design. Do not ship a regression to fix a Critical.
- **If a P0 fix is impossible in current architecture**, escalate to PM within 24 hours. Do not silently defer.
- **If multiple P1 fixes conflict** (same component, different approach), pause that component and pick the more conservative fix.

## Cross-cutting refactors (recommended as follow-up)

These are not findings but adjacent improvements:

1. **Codify empty-state pattern** (F-008 evidence). Create a `EmptyState` component with required slots: illustration, headline, body, CTA.
2. **Codify destructive-action confirmation** (F-003 evidence). Create a `ConfirmSheet` wrapper; lint rule to flag destructive actions without it.
3. **Codify contrast gate** (F-002 evidence). Add lint rule that fails any hex pairing under 4.5:1.
4. **Localize in waves** (F-014, F-016, F-017, F-018 evidence). Inventory all hardcoded strings; prioritize by screen traffic.

These refactors are out of scope for v3.3 but should ship in v3.4 or v3.5.