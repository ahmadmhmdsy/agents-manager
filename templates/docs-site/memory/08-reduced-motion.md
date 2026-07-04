# 08 · reduced-motion — USE THIS WHEN: any UI animation is in scope

The skeleton ships two animations by default: sidebar collapse (handled by
native `<details>`) and TOC scroll (instant scroll into view). Both honor
`prefers-reduced-motion: reduce`. Authors adding new motion MUST extend the
honoring.

## The check

```js
const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
```

Two ways to use it:

- **CSS** (preferred for visual animations):

  ```css
  @media (prefers-reduced-motion: no-preference) {
    .some-element { transition: transform .15s ease; }
  }
  ```

  Default in the unreduced case; instant in the reduced case.

- **JS** (for scroll / programmatic motion):

  ```js
  function scrollToAnchor(id) {
    const el = document.getElementById(id);
    el.scrollIntoView({
      behavior: reduced ? "auto" : "smooth",
      block: "start"
    });
  }
  ```

## Default-no-motion stance

Any new animation must answer two questions:

1. What does the **reduced** user experience? (Always: instant, no motion.)
2. Does the animation carry information, or is it decorative? (If decorative,
   `display: none` in the reduced case is fine; if it carries information,
   the no-motion variant still has to surface the information.)

## Forbidden patterns

- Auto-scrolling the main content on page load to bring the h1 into view. The
  user is already there.
- Looping animations that don't pause when off-screen.
- `setInterval` + `transform` (carousel-style); let CSS handle it or skip it.
- `box-shadow` transitions on focus rings that visibly move; change opacity or
  color instead.

## Acceptance for new motion

- Reduced-motion users never see motion. Period.
- Reduced-motion users always reach the same end state.
- The animation is reversible (no `display: none` → visible flicker loop).

These are bikeshed-able in review; the spirit is "if a user disables motion,
nothing about your feature changes except the timing".
