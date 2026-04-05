---
name: computational-exploration
description: >
  Scaffold a new research project with the wiki-based knowledge management
  system and perform initial computational exploration. Use whenever the user
  asks to start a new project, create a new research project, set up a project
  folder, scaffold a project, begin investigating a new topic, or explore
  something computationally. Trigger on: "new project on X", "let's start a
  project about Y", "set up folders for Z", "init project", "explore X
  computationally", "investigate Y", "let's look into Z".
---

# Research Project Scaffolder

Set up a new research project with the wiki knowledge base, Wolfram Language
computation, and structured LaTeX notes. The project takes a research topic
from **any scientific domain** and explores it through Wolfram models and
computation.

## What to ask the user

Before scaffolding, you need:

1. **Project name** — CamelCase like `SyntheticInfrageometry` or `DiscreteRicciFlow`.
   Becomes the root folder name.
2. **Topic description** — a sentence or two. E.g., "Studying axiomatic geometry
   on graphs using shortest-path metrics".
3. **Code directory name** (optional) — default is `Code/`, but projects may use
   `Wolfram/`, `src/`, `Lean/`, etc.
4. **Domain folders** (optional) — what domain-specific wiki folders to create.
   Suggest defaults based on the topic.
5. **Research depth** (optional) — short / standard (default) / deep.

If the user already provided these in their message, don't ask again.

## Research depth

| Level | Triggers | Papers | Wolfram Community |
|-------|----------|--------|-------------------|
| **Short** | "short", "quick", "brief" | 1 key paper | Skip |
| **Standard** (default) | — | 2–5 papers | Full search |
| **Deep** | "deep", "thorough" | Exhaustive | Full + extra sources |

## Cowork mode vs local mode

- **Local mode** (default): filesystem directly accessible.
- **Cowork mode**: remote VM, workspace is mounted. MCP can't write to mounted
  filesystem — use ExportString fallback for notebooks.

**Detection**: Cowork if working directory contains `/sessions/` or `/mnt/`, or
`check-env.sh` reports no local MCP but `mcp__wolfram__ping` succeeds.

## Step-by-step

### 0. Environment check

Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` then call `mcp__wolfram__ping`.
Determine mode (local vs. Cowork) and available tools.

### 1. Scaffold directories

Run the scaffold script:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-project.sh" "<ProjectName>" "<topic>" "." "<Author>" "<email>"
```

This creates:
```
<ProjectName>/
├── CLAUDE.md
├── Code/
│   └── Tools.wl
├── Resources/
├── Article/
│   ├── article1.tex
│   ├── notes1.tex
│   └── references.bib
└── Scripts/
    └── recover_resources.sh
```

### 2. Initialize the wiki

Use the **wiki-init** skill to create the wiki structure:

```
<ProjectName>/
├── Wiki/
│   ├── Index.md
│   ├── Status.md
│   ├── Log.md
│   ├── Concepts/
│   ├── Resources/
│   ├── Plans/
│   ├── Notebooks/
│   └── <Domain>/        ← project-specific folders
```

The wiki-init skill will:
- Ask for (or infer) domain-specific folders
- Create seed files
- Append wiki section to CLAUDE.md
- Update .gitignore with `Tour/`, `Resources/`, `Notebooks/*.nb`

### 3. Create initial code files

Create the initial topic code files in the code directory (default `Code/`,
or whatever the user chose):

- `<CodeDir>/<ProjectName>.wl` — core functions with `<ProjectName><Action>` naming
- `<CodeDir>/<ProjectName>Visualization.wl` — visualization functions

Write starter functions based on the topic. Use the Wolfram Language coding
standards from the user profile.

Present the code to the user for review (revision workflow).

### 4. Create initial wiki articles

For each major concept in the project, create a wiki article:

- `Wiki/Concepts/<ConceptName>.md` — for cross-cutting concepts
- `Wiki/<Domain>/<EntityName>.md` — for domain-specific entities

Populate `Wiki/Index.md` and `Wiki/Status.md`. Log the initialization.

### 5. Download reference papers

Every project needs a literature foundation. This step is **not optional**.

1. Search arXiv with `mcp__arxiv__search_papers` using relevant keywords
2. Download 2–5 key papers to `Resources/`
3. For each paper, use the **resource-add** skill pipeline:
   - Download PDF to `Resources/Author_Year_ShortTitle.pdf`
   - Create `Wiki/Resources/Author_Year.md` with citation, summary, and Recover section
   - Update `Wiki/Index.md`
4. Add BibTeX entries to `Article/references.bib`

### 5b. Search Wolfram web resources

(Skip for short depth.)

#### Technical Introduction

Fetch `https://wolframphysics.org/technical-introduction/`, identify sections
related to the project topic, summarize connections.

#### Wolfram Community

Search community tag pages and keyword search:
- `https://community.wolfram.com/content?curTag=wolfram+physics+project`
- `https://community.wolfram.com/content?curTag=<topic-keywords>`
- `https://community.wolfram.com/search?query=<topic-keywords>`

Title-match posts to project keywords. For matched posts:
- Download `.nb` attachments to `Resources/`
- Create wiki resource articles via resource-add
- Record URLs for posts without downloadable notebooks

### 6. Create initial notebook

Use the **notebook-create** skill to create `<ProjectName>1.nb` with:
- Setup section (package loads)
- Introductory text
- Initial computations demonstrating the core functions
- Visualization examples

If using the two-layer architecture, also write `Wiki/Notebooks/<ProjectName>.md`
as the notebook source.

### 7. Notes and article conventions

- `Article/article1.tex` — user's writing space. Don't fill it.
- `Article/notes1.tex` — working notes. **Only write when explicitly asked** ("note
  this", "write this down"). Bump to `notes2.tex` at ~300 lines.
- `Article/references.bib` — add entries whenever papers are downloaded.

## After scaffolding

Tell the user:
- Project location and folder overview
- Papers downloaded and summarized
- Wolfram Community resources found (if any)
- Available skills for ongoing work:
  - `resource-add` — add papers and references
  - `notebook-create` — create/edit notebooks
  - `wiki-plan` — create structured plans
  - `wiki-update` — update wiki after changes
  - `tour-start` — interactive project walkthrough
- Suggest next steps based on the topic and papers
