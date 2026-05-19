---
name: app-test
description: Launch a web app and run its smoke tests in a real visible browser, then report pass/fail with screenshots. Use when the user wants to test an application end-to-end, verify features still work, or "open and test the app". Works for any web app — each app provides a tests/smoke.mjs (this skill can scaffold one).
---

# app-test

A universal smoke-test runner. It launches an app, opens it in a **real
visible browser** (Playwright), runs the app's own test plan, screenshots
every step, and prints a pass/fail report.

## Design — why it works for any app

- **The runner (`runner.mjs`) is universal.** It never changes per app.
- **Each app ships `tests/smoke.mjs`** in its repo, describing how to
  launch that app and what to check. That file is the only app-specific
  part, and it lives with the app — so past apps, the current app, and
  every future version each carry their own up-to-date test plan.

## How to run it

1. Find the app's repo directory — the folder that has (or should have)
   `tests/smoke.mjs`. If unclear, ask the user.
2. If `<appDir>/tests/smoke.mjs` is missing, offer to scaffold it: copy
   `template-smoke.mjs` (in this skill folder) to `<appDir>/tests/smoke.mjs`
   and tailor its `config` and `run` steps to the app by reading its code.
3. First run only — install the browser (one time, shared by all apps):
   `cd <thisSkillDir> && npm install` then `npx playwright install chromium`.
4. Run: `node <thisSkillDir>/runner.mjs <appDir>`
5. Relay the pass/fail summary to the user and point them at the
   screenshots in `<appDir>/tests/screenshots/`.

## tests/smoke.mjs contract

The file exports:

- `config` — `{ start, url, env, cwd, slowMo, viewport, readyTimeoutMs }`.
  `start` is the launch command (e.g. `node server.js`); the runner waits
  until `url` responds. If `url` is already up, the runner reuses it.
- `run({ page, step, expect, appDir, config })` — the test body. Wrap each
  check in `await step("name", async () => { ... })`. `page` is a
  Playwright Page; `expect(cond, msg)` throws on a false condition.
- optional `setup({ appDir })` / `teardown({ appDir })` — run before
  launch / after the browser closes (e.g. clean a temp data directory).

`smoke.mjs` needs **no dependencies** — the runner supplies the browser.
Tests should run the app against a throwaway data directory and a spare
port so they never touch the user's real data.
