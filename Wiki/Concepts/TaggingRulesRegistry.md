# The notebook TaggingRules registry

*[ LLM Generated ]*

`TaggingRules` is the plugin's one non-rendering metadata slot inside a generated `.nb`, and it is **shared**: two independent writers store keys there, so any writer that sets a literal `TaggingRules -> {...}` erases the other's key.
The rule is: **merge by key, never replace the option.**

## The keys

| Key | Written by | Content |
|---|---|---|
| `"Provenance"` | `new-notebook` / `research-notebook` at build (MCP path), or `Scripts/generate_notebooks.wls` (batch fallback) | association of provenance fields parsed from the source's leading `<!-- provenance: ... -->` comment |
| `"ResearchNotebook"` | `research-notebook` after the export/re-import round-trip | `{ "Cells" -> <\| CellID -> Hash[ { content, style } ] \|> }`, the per-cell drift fingerprint |

Both writers can touch the same notebook: with prompt tracking on, a research notebook is built with `"Provenance"` (passed through `MathNotebookDocument`) and then stamped with `"ResearchNotebook"` — in that order, since the fingerprint must come from the round-tripped file.

## The merge stamp

The canonical helper lives in the `provenance` skill and is what every writer calls:

```wolfram
stampTaggingRule[ nb_Notebook, key_String -> value_ ] :=
  With[ { existing = Replace[ TaggingRules /. Options[ nb ], TaggingRules -> {} ] },
    Notebook[ First @ nb,
      Sequence @@ FilterRules[ Options[ nb ], Except[ TaggingRules ] ],
      TaggingRules -> Normal @ Append[ Association @ existing, key -> value ] ]
  ]
```

It adds or updates one key, keeps every other key and every other notebook option (`CreateCellID`, `StyleDefinitions`, ...), and only touches options — so a just-computed cell fingerprint stays valid across a provenance stamp and vice versa.
Verified 2026-07-28 on the AgentTools kernel: stamping either key alongside the other, re-stamping the same key, and the full `ExportString`/`ImportString` round-trip all preserve both keys, and the provenance skill's documented read-back (`"Provenance" /. ( TaggingRules /. Options[ nb, TaggingRules ] )`) is unaffected.

## History

Until 2026-07-28 the provenance injection existed only in `generate_notebooks.wls`, the license-gated batch fallback; the preferred MCP path never wrote `TaggingRules`, so the prompt-tracking toggle silently no-oped on the path that actually runs (found by the 2026-07-28 audit, fixed by AuditFixes T3).
The fingerprint key predates the fix, which is why coexistence had to be designed rather than assumed.

## See also

- [The Claude Code hook contract](HookContract.md) — the audit's other silently-inert mechanism
