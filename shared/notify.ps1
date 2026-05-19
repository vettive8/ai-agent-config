# Plays a random "task finished" sound. Shared by Codex and Claude Code.
#   Codex       -> called via the `notify` array in config.toml
#   Claude Code -> called via the `Stop` hook in settings.json
#
# State (notify_last_sound.txt) is kept next to this script via $PSScriptRoot,
# so the SAME file works whether it lives in ~/.codex or ~/.claude.

param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$EventPayload
)

$statePath = Join-Path $PSScriptRoot "notify_last_sound.txt"
$played = $false

try {
  $mediaDir = "C:\Windows\Media"
  $favoriteSoundNames = @(
    "Alarm03.wav",
    "chimes.wav",
    "tada.wav",
    "Windows Exclamation.wav",
    "Windows Logon.wav"
  )

  $wavCandidates = @(
    $favoriteSoundNames |
      ForEach-Object { Join-Path $mediaDir $_ } |
      Where-Object { Test-Path $_ }
  )

  if ($wavCandidates.Count -gt 0) {
    # Avoid replaying the same sound twice in a row.
    $lastPlayed = ""
    if (Test-Path $statePath) {
      $lastPlayed = (Get-Content -Path $statePath -Raw).Trim()
    }

    $candidatePool = $wavCandidates
    if ($wavCandidates.Count -gt 1 -and $lastPlayed) {
      $candidatePool = @($wavCandidates | Where-Object { $_ -ne $lastPlayed })
      if ($candidatePool.Count -eq 0) { $candidatePool = $wavCandidates }
    }

    $selectedPath = Get-Random -InputObject $candidatePool
    (New-Object System.Media.SoundPlayer $selectedPath).PlaySync()
    Set-Content -Path $statePath -Value $selectedPath -Encoding UTF8
    $played = $true
  }
} catch {}

# Fallback 1: built-in system sounds.
if (-not $played) {
  try {
    [System.Media.SystemSounds]::Exclamation.Play()
    Start-Sleep -Milliseconds 180
    [System.Media.SystemSounds]::Asterisk.Play()
    $played = $true
  } catch {}
}

# Fallback 2: raw console beeps.
if (-not $played) {
  try {
    [Console]::Beep(1200, 240)
    Start-Sleep -Milliseconds 80
    [Console]::Beep(1450, 300)
  } catch {}
}
