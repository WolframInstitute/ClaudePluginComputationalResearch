$MathNotebookEnvironmentStyles = {
  "Theorem", "Lemma", "Proposition", "Corollary", "Conjecture", "Claim",
  "Definition", "Example", "Construction",
  "Remark", "Question", "Observation"
};

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
      "@" ~~ Except[ "{" ] .. ~~ "{" ~~ body : Shortest[ __ ] ~~ "\n}" :> body ] ]

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
  SelectFirst[ $MathNotebookEnvironmentStyles,
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

bibFields[ body_String ] :=
  Association @ StringCases[ body, {
    key : WordCharacter .. ~~ Whitespace ... ~~ "=" ~~ Whitespace ... ~~
      "{" ~~ value : Shortest[ ___ ] ~~ "}" :> bibField[ key, value ],
    key : WordCharacter .. ~~ Whitespace ... ~~ "=" ~~ Whitespace ... ~~
      "\"" ~~ value : Shortest[ ___ ] ~~ "\"" :> bibField[ key, value ],
    key : WordCharacter .. ~~ Whitespace ... ~~ "=" ~~ Whitespace ... ~~
      value : DigitCharacter .. :> bibField[ key, value ] } ]

bibField[ key_String, value_String ] :=
  ToLowerCase @ key -> StringTrim @ StringReplace[ value, Whitespace -> " " ]

formatReference[ fields_Association ] :=
  StringRiffle[ Lookup[ fields, { "author", "title", "journal", "year" }, Nothing ], ", " ] <>
    referenceLink @ fields

referenceLink[ fields_Association ] :=
  Which[
    KeyExistsQ[ fields, "doi" ], ", https://doi.org/" <> fields[ "doi" ],
    KeyExistsQ[ fields, "eprint" ], ", https://arxiv.org/abs/" <> fields[ "eprint" ],
    KeyExistsQ[ fields, "url" ], ", " <> fields[ "url" ],
    True, "" ]
