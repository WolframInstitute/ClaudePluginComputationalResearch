# Revision rounds from comments in the document

*[ LLM Generated ]*

> Type: feature
> Autonomous: allowed
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

You review any document where you read it, not in the chat: a notebook, a LaTeX or Typst paper, a Markdown file.
You write comments into it on lines starting with `>>`, edit it directly where that is quicker, then ask for a revision.
The plugin writes the next version beside the old one, with the next number, and leaves the commented version untouched.
A clean command moves every earlier version into the folder's Archive, so only the latest stays in view.

## Motivation

- Feedback on a long document is easier to give in the document, next to the line it concerns.
- Today a revision overwrites the file, or it becomes a new dated artifact, and the round in between is lost.
- A numbered version per round gives a paper trail: what you asked for, and what came back.
- Old versions clutter a folder, but they should be moved aside, not deleted.

## Acceptance criteria

The README's *Revision* section is true:

- A `>>` comment in any document is read, acted on, and gone from the next version; one it could not act on stays, with the reason.
- The next version has the same stem and the next number, `_2`, `_3`, and so on; the commented version is never edited.
- Every edit you made by hand in the commented version is kept in the next one, including edits in a `.nb`.
- The next version changes only what the comments ask for; nothing is added that you did not ask for.
- This works in `Output/` as well as in `Artifacts/`.
- Clean works in any folder: it moves every numbered version but the latest into an `Archive/` subfolder, created if missing, and nothing is deleted.
- Every step is in git, so each round can be read back.

## Prompt history

- 2026-09-27 — "We should include some refinement protocol. That basically you could work iterativeliy on an artifact also in the way that he would produce notebook/tex, the user would write comments in the notebook [[ ... ]] ore in the tex what is to be changed, and then refine skill would create a new version with suffix_k or something like this. So that we have apepr trail of these revisions. Then everywhere whsould be an Archive folder and a clean command would move all previous revsisions to that archive folder. This could be discussued also in the readme where the general way of doing comptuation al research is discussed"

- 2026-09-27 — "yes of course you can write to output. But you cannot fabulate in output, just write what the user wants. The user will make the edits in the nb itself because doing it in the md is inconvenient. You have to deal with that. Well you should be able to refine with AI any documet and create the _k+1 version.... You ar efree to come up with something else than [[ ]] what is aesy to write"

- 2026-09-27 — "only the rounds well any folder.... it should create an Archive subfolder if not existenct yet"

## Technical details

### Requirements

- `revise` becomes invocable (`/revise <file>`): it stays the review protocol, and gains one *revision round*. The name `refine` is taken by backlog shaping.
- **Comment grammar.** A comment is a line whose text starts with `>>`, optionally after the language's comment sign (`% >>`, `(* >>`, `// >>`, `<!-- >>`). It runs to the end of the line; in a notebook, to the end of the cell. It refers to the passage it sits in or just above. `>>` at a line start collides with nothing in practice: in Wolfram it is a syntax error, so a commented input cell cannot be run by mistake.
- **What a round does.** It finds the latest version of the stem, lists each comment with its passage, applies exactly those changes, and writes version `k+1`. It then presents the list of comments with what it did about each, and waits (`revise`).
- **No invention.** A round changes only the passages the comments name. It adds no text, result or claim that no comment asked for. This matters most in `Output/`, which is the user's.
- **The document the user edited is the source.** Everything not commented is carried over verbatim, with the user's hand edits.
- **Notebooks.** The user edits the `.nb`, not its `.md`. So from round 2 the `.nb` is the source: the round imports `Name_k.nb`, rewrites only the commented cells, and writes `Name_k+1.nb`. The `.md` stays as version 1's source and is not carried forward. The drift fingerprint does not apply, since nothing is regenerated from Markdown. A round never evaluates cells.
- **Companion files.** The other files of the stem follow the edited one: a `.pdf` is rebuilt from the new `.tex`, and a `.wl` is carried over, changed only where a comment asks.
- **Naming.** `Note_260927.tex` is version 1, and rounds give `Note_260927_2.tex`, `_3`, … The date is still the date the work was settled; the number counts rounds.
- **Where.** Anywhere: `Artifacts/` folders and `Output/`. Writing `_k+1` beside a user's file overwrites nothing, and the user asked for it.
- **Clean.** `/clean [folder]` works in any folder, the current one by default. For each stem with numbered rounds it runs `git mv` on every version but the latest into the folder's `Archive/` subfolder, creating it if it does not exist. The Archive is tracked in git. Only numbered rounds move: an older-dated artifact stays where it is. Where the folder has an index `README.md`, it lists only the latest version, with a link to the Archive.
- [artifacts.md](../../skills/new-notebook/artifacts.md) § *One artifact, one date* drops `VersionSnapshots` for `Archive/`. A new date is still a new artifact; the number is for rounds within one date.

### Edge cases & out of scope

- A comment the round cannot act on stays in `k+1`, followed by a line `>> not done: <reason>`.
- A folder-shaped artifact (`Name_YYMMDD/` with `Notebook/`, `Code/`, …) is revised as a whole folder copy `Name_YYMMDD_2/`, so the bare inner names keep resolving.
- A document with no comments and no hand edits: the round says so and writes nothing.
- Out of scope: deleting archived versions, and diffs between versions (git has them).

## Tasks

- [ ] T4 (human) — trial on a throwaway note: two rounds on its `.tex` and on its `.nb` with hand edits in the `.nb`, then clean; the operator reads the trail.

### Done

(completed tasks move here with the session that closed them)

- [x] T1 (model: opus, effort: xhigh — design-critical) — answer the open questions with the operator and correct the Technical details. *(S0', 2026-09-27)*
- [x] T2 (S1) (model: opus, effort: high — protocol writing) — the revision round in `revise` and a `commands/revise.md`: grammar, naming, the no-invention rule, the text-file path and the `.nb`-to-`.nb` path through the MCP, the reply for a comment not acted on.
  - **Test:** read [skills/revise/round.md](../../skills/revise/round.md) against the Acceptance criteria — each criterion but *Clean* has a rule there.
  - **Test:** read the *Revision round* section of [skills/revise/SKILL.md](../../skills/revise/SKILL.md) and [commands/revise.md](../../commands/revise.md) — both say the same as round.md, in brief.
  - **Test:** check the four choices this task made in `## Decisions` (dated 2026-09-27, marked "the LLM") — overturn any you disagree with.
  - The round itself is exercised end to end only in T4.
- [x] T3 (model: sonnet, effort: high — mechanical) — `commands/clean.md` and the `Archive/` rule in `artifacts.md`, replacing `VersionSnapshots`; the generating skills link it. *(S2, 2026-09-27)*
- [x] T5 (model: sonnet, effort: high — doc pass) — README tables, ARCHITECTURE, the blog post (the idea: review happens in the document), and a version bump. *(S3, 2026-09-27)*

## Hand-off

T2, T3 and T5 are done and merged to `main`; released as 5.4.0.
Only T4 is left: the operator's trial — two rounds on a throwaway note's `.tex` and on its `.nb` with hand edits in the `.nb`, then `/clean`, reading the trail.
T5 also fixed the commit messages in `round.md` and `clean.md`: `revise(<stem>)` and `clean(<folder>)` were not Conventional Commits types, and a stem is not a valid lowercase scope, so the scaffolded `commit-msg` hook would have refused every round.

## Decisions` (dated 2026-09-27, marked "the LLM") — overturn any you disagree with.
  - The round itself is exercised end to end only in T4.
- [x] T3 (model: sonnet, effort: high — mechanical) — `commands/clean.md` and the `Archive/` rule in `artifacts.md`, replacing `VersionSnapshots`; the generating skills link it. *(S2, 2026-09-27)*
- [x] T5 (model: sonnet, effort: high — doc pass) — README tables, ARCHITECTURE, the blog post (the idea: review happens in the document), and a version bump. *(S3, 2026-09-27)*

## Hand-off

T2 done: the round is written in [round.md](../../skills/revise/round.md), summarised in `revise` § *Revision round*, with [commands/revise.md](../../commands/revise.md).
T3 done: [commands/clean.md](../../commands/clean.md) writes the procedure (stem/round detection per round.md § *Names*, the `Archive/` move, the README update, the commit message); `artifacts.md` § *One artifact, one date* now moves a superseded artifact's files into the same `Archive/` instead of a bespoke `VersionSnapshots_YYMMDD/` folder, and links `/clean`. The three generating skills (`new-notebook`, `new-research-note`, `new-research-notebook`) already link `artifacts.md`, so they reach the new rule through that one shared link — none needed a direct edit.
For T5: `ARCHITECTURE.md` line 77 still says `revise` has no command, and `commands/revise.md`, `commands/clean.md`, `round.md` are not in its tables yet; the commands count (line 75, "27") is now stale too.
The README *Revision* section can be checked against the landed code now that T3 is in.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-09-27 | A round may write `_k+1` in `Output/` | the operator: "of course you can write to output"; nothing is overwritten |
| 2026-09-27 | A round in `Output/` writes only what the comments ask | the operator: "you cannot fabulate in output" |
| 2026-09-27 | From round 2 the `.nb` is the source, not the `.md` | the operator edits the `.nb`; editing the `.md` is inconvenient |
| 2026-09-27 | Any document can be revised, not only notebooks and LaTeX | the operator: "refine with AI any document" |
| 2026-09-27 | Clean moves only numbered rounds, not superseded older-dated artifacts | the operator: "only the rounds" |
| 2026-09-27 | Clean works in any folder, creating its `Archive/` subfolder when missing | the operator: "well any folder.... it should create an Archive subfolder if not existenct yet" |
| 2026-09-27 | Comments are lines starting with `>>`, not `[[ ]]` | easy to type; `[[` collides with `Part` and wiki links. Chosen by the LLM at the operator's invitation, open to change |
| 2026-09-27 | A version number names the whole stem: `k+1` holds every file of `k`, uncommented ones copied verbatim (not the notebook's `.md`) | one number reads as one consistent set, and clean can move a version whole. Chosen by the LLM in T2, open to change |
| 2026-09-27 | An Output below a rewritten Input stays, and the reply names it as stale | removing it is a change no comment asked for; re-evaluating replaces it. Chosen by the LLM in T2, open to change |
| 2026-09-27 | A commented file inside a multi-file build (other than a folder-shaped artifact) makes the round ask which folder to version | renaming one `\input` file alone breaks the build. Chosen by the LLM in T2, open to change |
| 2026-09-27 | The round commits version `k` as the user left it, then `k+1`; hand edits with no comments are committed and no `k+1` is written | makes "every step is in git" true without a separate step; a copy with nothing changed is noise. Chosen by the LLM in T2, open to change |

## Progress

- **S0** 2026-09-27 — item filed from the operator's request; draft awaiting `/refine`.
- **S0'** 2026-09-27 — the operator answered four questions (Output, no invention, `.nb` as source, any document); README section written. Then the clean questions (only rounds, any folder); no open questions left. Moved to Ready on the operator's word.
- **S1** 2026-09-27 T2 — revision round written: grammar, names, steps, no invention, text-file and `.nb` paths; notebook mechanics verified on the kernel (Opus tier). → [round.md](../../skills/revise/round.md), [commands/revise.md](../../commands/revise.md), [Wiki/Concepts/NotebookCommentRound.md](../../Wiki/Concepts/NotebookCommentRound.md)
- **S2** 2026-09-27 T3 — `/clean` written: any folder, numbered-round detection per round.md § *Names*, `git mv` into `Archive/` (created if missing), README pruned to the latest with a link in, older-dated artifacts left alone. `artifacts.md` § *One artifact, one date* now archives a superseded artifact into the same `Archive/` instead of `VersionSnapshots_YYMMDD/`. → [commands/clean.md](../../commands/clean.md), [skills/new-notebook/artifacts.md](../../skills/new-notebook/artifacts.md)
- **S3** 2026-09-27 T5 — docs pass (in the orchestrating chat): ARCHITECTURE command count and `revise`/`clean` rows, README `clean` link, commit messages fixed for the hook, blog post entry, 5.4.0 bump and marketplace sync.
