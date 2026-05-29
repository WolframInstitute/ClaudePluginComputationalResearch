#!/usr/bin/env wolframscript

(* search_mathworld.wls — Search Wolfram MathWorld
   Usage: wolframscript -f search_mathworld.wls <keywords>
   Output: JSON array of {name, url, snippet}

   Scrapes mathworld.wolfram.com search results. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_mathworld.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = StringRiffle[ $ScriptCommandLine[[ 2 ;; ]], " " ];

links = Quiet @ Import[
    "https://mathworld.wolfram.com/search/?query=" <> URLEncode[ keywords ],
    "Hyperlinks"
];
If[ !ListQ[ links ], WriteString[ $Messages, "search_mathworld: fetch failed (network or site markup change)\n" ] ];

entryLinks = If[ ListQ[ links ],
    Union @ Select[ links,
        StringMatchQ[ #, RegularExpression[ ".*mathworld\\.wolfram\\.com/[A-Za-z][A-Za-z0-9]*\\.html" ] ] &&
        !StringContainsQ[ #, { "search", "topic", "letters", "alphabetical" } ] &
    ],
    {}
];

results = Map[
    Module[ { name, slug },
        slug = Last @ StringSplit[ StringReplace[ #, ".html" -> "" ], "/" ];
        name = StringTrim @ StringJoin @ Riffle[
            StringSplit[ slug, RegularExpression[ "(?=[A-Z])" ] ],
            " "
        ];
        <|
            "name" -> name,
            "url" -> #,
            "snippet" -> ""
        |>
    ] &,
    Take[ entryLinks, UpTo[ 20 ] ]
];

Print[ ExportString[ results, "JSON", "Compact" -> True ] ]
