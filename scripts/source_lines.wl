(* Source line ranges for the cells of a notebook generated from Markdown.

   Each generated cell carries, in its own TaggingRules, the lines of the .md it came from:
     Cell[ ..., TaggingRules -> { "SourceLines" -> { first, last } } ]
   A revision round anchors a note in a cell to those lines (project-provenance skill, Anchors).
   Loaded with Get on the MCP kernel by the generating pipelines and by document-revise/round.md. *)

SourceBlocks[ text_String ] :=
  With[ { lines = StringSplit[ text, "\n", All ] },
    { body = If[ First[ lines ] === "---", 2 + FirstPosition[ Rest[ lines ], "---", { 0 }, { 1 } ][[ 1 ]], 1 ] },
    { close = { state, i } |-> If[ state[ "open" ] === None, state[ "blocks" ], Append[ state[ "blocks" ], { state[ "open" ], i } ] ] },
    { final = Fold[
        { state, i } |-> With[ { line = lines[[ i ]] },
          Which[
            state[ "fence" ] =!= None,
              If[ StringStartsQ[ line, state[ "fence" ] ], <| state, "fence" -> None, "blocks" -> close[ state, i ], "open" -> None |>, state ],
            state[ "comment" ],
              If[ StringContainsQ[ line, "-->" ], <| state, "comment" -> False |>, state ],
            StringTrim[ line ] === "",
              <| state, "blocks" -> close[ state, i - 1 ], "open" -> None |>,
            StringMatchQ[ line, RegularExpression[ "(```|~~~).*" ] ],
              <| state, "blocks" -> close[ state, i - 1 ], "open" -> i, "fence" -> StringTake[ line, 3 ] |>,
            StringMatchQ[ line, RegularExpression[ "#{1,6} .*" ] ],
              <| state, "blocks" -> Append[ close[ state, i - 1 ], { i, i } ], "open" -> None |>,
            StringMatchQ[ line, RegularExpression[ "([-*+]|\\d+[.)]) .*|<!--.*" ] ],
              <| state, "blocks" -> close[ state, i - 1 ], "open" -> i,
                "comment" -> StringStartsQ[ line, "<!--" ] && ! StringContainsQ[ line, "-->" ] |>,
            state[ "open" ] === None,
              <| state, "open" -> i |>,
            True,
              state ] ],
        <| "blocks" -> { }, "open" -> None, "fence" -> None, "comment" -> False |>,
        Range[ body, Length[ lines ] ] ] },
    close[ final, Length[ lines ] ] ]

(* The converter keeps no source positions, so the source is converted twice: once as it is, and once
   with a sentinel paragraph "SOURCELINES first last" before each block. A sentinel is a block boundary,
   so it changes no other cell; the cells between two sentinels came from the block the first one names.
   The ranges are copied onto the plain conversion by position, and only when the two cell lists agree
   style by style -- otherwise the plain notebook comes back unstamped, which FreeQ[ nb, "SourceLines" ] shows. *)
SourceLineNotebook[ convert_, text_String ] :=
  SourceLineNotebook[ convert[ text ], convert[ MarkedSource[ text ] ] ]

SourceLineNotebook[ plain_Notebook, marked_Notebook ] :=
  With[ { sentinel = Cell[ c_, "Text", ___ ] /;
        StringMatchQ[ StringJoin @ Cases[ c, _String, { 0, Infinity } ], RegularExpression[ "\\s*SOURCELINES \\d+ \\d+\\s*" ] ] },
    { ranges = Rest @ FoldList[
        { range, cell } |-> If[ MatchQ[ cell, sentinel ], ToExpression @ Rest @ StringSplit @ StringJoin @ Cases[ First[ cell ], _String, { 0, Infinity } ], range ],
        None, First[ marked ] ] },
    { kept = Pick[ Transpose[ { First[ marked ], ranges } ], ! MatchQ[ #, sentinel ] & /@ First[ marked ] ] },
    If[ kept[[ All, 1, 2 ]] === First[ plain ][[ All, 2 ]],
      ReplacePart[ plain, 1 -> MapThread[ StampSourceLines, { First[ plain ], kept[[ All, 2 ]] } ] ],
      plain ] ]

MarkedSource[ text_String ] :=
  With[ { blocks = AssociationThread[ SourceBlocks[ text ][[ All, 1 ]], SourceBlocks[ text ] ] },
    StringRiffle[
      Flatten @ MapIndexed[
        { line, i } |-> If[ KeyExistsQ[ blocks, First[ i ] ],
          { "", "SOURCELINES " <> StringRiffle[ ToString /@ blocks[ First[ i ] ] ], "", line },
          line ],
        StringSplit[ text, "\n", All ] ],
      "\n" ] ]

StampSourceLines[ Cell[ content_, style_String, opts___ ], range : { _Integer, _Integer } | None ] :=
  If[ range === None,
    Cell[ content, style, opts ],
    Cell[ content, style,
      Sequence @@ FilterRules[ { opts }, Except[ TaggingRules ] ],
      TaggingRules -> Normal @ Append[ Association @ Replace[ TaggingRules /. { opts }, TaggingRules -> { } ], "SourceLines" -> range ] ] ]

CellSourceLines[ Cell[ ___, TaggingRules -> rules_, ___ ] ] :=
  Lookup[ Association @ rules, "SourceLines", None ]

CellSourceLines[ _ ] :=
  None

(* Lines first..last of the .md now take length lines: every range below them moves by the difference.
   Apply one edit at a time from the bottom of the file up, so the line numbers of the edits above stay valid. *)
ShiftSourceLines[ expr_, { first_Integer, last_Integer }, length_Integer ] :=
  expr /. ( "SourceLines" -> { a_Integer, b_Integer } ) /; a > last :> "SourceLines" -> { a, b } + length - ( last - first + 1 )
