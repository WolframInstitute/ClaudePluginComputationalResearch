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

- **EvaluateWorkItemsEfficiency** — next: T6, audit this repo's 16.6 kB `CLAUDE.md` against `README.md` and decide what a session actually needs auto-loaded.
  It moved ahead of implementing the pipeline (T7) and trialling it (T8) because the fixed preamble is the pipeline's dominant cost line, at a measured 31.5 k tokens per cold task.
  T1's measurement is in [Wiki/Concepts/SessionInformationBudget.md](../Wiki/Concepts/SessionInformationBudget.md), T2's in [Wiki/Concepts/ProgressWikiSplit.md](../Wiki/Concepts/ProgressWikiSplit.md), T3's format decision — now in force — in [Wiki/Concepts/ItemFileFormat.md](../Wiki/Concepts/ItemFileFormat.md), and T4's pipeline spec in [Wiki/Concepts/AutonomousPipeline.md](../Wiki/Concepts/AutonomousPipeline.md).

`AdoptMarkdownToNotebook` completed on 2026-07-27: `new-notebook` gained an auto-detected rich conversion engine, and `research-notebook` now uses that engine as the parser half of a two-half pipeline with MathNotebook post-processing, generating one-way from a readable `.md`.
`PacletDocumentation` completed on 2026-07-27; paclet presentation moved from a hand-built cloud notebook to real Wolfram documentation, bundled on publish and deployed publicly.
