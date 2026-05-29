#!/usr/bin/env wolframscript

(* search_wolfram_docs.wls — Search Wolfram Language documentation
   Usage: wolframscript -f search_wolfram_docs.wls <keywords>
   Output: JSON array of {name, url, usage}

   Searches built-in symbol names (all keywords must match),
   then searches guide/tutorial pages via web. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_wolfram_docs.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = $ScriptCommandLine[[ 2 ;; ]];

allNames = Names[ "System`*" ];
matching = Select[ allNames,
    ( name |-> AllTrue[ keywords, StringContainsQ[ name, #, IgnoreCase -> True ] & ] )
];

results = Map[
    <|
        "name" -> #,
        "url" -> "https://reference.wolfram.com/language/ref/" <> # <> ".html",
        "type" -> "symbol"
    |> &,
    Take[ matching, UpTo[ 30 ] ]
];

guideLinks = Quiet @ Import[
    "https://reference.wolfram.com/language/search/?query=" <> URLEncode[ StringRiffle[ keywords, " " ] ],
    "Hyperlinks"
];
If[ !ListQ[ guideLinks ], WriteString[ $Messages, "search_wolfram_docs: guide/tutorial fetch failed (network or site markup change)\n" ] ];
guides = If[ ListQ[ guideLinks ],
    Union @ Select[ guideLinks,
        StringContainsQ[ #, {"/guide/", "/tutorial/"} ] &&
        !StringContainsQ[ #, {"#", "?"} ] &
    ] // ( Take[ #, UpTo[ 10 ] ] & ),
    {}
];

guideResults = Map[
    Module[ { parts, name },
        parts = StringSplit[ StringTrim[ #, "/" ], "/" ];
        name = If[ Length[ parts ] > 0, Last[ parts ], # ];
        <|
            "name" -> StringReplace[ name, {"_" -> " ", "%" -> " "} ],
            "url" -> If[ StringStartsQ[ #, "http" ], #,
                "https://reference.wolfram.com" <> # ],
            "type" -> If[ StringContainsQ[ #, "/guide/" ], "guide", "tutorial" ]
        |>
    ] &,
    guides
];

Print[ ExportString[ Join[ results, guideResults ], "JSON", "Compact" -> True ] ]
