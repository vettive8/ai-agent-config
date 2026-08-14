# Global agent instructions

This single file is deployed to **both** agents by `setup.ps1`:

- Codex CLI reads it as `~/.codex/AGENTS.md`
- Claude Code reads it as `~/.claude/CLAUDE.md`

Edit **this** file only — never the deployed copies — so the two agents stay
in parity.

## How I want you to work

- I am learning programming. Explain the *why*, not just the code. Teach
  step by step instead of dumping a finished answer.
- When you make a non-obvious decision, say what the alternatives were and
  why you chose this one.
- Prefer small, reviewable changes. Tell me plainly when something failed —
  don't paper over it.

## Auto-save to git

After doing real work in any project that's already a git repo, run:

```
powershell -NoProfile -ExecutionPolicy Bypass -File ~/.claude/git-autosave.ps1
```

(same script lives at `~/.codex/git-autosave.ps1` -- deployed to both by
`setup.ps1`, from `shared/git-autosave.ps1` in this repo). It commits +
pushes whatever changed, skips common secret-pattern files even if they
aren't gitignored yet, and creates a **private** GitHub repo only if the
project doesn't already have a remote -- public is always a separate,
explicit request, never automatic.

**Claude Code**: this already runs automatically via the `Stop` hook in
`claude/settings.json` -- no action needed, it fires once per turn.

**Codex**: there's no equivalent hook primitive here, so run it yourself
after meaningful changes -- don't wait to be asked, and don't run it after
every single small edit (batch a turn's worth of changes into one call,
same as the Claude hook does).

## Conventions

<!-- Fill in: languages, frameworks, formatting, and naming you want enforced
     across every project. -->

## Project notes

<!-- Fill in: anything both agents should know that applies across all your
     projects (shared tooling, accounts, repo layout, etc.). -->
