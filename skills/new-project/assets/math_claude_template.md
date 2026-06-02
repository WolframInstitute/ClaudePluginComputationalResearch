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
- `Work/` — multi-session work items: spec, tasks, per-session progress (incl. formalization checklists); status is the folder (`Active/Backlog/Done/Dropped`), `Work/README.md` indexes active items
- `Resources/` — reference PDFs, notebooks (gitignored)
- `Lean/` (if present) — Mathlib-style formalization

## Work

`Work/` holds execution state — what's being built now, separate from the Wiki
(durable knowledge). Each file is one **work item**: a Spec (what to build), Tasks
(one ≈ one session), and a Progress log. An item's status is its **folder** —
`Active/`, `Backlog/`, `Done/`, `Dropped/` — changed by `git mv`, not a field;
`Work/README.md` indexes the active ones. Lean formalizations live here too as
`Type: formalization` work items.

- `/work <goal>` — create a work item (drafts a Spec for approval, then tasks)
- `/next-session [Name]` — in a FRESH session, do exactly one task, log progress, stop

## Provenance

Prompt tracking: **off**
<!-- When on, generated artifacts (notebooks, functions, wiki articles, work
     items) record their originating prompt/intent in Wiki/Prompts.md and carry
     an embedded back-pointer. Toggle with /provenance; see the `provenance` skill. -->

## Scientific journal

Scientific journal: **off**
<!-- When on, the LLM keeps a running LaTeX/Typst journal in Journal/ — a concise,
     structured, append-only stream of dated def/thm/rem/claim entries recording the
     math/physics content and main claims established, with resources cited into
     Journal/references.bib. Plain "on" = very concise; "on (verbose)" = fuller
     detail. Toggle with /journal; see the `journal` skill. -->

## Working style

- **State before proving.** Add a `Wiki/Theorems/<Name>.md` with the precise
  statement (and hypotheses, in math + Lean if formalising) *before*
  attempting a proof. Update its `Status:` field as you go (open / outlined
  / proved / formalised).
- **Define before stating.** Anything that appears in a theorem statement
  must first have a `Wiki/Definitions/<Term>.md` entry. Copy
  `Wiki/Definitions/_template.md` for the right structure.
- **Compute to explore.** Use Wolfram code (in `{{CODE_DIR}}/`) for examples,
  counterexamples, plotting structure, testing conjectures. LLM notebooks live
  under `NotebooksLLM/*.md` → `NotebooksLLM/*.nb` (co-located two-layer pipeline);
  `Notebooks/` is reserved for your hand-authored files and is never touched.
- **Reference precisely.** When a fact comes from MathWorld, nLab, DLMF,
  OEIS, Wikipedia, or a paper, link it from the relevant `Wiki/Definitions/`
  or `Wiki/Theorems/` article. Use the `search-math` skill to discover
  the right links and `add-resource` / `cite` to record them.

## Skills tuned for this project type

- `search-math` — search MathWorld, nLab, OEIS, DLMF, Wikipedia math
- `cite` — turn an arXiv ID or DOI into a BibTeX entry
- `lean` — drive a Lean/Mathlib session (only if `Lean/` exists)
- `new-notebook` — supports a `theorem-proof` template type for
  Statement/Proof/Corollaries/Examples notebooks
- `add-resource`, `update-wiki` — standard wiki workflow
- `work`, `next-session` — multi-session work tracking (spec / tasks / progress)

## MCP usage

- **Official Wolfram MCP** — computation, notebook generation, plotting.
  Prefer the current Wolfram/AgentTools paclet; the older Wolfram/MCPServer is a fallback.
- **arxiv-latex-mcp** — preferred for reading math papers (LaTeX source
  gives exact statements and proofs).
- **lean-lsp** — driven by `lean` for formalization.
- **crossref / reference-mcp** — citation lookup, used by `cite`.

## Loading code

```wolfram
dir = DirectoryName @ $InputFileName;  (* in .wl scripts *)
(* or *)
dir = NotebookDirectory[];             (* in notebooks *)

Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "Tools.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}Visualization.wl"}]
```

## Commits

- **Conventional Commits.** Subject line is `type(scope): subject` — e.g. `feat(theorems): add midpoint uniqueness`. Types: `feat fix docs style refactor perf test build ci chore revert`; scope optional; `!` marks a breaking change. Subject ≤ 72 chars, imperative mood, no trailing period.
- A `.githooks/commit-msg` hook enforces this (`core.hooksPath=.githooks`). If a commit is rejected, rewrite the subject — do not bypass with `--no-verify`.
