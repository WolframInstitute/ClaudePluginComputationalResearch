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

Set up a new project with the wiki knowledge base and optional Wolfram Language computation, paclet development, or a structured LaTeX/Typst journal.
The project takes a research topic from **any scientific domain** and explores it through Wolfram models and computation.

## What to ask the user

Before scaffolding, you need:

1. **Project type** — what kind of project to create:
   - **research** (default) — exploratory computation with Wiki, Code/, Resources/, optional Paper/.
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

4. **Include Paper/?** (optional) — default: yes.
   Creates Paper/ with LaTeX article templates (amsart, biblatex, shared macros).
   Say no to skip.
5. **Code directory name** (optional) — default is `Code/`, but projects may use `Wolfram/`, `src/`, `Lean/`, etc.
6. **Domain folders** (optional) — what domain-specific wiki folders to create.
   Suggest defaults based on the topic.
7. **Research depth** (optional) — short / standard (default) / deep.

#### math-research

4. **Include Paper/?** (optional) — default: yes.
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
7. **Include Paper/?** (optional) — default: no. Paper/ is gitignored in paclet-dev repos.
8. **Research depth** (optional) — short / standard (default) / deep.

#### paclet

4. **Organization name** (optional) — default: `WolframInstitute`.
5. **Include wiki?** (optional) — default: no. If yes, init-wiki runs inside the paclet repo for knowledge management.

#### all types

- **Track prompts?** (optional) — default: **no**.
  If yes, turn on prompt provenance: generated artifacts record their originating prompt/intent in `Wiki/Prompts.md` plus an embedded back-pointer.
  See the `provenance` skill.
  The scaffolds always write the toggle as `off`; flip it on after scaffolding if the user wants it (see *After scaffolding*).
- **Keep a scientific journal?** (optional) — default: **no**.
  If yes, turn on the running LaTeX/Typst journal: dated def/thm/rem/claim entries in `Journal/`, every resource cited.
  See the `journal` skill.
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

## Environment check (all types)

Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh`, then evaluate `1+1` with the official Wolfram MCP.
Determine mode (local vs. Cowork) and available tools.

## Scaffolding, by type

Follow the chosen type's procedure in its sibling file, read on demand — only the one for the chosen type:

- [research.md](research.md) — exploratory computation (default)
- [math-research.md](math-research.md) — theorems/definitions up front, optional Lean
- [paclet-dev.md](paclet-dev.md) — dev repo with paclet submodules
- [paclet.md](paclet.md) — standalone paclet

The directory trees are not repeated in those files; each scaffold script prints what it created.

## After scaffolding

If the user asked to track prompts, turn provenance on via the `provenance` skill: set `Prompt tracking: **on**` in `CLAUDE.md`, create `Wiki/Prompts.md`, and add its `## Prompts` entry to `Wiki/Index.md`.
If the user asked for the scientific journal, turn it on via the `journal` skill: set `Scientific journal: **on**` in `CLAUDE.md` and scaffold `Journal/`.
Otherwise leave each toggle at its scaffolded default (`off`).

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
  - `research-notebook` — cloud-published research document
    (definitions → theorems → symbols/functions → code calls)
  - `scaffold-paper` — add a LaTeX/Typst `Paper/` later
  - `check-wiki` — wiki health check (stale articles, broken links)
  - `build-paclet` / `publish-paclet` / `paclet-docs` — build, publish,
    and document paclets (paclet types)
  - `work` — create work items (spec / tasks / progress)
  - `next-session` — run one task per fresh session against a work item
  - `update-wiki` — update wiki after changes
  - `provenance` — optionally track the prompts/intent behind generated artifacts
  - `journal` — optionally keep a running, cited LaTeX/Typst journal of
    definitions, theorems, and main claims (off by default; `/journal on`)
  - `start-tour` — interactive project walkthrough
- Suggest next steps based on the topic and papers
