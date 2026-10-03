# Revising a notebook from its notes

*[ LLM Generated ]*

A revision round on a notebook works `.nb` → `.nb`: it imports the version the user annotated and edited, rewrites only the cells holding a note (`<< … >>`), and exports the next version.
It never goes through Markdown, because that round trip loses typeset content and environment styles ([fingerprint.md](../../skills/new-research-notebook/fingerprint.md) § *Why there is no reverse direction*), and with them the user's edits.
The procedure is [skills/revise/round.md](../../skills/revise/round.md) § *Notebooks*; this article holds what was measured to make it.

## What was measured

On the AgentTools kernel (Wolfram 15.0), 2026-09-27, on small probe notebooks in the scratchpad.

- **A typed comment is a token.**
  The front end parses `>> make this smaller` in an Input cell to `BoxData[RowBox[{">>", " ", RowBox[{"make", …}]}]]`, and `Graph[x] (* >> use a smaller graph *)` to a `RowBox` holding `"(*"`, `">>"` and `"*)"`.
- **So is a note** (2026-10-03).
  A bare `<< shorter >>` parses to `RowBox[{RowBox[{"<<", " ", "shorter"}], " ", ">>"}]`, and `Graph[g] (* << smaller graph >> *)` to a comment `RowBox` holding `"<<"` and `">>"`.
  On joined cell text, `"<<" ~~ Shortest[___] ~~ ">>"` found the notes in a Text cell, in a Text cell spanning lines, and in both Input cells, and did not match `<< MyPackage`` (`Get`, no closing `>>`) or `a >> file` (`Put`) alone.
  `SyntaxQ["<< shorter >>"]` is `False`, so a cell with a bare note cannot run.
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

The first grammar (2026-09-27) was a line starting `>>`; on 2026-10-03 it became a delimited note `<< … >>`, which the operator chose so a note can sit inside a sentence or run over several lines.

- A delimited note needs no line rule: it is found in a text file with one non-greedy multi-line match (`perl -0777`, `/<<(.*?)>>/sg`), which also reports the lines it spans.
- The remaining collisions are code's own uses — Wolfram `Get` and `Put`, C++ shifts, shell heredocs — so in code a note goes inside a comment, and a match outside one is read before it is taken.
  The one case that matches is an Input cell holding both a `Get` and a `Put`.
- The first grammar's collision, Markdown's nested block quote `>>`, is gone.

## See also

- [The notebook TaggingRules registry](TaggingRulesRegistry.md) — the fingerprint key a round carries over untouched
- [Folded cell groups](FoldedCellGroups.md) — the group structure a round must walk into
