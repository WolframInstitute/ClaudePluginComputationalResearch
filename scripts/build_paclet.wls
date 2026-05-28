#!/usr/bin/env wolframscript

(* build_paclet.wls - Build paclet archive and install locally
   Usage: wolframscript -f Scripts/build_paclet.wls <PacletName> [--with-docs]

   Documentation is excluded by default; pass --with-docs to bundle Documentation/.

   Auto-detects paclet directory:
     <root>/<PacletName>/<PacletName>/PacletInfo.wl  (dev repo, triple nesting)
     <root>/<PacletName>/PacletInfo.wl               (standalone, double nesting)

   If <PacletName> is a path containing PacletInfo.wl, uses it directly. *)

args = Rest @ $ScriptCommandLine;
withDocs = MemberQ[ args, "--with-docs" | "--docs" ];
positional = DeleteCases[ args, arg_ /; StringStartsQ[ arg, "--" ] ];
If[ Length[ positional ] < 1,
    Print[ "Usage: wolframscript -f build_paclet.wls <PacletName> [--with-docs]" ];
    Print[ "  Documentation is excluded by default; pass --with-docs to bundle it." ];
    Exit[ 1 ]
];

pacletArg = First @ positional;

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
Print[ "  Location: ", paclet[ "Location" ] ];
