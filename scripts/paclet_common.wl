(* paclet_common.wl — shared build/install logic for build_paclet.wls and
   publish_paclet.wls. Get[] from a sibling script via
   DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ]. *)

buildAndInstallPaclet[ pacletArg_String, withDocs_ ] :=
    Module[ { found, pacletDir, pacletName, tmpDir, docDir, pacletFile, paclet },
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

        CopyFile[ FileNameJoin[ { pacletDir, "PacletInfo.wl" } ], FileNameJoin[ { tmpDir, "PacletInfo.wl" } ] ];
        CopyDirectory[ FileNameJoin[ { pacletDir, "Kernel" } ], FileNameJoin[ { tmpDir, "Kernel" } ] ];
        docDir = FileNameJoin[ { pacletDir, "Documentation" } ];
        Which[
            withDocs && DirectoryQ[ docDir ],
                CopyDirectory[ docDir, FileNameJoin[ { tmpDir, "Documentation" } ] ];
                Print[ "  Included Documentation/" ],
            DirectoryQ[ docDir ],
                Print[ "  Skipped Documentation/ (pass --with-docs to include)" ]
        ];
        If[ DirectoryQ[ FileNameJoin[ { pacletDir, "Tests" } ] ],
            CopyDirectory[ FileNameJoin[ { pacletDir, "Tests" } ], FileNameJoin[ { tmpDir, "Tests" } ] ] ];

        Print[ "Building paclet archive..." ];
        pacletFile = CreatePacletArchive[ tmpDir ];
        Print[ "  Created: ", pacletFile ];

        DeleteDirectory[ tmpDir, DeleteContents -> True ];

        Print[ "Installing locally..." ];
        paclet = PacletInstall[ pacletFile, ForceVersionInstall -> True ];
        Print[ "  Installed: ", paclet[ "Name" ], " v", paclet[ "Version" ] ];

        <| "PacletFile" -> pacletFile, "Paclet" -> paclet, "PacletName" -> pacletName, "PacletDir" -> pacletDir |>
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
