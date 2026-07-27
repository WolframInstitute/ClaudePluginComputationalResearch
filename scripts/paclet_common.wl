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
