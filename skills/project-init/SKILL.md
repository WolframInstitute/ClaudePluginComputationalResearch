---
name: project-init
description: >
  Scaffold a new project with the wiki-based knowledge management system and
  perform initial setup. Use whenever the user asks to start a new project,
  create a new research project, set up a project folder, scaffold a project,
  begin investigating a new topic, explore something computationally, or create
  a new paclet. Trigger on: "new project on X", "let's start a project about Y",
  "set up folders for Z", "init project", "explore X computationally",
  "investigate Y", "let's look into Z", "create a paclet for X",
  "new paclet dev repo".
---

# Research Project Scaffolder

Set up a new project with the wiki knowledge base and optional Wolfram Language
computation, paclet development, or structured LaTeX notes. The project takes a
research topic from **any scientific domain** and explores it through Wolfram
models and computation.

## What to ask the user

Before scaffolding, you need:

1. **Project type** — what kind of project to create:
   - **research** (default) — exploratory computation with Wiki, Code/,
     Resources/, optional Paper/. Use for open-ended investigation of a topic.
   - **paclet-dev** — WolframInstitute-style dev repo with paclet submodules,
     experimental Code/, and research infrastructure. Use when developing one or
     more formal Wolfram paclets alongside research.
   - **paclet** — standalone Wolfram paclet. Clean paclet repo structure without
     dev-repo extras. Use for publishing a single paclet.

2. **Project name** — CamelCase like `SyntheticInfrageometry` or `DiscreteRicciFlow`.
   Becomes the root folder name. For paclet-dev, this is the dev repo name
   (often `<PacletName>Dev`).

3. **Topic description** — a sentence or two. E.g., "Studying axiomatic geometry
   on graphs using shortest-path metrics".

### Type-specific questions

#### research (default)

4. **Include Paper/?** (optional) — default: yes. Creates Paper/ with LaTeX
   article templates (amsart, biblatex, shared macros). Say no to skip.
5. **Code directory name** (optional) — default is `Code/`, but projects may use
   `Wolfram/`, `src/`, `Lean/`, etc.
6. **Domain folders** (optional) — what domain-specific wiki folders to create.
   Suggest defaults based on the topic.
7. **Research depth** (optional) — short / standard (default) / deep.

#### paclet-dev

4. **Paclet name(s)** — comma-separated if developing multiple paclets.
   E.g., `SyntheticInfrageometry,Infrageometry`.
5. **Organization name** (optional) — GitHub org for public paclet repos.
   Default: `WolframInstitute`.
6. **GitHub username** (optional) — for the private dev repo. Default: from
   git config.
7. **Include Paper/?** (optional) — default: no. Paper/ is gitignored in
   paclet-dev repos.
8. **Research depth** (optional) — short / standard (default) / deep.

#### paclet

4. **Organization name** (optional) — default: `WolframInstitute`.
5. **Include wiki?** (optional) — default: no. If yes, wiki-init runs inside
   the paclet repo for knowledge management.

If the user already provided these in their message, don't ask again.

## Research depth

| Level | Triggers | Papers |
|-------|----------|--------|
| **Short** | "short", "quick", "brief" | 1 key paper |
| **Standard** (default) | — | 2–5 papers |
| **Deep** | "deep", "thorough" | Exhaustive |

## Cowork mode vs local mode

- **Local mode** (default): filesystem directly accessible.
- **Cowork mode**: remote VM, workspace is mounted. MCP can't write to mounted
  filesystem — use ExportString fallback for notebooks.

**Detection**: Cowork if working directory contains `/sessions/` or `/mnt/`, or
`check-env.sh` reports no local MCP but the official Wolfram MCP responds.

---

## Scaffolding: research type

### 0. Environment check

Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` then evaluate `1+1` with the
official Wolfram MCP. Determine mode (local vs. Cowork) and available tools.

### 1. Scaffold directories

Run the scaffold script:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-project.sh" "<ProjectName>" "<topic>" "." "<Author>" "<email>" "<CodeDir>"
```

`<CodeDir>` defaults to `Code` if omitted.

This creates:
```
<ProjectName>/
├── CLAUDE.md
├── <CodeDir>/
│   └── Tools.wl
├── Resources/
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
│   └── <Domain>/        <- project-specific folders
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
4. If Paper/ exists, add biblatex entries to `Paper/references.bib`

### 6. Create initial notebook

Use the **notebook-create** skill to create `<ProjectName>1.nb` with:
- Setup section (package loads)
- Introductory text
- Initial computations demonstrating the core functions
- Visualization examples

If using the two-layer architecture, also write `Wiki/Notebooks/<ProjectName>.md`
as the notebook source.

### 7. Create Paper/ (if requested)

If the user wants a paper, use the **paper-init** skill:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paper.sh" "<ProjectName>" "<Title>" "<Author>" "<email>"
```

This creates `Paper/` with main.tex, macros.sty, references.bib, figures/,
and .latexmkrc. See paper-init skill for details.

Seed `Paper/references.bib` with biblatex entries from the papers downloaded
in step 5.

---

## Scaffolding: paclet-dev type

### 0. Environment check

Same as research type.

### 1. Scaffold the dev repo

Run the scaffold script:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paclet-dev.sh" \
    "<DevRepoName>" "<PacletName1,PacletName2>" \
    "<OrgName>" "<GitHubUser>" "<topic>" "<Author>" "<email>" "."
```

This creates:
```
<DevRepoName>/
├── <PacletName>/                      — would be git submodule
│   ├── <PacletName>/                  — actual paclet (triple nesting)
│   │   ├── PacletInfo.wl
│   │   ├── Kernel/
│   │   │   ├── <PacletName>.wl        — main loader
│   │   │   └── Usage.wl
│   │   └── Tests/
│   │       └── RunAllTests.wl
│   ├── run_tests.wls
│   ├── README.md
│   └── .gitignore
├── Code/                              — experimental/unrevised code
├── Scripts/
│   └── recover_resources.sh
├── .gitmodules
├── .gitignore
└── CLAUDE.md
```

### Triple nesting convention

The paclet name appears three times in the path:
```
PacletName/PacletName/Kernel/PacletName.wl
^submodule  ^paclet    ^main loader
```

- Level 1 (`PacletName/`): the git submodule directory in the dev repo
- Level 2 (`PacletName/PacletName/`): the actual paclet root containing
  PacletInfo.wl, Kernel/, Tests/
- The submodule repo root also has `run_tests.wls`, `README.md`, `.gitignore`

### Package system

Uses `Package[]` / `PackageExport` / `PackageScope` (not BeginPackage/EndPackage).

Main loader (`Kernel/PacletName.wl`):
```wolfram
Package["OrgName`PacletName`"]

PackageExport[SymbolOne]
PackageExport[SymbolTwo]

ClearAll["OrgName`PacletName`**`*", "OrgName`PacletName`*"]
```

Each kernel module:
```wolfram
Package["OrgName`PacletName`"]

PackageScope[helperName]

(* definitions *)
```

Usage.wl — all `::usage` strings, also starts with `Package["OrgName`PacletName`"]`.

### 2. Initialize the wiki

Use **wiki-init** inside `<DevRepoName>/`. The domain folders should reflect
the paclet's subject matter.

### 3. Create initial kernel modules

For each paclet, create at least one kernel module beyond the main loader:

- `<PacletName>/<PacletName>/Kernel/<ModuleName>.wl` — core functionality

Each module starts with:
```wolfram
Package["<OrgName>`<PacletName>`"]
```

Add corresponding `PackageExport` declarations in the main loader.
Add `::usage` messages in `Usage.wl`.

Present the code to the user for review (revision workflow).

### 4. Create experimental code

Populate `Code/` with exploratory scripts that use the paclet:

```wolfram
PacletDirectoryLoad[ "<PacletName>/<PacletName>" ]
Needs[ "<OrgName>`<PacletName>`" ]

(* experimental code here *)
```

### 5. Create initial tests

For each kernel module, create a test file:

- `<PacletName>/<PacletName>/Tests/<ModuleName>Tests.wlt`

Use `VerificationTest[...]` format. Test files mirror kernel files:
`NameTests.wlt` tests `Name.wl`.

### 6. Download reference papers

Same as research type step 5.

### 7. Create initial wiki articles and notebook

Same as research type steps 4 and 6.

### 8. Git setup guidance

After scaffolding, tell the user:
- The directory structure and triple-nesting convention
- How to initialize git repos (dev repo + each paclet as separate repo)
- How to set up submodules once the org repos exist on GitHub
- How to load paclets during development

Example git setup:
```bash
cd <DevRepoName> && git init
# For each paclet:
cd <PacletName> && git init && git remote add origin git@github.com:<OrgName>/<PacletName>.git && cd ..
# Then register submodules and set up dev repo remote
git remote add origin git@github.com:<GitHubUser>/<DevRepoName>.git
```

---

## Scaffolding: paclet type

### 0. Environment check

Same as research type.

### 1. Scaffold the paclet

Run the scaffold script:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paclet.sh" \
    "<PacletName>" "<OrgName>" "<topic>" "<Author>" "<email>" "."
```

This creates:
```
<PacletName>/                          — repo root
├── <PacletName>/                      — actual paclet
│   ├── PacletInfo.wl
│   ├── Kernel/
│   │   ├── <PacletName>.wl            — main loader
│   │   └── Usage.wl
│   └── Tests/
│       └── RunAllTests.wl
├── run_tests.wls
├── README.md
├── .gitignore
└── CLAUDE.md
```

### 2. (Optional) Initialize wiki

If the user wants wiki support, run **wiki-init** inside `<PacletName>/`.

### 3. Create initial kernel module

Create at least one kernel module, add `PackageExport` declarations and
`::usage` messages. Present for review.

### 4. Create initial tests

Create test files in `<PacletName>/<PacletName>/Tests/`.

---

## After scaffolding

Tell the user:
- Project location and folder overview
- For paclet types: the triple-nesting convention and loading instructions
- Papers downloaded and summarized (if applicable)
- Wolfram Community resources found (if any)
- Available skills for ongoing work:
  - `resource-add` — add papers and references
  - `wolfram-resources` — search Wolfram documentation, Function Repository, Community, etc.
  - `notebook-create` — create/edit notebooks
  - `wiki-plan` — create structured plans
  - `wiki-update` — update wiki after changes
  - `tour-start` — interactive project walkthrough
- Suggest next steps based on the topic and papers
