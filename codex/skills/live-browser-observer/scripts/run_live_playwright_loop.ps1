param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectDir,
  [string]$BaseUrl = "http://127.0.0.1:4173",
  [ValidateSet("tests", "user-session")]
  [string]$RunMode = "tests",
  [string]$SessionDuration = "2m",
  [int]$MaxRuns = 1,
  [int]$SlowMoMs = 300,
  [string]$TestCommand = "npx playwright test --headed --workers=1 --reporter=line",
  [string]$FixCommand = "",
  [string]$ArtifactsDir = "live-run-artifacts",
  [switch]$DebugMode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $ProjectDir)) {
  throw "ProjectDir does not exist: $ProjectDir"
}

if ($MaxRuns -lt 1) {
  throw "MaxRuns must be >= 1"
}

$resolvedProjectDir = (Resolve-Path -Path $ProjectDir).Path
$resolvedArtifactsDir = Join-Path $resolvedProjectDir $ArtifactsDir
New-Item -ItemType Directory -Force -Path $resolvedArtifactsDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$sessionDir = Join-Path $resolvedArtifactsDir $timestamp
New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null

Write-Host "[live-loop] Project: $resolvedProjectDir"
Write-Host "[live-loop] Artifacts: $sessionDir"
Write-Host "[live-loop] Base URL: $BaseUrl"
Write-Host "[live-loop] RunMode: $RunMode"
Write-Host "[live-loop] SessionDuration: $SessionDuration"
Write-Host "[live-loop] Max runs: $MaxRuns"
Write-Host "[live-loop] SlowMo: ${SlowMoMs}ms"
Write-Host "[live-loop] DebugMode: $DebugMode"

$env:APP_BASE_URL = $BaseUrl
$env:PWDEBUG = if ($DebugMode) { "1" } else { "0" }
$env:PLAYWRIGHT_JUNIT_OUTPUT_NAME = ""
$env:PLAYWRIGHT_HTML_OUTPUT_DIR = Join-Path $sessionDir "playwright-report"
$env:PW_TEST_HTML_REPORT_OPEN = "never"
$env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1"

if ($RunMode -eq "user-session") {
  $MaxRuns = 1
  $TestCommand = "npm run session:user -- --base-url '$BaseUrl' --duration '$SessionDuration' --slow-mo $SlowMoMs --artifacts-dir '$ArtifactsDir'"
}

$attempt = 1
while ($attempt -le $MaxRuns) {
  Write-Host "[live-loop] Attempt $attempt/$MaxRuns - running command..."

  $attemptLog = Join-Path $sessionDir ("attempt-" + $attempt + ".log")
  $env:PLAYWRIGHT_LIVE_SLOWMO = [string]$SlowMoMs

  Push-Location $resolvedProjectDir
  try {
    $testScript = [scriptblock]::Create($TestCommand)
    & $testScript 2>&1 | Tee-Object -FilePath $attemptLog
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
      $exitCode = 0
    }
  } finally {
    Pop-Location
  }

  if ($exitCode -eq 0) {
    if ($RunMode -eq "user-session") {
      Write-Host "[live-loop] User session completed on attempt $attempt."
    } else {
      Write-Host "[live-loop] Tests passed on attempt $attempt."
    }
    exit 0
  }

  Write-Host "[live-loop] Tests failed on attempt $attempt. Log: $attemptLog"

  if ($attempt -ge $MaxRuns) {
    break
  }

  if ([string]::IsNullOrWhiteSpace($FixCommand)) {
    Write-Host "[live-loop] No FixCommand provided. Stopping after first failure."
    exit 1
  }

  $fixPrompt = @(
    "Autonomous UI fix request.",
    "Current attempt: $($attempt + 1) of $MaxRuns",
    "Project directory: $resolvedProjectDir",
    "Failure log: $attemptLog",
    "Base URL: $BaseUrl",
    "Retest command: $TestCommand",
    "Edit files minimally and deterministically, then exit 0 on success."
  ) -join [Environment]::NewLine

  Write-Host "[live-loop] Running FixCommand..."
  Push-Location $resolvedProjectDir
  try {
    $fixScript = [scriptblock]::Create($FixCommand)
    $fixPrompt | & $fixScript
    $fixExitCode = $LASTEXITCODE
    if ($null -eq $fixExitCode) {
      $fixExitCode = 0
    }
  } finally {
    Pop-Location
  }

  if ($fixExitCode -ne 0) {
    Write-Host "[live-loop] FixCommand failed with code $fixExitCode."
    exit $fixExitCode
  }

  $attempt += 1
}

Write-Host "[live-loop] Reached max attempts ($MaxRuns) and tests are still failing."
exit 1
