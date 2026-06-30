# Severity Matrix — Stride v3.2

| Finding | Severity | Affected | Effort | Priority |
|---|---|---|---|---|
| F-001 — Paywall "No thanks" target too small | Critical | Paywall | S | P0 |
| F-002 — Onboarding step 3 contrast | Critical | Onboarding step 3 | XS | P0 |
| F-003 — Workout "End workout" no confirmation | Critical | Workout | S | P0 |
| F-004 — Home stats tiles inconsistent height | Major | Home | S | P1 |
| F-005 — Activity back button inconsistent | Major | Activity | S | P1 |
| F-006 — Stats chart legend contrast | Major | Stats | S | P1 |
| F-007 — Paywall close missing on Android | Major | Paywall (Android) | XS | P1 |
| F-008 — Profile empty state blank | Major | Profile | S | P1 |
| F-009 — Settings dark mode toggle | Major | Settings | M | P1 |
| F-010 — Onboarding video mute indicator | Major | Onboarding step 1 | XS | P1 |
| F-011 — Workout stats no announcement | Minor | Workout | M | P2 |
| F-012 — Stats tooltip dismisses fast | Minor | Stats | XS | P2 |
| F-013 — Activity filter chip overflow | Minor | Activity | XS | P2 |
| F-014 — Profile name RTL | Minor | Profile | S | P2 |
| F-015 — Settings scroll lost on re-entry | Minor | Settings | S | P2 |
| F-016 — Paywall price formatting | Minor | Paywall | S | P2 |
| F-017 — Home greeting hardcoded | Info | Home | XS | P3 |
| F-018 — Stats date format | Info | Stats | XS | P3 |
| F-019 — Workout toggle ARIA | Info | Workout | XS | P3 |
| F-020 — Onboarding button loading | Info | Onboarding | XS | P3 |

## Critical (P0) — fix immediately, block release if not done

- **F-001**: Paywall target size. Possible legal risk in EU consumer-protection jurisdictions.
- **F-002**: Onboarding step 3 contrast. Accessibility claim invalid until fixed.
- **F-003**: Workout destructive confirmation. Data loss is a trust killer.

## Major (P1) — fix in current sprint

- **F-004** through **F-010**. 7 items. Mixed effort; most are S or XS.

## Minor (P2) — backlog

- **F-011** through **F-016**. 6 items. Schedule for next sprint after P1 cleared.

## Info (P3) — nice to have

- **F-017** through **F-020**. 4 items. Bundle with related work.

## Effort summary

| Severity | Count | Total effort (approx) |
|---|---|---|
| Critical (P0) | 3 | 3 × S + XS ≈ 1 week for 1 dev |
| Major (P1) | 7 | 5 × S + 1 × M + 2 × XS ≈ 2 weeks for 1 dev |
| Minor (P2) | 6 | 4 × S + 1 × M + 1 × XS ≈ 1.5 weeks for 1 dev |
| Info (P3) | 4 | 4 × XS ≈ half day |
| **All** | **20** | **≈ 5 weeks for 1 dev (or 2.5 weeks for 2 devs in parallel)** |

## Recommendation

Fix all 3 P0 before next release. Fix 5 of 7 P1 in current sprint; defer 2 (F-006, F-009) to backlog if resources tight. Defer all P2/P3 unless work overlaps.