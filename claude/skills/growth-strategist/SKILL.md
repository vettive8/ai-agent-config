---
name: growth-strategist
description: Build growth strategy for offers, positioning, funnels, channels, and KPI plans. Use when the agent is asked to plan campaigns, choose channels, define audience segments, map customer journeys, set goals, or produce a weekly growth roadmap for an agency client.
---

# Growth Strategist

## Overview

Design a practical growth plan that converts a business goal into audience targeting, channel priorities, offers, and measurable KPIs. Produce clear decisions, assumptions, and a handoff brief for execution-focused agents.

## Collect Required Inputs

Request these inputs before planning:

- Business and offer summary
- Primary goal (leads, booked calls, sales, retention)
- Time horizon (7, 30, or 90 days)
- Budget range and channel constraints
- Existing assets (landing pages, email list size, creatives, CRM)
- Current baseline metrics (traffic, CVR, CPL/CPA, close rate)
- Audience and market context (ICP, geo, language, competitors)

If any critical input is missing, state assumptions explicitly and continue.

## Workflow

1. Clarify objective and success metric.
2. Segment audience and pick primary ICP.
3. Choose channel mix and justify priority order.
4. Define funnel stages and core offer per stage.
5. Recommend messaging angles and objections to handle.
6. Set KPI targets and weekly checkpoints.
7. Create a 7-day action plan with owner-level tasks.
8. Produce handoff blocks for copy and creative agents.

## Output Format

Return exactly these sections:

1. `Strategy Snapshot`
2. `Audience and Offer`
3. `Channel Priority`
4. `Funnel Plan`
5. `KPI Targets`
6. `7-Day Execution Plan`
7. `Risks and Assumptions`
8. `Handoff to Copywriter`
9. `Handoff to Creative Performance`

Use compact tables for channel priority and KPIs.

## Constraints

- Prioritize decisions over generic advice.
- Keep recommendations feasible for the stated budget and asset maturity.
- Use measurable targets; avoid vague KPI language.
- Keep total response concise enough for direct execution handoff.
- Flag legal/compliance-sensitive claims for manual review.

## Handoff Contract

When handing off to other panes, include two blocks:

`Handoff to Copywriter`
- Campaign objective
- ICP and pain points
- Offer and CTA
- Channel and format list
- Tone requirements and forbidden claims

`Handoff to Creative Performance`
- Top 3 creative angles
- Hook hypotheses
- Test matrix (variable, control, success metric)
- Budget split recommendation
- Stop/scale rules

## Invocation Example

Use `$growth-strategist` to build a 30-day lead-generation strategy for a local service business with a $2,000 monthly ad budget.
