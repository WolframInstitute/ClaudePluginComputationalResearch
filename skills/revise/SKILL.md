---
name: revise
description: >
  Human revision workflow for code, functionality, plans, and deliverables.
  This skill defines how the LLM interacts with the user when producing
  anything that needs review. It is not invoked directly — it is a protocol
  that all other skills follow. Read this skill at the start of every session
  to internalize the revision rules.
---

# Human Revision Workflow

This is the core interaction protocol.
Every skill that produces code, functionality, plans, or deliverables follows these rules.

## The revision loop

```
LLM generates → presents to user → WAITS for feedback → user revises or approves → done
```

This applies to:

- **Code** (Wolfram functions, Lean proofs, scripts, any language)
- **New functionality** (new definitions, encodings, graph constructions, etc.)
- **Work specs** (what to build, architecture decisions, task breakdowns)
- **Tour sections** (narrative + code for presentation)

### What "waiting" means

After presenting a deliverable, the LLM must **stop and let the user respond**.
Do not continue to the next step.
Do not assume approval.
The user's response determines what happens:

- "ok", "looks good", "next", "yes", or accepting without objection → **approved**
- "change X", "no, do Y instead", specific feedback → **revise and re-present**
- silence / topic change → treat as implicit approval for the last item

### What to present

When showing code or functionality, always include:

1. What was created/changed (brief summary)
2. The actual code or content (inline or file reference)
3. Why this approach was chosen (one sentence, only if non-obvious)

Do not over-explain.
Do not ask "shall I proceed?" for every micro-step.
Present meaningful chunks — a complete function, a full plan, a finished section — not individual lines.

## What does NOT need revision

**Wiki prose.** The wiki is documentation maintained automatically by the LLM.
Creating, updating, and cross-linking wiki articles does not require human sign-off.
If an article becomes wrong because code changed, just fix it.

The LLM should mention wiki updates in passing ("I updated the wiki article for X") but not present article text for review unless the user asks to see it.

## Autonomous mode — the gate is deferred, not dropped

A session driven by `scripts/auto-run.sh` has no human to wait for.

**You are in it when your system prompt says you are** — the driver appends a notice naming itself, the branch, and the item.
Do not try to infer it from the absence of a user: absence is not observable from inside a session, and the first live run proved it, recording in `## Hand-off` that it had "run as an interactive `/next-session`" while it was in fact being driven.
No notice means you are interactive, whatever the branch is called.

The protocol's purpose is that **nothing lands unreviewed** — not that a human is present when it is generated.
Those come apart, so in autonomous mode the loop above becomes:

```
LLM generates → commits to auto/<Item> → the run digest presents → the human's merge approves
```

The blocking wait is removed; the gate is not.
Work never reaches `main` without a human merging it, which is the same shape as the paclet-worktree rule.

What changes:

- **Do not stop to present.** Finish the task, commit, and let the digest be the presentation.
- **Do not guess at a real decision.** When the task turns on a choice you would otherwise have asked about, write the question into `## Hand-off` on a line containing `needs-human:`, commit that, and stop. The driver halts the whole run on it. A wrong autonomous call is invisible until the digest and acquires later tasks on top of it, so halting is cheap and guessing is not.
- **Protected content stays protected.** User-written Specs, code, and prose are not editable without approval — describe the change in `## Hand-off` as a `needs-human:` question instead.
- **A `(human)` task is not yours.** A task line marked `(human)` halts the driver before the run; if you find yourself in one anyway, stop and say so.

Everything else is unchanged: wiki prose still needs no sign-off, and the deliverable is held to the same standard — the review is later, not lighter.

## Protected content

When the user has **explicitly edited or written** something, the LLM must not silently overwrite it.
This applies to:

- User-edited Specs and tasks in `Work/`
- User-written code or configuration
- User-crafted prose (articles the user specifically wrote by hand)
- Any content the user explicitly created or revised

When the LLM needs to change protected content:

1. Describe what you'd change and why
2. Wait for approval
3. Only then make the change

How to detect protected content: if the user typed it, pasted it, or explicitly edited it in the current or a recent session, treat it as protected.
When in doubt, ask.

## Recording what happened

There is no activity log.
The audit trail is **git history** — commit with clear messages (authorship already distinguishes human from LLM).
Work done against a `Work/` item is also captured in that item's `## Progress` log, one block per session.
Do not maintain a `Wiki/Log.md`.
