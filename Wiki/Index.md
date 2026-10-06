# Wiki Index

Knowledge base for ComputationalResearch — the plugin itself, not a research project.
Updated after each substantial step.

The plugin's architecture — skills, scripts, commands, templates — is documented in [ARCHITECTURE.md](../ARCHITECTURE.md) and [README.md](../README.md), not mirrored here.
This wiki carries what those two files are the wrong place for: external dependencies and their recovery info, and cross-cutting concepts.

## Status

- [Status](Status.md) — current state

## Work

Execution state (specs, tasks, per-session progress) lives in the top-level `Work/` folder, not the Wiki.
See [Work/README.md](../Work/README.md).

## Concepts

- [Skill and command names](Concepts/SkillNames.md) — every name is `<area>-<word>`; the old to new table of version 6.0.0, with no alias stubs
- [Session Information Budget](Concepts/SessionInformationBudget.md) — what a `backlog-run` run must read before it can work, measured from git history
- [Progress vs Wiki](Concepts/ProgressWikiSplit.md) — where the durable knowledge actually is: ~53 kB in `## Progress`, 6.6 kB harvested, and what the misplacement costs to read
- [The work item file format](Concepts/ItemFileFormat.md) — the five sections, the one-fact-one-destination rule, the per-task routing annotation, and why `## Progress` is one line per session and read by nobody
- [The autonomous backlog-run pipeline](Concepts/AutonomousPipeline.md) — why the harness schedulers cannot drive it, how the `document-revise` gate is deferred to a branch and a digest, the stop conditions, and where `scripts/auto-run.sh` implements each
- [The `/backlog-run-scheduled` operator runbook](Concepts/AutoRunOperations.md) — what to do for each stop reason, how to read a digest, how to grow the allowlist, and how `work/<Item>` reaches `main`
- [The headless model and effort surface](Concepts/HeadlessModelSurface.md) — `--model` aliases and `--effort` on `claude -p`: a bad model fails closed for free, a bad effort fails open silently, and `modelUsage` names two models per run
- [Preamble audit](Concepts/PreambleAudit.md) — what belongs in an auto-loaded `CLAUDE.md`: 47 % of this repo's was inventory already in context by two other routes
- [Generated preamble audit](Concepts/GeneratedPreambleAudit.md) — the same test on the `CLAUDE.md` the plugin *generates*: already 82 % policy, the suspect code-style block exonerated, and two auto-loaded files found contradicting each other
- [Generating Wolfram paclet documentation](Concepts/PacletDocumentation.md) — five ways a generated doc page ships broken, what actually verifies one, and why there is no unevaluated code block
- [Paclet guide pages and tutorials](Concepts/PacletGuidesAndTutorials.md) — InfraGeometry already runs PureMath's docs path; where the sources live, the paclet-resource deploy against cloud notebooks, what the pinned converter still needs, and one guide per kernel folder
- [The Progress harvest](Concepts/ProgressHarvest.md) — what moved out of the closed items' Progress blocks into `Wiki/`, what did not, and why bytes are the wrong measure of it
- [The Claude Code hook contract](Concepts/HookContract.md) — hooks read JSON from stdin and block via exit 2 + stderr; a positional-args hook is silently inert
- [The notebook TaggingRules registry](Concepts/TaggingRulesRegistry.md) — `"Provenance"` and `"ResearchNotebook"` share the one metadata slot; every writer merges by key via `stampTaggingRule`, never replaces the option; each cell's `"SourceLines"` lives in the cell's own `TaggingRules`
- [Folded cell groups](Concepts/FoldedCellGroups.md) — the group state `{2}` shows the graphic and hides the code; `CellOpen` and a reordered `Closed` group both fail, and `Displacements.nb` is the precedent
- [Revising a notebook from its notes](Concepts/NotebookCommentRound.md) — a revision round carries the `.nb` over and keeps its `.md` in step through each cell's source lines: a typed `<<` or `>>` is a box token, a cell's text needs no front end, a group cell matches every note under it, and `Get`/`Put` alone never match; a three-round trial kept a repeated hand edit out of every later version
- [Running the paper style guide against a real document](Concepts/PaperStyleExercise.md) — the same mathematics written twice under `style.md`, as a notebook and as LaTeX: two of its rules contradict each other, five findings are the guide's and four the LaTeX path's, and `\cref` calls every definition a theorem until `aliascnt` and `nosort` are both set
- [Cutting with no journal](Concepts/CutWithNoJournal.md) — the tiers send marginal material to a journal that is off by default: the generator now refuses to cut *silently* and puts the list to the operator, because silence must not be able to delete anything
- [Set-valued naming in the graph-displacement theory](Concepts/DisplacementNaming.md) — domain notes evicted from `paper-create-notebook` by AuditFixes T7; belongs in the Infrageometry home project once it has a wiki

## Resources

- [MarkdownToNotebook](Resources/MarkdownToNotebook.md) — Markdown→notebook converter backing `notebook-create`'s rich mode; pinned by SHA
- [MathNotebook](Resources/MathNotebook.md) — AMS-style stylesheets, 12 numbered environments and cross-referencing; the post-processing half of `paper-create-notebook`
- [PureMath](Resources/PureMath.md) — the 1,480-page reference implementation of the MarkdownToNotebook doc pipeline; read for design, not depended on
