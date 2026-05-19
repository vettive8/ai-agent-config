# Command Recipes

## Standard Setup in Extension Project

```powershell
node c:/Development2/Business/Money/tools/livefix-loop/scaffold-extension-adapter.mjs --target .
npm i -D @playwright/test
npx playwright install chromium
```

Set extension build path:

```powershell
$env:EXTENSION_PATH='c:/path/to/extension/dist'
```

Optional popup path override:

```powershell
$env:EXTENSION_POPUP_PATH='popup.html'
```

## Run Extension Smoke Test

```powershell
npm run test:ext
```

## Run Visible Extension Session

45 seconds:

```powershell
npm run session:ext -- --duration 45s --slow-mo 90
```

2 minutes:

```powershell
npm run session:ext -- --duration 2m --slow-mo 120
```

## Run Autofix Loop

Without fixer (diagnostic only):

```powershell
node c:/Development2/Business/Money/tools/livefix-loop/livefix-loop.mjs --project . --test-cmd "npm run test:ext -- --reporter=line" --max-runs 1
```

With fixer:

```powershell
node c:/Development2/Business/Money/tools/livefix-loop/livefix-loop.mjs --project . --test-cmd "npm run test:ext -- --reporter=line" --fix-cmd "codex run --stdin" --max-runs 4
```

## Troubleshooting

1. If extension does not load:
   - Verify `EXTENSION_PATH` points to a built extension directory containing `manifest.json`.
2. If popup URL fails:
   - Set `EXTENSION_POPUP_PATH` to the correct HTML entry.
3. If tests are flaky:
   - Use explicit locators in `tests/extension.smoke.spec.js`.
4. If headed browser is not visible:
   - Ensure local desktop session is active.
