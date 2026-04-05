---
name: wiki-plan
description: >
  Create or update a plan in the wiki. Plans are structured documents in
  Wiki/Plans/ with goals, steps, decisions, and history. Use when the user
  says "plan for X", "let's plan", "add a plan", "update plan", "what's
  the plan", or when a multi-step task needs organization before execution.
---

# Wiki Plan Management

Plans live in `Wiki/Plans/` and follow the revision workflow — the LLM
drafts, presents to the user, and waits for feedback before proceeding.

## Prerequisites

`Wiki/` must exist. If it doesn't, invoke `wiki-init` first.

## Creating a new plan

### 1. Draft the plan

```markdown
# Plan: Title

> Status: **draft**

## Goal

What we're trying to achieve. One clear paragraph.

## Steps

- [ ] Step 1 — brief description
- [ ] Step 2 — brief description
- [ ] Step 3 — brief description

## Decisions

(none yet)

## History

| Date | Actor | Action |
|---|---|---|
| YYYY-MM-DD | LLM | Created plan |
```

### 2. Present to the user

Show the plan and wait for feedback. The user may:

- Approve as-is → save and index
- Revise steps → update and re-present
- Reject entirely → discard or start over

### 3. Save and index

Write to `Wiki/Plans/PlanName.md`. Add to `Wiki/Index.md` under Plans:

```markdown
- [Plan Name](Plans/PlanName.md) — one-line summary
```

Append to `Wiki/Log.md`.

## Updating an existing plan

### Completing steps

When a step is done, mark it:

```markdown
- [x] Step 2 — brief description
```

Add a history entry:

```markdown
| YYYY-MM-DD | LLM | Completed step 2 |
```

Update `Wiki/Status.md` if the overall project state changed.

### Revising the plan

If the user or circumstances require changes:

1. If the plan was **user-edited** (protected content): describe proposed
   changes and wait for approval
2. If the plan was **LLM-generated**: update directly, note in history

Always add a history entry for revisions:

```markdown
| YYYY-MM-DD | Human | Revised: changed step 3 to ... |
| YYYY-MM-DD | LLM | Updated plan per user feedback |
```

### Status transitions

Update the status line as the plan progresses:

- `**draft**` — initial state, not yet approved
- `**active**` — approved, work in progress
- `**completed**` — all steps done
- `**abandoned**` — explicitly dropped

## Plan naming

Use descriptive PascalCase names: `WikiMigration.md`, `RicciCurvatureExploration.md`,
`NotebookRefactor.md`. Keep names short but specific enough to distinguish
from other plans.

## Relationship to other skills

- Plans often trigger `wiki-update` when steps are completed
- Plans may reference `resource-add` for gathering materials
- Tour generation (`tour-start`) may follow a plan
- The `revise` protocol applies to all plan interactions
