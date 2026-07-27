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

`PacletDocumentation` is the only active item. T1, T2, T3 and T6 are done — `demo-notebook` is retired, `paclet-docs` is drafted against the official MCP doc tools, and guide pages are out of scope.
T4 still needs a human at a front end for the F1 lookup, and T5 owes the deployed docs URL that the README lost.
`Backlog/AdoptMarkdownToNotebook.md` holds the deferred MarkdownToNotebook question.

| Item | Next task |
|---|---|
| [PacletDocumentation](Active/PacletDocumentation.md) | T4 — Generate docs for one real paclet; verify (F1 step needs a human) |
