#!/usr/bin/env wolframscript

(* search_wikipedia_math.wls — Search Wikipedia, filtered to math articles
   Usage: wolframscript -f search_wikipedia_math.wls <keywords>
   Output: JSON array of {title, url, snippet}

   Uses the MediaWiki search API. Math filtering is heuristic: prefers titles
   containing math keywords (theorem, lemma, group, ring, field, manifold,
   topology, algebra, geometry, etc.) or articles whose snippet contains
   `\\[`/`\\(` LaTeX delimiters. Caller can still inspect all results. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_wikipedia_math.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = StringRiffle[ $ScriptCommandLine[[ 2 ;; ]], " " ];

response = Quiet @ Import[
    "https://en.wikipedia.org/w/api.php?action=query&list=search&srlimit=20&format=json&srsearch=" <>
        URLEncode[ keywords ],
    "RawJSON"
];

hits = If[ AssociationQ[ response ] && KeyExistsQ[ response, "query" ] &&
           AssociationQ[ response[ "query" ] ] && KeyExistsQ[ response[ "query" ], "search" ],
    response[ "query" ][ "search" ],
    {}
];

mathHints = { "theorem", "lemma", "manifold", "topology", "algebra", "geometry",
    "category", "homology", "cohomology", "group", "ring", "field", "module",
    "scheme", "variety", "polynomial", "matrix", "operator", "functor", "sheaf",
    "spectrum", "metric", "curvature", "differential", "integral", "measure",
    "probability", "stochastic", "graph", "lattice", "set", "logic", "axiom",
    "function", "sequence", "series", "tensor", "vector", "space" };

mathScore[ assoc_Association ] := Module[ { title, snippet, t, s },
    title = Quiet @ assoc[ "title" ];
    snippet = Quiet @ assoc[ "snippet" ];
    t = If[ StringQ[ title ], ToLowerCase[ title ], "" ];
    s = If[ StringQ[ snippet ], ToLowerCase[ snippet ], "" ];
    Total[ Boole[ StringContainsQ[ t, # ] ] & /@ mathHints ] +
        Boole[ StringContainsQ[ s, { "\\[", "\\(", "<math", "displaystyle" } ] ]
];

ranked = If[ ListQ[ hits ],
    ReverseSortBy[ hits, mathScore ],
    {}
];

results = Map[
    Module[ { title, snippet },
        title = Quiet @ #[ "title" ];
        snippet = Quiet @ #[ "snippet" ];
        <|
            "title" -> If[ StringQ[ title ], title, "" ],
            "url" -> If[ StringQ[ title ],
                "https://en.wikipedia.org/wiki/" <> URLEncode[ StringReplace[ title, " " -> "_" ] ],
                ""
            ],
            "snippet" -> If[ StringQ[ snippet ],
                StringTake[ StringReplace[ snippet,
                    RegularExpression[ "<[^>]+>" ] -> "" ], UpTo[ 200 ] ],
                ""
            ]
        |>
    ] &,
    Take[ ranked, UpTo[ 20 ] ]
];

Print[ ExportString[ results, "JSON", "Compact" -> True ] ]
