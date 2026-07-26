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

ConvertCitations[ cells_List, tags_List ] :=
  Replace[ cells,
    Cell[ TextData[ content_ ], style_String, opts___ ] :>
      Cell[ TextData @ Flatten[ citationSplit[ #, tags ] & /@ Flatten @ { content } ], style, opts ],
    { 1 } ]

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

citationSplit[ text_String, tags_List ] :=
  StringSplit[ text, "[" ~~ tag : ( Alternatives @@ tags ) ~~ "]" :> citationButton @ tag ]

citationSplit[ content_, tags_List ] :=
  content

citationButton[ tag_String ] :=
  ButtonBox[ referenceLabel @ tag, BaseStyle -> "Citation", ButtonData -> tag ]

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
    True, "" ]
