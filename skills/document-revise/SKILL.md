---
name: document-revise
description: >
  Apply human feedback and direct edits to a document within the requested
  scope, preserving unrequested content. Use for "revise this", notes left
  in a notebook, and /document-revise. Keep human manuscripts and _notes
  companions in place unless a new iteration is explicitly requested.
  A requested versioned revision round preserves the prior document and
  records notes, hand edits and outcomes in its provenance file.
---

# Human Revision Workflow

## Human-owned documents take precedence

Read [the paper collaboration policy](../paper-create/workflow.md) for human manuscripts and [the paclet design policy](../project-create/paclet-design.md) for design notebooks.
The human owns the numbered sequence and chooses the current source, integration and any next iteration; substantive proposals normally go in its concise `<stem>_notes` companion.
Follow the current human source, keep details in linked topical artifacts, and do not promote or rewrite the manuscript without an explicit request.
A request for a short proposal does not trigger a full paper, proof development, notebook/code bundle, journal, or another competing briefing.
Apply ordinary scoped edits and companion updates in place, preserving human corrections.
Use the versioned-round procedure below only for an explicitly requested new version; for human papers/designs, use the human-selected starting text and name.

This is the core interaction protocol.
Every skill that produces code, functionality, plans, or deliverables follows these rules.

## When to use

- Read at the start of every session; apply whenever producing code, functionality, plans, or deliverables.
- The other skills follow it as a protocol.
- Invoked directly — `/document-revise <file>`, "revise this", "I left notes in it" — apply the requested feedback; use a [revision round](#revision-round) only when versioning was requested.

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

Complete the authorized scope and present the result, then let the user respond before taking a further action that requires their decision.
Do not infer permission to integrate proposals, advance a human iteration or publish from the presentation itself.
An explicit scoped edit request already authorizes that edit; do not stop for another approval of routine implementation steps.
The user's response determines what happens:

- explicit approval such as "ok", "looks good", "next" or "yes" → approved for the action actually presented
- "change X", "no, do Y instead", specific feedback → **revise and re-present**
- silence / topic change → no new authorization to edit protected content, integrate proposals, advance an iteration or publish

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
An ordinary requested edit uses the saved document in place.
A specifically requested versioned round preserves it and writes the next version:

- **Names for a specifically requested versioned revision round.** It writes `Name_k+1` beside the latest version `Name_k` — `Note_260927.tex`, then `Note_260927_2.tex`, `_3`, … — with every file of the stem, and never edits version `k` again.
- **The edited document is the source.** Carry unrequested content and direct edits over intact.
  For a notebook, patch the saved `.nb` natively; reconcile any supporting `.md` only where faithful per-cell export is available, and report notebook-only content rather than fabricating source.
- **No invention.** It changes only the passages the notes name and adds nothing no note asked for — in a folder itself as much as in `Artifacts/`.
- **Every note is answered.** One acted on is gone from `k+1`; one not acted on stays, followed by `<< not done: <reason> >>`.
- **The document remembers.** Its provenance file `<stem>.provenance.md` records every note, hand edit and chat request, and keeps rules drawn from them; each round reads the rules first and checks the new version against them.
- **Preserve the trail.** Follow the project's commit/tracking policy and any no-commit instruction.
  Keep direct notebook work recoverable as the actual `.nb` when Markdown/provenance cannot reproduce it; only faithfully reproducible generated outputs may be excluded.

It then lists each note with what was done, and each new rule, and waits.
The full procedure — grammar, naming, the text-file and notebook paths — is in [round.md](round.md), and the provenance file's format in [provenance § *Document provenance*](../project-provenance/SKILL.md#document-provenance); both are read only when running a round.
Moving old versions aside is `/project-clean`.

## What does NOT need revision

**Wiki prose.** The wiki is documentation maintained automatically by the LLM.
Creating, updating, and cross-linking wiki articles does not require human sign-off.
If an article becomes wrong because code changed, just fix it.

The LLM should mention wiki updates in passing ("I updated the wiki article for X") but not present article text for review unless the user asks to see it.

## Autonomous mode — the gate is deferred, not dropped

A session driven by `scripts/auto-run.sh`, or a worker dispatched by `/backlog-autolab`, has no human to wait for.

**You are in it when you are told so** — `auto-run.sh` appends a notice to your system prompt, and `/backlog-autolab` puts it at the top of a worker's prompt; either names the driver, the branch, and the item.
Do not try to infer it from the absence of a user: absence is not observable from inside a session, and the first live run proved it, recording in `## Hand-off` that it had "run as an interactive `/backlog-run`" while it was in fact being driven.
No notice means you are interactive, whatever the branch is called.

The protocol's purpose is that **nothing lands unreviewed** — not that a human is present when it is generated.
Those come apart, so in autonomous mode the loop above becomes:

```
LLM generates → commits to work/<Item> → the run digest presents → the human's merge approves
```

The blocking wait is removed; the gate is not.
Work never reaches `main` without a human merging it, which is the same shape as the paclet-worktree rule.

What changes:

- **Do not stop to present.** Finish the task, commit, and let the digest be the presentation.
- **Do not guess at a real decision.** When the task turns on a choice you would otherwise have asked about, write the question into `## Hand-off` on a line containing `needs-human:`, commit that, and stop. The driver halts the item on it. A wrong autonomous call is invisible until the digest and acquires later tasks on top of it, so halting is cheap and guessing is not.
- **Protected content stays protected.** Edit user-written Specs, code, prose or notebooks only within an explicitly authorized scope.
  If the required change exceeds that scope, describe it in `## Hand-off` as a `needs-human:` question instead.
- **A `(human)` task is not yours.** A task line marked `(human)` halts the driver before the run; if you find yourself in one anyway, stop and say so.

Everything else is unchanged: wiki prose still needs no sign-off, and the deliverable is held to the same standard — the review is later, not lighter.

## Protected content

**Preserve human edits everywhere, including `Artifacts/`, companions and notebooks.**
Read the actual saved document before editing and reconcile concurrent changes before saving.
An explicit request authorizes its stated edits in place; it does not authorize unrelated rewriting, publication or a new human iteration.
Research/proposal requests around a human paper normally authorize its concise companion and necessary topical artifacts, not changes to the human manuscript.

The folder/`Artifacts/`/`Archive/` convention in [artifacts.md](../notebook-create/artifacts.md) organizes new outputs; it does not override an established human document's path or make edits inside `Artifacts/` disposable.
For notebooks, use [native targeted edits](../notebook-create/editing.md), preserving cells, semantic options, grouping and author metadata.
Automatic wiki/journal maintenance exemptions do not authorize undoing human corrections.

If a needed change falls outside the user's authorized scope, describe it and obtain that decision before making the dependent change.
Ask only when the scope or baseline is genuinely unresolved; do not repeat approval requests for edits already authorized.

## Recording what happened

There is no activity log.
The audit trail is **git history** — commit with clear messages (authorship already distinguishes human from LLM).
Work done against a `Work/` item is also captured in that item's `## Progress` log, one block per session.
Do not maintain a `Wiki/Log.md`.

## Integration with other skills

- Every deliverable-producing skill follows this loop; `paper-create`, `paper-lean`, `paclet-publish`, `notebook-create`, `paper-create-notebook`, and `wiki-update` link here for their specific gates.
- `backlog-add` presents Specs through it; `backlog-run` reads it before every session; `scripts/auto-run.sh` and the `backlog-autolab` workers run under *Autonomous mode*.
- A revision round works on what the generating skills write — `notebook-create`, `paper-create-note`, `paper-create-notebook`, `paper-create` — and on any document in progress, wherever it sits.

## When NOT to use

- Wiki prose and journal entries — the named exemptions; update them freely.
- Purely mechanical operations that change no deliverable (formatting, `git mv`, index updates).
