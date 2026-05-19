# Playwright Live Mode

## Goal

Run browser automation where users can watch interactions in real time and still get machine-readable artifacts.

## Modes

1. Headed observer mode
- Use for demos and debugging with human-visible clicks/typing.
- Command pattern:
  - `npx playwright test --headed --workers=1 --reporter=line`

2. Debug inspector mode
- Use when stepping action-by-action.
- Command pattern:
  - `$env:PWDEBUG=1; npx playwright test --headed --workers=1`

3. CI artifact mode
- Use when UI cannot be shown.
- Keep `trace: retain-on-failure`, `video: retain-on-failure`, and screenshots.

## Slow Motion

Expose action pacing with:

- `PLAYWRIGHT_LIVE_SLOWMO=300` for normal demos.
- `PLAYWRIGHT_LIVE_SLOWMO=700` for teaching walkthroughs.

Use this in tests:

```js
const slowMo = Number(process.env.PLAYWRIGHT_LIVE_SLOWMO || 0);
```

and in a manual launch script pass `slowMo` into `chromium.launch({ headless: false, slowMo })`.

## Reliability Defaults

- Single worker during live mode (`--workers=1`).
- Deterministic base URL.
- Stable selectors (`getByRole`, `getByLabel`, `data-testid`).
- Store every attempt log and artifact under timestamped folders.
