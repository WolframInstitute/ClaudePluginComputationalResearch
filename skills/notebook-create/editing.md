# Existing notebooks and Markdown export

Use this reference for editing a saved `.nb`, reconciling its supporting source, or exporting requested Markdown.
The saved notebook includes direct human edits even when it began as a generated file.
A Markdown export is not a reversible representation of arbitrary notebook content.

## Targeted notebook edits

1. Read the selected notebook with native notebook tools, or inspect the relevant cells and options from `Import[path, "NB"]` in the evaluator without evaluating cell contents.
   Identify the document role, requested change, current human baseline and any companion or supporting source.
   A tool that returns simplified text may omit options or boxes; inspect those separately before writing.
2. Use supported native editing operations that preserve the notebook, or patch the imported Notebook expression at the selected cell/content/option positions.
   Preserve untouched cells, group wrappers and order, cell IDs, tags, initialization settings, stylesheet, notebook metadata and author information.
   Convert new Markdown fragments only when needed; insert their content without applying whole-document generation passes or replacing the existing cell's unrelated options.
3. Re-read the saved file before writing and reconcile concurrent changes.
   Edit its existing path for an authorized in-place change; use a new version only when requested or required by the established human iteration workflow.
   Preserve the previous saved content through the project's existing history/archive mechanism; notebook-only human work must remain recoverable.
4. Re-read the result and compare the cells, nested groups and options against the saved baseline.
   Only the requested passages/options and necessary source anchors may differ.
   Check math and any rich cells affected by the edit; file size and cell counts alone cannot prove preservation.
   Record any unavoidable serialization changes rather than ignoring all notebook options.

Keep an already-open notebook editor open and use the saved file as the base.
Do not evaluate existing Input cells merely to inspect or revise prose; run computations only within the user's authorized scope.
If a changed Input has an existing Output, report that the output is stale and whether it was rechecked.
If available tools cannot preserve the requested notebook content, leave it intact and state the specific limitation.

## Per-cell source write-back

A supporting `.md` should reflect direct notebook edits only where a faithful representation has been established.
Never join the strings inside boxes to obtain Wolfram code: `SuperscriptBox["x", "2"]` represents `x^2`, not `x2`.
`FractionBox`, `InterpretationBox`, `TemplateBox`, implicit multiplication and multi-statement cells make string flattening unsafe too.

- Reuse original literal source when it still represents the cell faithfully.
- For an Input cell with ordinary boxes, use a supported InputForm/source export, or held box interpretation (for example `MakeExpression[boxes, StandardForm]`, retaining its `HoldComplete`) without executing the cell.
  Reparse the proposed source under hold in the same context and compare the held structure with the original interpretation before accepting it.
  A matching parse establishes the interpreted expression, not preservation of comments, formatting, custom box behavior or statement/output boundaries; check those when relevant.
- Inspect Text cells with their formula and link structures intact.
  Write plain text or Markdown math only when the conversion preserves the actual meaning and needed metadata; an `InputForm` dump of `TextData` is not itself usable Markdown.

These are conversion criteria, not a promised general converter.
Do not force custom, dynamic, interpreted or unsupported boxes through a guessed serialization.
When faithful write-back is unavailable, preserve the actual notebook cell, leave the corresponding source block unchanged, and report the cell and limitation in the existing provenance/companion.
Mark the notebook/source synchronization incomplete using the [fingerprint contract](../paper-create-notebook/fingerprint.md); do not claim that the `.md` reproduces the notebook or stamp it as safe to regenerate.
Continue independent targeted edits that can be made faithfully.
For a notebook without supporting source, do not create one just to satisfy this machinery.

## Markdown export

Use this mode when the user asks to export or convert a notebook to Markdown.
It writes the requested `.md` and any agreed supporting assets without changing, evaluating, restamping or rebuilding the `.nb`.
Preserve the notebook's name and authority; choose a distinct export path that does not clobber an existing human Markdown source.

Use an available notebook-to-Markdown exporter or extract supported content through notebook-aware tools, then inspect the resulting Markdown and any asset links.
The built-in `ExportString[Import[path, "NB"], "Markdown"]` is an export candidate, not an editing round-trip.
Known limits include lost environment styles/tags, citations, frontmatter, table structure, custom or dynamic cells, code semantics and formulas rendered as missing PNG references.
A converter can also change Unicode or heading levels; check the constructs actually present in this notebook.

Report material losses and omitted/unsupported cells with stable notebook locations when available.
Do not invent missing formulas or claim that absent linked images were exported.
When a faithful full export is unavailable, provide a clearly identified partial export if useful within the request, keep the original notebook intact, and state what remains unavailable.
A later Markdown-to-notebook conversion is a separately requested new output, not permission to replace the human notebook.
