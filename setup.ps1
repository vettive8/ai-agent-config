# setup.ps1 -- deploy ai-agent-config into Codex and Claude Code.
#
# Run this on a NEW machine after `git clone`. It installs:
#   - the finish-sound script  -> ~/.codex + ~/.claude
#   - shared instructions      -> AGENTS.md + CLAUDE.md
#   - skills                   -> ~/.codex/skills + ~/.claude/skills
#   - config templates         -> config.toml + settings.json
#
# Existing files are backed up to <name>.bak before being overwritten.
# Secrets (auth.json / .credentials.json) are never touched -- just log in.
#
# NOTE: don't run this on the machine the repo was captured from -- it would
# replace your live config.toml / settings.json with the trimmed templates
# (a .bak backup is still made either way).

$ErrorActionPreference = 'Stop'
$repo      = $PSScriptRoot
$codexDir  = Join-Path $env:USERPROFILE ".codex"
$claudeDir = Join-Path $env:USERPROFILE ".claude"

function Backup-IfExists($path) {
  if (Test-Path $path) {
    Copy-Item $path "$path.bak" -Force
    Write-Host "  backed up -> $path.bak" -ForegroundColor DarkYellow
  }
}

Write-Host "Deploying ai-agent-config for user '$env:USERNAME'..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$codexDir\skills","$claudeDir\skills" | Out-Null

# 1. Finish-sound script -> both agents.
Copy-Item "$repo\shared\notify.ps1" (Join-Path $codexDir  "notify.ps1") -Force
Copy-Item "$repo\shared\notify.ps1" (Join-Path $claudeDir "notify.ps1") -Force
Write-Host "[ok] notify.ps1 -> Codex + Claude" -ForegroundColor Green

# 1b. git-autosave script -> both agents. Claude wires it as a Stop hook
# automatically (see claude/settings.json below); Codex has no equivalent
# hook primitive, so it's invoked via the shared instructions instead --
# see shared/instructions.md.
Copy-Item "$repo\shared\git-autosave.ps1" (Join-Path $codexDir  "git-autosave.ps1") -Force
Copy-Item "$repo\shared\git-autosave.ps1" (Join-Path $claudeDir "git-autosave.ps1") -Force
Write-Host "[ok] git-autosave.ps1 -> Codex + Claude" -ForegroundColor Green

# 2. Shared instructions -> AGENTS.md (Codex) and CLAUDE.md (Claude).
Backup-IfExists "$codexDir\AGENTS.md"
Backup-IfExists "$claudeDir\CLAUDE.md"
Copy-Item "$repo\shared\instructions.md" "$codexDir\AGENTS.md"  -Force
Copy-Item "$repo\shared\instructions.md" "$claudeDir\CLAUDE.md" -Force
Write-Host "[ok] instructions -> AGENTS.md + CLAUDE.md" -ForegroundColor Green

# 3. Skills.
if (Test-Path "$repo\codex\skills")  { Copy-Item "$repo\codex\skills\*"  "$codexDir\skills\"  -Recurse -Force }
if (Test-Path "$repo\claude\skills") { Copy-Item "$repo\claude\skills\*" "$claudeDir\skills\" -Recurse -Force }
Write-Host "[ok] skills -> Codex + Claude" -ForegroundColor Green

# 4. Codex config.toml -- patch the notify path for this user, then place.
Backup-IfExists "$codexDir\config.toml"
$codexCfg = (Get-Content "$repo\codex\config.toml" -Raw).Replace(
  'C:\\Users\\ASUS\\.codex', $codexDir.Replace('\','\\'))
[System.IO.File]::WriteAllText("$codexDir\config.toml", $codexCfg)
Write-Host "[ok] config.toml -> Codex (notify path patched)" -ForegroundColor Green

# 5. Claude settings.json -- patch the hook path for this user, then place.
Backup-IfExists "$claudeDir\settings.json"
$claudeCfg = (Get-Content "$repo\claude\settings.json" -Raw).Replace(
  'C:\\Users\\ASUS\\.claude', $claudeDir.Replace('\','\\'))
[System.IO.File]::WriteAllText("$claudeDir\settings.json", $claudeCfg)
Write-Host "[ok] settings.json -> Claude (hook path patched)" -ForegroundColor Green

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Cyan
Write-Host "  - Log in to each agent (secrets are never part of this repo)."
Write-Host "  - app-test skill needs Playwright: cd '$claudeDir\skills\app-test'; npm install"
