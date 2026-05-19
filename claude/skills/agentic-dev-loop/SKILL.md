---
name: agentic-dev-loop
description: Execute autonomous software delivery loops with minimal supervision, including context gathering, implementation, validation, and handoff. Use when users ask the agent to "just do it", request agentic workflows, want end-to-end issue execution, or need repeated build-test-fix cycles with clear stop conditions.
---

# Agentic Dev Loop

## Overview

Run deterministic request-to-delivery loops in a repository without unnecessary user interaction. Prioritize implementation speed, verification rigor, and explicit reporting of assumptions and risks.

## Workflow

1. Establish scope.
- Extract acceptance criteria from the request.
- Infer defaults for low-risk ambiguity and proceed.
- Ask one focused question only if blocked by missing requirements, credentials, or high-risk side effects.

2. Gather context.
- Read repository instructions first (`AGENTS.md`, project docs, relevant configs).
- Use targeted search (`rg --files`, `rg <pattern>`) instead of broad scans.

3. Execute changes.
- Create a short concrete plan (3-7 steps).
- Implement small coherent diffs that preserve existing architecture unless asked otherwise.
- Prefer existing scripts and project tooling before creating new mechanisms.

4. Validate results.
- Run `scripts/run_repo_checks.py --mode quick` during iteration.
- Run `scripts/run_repo_checks.py --mode full` before handoff when feasible.
- If checks fail, fix and rerun until passing or a hard blocker is reached.

5. Handoff clearly.
- Provide changed files, commands executed, and pass/fail status.
- State assumptions, blockers, and residual risks explicitly.
- Suggest next steps only when they are natural and actionable.

## Resource Usage

- Use `scripts/run_repo_checks.py` for stack-aware lint/test/build checks.
- Read `references/workflow-blueprint.md` for autonomy levels and stop conditions.

## Output Contract

Include:
1. Implementation summary.
2. Paths of changed files.
3. Validation commands and outcomes.
4. Blockers or unresolved risks.

Avoid:
- Long speculative plans when direct implementation is possible.
- Claiming checks passed without running them.
- Unscoped refactors unless explicitly requested.
