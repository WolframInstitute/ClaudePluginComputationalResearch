# {{PROJECT_NAME}}

{{TOPIC_DESCRIPTION}}

## Project goals

{{GOALS}}

## Project type

This is a **math-research** project. It is organised around precise statements
(theorems and definitions in `Wiki/`) rather than around an open-ended
exploration. Computation is used to test conjectures, generate examples, and
visualise structures — but the wiki is the source of truth for what is true,
what is conjectured, and what is open.

## Directory layout

- `{{CODE_DIR}}/Tools.wl` — shared general utilities
- `{{CODE_DIR}}/{{PROJECT_NAME}}.wl` — core functions
- `{{CODE_DIR}}/{{PROJECT_NAME}}Visualization.wl` — visualisations
- `Wiki/Theorems/` — one `.md` per theorem (statement, proof outline, status)
- `Wiki/Definitions/` — one `.md` per formal definition (see `_template.md`)
- `Wiki/Domains/categories.md` — math-domain taxonomy (adapt to project scope)
- `Work/` — multi-session work items: spec, tasks, per-session progress (incl. formalization checklists); `Work/README.md` is the board
- `Resources/` — reference PDFs, notebooks (gitignored)
- `Lean/` (if present) — Mathlib-style formalization

## Work

`Work/` holds execution state — what's being built now, separate from the Wiki
(durable knowledge). Each file is one **work item**: a Spec (what to build),
Tasks (one ≈ one session), and a Progress log; `Work/README.md` is the board.
Lean formalizations live here too as `Type: formalization` work items.

- `/work <goal>` — create a work item (drafts a Spec for approval, then tasks)
- `/next-session [Name]` — in a FRESH session, do exactly one task, log progress, stop

## Working style

- **State before proving.** Add a `Wiki/Theorems/<Name>.md` with the precise
  statement (and hypotheses, in math + Lean if formalising) *before*
  attempting a proof. Update its `Status:` field as you go (open / outlined
  / proved / formalised).
- **Define before stating.** Anything that appears in a theorem statement
  must first have a `Wiki/Definitions/<Term>.md` entry. Copy
  `Wiki/Definitions/_template.md` for the right structure.
- **Compute to explore.** Use Wolfram code (in `{{CODE_DIR}}/`) for examples,
  counterexamples, plotting structure, testing conjectures. Notebooks live
  under `Wiki/Notebooks/*.md` → `Notebooks/*.nb` (two-layer pipeline).
- **Reference precisely.** When a fact comes from MathWorld, nLab, DLMF,
  OEIS, Wikipedia, or a paper, link it from the relevant `Wiki/Definitions/`
  or `Wiki/Theorems/` article. Use the `math-resources` skill to discover
  the right links and `resource-add` / `cite-from-id` to record them.

## Skills tuned for this project type

- `math-resources` — search MathWorld, nLab, OEIS, DLMF, Wikipedia math
- `cite-from-id` — turn an arXiv ID or DOI into a BibTeX entry
- `lean-bridge` — drive a Lean/Mathlib session (only if `Lean/` exists)
- `notebook-create` — supports a `theorem-proof` template type for
  Statement/Proof/Corollaries/Examples notebooks
- `resource-add`, `wiki-update` — standard wiki workflow
- `work`, `next-session` — multi-session work tracking (spec / tasks / progress)

## MCP usage

- **Official Wolfram MCP** — computation, notebook generation, plotting.
  Prefer the current Wolfram/AgentTools paclet; the older Wolfram/MCPServer is a fallback.
- **arxiv-latex-mcp** — preferred for reading math papers (LaTeX source
  gives exact statements and proofs).
- **lean-lsp** — driven by `lean-bridge` for formalization.
- **crossref / reference-mcp** — citation lookup, used by `cite-from-id`.

## Loading code

```wolfram
dir = DirectoryName @ $InputFileName;  (* in .wl scripts *)
(* or *)
dir = NotebookDirectory[];             (* in notebooks *)

Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "Tools.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}Visualization.wl"}]
```
