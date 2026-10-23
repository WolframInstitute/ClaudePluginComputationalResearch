# Human-owned papers and research companions

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

## Paclet repositories

The same ownership and concise-companion model applies to paclet design notebooks; see [the paclet design policy](../project-create/paclet-design.md).
Use `<PacletName>N.nb` and its `_notes.nb` companion in the repository root beside the paclet folder rather than treating a proposed API as an accepted human design.
