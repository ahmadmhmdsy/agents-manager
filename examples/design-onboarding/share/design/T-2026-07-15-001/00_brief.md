# Brief — T-2026-07-15-001

**Date:** 2026-07-15
**Sub-agent:** design
**Modes executed:** {MOCK}
**Scope tier:** small

## User task (restated)

Design a 2-screen mobile onboarding flow for "Strides" — a fitness tracker app for runners. Screens:

1. Welcome — big CTA, brand intro
2. Goal-setting — user picks a weekly km target (5, 10, 15, 25, custom)

Locked by user: mobile-only, iOS-first, English UI, iOS HIG aesthetic.

## Mode set

`{MOCK}` — produce one direction's mockup (per user: "iOS HIG aesthetic" implies the direction).

## Scope tier

`small` — 2 screens, 1 direction, no full `02_system/`. Just enough for `am-coder` to start a SwiftUI / React Native / Compose implementation.

## Audience

iOS users in English-speaking markets (US, UK, AU, CA). Runners, broadly — casual 5K types to half-marathoners.

## Platform assumptions

- iPhone (390×844 frame — iPhone 14 baseline)
- iOS 17+, large titles, segmented controls, system colors
- Light mode only for this dispatch (dark mode flagged as deferred)
- Dynamic Type friendly (no fixed pixel heights on text containers)

## Constraints

- Strict separation: no `src/**` writes
- Token-only mockup (no inline hex outside `:root`)
- Self-contained `mockup.html` (opens standalone, no project setup)
- iOS HIG tokens only (`--color-blue` = `#007AFF`, not a custom brand blue)

## Assumptions (flag for user)

- The user said "iOS HIG aesthetic" — interpreted as Apple's standard system colors + SF Pro font. If they want a brand-blue instead, re-dispatch with new direction.
- Custom km options (5/10/15/25) picked as common weekly targets. Could be re-bucketed by user.

## What this dispatch does NOT cover

- Dark mode variant
- Running / workout screens (post-onboarding)
- Account creation, sign-in, sign-up with Apple
- Localization beyond English (RTL deferred)

## Self-critique (will be filled in 99_handoff.md)

Pending.