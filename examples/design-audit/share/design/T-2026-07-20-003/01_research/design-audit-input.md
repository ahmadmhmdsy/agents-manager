# Audit Input — Stride v3.2

## Subject

Stride fitness tracking app, iOS + Android, version 3.2 (currently in stores).

## Audit scope

### In scope (8 screens)
1. Home (today's activity summary)
2. Activity (workout history)
3. Workout (live tracking)
4. Stats (trends and charts)
5. Profile (user settings)
6. Settings (app preferences)
7. Onboarding (4-step welcome)
8. Paywall (subscription prompt)

### Out of scope
- Launch screens (splash)
- Marketing site
- Apple Watch companion
- Web dashboard (different codebase)
- Push notification copy
- Email templates

## Reference standards

- **WCAG 2.2 AA** (web-equivalent accessibility)
- **Apple HIG** (iOS-specific patterns)
- **Material 3** (Android-specific patterns)
- **Brand book** v2.1 (internal)

## Accessibility level claimed

"WCAG 2.2 AA" — claimed in App Store and Play Store listings.

## What's in scope

- Visual design (color, typography, layout)
- Accessibility (contrast, target sizes, screen reader, motion)
- Consistency (does the app follow its own patterns?)
- Information architecture
- Error handling and empty states
- Onboarding and paywall UX

## What's out of scope

- Backend performance (separate audit)
- Code quality (separate audit)
- Security (separate audit)
- Internationalization / RTL (separate audit, scheduled Q4)

## Known issues (from internal QA)

- Paywall dismiss button sometimes missed by users
- Onboarding step 3 has higher drop-off than steps 1, 2, 4
- Apple Watch sync occasionally fails (UI shows stale data)

## Audit criteria (priority order)

1. WCAG 2.2 AA contrast (4.5:1 body, 3:1 large)
2. Touch target size (44pt iOS, 48dp Android)
3. Screen reader labels and roles
4. Reduced motion support
5. Apple HIG / Material 3 compliance
6. Brand book adherence
7. Consistency with the app's own patterns
8. Information hierarchy and visual rhythm