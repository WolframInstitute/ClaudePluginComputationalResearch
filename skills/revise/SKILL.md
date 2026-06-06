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
