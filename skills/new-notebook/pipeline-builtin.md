# new-notebook: built-in engine pipeline

The post-processing and the complete MCP call for the built-in engine (`ImportString[md, {"Markdown", "Notebook"}]`).
Read when actually generating a notebook on the built-in path; engine selection and all conventions are in [SKILL.md](SKILL.md).

## Post-processing

After `ImportString`, apply these transformations before `ExportString` — the function definitions appear **once**, inside the complete call below:

1. **Heading shift.** The WL-15 importer maps `##`→`Chapter`; the corpus uses `Title`/`Section`/`Subsection`, so every heading shifts down one level (`Chapter`→`Section`, `Section`→`Subsection`, `Subsection`→`Subsubsection`) immediately after `cells = First[nb]`.
2. **Marker normalization.** Any `**[ LLM Generated ]**` bold-Text marker from the source (legacy unspaced spelling included) becomes a single `"Subtitle"` cell.
3. **Rename `"Program"` → `"CodeText"`** — untagged fences are display-only code.
4. **`boxifyInputCells` — Critical.** The importer produces `Cell[BoxData["raw string"], "Input"]`; without a structural `RowBox` tree, hover help, F1 lookup, autocomplete, and the suggestion bar are all dead.
   Boxify via `ToBoxes[ToExpression[code, StandardForm, Defer]]` (`Defer` keeps the code unevaluated) — **except** visualization cells.
   **Visualization guard:** boxifying a cell whose code produces `Graphics` (`Plot`, `HighlightGraph`, charts, …) strands it with a `Map is not a Graphics primitive` error at front-end evaluation; those cells stay as plain `BoxData[content]`, same as the parse-failure fallback.
   Do not skip this step — without it, every Input cell ships broken.
5. **`markInitCells`.** Input cells under `Setup`/`Initialization`/`Preamble`/`Dependencies` headings get `InitializationCell -> True`.
   Wildcard `StringMatchQ` avoids false positives ("Indefinite Integrals" must NOT trigger).
6. **`addLLMSubtitle` — Critical.** Every generated notebook carries a `"Subtitle"` cell reading `[ LLM Generated ]` (spaced form) directly under the `"Title"`; the function dedupes so exactly one marker ships, whether the source carried one or not.
   Never ship an LLM-generated `.nb` without this marker (paclet code is exempt; notebooks are not).

## The complete Wolfram MCP call

This is the canonical copy of `vizCellQ`, `boxifyInputCells`, `markInitCells`, and `addLLMSubtitle` — [pipeline-rich.md](pipeline-rich.md) reuses the last two from here rather than restating them.

```wolfram
Module[{md, nb, cells, markInitCells, boxifyInputCells, addLLMSubtitle, vizCellQ, vizHeads, tick, fence},

  tick = FromCharacterCode[96];
  fence = StringJoin[tick, tick, tick];

  vizHeads = {"Graphics", "Plot", "HighlightGraph", "InfraSceneHighlight",
    "Chart", "Histogram", "Manipulate", "Animate", "ArrayPlot", "MatrixPlot",
    "DensityPlot", "ContourPlot", "RegionPlot", "GraphPlot", "Show[", "Graph["};
  vizCellQ[content_String] := StringContainsQ[content, vizHeads];

  boxifyInputCells[cellList_List] := cellList /. {
    Cell[BoxData[content_String], style:("Input"|"Code"), opts___] :>
      If[vizCellQ[content], Cell[BoxData[content], style, opts],
        With[{parsed = ToExpression[content, StandardForm, Defer]},
          If[parsed === $Failed,
            Cell[BoxData[content], style, opts],
            Cell[BoxData[ToBoxes[parsed]], style, opts]
          ]
        ]],
    Cell[content_String, style:("Input"|"Code"), opts___] :>
      If[vizCellQ[content], Cell[BoxData[content], style, opts],
        With[{parsed = ToExpression[content, StandardForm, Defer]},
          If[parsed === $Failed,
            Cell[BoxData[content], style, opts],
            Cell[BoxData[ToBoxes[parsed]], style, opts]
          ]
        ]]
  };

  markInitCells[cellList_List] := Module[{inSetup = False, result = {}},
    Do[Which[
      MatchQ[c, Cell[t_String, "Chapter"|"Section"|"Subsection", ___] /;
        StringMatchQ[t, ("*Setup*"|"*Initialization*"|"*Preamble*"|"*Dependencies*"),
          IgnoreCase -> True]],
        inSetup = True; AppendTo[result, c],
      MatchQ[c, Cell[_, "Title"|"Chapter"|"Section"|"Subsection"|"Subsubsection", ___]],
        inSetup = False; AppendTo[result, c],
      inSetup && MatchQ[c, Cell[_, "Input", ___]],
        AppendTo[result, Append[c, InitializationCell -> True]],
      True, AppendTo[result, c]
    ], {c, cellList}];
    result
  ];

  addLLMSubtitle[cellList_List] := Module[
    {cells = DeleteCases[cellList, Cell["[ LLM Generated ]", "Subtitle", ___]], pos},
    pos = FirstPosition[cells, Cell[_, "Title", ___], Missing[], {1}];
    If[MissingQ[pos],
      Prepend[cells, Cell["[ LLM Generated ]", "Subtitle"]],
      Insert[cells, Cell["[ LLM Generated ]", "Subtitle"], pos[[1]] + 1]]
  ];

  md = StringJoin[
    "# My Notebook Title\n\n",
    "Introductory text.\n\n",
    "## Setup\n\n",
    fence, "wolfram\nNeeds[\"Pkg", tick, "\"]\n", fence, "\n\n",
    "## Analysis\n\n",
    "Explanatory text.\n\n",
    fence, "wolfram\nPlot[Sin[x], {x, 0, 2 Pi}]\n", fence, "\n"
  ];

  nb = ImportString[md, {"Markdown", "Notebook"}];
  cells = First[nb];
  cells = cells /. {
    Cell[c_, "Chapter", o___] :> Cell[c, "Section", o],
    Cell[c_, "Section", o___] :> Cell[c, "Subsection", o],
    Cell[c_, "Subsection", o___] :> Cell[c, "Subsubsection", o]
  };
  cells = cells /. {
    Cell[TextData[{StyleBox["[LLM Generated]" | "[ LLM Generated ]", ___]}], _String, o___] :> Cell["[ LLM Generated ]", "Subtitle", o],
    Cell[TextData[StyleBox["[LLM Generated]" | "[ LLM Generated ]", ___]], _String, o___] :> Cell["[ LLM Generated ]", "Subtitle", o],
    Cell["[LLM Generated]" | "[ LLM Generated ]", _String, o___] :> Cell["[ LLM Generated ]", "Subtitle", o]
  };
  cells = cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts];
  cells = boxifyInputCells[cells];
  cells = markInitCells[cells];
  cells = addLLMSubtitle[cells];
  ExportString[Notebook[cells], "NB"]
]
```

With provenance on, wrap the final expression per SKILL.md § *Provenance*: `ExportString[ stampTaggingRule[ Notebook[cells], "Provenance" -> prov ], "NB" ]`.
