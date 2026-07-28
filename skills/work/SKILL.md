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
Each file is one **work item**: a Spec, Tasks (one ≈ one session), a Hand-off for the next session, and a one-line Progress log.
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

The Spec and other item prose follow the `Semantic line breaks` toggle in `CLAUDE.md` § *Source formatting*.

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

## The item file format

Five sections, and they are the whole file: `## Spec`, `## Tasks`, `## Hand-off`, `## Decisions`, `## Progress`.
Do not add a sixth — measured, invented sections are always a destination violation (an item's conclusions belong in `Wiki/`, a blocker in `## Hand-off`, draft content in the artifact).
Rationale and measurements: [Wiki/Concepts/ItemFileFormat.md](../../Wiki/Concepts/ItemFileFormat.md) in this repo.

**One fact, one destination — nothing is written twice.**

| the fact is… | it lives in | and it is |
|---|---|---|
| durable — about a tool, an artifact, this project | a `Wiki/` article | corrected in place when it changes |
| a choice between real alternatives | one `## Decisions` row | edited when reversed |
| the Spec being wrong | the Spec sentence | replaced |
| what the next session needs and is not yet true anywhere else | `## Hand-off` | overwritten each session |
| that a session happened | one `## Progress` line | left alone |

Only `## Progress` grows with session count, at one line, so the read a session pays is flat.
`## Hand-off` and `## Decisions` are the sections that make that possible: they give every corrigible thing a mutable home, so the append-only log never has to carry a correction.

- **`## Spec`** — the contract. Corrected in place; never appended to. Findings are not Spec material. Past ~1 screen it is a signal the item should have been split.
- **`## Hand-off`** — one block, rewritten (or emptied) every session. Half-finished state, a blocker, an open branch. Not a diary.
- **`## Decisions`** — a row is earned by a choice between real alternatives that a later session could otherwise re-litigate. One sentence for the decision, one for the rationale, a link for the evidence. A reversal **edits** the row it reverses; the table never holds a row and its contradiction.
- **`## Progress`** — append-only, one line per session, and nothing reads it. It is the audit trail for a human and for git.

Closed items are **not** rewritten or pruned — git already holds every version, and a closed item is read at most once more.
When a later pass finds a claim in an archived Progress block that is false today, append one line under that block rather than deleting the claim:

```
> Superseded: <what is true now> — see [Article](../../Wiki/...).
```

Items written before this format keep their old Progress blocks; the next session on one adds a `## Hand-off` and writes its own line in the new shape.

### The autonomy markers

Two optional, hand-written markers control whether `/auto-run` may work the item unattended.
Both are opt-in and fail closed — an unmarked item is never picked.

- **`> Autonomous: allowed`** — one more `>` header line beside `> Type:`, above `## Spec`. It makes the whole item eligible. Add it only when the user asks for it; it is their decision, not the drafting session's.
- **`(human)`** — appended to a single task line. The driver halts before running that task, so an author can gate one step of an otherwise autonomous item — a spec that must be presented, a deliverable the user wants to see generated.

Neither adds a section, so the five-section rule holds.
The driver, the stop conditions, and why the `revise` gate survives this: [Wiki/Concepts/AutonomousPipeline.md](../../Wiki/Concepts/AutonomousPipeline.md).

## Updating the spec later

The Spec is the contract, and it is **edited in place** — a session that finds it wrong replaces the sentence rather than appending an amendment.
If the user edited it, it is protected content: describe the proposed change, wait for approval, edit, then add one `## Decisions` row.
If it is LLM-drafted and unapproved, edit directly.

## Relationship to other skills

- `next-session` executes one task per fresh session against an item created here.
  In a paclet-dev repo, an item that changes paclet code is developed on a `work/<item>` branch in a gitignored `<Paclet>--<item>/` worktree and lands as a PR on that paclet's repo (the dev repo stays on `main`) — name the target paclet in the Spec.
- `update-wiki` records durable knowledge in `Wiki/` — this skill does not touch the Wiki; it manages execution state only.
- The `revise` protocol governs every Spec and task-list interaction.
- For Lean formalization, `lean` creates a `Type: formalization` item here.
