#!/usr/bin/env wolframscript

(* search_nlab.wls — Search the nLab category-theory wiki
   Usage: wolframscript -f search_nlab.wls <keywords>
   Output: JSON array of {name, url, snippet}

   Scrapes ncatlab.org/nlab/search?query=... results. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_nlab.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = StringRiffle[ $ScriptCommandLine[[ 2 ;; ]], " " ];

links = Quiet @ Import[
    "https://ncatlab.org/nlab/search?query=" <> URLEncode[ keywords ],
    "Hyperlinks"
];

pageLinks = If[ ListQ[ links ],
    Union @ Select[ links,
        StringContainsQ[ #, "ncatlab.org/nlab/show/" ] &&
        !StringContainsQ[ #, { "#", "?", "search", "all_pages", "history" } ] &&
        !StringMatchQ[ #, RegularExpression[ ".*/(20[0-9]{2}|19[0-9]{2}).*changes.*" ] ] &
    ],
    {}
];

results = Map[
    Module[ { slug, name },
        slug = Last @ StringSplit[ StringTrim[ #, "/" ], "/" ];
        name = StringReplace[ URLDecode[ slug ], { "+" -> " ", "_" -> " " } ];
        <|
            "name" -> name,
            "url" -> If[ StringStartsQ[ #, "http" ], #, "https://ncatlab.org" <> # ],
            "snippet" -> ""
        |>
    ] &,
    Take[ pageLinks, UpTo[ 20 ] ]
];

Print[ ExportString[ results, "JSON", "Compact" -> True ] ]
