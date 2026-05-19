# app-test

A universal browser smoke-test skill for Claude Code. It launches a web
app, opens it in a **real visible browser**, runs the app's own test plan
at a human-watchable pace, narrates each step with an on-page caption,
screenshots everything, and reports pass/fail.

## Design

Two parts, deliberately separated:

- **The runner (`runner.mjs`) is universal.** It never changes per app —
  it launches the app, drives a Playwright browser, runs steps, reports.
- **Each app ships its own `tests/smoke.mjs`** describing how to launch
  that app and what to check. That file lives in the app's repo, so every
  app — and every version of it — carries its own up-to-date test plan.

This is what makes one skill work for any app, past or future: the runner
is the constant; the test plan travels with the app.

## Install

```sh
npm install
npx playwright install chromium
```

## Use

As a Claude Code skill, invoke `/app-test` (see `SKILL.md`). Directly:

```sh
node runner.mjs <appDir>
```

`<appDir>` is an app repo containing `tests/smoke.mjs`. Screenshots are
written to `<appDir>/tests/screenshots/`.

## Writing tests/smoke.mjs

Copy `template-smoke.mjs` into `<appRepo>/tests/smoke.mjs` and fill in the
`config` (how to launch) and `run({ page, step, expect })` (the steps). It
needs no dependencies — the runner supplies the Playwright `page`. Run the
app on a spare port against a throwaway data directory so tests never
touch real data.
