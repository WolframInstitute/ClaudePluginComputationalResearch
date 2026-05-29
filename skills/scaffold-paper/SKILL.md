---
name: scaffold-paper
description: >
  Scaffold a Paper/ folder with LaTeX (amsart, biblatex) or Typst article
  templates and a shared preamble, then act as an editor on the user-owned
  document. Use when the user says "scaffold paper", "add paper", "create paper
  folder", "set up latex", "set up typst", or during new-project when the user
  wants a paper. Trigger on: "paper setup", "latex template", "typst template",
  "add Paper/", "I want to write a paper".
---

# Scaffold Paper

Create a `Paper/` directory for a typeset article, then help the user *edit* it.
Two formats:

- **LaTeX** (default) — amsart document class, biblatex with biber, shared `macros.sty`.
- **Typst** — `main.typ` importing a shared `macros.typ`, native `bibliography()`.

The paper is the **user's document**. This skill scaffolds the structure and then
acts as an *editor*, not an author (see Rules below).

## What you need

1. **Project directory** — where to create Paper/. Usually the project root.
2. **Format** — LaTeX (default) or Typst. Pass `--typst` if the user wants Typst,
   or they say "typst".
3. **Title** (optional) — working title. Default: project name.
4. **Author** (optional) — defaults from git config.

If invoked from new-project, these are already known.

## Step-by-step

### 1. Run the scaffold script

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paper.sh" [--typst] "<ProjectDir>" "<Title>" "<Author>" "<email>"
```

LaTeX creates:
```
Paper/
├── main.tex           — article (amsart + \usepackage{macros})
├── macros.sty         — shared preamble, theorem envs, macros
├── references.bib     — bibliography (biblatex format)
├── figures/           — for TikZ exports and plots
└── .latexmkrc         — latexmk config (pdflatex + biber)
```

Typst (`--typst`) creates:
```
Paper/
├── main.typ           — document (#import "macros.typ": *)
├── macros.typ         — shared preamble, math shorthand, theorem envs
├── references.bib     — bibliography (read natively by Typst)
└── figures/           — for plots and images
```

### 2. Seed references from existing resources

If `Wiki/Resources/` exists and contains paper articles, extract BibTeX entries
and add them to `references.bib`. Use arXiv MCP or crossref MCP to fetch proper
biblatex/BibTeX entries for each paper. Both formats read `references.bib`.

### 3. Update .gitignore

If Paper/ is NOT already gitignored (research projects where Paper/ is tracked),
add build artifact patterns. LaTeX:

```
Paper/*.aux
Paper/*.bbl
Paper/*.bcf
Paper/*.blg
Paper/*.fdb_latexmk
Paper/*.fls
Paper/*.log
Paper/*.out
Paper/*.run.xml
Paper/*.synctex.gz
Paper/*.toc
Paper/*.pdf
```

Typst produces only `Paper/*.pdf`. If Paper/ is already gitignored entirely
(paclet-dev type), no action needed.

## Template contents

### macros.sty (LaTeX)

Shared preamble loaded by main.tex:

- **Fonts**: newpxtext + newpxmath (Palatino), microtype
- **Math**: amsthm, amsmath, amssymb, mathtools, mathrsfs
- **Graphics**: tikz, tikz-cd, subcaption
- **Bibliography**: biblatex with biber (alphabetic style)
- **References**: cleveref (nameinlink, capitalize)
- **Theorem environments**: theorem, corollary, proposition, lemma, conjecture,
  definition, example, construction, remark, question, observation
- **Operators**: dist, diam, Aut, End, Hom
- **Shorthand**: \NN, \ZZ, \QQ, \RR, \CC, \FF, \GG, \VV, \EE

### macros.typ (Typst)

Shared preamble applied with `#show: macros`. Mirrors the LaTeX setup: page/font
style, the same math shorthand (`NN`, `ZZ`, …), the same operators, and
dependency-free counter-based theorem blocks (`theorem`, `lemma`, `definition`,
…) so the first compile needs no network. A comment points to
`@preview/ctheorems` for richer numbering.

Extend macros.sty / macros.typ freely as the project needs.

### Compiling

```bash
cd Paper && latexmk -pdf main.tex      # LaTeX
cd Paper && typst compile main.typ     # Typst (typst watch for live preview)
```

## Rules for LLM

This skill **scaffolds and edits**; it does not write the paper.

- **main.tex / main.typ is the user's writing space.** Do not author content
  unprompted and do not overwrite user prose.
- Act as an **editor on request**:
  - Import material at a specified location ("put the lemma after Section 2").
  - Correct or rewrite a paragraph the user points to.
  - Add figures (TikZ / `figures/` images), code listings, tables.
  - Keep notation consistent with macros.sty / macros.typ.
- **macros.sty / macros.typ** can be extended freely — add macros, operators,
  theorem environments as needed.
- **references.bib** — add entries when papers are downloaded or cited.
- When you do add prose at the user's request, write in the user's voice.
