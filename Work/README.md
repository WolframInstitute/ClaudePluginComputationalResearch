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

- [AuditFixes](Active/AuditFixes.md) — next: T10, final sweep — mechanical checks, version bump, marketplace sync, blog draft.

`Backlog/` is empty.
The one thing left open by the items below is whether `/auto-run` should stop inheriting the user's `~/.claude/settings.json` allow rules — recorded as an open question in [Wiki/Status.md](../Wiki/Status.md#open-questions), not yet filed as an item, because it changes the pipeline's security posture rather than fixing it.

`HardenAutoRun` completed on 2026-07-28 after two tasks: all four never-live `/auto-run` stop conditions fired against real sessions, `--allowedTools` turned out to only ever *add* to the settings files, and the driver gained the Wolfram MCP defaults.
`AutoRunHaltTrial` was dropped on 2026-07-28: the crash-test dummy `HardenAutoRun` drove, whose five tasks were sabotage rather than work — `Dropped/` rather than `Done/` for exactly that reason.
`EvaluateWorkItemsEfficiency` completed on 2026-07-28 after nine tasks: the per-session budget is measured, the item file format is decided and in force, both auto-loaded preambles are audited, the unattended pipeline is built and trialled live, and T5's harvest moved the closed items' durable content into `Wiki/`.
`AutoRunTrial` completed on 2026-07-28: the throwaway item that gave `EvaluateWorkItemsEfficiency` T8 a real item to drive, closing with its `(human)` task done interactively.
`AdoptMarkdownToNotebook` completed on 2026-07-27: `new-notebook` gained an auto-detected rich conversion engine, and `research-notebook` now uses that engine as the parser half of a two-half pipeline with MathNotebook post-processing, generating one-way from a readable `.md`.
`PacletDocumentation` completed on 2026-07-27; paclet presentation moved from a hand-built cloud notebook to real Wolfram documentation, bundled on publish and deployed publicly.
