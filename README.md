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
    git-autosave.ps1   <- auto-commit+push script, used by both agents
  codex/
    config.toml        <- Codex settings (trimmed: no machine paths)
    skills/            <- 6 custom Codex skills
  claude/
    settings.json      <- Claude Code settings (theme + finish-sound hook)
    skills/            <- 7 skills (app-test + the 6 ported from Codex)
```

---

## The two agents at a glance

| | Codex CLI | Claude Code |
|---|---|---|
| Config file | `~/.codex/config.toml` (TOML) | `~/.claude/settings.json` (JSON) |
| Global instructions | `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` |
| Skills folder | `~/.codex/skills/` | `~/.claude/skills/` |
| Finish sound | `notify` array in config.toml | `Stop` hook in settings.json |
| Git auto-save | run manually via `shared/instructions.md` (no hook primitive) | `Stop` hook in settings.json (automatic) |
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

### Claude Code — 7 skills

| Skill | What it does |
|---|---|
| `app-test` | Launches a web app, opens it in a real visible browser (Playwright), runs the app's own `tests/smoke.mjs`, screenshots every step, prints pass/fail. Universal runner — works for any app. |
| 6 ported from Codex | `agentic-dev-loop`, `live-browser-observer`, `livefix-extension`, `growth-strategist`, `creative-performance-lab`, `copywriter-campaigns` — see the Codex table above; descriptions were made agent-neutral. |

> `app-test` needs Playwright. After deploy: `cd ~/.claude/skills/app-test && npm install`.

### Built-in skills (ship with each tool — not portable, listed for reference)

Each agent comes with its own built-ins. These are **not** a gap to close —
they are part of the tool itself.

- **Codex** (`skills/.system/`): `imagegen`, `openai-docs`, `plugin-creator`,
  `skill-creator`, `skill-installer`
- **Claude Code**: `update-config`, `simplify`, `loop`, `schedule`,
  `claude-api`, `init`, `review`, `security-review`, `keybindings-help`,
  `fewer-permission-prompts`

### Git auto-save

`shared/git-autosave.ps1` commits + pushes whatever changed in the current
project after real work happens -- "go back in time" recoverability, even
for incomplete changes. Rules, by design:

- Only acts inside an *existing* git repo. Never auto-runs `git init` in an
  arbitrary folder -- that stays a deliberate, visible action.
- Never stages secret-pattern files (`.env`, `*.pem`, `id_rsa`,
  `*credentials*.json`, etc.) even if they aren't gitignored yet.
- Creates a GitHub remote only if none exists and `gh` is authenticated --
  **always private**. Public is a separate, explicit decision, never
  automatic.
- Never throws -- failures are reported, never block the session.

Claude Code runs it automatically (the `Stop` hook in `claude/settings.json`
fires once per turn). Codex has no equivalent hook primitive, so it's
invoked via an instruction in `shared/instructions.md` instead -- see that
file for the exact wording.

### Skill parity — status

| | Codex | Claude Code |
|---|---|---|
| Custom skills | **6** | **7** (the 6 + `app-test`) |
| Still missing | `app-test` | — |

The 6 Codex skills are now ported into Claude Code with agent-neutral
descriptions (the Codex-only `agents/openai.yaml` was dropped from the Claude
copies). The one remaining gap: `app-test` is not yet in Codex — adding it
there needs an `agents/openai.yaml` wrapper.

---

## What is and isn't cross-agent portable

| Concept | Portable? | Notes |
|---|---|---|
| **Skills** (`SKILL.md`) | ✅ Yes | Same format in both. Codex adds an optional `agents/openai.yaml`; Claude ignores it. |
| **Global instructions** | ✅ Yes | One `shared/instructions.md` → written to `AGENTS.md` *and* `CLAUDE.md`. |
| **Finish-sound script** | ✅ Yes | One `shared/notify.ps1`; keys its state off `$PSScriptRoot` so it runs from either folder. |
| **Git auto-save script** | ✅ Yes (logic) | One `shared/git-autosave.ps1`, callable from any shell. **Wiring differs**: Claude fires it automatically via a `Stop` hook; Codex has no hook primitive, so it's an instruction in `shared/instructions.md` telling the agent to run it after real work. |
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

- ✅ Finish sound — both agents (unified script).
- ✅ Shared instructions — both agents get `instructions.md`.
- ✅ **Skills — the 6 Codex skills are ported into Claude Code** with neutral
  wording. Claude now has 7, Codex has 6.
- ⬜ Add `app-test` to Codex (needs an `agents/openai.yaml`) for 100% parity.
- ⬜ A shared, machine-independent command allowlist (clean replacement for
  Codex's `rules/default.rules`).
