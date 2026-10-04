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

- [ ] T3 (model: sonnet, effort: high — doc pass) — README check against the acceptance criteria, ARCHITECTURE, the blog post (the idea: one rule for every folder, papers beside the research), version bump.

### Done

- [x] T2 (S2) — `Paper/` to `Research/` across skills, scripts and templates, with the fallback for an existing `Paper/`; destinations in the four generating skills; the scaffolds and their project READMEs.
  - **Test:** run `scripts/scaffold-project.sh Demo "x" /tmp/demo`, then `scripts/scaffold-paper.sh --name First /tmp/demo/Demo` — `Code/` and `Research/` each have `Artifacts/README.md`, `Demo/README.md` states the three places, and the paper lands in `Research/First.tex`.
  - **Test:** `mkdir -p /tmp/old/Paper && scripts/scaffold-paper.sh /tmp/old` — the paper goes to `Paper/main.tex`, and the script says `Research/` is the new place and nothing is moved.
  - **Test:** `grep -rn 'Paper/' skills commands scripts` — only the fallback sentences in new-paper, cite, search-wolfram, artifacts.md, the scaffold script and the project README templates remain.
  - **Test:** read [new-paper](../../skills/new-paper/SKILL.md) and the destination paragraph in [new-notebook](../../skills/new-notebook/SKILL.md), [new-research-note](../../skills/new-research-note/SKILL.md), [new-research-notebook](../../skills/new-research-notebook/SKILL.md) — a document in progress goes in the folder, a one-off or an unsaid request in `Artifacts/`.

- [x] T1 (S1) — rewrite artifacts.md as the three-places convention (root, `Artifacts/`, `Archive/`, the `Research/` rule for papers); `revise`, `clean`, the generating skills and `new-paper` link it; the protected-content paragraph in `revise`.
  - **Test:** read [artifacts.md](../../skills/new-notebook/artifacts.md) — the three places, *Never overwrite*, *Which place* (with *Papers* and *Moving up*) and *Archive* say what the README *Autoorganization* section promises.
  - **Test:** read [revise § Protected content](../../skills/revise/SKILL.md#protected-content) — it opens with "Never overwrite; outside `Artifacts/`, write only on request" and links artifacts.md.
  - **Test:** `grep -rn 'Output/' skills commands` — no hits; `grep -rn 'One artifact, one date' skills commands` — no hits (the anchor is now *Archive*).

## Hand-off

T2 done: skills, scripts and templates follow [artifacts.md](../../skills/new-notebook/artifacts.md); T3 is the README, ARCHITECTURE, blog and version pass.
For T3:
- README *Autoorganization* still says the rule "is in design, see FolderRule" and has "Everything outside `Artifacts/` is yours" (line ~103); ARCHITECTURE.md 10-14 carries the old rule.
- The acceptance criterion "the plugin asks which when it is not clear" contradicts the 2026-10-03 Decision (ambiguous goes to `Artifacts/` without asking); skills follow the Decision, so reword the criterion.
- New assets: `artifacts_index_template.md` (one index text, used by all three project scaffolds, replacing two inline copies) and `project_readme_template.md` (the project's README that states the three places); list both in ARCHITECTURE.
- `scaffold-math-project.sh` created no `Artifacts/` before; it now does, like the others. Paclet-dev dev repos now track `Research/` (the `Paper/` line left `gitignore_dev.template`).
- Fallback: `scaffold-paper.sh` uses an existing `Paper/` (even if `Research/` also exists) and prints that `Research/` is the new place; nothing is moved. Wiki holds only historical `Paper/` mentions (PaperStyleExercise, Status), left as history.
- Not done: `Research/` is created by the paper scaffold only through `mkdir -p` of the files; `Research/Artifacts/` comes from the project scaffolds. A project made before this change has no `Research/Artifacts/` index until a generating skill creates it.

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
- **S1** 2026-10-04 T1 — artifacts.md rewritten as the three-places convention; revise, round.md, /clean, the generating skills and new-paper point at it; `Output/` gone from revise. → [artifacts.md](../../skills/new-notebook/artifacts.md)
- **S2** 2026-10-04 T2 — `Paper/` to `Research/` across the skills, scripts and templates; destinations in the four generating skills; shared index and project README templates; throwaway project and papers scaffolded to confirm. → [new-paper](../../skills/new-paper/SKILL.md), [scaffold-paper.sh](../../scripts/scaffold-paper.sh)
