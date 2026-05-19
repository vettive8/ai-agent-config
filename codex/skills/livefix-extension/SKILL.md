---
name: livefix-extension
description: Orchestrate Playwright-based extension QA and autofix loops using the LiveFix toolkit. Use when a user wants to set up or run Chrome extension smoke tests, visible live browser sessions, or repeated test-fix-retest loops in a project, especially when moving the same workflow across repositories.
---

# LiveFix Extension

## Overview

Run a consistent workflow for Chrome extension testing with Playwright persistent context.  
Use this skill to scaffold adapter files, run smoke/live sessions, and execute the LiveFix autofix loop.

## Workflow

1. Confirm target project path and extension build path.
2. Ensure LiveFix toolkit exists:
`c:/Development2/Business/Money/tools/livefix-loop`
3. Scaffold extension adapter in the target project:
`node c:/Development2/Business/Money/tools/livefix-loop/scaffold-extension-adapter.mjs --target <project-path>`
4. Ensure Playwright dependencies in target project:
`npm i -D @playwright/test`
`npx playwright install chromium`
5. Set extension path environment variable:
`$env:EXTENSION_PATH='c:/path/to/extension/dist'`
6. Run extension smoke test:
`npm run test:ext`
7. Run visible user-like extension session:
`npm run session:ext -- --duration 2m`
8. Run autofix loop when needed:
`node c:/Development2/Business/Money/tools/livefix-loop/livefix-loop.mjs --project <project-path> --test-cmd "npm run test:ext -- --reporter=line" --fix-cmd "codex run --stdin" --max-runs 4`

## Invocation Rules

1. If the user asks to "set up extension loop," execute steps 1-6.
2. If the user asks to "run live observer," execute step 7 with requested duration.
3. If the user asks to "autofix failing extension tests," execute step 8 and report artifacts.
4. Prefer minimal edits in extension project when tests fail; rerun loop after each fix.

## Reporting Contract

Always report:
1. Commands executed.
2. Pass/fail status.
3. Artifact paths (`.livefix/artifacts`, `live-run-artifacts`, Playwright traces/videos).
4. Any selector assumptions and next patch target.

## References

Load [command-recipes.md](./references/command-recipes.md) for concrete command variants and troubleshooting.
