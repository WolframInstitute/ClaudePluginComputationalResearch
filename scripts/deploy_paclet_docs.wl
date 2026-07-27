(* deploy_paclet_docs.wl — deploy a paclet's Documentation/ pages to the Wolfram
   Cloud as public notebooks with an HTML index, so a reader who has not installed
   the paclet can still read its reference pages.

   Get[] this through the Wolfram MCP kernel (no extra license seat) and call

       deployPacletDocs[ "<pacletDir>", "<cloudDir>" ]

   <pacletDir> contains PacletInfo.wl; <cloudDir> is a path under the connected
   cloud account, e.g. "MathNotebook/Documentation". Returns an association with
   "IndexURL", "Pages", and "Failed". *)

deployPacletDocs[ pacletDir_String, cloudDir_String ] :=
    Module[ { info, publisher, name, version, refs, guides, urls, deployed, index },
        info = PacletObject[ File @ FileNameJoin[ { pacletDir, "PacletInfo.wl" } ] ];
        publisher = Replace[ info[ "PublisherID" ], Except[ _String ] :> "" ];
        name = Last @ StringSplit[ info[ "Name" ], "/" ];
        version = info[ "Version" ];

        refs = FileNames[ "*.nb", FileNameJoin[ { pacletDir, "Documentation", "English", "ReferencePages", "Symbols" } ] ];
        guides = FileNames[ "*.nb", FileNameJoin[ { pacletDir, "Documentation", "English", "Guides" } ] ];
        If[ refs === {} && guides === {},
            Return @ Failure[ "NoDocumentation", <| "MessageTemplate" -> "No documentation pages under `1`", "MessageParameters" -> { pacletDir } |> ]
        ];

        urls = Association @ Join[
            ( FileBaseName[ # ] -> docPageURL[ cloudDir, "ref", FileBaseName @ # ] ) & /@ refs,
            ( FileBaseName[ # ] -> docPageURL[ cloudDir, "guide", FileBaseName @ # ] ) & /@ guides
        ];

        deployed = Association @ Join[
            deployDocPage[ #, cloudDir, "ref", publisher, name, urls ] & /@ refs,
            deployDocPage[ #, cloudDir, "guide", publisher, name, urls ] & /@ guides
        ];

        index = CloudExport[
            docIndexHTML[ info, name, version, FileBaseName /@ refs, FileBaseName /@ guides, urls ],
            { "String", "text/html" },
            CloudObject[ FileNameJoin[ { cloudDir, "index.html" } ] ],
            Permissions -> "Public"
        ];

        <|
            "IndexURL" -> Replace[ index, { c_CloudObject :> First[ c ], other_ :> other } ],
            "Pages" -> Select[ deployed, StringQ ],
            "Failed" -> Keys @ Select[ deployed, ! StringQ[ # ] & ]
        |>
    ];

docPageURL[ cloudDir_, type_, pageName_ ] :=
    First @ CloudObject @ FileNameJoin[ { cloudDir, type, pageName <> ".nb" } ];

deployDocPage[ pageFile_, cloudDir_, type_, publisher_, name_, urls_ ] :=
    Module[ { pageName = FileBaseName @ pageFile, result },
        result = CloudDeploy[
            rewriteDocLinks[ Import @ pageFile, publisher, name, urls ],
            CloudObject @ FileNameJoin[ { cloudDir, type, pageName <> ".nb" } ],
            Permissions -> "Public"
        ];
        pageName -> Replace[ result, { c_CloudObject :> First[ c ], other_ :> other } ]
    ];

(* Generated pages carry paclet: links in two forms — TemplateBox[ { label,
   "paclet:<Pub>/<Paclet>/ref/<Sym>", <web url> }, "TextRefLink" ] in prose, and
   ButtonBox[ label, BaseStyle -> "Link", ButtonData -> "paclet:…" ] in Usage and
   See Also. Both need rewriting: outside a Documentation Center a paclet: URI
   resolves to nothing, and the web url the generator writes for the paclet's own
   symbols is reference.wolfram.com/language/<Pub>/<Paclet>/ref/<Sym>.html, which
   exists only for paclets shipped with the Wolfram Language. Links to built-in
   symbols do have a real reference.wolfram.com page. *)
rewriteDocLinks[ nb_, publisher_, name_, urls_ ] :=
    With[ { prefix = "paclet:" <> If[ publisher === "", "", publisher <> "/" ] <> name <> "/" },
        nb /. {
            TemplateBox[ { label_, uri_String, rest___ }, style_, opts___ ] /; StringStartsQ[ uri, "paclet:" ] :>
                With[ { url = docLinkURL[ uri, prefix, urls ] },
                    If[ StringQ @ url,
                        TemplateBox[ { label, { URL @ url, None }, url }, style, opts ],
                        TemplateBox[ { label, uri, rest }, style, opts ]
                    ]
                ],
            HoldPattern[ ButtonData -> uri_String ] /; StringStartsQ[ uri, "paclet:" ] :>
                With[ { url = docLinkURL[ uri, prefix, urls ] },
                    ButtonData -> If[ StringQ @ url, { URL @ url, None }, uri ]
                ]
        }
    ];

docLinkURL[ uri_, prefix_, urls_ ] :=
    Which[
        StringStartsQ[ uri, prefix ],
            Lookup[ urls, Last @ StringSplit[ uri, "/" ], Missing[ "PageNotDeployed", uri ] ],
        StringMatchQ[ uri, "paclet:" ~~ ( "ref" | "guide" | "tutorial" ) ~~ "/" ~~ __ ],
            "https://reference.wolfram.com/language/" <> StringDrop[ uri, StringLength @ "paclet:" ] <> ".html",
        True,
            Missing[ "UnknownScheme", uri ]
    ];

docIndexHTML[ info_, name_, version_, refs_, guides_, urls_ ] :=
    Module[ { esc, link, description, pacletURL },
        esc = { s } |-> StringReplace[ ToString @ s, { "&" -> "&amp;", "<" -> "&lt;", ">" -> "&gt;", "\"" -> "&quot;" } ];
        link = { page } |-> "<li><a href=\"" <> esc @ urls[ page ] <> "\"><code>" <> esc @ page <> "</code></a></li>";
        description = Replace[ info[ "Description" ], Except[ _String ] :> "" ];
        pacletURL = Replace[ info[ "URL" ], Except[ _String ] :> "" ];
        StringJoin[
            "<!doctype html><html><head><meta charset=\"utf-8\">",
            "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">",
            "<title>", esc @ name, " reference</title><style>",
            "body{font-family:system-ui,-apple-system,\"Segoe UI\",sans-serif;line-height:1.55;",
            "max-width:46rem;margin:3rem auto;padding:0 1.25rem;color:#1c1c1e}",
            "a{color:#0b4aa6}code{font-family:ui-monospace,Menlo,monospace}",
            "h1{font-size:1.6rem;margin-bottom:.25rem}h2{font-size:1.05rem;margin-top:2rem}",
            "p.meta{color:#6b6b70;margin-top:0}ul{columns:2;column-gap:2rem;padding-left:1.2rem}",
            "pre{background:#f5f5f7;padding:.75rem 1rem;overflow-x:auto;border-radius:6px}",
            "@media(prefers-color-scheme:dark){body{background:#1c1c1e;color:#ececf0}",
            "a{color:#7fb2ff}pre{background:#2c2c2e}p.meta{color:#9a9aa0}}",
            "</style></head><body>",
            "<h1>", esc @ name, "</h1>",
            "<p class=\"meta\">Version ", esc @ version,
            If[ description === "", "", " &middot; " <> esc @ description ], "</p>",
            If[ pacletURL === "", "", "<p><a href=\"" <> esc @ pacletURL <> "\">Repository</a></p>" ],
            If[ guides === {}, "",
                "<h2>Guides</h2><ul>" <> StringJoin[ link /@ Sort @ guides ] <> "</ul>" ],
            "<h2>Reference pages</h2><ul>", StringJoin[ link /@ Sort @ refs ], "</ul>",
            "<h2>In-product documentation</h2>",
            "<p>Install the paclet and the same pages are searchable in the Documentation Center:</p>",
            "<pre>PacletInstall[ \"", esc @ name, "\" ]</pre>",
            "</body></html>"
        ]
    ];
