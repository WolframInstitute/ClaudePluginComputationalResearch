(* paclet_common.wl — shared build/install logic for build_paclet.wls and
   publish_paclet.wls. Get[] from a sibling script via
   DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ]. *)

buildAndInstallPaclet[ pacletArg_String, withDocs_ ] :=
    Module[ { found, pacletDir, pacletName, tmpDir, staged, pacletFile, paclet },
        found = findPacletDir[ pacletArg ];
        If[ found === None,
            Print[ "Error: cannot find PacletInfo.wl for ", pacletArg ];
            Exit[ 1 ]
        ];
        pacletDir = DirectoryName[ found ];
        pacletName = FileBaseName[ pacletDir ];
        Print[ "Paclet directory: ", pacletDir ];

        tmpDir = FileNameJoin[ { $TemporaryDirectory, pacletName <> "-build" } ];
        If[ DirectoryQ[ tmpDir ], DeleteDirectory[ tmpDir, DeleteContents -> True ] ];
        CreateDirectory[ tmpDir ];

        staged = stagePacletFiles[ pacletDir, tmpDir, withDocs ];
        Print[ "  Staged: ", StringRiffle[ staged, ", " ] ];
        If[ ! withDocs && DirectoryQ[ FileNameJoin[ { pacletDir, "Documentation" } ] ],
            Print[ "  Skipped Documentation/ (pass --with-docs to include)" ] ];

        Print[ "Building paclet archive..." ];
        pacletFile = CreatePacletArchive[ tmpDir ];
        Print[ "  Created: ", pacletFile ];

        DeleteDirectory[ tmpDir, DeleteContents -> True ];

        Print[ "Installing locally..." ];
        paclet = PacletInstall[ pacletFile, ForceVersionInstall -> True ];
        Print[ "  Installed: ", paclet[ "Name" ], " v", paclet[ "Version" ] ];

        <| "PacletFile" -> pacletFile, "Paclet" -> paclet, "PacletName" -> pacletName, "PacletDir" -> pacletDir |>
    ];

(* Stage every top-level item of the paclet, not a fixed list: a paclet may ship
   FrontEnd/ (palettes, stylesheets), Assets/, Documentation/ or anything else its
   PacletInfo declares, and a fixed {Kernel, Tests} copy silently ships a paclet
   with those missing. Dotfiles and build/ are repo artifacts, not paclet content. *)
stagePacletFiles[ pacletDir_, tmpDir_, withDocs_ ] :=
    Module[ { items },
        items = Select[ FileNameTake /@ FileNames[ "*", pacletDir ],
            ! StringStartsQ[ #, "." ] && ! MemberQ[ { "build" }, # ] &
        ];
        If[ ! withDocs, items = DeleteCases[ items, "Documentation" ] ];
        Scan[
            { item } |-> With[ { src = FileNameJoin[ { pacletDir, item } ], dest = FileNameJoin[ { tmpDir, item } ] },
                If[ DirectoryQ[ src ], CopyDirectory[ src, dest ], CopyFile[ src, dest ] ]
            ],
            items
        ];
        Scan[ DeleteFile, FileNames[ ".DS_Store", tmpDir, Infinity ] ];
        Sort[ items ]
    ];

findPacletDir[ name_String ] :=
    Module[ { candidates, scriptRoot, cwd },
        scriptRoot = ParentDirectory[ DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ] ];
        cwd = Directory[];
        candidates = {
            FileNameJoin[ { name, "PacletInfo.wl" } ],
            FileNameJoin[ { cwd, name, name, "PacletInfo.wl" } ],
            FileNameJoin[ { cwd, name, "PacletInfo.wl" } ],
            FileNameJoin[ { scriptRoot, name, name, "PacletInfo.wl" } ],
            FileNameJoin[ { scriptRoot, name, "PacletInfo.wl" } ]
        };
        SelectFirst[ candidates, FileExistsQ ] /. _Missing :> None
    ];

(* Check metadata URIs against the installed paclet before publication. *)
validateDocumentationFiles[ pages_List, installedRoot_String, reader_, resolver_ ] :=
    Module[ { rootParts = FileNameSplit @ ExpandFileName[ installedRoot ], failures },
        failures = DeleteCases[
            Map[ Function[ page,
                Module[ { nb, tags, metadata, uri, resolved, parts },
                    nb = Quiet @ Check[ reader[ page, "NB" ], $Failed ];
                    If[ ! MatchQ[ nb, _Notebook ], Return[ Failure[ "UnreadableDocPage", <| "Page" -> page |> ] ] ];
                    tags = Quiet @ Check[ Association[ TaggingRules /. Options[ nb, TaggingRules ] ], <||> ];
                    metadata = Quiet @ Check[ Association[ Lookup[ tags, "Metadata", <||> ] ], <||> ];
                    uri = Lookup[ metadata, "uri", Lookup[ metadata, "URI", Missing[ "NoURI" ] ] ];
                    If[ ! StringQ[ uri ] || StringLength[ uri ] == 0,
                        Return[ Failure[ "MissingDocumentationURI", <| "Page" -> page |> ] ] ];
                    If[ ! StringStartsQ[ uri, "paclet:" ], uri = "paclet:" <> uri ];
                    resolved = Quiet @ Check[ resolver[ uri ], $Failed ];
                    If[ ! StringQ[ resolved ] || ! FileExistsQ[ resolved ] || DirectoryQ[ resolved ],
                        Return[ Failure[ "UnresolvedDocumentationURI", <| "Page" -> page, "URI" -> uri |> ] ] ];
                    parts = FileNameSplit @ ExpandFileName[ resolved ];
                    If[ Length[ parts ] <= Length[ rootParts ] || Take[ parts, Length[ rootParts ] ] =!= rootParts,
                        Return[ Failure[ "DocumentationOutsideInstalledPaclet", <| "Page" -> page, "Resolved" -> resolved |> ] ] ];
                    True
                ]
            ], pages ], True
        ];
        If[ failures === { }, True, Failure[ "DocumentationResolutionFailed", <| "Failures" -> failures |> ] ]
    ];

verifyInstalledDocumentation[ result_Association ] :=
    Module[ { docs, pages, installedRoot, refreshed },
        docs = FileNameJoin[ { result[ "PacletDir" ], "Documentation" } ];
        If[ ! DirectoryQ[ docs ], Return[ True ] ];
        pages = Select[ FileNames[ "*.nb", docs, Infinity ],
            MemberQ[ Partition[ FileNameSplit[ # ], 2, 1 ], { "ReferencePages", "Symbols" } ] & ];
        If[ pages === { }, Return[ True ] ];
        installedRoot = Quiet @ Check[ result[ "Paclet" ][ "Location" ], $Failed ];
        If[ ! StringQ[ installedRoot ] || ! DirectoryQ[ installedRoot ],
            Return[ Failure[ "InstalledPacletLocationUnavailable", <||> ] ] ];
        refreshed = Quiet @ Check[ PacletDataRebuild[ ], $Failed ];
        If[ refreshed === $Failed, Return[ Failure[ "DocumentationIndexRebuildFailed", <||> ] ] ];
        validateDocumentationFiles[ pages, installedRoot, Import, Documentation`ResolveLink ]
    ];
