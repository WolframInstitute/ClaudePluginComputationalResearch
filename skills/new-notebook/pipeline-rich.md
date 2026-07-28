# new-notebook: rich engine pipeline

The [`WolframInstitute/MarkdownToNotebook`](https://github.com/WolframInstitute/MarkdownToNotebook) path, used at a pinned SHA from a local clone — see [Wiki/Resources/MarkdownToNotebook.md](../../Wiki/Resources/MarkdownToNotebook.md).
Read when actually generating a notebook on the rich path; engine selection is in [SKILL.md](SKILL.md).

## What rich mode changes

| | Built-in | Rich |
|---|---|---|
| `## Heading` | `"Chapter"` — the down-shift fixes it | `"Section"` already — **do not shift** |
| `wolfram` fence | `BoxData["raw string"]` — needs `boxifyInputCells` and its visualization guard | structural `RowBox`, source spacing verbatim — **no boxify, no guard** |
| YAML frontmatter | leaks in as a `Text` cell | consumed as metadata |
| `$…$` / `$$…$$` | flat `InlineMath` | `InlineFormula` / `DisplayFormula` with real `FractionBox`, `SubscriptBox` |
| Markdown table | Tabular/TableView | `2ColumnTableMod` with `TableText` cells |
| Notebook options | none | `CreateCellID -> True`, `StyleDefinitions -> "Default.nb"` |
| `CellLabel` | none | stale `In[n]:=` stamped even under `"Evaluate" -> False` |

Two consequences are easy to get wrong:

- **Keep the notebook options.** `ExportString[Notebook[cells], "NB"]` silently drops them; rich mode must rebuild the original expression instead — `ReplacePart[nb, 1 -> cells]`.
- **Drop the boxify step, keep the rest.** The parser already emits the structural box tree, so `boxifyInputCells` is dead weight, and its visualization guard is unnecessary: the guard existed only because `ToBoxes[ToExpression[…, Defer]]` strands graphics cells, and rich mode never calls it.
  `markInitCells` and the `[ LLM Generated ]` marker normalization still apply unchanged.

## Surface the parser degradation

The converter's `ensureParser[]` installs the `Wolfram/Parser` paclet on first use.
On a fresh machine that is network I/O, and if it fails the converter **silently** degrades to `ImportString[…, "TeX"]` with worse math fidelity.
Probe before converting and report the result — do not swallow it:

```wolfram
PacletFind["Wolfram/Parser"] =!= {}
```

If it returns `False`, say the first conversion will install a paclet, and that math fidelity degrades silently if the install fails.

## The rich-mode Wolfram MCP call

Same shape as the built-in call, minus the heading shift and the boxify step, plus `CellLabel` stripping and option preservation.
Build `md` with the same `tick` / `fence` rules.
Define `markInitCells` and `addLLMSubtitle` exactly as in [pipeline-builtin.md](pipeline-builtin.md) — **one change**: `markInitCells` matches heading styles `"Section"|"Subsection"|"Subsubsection"` (and resets on `"Title"|"Section"|"Subsection"|"Subsubsection"`), because rich mode never produces `"Chapter"`.

```wolfram
Module[{wl, md, nb, cells, markInitCells, addLLMSubtitle},

  wl = "MarkdownToNotebook/MarkdownToNotebook.wl";   (* pinned clone, project root *)

  (* markInitCells and addLLMSubtitle: definitions from pipeline-builtin.md,
     with the Section-first heading match described above *)

  md = StringJoin["# My Notebook Title\n\n", "**[ LLM Generated ]**\n\n", "..."];

  Get[wl];
  nb = MarkdownToNotebook[md, "Evaluate" -> False];
  cells = First[nb];
  cells = cells /. {
    Cell[TextData[{StyleBox["[LLM Generated]" | "[ LLM Generated ]", ___]}], _String, o___] :> Cell["[ LLM Generated ]", "Subtitle"],
    Cell[TextData[StyleBox["[LLM Generated]" | "[ LLM Generated ]", ___]], _String, o___] :> Cell["[ LLM Generated ]", "Subtitle"],
    Cell["[LLM Generated]" | "[ LLM Generated ]", _String, o___] :> Cell["[ LLM Generated ]", "Subtitle"]
  };
  cells = cells /. Cell[c_, s_String, o___] :>
    Cell[c, s, Sequence @@ DeleteCases[{o}, CellLabel -> _]];
  cells = markInitCells[cells];
  cells = addLLMSubtitle[cells];
  ExportString[ReplacePart[nb, 1 -> cells], "NB"]
]
```

Note the differences from the built-in call, each load-bearing:

- **No heading shift** — `##` is already `"Section"`, so shifting would demote every heading one level too far.
- **No `boxifyInputCells`, no `vizCellQ`** — the boxes arrive structural.
- **`markInitCells` matches `"Section"` first**, not `"Chapter"`.
- **`ReplacePart[nb, 1 -> cells]`**, not `Notebook[cells]` — keeps `CreateCellID` and `StyleDefinitions`.
- **`CellLabel` stripped** — the converter stamps `In[n]:=` on cells it did not evaluate.

With provenance on, stamp per SKILL.md § *Provenance*: apply `stampTaggingRule` to `ReplacePart[nb, 1 -> cells]`, which it leaves option-complete.
