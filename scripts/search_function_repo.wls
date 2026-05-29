#!/usr/bin/env wolframscript

(* search_function_repo.wls — Search Wolfram Function Repository
   Usage: wolframscript -f search_function_repo.wls <keywords>
   Output: JSON array of {name, url, description}

   Uses ResourceSearch for reliable results. Falls back to web scraping. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_function_repo.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = StringRiffle[ $ScriptCommandLine[[ 2 ;; ]], " " ];

resourceResults = Normal @ Quiet @ ResourceSearch[ keywords ];
functionResults = If[ ListQ[ resourceResults ],
    Select[ resourceResults,
        ToString @ Quiet[ #[ "ResourceType" ] ] === "Function" & ],
    {}
];
results = If[ ListQ[ functionResults ] && Length[ functionResults ] > 0,
    Map[
        Module[ { name, desc },
            name = Quiet @ #[ "Name" ];
            desc = Quiet @ #[ "Description" ];
            <|
                "name" -> If[ StringQ[ name ], name, ToString[ # ] ],
                "url" -> "https://resources.wolframcloud.com/FunctionRepository/resources/" <>
                    URLEncode[ If[ StringQ[ name ], name, "" ] ],
                "description" -> If[ StringQ[ desc ], StringTake[ desc, UpTo[ 200 ] ], "" ]
            |>
        ] &,
        Take[ functionResults, UpTo[ 20 ] ]
    ],
    {}
];

If[ Length[ results ] == 0,
    links = Quiet @ Import[
        "https://resources.wolframcloud.com/FunctionRepository/search/?search=" <> URLEncode[ keywords ],
        "Hyperlinks"
    ];
    If[ !ListQ[ links ], WriteString[ $Messages, "search_function_repo: fallback fetch failed (network or site markup change)\n" ] ];
    If[ ListQ[ links ],
        functionLinks = Union @ Select[ links,
            StringContainsQ[ #, "/FunctionRepository/resources/" ] &&
            !StringContainsQ[ #, {"search", "category", "#", "?"} ] &
        ];
        results = Map[
            Module[ { name },
                name = Last @ StringSplit[ StringTrim[ #, "/" ], "/" ];
                <|
                    "name" -> URLDecode[ name ],
                    "url" -> If[ StringStartsQ[ #, "http" ], #,
                        "https://resources.wolframcloud.com" <> # ],
                    "description" -> ""
                |>
            ] &,
            Take[ functionLinks, UpTo[ 20 ] ]
        ];
    ];
];

Print[ ExportString[ results, "JSON", "Compact" -> True ] ]
