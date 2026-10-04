---
name: project-create
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

Set up a new project with the wiki knowledge base and optional Wolfram Language computation, paclet development, or a structured LaTeX/Typst journal.
The project takes a research topic from **any scientific domain** and explores it through Wolfram models and computation.

## When to use

- The user says "new project on X", "let's start a project about Y", "set up folders for Z", "init project", "create a paclet for X", "new paclet dev repo".
- The user wants to investigate or explore a topic computationally and no project exists yet.

## What to ask the user

Before scaffolding, you need:

1. **Project type** — what kind of project to create:
   - **research** (default) — exploratory computation with Wiki, Code/, Research/, Resources/, optional paper.
     Use for open-ended investigation of a topic.
   - **math-research** — pure-math project organised around precise theorems and definitions.
     Wiki/{Theorems,Definitions,Domains}/ and a top-level Work/ up front, math-domain taxonomy seeded, optional Lean/ subdirectory.
     Use when the work is theorem-proving or formalisation-flavoured.
   - **paclet-dev** — WolframInstitute-style dev repo with paclet submodules, experimental Code/, and research infrastructure.
     Use when developing one or more formal Wolfram paclets alongside research.
   - **paclet** — standalone Wolfram paclet.
     Clean paclet repo structure without dev-repo extras.
     Use for publishing a single paclet.

2. **Project name** — CamelCase like `SyntheticInfrageometry` or `DiscreteRicciFlow`.
   Becomes the root folder name.
   For paclet-dev, this is the dev repo name (often `<PacletName>Dev`).

3. **Topic description** — a sentence or two.
   E.g., "Studying axiomatic geometry on graphs using shortest-path metrics".

### Type-specific questions

#### research (default)

4. **Include a paper?** (optional) — default: yes.
   Adds a paper to `Research/` with LaTeX article templates (amsart, biblatex, shared macros).
   Say no to skip.
5. **Code directory name** (optional) — default is `Code/`, but projects may use `Wolfram/`, `src/`, `Lean/`, etc.
6. **Domain folders** (optional) — what domain-specific wiki folders to create.
   Suggest defaults based on the topic.
7. **Research depth** (optional) — short / standard (default) / deep.

#### math-research

4. **Include a paper?** (optional) — default: yes.
5. **Include Lean/?** (optional) — default: no. Set yes if the project will formalise results in Lean/Mathlib.
   The scaffold creates an empty `Lean/` directory; the user runs `lake new <ProjectName> math` inside it themselves.
6. **Code directory name** (optional) — default `Code/`.
7. **Research depth** (optional) — short / standard (default) / deep.

#### paclet-dev

4. **Paclet name(s)** — comma-separated if developing multiple paclets.
   E.g., `SyntheticInfrageometry,Infrageometry`.
5. **Organization name** (optional) — GitHub org for public paclet repos.
   Default: `WolframInstitute`.
6. **GitHub username** (optional) — for the private dev repo.
   Default: from git config.
7. **Include a paper?** (optional) — default: no. The paper goes to `Research/`, which the dev repo tracks.
8. **Research depth** (optional) — short / standard (default) / deep.

#### paclet

4. **Organization name** (optional) — default: `WolframInstitute`.
5. **Include wiki?** (optional) — default: no. If yes, wiki-init runs inside the paclet repo for knowledge management.

#### all types

- **Track prompts?** (optional) — default: **no**.
  If yes, turn on prompt provenance: generated artifacts record their originating prompt/intent in `Wiki/Prompts.md` plus an embedded back-pointer.
  See the `project-provenance` skill.
  The scaffolds always write the toggle as `off`; flip it on after scaffolding if the user wants it (see *After scaffolding*).
- **Keep a scientific journal?** (optional) — default: **no**.
  If yes, turn on the running LaTeX/Typst journal: dated def/thm/rem/claim entries in `Journal/`, every resource cited.
  See the `paper-journal` skill.
  The scaffolds always write the toggle as `off`; flip it on after scaffolding if the user wants it (see *After scaffolding*).

If the user already provided these in their message, don't ask again.

## Research depth

| Level | Triggers | Papers |
|-------|----------|--------|
| **Short** | "short", "quick", "brief" | 1 key paper |
| **Standard** (default) | — | 2–5 papers |
| **Deep** | "deep", "thorough" | Exhaustive |

## Cowork mode vs local mode

- **Local mode** (default): filesystem directly accessible.
- **Cowork mode**: remote VM, workspace is mounted.
  MCP can't write to mounted filesystem — use ExportString fallback for notebooks.

**Detection**: Cowork if working directory contains `/sessions/` or `/mnt/`, or `check-env.sh` reports no local MCP but the official Wolfram MCP responds.

## Steps

After the questionnaire above:

### 1. Environment check (all types)

Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh`, then evaluate `1+1` with the official Wolfram MCP.
Determine mode (local vs. Cowork) and available tools.

### 2. Scaffold, by type

Follow the chosen type's procedure in its sibling file, read on demand — only the one for the chosen type:

- [research.md](research.md) — exploratory computation (default)
- [math-research.md](math-research.md) — theorems/definitions up front, optional Lean
- [paclet-dev.md](paclet-dev.md) — dev repo with paclet submodules
- [paclet.md](paclet.md) — standalone paclet

The directory trees are not repeated in those files; each scaffold script prints what it created.

### 3. After scaffolding

If the user asked to track prompts, turn provenance on via the `project-provenance` skill: set `Prompt tracking: **on**` in `CLAUDE.md`, create `Wiki/Prompts.md`, and add its `## Prompts` entry to `Wiki/Index.md`.
If the user asked for the scientific journal, turn it on via the `paper-journal` skill: set `Scientific journal: **on**` in `CLAUDE.md` and scaffold `Journal/`.
Otherwise leave each toggle at its scaffolded default (`off`).

Tell the user:
- Project location and folder overview
- For paclet types: the triple-nesting convention and loading instructions
- Papers downloaded and summarized (if applicable)
- Wolfram Community resources found (if any)
- Available skills for ongoing work:
  - `wiki-add-resource` — add papers and references (also recognises MathWorld,
    nLab, OEIS, DLMF, Wikipedia URLs)
  - `wiki-search-wolfram` — search Wolfram documentation, Function Repository,
    Community, etc.
  - `wiki-search-math` — search MathWorld, nLab, OEIS, DLMF, Wikipedia math
    (tuned for math-research projects)
  - `paper-cite` — produce BibTeX from an arXiv ID or DOI
  - `paper-lean` — drive a Lean/Mathlib session (math-research projects
    with `Lean/`)
  - `notebook-create` — create/edit notebooks (supports a `theorem-proof`
    template for math-research projects)
  - `paper-create-notebook` — cloud-published research document
    (definitions → theorems → symbols/functions → code calls)
  - `paper-create` — add a LaTeX/Typst paper to `Research/` later
  - `wiki-check` — wiki health check (stale articles, broken links)
  - `paclet-build` / `paclet-publish` / `paclet-docs` — build, publish,
    and document paclets (paclet types)
  - `backlog-add` — create work items (spec / tasks / progress)
  - `backlog-run` — run one task per fresh session against a work item
  - `wiki-update` — update wiki after changes
  - `project-provenance` — optionally track the prompts/intent behind generated artifacts
  - `paper-journal` — optionally keep a running, cited LaTeX/Typst journal of
    definitions, theorems, and main claims (off by default; `/paper-journal on`)
  - `project-tour` — interactive project walkthrough
- Suggest next steps based on the topic and papers

## Integration with other skills

- `wiki-init`, `wiki-add-resource`, `notebook-create`, and `paper-create` are invoked by the type procedures; `wiki-search-wolfram` / `wiki-search-math` gather resources during setup.
- `project-provenance` and `paper-journal` own the two optional toggles this skill asks about.

## When NOT to use

- The project already exists — use the specific skill (`wiki-init`, `paper-create`, `backlog-add`, …) for the missing piece.
- A quick one-off computation — no scaffolding needed; just compute.
