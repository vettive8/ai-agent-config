# Agentic Workflow Blueprint

## Purpose
Define how to operate with high autonomy while keeping safety and quality constraints explicit.

## Autonomy Levels
Use one level per task and escalate only when needed.

1. Guided
- Ask before major code changes.
- Use when requirements are unstable.

2. Active
- Implement directly and ask only for blocking decisions.
- Use for standard feature work and bug fixes.

3. Autonomous
- Run full discover-plan-implement-validate loop without pauses.
- Use for well-scoped engineering tasks.

4. Unattended
- Execute non-interactively on a schedule/CI runner.
- Use only with strict repository guardrails and deterministic checks.

## Stop Conditions
Stop and ask the user only if one of these applies:
- Required credentials, keys, or external access are unavailable.
- A destructive or production-impacting action is required.
- Two plausible implementations have materially different product behavior.
- Validation cannot run because required tooling is missing.

## Validation Policy
- Prefer project-native checks first.
- Run quick checks during iteration.
- Run full checks before handoff when feasible.
- Report exact commands and status codes.

## Suggested Prompt Pattern
Use this prompt for autonomous execution in Codex:

```text
Execute this task end-to-end with minimal interruptions.
Infer reasonable defaults, implement changes, run checks, and provide a concise handoff.
Ask questions only if blocked by credentials, destructive risk, or conflicting requirements.
```
