#!/usr/bin/env wolframscript

(* build_dev_notebook.wls — assemble, evaluate, smoke-test, and cloud-deploy a
   paclet "dev notebook": a self-contained reference card + worked examples that
   shows what the paclet does, embedded outputs and all.

   This file is a TEMPLATE. The dev-notebook skill copies it into a paclet repo as
   Scripts/build_<name>_notebook.wls and fills the three marked sections:
     (A) CONFIG        — paclet name, context, directory, title, intro
     (B) REFERENCE     — exported symbols grouped by source module
     (C) EXAMPLES      — worked example sections (prose + held code)
   Everything else is reusable boilerplate and should not need editing.

   The generated .nb is a build artifact (write it under a gitignored folder).
   The .wls is the source of truth — re-running rebuilds and redeploys to the
   SAME cloud object, so the public URL is stable across versions.

   Usage: wolframscript -f Scripts/build_<name>_notebook.wls *)

(* ─────────────────────────────────────────────────────────────────────────
   (A) CONFIG — FILL THIS IN
   ───────────────────────────────────────────────────────────────────────── *)

pacletName   = "{{PACLET_NAME}}";                 (* e.g. "SyntheticInfrageometry" *)
pacletAuthor = "{{AUTHOR}}";                      (* shown in the README section title *)
pacletDir    = "{{PACLET_DIR}}";                  (* abs dir holding PacletInfo.wl *)
pacletNeeds  = "{{ORG_NAME}}`" <> pacletName <> "`";  (* context to Needs[] *)
notebooksDir = "{{NOTEBOOKS_DIR}}";               (* gitignored output dir, e.g. NotebooksLLM *)
cloudName    = "DevNotebooks/" <> pacletName <> ".nb";  (* stable cloud object name *)

nbTitle    = pacletName;
nbSubtitle = "Dev notebook \[Dash] " <> pacletName;
nbIntro    = "{{INTRO}}";  (* 2-4 plain sentences: what it is, what you're looking at.
                              NO formulas, function names, or option names here. *)

(* ─────────────────────────────────────────────────────────────────────────
   Reusable boilerplate — cell constructors, output heuristic, smoke test.
   ───────────────────────────────────────────────────────────────────────── *)

$messages = {};
$timedOut = False;

(* terse first line of a symbol's ::usage, "" if none *)
usageLine[ name_String ] :=
  With[ { u = Quiet @ MessageName[ Symbol[ name ], "usage" ] },
    If[ StringQ[ u ], First @ StringSplit[ u, "\n" ], name ] ];

(* embed graphics as a rasterized bitmap; everything small as live typeset boxes *)
rasterizeQ[ expr_ ] :=
  MemberQ[ { Graphics, Graphics3D, Image, Image3D, Legended, Graph }, Head @ expr ] ||
  ( MemberQ[ { Grid, Column, Row }, Head @ expr ] && ! FreeQ[ expr, _Graphics | _Graphics3D ] );

outCell[ result_ ] :=
  Cell[
    BoxData @ ToBoxes @ If[ rasterizeQ @ result,
      Rasterize[ result, ImageResolution -> 144, ImageSize -> 420 ],
      result ],
    "Output" ];

(* section / subsection / text cell constructors *)
sec[ title_ ] := Cell[ title, "Section" ];
sub[ title_ ] := Cell[ title, "Subsection" ];
txt[ body_ ]  := Cell[ body, "Text" ];

(* input + embedded output pair; code is HELD until evaluated here *)
io[ Hold[ code_ ] ] :=
  Module[ { result },
    result = TimeConstrained[ code, 60, $timedOut ];
    If[ result === $timedOut,
      Print[ "  TIMEOUT: ", ToString[ HoldForm[ code ], InputForm ] ] ];
    Sequence[
      Cell[ BoxData @ ToBoxes @ HoldForm @ code, "Input" ],
      outCell @ result ] ];

(* reference group: subsection + two-column Grid (signature | description) *)
refGroup[ moduleName_ -> syms_List ] :=
  Sequence[
    sub @ moduleName,
    Cell[
      BoxData @ ToBoxes @ Grid[
        { StyleBox[ #, "Code" ], usageLine @ # } & /@ syms,
        Alignment -> { Left, Left }, Spacings -> { 2, 1 },
        Dividers -> None ],
      "Output" ] ];

(* ─────────────────────────────────────────────────────────────────────────
   Load the paclet (errors here are fatal — the notebook must run clean).
   ───────────────────────────────────────────────────────────────────────── *)

PacletDirectoryLoad[ pacletDir ];
Needs[ pacletNeeds ];

(* ─────────────────────────────────────────────────────────────────────────
   Smoke test: collect every message raised while the examples evaluate.
   Each io[] forces a render via Rasterize, so render-time errors are caught too.
   ───────────────────────────────────────────────────────────────────────── *)

Internal`HandlerBlock[ { "Message", (AppendTo[ $messages, #1 ] &) },

  (* ───────────────────────────────────────────────────────────────────────
     (B) REFERENCE — FILL THIS IN
     One entry per source module, listing its exported symbols.
     usageLine pulls each symbol's ::usage first line automatically, so this
     never drifts from the code.
     ─────────────────────────────────────────────────────────────────────── *)

  referenceGroups = {
    "{{MODULE_A}}" -> { "{{SymbolA1}}", "{{SymbolA2}}" },
    "{{MODULE_B}}" -> { "{{SymbolB1}}", "{{SymbolB2}}" }
  };

  (* ───────────────────────────────────────────────────────────────────────
     (C) EXAMPLES — FILL THIS IN
     One {sec, txt, io...} block per concept. Mostly code, each io[] producing
     a picture. Wrap option/method variants in their own sub[] titled by the
     literal code form of the option. Follow the project's example house style.
     ─────────────────────────────────────────────────────────────────────── *)

  exampleCells = {

    sec @ "{{EXAMPLE_1_TITLE}}",
    txt @ "{{EXAMPLE_1_PROSE}}",
    io @ Hold[ {{EXAMPLE_1_CODE}} ],

    sec @ "{{EXAMPLE_2_TITLE}}",
    txt @ "{{EXAMPLE_2_PROSE}}",
    sub @ "{{OPTION_FORM_1}}",   (* e.g. "Method" -> "3DFiber" *)
    io @ Hold[ {{EXAMPLE_2_CODE_A}} ],
    sub @ "{{OPTION_FORM_2}}",
    io @ Hold[ {{EXAMPLE_2_CODE_B}} ]

  };

  (* ───────────────────────────────────────────────────────────────────────
     Assemble the notebook. Title + the spec subtitle + the mandatory
     [LLM Generated] marker, then intro, reference, examples.
     ─────────────────────────────────────────────────────────────────────── *)

  notebook = Notebook[
    Flatten @ {
      Cell[ nbTitle, "Title" ],
      Cell[ nbSubtitle, "Subtitle" ],
      Cell[ "[LLM Generated]", "Subtitle" ],
      Cell[ nbIntro, "Text" ],
      sec @ "Function reference",
      referenceGroups /. (g_Rule :> refGroup[ g ]) // Apply[ Sequence ],
      exampleCells
    },
    WindowTitle -> nbSubtitle
  ];
];

(* ─────────────────────────────────────────────────────────────────────────
   Report messages — must be ZERO before deploy.
   ───────────────────────────────────────────────────────────────────────── *)

If[ $messages =!= {},
  Print[ "SMOKE TEST FAILED \[Dash] ", Length @ $messages, " message(s):" ];
  Print[ "  ", # ] & /@ DeleteDuplicates @ $messages;
  Print[ "Fix the offending example (shrink the input rather than raising the cap), then rerun." ];
  Exit[ 1 ] ];

Print[ "Smoke test: 0 messages." ];

(* ─────────────────────────────────────────────────────────────────────────
   Export local .nb (gitignored artifact) and deploy public to the cloud.
   ───────────────────────────────────────────────────────────────────────── *)

If[ ! DirectoryQ @ notebooksDir, CreateDirectory[ notebooksDir, CreateIntermediateDirectories -> True ] ];
localPath = FileNameJoin[ { notebooksDir, pacletName <> "DevNotebook.nb" } ];
Export[ localPath, notebook ];
Print[ "Wrote ", localPath ];

CloudConnect[];
cloudObj = CloudDeploy[ notebook, CloudObject[ cloudName ], Permissions -> "Public" ];
cloudURL = First @ cloudObj;

Print[ "" ];
Print[ "=== DEV_NOTEBOOK_URL: ", cloudURL, " ===" ];
