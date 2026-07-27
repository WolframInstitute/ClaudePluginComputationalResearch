# Work

Execution state for ComputationalResearch — what's being built now.
Each file is one **work item**: a Spec (what to build), Tasks (one ≈ one session), and a Progress log.
Durable knowledge lives in `Wiki/`.

An item's **status is its folder** — there is no status field:

| Folder | Meaning | Names |
|---|---|---|
| `Active/` | in progress | `<Name>.md` |
| `Backlog/` | proposed / not started (drafts live here) | `<Name>.md` |
| `Done/` | completed | `YYYY-MM-DD-<Name>.md` (completion date) |
| `Dropped/` | abandoned / superseded | `YYYY-MM-DD-<Name>.md` (drop date) |

Changing status is a `git mv`.
Names are clean while an item is live and get a date prefix when archived, so `Done/` and `Dropped/` read chronologically.

Run `/next-session` in a **fresh** session to work the next task of an active item — clean context per task is the whole point.
Use `/work` to create a new item.

## Active

The one thing the folders can't show — each in-progress item and its next task.
`Backlog/`, `Done/`, and `Dropped/` are not mirrored here; browse the folders.

`PacletDocumentation` is the only item left. T1 and T2 are done; T3–T6 are blocked on decisions that are the user's — read its Blocked section first.

| Item | Next task |
|---|---|
| [PacletDocumentation](Active/PacletDocumentation.md) | T3 — Draft the `paclet-docs` skill — **blocked**, see the item's Blocked section |
