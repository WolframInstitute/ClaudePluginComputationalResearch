# research-notebook: embedding evaluated outputs

How the generator evaluates every Input cell and attaches real Output cells, headless.

`NotebookEvaluate` needs a front end driving the kernel and **hangs headless**, so do not reach for it.
Evaluate in the kernel and build the Output cells yourself — the approach proven in [`WolframInstitute/MarkdownToNotebook`](https://github.com/WolframInstitute/MarkdownToNotebook) (`captureCellRun` / `outputBoxes`; nothing to install):

1. Parse each cell's source with `ToExpression[code, InputForm, Hold]` to get the top-level statements, and evaluate them **in document order**, threading kernel state across cells.
2. A statement whose held form is `CompoundExpression[___, Null]` — a `;`-terminated line — evaluates for its side effect and emits **no** Output, matching notebook semantics.
   Every other statement contributes one Output.
3. Wrap the result with `ToBoxes`, which keeps graphics **live** as `GraphicsBox`/`Graphics3DBox` rather than rasterizing.
   Rasterize only what has no faithful inline form (a whole `Notebook` or `NotebookObject`), and cap the raster (long dimension ≈ 1200 px, area ≈ 480k px) so the cell does not trip the resource checker's large-cell bounds.
4. Emit `Cell[CellGroupData[{inputCell, outputCells...}, Open]]`.
5. Evaluate in a **private context** per notebook (`Block[{$Context = "Build<Name>`", $ContextPath = {"System`"}}, …]`) so the build does not leak symbols.
6. Substitute `NotebookDirectory[]` with the target directory before evaluating — there is no notebook at build time.

Two traps, both real:

- **Match Input cells at level `{1}` only.**
  An imported Markdown table becomes a `Tabular` cell whose content nests further `Cell` expressions; a `Replace[…, {1, Infinity}]` matches those too and consumes the code list out of step.
  The symptom is silent: `ExportString[nb, "NB"]` returns the 7-character string `"$Failed"` with no message, and the written file is 7 bytes.
- **`ExportString` failing silently** is the general failure mode.
  Always check `StringQ` on its result and that the written notebook re-imports with head `Notebook`; file size alone will not tell you.

`NotebookToMarkdown.wl` is **not** used anywhere in this pipeline (see [fingerprint.md](fingerprint.md) § *Why there is no reverse direction*), but its message / `Print` / `CellPrint` capture is still worth reading if the notebook's outputs must record those channels.
