#!/usr/bin/env wolframscript

(* cite_from_id.wls — Generate BibTeX/biblatex entry from arXiv ID or DOI
   Usage: wolframscript -f cite_from_id.wls <id>
          where <id> is an arXiv id (e.g. 2301.00001 or arXiv:2301.00001)
          or a DOI (e.g. 10.1088/0951-7715/4/2/002 or https://doi.org/...).
   Output: BibTeX entry to stdout. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f cite_from_id.wls <arxivId | doi>" ];
    Exit[ 1 ]
];

id = $ScriptCommandLine[[ 2 ]];

(* Normalise: strip prefixes and URL wrappers. *)
arxivPattern = RegularExpression[ "(?i)^(arxiv:|https?://arxiv\\.org/(abs|pdf)/)?([a-z\\-]+/[0-9]{7}|[0-9]{4}\\.[0-9]{4,5})(v[0-9]+)?$" ];
doiPrefixed = StringReplace[ id, RegularExpression[ "(?i)^(doi:|https?://(dx\\.)?doi\\.org/)" ] -> "" ];

bibKey[ s_String ] := StringReplace[ s, RegularExpression[ "[^A-Za-z0-9]" ] -> "_" ];

arxivBibtex[ aid_String ] := Module[ { url, data, entry, title, authors, year, abstract, key },
    url = "https://export.arxiv.org/api/query?id_list=" <> aid;
    data = Quiet @ Import[ url, "XML" ];
    If[ FailureQ[ data ] || data === $Failed,
        Return[ "% arXiv fetch failed for " <> aid ]
    ];
    title = Quiet @ StringTrim @ First[ Cases[ data, XMLElement[ "title", _, { t_String } ] :> t, Infinity ][[ 2 ;; 2 ]], "" ];
    authors = Quiet @ Cases[ data,
        XMLElement[ "author", _, { XMLElement[ "name", _, { n_String } ], ___ } ] :> n, Infinity ];
    year = Quiet @ StringTake[
        First[ Cases[ data, XMLElement[ "published", _, { d_String } ] :> d, Infinity ], "" ],
        UpTo[ 4 ]
    ];
    abstract = Quiet @ StringTrim @ First[
        Cases[ data, XMLElement[ "summary", _, { s_String } ] :> s, Infinity ], "" ];
    key = If[ Length[ authors ] > 0,
        bibKey[ Last @ StringSplit @ First[ authors ] ] <> If[ StringLength[ year ] == 4, year, "" ],
        "arxiv_" <> StringReplace[ aid, { "." -> "_", "/" -> "_" } ]
    ];
    StringJoin[
        "@article{", key, ",\n",
        "  author        = {", StringRiffle[ authors, " and " ], "},\n",
        "  title         = {", title, "},\n",
        "  year          = {", year, "},\n",
        "  eprint        = {", aid, "},\n",
        "  archivePrefix = {arXiv},\n",
        "  url           = {https://arxiv.org/abs/", aid, "},\n",
        If[ StringLength[ abstract ] > 0,
            "  abstract      = {" <> StringTake[ abstract, UpTo[ 1000 ] ] <> "},\n",
            ""
        ],
        "}"
    ]
];

doiBibtex[ doi_String ] := Module[ { url, bib },
    url = "https://api.crossref.org/works/" <> doi <> "/transform/application/x-bibtex";
    bib = Quiet @ Import[ url, "Text" ];
    If[ FailureQ[ bib ] || !StringQ[ bib ] || StringLength[ bib ] < 20,
        "% Crossref fetch failed for " <> doi,
        StringTrim[ bib ]
    ]
];

Which[
    StringMatchQ[ id, arxivPattern ],
        Module[ { aid },
            aid = First @ StringCases[ id,
                RegularExpression[ "([a-z\\-]+/[0-9]{7}|[0-9]{4}\\.[0-9]{4,5})(v[0-9]+)?" ] -> "$1" ];
            Print[ arxivBibtex[ aid ] ]
        ],
    StringMatchQ[ doiPrefixed, RegularExpression[ "10\\.[0-9]+/.+" ] ],
        Print[ doiBibtex[ doiPrefixed ] ],
    True,
        Print[ "% Could not classify identifier: " <> id ];
        Exit[ 1 ]
]
