---
name: paper-init
description: >
  Create a Paper/ folder with LaTeX article templates using amsart, biblatex,
  and a shared preamble. Use when the user says "add paper", "create paper
  folder", "set up latex", "init paper", or during project-init when the user
  wants a paper. Trigger on: "paper setup", "latex template", "add Paper/",
  "I want to write a paper".
---

# Paper Initialization

Create a `Paper/` directory with a LaTeX article setup: amsart document class,
biblatex with biber, shared macros, and modern typography.

## What you need

1. **Project directory** — where to create Paper/. Usually the project root.
2. **Title** (optional) — working title for the article. Default: project name.
3. **Author** (optional) — defaults from git config.

If invoked from project-init, these are already known.

## Step-by-step

### 1. Run the scaffold script

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paper.sh" "<ProjectDir>" "<Title>" "<Author>" "<email>"
```

This creates:
```
Paper/
├── main.tex           — article (amsart + \usepackage{macros})
├── macros.sty         — shared preamble, theorem envs, macros
├── references.bib     — bibliography (biblatex format)
├── figures/           — for TikZ exports and plots
└── .latexmkrc         — latexmk config (pdflatex + biber)
```

### 2. Seed references from existing resources

If `Wiki/Resources/` exists and contains paper articles, extract BibTeX entries
and add them to `references.bib`. Use arXiv MCP or crossref MCP to fetch
proper biblatex entries for each paper.

### 3. Update .gitignore

If Paper/ is NOT already gitignored (i.e., research projects where Paper/ is
tracked), add build artifact patterns:

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

If Paper/ is already gitignored entirely (paclet-dev type), no action needed.

## Template contents

### macros.sty

Shared preamble loaded by main.tex. Contains:

- **Fonts**: newpxtext + newpxmath (Palatino), microtype
- **Math**: amsthm, amsmath, amssymb, mathtools, mathrsfs
- **Graphics**: tikz, tikz-cd, subcaption
- **Bibliography**: biblatex with biber (alphabetic style)
- **References**: cleveref (nameinlink, capitalize)
- **Theorem environments**: theorem, corollary, proposition, lemma, conjecture,
  definition, example, construction, remark, question, observation
- **Operators**: dist, diam, Aut, End, Hom
- **Shorthand**: \NN, \ZZ, \QQ, \RR, \CC, \FF, \GG, \VV, \EE

Extend macros.sty freely — add new macros, operators, theorem environments
as the project needs them.

### Compiling

```bash
cd Paper && latexmk -pdf main.tex
```

## Rules for LLM

- **main.tex is the user's writing space.** Do not overwrite user content.
  Only add content when explicitly asked ("write section on X", "add theorem").
- **macros.sty** can be extended freely — add new macros, operators, theorem
  environments as needed during the project.
- **references.bib** — add entries when papers are downloaded or cited.
- Write in the user's mathematical voice. Keep notation consistent with macros.sty.
