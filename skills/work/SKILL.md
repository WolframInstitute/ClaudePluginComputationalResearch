---
name: work
description: >
  Create and manage work items in the top-level Work/ folder — each a
  multi-session effort with a Spec (what to build), a Tasks checklist (one task
  ≈ one session), and a Progress log. This is the project's execution state,
  separate from the Wiki knowledge base. Use for: "new work item", "start a
  work item", "spec out X", "plan for X", "break X into tasks", "track this
  across sessions", "add a task", "update the spec", or the /work command.
  Creates Work/<Name>.md, bootstrapping the folder if missing. Specs follow the
  revise protocol. Do NOT trigger on casual uses of the word "work".
---

# Work Items

`Work/` is the project's execution state — what we're building right now. Each
file is one **work item**: a Spec (what to build), Tasks (one ≈ one session), and
a Progress log. Durable knowledge goes in `Wiki/`; planning and progress go here.

Work items follow the `revise` protocol — the LLM drafts the Spec, presents it,
and waits for approval before work begins.

## Bootstrap

If `Work/` does not exist, create it and seed `Work/README.md` from
`${CLAUDE_PLUGIN_ROOT}/skills/new-project/assets/work_readme_template.md`
(substitute the project name). The folder is tracked in git — do not gitignore it.

## Creating a work item

### 1. Draft

Ask for a CamelCase name and a one-line goal. Copy
`${CLAUDE_PLUGIN_ROOT}/skills/new-project/assets/work_item_template.md` to
`Work/<Name>.md`, set the heading, and draft the `## Spec` — for a quick item the
one-paragraph goal is enough; for a heavy one fill Requirements / Design / Edge cases.

Fill the `Origin:` line in the Spec with the user's originating request. If the
project has prompt tracking on (see the [provenance](../provenance/SKILL.md)
skill), also append a `Wiki/Prompts.md` ledger entry for the new item.

### 2. Present and wait

Show the Spec and wait (revise loop). On approval, flip `> Status: **draft**` →
`**active**`.

### 3. Decompose into tasks

Derive `## Tasks` from the approved Spec — each unchecked box should be one focused
session. Present, revise, then add the item to the board in `Work/README.md`.

## The board

`Work/README.md` holds a table of every item with its status and next unchecked
task. Update the row whenever an item is created, its status changes, or its next
task changes. This is the at-a-glance "what's on my plate" view.

## Status transitions

- `**draft**` — Spec written, not yet approved
- `**active**` — approved, in progress
- `**done**` — all tasks complete
- `**abandoned**` — explicitly dropped

## Updating the spec later

The Spec is the contract. If the user edited it, it is protected content: describe
the proposed change, wait for approval, edit, then add a row to `## Decisions`. If
it is LLM-drafted and unapproved, edit directly.

## Relationship to other skills

- `next-session` executes one task per fresh session against an item created here.
- `update-wiki` records durable knowledge in `Wiki/` — this skill does not touch
  the Wiki; it manages execution state only.
- The `revise` protocol governs every Spec and task-list interaction.
- For Lean formalization, `lean` creates a `Type: formalization` item here.
