#!/usr/bin/env wolframscript

(* generate_notebooks.wls — Build .nb files from the .md sources of an
   Artifacts folder. Source and output share one dated stem and sit side by
   side; both are tracked. Pass the folder as the first argument to override
   the default Code/Artifacts. *)

(* Scripts live in <root>/Scripts/, so climb one level for the project root. *)
root = ParentDirectory[DirectoryName[$ScriptCommandLine[[1]]]];
nbDir = If[Length[$ScriptCommandLine] > 1,
	ExpandFileName[$ScriptCommandLine[[2]]],
	FileNameJoin[{root, "Code", "Artifacts"}]];

mdFiles = FileNames["*.md", nbDir];

If[mdFiles === {},
	Print["No .md sources found in ", nbDir];
	Exit[1]
];

markInitCells[cellList_List] :=
	Module[
		{inSetup = False, result = {}},
		Do[
			Which[
				MatchQ[c, Cell[t_String, "Chapter" | "Section" | "Subsection", ___] /;
					StringMatchQ[t, ("*Setup*" | "*Initialization*" | "*Preamble*" | "*Dependencies*"),
						IgnoreCase -> True]],
				inSetup = True; AppendTo[result, c],
				MatchQ[c, Cell[_, "Title" | "Chapter" | "Section" | "Subsection" | "Subsubsection", ___]],
				inSetup = False; AppendTo[result, c],
				inSetup && MatchQ[c, Cell[_, "Input", ___]],
				AppendTo[result, Append[c, InitializationCell -> True]],
				True,
				AppendTo[result, c]
			],
			{c, cellList}
		];
		result
	]

addLLMSubtitle[cellList_List] :=
	Module[{cells = DeleteCases[cellList, Cell["[[ LLM Generated ]]", "Subtitle", ___]], pos},
		pos = FirstPosition[cells, Cell[_, "Title", ___], Missing[], {1}];
		If[MissingQ[pos],
			Prepend[cells, Cell["[[ LLM Generated ]]", "Subtitle"]],
			Insert[cells, Cell["[[ LLM Generated ]]", "Subtitle"], pos[[1]] + 1]
		]
	]

(* Boxifying a cell whose code builds Graphics (Plot, HighlightGraph,
   InfraSceneHighlight, ...) strands it with a "Map is not a Graphics
   primitive" error at front-end evaluation, so leave such cells as plain
   text and boxify everything else (for hover/F1 docs). *)
vizHeads = {"Graphics", "Plot", "HighlightGraph", "InfraSceneHighlight",
	"Chart", "Histogram", "Manipulate", "Animate", "ArrayPlot", "MatrixPlot",
	"DensityPlot", "ContourPlot", "RegionPlot", "GraphPlot", "Show[", "Graph["};

vizCellQ[content_String] :=
	StringContainsQ[content, vizHeads]

boxifyCell[content_String, style_, opts___] :=
	If[vizCellQ[content],
		Cell[BoxData[content], style, opts],
		With[{parsed = ToExpression[content, StandardForm, Defer]},
			If[parsed === $Failed,
				Cell[BoxData[content], style, opts],
				Cell[BoxData[ToBoxes[parsed]], style, opts]
			]
		]
	]

(* Parse a leading `<!-- provenance: key: value ... -->` block (see the
   `project-provenance` skill). Returns an Association or None. *)
provenanceComment[text_String] :=
	SelectFirst[
		StringCases[text, Shortest["<!--" ~~ b___ ~~ "-->"] :> b],
		StringContainsQ[#, "provenance", IgnoreCase -> True] &,
		None
	]

parseProvenance[text_String] :=
	Module[{block, pairs},
		block = provenanceComment[text];
		If[block === None, Return[None]];
		pairs = Flatten @ StringCases[
			StringSplit[block, "\n"],
			StartOfString ~~ WhitespaceCharacter ... ~~ key : (LetterCharacter ..) ~~ ":" ~~
				WhitespaceCharacter ... ~~ val : __ :>
				(key -> StringTrim[StringTrim[val], "\""])
		];
		pairs = DeleteCases[pairs, ("provenance" -> _)];
		If[pairs === {}, None, Association[pairs]]
	]

Print["Notebook Generator"];
Print["==================="];
Print["Folder:  ", nbDir];
Print[""];

results = {};

Do[
	baseName = FileBaseName[mdFile];
	outFile = FileNameJoin[{nbDir, baseName <> ".nb"}];
	Print["[", baseName, "] Converting..."];

	md = Import[mdFile, "Text"];

	prov = parseProvenance[md];
	(* Drop only the provenance comment; leave any other HTML comments intact. *)
	md = StringReplace[md, Shortest["<!--" ~~ c___ ~~ "-->"] :>
		If[StringContainsQ[c, "provenance", IgnoreCase -> True], "", "<!--" <> c <> "-->"]];

	nb = ImportString[md, {"Markdown", "Notebook"}];
	cells = First[nb];
	cells = cells /. {
		Cell[c_, "Chapter", o___] :> Cell[c, "Section", o],
		Cell[c_, "Section", o___] :> Cell[c, "Subsection", o],
		Cell[c_, "Subsection", o___] :> Cell[c, "Subsubsection", o]
	};
	cells = cells /. {
		Cell[TextData[{StyleBox["[LLM Generated]" | "[ LLM Generated ]" | "[[ LLM Generated ]]", ___]}], _String, o___] :> Cell["[[ LLM Generated ]]", "Subtitle", o],
		Cell[TextData[StyleBox["[LLM Generated]" | "[ LLM Generated ]" | "[[ LLM Generated ]]", ___]], _String, o___] :> Cell["[[ LLM Generated ]]", "Subtitle", o],
		Cell["[LLM Generated]" | "[ LLM Generated ]" | "[[ LLM Generated ]]", _String, o___] :> Cell["[[ LLM Generated ]]", "Subtitle", o]
	};
	cells = cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts];
	cells = cells /. {
		Cell[BoxData[content_String], style:("Input" | "Code"), opts___] :> boxifyCell[content, style, opts],
		Cell[content_String, style:("Input" | "Code"), opts___] :> boxifyCell[content, style, opts]
	};
	cells = markInitCells[cells];
	cells = addLLMSubtitle[cells];

	nbExpr = If[prov === None,
		Notebook[cells],
		Notebook[cells, TaggingRules -> {"Provenance" -> prov}]
	];
	nbString = ExportString[nbExpr, "NB"];
	Export[outFile, nbString, "Text"];

	Print["[", baseName, "] Written: ", outFile];
	Print[""];
	AppendTo[results, baseName -> outFile],
	{mdFile, mdFiles}
];

Print["==================="];
Print["Generated ", Length[results], " notebook(s):"];
Do[Print["  ", r[[1]], " -> ", r[[2]]], {r, results}];
