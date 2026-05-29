---
name: new-project
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
   - **math-research** — pure-math project organised around precise theorems
     and definitions. Wiki/{Theorems,Definitions,Domains}/ and a top-level Work/
     up front, math-domain taxonomy seeded, optional Lean/ subdirectory.
     Use when the work is theorem-proving or formalisation-flavoured.
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

#### math-research

4. **Include Paper/?** (optional) — default: yes.
5. **Include Lean/?** (optional) — default: no. Set yes if the project will
   formalise results in Lean/Mathlib. The scaffold creates an empty `Lean/`
   directory; the user runs `lake new <ProjectName> math` inside it
   themselves.
6. **Code directory name** (optional) — default `Code/`.
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
5. **Include wiki?** (optional) — default: no. If yes, init-wiki runs inside
   the paclet repo for knowledge management.

#### all types

- **Track prompts?** (optional) — default: **no**. If yes, turn on prompt
  provenance: generated artifacts record their originating prompt/intent in
  `Wiki/Prompts.md` plus an embedded back-pointer. See the `provenance` skill.
  The scaffolds always write the toggle as `off`; flip it on after scaffolding
  if the user wants it (see *After scaffolding*).

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
├── Scripts/
│   └── recover_resources.sh
└── Work/
    └── README.md
```

### 2. Initialize the wiki

Use the **init-wiki** skill to create the wiki structure:

```
<ProjectName>/
├── Wiki/
│   ├── Index.md
│   ├── Status.md
│   ├── Concepts/
│   ├── Resources/
│   └── <Domain>/        <- project-specific folders
```

The init-wiki skill will:
- Ask for (or infer) domain-specific folders
- Create seed files
- Append wiki section to CLAUDE.md
- Update .gitignore with `Tour/`, `Resources/`, `NotebooksLLM/`

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
3. For each paper, use the **add-resource** skill pipeline:
   - Download PDF to `Resources/Author_Year_ShortTitle.pdf`
   - Create `Wiki/Resources/Author_Year.md` with citation, summary, and Recover section
   - Update `Wiki/Index.md`
4. If Paper/ exists, add biblatex entries to `Paper/references.bib`

### 6. Create initial notebook

Use the **new-notebook** skill to create `NotebooksLLM/<ProjectName>1.nb` with:
- Setup section (package loads)
- Introductory text
- Initial computations demonstrating the core functions
- Visualization examples

If using the two-layer architecture, also write `NotebooksLLM/<ProjectName>.md`
as the notebook source.

### 7. Create Paper/ (if requested)

If the user wants a paper, use the **scaffold-paper** skill (add `--typst` for a
Typst paper instead of the default LaTeX):

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paper.sh" [--typst] "<ProjectName>" "<Title>" "<Author>" "<email>"
```

This creates `Paper/` with main.tex, macros.sty, references.bib, figures/,
and .latexmkrc (LaTeX) or main.typ, macros.typ, references.bib, figures/
(Typst). See scaffold-paper skill for details.

Seed `Paper/references.bib` with biblatex entries from the papers downloaded
in step 5.

---

## Scaffolding: math-research type

### 0. Environment check

Same as research type. Also check whether `lean` is on `PATH` if the user
wants Lean — warn (don't fail) if it's not.

### 1. Scaffold the project

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-math-project.sh" \
    "<ProjectName>" "<topic>" "." "<Author>" "<email>" "<CodeDir>" "<WithLean=0|1>"
```

This creates:

```
<ProjectName>/
├── CLAUDE.md                        — math variant (see math_claude_template.md)
├── <CodeDir>/
│   └── Tools.wl
├── Resources/
├── Scripts/
│   ├── recover_resources.sh
│   ├── generate_notebooks.wls
│   └── publish_notebooks.wls
├── Wiki/
│   ├── Theorems/                    — one .md per theorem
│   ├── Definitions/
│   │   └── _template.md             — copy for new definitions
│   └── Domains/
│       └── categories.md            — math-domain taxonomy seed
├── Work/                            — work items (incl. formalization checklists)
│   └── README.md
└── Lean/                            — only if WithLean=1
```

### 2. Initialize the wiki

Run **init-wiki** inside `<ProjectName>/`. It will create `Index.md`,
`Status.md`, `Concepts/`, `Resources/`. The
`Theorems/`, `Definitions/`, `Domains/` directories already exist
and should be left alone.

### 3. Adapt the domain taxonomy

Read `Wiki/Domains/categories.md` and prune it to the project's actual scope.
Anything not touched should be deleted — the file is a working catalogue, not
a master reference. Add cross-links to the wiki articles you'll create next.

### 4. Seed initial definitions and theorems

For each central concept:

- Copy `Wiki/Definitions/_template.md` to
  `Wiki/Definitions/<Term>.md` and fill in Notation / Prerequisites /
  Statement / Properties / Examples / References.

For each central theorem the project wants to prove or use:

- Create `Wiki/Theorems/<Name>.md` with a precise statement, hypotheses,
  proof outline (math-level), status field (`open | outlined | proved |
  formalised`), and cross-links to required definitions.

Use **search-math** to find authoritative external references for each.

### 5. Create initial code files

Same as research type. Code in `<CodeDir>/` is for computing examples,
counterexamples, and visualisations — it is *not* the source of truth for
the math.

### 6. Download reference papers

Same as research type. For math-research projects, prefer using
**arxiv-latex-mcp** to read papers so equations are exact.

### 7. Create initial notebook (theorem-proof template)

If a central theorem already has an outlined proof, use **new-notebook**
with the `theorem-proof` template type to produce a working notebook around
it (Setup → Statement → Proof → Corollaries → Examples).

### 8. (Optional) Initialize Lean

If `WithLean=1` was set:

1. Tell the user to run `cd <ProjectName>/Lean && lake new <ProjectName> math`
   themselves — this skill does not run `lake` on their behalf.
2. Once the lakefile exists, invoke **lean** to set up a
   `Work/Formalize-<topic>.md` formalization checklist for the first
   theorem.

### 9. Paper (if requested)

Same as research type step 7.

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

Use **init-wiki** inside `<DevRepoName>/`. The domain folders should reflect
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

If the user wants wiki support, run **init-wiki** inside `<PacletName>/`.

### 3. Create initial kernel module

Create at least one kernel module, add `PackageExport` declarations and
`::usage` messages. Present for review.

### 4. Create initial tests

Create test files in `<PacletName>/<PacletName>/Tests/`.

---

## After scaffolding

If the user asked to track prompts, turn provenance on via the `provenance`
skill: set `Prompt tracking: **on**` in `CLAUDE.md`, create `Wiki/Prompts.md`,
and add its `## Prompts` entry to `Wiki/Index.md`. Otherwise leave the toggle at
its scaffolded default (`off`).

Tell the user:
- Project location and folder overview
- For paclet types: the triple-nesting convention and loading instructions
- Papers downloaded and summarized (if applicable)
- Wolfram Community resources found (if any)
- Available skills for ongoing work:
  - `add-resource` — add papers and references (also recognises MathWorld,
    nLab, OEIS, DLMF, Wikipedia URLs)
  - `search-wolfram` — search Wolfram documentation, Function Repository,
    Community, etc.
  - `search-math` — search MathWorld, nLab, OEIS, DLMF, Wikipedia math
    (tuned for math-research projects)
  - `cite` — produce BibTeX from an arXiv ID or DOI
  - `lean` — drive a Lean/Mathlib session (math-research projects
    with `Lean/`)
  - `new-notebook` — create/edit notebooks (supports a `theorem-proof`
    template for math-research projects)
  - `work` — create work items (spec / tasks / progress)
  - `next-session` — run one task per fresh session against a work item
  - `update-wiki` — update wiki after changes
  - `provenance` — optionally track the prompts/intent behind generated artifacts
  - `start-tour` — interactive project walkthrough
- Suggest next steps based on the topic and papers
