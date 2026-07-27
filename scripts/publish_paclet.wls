#!/usr/bin/env wolframscript

(* publish_paclet.wls - Build, install locally, and publish paclet to Wolfram Cloud
   Usage: wolframscript -f Scripts/publish_paclet.wls <PacletName> [--no-docs]

   Documentation/ is bundled by default — a published paclet ships its docs.
   Pass --no-docs to exclude it.

   Auto-detects paclet directory:
     <root>/<PacletName>/<PacletName>/PacletInfo.wl  (dev repo, triple nesting)
     <root>/<PacletName>/PacletInfo.wl               (standalone, double nesting)

   If <PacletName> is a path containing PacletInfo.wl, uses it directly.

   Produces a public cloud URL for PacletInstall. *)

Get[ FileNameJoin[ { DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ], "paclet_common.wl" } ] ];

args = Rest @ $ScriptCommandLine;
withDocs = ! MemberQ[ args, "--no-docs" ];
positional = DeleteCases[ args, arg_ /; StringStartsQ[ arg, "--" ] ];
If[ Length[ positional ] < 1,
    Print[ "Usage: wolframscript -f publish_paclet.wls <PacletName> [--no-docs]" ];
    Print[ "  Documentation/ is bundled by default; pass --no-docs to exclude it." ];
    Exit[ 1 ]
];

result = buildAndInstallPaclet[ First @ positional, withDocs ];
pacletName = result[ "PacletName" ];
pacletFile = result[ "PacletFile" ];

(* ── Publish to Wolfram Cloud ─────────────────────────────────────────── *)

Print[ "Uploading to Wolfram Cloud..." ];
CloudConnect[];
cloudObj = CloudObject[ pacletName <> ".paclet", Permissions -> "Public" ];
CopyFile[ pacletFile, cloudObj, OverwriteTarget -> True ];
cloudURL = First[ cloudObj ];

Print[ "  Published: ", cloudURL ];

(* ── Deploy the documentation pages, for readers who have not installed ─── *)

docsURL = If[ withDocs && DirectoryQ[ FileNameJoin[ { result[ "PacletDir" ], "Documentation" } ] ],
    Print[ "Deploying documentation..." ];
    Get[ FileNameJoin[ { DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ], "deploy_paclet_docs.wl" } ] ];
    With[ { deployed = deployPacletDocs[ result[ "PacletDir" ], FileNameJoin[ { pacletName, "Documentation" } ] ] },
        If[ AssociationQ[ deployed ],
            Print[ "  Deployed ", Length @ deployed[ "Pages" ], " pages" ];
            If[ deployed[ "Failed" ] =!= { }, Print[ "  Failed: ", StringRiffle[ deployed[ "Failed" ], ", " ] ] ];
            deployed[ "IndexURL" ],
            Print[ "  ", deployed ];
            Missing[ "DeployFailed" ]
        ]
    ],
    Missing[ "NoDocumentation" ]
];

Print[ "" ];
Print[ "=== PACLET_URL: ", cloudURL, " ===" ];
If[ StringQ[ docsURL ], Print[ "=== DOCS_URL: ", docsURL, " ===" ] ];
Print[ "" ];
Print[ "Install from cloud:" ];
Print[ "  PacletInstall[\"", cloudURL, "\"]" ];
