---
name: creative-performance-lab
description: Design and evaluate performance creative systems including hooks, concepts, test matrices, and iteration loops. Use when the agent is asked to plan creative experiments, diagnose underperforming ads, or produce structured test-and-learn plans tied to KPIs.
---

# Creative Performance Lab

## Overview

Convert campaign goals into a repeatable creative testing system with clear hypotheses, controls, and scaling rules. Focus on measurable learning velocity and performance lift across paid and organic channels.

## Collect Required Inputs

Request these inputs before designing tests:

- Offer and audience summary
- Channel/platform and placement constraints
- Current creative inventory and prior winners/losers
- Baseline performance metrics (CTR, CPC, CPM, CVR, CPA)
- Production constraints (team bandwidth, asset types, deadlines)
- Budget by test cycle

If data is incomplete, document assumptions and define a minimum viable test plan.

## Workflow

1. Diagnose current performance and bottlenecks.
2. Define 1 primary KPI and 2 supporting KPIs per test cycle.
3. Generate creative hypotheses mapped to funnel stage.
4. Build test matrix with one variable changed at a time.
5. Set launch checklist and measurement windows.
6. Define stop, hold, iterate, and scale thresholds.
7. Produce a feedback packet for strategist and copywriter.

## Output Format

Return exactly these sections:

1. `Performance Diagnosis`
2. `Creative Hypotheses`
3. `Test Matrix`
4. `Asset Briefs`
5. `Measurement Plan`
6. `Decision Rules (Stop/Scale/Iterate)`
7. `Weekly Learning Agenda`
8. `Handoff to Copywriter`
9. `Handoff to Strategist`

For `Test Matrix`, include columns:
- `Concept`
- `Variable`
- `Control`
- `KPI`
- `Sample Size Target`
- `Decision Date`

## Constraints

- Limit each cycle to a manageable number of tests.
- Avoid changing multiple core variables in one test cell.
- Tie every creative idea to a measurable outcome.
- Keep asset briefs implementation-ready and channel-specific.
- Flag any tracking gaps that reduce confidence in results.

## Handoff Contract

When handing off to copywriter, include:

- Winning and risky message angles
- Hook style guidance by platform
- Mandatory proof points and CTA direction
- Character-limit targets for each placement

When handing off to strategist, include:

- Budget reallocation recommendation
- Channel-level scaling decision
- Confidence level and data-quality notes
- Next cycle hypothesis priorities

## Invocation Example

Use `$creative-performance-lab` to design a 2-week test matrix for improving CTR and reducing CPA on Meta lead ads.
