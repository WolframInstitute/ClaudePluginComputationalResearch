#!/usr/bin/env wolframscript

(* search_wolfram_community.wls — Construct Wolfram Community search URLs
   Usage: wolframscript -f search_wolfram_community.wls <keywords>
   Output: JSON object with search and tag URLs

   The Community site is JavaScript-rendered, so Import cannot scrape results.
   This script constructs the URLs; the skill should use WebFetch on them. *)

If[ Length[ $ScriptCommandLine ] < 2,
    Print[ "Usage: wolframscript -f search_wolfram_community.wls <keywords>" ];
    Exit[ 1 ]
];

keywords = $ScriptCommandLine[[ 2 ;; ]];
query = StringRiffle[ keywords, " " ];
tag = StringRiffle[ keywords, "+" ];

result = <|
    "search_url" -> "https://community.wolfram.com/search?query=" <> URLEncode[ query ],
    "tag_url" -> "https://community.wolfram.com/content?curTag=" <> URLEncode[ tag ],
    "note" -> "Community site requires JavaScript. Use WebFetch on these URLs."
|>;

Print[ ExportString[ result, "JSON", "Compact" -> True ] ]
