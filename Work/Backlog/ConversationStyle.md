# Short, structured answers in every session

*[ LLM Generated ]*

> Type: refactor
> Waiting on: you — the Acceptance criteria and the open questions.
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

The plugin makes Claude answer in one short, fixed shape.
After a piece of work, the user sees the task, the state before, what changed, how to test it, and what to do next.
Every session and every skill report uses it, so conversations move faster.

## Motivation

- Answers are long prose; the user has to dig for what changed and what to check.
- Each skill ends its report in its own way.
- The style now lives only in one user's global instructions, so no other plugin user gets it.
- The Test Instructions already exist per task in work items, but not in the chat reply.

## Acceptance criteria

- A report after a piece of work has Task, Before, After, Test Instructions and Next.
- Status is marked with ✅ ❌ ❓ ⚠️.
- Bullets are short, one line each; a simple question gets a short answer with no sections.
- A decision is asked as a direct question: "Shall I …?".
- The skills that end with a report (next-session, autolab, work, revise, the release steps) use the same shape.
- The style reaches every plugin user without editing their own instructions.
- When Claude edits text the user wrote, it keeps as much as possible, fixes only what is necessary, and gives improvements as proposals.

## Prompt history

- 2026-09-27 — "is it possible to instruct claude to talk to me difffernetly? more simple language, shorter, strcutured (itermize) in sections"
- 2026-09-27 — "perhaps you should use some emojis ..  ✅ ❌ ❓ and perhaps you should have section Test Instructions where you conciesely describe what I should check."
- 2026-09-27 — "perhaps reminding shortly the question, then saying before, then after and test instructions, and proposal for what next? You should use the triangle for warning too."
- 2026-09-27 — "And do not put shit like If you want this, ... just ask Shall I ,,,? or somethihng."
- 2026-09-27 — "You should also add that when editing something the user wrote himself you should keep as much of it as possible and better give only corrections if not necessary and proposeals for imtoevments. This is in particular for writing papers and other text."
- 2026-09-27 — "writing this to acompuataiotnal research would be great. To streamline the conversiation and getting things done."

## Technical details

The source text is the "How to Talk to Me" section of the author's `~/.claude/CLAUDE.md`, written 2026-09-27.
The rule is written once in the plugin and linked from the skills, not copied into each.

### Requirements

- One home for the rule: an output style shipped by the plugin, or a section in `skills/revise/SKILL.md`, which every session already follows.
- The editing rule lands where the plugin edits user text: `new-paper` (editor on the user-owned document) and `revise` (revision rounds).
- Skill report templates (next-session, autolab digest, work, revise) switch to Task / Before / After / Test Instructions / Next.
- `README.md` gets the promise first (README is the contract), then the implementation.

### Edge cases & out of scope

- Documents the plugin writes (wiki, papers, notebooks, work items) keep their own formats; this is the chat reply only.
- Autolab digests are read later, not live; they may need the same shape per item.

### Open questions

1. Home for the rule: a plugin output style (strong, but replaces the default style and may be optional per user) or the revise protocol (always loaded, weaker)?
2. Can a plugin ship an output style, and can it be on by default? Needs a check.
3. Opt-out: should a user be able to turn the style off in their project `CLAUDE.md`?

## Tasks

One unchecked box ≈ one focused session — small enough to finish, report, and commit in a single sitting.

- [ ] T1 (model: sonnet, effort: medium — lookup) — check whether plugins can ship output styles and how they are enabled; record the answer in the Wiki.
- [ ] T2 (human) — decide the home and the opt-out; write the README sentence.
- [ ] T3 (model: opus, effort: high — rule wording) — write the rule in its home; switch the report templates of the listed skills to the shape.
- [ ] T4 (human) — trial it in real sessions; tune the wording.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

(nothing yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|

## Progress

