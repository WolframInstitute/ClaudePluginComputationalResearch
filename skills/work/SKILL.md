---
name: work
description: >
  Create and manage work items in the top-level Work/ folder — each a
  multi-session effort with a Spec (what to build), a Tasks checklist (one task
  ≈ one session), and a Progress log. This is the project's execution state,
  separate from the Wiki knowledge base. Use for: "new work item", "start a
  work item", "spec out X", "plan for X", "break X into tasks", "track this
  across sessions", "add a task", "update the spec", or the /work command.
  Creates Work/Backlog/<Name>.md, bootstrapping the folder if missing. A work
  item's status is its folder (Active/Backlog/Done/Dropped), not a field. Specs
  follow the revise protocol. Do NOT trigger on casual uses of the word "work".
---

# Work Items

`Work/` is the project's execution state — what we're building right now.
Each file is one **work item**: a Spec (what to build), Tasks (one ≈ one session), and a Progress log.
Durable knowledge goes in `Wiki/`; planning and progress go here.

Work items follow the `revise` protocol — the LLM drafts the Spec, presents it, and waits for approval before work begins.

## Folders are the status

An item's status is **which folder it lives in** — there is no status field.
State is encoded once, in the filesystem; changing state is a `git mv`.

```
Work/
├── README.md     — index: active items + their next task; buckets are linked, not re-listed
├── Active/       — in progress              <Name>.md
├── Backlog/      — proposed / not started   <Name>.md            (drafts live here)
├── Done/         — completed                YYYY-MM-DD-<Name>.md  (by completion date)
└── Dropped/      — abandoned / superseded   YYYY-MM-DD-<Name>.md  (by drop date)
```

Names are **clean** (`<Name>.md`, CamelCase) while an item is live in `Active/` or `Backlog/` — that is what you reference it by.
On archival the file is `git mv`'d into `Done/` or `Dropped/` and **prefixed with that day's date** (`date +%F`), so the archives read chronologically.
Resolve an item by name with an exact path in `Active/` then `Backlog/`; glob `Done/*-<Name>.md` and `Dropped/*-<Name>.md` for archived ones.

## Bootstrap

If `Work/` does not exist, create it and seed `Work/README.md` from `${CLAUDE_PLUGIN_ROOT}/skills/new-project/assets/work_readme_template.md` (substitute the project name).
The folder is tracked in git — do not gitignore it.
Create each bucket (`Active/`, `Backlog/`, `Done/`, `Dropped/`) lazily the first time an item lands in it.

## Creating a work item

### 1. Draft

Ask for a CamelCase name and a one-line goal.
Copy `${CLAUDE_PLUGIN_ROOT}/skills/new-project/assets/work_item_template.md` to `Work/Backlog/<Name>.md`, set the heading, and draft the `## Spec` — for a quick item the one-paragraph goal is enough; for a heavy one fill Requirements / Design / Edge cases.

Fill the `Origin:` line in the Spec with the user's originating request.
If the project has prompt tracking on (see the [provenance](../provenance/SKILL.md) skill), also append a `Wiki/Prompts.md` ledger entry for the new item.

When `CLAUDE.md` has `Semantic line breaks: on` (the default — see its *Source formatting* rule), write the Spec and other prose in this item one sentence per source line.

### 2. Present and wait

Show the Spec and wait (revise loop).
A spec in `Backlog/` is still a malleable draft; approval is the gate to starting work, not a field to flip.

### 3. Decompose into tasks

Derive `## Tasks` from the approved Spec — each unchecked box should be one focused session.
To start work now, `git mv` the file into `Active/` (it is now the approved contract) and add it to the index in `Work/README.md`.
To queue it for later, leave it in `Backlog/`.

## The index

`Work/README.md` lists the **Active** items and each one's next unchecked task — the one thing the folders can't show.
It does **not** re-list `Backlog/`, `Done/`, or `Dropped/`; those are just linked, since the folder is already the record.
Update an active item's line when its next task changes; drop the line when the item leaves `Active/`.

## Lifecycle (move the file)

- **Backlog → Active** — start work (`git mv` into `Active/`, clean name).
- **Active → Backlog** — park an item you're not working now.
- **Active → Done** — all tasks complete; `git mv` into `Done/`, prefix with today's date.
- **Active/Backlog → Dropped** — abandoned or superseded; `git mv` into `Dropped/`, prefix with today's date.

After any move, fix `Work/README.md` (it tracks only `Active/`).

## Updating the spec later

The Spec is the contract.
If the user edited it, it is protected content: describe the proposed change, wait for approval, edit, then add a row to `## Decisions`.
If it is LLM-drafted and unapproved, edit directly.

## Relationship to other skills

- `next-session` executes one task per fresh session against an item created here.
  In a paclet-dev repo, an item that changes paclet code is developed on a `work/<item>` branch in a gitignored `<Paclet>--<item>/` worktree and lands as a PR on that paclet's repo (the dev repo stays on `main`) — name the target paclet in the Spec.
- `update-wiki` records durable knowledge in `Wiki/` — this skill does not touch the Wiki; it manages execution state only.
- The `revise` protocol governs every Spec and task-list interaction.
- For Lean formalization, `lean` creates a `Type: formalization` item here.
