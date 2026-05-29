#!/usr/bin/env wolframscript

(* build_paclet.wls - Build paclet archive and install locally
   Usage: wolframscript -f Scripts/build_paclet.wls <PacletName> [--with-docs]

   Documentation is excluded by default; pass --with-docs to bundle Documentation/.

   Auto-detects paclet directory:
     <root>/<PacletName>/<PacletName>/PacletInfo.wl  (dev repo, triple nesting)
     <root>/<PacletName>/PacletInfo.wl               (standalone, double nesting)

   If <PacletName> is a path containing PacletInfo.wl, uses it directly. *)

Get[ FileNameJoin[ { DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ], "paclet_common.wl" } ] ];

args = Rest @ $ScriptCommandLine;
withDocs = MemberQ[ args, "--with-docs" | "--docs" ];
positional = DeleteCases[ args, arg_ /; StringStartsQ[ arg, "--" ] ];
If[ Length[ positional ] < 1,
    Print[ "Usage: wolframscript -f build_paclet.wls <PacletName> [--with-docs]" ];
    Print[ "  Documentation is excluded by default; pass --with-docs to bundle it." ];
    Exit[ 1 ]
];

result = buildAndInstallPaclet[ First @ positional, withDocs ];
Print[ "  Location: ", result[ "Paclet" ][ "Location" ] ];
