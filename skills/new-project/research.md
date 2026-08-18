# new-project: research type

Read after the shared questionnaire and environment check in [SKILL.md](SKILL.md).

## 1. Scaffold directories

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-project.sh" "<ProjectName>" "<topic>" "." "<Author>" "<email>" "<CodeDir>"
```

`<CodeDir>` defaults to `Code` if omitted.
The script creates `CLAUDE.md`, `<CodeDir>/Tools.wl`, `Resources/`, `Scripts/recover_resources.sh`, and `Work/README.md`, and prints what it made.

## 2. Initialize the wiki

Use the **init-wiki** skill to create `Wiki/` (`Index.md`, `Status.md`, `Concepts/`, `Resources/`, domain folders).
It asks for (or infers) the domain-specific folders, creates seed files, appends the wiki section to `CLAUDE.md`, and updates `.gitignore` with `Tour/`, `Resources/`, `NotebooksLLM/*.nb` (the `.md` sources stay tracked).

## 3. Create initial code files

Create the initial topic code files in the code directory (default `Code/`, or whatever the user chose):

- `<CodeDir>/<ProjectName>.wl` — core functions with `<ProjectName><Action>` naming
- `<CodeDir>/<ProjectName>Visualization.wl` — visualization functions

Write starter functions based on the topic.
Use the Wolfram Language coding standards from the user profile.

Present the code to the user for review (revision workflow).

## 4. Create initial wiki articles

For each major concept in the project, create a wiki article:

- `Wiki/Concepts/<ConceptName>.md` — for cross-cutting concepts
- `Wiki/<Domain>/<EntityName>.md` — for domain-specific entities

Populate `Wiki/Index.md` and `Wiki/Status.md`.
Log the initialization.

## 5. Download reference papers

Every project needs a literature foundation.
This step is **not optional**.

1. Search arXiv with `mcp__arxiv__search_papers` using relevant keywords
2. Download 2–5 key papers to `Resources/`
3. For each paper, use the **add-resource** skill pipeline:
   - Download PDF to `Resources/Author_Year_ShortTitle.pdf`
   - Create `Wiki/Resources/Author_Year.md` with citation, summary, and Recover section
   - Update `Wiki/Index.md`
4. If Paper/ exists, add biblatex entries to `Paper/references.bib`

## 6. Create initial notebook

Use the **new-notebook** skill: write `NotebooksLLM/<ProjectName>.md` as the notebook source and generate `NotebooksLLM/<ProjectName>_YYYY-MM-DD.nb` from it (two-layer architecture; the `.nb` carries its first-creation date), with:

- Setup section (package loads)
- Introductory text
- Initial computations demonstrating the core functions
- Visualization examples

## 7. Create Paper/ (if requested)

If the user wants a paper, use the **scaffold-paper** skill (add `--typst` for a Typst paper instead of the default LaTeX):

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paper.sh" [--typst] "<ProjectName>" "<Title>" "<Operator>" "<email>" "<Model>" "<Freedom>" "<Prompt>"
```

This creates `Paper/` with main.tex, macros.sty, references.bib, figures/, and .latexmkrc (LaTeX) or main.typ, macros.typ, references.bib, figures/ (Typst).
The document's author is the **model**; the footnote names the operator, the freedom level in bold, and the instructions in one sentence.
See scaffold-paper skill for details, and its shared writing guide before adding any prose.

Seed `Paper/references.bib` with biblatex entries from the papers downloaded in step 5.
