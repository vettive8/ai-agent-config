# ai-agent-config

A portable, shareable setup for the two coding agents I use side by side:
**Codex CLI** and **Claude Code**. Clone this on any machine, run `setup.ps1`,
and both agents come up configured the same way — same skills, same finish
sound, same global instructions.

This repo is a *curated copy* of `~/.codex` and `~/.claude` — only the
share-worthy parts. Secrets and machine state are deliberately left out
(see [Excluded](#deliberately-excluded)).

---

## Repo layout

```
ai-agent-config/
  README.md            <- you are here
  setup.ps1            <- one-click installer (deploys into both agents)
  .gitignore           <- safety net so secrets can never be committed
  shared/
    instructions.md    <- deployed as both AGENTS.md and CLAUDE.md
    notify.ps1         <- the finish-sound script, used by both agents
  codex/
    config.toml        <- Codex settings (trimmed: no machine paths)
    skills/            <- 6 custom Codex skills
  claude/
    settings.json      <- Claude Code settings (theme + finish-sound hook)
    skills/
      app-test/        <- 1 Claude skill
```

---

## The two agents at a glance

| | Codex CLI | Claude Code |
|---|---|---|
| Config file | `~/.codex/config.toml` (TOML) | `~/.claude/settings.json` (JSON) |
| Global instructions | `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` |
| Skills folder | `~/.codex/skills/` | `~/.claude/skills/` |
| Finish sound | `notify` array in config.toml | `Stop` hook in settings.json |
| Model | `gpt-5.5`, reasoning effort `xhigh` | set in-app |

---

## Skills inventory

### Codex — 6 custom skills

| Skill | What it does | Extras |
|---|---|---|
| `agentic-dev-loop` | Autonomous request-to-delivery loops with minimal supervision: scope, implement, validate, hand off. Repeated build-test-fix cycles with clear stop conditions. | `references/`, `scripts/run_repo_checks.py` |
| `live-browser-observer` | Headed Playwright sessions you can watch live, with step logs, screenshots, and optional autonomous retry/fix loops. | `references/`, `scripts/run_live_playwright_loop.ps1` |
| `livefix-extension` | Playwright-based Chrome-extension QA and autofix loops using the LiveFix toolkit; scaffolds adapter files, runs smoke/live sessions. | `references/command-recipes.md` |
| `growth-strategist` | Growth strategy: offers, positioning, funnels, channels, KPI plans, weekly roadmaps for agency clients. | — |
| `creative-performance-lab` | Performance-creative systems: hooks, concepts, test matrices, iteration loops tied to KPIs. | — |
| `copywriter-campaigns` | Conversion-focused campaign copy: ads, landing pages, email sequences, outreach. | — |

Each Codex skill folder = `SKILL.md` + `agents/openai.yaml` (Codex-specific).

### Claude Code — 1 skill

| Skill | What it does |
|---|---|
| `app-test` | Launches a web app, opens it in a real visible browser (Playwright), runs the app's own `tests/smoke.mjs`, screenshots every step, prints pass/fail. Universal runner — works for any app. |

> `app-test` needs Playwright. After deploy: `cd ~/.claude/skills/app-test && npm install`.

### Built-in skills (ship with each tool — not portable, listed for reference)

Each agent comes with its own built-ins. These are **not** a gap to close —
they are part of the tool itself.

- **Codex** (`skills/.system/`): `imagegen`, `openai-docs`, `plugin-creator`,
  `skill-creator`, `skill-installer`
- **Claude Code**: `update-config`, `simplify`, `loop`, `schedule`,
  `claude-api`, `init`, `review`, `security-review`, `keybindings-help`,
  `fewer-permission-prompts`

### The difference — what "maximize" means

| | Codex | Claude Code |
|---|---|---|
| Custom skills | **6** | **1** (`app-test`) |
| Missing vs. the other | `app-test` | all **6** Codex skills |

To reach parity:

1. Copy the 6 Codex skills into Claude Code. `SKILL.md` is the same format;
   the extra `agents/openai.yaml` is harmless (Claude ignores it).
2. Edit each skill's description — they currently say *"Use when Codex is
   asked to..."*. Make the wording agent-neutral so it triggers in Claude too.
3. Optionally add `app-test` to Codex (needs an `agents/openai.yaml`).
4. Test: launch each agent and confirm the new skills are listed.

---

## What is and isn't cross-agent portable

| Concept | Portable? | Notes |
|---|---|---|
| **Skills** (`SKILL.md`) | ✅ Yes | Same format in both. Codex adds an optional `agents/openai.yaml`; Claude ignores it. |
| **Global instructions** | ✅ Yes | One `shared/instructions.md` → written to `AGENTS.md` *and* `CLAUDE.md`. |
| **Finish-sound script** | ✅ Yes | One `shared/notify.ps1`; keys its state off `$PSScriptRoot` so it runs from either folder. |
| **Settings file** | ⚠️ Concept only | TOML vs JSON — the *ideas* map (model, sound), the files don't. |
| **Sound wiring** | ⚠️ Per-agent | Codex `notify =` array vs Claude `Stop` hook. |
| **Auto-approvals** | ❌ No | Codex `rules/*.rules` vs Claude `permissions` — different models. |
| **Plugins** | ❌ No | OpenAI marketplaces vs Anthropic marketplace — different ecosystems. |

---

## Deploy to a machine

```powershell
git clone <this-repo-url> ai-agent-config
cd ai-agent-config
.\setup.ps1
```

`setup.ps1` copies everything into `~/.codex` and `~/.claude`, patches the
finish-sound paths for the current Windows user, and backs up any existing
file to `<name>.bak` first. Then log in to each agent normally.

> Don't run `setup.ps1` on the machine this repo was captured from — it would
> overwrite your live `config.toml` / `settings.json` with the trimmed
> templates (backups are still made).

---

## Deliberately excluded

Never in this repo — `.gitignore` blocks them as a safety net:

- **Secrets:** `auth.json`, `.credentials.json` — login tokens.
- **Machine state:** `sessions/`, `logs_*.sqlite`, `cache/`, `projects/`,
  `file-history/`, `installation_id`, `notify.log`.
- **Codex `rules/default.rules`:** auto-approval rules hardcoded to one
  machine's project paths — useless elsewhere.
- **`[projects]` trust list:** machine-specific folder paths.
- **`node_modules/`:** reinstalled with `npm install`.

---

## Parity status & next steps

Current state — **Codex is richer than Claude Code:**

- ✅ Finish sound — both agents (unified script).
- ✅ Shared instructions — both agents get `instructions.md`.
- ⬜ **Skills not yet at parity:** Codex has 6, Claude has 1. The 6 Codex
  `SKILL.md` files work in Claude as-is — copying them into `claude/skills/`
  is the next move toward full parity.
- ⬜ `app-test` could also be added to Codex (add an `agents/openai.yaml`).
- ⬜ A shared, machine-independent command allowlist (clean replacement for
  Codex's `rules/default.rules`).
