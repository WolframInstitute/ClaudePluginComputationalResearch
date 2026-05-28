---
name: wiki-init
description: >
  Initialize a plain-markdown knowledge base (Wiki/) in the current repo.
  Use when the user says "init wiki", "set up knowledge base", "add wiki to
  this repo", or when starting a new project that needs a wiki.
  Also triggers when wiki-update or wiki-health is invoked but Wiki/ does not
  exist yet.
---

# Wiki Initialization

Create a `Wiki/` knowledge base in the current repo. The wiki is plain Markdown —
no databases, no embeddings, no special tooling. Works on GitHub, in Obsidian, in
any text editor.

## Step 1 — Ask the user for domain folders

The core structure is fixed:

```
Wiki/
  Index.md
  Status.md
  Concepts/
  Resources/
  Notebooks/
  <Domain>/         ← user chooses these
```

Ask the user what domain-specific folders to create. Give examples based on the
repo content:

- Math project: `Systems/`, `Proofs/`, `Theorems/`
- Formalization project: `Systems/`, `Proofs/`, `Concepts/`
- Software project: `Architecture/`, `APIs/`, `Modules/`
- Research project: `Experiments/`, `Methods/`, `Datasets/`

Also ask what the **code directory** should be called. Default is `Code/`, but
some projects use `Wolfram/`, `src/`, `Lean/`, etc. This affects where the
project-init skill creates code files.

If the user doesn't care, pick sensible defaults based on the repo.

## Step 2 — Create the folder structure

Create all directories and seed files. Use empty `.gitkeep` files in folders
that start empty (except `Concepts/`, `Resources/`, `Notebooks/` which
get populated via other skills).

## Step 3 — Seed Index.md

```markdown
# Wiki Index

Knowledge base for [project]. Updated after each substantial step.
All articles are **draft** until reviewed — see revision workflow.

## Status
- [Status](Status.md) — current state

## Work

Execution state (specs, tasks, per-session progress) lives in the top-level
`Work/` folder, not the Wiki. See `Work/README.md`.

## Concepts

(none yet)

## Resources

(none yet)

## Notebooks

(none yet)

## Tour

Interactive guided walk through the project — say **"start tour"** to begin.
Tour data lives in `Tour/` (local, gitignored).

## [Domain Section]

(none yet)
```

One section per domain folder. Link format: `[Title](Folder/File.md) — summary`.

## Step 4 — Seed Status.md

```markdown
# Status

## Current state

Wiki initialized. No articles yet.

## In progress

(nothing)

## Blockers

(none)
```

Populate with real information if the repo already has content worth summarizing.

## Step 5 — Update CLAUDE.md

Append the wiki section to the repo's `CLAUDE.md` (create the file if it
doesn't exist). Use this template:

```markdown
## Knowledge Base (Wiki)

Wiki/ is a plain-markdown knowledge base maintained by the LLM. Human-readable,
no special tooling needed.

### Maintenance rules

After every substantial step, the LLM:
1. Creates or updates relevant articles in Wiki/
2. Updates Wiki/Index.md
3. Updates Wiki/Status.md
4. Adds cross-links in See also sections

The wiki is documentation — the LLM keeps it accurate automatically.
No human sign-off needed for wiki prose.

### Human revision (code & functionality)

The LLM always presents new code, functionality, and work specs to the user for
review. It does not silently overwrite user-edited content. The revision loop:
generate → present → wait for feedback → revise or proceed.

### Work items (execution state)

Multi-session work lives in the top-level `Work/` folder (spec / tasks /
progress per item), separate from the Wiki. Run `/next-session` in a fresh
session to do the next task. See `Work/README.md`.

### Resources

Wiki/Resources/ holds summaries with download/clone URLs and a ## Recover
section. Resources/ (gitignored) holds actual binary files.

To rebuild all resources from wiki: Scripts/recover_resources.sh
The script parses ## Recover sections from Wiki/Resources/*.md.

### Notebooks

Wiki/Notebooks/ holds .md sources for Wolfram notebooks. Notebooks/ (gitignored)
holds generated .nb files. Scripts convert .md → .nb and optionally publish to
Wolfram Cloud. README.md lists all notebooks with source and cloud links.

### Guided Tour

Say "start tour" for an interactive walk through the project. Tour/ is
created on demand (local, gitignored). Each section produces a narrative .md
and runnable code file. The LLM stops after each section for feedback.
```

## Step 6 — Update .gitignore

Add these entries if not already present:

```
Tour/
Resources/
Notebooks/
```

Exceptions: if the project has git submodules in `Resources/`, preserve them
with lines like `!Resources/SubmoduleName/`.

`Wiki/` itself is tracked. `Tour/`, `Resources/` (binary files), and generated
`.nb` files are gitignored.

## Step 7 — Scan and seed articles

If the repo already has code, documentation, or other content:

1. Identify the main entities (modules, systems, proofs, experiments, etc.)
2. Create a short wiki article for each in the appropriate domain folder
3. Add entries to `Index.md`
4. Update `Status.md` with a real summary
5. Cross-link articles with relative markdown links in See also sections

Use the article format from the wiki-update skill.

## Article format

```markdown
# Title

One-paragraph summary.

## Details

Body. Use subsections as needed.

## See also

- [Other Article](../Folder/OtherArticle.md) — why it's related
```

No status headers on wiki articles — they're documentation, maintained automatically.

## Backlink convention

Use standard markdown relative links so the wiki is clickable on GitHub:

```markdown
[Article Title](../Folder/Article.md)
```

Paths are relative to the current file. Examples from `Wiki/Systems/TM.md`:
- Link to a proof: `[TM → GS](../Proofs/TMtoGS.md)`
- Link to a concept: `[Simulation Encoding](../Concepts/SimulationEncoding.md)`
- Link to a resource: `[Moore 1991](../Resources/Moore1991.md)`

From `Wiki/Index.md` (one level up from subfolders):
- `[Turing Machine](Systems/TuringMachine.md)`
