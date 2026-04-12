#!/usr/bin/env wolframscript

(* search_wolfram_physics.wls — Search wolframphysics.org resources
   Usage: wolframscript -f search_wolfram_physics.wls <keywords>
   Output: JSON object with results from each sub-resource

   Searches: glossary, archives/bulletins, technical documents, tools,
   Q&A, and universe registry. Filters by keyword relevance. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_wolfram_physics.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = $ScriptCommandLine[[ 2 ;; ]];
keywordPattern = Alternatives @@ keywords;

baseUrl = "https://www.wolframphysics.org";

(* Helper: fetch links and filter by keywords *)
fetchAndFilter[ url_String, linkPattern_String ] :=
    Module[ { links },
        links = Quiet @ Import[ url, "Hyperlinks" ];
        If[ !ListQ[ links ], Return[ {} ] ];
        links = Union @ Select[ links, StringContainsQ[ #, linkPattern ] & ];
        Select[ links,
            StringContainsQ[ #, keywordPattern, IgnoreCase -> True ] & ]
    ]

(* 1. Glossary — terms and definitions *)
glossaryLinks = Quiet @ Import[ baseUrl <> "/glossary/", "Hyperlinks" ];
glossaryTerms = If[ ListQ[ glossaryLinks ],
    Module[ { termLinks },
        termLinks = Select[ glossaryLinks,
            StringContainsQ[ #, "/glossary/" ] &&
            # =!= baseUrl <> "/glossary/" &&
            !StringContainsQ[ #, {"#", "?"} ] &
        ] // Union;
        Map[
            Module[ { slug },
                slug = Last @ StringSplit[ StringTrim[ #, "/" ], "/" ];
                <| "term" -> StringReplace[ slug, "-" -> " " ],
                   "url" -> If[ StringStartsQ[ #, "http" ], #, baseUrl <> # ] |>
            ] &,
            termLinks
        ]
    ],
    {}
];
(* Filter glossary by keywords *)
glossaryTerms = Select[ glossaryTerms,
    StringContainsQ[ #[ "term" ], keywordPattern, IgnoreCase -> True ] & ];

(* 2. Archives — bulletins and working materials *)
archiveLinks = Quiet @ Import[ baseUrl <> "/archives/index/", "Hyperlinks" ];
archives = If[ ListQ[ archiveLinks ],
    Module[ { bulletinLinks },
        bulletinLinks = Select[ archiveLinks,
            StringContainsQ[ #, {"/bulletins/", "/archives/"} ] &&
            !StringContainsQ[ #, {"#", "index"} ] &&
            # =!= baseUrl <> "/archives/index/" &
        ] // Union;
        Map[
            Module[ { slug },
                slug = Last @ StringSplit[ StringTrim[ #, "/" ], "/" ];
                <| "title" -> StringReplace[ slug, "-" -> " " ],
                   "url" -> If[ StringStartsQ[ #, "http" ], #, baseUrl <> # ] |>
            ] &,
            bulletinLinks
        ]
    ],
    {}
];

(* 3. Technical documents *)
techLinks = Quiet @ Import[ baseUrl <> "/technical-documents/", "Hyperlinks" ];
techDocs = If[ ListQ[ techLinks ],
    Module[ { docLinks },
        docLinks = Select[ techLinks,
            (StringContainsQ[ #, ".pdf" ] || StringContainsQ[ #, "/technical-" ]) &&
            !StringContainsQ[ #, {"#", "?"} ] &
        ] // Union;
        Map[
            Module[ { slug },
                slug = Last @ StringSplit[ StringTrim[ #, "/" ], "/" ];
                <| "title" -> StringReplace[ StringReplace[ slug, ".pdf" -> "" ], "-" -> " " ],
                   "url" -> If[ StringStartsQ[ #, "http" ], #, baseUrl <> # ] |>
            ] &,
            docLinks
        ]
    ],
    {}
];

(* 4. Tools page — list available software *)
toolLinks = Quiet @ Import[ baseUrl <> "/tools/", "Hyperlinks" ];
tools = If[ ListQ[ toolLinks ],
    Module[ { toolPageLinks },
        toolPageLinks = Select[ toolLinks,
            StringContainsQ[ #, "/tools/" ] &&
            # =!= baseUrl <> "/tools/" &&
            !StringContainsQ[ #, {"#", "?"} ] &
        ] // Union;
        Map[
            Module[ { slug },
                slug = Last @ StringSplit[ StringTrim[ #, "/" ], "/" ];
                <| "name" -> StringReplace[ slug, "-" -> " " ],
                   "url" -> If[ StringStartsQ[ #, "http" ], #, baseUrl <> # ] |>
            ] &,
            toolPageLinks
        ]
    ],
    {}
];

result = <|
    "glossary" -> Take[ glossaryTerms, UpTo[ 20 ] ],
    "archives" -> Take[ archives, UpTo[ 20 ] ],
    "technical_documents" -> Take[ techDocs, UpTo[ 20 ] ],
    "tools" -> Take[ tools, UpTo[ 10 ] ],
    "urls" -> <|
        "glossary" -> baseUrl <> "/glossary/",
        "archives" -> baseUrl <> "/archives/index/",
        "technical_documents" -> baseUrl <> "/technical-documents/",
        "tools" -> baseUrl <> "/tools/",
        "questions" -> baseUrl <> "/questions/",
        "universes" -> baseUrl <> "/universes/",
        "visual_gallery" -> baseUrl <> "/visual-gallery/",
        "technical_introduction" -> baseUrl <> "/technical-introduction/"
    |>
|>;

Print[ ExportString[ result, "JSON", "Compact" -> True ] ]
