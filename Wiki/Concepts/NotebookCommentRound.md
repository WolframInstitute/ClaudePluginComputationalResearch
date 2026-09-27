# Revising a notebook from its comments

*[ LLM Generated ]*

A revision round on a notebook works `.nb` → `.nb`: it imports the version the user commented and edited, rewrites only the commented cells, and exports the next version.
It never goes through Markdown, because that round trip loses typeset content and environment styles ([fingerprint.md](../../skills/new-research-notebook/fingerprint.md) § *Why there is no reverse direction*), and with them the user's edits.
The procedure is [skills/revise/round.md](../../skills/revise/round.md) § *Notebooks*; this article holds what was measured to make it.

## What was measured

On the AgentTools kernel (Wolfram 15.0), 2026-09-27, on small probe notebooks in the scratchpad.

- **A typed comment is a token.**
  The front end parses `>> make this smaller` in an Input cell to `BoxData[RowBox[{">>", " ", RowBox[{"make", …}]}]]`, and `Graph[x] (* >> use a smaller graph *)` to a `RowBox` holding `"(*"`, `">>"` and `"*)"`.
- **A cell's text needs no front end.**
  `StringJoin @ Cases[content, _String, {0, Infinity}]` gave the same text as the front end's `ExportPacket[cell, "InputText"]` on every probe cell — Text, `TextData` with a `StyleBox`, and Input — so finding comments costs no front end process.
- **Group cells match too.**
  A `CellGroupData` cell contains the strings of every cell under it, so a search over all `Cell`s also returns the section above each comment.
  The pattern has to exclude `_CellGroupData` content.
- **`Export` adds three options, once.**
  A notebook built without them comes back from `Export`/`Import` with `FrontEndVersion`, `StyleDefinitions` and an `ExpressionUUID`; after that the round trip is a fixed point, and `Get` and `Import[…, "NB"]` return the same expression.
- **Rewriting content leaves the rest identical.**
  `ReplacePart` on the content of two cells, then `Export` and re-import: the notebook options were unchanged and exactly those two cells differed.
- **Code for an Input cell** comes from the front end's parser packet, `FrontEnd`UndocumentedTestFEParserPacket[code, False]`, which returns the `BoxData` with lines separated by `"\n"`.

## Why the grammar is what it is

- A bare `>>` counts only at the start of a line, because in the middle of Wolfram code it is `Put`: `a >> b` is not a comment.
  At the start of an Input cell it is a syntax error, so a commented cell cannot run by mistake.
- A `>>` after a comment sign counts anywhere in a line, since `(* >>`, `% >>` or `// >>` has no other reading.
- The one real collision is Markdown's nested block quote, which is also written `>>`; generated Markdown uses none.

## See also

- [The notebook TaggingRules registry](TaggingRulesRegistry.md) — the fingerprint key a round carries over untouched
- [Folded cell groups](FoldedCellGroups.md) — the group structure a round must walk into
