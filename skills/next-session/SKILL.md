---
name: next-session
description: >
  Run one disciplined work session against a Work/ item: pick the next
  incomplete task, study the Spec, implement exactly ONE task, append a Progress
  report, mark the task done, sync durable knowledge to the Wiki, commit, and
  STOP. Built to be run in a FRESH session each time to avoid context
  accumulation. Use for: "next session", "next task", "work the next task",
  "continue the work item", "resume <Name>", or the /next-session command. It
  does exactly one task then stops — it never chains tasks.
---

# Next Session

Run exactly **one** task against a `Work/` item, then stop.
Running each task in a fresh session is the whole point — it keeps context small and avoids the rot that builds up over a long chat.
Read `revise` first; it governs the deliverable.

## 1. Locate the item

- If a name was given (`/next-session GraphCurvature`), use `Work/Active/<Name>.md`.
  If it is in `Work/Backlog/` instead, `git mv` it into `Active/` first (it is being started).
  An archived item (`Work/Done/` or `Work/Dropped/`) has no next task — surface that instead.
- Else read `Work/README.md` (it lists active items); if exactly one is active, use it; if several, ask which.

## 2. Load context

Read the item file — `## Spec`, `## Tasks`, `## Hand-off`, `## Decisions`.
The format holds that read flat in session count, so there is no partial-read rule: `## Progress` is one line per session and nothing in it is needed (see `Wiki/Concepts/ItemFileFormat.md`).
An item that predates the format carries multi-paragraph Progress blocks — read only the last one or two of those, and give the item a `## Hand-off` in step 5.

## 3. Pick the task

Take the first unchecked box in `## Tasks`.
State it back to the user.

## 4. Do exactly one task

Implement that single task — code, notebook, proof, whatever it calls for — following the `revise` loop for the deliverable.
Do not start the next task.
If the task changes a paclet submodule (paclet-dev), make the edits in that paclet's worktree on the item's branch — procedure in [paclet-worktree.md](paclet-worktree.md), read only in that case.

## 5. File what the session produced

**One fact, one destination — nothing is written twice** (rationale: `Wiki/Concepts/ItemFileFormat.md`).

| the fact is… | write it to |
|---|---|
| durable — about a tool, an artifact, or this plugin | a `Wiki/` article, created or **corrected in place** (step 7) |
| a choice between real alternatives | one `## Decisions` row, one sentence each; a reversal **edits** the row it reverses |
| the Spec being wrong | the Spec sentence itself — replace it, do not append an amendment |
| what the next session must know, and not yet true anywhere else | `## Hand-off` — **overwrite** it, including to empty |
| that the session happened | one `## Progress` line |

The Progress line, appended at the bottom:

```
- **SN** YYYY-MM-DD Tk — one clause naming what changed. → [links to what was filed](...)
```

Filing a fact in `Wiki/` **discharges** the obligation to state it in Progress — the line links it rather than summarising it.
Do not add sections to the item file: conclusions go to `Wiki/`, blockers to `## Hand-off`.

If the project has prompt tracking on (see the [provenance](../provenance/SKILL.md) skill), the session's prompt goes to the `Wiki/Prompts.md` ledger, not into the item file.

When `CLAUDE.md` has `Semantic line breaks: on` (the default — see its *Source formatting* rule), write prose one sentence per source line, here and in the step-4 deliverable.

## 6. Close the task

Check the box and move it to `### Done` with the session number.
Update the item's line in `Work/README.md` (next task).
If that was the **last** task, complete the item: `git mv` the file from `Active/` into `Done/`, prefixing it with today's date (`Work/Done/YYYY-MM-DD-<Name>.md`), and remove its line from `Work/README.md`.
The folder is now its status — there is no field to flip.

## 7. Sync durable knowledge

Invoke `update-wiki` for the durable facts from step 5 — a new function, a result, a definition, a gotcha about an external tool.
It updates `Wiki/` articles and `Status.md`.
When a fact contradicts what an article says, **edit the article**; `Wiki/` is the one surface where a fact can be corrected instead of contradicted, which is why durable content goes there rather than into an append-only log.
`Work/` (the folders + the index, already updated above) owns active items and blockers.

If the project's scientific journal is on (see the [journal](../journal/SKILL.md) skill), append a concise dated def/thm/rem/claim entry for what was established this session, citing resources used.
When off, skip.

## 8. Commit

If the user commits, use the `commit` skill. git history is now the project's audit trail, so write a message that names the item and task.
In an autonomous run (see `revise` § *Autonomous mode*) there is no user to ask: commit unconditionally, on the `auto/<Item>` branch you were started on. The driver reads the new commit and the newly checked box as proof the task ran.
In a paclet-dev repo, paclet code is committed in its worktree on `work/<item>` and the dev-repo tracking (`Work/`, `Wiki/`, `Code/`) on `main` — see [paclet-worktree.md](paclet-worktree.md).

## 9. Stop

Say: "Session N complete (Tk).
Start a fresh session and run /next-session for the next task."
Do not continue.

## Type-aware execution

For a `Type: formalization` item, "do one task" (step 4) means close one Lean sub-goal via the `lean` core loop.
Which Mathlib lemma or tactic closed it is a durable fact — it goes to the `Wiki/` theorem article, not into the item file.
