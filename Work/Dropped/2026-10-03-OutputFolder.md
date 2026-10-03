# One Output folder for what a project delivers

*[ LLM Generated ]*

> Type: refactor
> Superseded: merged into [FolderRule](../Ready/FolderRule.md) on 2026-10-03; papers go to `Research/`, and there is no `Output/`.
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

A project keeps what it delivers — papers, paclets, and anything else it ships — in one folder called Output.
Today only papers have a folder, and it is called Paper.

## Motivation

- A project delivers more than papers, and nothing says where the rest goes.
- The README already shows the Output folder, so the skills and the README disagree until this lands.

## Acceptance criteria

The README's directory tree is true:

- A new project's papers are set up in the Output folder.
- The Output folder stays yours: the plugin sets things up in it on request and never overwrites.
- A project that already has a Paper folder keeps working, and is told the new name without anything being moved.

## Prompt history

- 2026-09-26 — "We dont need papaer folder anymore ... it could be perhaps Output and there could be paclet, paper, whatever"
- 2026-09-26 — "I dont know honestly we should have work items to sort it out and to make readme compatible with the actual implementsation."

## Technical details

### Requirements

- `new-paper` and `scaffold-paper.sh` write to `Output/`, not `Paper/`.
- `new-project`, the scaffold scripts, the gitignore templates, `cite`, `journal`, `search-wolfram` and `new-research-notebook` all name `Output/` — about 60 references in 14 files.
- An existing `Paper/` is found and used; the skills say that `Output/` is the new name and never move it themselves.

### Edge cases & out of scope

- Moving any existing project's files.

### Open questions

1. Whether a paper sits flat in `Output/` or in its own subfolder, such as `Output/<PaperName>/`, now that the folder is shared with paclets.
2. Whether a paclet built in the project lives in `Output/` too, and how that fits the paclet-dev layout of separate paclet clones.
3. Whether `Output/` stays gitignored by default, as `Paper/` is.

## Tasks

- [ ] T1 (model: opus, effort: xhigh — design-critical) — answer the open questions with the operator and correct the Technical details.
- [ ] T2 (model: sonnet, effort: high — mechanical sweep) — rename `Paper/` to `Output/` across the skills, scripts and templates, with the fallback for an existing `Paper/`; scaffold a throwaway project to confirm.
- [ ] T3 (model: sonnet, effort: high — doc pass) — ARCHITECTURE, the blog post if the idea changed, and a version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item; nothing in flight.
The README already shows `Output/`, so it is ahead of the skills until T2 lands.

## Decisions

| Date | Decision | Rationale |
|---|---|---|

## Progress

- **S0** 2026-09-26 — item filed from the operator's request; draft awaiting `/refine`.
- **S0'** 2026-10-03 — dropped: the operator ruled "No Output"; the `Paper/` rename lives on in `FolderRule`.
