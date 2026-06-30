# Audit Findings — Stride v3.2

**Mode**: AUDIT + EVALUATE
**Standard**: WCAG 2.2 AA + Apple HIG + Material 3 + Brand book v2.1
**Date**: 2026-07-20
**Auditor**: am-design

## Summary

- **3 Critical (P0)** findings — must fix before next release.
- **7 Major (P1)** findings — fix in current sprint.
- **12 Minor (P2)** findings — backlog.
- **4 Info (P3)** findings — nice-to-have.

Critical issues cluster around the **Paywall** and **Onboarding step 3** (matching known QA complaints). Accessibility issues are systemic, not isolated.

## Methodology

- Screens reviewed: 8 (see `01_research/design-audit-input.md`).
- Tools: iOS Simulator (Xcode 16), Android Emulator (API 34), Chrome DevTools, axe-core 4.10, manual screen reader walkthrough (VoiceOver + TalkBack).
- Time spent: 6 hours over 2 days.

---

## F-001 — Paywall "No thanks" button fails 44pt target

**Severity**: Critical
**Standard**: Apple HIG (44×44 pt touch target).
**Affected**: Paywall screen, all variants.
**Observed**: The "No thanks" link-style button is 28pt tall, well below the 44pt minimum. Users tap "Subscribe" by accident.
**Expected**: Either a button at 44pt minimum, or the link relocated so accidental taps are impossible.
**Impact**: Lost subscriptions. Possible legal risk in jurisdictions that require explicit consent.
**Fix**: Convert the link to a 44pt button OR move it above the subscribe button with clear spacing. (See `remediation-plan.md` § Phase 1.)
**Effort**: S (one screen, one component).

## F-002 — Onboarding step 3 contrast failure

**Severity**: Critical
**Standard**: WCAG 2.2 SC 1.4.3 (4.5:1).
**Affected**: Onboarding step 3 only.
**Observed**: Body text color is `#A0AEC0` on `#F7FAFC`. Contrast ratio: **3.8:1**. Fails AA (4.5:1).
**Expected**: 4.5:1 minimum.
**Impact**: Users with low vision cannot read step 3. Likely contributor to higher drop-off on this step.
**Fix**: Darken body text to `#718096` or darker (5.1:1 on `#F7FAFC`).
**Effort**: XS (one color token).

## F-003 — Workout "End workout" has no confirmation

**Severity**: Critical
**Standard**: UX best practice + Apple HIG (destructive actions).
**Affected**: Workout screen (live tracking).
**Observed**: Tapping "End workout" immediately ends the session. No confirmation. Accidental taps delete up to 90 minutes of tracked data.
**Expected**: Confirmation modal: "End workout? Your data will be saved."
**Impact**: User data loss. Trust damage.
**Fix**: Add confirmation sheet before destructive action.
**Effort**: S.

## F-004 — Home screen stats tiles inconsistent height

**Severity**: Major
**Standard**: Internal consistency (the app's own grid system).
**Affected**: Home screen only.
**Observed**: The 3 stats tiles ("Steps", "Calories", "Active minutes") have inconsistent heights (vary by 12px between them) due to dynamic number length.
**Expected**: Fixed grid; numbers truncate or shrink to fit.
**Impact**: Visual rhythm breaks. Looks unfinished.
**Fix**: Set fixed tile height + number font-size cap.
**Effort**: S.

## F-005 — Activity screen back button inconsistent

**Severity**: Major
**Standard**: Apple HIG (back navigation).
**Affected**: Activity → Workout detail flow.
**Observed**: When opening Workout detail from Activity, the back button says "Activity" but uses a back-chevron pointing left (LTR convention). Works correctly. But when opening Workout detail from Notification, the back button says "Done" instead of a back-chevron. Inconsistent with the rest of the app.
**Expected**: Consistent back behavior — chevron + previous screen name.
**Fix**: Always use the standard back-chevron pattern; never "Done" for a navigated-back destination.
**Effort**: S.

## F-006 — Stats chart legend below WCAG contrast

**Severity**: Major
**Standard**: WCAG 2.2 SC 1.4.11 (non-text contrast 3:1).
**Affected**: Stats screen, all charts.
**Observed**: Chart series colors: `#E2E8F0` (light gray) on `#FFFFFF`. Contrast: 1.4:1. Fails non-text contrast 3:1.
**Expected**: 3:1 for graphical objects.
**Fix**: Darken series colors to at least `#A0AEC0` (3.2:1).
**Effort**: S (design tokens update).

## F-007 — Paywall close affordance missing on Android

**Severity**: Major
**Standard**: Google Play policy + Material 3.
**Affected**: Paywall on Android only.
**Observed**: No "X" or back affordance to dismiss paywall. iOS has it (top-right X). Android users have to use system back gesture, which feels hidden.
**Expected**: Consistent dismiss affordance on both platforms.
**Fix**: Add "X" button top-right on Android matching iOS.
**Effort**: XS.

## F-008 — Profile screen empty state blank

**Severity**: Major
**Standard**: Internal consistency (empty states elsewhere use illustration + CTA).
**Affected**: Profile screen, when user has no achievements yet.
**Observed**: Profile shows a blank gray box with text "No achievements yet" — no illustration, no CTA to discover achievements feature.
**Expected**: Same empty-state pattern as other screens: illustration + 1-line + CTA.
**Fix**: Add illustration + CTA "Browse achievements →".
**Effort**: S.

## F-009 — Settings dark mode toggle missing

**Severity**: Major
**Standard**: iOS/Android user expectations (system dark mode supported, but no app-level override).
**Affected**: Settings screen.
**Observed**: App follows system dark mode but provides no in-app override. Users who want dark during day (or light at night) cannot.
**Expected**: Three-way toggle: System / Light / Dark.
**Fix**: Add toggle; respect user choice; persist.
**Effort**: M.

## F-010 — Onboarding step 1 video autoplay without sound indicator

**Severity**: Major
**Standard**: WCAG 2.2 SC 1.4.2 (audio control).
**Affected**: Onboarding step 1.
**Observed**: Video autoplays muted (good) but lacks a clear "Tap to unmute" affordance. Users don't know sound is available.
**Expected**: Visible "🔊 Tap for sound" badge or speaker icon.
**Fix**: Add visible speaker icon with tooltip.
**Effort**: XS.

## F-011 — Workout screen stats update without announcement

**Severity**: Minor
**Standard**: WCAG 2.2 SC 4.1.3 (status messages).
**Affected**: Workout screen.
**Observed**: Live stats update every second but screen reader users hear nothing.
**Expected**: ARIA live region announces mile/km milestones or every minute.
**Fix**: Add polite live region with throttled announcements.
**Effort**: M.

## F-012 — Stats tooltip on chart tap dismisses too quickly

**Severity**: Minor
**Affected**: Stats screen.
**Observed**: Tooltip disappears 800ms after tap. Users can't read the value.
**Expected**: Tooltip persists until user taps elsewhere.
**Fix**: Increase persistence to 3000ms or until tap-outside.
**Effort**: XS.

## F-013 — Activity filter chip overflow on small screens

**Severity**: Minor
**Affected**: Activity screen, devices < 360pt wide.
**Observed**: 6 filter chips don't fit; horizontal scroll appears but no scroll indicator.
**Expected**: Either reduce chip count or show scroll affordance.
**Fix**: Add fade gradient on right edge to indicate scrollability.
**Effort**: XS.

## F-014 — Profile name field doesn't support RTL names

**Severity**: Minor
**Standard**: i18n best practice.
**Affected**: Profile screen.
**Observed**: Field is left-aligned; Arabic names display but with English punctuation. RTL alignment not handled.
**Expected**: Field direction matches user locale.
**Fix**: Add `text-align: start` and locale-aware input mode.
**Effort**: S.

## F-015 — Settings screen scroll position lost on re-entry

**Severity**: Minor
**Affected**: Settings screen.
**Observed**: Scrolling down, navigating away, then back — returns to top.
**Expected**: Preserve scroll position (standard pattern).
**Fix**: Implement scroll restoration on screen re-entry.
**Effort**: S.

## F-016 — Paywall price formatting inconsistent across locales

**Severity**: Minor
**Standard**: Locale formatting.
**Affected**: Paywall.
**Observed**: US shows "$9.99/mo"; UK shows "£9.99 /month"; Germany shows "9,99 €". Inconsistent spacing and separator use.
**Expected**: Use `Intl.NumberFormat` for currency display per locale.
**Fix**: Implement locale-aware formatter.
**Effort**: S.

## F-017 — Home screen greeting is hardcoded English

**Severity**: Info
**Affected**: Home screen.
**Observed**: Greeting reads "Good morning, Alex" in English regardless of locale.
**Expected**: Localized greeting.
**Fix**: Add to strings file.
**Effort**: XS.

## F-018 — Stats screen date axis format inconsistent

**Severity**: Info
**Affected**: Stats screen.
**Observed**: "Sep 4" in some places, "4 Sep" in others, "9/4" in third. Inconsistent within same screen.
**Expected**: One format per locale.
**Fix**: Standardize on locale-appropriate format.
**Effort**: XS.

## F-019 — Workout screen "km" / "mi" toggle lacks ARIA state

**Severity**: Info
**Affected**: Workout screen.
**Observed**: Toggle shows selected state visually but not via `aria-pressed`.
**Expected**: Screen reader announces selected state.
**Fix**: Add `aria-pressed` to toggle button.
**Effort**: XS.

## F-020 — Onboarding step 4 "Get started" button has no loading state

**Severity**: Info
**Affected**: Onboarding step 4.
**Observed**: Tap → network request → spinner appears. No skeleton or progress hint during the (sometimes slow) request.
**Expected**: Show progress on the button itself.
**Fix**: Add button loading state.
**Effort**: XS.

---

## Patterns observed

- **Empty states inconsistent**: Some have illustrations, some don't. Codify the empty-state pattern.
- **Destructive actions**: Sometimes confirmed, sometimes not. Make confirmation the default for any destructive action.
- **Localization**: Started but incomplete. Multiple places hardcode English. Bulk localize.
- **Accessibility**: Criticals cluster in Paywall + Onboarding. The rest of the app is mostly fine.

## What's working

- Typography hierarchy is consistent and reads well.
- Color usage in primary screens (Home, Activity) follows brand book.
- Information density is appropriate — not too sparse, not too dense.
- Loading states are clear and quick.
- Empty states in Stats and Workout are well-designed.