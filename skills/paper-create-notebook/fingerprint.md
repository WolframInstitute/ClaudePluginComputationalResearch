# Notebook drift detection

A regeneration check must detect changes that the Markdown source would overwrite, including direct human edits to options, metadata and structure.
It is separate from targeted notebook editing: a missing or changed stamp never prevents safe native edits to the saved notebook.

This file specifies the stronger contract; it does not ship a complete schema-2 verifier.
Until an available implementation has been inspected and checked against that contract on the saved notebook, fail closed to native targeted editing rather than regenerate an existing `.nb`.
A new notebook can still be generated; replacing an existing notebook requires either that verified preservation check or explicit authorization to replace its contents while retaining the original snapshot.
Do not infer enforcement from these instructions or the presence of a `"SchemaVersion" -> 2` label alone.

## Current fingerprint contract: schema 2

Store the record under the notebook's `TaggingRules` key `"ResearchNotebook"`, merged with existing keys through `stampTaggingRule` ([project-provenance](../project-provenance/SKILL.md#embedded-back-pointers-so-provenance-travels-with-the-file)).
Use an explicit `"SchemaVersion" -> 2`; the record contains:

- **`"Cells"`**: a map from each unique leaf `CellID` to a digest of the cell's content, style and semantic options after the narrow normalization below.
  Include Input and Output cells inside every `CellGroupData`; detect absent, new and duplicate IDs rather than silently dropping them from an association.
- **`"Structure"`**: a digest of the ordered, nested tree of cell IDs, group wrappers, grouping options and open/closed group states.
  A flat set of hashes cannot detect a reordered cell or a changed group.
- **`"NotebookOptions"`**: a digest of notebook options and metadata after the same narrow normalization.
  Include `StyleDefinitions` (including embedded styles), author/provenance metadata, notebook behavior options and all non-generated `TaggingRules` keys.
- **`"SourceSync"`**: `"Complete"` only when the supporting source has been reconciled with all notebook content and semantic settings that the generation path must preserve.
  Use `"Incomplete"` with `"PendingCells"` or a linked provenance entry when faithful source write-back is unavailable; an unchanged notebook hash does not clear that status.

Hash the actual held notebook data without evaluating Input cells or interpreting their boxes.
Preserve option values exactly; canonicalize equivalent association/option ordering only with a documented implementation that respects duplicate-option precedence.
Do not flatten group structure or normalize code/math into a supposedly equivalent expression for the preservation hash.

### Narrow normalization

Exclude only these generated fields at their own option/key locations:

- cell `CellChangeTimes`;
- automatically generated evaluation `CellLabel` values of the form `In[n]:=` or `Out[n]=` (retain custom labels);
- the cell `TaggingRules` key `"SourceLines"` only, retaining all other keys;
- notebook `FrontEndVersion`;
- the notebook `TaggingRules` key `"ResearchNotebook"` containing the fingerprint itself.

Everything else remains covered, including `CellTags`, `CellID`, `InitializationCell`, `Evaluatable`, `CellDingbat`, counter settings, formatting, `ExpressionUUID`, window settings and unrelated `TaggingRules`.
Do not delete matching rule names recursively from content or from embedded styles: a literal rule in Wolfram code is notebook content, not an option to ignore.
If serialization changes another field, investigate and record it; do not broaden the ignore list just to make the check pass.

## Stamping, checking and legacy notebooks

1. **Stamp only a known baseline.** For a newly generated notebook, assign unique small `CellID`s, write it, re-import it, then compute the schema-2 record from the round-tripped notebook.
   Stamp that imported expression while merging existing `TaggingRules`, write it, and re-import once more to check all three digests and the source-sync state.
   Never stamp an older edited file merely to make a subsequent check appear clean.
2. **Check before regeneration.** Re-read the saved `.nb`, compare cell digests, the ordered group tree and notebook options, and require `"SourceSync" -> "Complete"`.
   Resolve any cell-ID ambiguity conservatively as unverified content.
   Recheck immediately before writing so a concurrent edit is not overwritten.
3. **On drift, preserve the notebook.** Report the changed cells/options/structure and reconcile through [native targeted editing and per-cell write-back](../notebook-create/editing.md).
   An authorized targeted edit can continue without asking the human to transcribe or discard all unrelated changes.
   Discarding human changes or replacing the whole notebook requires explicit authorization for that action.
4. **Missing, legacy or partial records are unverified.** The former `<| CellID -> Hash[{content, style}] |>` scheme did not cover options, metadata or grouping/order.
   Matching legacy hashes cannot prove that human edits were preserved, and may not be silently upgraded into permission to rebuild.
   Use the actual `.nb` as the base; establish a new complete baseline only after reconciliation or an explicitly authorized replacement.
5. **After native edits or a revision round**, stamp the actual saved notebook if a baseline is being maintained, but retain `"SourceSync" -> "Incomplete"` whenever any notebook-only changes remain.
   Record the unresolved cells/settings in the existing provenance file so subsequent work cannot mistake a fresh stamp for a faithful Markdown source.

A clean schema-2 check permits a requested rebuild only for content designated as generated and fully reconciled; it does not override human ownership, scope or publication rules.
The schema above is a workflow requirement, not a claim that these instructions or an implementation were validated in a Wolfram kernel.
Historical tests of the older content/style hashes establish only their narrower behavior.

## Why Markdown export cannot substitute for this check

The former conversion audit at the pinned parser SHA recorded these losses from `ExportString[Import[path], "Markdown"]` on a research notebook:

- typeset constructs became references to PNGs that did not exist, including inline formulas, equations, citation buttons and a table;
- environment markers disappeared, so a Definition would return as ordinary Text;
- a Wolfram fence contained `$Failed` and converter-private symbols;
- Unicode, heading levels and frontmatter changed.

`NotebookToMarkdown.wl` also lost frontmatter and table headers in that audit (`Wiki/Resources/MarkdownToNotebook.md`).
These historical observations justify avoiding a Markdown editing round-trip; they do not claim that every exporter or future version behaves identically.
A requested Markdown export remains supported as a separate, checked output with explicit limitations ([editing.md](../notebook-create/editing.md#markdown-export)).
