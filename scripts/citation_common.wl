(* Shared identifier-to-BibTeX logic for the persistent MCP kernel and CLI.
   Returns a BibTeX String or Failure; never prints or exits.
   An optional importer permits offline checks without network access. *)

citationFromIdentifier[ input_, importer_: Import ] :=
    Module[ { id, arxivPattern, doi, bibKey, arxivBibtex, doiBibtex, fail },
        If[ ! StringQ[ input ],
            Return[ Failure[ "InvalidIdentifier", <| "MessageTemplate" -> "Expected an arXiv ID or DOI string." |> ] ]
        ];
        id = StringTrim[ input ];
        fail[ tag_, message_ ] := Failure[ tag, <| "MessageTemplate" -> message, "Identifier" -> id |> ];
        arxivPattern = RegularExpression[ "(?i)^(arxiv:|https?://arxiv\\.org/(abs|pdf)/)?([a-z\\-]+/[0-9]{7}|[0-9]{4}\\.[0-9]{4,5})(v[0-9]+)?$" ];
        doi = StringReplace[ id, RegularExpression[ "(?i)^(doi:|https?://(dx\\.)?doi\\.org/)" ] -> "" ];
        bibKey[ s_String ] := StringReplace[ s, RegularExpression[ "[^A-Za-z0-9]" ] -> "_" ];

        arxivBibtex[ aid_String ] := Module[ { data, entries, entry, title, authors, year, abstract, key },
            data = Quiet @ Check[ importer[ "https://export.arxiv.org/api/query?id_list=" <> aid, "XML" ], $Failed ];
            If[ FailureQ[ data ] || data === $Failed,
                Return[ fail[ "ArxivFetchFailed", "arXiv fetch failed for " <> aid ] ]
            ];
            entries = Cases[ data, XMLElement[ "entry", _, children_ ] :> children, Infinity ];
            If[ entries === {}, Return[ fail[ "ArxivEntryMissing", "No arXiv entry returned for " <> aid ] ] ];
            entry = First[ entries ];
            title = StringTrim @ First[ Cases[ entry, XMLElement[ "title", _, { t_String } ] :> t, Infinity ], "" ];
            authors = DeleteCases[ Cases[ entry,
                XMLElement[ "author", _, children_ ] :>
                    StringTrim @ First[ Cases[ children, XMLElement[ "name", _, { n_String } ] :> n, Infinity ], "" ],
                Infinity ], "" ];
            year = StringTake[ First[ Cases[ entry, XMLElement[ "published", _, { d_String } ] :> d, Infinity ], "" ], UpTo[ 4 ] ];
            abstract = StringTrim @ First[ Cases[ entry, XMLElement[ "summary", _, { s_String } ] :> s, Infinity ], "" ];
            If[ title === "" || authors === {} || StringLength[ year ] =!= 4,
                Return[ fail[ "ArxivMetadataMissing", "Incomplete arXiv metadata for " <> aid ] ]
            ];
            key = bibKey[ Last @ StringSplit @ First[ authors ] ] <> year;
            StringJoin[
                "@article{", key, ",\n",
                "  author        = {", StringRiffle[ authors, " and " ], "},\n",
                "  title         = {", title, "},\n",
                "  year          = {", year, "},\n",
                "  eprint        = {", aid, "},\n",
                "  archivePrefix = {arXiv},\n",
                "  url           = {https://arxiv.org/abs/", aid, "},\n",
                If[ abstract =!= "", "  abstract      = {" <> StringTake[ abstract, UpTo[ 1000 ] ] <> "},\n", "" ],
                "}"
            ]
        ];

        doiBibtex[ doiValue_String ] := Module[ { bib },
            bib = Quiet @ Check[ importer[ "https://api.crossref.org/works/" <> doiValue <> "/transform/application/x-bibtex", "Text" ], $Failed ];
            If[ ! StringQ[ bib ] || StringLength[ StringTrim[ bib ] ] < 20 || ! StringStartsQ[ StringTrim[ bib ], "@" ],
                fail[ "CrossrefFetchFailed", "Crossref fetch failed for " <> doiValue ],
                StringTrim[ bib ]
            ]
        ];

        Which[
            StringMatchQ[ id, arxivPattern ],
                arxivBibtex[ First @ StringCases[ id,
                    RegularExpression[ "([a-z\\-]+/[0-9]{7}|[0-9]{4}\\.[0-9]{4,5})(v[0-9]+)?" ] -> "$1" ] ],
            StringMatchQ[ doi, RegularExpression[ "10\\.[0-9]+/.+" ] ], doiBibtex[ doi ],
            True, fail[ "InvalidIdentifier", "Could not classify identifier: " <> id ]
        ]
    ];
