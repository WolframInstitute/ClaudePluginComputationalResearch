# {{PROJECT_NAME}}

{{TOPIC_DESCRIPTION}}

## Project goals

{{GOALS}}

## Code structure

- `{{CODE_DIR}}/Tools.wl` — shared general utilities
- `{{CODE_DIR}}/{{PROJECT_NAME}}.wl` — core functions
- `{{CODE_DIR}}/{{PROJECT_NAME}}Visualization.wl` — visualization

Additional topic scopes follow the same pattern:
- `{{CODE_DIR}}/<Topic>.wl` — core functions
- `{{CODE_DIR}}/<Topic>Visualization.wl` — visualization
- `{{CODE_DIR}}/<Topic>Experiment.wl` — experiments
- `{{CODE_DIR}}/<Topic>Test.wl` — tests (VerificationTest + TestReport)

Folders: `{{CODE_DIR}}/` (the code and notebooks about it) and `Research/` (papers, research notebooks, notes) each have three places — the folder itself for documents in progress, `Artifacts/` for what the LLM made once, on request (named `<WhatItSettles>_YYMMDD`, with an index), `Archive/` for what is superseded. A request that does not say which place goes to `Artifacts/`. The LLM never silently overwrites human work; concise paper companions may be maintained in place under the paper workflow below. Papers live in `Research/`; there is no `Paper/` folder.

## Resources

`Resources/` — reference papers and community notebooks, named as `Author_Year_Title.pdf` or `.nb`

## Work

Durable knowledge goes in `Wiki/`; plans, todos, and progress go in `Work/`.
`Work/README.md` carries the conventions and indexes the active items — `/backlog-add` and `/backlog-run` open it by name.

## Provenance

Prompt tracking: **off** <!-- When on, generated artifacts (notebooks, functions, wiki articles, work items) record their originating prompt/intent in Wiki/Prompts.md and carry an embedded back-pointer.
Toggle with /project-provenance; see the `project-provenance` skill. -->

## Scientific journal

Scientific journal: **off** <!-- When on, the LLM keeps a running LaTeX/Typst journal in Journal/ — a concise, structured, append-only stream of dated def/thm/rem/claim entries recording the math/physics content and main claims established, with resources cited into Journal/references.bib.
Plain "on" = very concise; "on (verbose)" = fuller detail.
Toggle with /paper-journal; see the `paper-journal` skill. -->

## MCP usage

- **Official Wolfram MCP** — primary server for evaluation, notebook I/O (Markdown pipeline), docs search, and computation.
  Prefer the current Wolfram/AgentTools paclet; the older Wolfram/MCPServer works as a fallback.
- **arxiv-latex-mcp** — preferred for reading papers.
  LaTeX source gives exact equations and definitions for Wolfram implementations.
  Fall back to arxiv MCP PDF reading only if LaTeX source is unavailable.
- **Unofficial Wolfram MCP** (if installed) — use for LSP features only: `hover_info` (type signatures), `find_definition`, `find_references`, `get_diagnostics` (errors/warnings), `document_symbols` (file outline).
  Do not use its notebook-manipulation tools; use the Markdown pipeline instead.

## Loading code

```wolfram
dir = DirectoryName @ $InputFileName;  (* in .wl scripts *)
(* or *)
dir = NotebookDirectory[];             (* in notebooks *)

Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "Tools.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}Visualization.wl"}]
```


# Paper writing and coworking

This is the default collaboration workflow for a paper with a human author.
It applies to LaTeX, Typst, Markdown and notebook projects; keep an established project's location, format and names unless the user requests a change.

## Authority and iterations

- The authoritative path to the paper is a human-owned sequence such as `paper1.tex`, `paper2.tex`, ... .
  The project records which iteration is current.
  Recency of an assistant output never determines authority.
- Read the current human source before proposing work.
  Preserve its structure, style, terminology, notation, scope and intent, even when suggesting corrections.
  Do not silently build a different theory around an unrelated replacement draft.
- Edit a human manuscript or its author-maintained dependencies only on an explicit request for that edit, within its stated scope.
  Requests for research, review, improvements or a bigger proposal normally authorize the companion and artifacts, not a rewrite of the human paper.
  Existing human edits remain protected wherever they occur, including notes and artifacts.
- Only the human decides which proposals to integrate and when to start another human iteration.
  Do not automatically create `paper2`, promote a companion, merge its contents into the paper, or replace the human's work.
  When asked for a new iteration, preserve the previous version and use the human-selected starting text.
- Keep the human able to edit directly.
  Use ownership conventions, not read-only locks.
  Preserve human authorship and metadata; do not stamp a human manuscript as model-authored because the model helped with it.

## What goes where

| Location | Role and form |
| --- | --- |
| `paperN.tex` | Current human-owned manuscript, in the author's form |
| `paperN_notes.tex` | The single concise research companion corresponding to that manuscript |
| `notes.tex`, if useful | Optional human/shared scratchpad for quick comments, not a second briefing |
| `Artifacts/` | Separate topical investigations: existing proofs, calculations, counterexamples, data, code, notebooks, citations |
| `Archive/` | Superseded drafts, companions and artifacts; keep their provenance and content recoverable |

Use the actual paper stem and extension, for example `liebracket1.tex` and `liebracket1_notes.tex`.
The `_notes` suffix describes a research companion; identify assistant contributions inside it rather than requiring a `Notes/Human` versus `Notes/LLM` folder tree.
Mixed human/assistant notes are welcome, with inline provenance where useful.
Do not maintain competing `_llm` and `_notes` drafts for the same role.
Keep an explicitly requested full alternative draft separately and clearly identified.
Do not migrate unrelated existing projects or fabricate a new iteration merely to impose these example filenames.

## Companion form

- Follow the corresponding human manuscript's section order and notation.
  Start simple: short mathematical sentences, itemized proposals, precise candidate statements, corrections, questions, citations and links.
  Avoid an unsolicited abstract, polished article prose, broad surveys, repetitive explanations and new directions unrelated to the author's questions.
- State hypotheses and distinguish established background, an available argument, a conjecture, a computational observation, and an open problem.
  A short presentation must not buy brevity by representing a proof gap or finite computation as a theorem.
  Do not imply novelty because the model rediscovered something.
- Cite sources actually read, with a precise location when available.
  Link existing topical artifacts for details and make their proof or verification status explicit.
  Do not claim an investigation or a source check was performed when it was not.
- Go deep only when requested or necessary to answer the authorized question.
  Keep a requested long proof or computational investigation in an appropriate topical artifact and summarize its result in the companion.
  Do not automatically generate a full paper, notebook, code bundle, journal and companion for the same request.
- Keep the companion current in place, preserving human corrections.
  The human manuscript's numbered iterations do not imply that every assistant note needs a new human paper version.
  Preserve meaningful superseded material in `Archive/`.

## References, building and reading copies

Use normal LaTeX labels and standard cross-document reference/build mechanisms, with distinct namespaces for the human manuscript and companion.
Do not type theorem numbers by hand when a stable label exists.
Build and reference maintenance is the assistant's responsibility, not a custom Python refresh command for the author.
An editor may use cached external labels without executing local build hooks; do not claim automatic freshness unless verified, and handle the maintenance or state the limitation clearly.

When a document is already open, edit that saved file in place and keep its editor open.
Use its normal compiler to check the result.
Do not create a replacement document, a separate exported PDF or another tab unless requested.
An explicitly requested topical artifact or companion is a separate authorized document, not a replacement for the human paper.

Goodnotes and other reading copies can contain human annotations.
Rename or organize them in place when requested; never replace, delete, or reimport over an annotated copy merely to refresh a build.
Preserve the annotated snapshot and clearly distinguish any newly requested reading copy.
Uploading, publishing, releasing or updating a cloud mirror remains a distinct action with the user's authorized scope; local source edits do not imply public publication.

## Coworking loop

1. Read the current human manuscript and existing companion before acting.
2. Address the user's current question in the companion or a requested artifact, without silently changing the paper.
3. Give a short account of the change, its status, evidence, and relevant file links.
4. Incorporate feedback in the requested place.
   The human chooses manuscript edits, integration and the next iteration.

An explicit request already authorizes its stated edits; do not ask again for routine confirmation.
Unanswered proposals, elapsed time, silence and topic changes do not authorize editing or promoting the human manuscript.


# Human-owned paclet design notebooks

When developing a paclet repository, support the user in keeping an editable design notebook and one concise companion in the repository root, beside the paclet folder.
Apply the same ownership and iteration control as for a human paper.

## Naming and location

| Role | Path, for a paclet named `Infrageometry` |
| --- | --- |
| Human-owned design, iteration 1 | `Infrageometry1.nb` |
| Concise companion to iteration 1 | `Infrageometry1_notes.nb` |
| Next human iteration, only when the human chooses | `Infrageometry2.nb` |
| Its matching companion | `Infrageometry2_notes.nb` |

Use the actual paclet name and capitalization, not a hard-coded `Infrageometry` stem or the repository name when it differs from the paclet name.
Place both notebooks in the repository root alongside the paclet folder; do not introduce a separate notes directory.
Preserve existing human files and recorded current paths; relocating an existing notebook requires a scoped user request.
In a multi-paclet development repository, each paclet has its own named pair at the repository root.
Record the current human design and companion paths in the repository's `AGENTS.md` and `CLAUDE.md` when those notebooks exist; do not infer acceptance from the newest file timestamp.
Keep design notebooks outside the nested paclet payload so development notes are not accidentally shipped.

## Authority and content

- The human design notebook is the primary design document and is directly editable by the human.
  The human decides what belongs in it and when to begin the next numbered iteration.
  Edit its content only on an explicit request, preserving direct notebook edits, structure, vocabulary and notation.
- Before substantial paclet/API work, read the current human design and its companion.
  Use the accepted design to guide the requested implementation, interface naming, examples and relevant checks.
  If implementation and design diverge, identify the discrepancy in the companion and propose a design change; do not silently rewrite the human notebook.
  An explicit code-change request authorizes that implementation scope, not automatic promotion of every companion proposal.
- The companion follows the design notebook's sections and terminology.
  Keep it easy to scan: itemized proposed operations and signatures, precise mathematical statements, small examples, corrections, alternatives, open decisions, and citations or links.
  Clearly distinguish accepted design, proposals, proved results and observed computational behavior.
  Preserve human corrections in the companion too.
- A useful design notebook can describe the mathematical objects, intended representations, public operations, invariants, expected input/output examples, boundary cases and acceptance checks.
  Help the human establish these incrementally; do not invent a large API or write a full theory document when only a small design decision was requested.
- Put requested long derivations, experiments, benchmarks, detailed algorithms and supporting code in topical `Artifacts/` files and link them from the companion.
  Do not add competing full-design `_llm` documents or separate human/LLM notes directories.
  Keep meaningful superseded versions recoverable in `Archive/`.

## Notebook and build support

Use actual editable Wolfram notebooks for the `.nb` deliverables, not renamed text/PDF documents.
The assistant handles notebook tooling, conversion and supporting sources; the human should not run custom refresh or conversion scripts to keep the design usable.
If a Markdown or code source supports generation, it is machinery: never regenerate over human edits in the design `.nb` or a corrected companion.
Reconcile those edits first using the notebook-aware workflow.

During an authorized repository setup or design task, help establish a minimal design/companion pair if missing and record the selected current version.
A routine archive build does not authorize overwriting a design, inventing the next iteration, or requiring the human to complete a design document before the build can proceed.
For an existing build request, consult the current design when present and report relevant inconsistencies without making notebook creation a blocking gate.

Design notes are repository documentation, not automatically a shipped paclet feature.
Keep them outside the actual paclet source payload where possible; if layouts overlap, check packaging intent rather than silently changing declared assets or publishing notebooks.
This convention does not authorize editing a reference clone or migrating an unrelated repository.
