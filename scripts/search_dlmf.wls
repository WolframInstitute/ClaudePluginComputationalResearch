#!/usr/bin/env wolframscript

(* search_dlmf.wls — Search the NIST Digital Library of Mathematical Functions
   Usage: wolframscript -f search_dlmf.wls <keywords>
   Output: JSON array of {name, url, location}

   Scrapes dlmf.nist.gov/search/?q=... results. The DLMF locator structure is
   <chapter>.<section>.E<equation> or .<subsection>; we surface the locator
   as `location`. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_dlmf.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = StringRiffle[ $ScriptCommandLine[[ 2 ;; ]], " " ];

html = Quiet @ Import[
    "https://dlmf.nist.gov/search/search?q=" <> URLEncode[ keywords ],
    "Text"
];

matches = If[ StringQ[ html ],
    StringCases[ html, RegularExpression[ "\\.\\./([0-9]+(?:\\.[0-9A-Za-z]+)+(?:#[A-Za-z0-9._]+)?)" ] :> "$1" ],
    {}
];

pageLinks = Take[ DeleteDuplicates[ matches ], UpTo[ 20 ] ];

results = Map[
    Module[ { location },
        location = #;
        <|
            "name" -> "DLMF " <> location,
            "url" -> "https://dlmf.nist.gov/" <> location,
            "location" -> location
        |>
    ] &,
    pageLinks
];

Print[ ExportString[ results, "JSON", "Compact" -> True ] ]
