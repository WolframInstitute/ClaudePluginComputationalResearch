# Work

Execution state for {{PROJECT_NAME}} — what's being built now.
Each file is one **work item**: a Spec, Tasks (one ≈ one session), a Hand-off for the next session, and a one-line Progress log.
Durable knowledge lives in `Wiki/`.

An item's **status is its folder** — there is no status field:

| Folder | Meaning | Names |
|---|---|---|
| `Backlog/` | being shaped with the human (`/refine`) | `<Name>.md` |
| `Ready/` | approved and fully specified — `/auto-run` may take it | `<Name>.md` |
| `Active/` | in progress | `<Name>.md` |
| `UnderReview/` | all tasks done — the human checks it against the test instructions | `<Name>.md` |
| `Done/` | reviewed and accepted | `YYYY-MM-DD-<Name>.md` (acceptance date) |
| `Dropped/` | abandoned / superseded | `YYYY-MM-DD-<Name>.md` (drop date) |

Changing status is a `git mv`.
Names are clean while an item is live and get a date prefix when archived, so `Done/` and `Dropped/` read chronologically.

Use `/work` to file a new item and `/refine` to shape one with the LLM until it is ready.
Run `/next-session` in a **fresh** session to work the next task of an active item — clean context per task is the whole point — or `/auto-run` to work a Ready item unattended.
`Backlog/`, `Done/`, and `Dropped/` are not mirrored here; browse the folders.

## Ready

| Item | What it is |
|---|---|
| _(none yet)_ | |

## Active

| Item | Next task |
|---|---|
| _(none yet)_ | |

## Under review

| Item | What to check |
|---|---|
| _(none yet)_ | |
