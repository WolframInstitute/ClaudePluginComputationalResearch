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

Run exactly **one** task against a `Work/` item, then stop. Running each task in a
fresh session is the whole point — it keeps context small and avoids the rot that
builds up over a long chat. Read `revise` first; it governs the deliverable.

## 1. Locate the item

- If a name was given (`/next-session GraphCurvature`), use `Work/<Name>.md`.
- Else read the board in `Work/README.md`; if exactly one item is `active`, use it;
  if several, ask which.

## 2. Load minimal context

Read the full `## Spec` and `## Tasks`, but only the **tail** of `## Progress` (the
last one or two sessions). Do not re-read the whole history — that partial read is
what keeps this cheap.

## 3. Pick the task

Take the first unchecked box in `## Tasks`. State it back to the user.

## 4. Do exactly one task

Implement that single task — code, notebook, proof, whatever it calls for —
following the `revise` loop for the deliverable. Do not start the next task.

## 5. Append a Progress report

Add a block to `## Progress`:

```
### Session N — YYYY-MM-DD — Tk
- **Prompt:** the request that drove this session (optional)
- **Did:** what was completed
- **Learned:** facts/gotchas worth carrying forward
- **Next:** the next task
```

If the project has prompt tracking on (see the
[provenance](../provenance/SKILL.md) skill), keep the `**Prompt:**` line and
mirror an entry to `Wiki/Prompts.md` for any artifact generated this session.
When tracking is off, the `**Prompt:**` line is optional.

## 6. Close the task

Check the box and move it to `### Done` with the session number. Update the item's
row in the `Work/README.md` board (status + next task).

## 7. Sync durable knowledge

Invoke `update-wiki` for anything that became durable knowledge this session — a new
function, a result, a definition, a decision. It updates `Wiki/` articles and
`Status.md`. The Work board (already updated above) owns active items and blockers.
There is no activity log; git and `## Progress` are the record.

## 8. Commit

If the user commits, use the `commit` skill. git history is now the project's audit
trail, so write a message that names the item and task.

## 9. Stop

Say: "Session N complete (Tk). Start a fresh session and run /next-session for the
next task." Do not continue.

## Type-aware execution

For a `Type: formalization` item, "do one task" (step 4) means close one Lean
sub-goal via the `lean` core loop, and the Progress "Learned" note records
which Mathlib lemma or tactic closed it.
