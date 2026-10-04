# Three places in every folder

*[ LLM Generated ]*

> Type: refactor
> Autonomous: allowed
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

Every folder that holds documents has the same three places.
The folder itself holds the documents in progress, yours and the ones you write with the plugin, one numbered version per round.
An Artifacts subfolder holds what the plugin made once, on request.
An Archive subfolder holds what is superseded, and nothing is deleted.
Papers live in the Research folder beside the research notebooks and notes; there is no separate Paper or Output folder.

## Motivation

- Today the rule is "everything the plugin writes goes to Artifacts", which has no place for a document you and the plugin write together.
- Revision rounds already write `_2`, `_3` beside a document and move old rounds to `Archive/`, but only `Artifacts/` folders are described.
- One rule for every folder is easier to remember than one rule per skill.
- Papers have their own folder today, and the README showed an Output folder that nothing writes to; both go.

## Acceptance criteria

The README's *Autoorganization* section is true:

- A new project's `Code/` and `Research/` follow the rule, and the scaffold says so in the project's README.
- A new paper is set up in `Research/`; a project that already has a `Paper/` folder keeps working and is told the new place, with nothing moved.
- A one-off the plugin makes lands in the folder's `Artifacts/`; a document in progress lands in the folder itself, and the plugin asks which when it is not clear.
- Clean moves earlier versions into the `Archive/` of the folder the document is in, wherever that folder is.
- The plugin never overwrites a file anywhere.

## Prompt history

- 2026-09-26 — "We dont need papaer folder anymore ... it could be perhaps Output and there could be paclet, paper, whatever"
- 2026-10-03 — "We need the rule that each folder has Archive and Artifacts subfolder. One time LLM Artifacts are stored in Artifacts. Output or documents iteratively being processed are stored in the root folder. All this should be nicely described in the README and should have well thought skills with good names."
- 2026-10-03 — "no actually we should have Research and papers go there as well as some research noteboks, I think"
- 2026-10-03 — "yess. No Output."

## Technical details

The convention lives in [artifacts.md](../../skills/new-notebook/artifacts.md), named for the one place it knew; it becomes the convention for the three places and is linked from `revise`, `clean`, the three generating skills and `new-paper`.
`/clean` ([clean.md](../../commands/clean.md)) already archives into the `Archive/` of the folder it runs in, and round.md already writes `_k+1` beside any document, so the mechanics exist; what changes is where version 1 goes and what the documents say.

### Requirements

- The generating skills (`new-notebook`, `new-research-note`, `new-research-notebook`, `new-paper`) take a destination: the folder itself for a document in progress, `Artifacts/` for a one-off; `new-paper` always writes a document in progress.
  A request that does not say which goes to `Artifacts/`, without asking.
- `new-paper` and `scaffold-paper.sh` write to `Research/`, flat, or `Research/<PaperName>/` when the paper has its own bibliography and figures; an existing `Paper/` is found and used, and the skill says `Research/` is the new place.
  About 60 references to `Paper/` in 14 files (`new-project`, the scaffolds, the gitignore templates, `cite`, `journal`, `search-wolfram`, `new-research-notebook`) move with it.
- The scaffolds create `Artifacts/` under `Code/` and `Research/` with the index; `Archive/` is created lazily by `/clean`.
  Every folder archives into its own `Archive/`: a document revised inside `Artifacts/` archives into `Artifacts/Archive/`.
- The protected-content rule in `revise` is restated as: never overwrite; outside `Artifacts/` write only on request.
- Moving an artifact up into its folder is a plain move the user makes; the next index update notes where it went. No command.

### Edge cases & out of scope

- `Work/` and `Wiki/` are not document folders: `Work/` has its status folders, `Wiki/` has no versions.
- Moving any existing project's files.
- Paclets stay in their own clones (paclet-dev); nothing built lands in the project.

## Tasks

- [ ] T1 (model: opus, effort: high — convention writing) — rewrite artifacts.md as the three-places convention (root, `Artifacts/`, `Archive/`, the `Research/` rule for papers); `revise`, `clean`, the generating skills and `new-paper` link it; the protected-content paragraph in `revise`.
- [ ] T2 (model: sonnet, effort: high — mechanical sweep) — `Paper/` to `Research/` across skills, scripts and templates, with the fallback for an existing `Paper/`; destinations in the four generating skills; the scaffolds and their project READMEs; scaffold a throwaway project and a paper in it to confirm.
- [ ] T3 (model: sonnet, effort: high — doc pass) — README check against the acceptance criteria, ARCHITECTURE, the blog post (the idea: one rule for every folder, papers beside the research), version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item; the design questions are settled in `## Decisions`.
The README *Autoorganization* section states the rule and the tree without `Output/`, so it is ahead of the skills until T2 lands.
`OutputFolder` was merged into this item and dropped.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-10-03 | Papers live in `Research/`; no `Paper/`, no `Output/` | the operator: "Research and papers go there as well as some research notebooks", "No Output" |
| 2026-10-03 | Every folder has its own `Archive/`, `Artifacts/` included | the operator approved; one rule, applied recursively |
| 2026-10-03 | Moving an artifact up into the folder is a plain move, no command | the operator approved; one `git mv` needs no skill |
| 2026-10-03 | An ambiguous request goes to `Artifacts/`, without asking | the operator approved; nothing is overwritten, so the cheap default is safe |
| 2026-10-03 | Paclets stay in their own clones | paclet-dev already keeps them there; the project holds no build output |

## Progress

- **S0** 2026-10-03 — item filed from the operator's request; README section written first.
- **S0'** 2026-10-03 — the operator settled the four questions and dropped `Output/`; `OutputFolder` merged in; moved to Ready.
