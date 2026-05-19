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

## Conventions

<!-- Fill in: languages, frameworks, formatting, and naming you want enforced
     across every project. -->

## Project notes

<!-- Fill in: anything both agents should know that applies across all your
     projects (shared tooling, accounts, repo layout, etc.). -->
