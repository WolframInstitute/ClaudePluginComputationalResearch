# Work

Execution state for ComputationalResearch — what's being built now.
Each file is one **work item**: a Spec, Tasks (one ≈ one session), a Hand-off for the next session, and a one-line Progress log.
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

_(none)_

`HardenAutoRun` is in `Backlog/` and is the obvious next thing to start: two sessions to trip `/auto-run`'s three still-stub-tested stop conditions live and to fill its empty MCP allowlist.

`EvaluateWorkItemsEfficiency` completed on 2026-07-28 after nine tasks: the per-session budget is measured, the item file format is decided and in force, both auto-loaded preambles are audited, the unattended pipeline is built and trialled live, and T5's harvest moved the closed items' durable content into `Wiki/`.
`AutoRunTrial` completed on 2026-07-28: the throwaway item that gave `EvaluateWorkItemsEfficiency` T8 a real item to drive, closing with its `(human)` task done interactively.
`AdoptMarkdownToNotebook` completed on 2026-07-27: `new-notebook` gained an auto-detected rich conversion engine, and `research-notebook` now uses that engine as the parser half of a two-half pipeline with MathNotebook post-processing, generating one-way from a readable `.md`.
`PacletDocumentation` completed on 2026-07-27; paclet presentation moved from a hand-built cloud notebook to real Wolfram documentation, bundled on publish and deployed publicly.
