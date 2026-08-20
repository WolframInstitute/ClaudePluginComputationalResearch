$MathNotebookEnvironmentStyles = {
  "Theorem", "Lemma", "Proposition", "Corollary", "Conjecture", "Claim",
  "Definition", "Example", "Construction",
  "Remark", "Question", "Observation"
};

(* Styles a bold marker can name. Proof is a PlainArticle style but takes no
   number and is not citable, so it stays out of the environment list. *)
$MathNotebookMarkerStyles = Append[ $MathNotebookEnvironmentStyles, "Proof" ];

$MathNotebookStyleSheetName = "PlainArticle.nb";

$MathNotebookReferenceLabelSpec = Join[
  <| "DisplayFormulaNumbered" -> { "(", { "DisplayFormulaNumbered" }, ")" },
     "Section" -> { "Section ", { "Section" }, "" },
     "Subsection" -> { "Section ", { "Section", "Subsection" }, "" },
     "Subsubsection" -> { "Section ", { "Section", "Subsection", "Subsubsection" }, "" },
     "ItemNumbered" -> { "Item ", { "ItemNumbered" }, "" } |>,
  AssociationMap[ { # <> " ", { "Section", "Theorem" }, "" } &, $MathNotebookEnvironmentStyles ] ];

MathNotebookDocument[ cells_List, bibTags_List : { }, opts : OptionsPattern[ Notebook ] ] :=
  Notebook[
    ConvertCitations[ NumberTaggedFormulas @ ConvertEnvironmentCells @ cells, bibTags ],
    opts, StyleDefinitions -> MathNotebookStyleSheet[ ] ]

(* Every pass walks INTO CellGroupData. A research notebook folds each Example under the claim
   it supports, so its environment marker, its tagged equations and its citations all sit inside
   a group -- at level {1} they were silently skipped and the Example stayed a Text cell. *)
mapCellList[ f_, cells_List ] :=
  Replace[ cells, {
    Cell[ CellGroupData[ group_List, state___ ], opts___ ] :>
      Cell[ CellGroupData[ mapCellList[ f, group ], state ], opts ],
    cell_Cell :> f[ cell ] },
    { 1 } ]

documentCells[ cells_List ] :=
  Flatten @ Replace[ cells, {
    Cell[ CellGroupData[ group_List, ___ ], ___ ] :> documentCells @ group,
    cell_Cell :> { cell } },
    { 1 } ]

NumberTaggedFormulas[ cells_List ] :=
  mapCellList[ numberTaggedFormula, cells ]

numberTaggedFormula[ Cell[ content_, "DisplayFormula", opts___ ] ] /; ! FreeQ[ { opts }, CellTags ] :=
  Cell[ content, "DisplayFormulaNumbered", opts ]

numberTaggedFormula[ cell_ ] :=
  cell

ConvertEnvironmentCells[ Notebook[ cells_List, opts___ ] ] :=
  Notebook[ ConvertEnvironmentCells @ cells, opts ]

ConvertEnvironmentCells[ cells_List ] :=
  mapCellList[ convertEnvironmentCell, cells ]

MathNotebookStyleSheet[ ] :=
  Get @ FileNameJoin @ {
    PacletObject[ "WolframInstitute/MathNotebook" ][ "Location" ],
    "FrontEnd", "StyleSheets", "MathNotebook", $MathNotebookStyleSheetName }

ConvertCitations[ cells_List, bibTags_List ] :=
  With[ { targets = CitationTargets @ cells },
    mapCellList[ citationCell[ #, targets, bibTags ] &, cells ] ]

citationCell[ Cell[ TextData[ content_ ], style_String, opts___ ], targets_, bibTags_ ] :=
  Cell[ TextData @ Flatten[ citationSplit[ #, targets, bibTags ] & /@ Flatten @ { content } ],
    style, opts ]

citationCell[ cell_, _, _ ] :=
  cell

CitationTargets[ cells_List ] :=
  Association @ Cases[ documentCells @ cells,
    Cell[ _, style_String, opts___ ] /; ! FreeQ[ { opts }, CellTags ] :>
      First @ Flatten @ { CellTags /. { opts } } -> style ]

ReferenceCells[ entries_Association ] :=
  KeyValueMap[
    { tag, text } |-> Cell[ TextData @ text, "Reference", CellTags -> tag,
      CellDingbat -> Cell[ TextData @ referenceLabel @ tag ] ],
    entries ]

BibTeXReferences[ file_String ] :=
  Association @ Map[ bibEntry,
    StringCases[ Import[ file, "Text" ],
      "@" ~~ Except[ "{" ] .. ~~ "{" ~~ body : Shortest[ __ ] ~~
        "\n" ~~ WhitespaceCharacter ... ~~ "}" :> body ] ]

convertEnvironmentCell[ Cell[ TextData[ content_ ], "Text", opts___ ] ] :=
  Replace[ markerSplit @ Flatten @ { content },
    { { style_String, rest_List } :> Cell[ TextData @ rest, style, opts ],
      _ :> Cell[ TextData @ content, "Text", opts ] } ]

convertEnvironmentCell[ Cell[ text_String, "Text", opts___ ] ] :=
  convertEnvironmentCell @ Cell[ TextData @ { text }, "Text", opts ]

convertEnvironmentCell[ cell_ ] :=
  cell

markerSplit[ { StyleBox[ marker_String, ___ ], rest___ } ] :=
  Replace[ markerStyle @ marker, { style_String :> { style, trimLeading @ { rest } } } ]

markerSplit[ { first_String, rest___ } ] :=
  Replace[
    StringCases[ first,
      StartOfString ~~ "**" ~~ marker : Except[ "*" ] .. ~~ "**" ~~ tail___ :> { marker, tail } ],
    { { { marker_String, tail_String } } :>
        Replace[ markerStyle @ marker,
          { style_String :> { style, trimLeading @ Prepend[ { rest }, tail ] } } ] } ]

markerSplit[ _ ] :=
  None

markerStyle[ marker_String ] :=
  SelectFirst[ $MathNotebookMarkerStyles,
    StringMatchQ[ StringTrim @ marker, # ~~ "." ] & ]

trimLeading[ { first_String, rest___ } ] :=
  DeleteCases[ Prepend[ { rest }, StringDelete[ first, StartOfString ~~ Whitespace ] ], "" ]

trimLeading[ content_List ] :=
  content

citationSplit[ text_String, targets_Association, bibTags_List ] :=
  StringSplit[ text,
    "[" ~~ tag : ( Alternatives @@ Join[ Keys @ targets, bibTags ] ) ~~ "]" :>
      citationButton[ tag, Lookup[ targets, tag, None ] ] ]

citationSplit[ content_, targets_Association, bibTags_List ] :=
  content

citationButton[ tag_String ] :=
  ButtonBox[ referenceLabel @ tag, BaseStyle -> "Citation", ButtonData -> tag ]

citationButton[ tag_String, style_ ] :=
  Replace[ Lookup[ $MathNotebookReferenceLabelSpec, style, None ],
    { { prefix_, counters_, suffix_ } :>
        ButtonBox[
          RowBox @ DeleteCases[
            Flatten @ { prefix, Riffle[ CounterBox[ #, tag ] & /@ counters, "." ], suffix }, "" ],
          BaseStyle -> "Citation", ButtonData -> tag ],
      _ :> citationButton @ tag } ]

referenceLabel[ tag_String ] :=
  "[" <> tag <> "]"

bibEntry[ body_String ] :=
  StringTrim @ First @ StringSplit[ body, "," ] -> formatReference @ bibFields @ body

(* A braced value closes at the "}" that ENDS THE FIELD -- the one followed by the
   separating comma or by the end of the entry -- not at the first "}" in it. The
   brace-protected capitalisation Crossref emits (title = {A {Hodge} theory})
   truncated at the inner brace under the old first-"}" rule. The loose clause is
   kept last so a field the strict one cannot parse is still read, not dropped. *)
bibFields[ body_String ] :=
  Association @ StringCases[ body, {
    key : WordCharacter .. ~~ Whitespace ... ~~ "=" ~~ Whitespace ... ~~
      "{" ~~ value : Shortest[ ___ ] ~~ "}" ~~ WhitespaceCharacter ... ~~
        ( "," | EndOfString ) :> bibField[ key, value ],
    key : WordCharacter .. ~~ Whitespace ... ~~ "=" ~~ Whitespace ... ~~
      "\"" ~~ value : Shortest[ ___ ] ~~ "\"" :> bibField[ key, value ],
    key : WordCharacter .. ~~ Whitespace ... ~~ "=" ~~ Whitespace ... ~~
      value : DigitCharacter .. :> bibField[ key, value ],
    key : WordCharacter .. ~~ Whitespace ... ~~ "=" ~~ Whitespace ... ~~
      "{" ~~ value : Shortest[ ___ ] ~~ "}" :> bibField[ key, value ] } ]

(* The braces are BibTeX's capitalisation guard and mean nothing in a notebook, so
   they come out: "A {Hodge} theory" would otherwise print its braces to a reader. *)
bibField[ key_String, value_String ] :=
  ToLowerCase @ key ->
    StringTrim @ StringDelete[ StringReplace[ value, Whitespace -> " " ], "{" | "}" ]

formatReference[ fields_Association ] :=
  StringRiffle[ Lookup[ fields, { "author", "title", "journal", "year" }, Nothing ], ", " ] <>
    referenceLink @ fields

referenceLink[ fields_Association ] :=
  Which[
    KeyExistsQ[ fields, "doi" ], ", https://doi.org/" <> fields[ "doi" ],
    KeyExistsQ[ fields, "eprint" ], ", https://arxiv.org/abs/" <> fields[ "eprint" ],
    KeyExistsQ[ fields, "url" ], ", " <> fields[ "url" ],
    True, "" ]

(* ==================== research-notebook generator passes ====================
   These four ran as prose in the skill and were re-implemented on every build.
   They live here beside the passes they must be ordered against:
     ReadCellTags  -> FoldExampleGroups -> MathNotebookDocument -> AssignCellIDs
   ReadCellTags walks the FLAT list, so it must precede any grouping; the passes
   inside MathNotebookDocument recurse on their own (mapCellList).            *)

addCellOption[ Cell[ args__ ], opt_Rule ] :=
  Module[ { parts = { args }, styles, rest },
    styles = TakeWhile[ Rest @ parts, StringQ ];
    rest = Drop[ parts, 1 + Length @ styles ];
    Cell[ First @ parts, Sequence @@ styles, opt,
      Sequence @@ DeleteCases[ rest, First[ opt ] -> _ ] ] ]

(* ---- {#Tag} in the source becomes CellTags ---- *)

ReadCellTags[ cells_List ] :=
  Fold[ readCellTag, { }, cells ]

readCellTag[ done_List, cell_Cell ] :=
  With[ { tag = standaloneCellTag @ cell },
    Which[
      StringQ[ tag ] && done =!= { }, MapAt[ addCellOption[ #, CellTags -> tag ] &, done, -1 ],
      StringQ[ tag ], done,
      True, Append[ done, inlineCellTag @ cell ] ] ]

(* a cell whose WHOLE content is {#Tag} names the cell above it -- the shape a
   display equation's tag takes, written on the line after the equation *)
standaloneCellTag[ Cell[ content_, ___ ] ] :=
  Replace[
    StringCases[ cellPlainText @ content,
      StartOfString ~~ WhitespaceCharacter ... ~~ "{#" ~~ tag : Except[ "}" ] .. ~~ "}" ~~
        WhitespaceCharacter ... ~~ EndOfString :> tag ],
    { { tag_String } :> tag, _ :> None } ]

inlineCellTag[ Cell[ content_, rest___ ] ] :=
  Replace[ trailingCellTag @ content,
    { { stripped_, tag_String } :> addCellOption[ Cell[ stripped, rest ], CellTags -> tag ],
      _ :> Cell[ content, rest ] } ]

trailingCellTag[ text_String ] :=
  Replace[
    StringCases[ text,
      StartOfString ~~ body___ ~~ WhitespaceCharacter ... ~~ "{#" ~~ tag : Except[ "}" ] .. ~~ "}" ~~
        WhitespaceCharacter ... ~~ EndOfString :> { body, tag } ],
    { { { body_String, tag_String } } :>
        { StringDelete[ body, WhitespaceCharacter .. ~~ EndOfString ], tag },
      _ :> None } ]

trailingCellTag[ TextData[ content_ ] ] :=
  Module[ { parts = Flatten @ { content } },
    If[ parts === { } || ! StringQ @ Last @ parts,
      None,
      Replace[ trailingCellTag @ Last @ parts,
        { { stripped_String, tag_String } :>
            { TextData @ DeleteCases[ ReplacePart[ parts, -1 -> stripped ], "" ], tag },
          _ :> None } ] ] ]

trailingCellTag[ _ ] :=
  None

cellPlainText[ text_String ] :=
  text

cellPlainText[ TextData[ content_ ] ] :=
  StringJoin @ Cases[ Flatten @ { content }, _String ]

cellPlainText[ _ ] :=
  ""

(* ---- the fold: a closed group displaying its SECOND cell ----
   Open shows both, Closed shows the Input -- backwards. Accepts either a bare
   Input followed by an Output or an already-grouped pair, so it can run before
   or after the outputs are embedded. A SECOND Output lands outside the group,
   which is the visible symptom of a violated one-Output-per-Input rule.      *)

FoldExampleGroups[ cells_List ] :=
  Fold[ foldExampleGroup, { }, cells ]

foldExampleGroup[ done_List, Cell[ CellGroupData[ group_List, ___ ], opts___ ] ] /;
  inputOutputGroupQ @ group :=
  Append[ done, Cell[ CellGroupData[ group, { 2 } ], opts ] ]

foldExampleGroup[ done_List, cell : Cell[ _, "Output", ___ ] ] /;
  done =!= { } && inputCellQ @ Last @ done :=
  MapAt[ Cell[ CellGroupData[ { #, cell }, { 2 } ] ] &, done, -1 ]

foldExampleGroup[ done_List, cell_ ] :=
  Append[ done, cell ]

inputCellQ[ Cell[ _, "Input", ___ ] ] :=
  True

inputCellQ[ _ ] :=
  False

inputOutputGroupQ[ { Cell[ _, "Input", ___ ], Cell[ _, "Output", ___ ] } ] :=
  True

inputOutputGroupQ[ _ ] :=
  False

(* ---- CellIDs ----
   CreateCellID -> True instructs the FRONT END and does not stamp cells built in
   the kernel; the drift fingerprint keys on CellID, so the generator assigns
   them. Recurses into groups, unlike ReadCellTags.                           *)

AssignCellIDs[ cells_List ] :=
  Block[ { $cellIDCounter = 0 }, assignCellIDs @ cells ]

(* Runs on the notebook MathNotebookDocument returns, which is where the pass
   order above puts it. Measured 2026-08-20: the two orders give an identical
   notebook, so this overload exists to keep the documented order callable --
   without it AssignCellIDs[ MathNotebookDocument[ ... ] ] does not evaluate
   and the build exports the unevaluated expression.                        *)

AssignCellIDs[ Notebook[ cells_List, opts___ ] ] :=
  Notebook[ AssignCellIDs @ cells, opts ]

assignCellIDs[ cells_List ] :=
  Replace[ cells, {
    Cell[ CellGroupData[ group_List, state___ ], opts___ ] :>
      Cell[ CellGroupData[ assignCellIDs @ group, state ], opts ],
    cell_Cell :> withCellID @ cell },
    { 1 } ]

withCellID[ cell : Cell[ content_, rest___ ] ] :=
  If[ ! FreeQ[ { rest }, CellID ],
    cell,
    addCellOption[ cell, CellID -> ++$cellIDCounter ] ]

(* ---- the head ----
   The author is the MODEL and nothing else. The operator and the session's
   intention ride in a Date cell under the date: the notebook has no footnote
   style, and Caption is not one -- it carries a "Figure n." dingbat and
   increments a counter. Date inherits Text, is centred and small, takes neither,
   and every MathNotebook sheet declares it, so it survives a sheet swap.     *)

ResearchHeadCells[ meta_Association ] :=
  { Cell[ "[ LLM Generated ]", "Author" ],
    headCell[ meta, "title", "Title" ],
    headCell[ meta, "model", "Author" ],
    headCell[ meta, "date", "Date" ],
    footnoteCell @ meta }

headCell[ meta_Association, key_String, style_String ] :=
  Replace[ Lookup[ meta, key ], { s_String :> Cell[ s, style ], _ :> Nothing } ]

(* The freedom level is BOLD because it answers the question a reader of a
   machine-written paper asks first: how much of this direction was the machine's.
   One of Directed / Guided / Open exploration, then one sentence summarising the
   instructions actually given. *)
footnoteCell[ meta_Association ] :=
  Replace[ Lookup[ meta, { "operator", "freedom", "prompt" } ],
    { { operator_String, freedom_String, prompt_String } :>
        Cell[ TextData @ { "Operator: " <> operator <> ". ",
          StyleBox[ freedom, FontWeight -> "Bold" ], " \[LongDash] " <> prompt }, "Date" ],
      { operator_String, freedom_String, _ } :>
        Cell[ TextData @ { "Operator: " <> operator <> ". ",
          StyleBox[ freedom, FontWeight -> "Bold" ], "." }, "Date" ],
      { operator_String, __ } :> Cell[ "Operator: " <> operator <> ".", "Date" ],
      _ :> Nothing } ]
