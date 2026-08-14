# git-autosave.ps1
#
# Runs after every Claude Code turn (Stop hook). Commits + pushes whatever
# changed in the current repo so work-in-progress is always recoverable.
#
# Safety rules, by design:
#   - Does nothing outside an existing git repo. Never auto-runs `git init`
#     in an arbitrary folder -- that stays a deliberate, visible action.
#   - Never stages files matching common secret patterns (.env, *.pem,
#     id_rsa, *credentials*.json, etc.), even if not yet gitignored.
#   - Creates a GitHub remote only if one doesn't exist yet, only if `gh`
#     is authenticated, and always as PRIVATE. Public is a separate,
#     explicit decision, never automatic.
#   - Never throws: any failure is swallowed and reported via
#     systemMessage so it's visible without ever blocking the session.

$ErrorActionPreference = "Continue"
# Deliberately NOT "Stop": on Windows PowerShell 5.1, redirecting a native
# command's stderr (git/gh routinely print benign warnings there) wraps it
# in a NativeCommandError, which "Stop" then turns into a terminating
# exception. Exit codes are checked explicitly below instead.

function Emit-Message($text) {
    (@{ systemMessage = $text } | ConvertTo-Json -Compress)
}

try {
    $inRepo = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $inRepo -ne "true") {
        exit 0
    }

    $status = git status --porcelain 2>$null
    if (-not $status) {
        exit 0
    }

    $secretPatterns = @('*.env', '.env.*', '*credentials*.json', '*.pem', 'id_rsa', 'id_ed25519', '*.key', '*secret*')
    $changedFiles = $status | ForEach-Object {
        # porcelain format: "XY path" (or "XY old -> new" for renames) -- take the last path token
        ($_.Substring(3).Trim().Trim('"') -split ' -> ')[-1]
    }
    $risky = $changedFiles | Where-Object {
        $f = $_
        ($secretPatterns | Where-Object { $f -like $_ }).Count -gt 0
    }

    git add -A *>$null
    foreach ($f in $risky) {
        git reset -- "$f" *>$null
    }

    $staged = git diff --cached --name-only 2>$null
    if (-not $staged) {
        if ($risky) {
            Emit-Message "git-autosave: skipped -- only secret-pattern files changed ($($risky -join ', ')), nothing safe to commit"
        }
        exit 0
    }

    $stagedList = @($staged)
    $summary = ($stagedList | Select-Object -First 3) -join ", "
    $more = if ($stagedList.Count -gt 3) { " +$($stagedList.Count - 3) more" } else { "" }
    git commit -m "auto-save: $summary$more" --quiet *>$null

    $remotes = git remote 2>$null
    if (-not $remotes) {
        & gh auth status *>$null
        if ($LASTEXITCODE -eq 0) {
            $repoName = Split-Path -Leaf (git rev-parse --show-toplevel)
            gh repo create $repoName --private --source=. --remote=origin --push *>$null
            if ($LASTEXITCODE -eq 0) {
                Emit-Message "git-autosave: committed + created private GitHub repo '$repoName' + pushed"
                exit 0
            }
        }
        Emit-Message "git-autosave: committed locally (no GitHub remote, could not auto-create one)"
        exit 0
    }

    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    git push --quiet *>$null
    if ($LASTEXITCODE -ne 0) {
        git push --quiet --set-upstream origin $branch *>$null
    }
    if ($LASTEXITCODE -eq 0) {
        Emit-Message "git-autosave: committed + pushed ($($stagedList.Count) file(s))"
    } else {
        Emit-Message "git-autosave: committed locally, push failed (check remote/auth)"
    }
} catch {
    Emit-Message "git-autosave error (non-fatal): $($_.Exception.Message)"
    exit 0
}
