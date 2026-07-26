$MathNotebookEnvironmentStyles = {
  "Theorem", "Lemma", "Proposition", "Corollary", "Conjecture", "Claim",
  "Definition", "Example", "Construction",
  "Remark", "Question", "Observation"
};

$MathNotebookStyleSheetName = "AMSArticle.nb";

MathNotebookDocument[ cells_List, opts : OptionsPattern[ Notebook ] ] :=
  Notebook[ NumberTaggedFormulas @ ConvertEnvironmentCells @ cells, opts,
    StyleDefinitions -> MathNotebookStyleSheet[ ] ]

NumberTaggedFormulas[ cells_List ] :=
  Replace[ cells,
    Cell[ content_, "DisplayFormula", opts___ ] /; ! FreeQ[ { opts }, CellTags ] :>
      Cell[ content, "DisplayFormulaNumbered", opts ],
    { 1 } ]

ConvertEnvironmentCells[ Notebook[ cells_List, opts___ ] ] :=
  Notebook[ ConvertEnvironmentCells @ cells, opts ]

ConvertEnvironmentCells[ cells_List ] :=
  convertEnvironmentCell /@ cells

MathNotebookStyleSheet[ ] :=
  Get @ FileNameJoin @ {
    PacletObject[ "WolframInstitute/MathNotebook" ][ "Location" ],
    "FrontEnd", "StyleSheets", "MathNotebook", $MathNotebookStyleSheetName }

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
