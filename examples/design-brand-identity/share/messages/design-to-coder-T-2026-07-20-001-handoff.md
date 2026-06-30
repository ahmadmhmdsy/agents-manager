# Handoff: design → next agent (T-2026-07-20-001)

**From**: am-design
**To**: marketing team (primary) + external agency (when briefed)
**Mode set**: BRAND + WRITE
**Audience**: marketing + agency
**Status**: DONE

## Pointer

Read `share/design/T-2026-07-20-001/99_handoff.md` first. It links every artifact and lists the top-3 don'ts.

## Artifacts to read

For marketing:
- `02_brand/brand-guidelines.md` — start here
- `02_brand/color-palette.json` — feed into token compiler
- `02_brand/voice-and-tone.md` — share with copywriters
- `02_brand/logo/logo-placeholder.svg` — placeholder until real logo arrives

For external agency:
- Same three plus `02_brand/brand-guidelines.md` (already in the list)

## How to wire tokens

For Style Dictionary (npm):
```bash
npm install style-dictionary
npx style-dictionary build --source share/design/T-2026-07-20-001/02_brand/color-palette.json
```

For Tailwind (tailwind.config.js):
```js
import palette from './share/design/T-2026-07-20-001/02_brand/color-palette.json' assert { type: 'json' };
export default {
  theme: {
    extend: {
      colors: Object.fromEntries(
        Object.entries(palette.color).map(([k, v]) => [k, v.$value])
      )
    }
  }
};
```

## Open questions for the user

See `99_handoff.md` § Open questions.

## STATUS: DONE