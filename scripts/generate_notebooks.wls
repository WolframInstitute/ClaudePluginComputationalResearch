#!/usr/bin/env wolframscript

(* generate_notebooks.wls — Build .nb files from Wiki/Notebooks/*.md sources *)

root = DirectoryName[$ScriptCommandLine[[1]]];
wikiDir = FileNameJoin[{root, "Wiki", "Notebooks"}];
outDir = FileNameJoin[{root, "Notebooks"}];

mdFiles = FileNames["*.md", wikiDir];

If[mdFiles === {},
	Print["No .md sources found in ", wikiDir];
	Exit[1]
];

If[!DirectoryQ[outDir],
	CreateDirectory[outDir]
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

Print["Notebook Generator"];
Print["==================="];
Print["Source:  ", wikiDir];
Print["Output:  ", outDir];
Print[""];

results = {};

Do[
	baseName = FileBaseName[mdFile];
	outFile = FileNameJoin[{outDir, baseName <> ".nb"}];
	Print["[", baseName, "] Converting..."];

	md = Import[mdFile, "Text"];

	nb = ImportString[md, {"Markdown", "Notebook"}];
	cells = First[nb];
	cells = cells /. Cell[content_, "Program", opts___] :> Cell[content, "CodeText", opts];
	cells = cells /. {
		Cell[BoxData[content_String], style:("Input" | "Code"), opts___] :>
			With[ { parsed = ToExpression[ content, StandardForm, Defer ] },
				If[ parsed === $Failed,
					Cell[ BoxData[ content ], style, opts ],
					Cell[ BoxData[ ToBoxes[ parsed ] ], style, opts ]
				]
			],
		Cell[content_String, style:("Input" | "Code"), opts___] :>
			With[ { parsed = ToExpression[ content, StandardForm, Defer ] },
				If[ parsed === $Failed,
					Cell[ BoxData[ content ], style, opts ],
					Cell[ BoxData[ ToBoxes[ parsed ] ], style, opts ]
				]
			]
	};
	cells = markInitCells[cells];

	nbString = ExportString[Notebook[cells], "NB"];
	Export[outFile, nbString, "Text"];

	Print["[", baseName, "] Written: ", outFile];
	Print[""];
	AppendTo[results, baseName -> outFile],
	{mdFile, mdFiles}
];

Print["==================="];
Print["Generated ", Length[results], " notebook(s):"];
Do[Print["  ", r[[1]], " -> ", r[[2]]], {r, results}];
