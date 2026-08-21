# research-notebook: the drift-detection fingerprint

How the build stamps a per-cell fingerprint and how regeneration checks it.
This mechanism guards the one-way `.md` → `.nb` pipeline — the working arrangement and the stop-on-drift rule are in [SKILL.md](SKILL.md).

## Stamping and checking

1. **At build**, after writing the `.nb`, re-import it, fingerprint the round-tripped cells, and store the result in a notebook option:

   ```wolfram
   TaggingRules -> { "ResearchNotebook" -> { "Cells" -> fingerprint } }
   ```

   The fingerprint is `<| CellID -> Hash[ { content, style } ] |>`, and it has to **walk into `CellGroupData`**.
   Level `{1}` alone is not enough: `FoldExampleGroups` puts every Example's `Input` and `Output` inside a group and the folded *Initialization* section is another, so on a document with four Examples that is eleven cells — all of the code and all of the outputs — outside drift detection, with the check reporting clean because both sides use the same level (measured on `SidonBound`, 2026-08-21).
   Two details are load-bearing: **assign the `CellID`s yourself** — `CreateCellID -> True` is an instruction to the front end and does **not** stamp programmatically built cells — and **fingerprint after the round-trip**, never the in-memory expression, because `Export` normalises cell content and an in-memory fingerprint reports every cell as edited.
   **Stamp the round-tripped notebook, never the in-memory one.**
   Writing a stamp taken from the round trip back onto the in-memory expression describes cells the file does not hold: `Export` normalises a `GraphicsBox`, so every graphics output comes out reported as edited on the next check.
   That is the mechanism behind the three stale entries the T4 read of `EquidistanceOddGirth` found (2026-08-20) and behind their recurrence on the next build (2026-08-21) — measured both times as exactly the three graphics `Output` cells, with `Export`/`Import` itself a fixed point.
   Build the final notebook as `Notebook[ First[ imported ], <options>, TaggingRules -> … ]` and export *that*, then re-import and confirm the drift report is empty before declaring the build good.

   The stamp must **merge** into any `TaggingRules` already on the notebook — with prompt tracking on, the build has put a `"Provenance"` key there — so write it through the `stampTaggingRule` helper in the [provenance](../provenance/SKILL.md) skill, never as a literal `TaggingRules -> {...}` that replaces the option.
   Stamping only touches options, so the just-computed cell fingerprint stays valid.
2. **Before regenerating**, re-import and compare.
   A cell with no `CellID` is **user-added**; a recorded `CellID` that is gone is **user-deleted**; a recorded `CellID` whose hash moved is **user-edited**.
3. **If anything drifted, stop.**
   Present the drift and let the user decide — transcribe it into the `.md`, or discard it.
   Do not regenerate over it and do not guess.
   If nothing drifted, regenerate freely.

Verified: an untouched notebook reports zero drift (no false positives), and a notebook with one cell rewritten, one added and one deleted reports exactly those three.

## Why there is no reverse direction

Both candidates lose content, measured at the pinned SHA.

`ExportString[ Import[ path ], "Markdown" ]` on a generated research notebook turned a 639-character source into 955 characters of unusable output:

- Every typeset construct became a reference to a PNG that does not exist — `![…](img/….png)` — including each subscripted inline formula, each `DisplayFormula`, every `Citation` button, and the whole table.
- The environment markers were gone: a `Definition` cell exports as bare prose, so a round-trip would silently demote it to `Text`.
- A `wolfram` fence came back as broken literal source containing `$Failed` and `MarkdownTools\`Private\`` symbols.
- Non-ASCII characters mojibaked (`κ` → `Îº`), headings shifted down a level, and the frontmatter was dropped.

`NotebookToMarkdown.wl` is not a way out either — it loses frontmatter and empties table headers (see `Wiki/Resources/MarkdownToNotebook.md`).

The fingerprint replaces both: it detects *that* and *where* the user edited without needing to read the notebook back as Markdown.
