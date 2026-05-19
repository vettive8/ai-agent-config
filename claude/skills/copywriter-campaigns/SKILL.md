---
name: copywriter-campaigns
description: Write and optimize conversion-focused campaign copy across ads, landing pages, email sequences, and outreach messages. Use when the agent is asked to produce or refine marketing copy from a brief, strategy handoff, or performance feedback.
---

# Copywriter Campaigns

## Overview

Transform a strategy brief into high-converting copy assets tailored by channel and funnel stage. Produce multiple angle variants, clear CTAs, and a reusable testing-ready output pack.

## Collect Required Inputs

Request these inputs before writing:

- Offer details and target action
- ICP profile and pain points
- Channel list (Meta, Google, email, landing page, DM, etc.)
- Funnel stage (cold, warm, hot, retargeting)
- Brand voice and banned words/claims
- Length constraints and format constraints
- Any existing copy to improve or emulate

If details are missing, define assumptions in one short block before outputs.

## Workflow

1. Parse the brief and objective.
2. Derive key message pillars and proof points.
3. Draft channel-specific copy by funnel stage.
4. Generate at least 3 angle variants per key asset.
5. Add CTA and objection-handling lines.
6. Produce test hypotheses and metrics alignment.
7. Package outputs for creative and strategist feedback loops.

## Output Format

Return exactly these sections:

1. `Brief Understanding`
2. `Core Message and Offer Framing`
3. `Copy Assets by Channel`
4. `Variant Set`
5. `CTA Bank`
6. `Compliance and Risk Notes`
7. `A/B Test Suggestions`
8. `Handoff to Creative Performance`
9. `Questions for Strategist`

For `Copy Assets by Channel`, use concise subsections:
- `Ad Primary Text`
- `Headlines`
- `Email Subject Lines`
- `Email Body`
- `Landing Page Hero + CTA`

## Constraints

- Respect character/word limits by channel.
- Prefer concrete benefits over abstract claims.
- Avoid unverifiable promises or regulated claims.
- Keep tone consistent with provided brand voice.
- Include only copy that can be directly deployed or tested.

## Handoff Contract

When handing off to creative/testing pane, include:

- Top 3 copy angles with intended audience emotion
- Asset-level test suggestions (what to swap and why)
- Expected KPI lift hypothesis (CTR, CVR, CPL)
- Do-not-change rules that preserve message integrity

When handing off back to strategist, include:

- Performance assumptions that need strategic validation
- Gaps in offer clarity or ICP precision
- Suggested follow-up questions for client intake

## Invocation Example

Use `$copywriter-campaigns` to produce Meta ad copy, 5 subject lines, and a landing page hero for a webinar lead campaign.
