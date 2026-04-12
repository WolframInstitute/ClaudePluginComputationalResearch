# {{PROJECT_NAME}}

{{TOPIC_DESCRIPTION}}

## Project goals

{{GOALS}}

## Code structure

- `{{CODE_DIR}}/Tools.wl` — shared general utilities
- `{{CODE_DIR}}/{{PROJECT_NAME}}.wl` — core functions
- `{{CODE_DIR}}/{{PROJECT_NAME}}Visualization.wl` — visualization

Additional topic scopes follow the same pattern:
- `{{CODE_DIR}}/<Topic>.wl` — core functions
- `{{CODE_DIR}}/<Topic>Visualization.wl` — visualization
- `{{CODE_DIR}}/<Topic>Experiment.wl` — experiments
- `{{CODE_DIR}}/<Topic>Test.wl` — tests (VerificationTest + TestReport)

Notebooks: `<Topic>1.nb` per topic, `Test1.nb` for tests.

## Resources

`Resources/` — reference papers and community notebooks, named as `Author_Year_Title.pdf` or `.nb`

## MCP usage

- **Official Wolfram MCP** — primary server for all evaluation, notebook
  generation (Markdown pipeline), and computation.
- **arxiv-latex-mcp** — preferred for reading papers. LaTeX source gives
  exact equations and definitions for Wolfram implementations. Fall back to
  arxiv MCP PDF reading only if LaTeX source is unavailable.
- **Unofficial Wolfram MCP** (if installed) — use for LSP features only:
  `hover_info` (type signatures), `find_definition`, `find_references`,
  `get_diagnostics` (errors/warnings), `document_symbols` (file outline).
  Do not use its notebook-manipulation tools; use the Markdown pipeline instead.

## Loading code

```wolfram
dir = DirectoryName @ $InputFileName;  (* in .wl scripts *)
(* or *)
dir = NotebookDirectory[];             (* in notebooks *)

Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "Tools.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}.wl"}]
Get @ FileNameJoin[{dir, "{{CODE_DIR}}", "{{PROJECT_NAME}}Visualization.wl"}]
```
