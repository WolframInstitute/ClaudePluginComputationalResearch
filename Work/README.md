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

`AdoptMarkdownToNotebook` went active on 2026-07-27 when its blocking Phase 0 question — the licence — was answered.
`PacletDocumentation` completed on 2026-07-27; paclet presentation moved from a hand-built cloud notebook to real Wolfram documentation, bundled on publish and deployed publicly.

| Item | Next task |
|---|---|
| [AdoptMarkdownToNotebook](Active/AdoptMarkdownToNotebook.md) | T4 — implement `new-notebook`'s opt-in rich mode against the pinned local clone and register the resource in `Wiki/` (`init-wiki` first). |
