#!/usr/bin/env wolframscript

(* publish_paclet.wls - Build, install locally, and publish paclet to Wolfram Cloud
   Usage: wolframscript -f Scripts/publish_paclet.wls <PacletName> [--with-docs]

   Documentation is excluded by default; pass --with-docs to bundle Documentation/.

   Auto-detects paclet directory:
     <root>/<PacletName>/<PacletName>/PacletInfo.wl  (dev repo, triple nesting)
     <root>/<PacletName>/PacletInfo.wl               (standalone, double nesting)

   If <PacletName> is a path containing PacletInfo.wl, uses it directly.

   Produces a public cloud URL for PacletInstall. *)

Get[ FileNameJoin[ { DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ], "paclet_common.wl" } ] ];

args = Rest @ $ScriptCommandLine;
withDocs = MemberQ[ args, "--with-docs" | "--docs" ];
positional = DeleteCases[ args, arg_ /; StringStartsQ[ arg, "--" ] ];
If[ Length[ positional ] < 1,
    Print[ "Usage: wolframscript -f publish_paclet.wls <PacletName> [--with-docs]" ];
    Print[ "  Documentation is excluded by default; pass --with-docs to bundle it." ];
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
Print[ "" ];
Print[ "=== PACLET_URL: ", cloudURL, " ===" ];
Print[ "" ];
Print[ "Install from cloud:" ];
Print[ "  PacletInstall[\"", cloudURL, "\"]" ];
