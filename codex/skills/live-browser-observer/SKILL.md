---
name: live-browser-observer
description: Run headed Playwright sessions so users can watch browser actions in real time, with step logs, screenshots, and optional autonomous retry/fix loops. Use when users ask to "see what the agent is doing", request live UI automation demos, or want autonomous test-fix-retest behavior with visible browser interaction.
---

# Live Browser Observer

## Overview

Use this skill to run browser automation in headed mode so users can watch every step live while Codex logs actions and captures artifacts.

## Workflow

1. Validate prerequisites.
- Ensure the project has Playwright and a runnable target app.
- Ensure a visible desktop session is available (local monitor, remote desktop, or phone remote-desktop app).
- Note: if the execution policy blocks GUI launch in this environment, run the provided command directly in the user's terminal session.

2. Run visible automation.
- Prefer one worker and headed mode for readability.
- Use slow motion to make clicks and typing observable.
- Capture traces/video/screenshots for post-run review.

3. Optional autonomous loop.
- If requested, run test -> capture failure -> fix command -> retest.
- Limit attempts and persist logs under a run artifacts directory.

4. Report.
- Provide command used, pass/fail status, and artifact paths.

## Commands

Run a single visible Playwright session:

```powershell
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/run_live_playwright_loop.ps1" `
  -ProjectDir "<repo>/agents/playwright-autofix-loop" `
  -BaseUrl "http://127.0.0.1:4173" `
  -MaxRuns 1 `
  -SlowMoMs 350
```

Run a human-like session for a fixed duration:

```powershell
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/run_live_playwright_loop.ps1" `
  -ProjectDir "<repo>/agents/playwright-autofix-loop" `
  -BaseUrl "http://127.0.0.1:4173" `
  -RunMode "user-session" `
  -SessionDuration "2m" `
  -SlowMoMs 700
```

Run inspector mode (step-by-step):

```powershell
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/run_live_playwright_loop.ps1" `
  -ProjectDir "<repo>/agents/playwright-autofix-loop" `
  -BaseUrl "http://127.0.0.1:4173" `
  -MaxRuns 1 `
  -SlowMoMs 500 `
  -DebugMode
```

Run with autonomous fixer retries:

```powershell
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/run_live_playwright_loop.ps1" `
  -ProjectDir "<repo>/agents/playwright-autofix-loop" `
  -BaseUrl "http://127.0.0.1:4173" `
  -MaxRuns 4 `
  -FixCommand "codex run --stdin"
```

## References

- For modes and troubleshooting, read `references/playwright-live-mode.md`.
