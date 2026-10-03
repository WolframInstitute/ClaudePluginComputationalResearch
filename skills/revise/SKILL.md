---
name: revise
description: >
  Human revision workflow for code, functionality, plans, and deliverables.
  This skill defines how the LLM interacts with the user when producing
  anything that needs review — a protocol that all other skills follow; read
  it at the start of every session to internalize the revision rules. Invoked
  directly (`/revise <file>`), it runs one revision round: it reads the
  `<< … >>` notes and hand edits the user left in a document — a notebook, a LaTeX
  or Typst paper, a Markdown file, code — and writes the next numbered
  version beside it (`_2`, `_3`, …), changing only what the notes ask and
  remembering past rounds in the document's provenance file.
  Use for: "revise this", "revision round", "I left notes in the notebook",
  "next version of the paper", or the /revise command.
---

# Human Revision Workflow

This is the core interaction protocol.
Every skill that produces code, functionality, plans, or deliverables follows these rules.

## When to use

- Read at the start of every session; apply whenever producing code, functionality, plans, or deliverables.
- The other skills follow it as a protocol.
- Invoked directly — `/revise <file>`, "revise this", "I left notes in it" — it runs one [revision round](#revision-round).

## Steps

The revision loop:

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

## Revision round

The user reviews a document where they read it, not in the chat.
They write notes into it as `<< … >>`, inside a line or over several — in code inside a comment, as in `% << shorter >>` or `(* << smaller graph >> *)` — and may edit it directly.
A round turns that into the next version:

- **Names.** It writes `Name_k+1` beside the latest version `Name_k` — `Note_260927.tex`, then `Note_260927_2.tex`, `_3`, … — with every file of the stem, and never edits version `k` again.
- **The edited document is the source.** Everything without a note is carried over verbatim, hand edits included; for a notebook, the `.nb` the user edited is carried over, and its `.md` is kept in step with it, each cell knowing its source lines.
- **No invention.** It changes only the passages the notes name and adds nothing no note asked for — in `Output/` as much as in `Artifacts/`.
- **Every note is answered.** One acted on is gone from `k+1`; one not acted on stays, followed by `<< not done: <reason> >>`.
- **The document remembers.** Its provenance file `<stem>.provenance.md` records every note, hand edit and chat request, and keeps rules drawn from them; each round reads the rules first and checks the new version against them.
- **Git holds the trail.** Version `k` is committed as the user left it, then `k+1` once written — text files, `.md` sources and the provenance file, never a generated `.nb`.

It then lists each note with what was done, and each new rule, and waits.
The full procedure — grammar, naming, the text-file and notebook paths — is in [round.md](round.md), and the provenance file's format in [provenance § *Document provenance*](../provenance/SKILL.md#document-provenance); both are read only when running a round.
Moving old versions aside is `/clean`.

## What does NOT need revision

**Wiki prose.** The wiki is documentation maintained automatically by the LLM.
Creating, updating, and cross-linking wiki articles does not require human sign-off.
If an article becomes wrong because code changed, just fix it.

The LLM should mention wiki updates in passing ("I updated the wiki article for X") but not present article text for review unless the user asks to see it.

## Autonomous mode — the gate is deferred, not dropped

A session driven by `scripts/auto-run.sh`, or a worker dispatched by `/autolab`, has no human to wait for.

**You are in it when you are told so** — `auto-run.sh` appends a notice to your system prompt, and `/autolab` puts it at the top of a worker's prompt; either names the driver, the branch, and the item.
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
- **Do not guess at a real decision.** When the task turns on a choice you would otherwise have asked about, write the question into `## Hand-off` on a line containing `needs-human:`, commit that, and stop. The driver halts the item on it. A wrong autonomous call is invisible until the digest and acquires later tasks on top of it, so halting is cheap and guessing is not.
- **Protected content stays protected.** User-written Specs, code, and prose are not editable without approval — describe the change in `## Hand-off` as a `needs-human:` question instead.
- **A `(human)` task is not yours.** A task line marked `(human)` halts the driver before the run; if you find yourself in one anyway, stop and say so.

Everything else is unchanged: wiki prose still needs no sign-off, and the deliverable is held to the same standard — the review is later, not lighter.

## Protected content

**Everything outside an `Artifacts/` folder is the user's.**
The LLM writes its own output into `Code/Artifacts/` and `Research/Artifacts/` ([artifacts.md](../new-notebook/artifacts.md)), and everywhere else it proposes rather than overwrites.
That is a path check, not a judgment call, and it is the mechanism behind the rest of this section.

Within that, the LLM must not silently overwrite anything the user has **explicitly edited or written**, wherever it sits:

- User-edited Specs and tasks in `Work/`
- User-written code or configuration
- User-crafted prose (articles the user specifically wrote by hand)
- Any content the user explicitly created or revised — including inside an `Artifacts/` folder, once the user has edited it

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

## Integration with other skills

- Every deliverable-producing skill follows this loop; `new-paper`, `lean`, `publish-paclet`, `new-notebook`, `new-research-notebook`, and `update-wiki` link here for their specific gates.
- `work` presents Specs through it; `next-session` reads it before every session; `scripts/auto-run.sh` and the `autolab` workers run under *Autonomous mode*.
- A revision round works on what the generating skills write — `new-notebook`, `new-research-note`, `new-research-notebook`, `new-paper` — and on anything in `Output/`.

## When NOT to use

- Wiki prose and journal entries — the named exemptions; update them freely.
- Purely mechanical operations that change no deliverable (formatting, `git mv`, index updates).
