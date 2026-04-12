#!/usr/bin/env wolframscript

(* publish_paclet.wls - Build, install locally, and publish paclet to Wolfram Cloud
   Usage: wolframscript -f Scripts/publish_paclet.wls <PacletName>

   Auto-detects paclet directory:
     <root>/<PacletName>/<PacletName>/PacletInfo.wl  (dev repo, triple nesting)
     <root>/<PacletName>/PacletInfo.wl               (standalone, double nesting)

   If <PacletName> is a path containing PacletInfo.wl, uses it directly.

   Produces a public cloud URL for PacletInstall. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f publish_paclet.wls <PacletName>" ];
    Exit[ 1 ]
];

pacletArg = $ScriptCommandLine[[ 2 ]];

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

(* ── Build ────────────────────────────────────────────────────────────── *)

tmpDir = FileNameJoin[ { $TemporaryDirectory, pacletName <> "-build" } ];
If[ DirectoryQ[ tmpDir ], DeleteDirectory[ tmpDir, DeleteContents -> True ] ];
CreateDirectory[ tmpDir ];

CopyFile[ FileNameJoin[ { pacletDir, "PacletInfo.wl" } ], FileNameJoin[ { tmpDir, "PacletInfo.wl" } ] ];
CopyDirectory[ FileNameJoin[ { pacletDir, "Kernel" } ], FileNameJoin[ { tmpDir, "Kernel" } ] ];
If[ DirectoryQ[ FileNameJoin[ { pacletDir, "Documentation" } ] ],
    CopyDirectory[ FileNameJoin[ { pacletDir, "Documentation" } ], FileNameJoin[ { tmpDir, "Documentation" } ] ] ];
If[ DirectoryQ[ FileNameJoin[ { pacletDir, "Tests" } ] ],
    CopyDirectory[ FileNameJoin[ { pacletDir, "Tests" } ], FileNameJoin[ { tmpDir, "Tests" } ] ] ];

Print[ "Building paclet archive..." ];
pacletFile = CreatePacletArchive[ tmpDir ];
Print[ "  Created: ", pacletFile ];

DeleteDirectory[ tmpDir, DeleteContents -> True ];

(* ── Install locally ──────────────────────────────────────────────────── *)

Print[ "Installing locally..." ];
paclet = PacletInstall[ pacletFile, ForceVersionInstall -> True ];
Print[ "  Installed: ", paclet[ "Name" ], " v", paclet[ "Version" ] ];

(* ── Publish to Wolfram Cloud ─────────────────────────────────────────── *)

Print[ "Uploading to Wolfram Cloud..." ];
CloudConnect[];
cloudObj = CloudObject[ pacletName <> ".paclet", Permissions -> "Public" ];
CopyFile[ pacletFile, cloudObj, OverwriteTarget -> True ];
cloudURL = First[ cloudObj ];

Print[ "  Published: ", cloudURL ];
Print[ "" ];
Print[ "=== PACLET_URL: ", cloudURL, " ===" ];
Print[ "" ];
Print[ "Install from cloud:" ];
Print[ "  PacletInstall[\"", cloudURL, "\"]" ];
