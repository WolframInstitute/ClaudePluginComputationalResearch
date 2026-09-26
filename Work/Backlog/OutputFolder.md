# OutputFolder

*[ LLM Generated ]*

> Type: refactor
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: "We dont need papaer folder anymore ... it could be perhaps Output and there could be paclet, paper, whatever" (2026-09-26, operator.)

A project keeps its papers in `Paper/`, and nowhere names the other things a project delivers.
The README already shows the new layout: one `Output/` folder for what the user delivers — papers, paclets, and whatever else a project ships.
This item makes the plugin follow it.

### Requirements

- `new-paper` and `scaffold-paper.sh` write to `Output/`, not `Paper/`.
- `new-project`, the scaffold scripts, the gitignore templates, `cite`, `journal`, `search-wolfram` and `new-research-notebook` all name `Output/`.
- `Output/` stays the user's, like `Paper/` was: the plugin scaffolds into it on request and never overwrites.
- An existing project with a `Paper/` keeps working: the skills find it and say that `Output/` is the new name, and never move it themselves.

### Design questions for T1

- Whether a paper sits flat in `Output/` or in its own subfolder, such as `Output/<PaperName>/`, now that the folder is shared with paclets.
- Whether a paclet built in the project lives in `Output/` too, and how that fits the paclet-dev layout of separate paclet clones.
- Whether `Output/` stays gitignored by default, as `Paper/` is.

### Out of scope

- Moving any existing project's files.

## Tasks

- [ ] T1 (model: opus, effort: xhigh — design-critical) — answer the design questions and correct this Spec.
- [ ] T2 (model: sonnet, effort: high — mechanical sweep) — rename `Paper/` to `Output/` across the skills, scripts and templates, about 60 references in 14 files, with the fallback for an existing `Paper/`; scaffold a throwaway project to confirm.
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

- **S0** 2026-09-26 — item filed from the operator's request; draft Spec awaiting approval.
