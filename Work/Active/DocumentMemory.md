# A document remembers how you revised it

*[ LLM Generated ]*

> Type: feature
> Autonomous: allowed
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

You and Claude write one document together over many rounds: you put notes `<< … >>` into it and edit it, Claude writes the next version.
Each document keeps a provenance file beside it: every note you wrote, tied to the lines it was about, every edit you made by hand, and what you asked for in the chat.
From these it keeps a short list of rules, and reads them before each new version, so a correction you made once is not needed again.

## Motivation

- A revision round already keeps your edits and answers your notes, but forgets them once the round is over.
- So a mistake you fixed by hand in version 2 can come back in version 4, wherever a note makes Claude rewrite a passage.
- What you said in the chat about a document ("proofs shorter everywhere") is lost with the session.
- The versions show *what* changed, not *why*; the provenance says what you asked for, where, and what came back.

## Acceptance criteria

- You write a note as `<< … >>` anywhere in a document, on one line or several; in code, inside a comment.
- Every document under revision has one provenance file beside it, readable and editable by you.
- Each note is recorded with the lines it was about and what was done; for a notebook, the lines of its Markdown source.
- Your hand edits and your chat requests about the document are recorded too.
- The file holds a short list of rules drawn from your notes and edits, each saying where it came from; every round reads them first and checks the new version against them.
- Generated notebooks are never committed; each version's `.md` is.
- The provenance file stays in view when old versions move to the Archive.

## Prompt history

- 2026-09-28 — "We should be able to work together on one document. Let's say tex file or nb. The user will write notes [[ .. ]] in the latest document (notebook) and you are going to be performing them and generating document with the suffix _(k+1). You should be remembering all user edits and all user prompts related to that output we are working on so that you are not doing the same mistakes again. So some sort of document-centered provenance. We need it as AI-collaborative doucment creation. We need some design of relevant skills for that."
- 2026-09-28 — "how about .provenance? you should store my notes to particular lines in that document. Note that if it is a notebok you should store it with respect to the corresponding md file. notebooks are not put to git either. … And yes, writing << ... >> is perhaps the best"
- 2026-09-28 — "llm generated notebooks in this review process dont go to git. They have their md files. Can you tell me what is the workflow then if I want to refine a document with AI? This has to be written in the README of the plugin too."

## Technical details

Builds on the revision round ([round.md](../../skills/revise/round.md), 5.4.0), which does the notes → `_k+1` part.
The file format belongs to the `provenance` skill (a new *Document provenance* section, always on for a revised document); `revise` writes it during a round.

### The note grammar

A note is the text between `<<` and `>>`.
It may sit inside a line, span lines, and in a notebook it stays within one cell.
In prose — a notebook Text cell, LaTeX, Typst, Markdown — it goes anywhere; in LaTeX, `% << … >>` keeps it out of the PDF.
In code it goes inside a comment: `(* << smaller graph >> *)`, `# << … >>`.
A bare `<< … >>` in a Wolfram Input cell is a syntax error (checked: `SyntaxQ["<< shorter >>"]` is `False`), so a cell with a note can't be run by mistake.
`<< Package`` has no closing `>>`, so it is not a note.
It replaces `>>`; a note not acted on stays, followed by `<< not done: <reason> >>`.

### The provenance file

One per stem, beside the document: `Note_260927.provenance.md`.
It is not numbered, a round does not copy it into `k+1`, and `/clean` leaves it in place.

```markdown
# Note_260927 — provenance

## Rules
- Write "it is shown", never "we show". *(r2, hand edits H1–H4)*
- Example graphs have at most 10 vertices. *(r3, N2)*

## Requests
- 2026-09-27 — "make a note on geodesic pools" *(v1, new-research-note)*
- 2026-09-28 — "proofs shorter everywhere" *(chat, before r3)*

## Rounds
### r3 — 2026-09-28, v2 → v3
- N1 · `Note_260927_2.md` L41–47 (Example 2) · "make this example smaller" → 6-cycle
- N2 · L88 · "cite the source" → not done, no source in Resources/
- H1 · L12 · "we show" → "it is shown"
```

A note is stored with its version, its line range, the passage it was about, its text, and what was done.
The quoted passage keeps the record readable after lines move in later versions.

### Anchors: which lines

- **Text files** (`.tex`, `.typ`, `.md`, code): lines of the file itself.
- **Notebooks**: lines of the version's Markdown source.
  Each version of a notebook has one: `Note_260927_2.md` beside `Note_260927_2.nb`, and this changes round.md, which today drops the `.md` after version 1.
  Each generated cell carries its source line range in `TaggingRules`, beside the fingerprint `new-research-notebook` already stamps.
  A note in a cell maps to that cell's lines; a note in a cell you added maps to "after line n" of the cell above it.
  When a round rewrites a cell, Claude writes the change into the `.md` first and converts only that cell, so the pair stays in step.
  A cell you edited by hand is written back into the `.md` by Claude reading that one cell. The `NotebookToMarkdown` engine is not used, since it silently loses content (see `Wiki/Resources/MarkdownToNotebook.md`).

### Hand edits without git

- **Notebooks**: a cell whose fingerprint no longer matches is one you edited; the `.md` holds what Claude wrote, so both sides of the edit are known. No git needed.
- **Text files**: `git diff` between the version as Claude wrote it and as you left it.
  This needs version 1 committed as written, which `new-research-note` does not do today (it writes a dated note from a conversation into `Research/Artifacts/` and leaves it uncommitted for your review).

### How a round uses it

1. Read `## Rules` and the last two rounds.
2. Record the new notes, hand edits and any chat request.
3. Rewrite only the passages with notes, obeying the rules.
4. Before writing `k+1`, check each rewritten passage against every rule, and that no earlier hand edit was undone.
5. The reply lists each note with what was done, and any new rule.

Rules are added automatically and shown in the reply; you delete or rewrite a wrong one in the file.
A rule you wrote or edited is protected (revise § *Protected content*).
A new note that contradicts a rule wins, and the rule is rewritten.
A rule that recurs across documents is proposed for the project style, never moved there by Claude.

### Edge cases & out of scope

- A text file with no baseline commit: the round records "no baseline" and draws no rules from edits.
- A notebook generated before this item has no line ranges in its cells: notes are anchored by quoted passage only.
- Out of scope: memory across unrelated documents; any database.

### Git

A round commits the text files and each notebook's `.md`, never a generated `.nb`.
This changes round.md (which commits both versions of a notebook) and `new-notebook/artifacts.md` (which tracks every artifact file, `.nb` included).

## Tasks

One unchecked box ≈ one focused session — small enough to finish, report, and commit in a single sitting.

- [ ] T5 — trial: three rounds on a throwaway `.tex` and `.nb` with a repeated hand edit; round 3 must not bring it back.
- [ ] T6 (model: sonnet, effort: high — doc pass) — README tables, ARCHITECTURE, blog post, version bump.

### Done

(completed tasks move here with the session that closed them)

- [x] T4 (S3) — the generating skills write the first Request; version 1 of a text file committed as written.
  - **Test:** read [provenance § *Version 1*](../../skills/provenance/SKILL.md#version-1) — the generating skill writes the first Request and commits version 1 as written, never the `.nb`.
  - **Test:** read the checklist and step 8 of [new-research-note](../../skills/new-research-note/SKILL.md) and step 9 of [new-research-notebook](../../skills/new-research-notebook/SKILL.md) — both write the provenance file; new-research-note now commits instead of leaving files uncommitted.

- [x] T1 (human) — review the README *Revision* section and the Acceptance criteria. *(S0'', 2026-09-28)*
- [x] T2 (S1) — `<< … >>` grammar in round.md and commands/revise.md; `.nb` never committed in round.md and artifacts.md; the *Document provenance* section of `provenance` (format, anchors, hand edits, rules); round.md links it; `/clean` leaves the file.
  - **Test:** read [round.md](../../skills/revise/round.md) § *The note grammar* and § *Steps* — notes are `<< … >>`, steps 3, 7 and 9 read, check and record the provenance file, step 10 never stages a `.nb`.
  - **Test:** read [provenance § *Document provenance*](../../skills/provenance/SKILL.md#document-provenance) — the file, its three sections, anchors, hand edits and rules match this item's Technical details.
  - **Test:** run the `perl` line from round.md § *Text files* on a `.tex` holding `% << shorter >>` and a two-line `% << … >>` — it prints each note with its line range.
  - **Test:** read [clean.md](../../commands/clean.md) and [artifacts.md](../../skills/new-notebook/artifacts.md) § *Git and the Cloud* — the provenance file stays put; a generated `.nb` is not tracked.
- [x] T3 (S2) — `"SourceLines"` per cell at generation (`scripts/source_lines.wl`, wired into new-notebook, new-research-note, new-research-notebook); the `.md` carried per version; round.md § *Notebooks* rewritten `.md`-first with cell write-back.
  - **Test:** on the MCP kernel, `Get` the MarkdownToNotebook clone and [source_lines.wl](../../scripts/source_lines.wl), then `SourceLineNotebook[ MarkdownToNotebook[ #, "Evaluate" -> False ] &, Import[ "Research/Artifacts/SidonBound_260821.md", "Text" ] ]` — every cell carries `TaggingRules -> { "SourceLines" -> { first, last } }`, and the first cell starting `Definition.` has range `{ 36, 36 }`, its line in the `.md`.
  - **Test:** read [round.md](../../skills/revise/round.md) § *Names* and § *Notebooks* — the `.md` is carried as `Name_k+1.md`; steps 3–7 write the `.md` bottom-up, convert only the rewritten passages, write hand edits back, check every range is a block of the new `.md`, and re-stamp the fingerprint.
  - **Test:** read [provenance § *Anchors*](../../skills/provenance/SKILL.md#anchors) and [TaggingRulesRegistry](../../Wiki/Concepts/TaggingRulesRegistry.md) — the key is named `"SourceLines"`.
  - **Test:** read [new-research-note](../../skills/new-research-note/SKILL.md) § *Conversion* — it now converts through new-notebook's pipeline, not `WriteNotebook`; check you agree.

## Hand-off

- Review: T4 reverses new-research-note's "do not commit": it now commits version 1 (files by name, no `.nb`) as the baseline for hand edits. new-paper is untouched (user-owned writing space); new-notebook only points at the rule via artifacts.md.

- T4: the generating skills write the first Request; and version 1 of a text file is committed as written. A notebook's `Name.md` is already tracked at generation (artifacts.md).
- T5: the trial's `.nb` must come from `new-research-notebook` or `new-notebook`, since only those carry fingerprints (hand edits) and source lines; a `new-notebook` notebook has no fingerprint, so its hand edits record `no baseline`.
- Review: T3 switched `new-research-note` from `mcp__Wolfram__WriteNotebook` to new-notebook's pipeline, because `WriteNotebook` makes one cell per line of a paragraph and cannot carry source lines ([NotebookCommentRound § *Source lines*](../../Wiki/Concepts/NotebookCommentRound.md#source-lines-measured-2026-10-03)). Revert if that skill must keep `WriteNotebook`; its notebooks would then use round.md's no-source-lines path.
- Review: the round's per-passage conversion (round.md step 4) was measured on two passages of `SidonBound`, not yet on a notebook a user edited; T5 is that test. ARCHITECTURE gained the `source_lines.wl` row (scripts 31 → 32) ahead of T6.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-09-28 | Notes are written `<< … >>`, replacing `>>` | the operator: "writing << ... >> is perhaps the best"; delimited, so a note can sit inside a sentence |
| 2026-09-28 | One file per stem, `<stem>.provenance.md` | the operator proposed `.provenance`; `.md` added so it renders. Open to change |
| 2026-09-28 | A notebook's notes are anchored to lines of its `.md` | the operator: "store it with respect to the corresponding md file" |
| 2026-09-28 | Generated notebooks in a revision are not committed; their `.md` is | the operator: "llm generated notebooks in this review process dont go to git. They have their md files." |
| 2026-09-28 | The format lives in `provenance`, the round in `revise`; no new skill | the operator called it document-centered provenance; the round stays the one entry point. Chosen by the LLM, open to change |
| 2026-09-28 | Rules are added automatically, shown in the reply, and overruled by editing the file | a wrong rule costs one deletion; asking each time slows every round. Chosen by the LLM, open to change |

## Progress

- **S0** 2026-09-28 — item filed from the operator's request; draft awaiting answers to the open questions.
- **S0'** 2026-09-28 — the operator chose `<< … >>`, the `.provenance` name, `.md` anchors for notebooks, no git for notebooks; one open question left.
- **S0''** 2026-09-28 — the operator settled git (no `.nb`, `.md` yes); README *Revision* section rewritten as the workflow; approved ("okey fine"), moved to Ready.
- **S1** 2026-10-03 T2 — `<< … >>` grammar, provenance-file steps and no-`.nb` git rule in the round; *Document provenance* section written. → [round.md](../../skills/revise/round.md), [provenance](../../skills/provenance/SKILL.md#document-provenance), [NotebookCommentRound](../../Wiki/Concepts/NotebookCommentRound.md)
- **S2** 2026-10-03 T3 — cells carry `"SourceLines"` from generation; the round keeps `Name_k.md` per version and writes it first. → [source_lines.wl](../../scripts/source_lines.wl), [round.md § *Notebooks*](../../skills/revise/round.md#notebooks), [NotebookCommentRound](../../Wiki/Concepts/NotebookCommentRound.md), [TaggingRulesRegistry](../../Wiki/Concepts/TaggingRulesRegistry.md)
- **S3** 2026-10-03 T4 — generating skills write the first Request and commit version 1 as written. → [provenance § *Version 1*](../../skills/provenance/SKILL.md#version-1), [new-research-note](../../skills/new-research-note/SKILL.md), [new-research-notebook](../../skills/new-research-notebook/SKILL.md), [artifacts.md](../../skills/new-notebook/artifacts.md)
