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

- **AutoRunTrial** — next: T1, write the `/auto-run` operator runbook. Marked `> Autonomous: allowed`; it exists to give the driver a real session to work under `EvaluateWorkItemsEfficiency` T8's supervision, and is disposable once that trial is over.
- **EvaluateWorkItemsEfficiency** — next: T8, trial the pipeline supervised on one real item and confirm the stop conditions fire.
  T7 built it — `scripts/auto-run.sh` behind `/auto-run` — and verified every stop condition against a stub; no item is marked `> Autonomous: allowed` yet, and T8 should mark a throwaway rather than this one.
  T1's measurement is in [Wiki/Concepts/SessionInformationBudget.md](../Wiki/Concepts/SessionInformationBudget.md), T2's in [Wiki/Concepts/ProgressWikiSplit.md](../Wiki/Concepts/ProgressWikiSplit.md), T3's format decision — now in force — in [Wiki/Concepts/ItemFileFormat.md](../Wiki/Concepts/ItemFileFormat.md), T4's spec and T7's implementation map in [Wiki/Concepts/AutonomousPipeline.md](../Wiki/Concepts/AutonomousPipeline.md), and T6's audit in [Wiki/Concepts/PreambleAudit.md](../Wiki/Concepts/PreambleAudit.md).

`AdoptMarkdownToNotebook` completed on 2026-07-27: `new-notebook` gained an auto-detected rich conversion engine, and `research-notebook` now uses that engine as the parser half of a two-half pipeline with MathNotebook post-processing, generating one-way from a readable `.md`.
`PacletDocumentation` completed on 2026-07-27; paclet presentation moved from a hand-built cloud notebook to real Wolfram documentation, bundled on publish and deployed publicly.
