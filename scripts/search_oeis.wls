#!/usr/bin/env wolframscript

(* search_oeis.wls — Search the Online Encyclopedia of Integer Sequences
   Usage: wolframscript -f search_oeis.wls <keywords>
   Output: JSON array of {anum, name, sequence, url}

   Uses the OEIS JSON API at oeis.org/search?q=...&fmt=json. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_oeis.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = StringRiffle[ $ScriptCommandLine[[ 2 ;; ]], " " ];

response = Quiet @ Import[
    "https://oeis.org/search?q=" <> URLEncode[ keywords ] <> "&fmt=json",
    "RawJSON"
];

hits = Which[
    ListQ[ response ], response,
    AssociationQ[ response ] && KeyExistsQ[ response, "results" ] && ListQ[ response[ "results" ] ],
        response[ "results" ],
    True, {}
];

results = Map[
    Module[ { anum, name, data },
        anum = Quiet @ #[ "number" ];
        name = Quiet @ #[ "name" ];
        data = Quiet @ #[ "data" ];
        <|
            "anum" -> If[ IntegerQ[ anum ], "A" <> StringPadLeft[ ToString[ anum ], 6, "0" ], "" ],
            "name" -> If[ StringQ[ name ], name, "" ],
            "sequence" -> If[ StringQ[ data ], StringTake[ data, UpTo[ 120 ] ], "" ],
            "url" -> If[ IntegerQ[ anum ],
                "https://oeis.org/A" <> StringPadLeft[ ToString[ anum ], 6, "0" ],
                "https://oeis.org/search?q=" <> URLEncode[ keywords ]
            ]
        |>
    ] &,
    Take[ hits, UpTo[ 20 ] ]
];

Print[ ExportString[ results, "JSON", "Compact" -> True ] ]
