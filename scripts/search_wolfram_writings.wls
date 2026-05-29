#!/usr/bin/env wolframscript

(* search_wolfram_writings.wls — Search Stephen Wolfram's writings
   Usage: wolframscript -f search_wolfram_writings.wls <keywords>
   Output: JSON array of {title, url, date} *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_wolfram_writings.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = StringRiffle[ $ScriptCommandLine[[ 2 ;; ]], " " ];
url = "https://writings.stephenwolfram.com/?s=" <> URLEncode[ keywords ];

links = Quiet @ Import[ url, "Hyperlinks" ];
If[ !ListQ[ links ], WriteString[ $Messages, "search_wolfram_writings: fetch failed (network or site markup change)\n" ]; Print[ "[]" ]; Exit[ 0 ] ];

postLinks = Union @ Select[ links,
    StringMatchQ[ #, "https://writings.stephenwolfram.com/20" ~~ __ ] &&
    !StringContainsQ[ #, {"#", "?", "/tag/", "/category/"} ] &
];

results = Map[
    Module[ { parts, year, month, slug, title },
        parts = StringSplit[ StringTrim[ #, "/" ], "/" ];
        year = If[ Length[ parts ] >= 4, parts[[ 4 ]], "" ];
        month = If[ Length[ parts ] >= 5, parts[[ 5 ]], "" ];
        slug = If[ Length[ parts ] >= 6, parts[[ 6 ]], "" ];
        title = StringReplace[ slug, "-" -> " " ];
        <|
            "title" -> title,
            "url" -> #,
            "date" -> year <> "-" <> month
        |>
    ] &,
    Take[ postLinks, UpTo[ 15 ] ]
];

Print[ ExportString[ results, "JSON", "Compact" -> True ] ]
