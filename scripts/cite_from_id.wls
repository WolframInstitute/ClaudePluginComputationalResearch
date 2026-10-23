#!/usr/bin/env wolframscript

(* cite_from_id.wls — Generate BibTeX/biblatex from an arXiv ID or DOI.
   Usage: wolframscript -f cite_from_id.wls <identifier>
   Citation logic is shared with the MCP in citation_common.wl. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f cite_from_id.wls <arxivId | doi>" ];
    Exit[ 1 ]
];

Get[ FileNameJoin[ { DirectoryName[ ExpandFileName[ $ScriptCommandLine[[ 1 ]] ] ], "citation_common.wl" } ] ];
Module[ { result = citationFromIdentifier[ $ScriptCommandLine[[ 2 ]] ] },
    If[ FailureQ[ result ],
        Print[ "% ", result[ "MessageTemplate" ] ];
        Exit[ 1 ],
        Print[ result ]
    ]
];
