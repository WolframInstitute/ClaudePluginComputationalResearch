# MarkdownToNotebook

*[ LLM Generated ]*

Nikolay Murzin et al., *MarkdownToNotebook* — `WolframInstitute/MarkdownToNotebook`, https://github.com/WolframInstitute/MarkdownToNotebook.
Pinned at `204db7c924ad562757abd13fe390ca56b39a35c3` (2026-07-26).

## Summary

A Wolfram Language converter that turns a literate-Markdown document into a Wolfram notebook, choosing the layout from a `Template` frontmatter key.
`MarkdownToNotebook.wl` is a single 5273-line file of interdependent private definitions with no package boundary; `NotebookToMarkdown.wl` (1505 lines) is the reverse direction.
Templates cover `Symbol` / `Guide` / `TechNote` documentation pages, `FunctionResource` / `Paclet` definition notebooks, and a plain `Default`.

The value over WL 15's built-in `ImportString[md, {"Markdown", "Notebook"}]` is fidelity on three constructs, all measured at the pinned SHA:

- **Code arrives as structural boxes.** A `wolfram` fence becomes a real `RowBox` tree with source spacing preserved as `" "` leaves, so the house code style survives conversion and hover help, F1, and autocomplete all work.
  The built-in importer returns `BoxData["raw string"]`, which is why the built-in pipeline needs a re-parse step and a graphics blocklist around it.
- **LaTeX math becomes real boxes.** `$$…$$` yields `DisplayFormula` containing `FractionBox` / `SubscriptBox`, not flat `InlineMath`.
- **YAML frontmatter is consumed as metadata** rather than leaking in as a literal `Text` cell.

The reason it can do all three, and the most transferable thing measured about it: **this plugin's cell-content limitations are a property of the MCP append-cell transport, not of notebooks.**
The converter assembles the whole `Notebook[…]` expression in the kernel and writes it in one go, so `TextData`, `BoxData`, `StyleBox` and `ButtonBox` are never marshalled through a cell-append tool call.
Every construct the project's notebook guidance lists as "does not render" — inline and display math, bold/italic, hyperlinks, pipe tables, blockquote callouts, soft line breaks joined per CommonMark — came out as correct boxes.
Where it is *no* better: nested bullets flatten to plain `Item` with no `SubItem`/`SubSubItem`, and wikilinks pass through as literal text. Both are parity, not a gain.

Two properties bound how far to trust it.
The **reverse direction loses content**: a round-trip drops the frontmatter entirely, drops the `>` blockquote marker, and returns a pipe table with an empty header row and the real header demoted into the body.
That is silent content loss, not formatting drift, so `NotebookToMarkdown` is not used anywhere in this plugin.
And `ensureParser[]` installs the `Wolfram/Parser` paclet on first call, degrading **silently** to `ImportString[…, "TeX"]` with worse math fidelity if the install fails.

`WolframInstitute/PureMath` is the existence proof at scale: it authors 1,480 Markdown doc pages and converts them with this function before running `DocumentationBuild`.
Its build script is 55% workaround by line, but those shims repair DocumentationTools template slots and protect a 1,480-page parallel cloud batch — neither applies to the `Default` template at N=1.

## Use in this project

Backs `new-notebook`'s **rich mode** — the auto-detected second conversion engine, used when a source has YAML frontmatter or LaTeX math.
See [new-notebook](../../skills/new-notebook/SKILL.md), section *Conversion engine — built-in vs rich*.
`paclet-docs` does not use it; that skill uses the official MCP doc tools.

Called as the **local file at a pinned SHA**, via `Get`, with `Template: Default` and `"Evaluate" -> False`.
Not called as the deployed cloud resource: that lives on a personal `obj/nikm/` path that can disappear, and reports `"Version" -> None` with no `"LatestUpdate"`, so drift is undetectable.

Also backs [research-notebook](../../skills/research-notebook/SKILL.md), but only as the **parser half** of a two-half pipeline: the converter produces the cells, then `scripts/mathnotebook_post.wl` applies the MathNotebook environments, the equation numbering, and the citations.
The join works because a Markdown bold run arrives as `StyleBox[ "Definition.", FontWeight -> "Bold" ]` at the head of the cell's `TextData` — exactly the shape `markerSplit` already matched.

That split is forced by what the converter does **not** have.
Its own theorem environments (`::: theorem` / `::: proof`) exist only under `Template: Chapter`, which swaps `StyleDefinitions` for `BookToolsStyles.nb` — a stylesheet that ships with the `WolframBookTools` paclet and is absent from a stock installation.
Under `Template: Default` those divs are **silently dropped entirely**, 3 divs → 0 cells with no message, and an unrecognised div kind (`::: theorem numbered`, say — the numbered spelling is `::: theorem-numbered`) degrades just as silently to plain cells.
Even under `Chapter` the environments are thin: every label shares the single `Theorem` cell style, numbering is `CounterBox["Section"].CounterBox["Subsection"]` with no per-environment counter — so a Proposition and a Lemma in the same subsection print the *same* number — head cells carry no `CellTags`, `[text](#anchor)` becomes a dead `URL` fragment button, and `[@key]` citations pass through as literal text.
There is no bibliography engine; `## References` under `Chapter` yields `ReferenceSection` / `Reference` styling only.

The reverse direction stays unused, now for a second measured reason beyond the frontmatter and table losses above: on a notebook carrying typeset math, `ExportString[ Import[ path ], "Markdown" ]` replaces every formula, citation button and table with a reference to a nonexistent PNG, mojibakes non-ASCII characters, and returns `wolfram` fences as broken literal source containing `$Failed`.
`research-notebook` therefore generates one-way and detects `.nb` edits with a per-cell `CellID` fingerprint instead.

Two rich-mode TeX losses worth carrying, measured at this SHA: `\to` and `\mapsto` become an **empty string** (`\rightarrow`, `\longrightarrow`, `\hookrightarrow` and pasted Unicode all work), and `\tag{…}` is not understood — it renders literally as `(tag)`.
Also, the converter's own table styles `2ColumnTableMod` / `TableText` / `ModInfo` are defined in neither `Default.nb` nor MathNotebook's `AMSArticle.nb`, so pipe tables render unstyled under both.
And a `wolfram` fence starting with `FormBox[…]` stays an `Input` cell under rich mode, so the display-math-by-fence convention is built-in-only and equation `CellTags` must be attached after conversion.

### Four pipeline traps

Each of these fails silently, and two produced a check that could not fail:

- **`##` is already `"Section"`.** The built-in pipeline's heading down-shift must **not** run under rich mode.
- **`ExportString[Notebook[cells], "NB"]` drops the converter's options** — `CreateCellID`, `StyleDefinitions` — so rebuild with `ReplacePart[nb, 1 -> cells]` rather than re-wrapping.
- **`CreateCellID -> True` is a front-end instruction, not a stamp.** It does not put `CellID`s on programmatically built cells. The first version of `research-notebook`'s fingerprint was therefore vacuous: it recorded an empty association and every check passed. Assign the `CellID`s yourself.
- **Fingerprint after the round-trip, never in memory.** `Export` normalises cell content, so hashing in-memory cells and comparing against the re-imported file reported 6 of 15 cells edited when one had changed. Export, re-import, fingerprint *that*, write the stamp back.

The converter also stamps `CellLabel -> "In[n]:= "` on cells even under `"Evaluate" -> False`, so rich mode strips it.

Rich mode **removes a workaround rather than adding a feature**: the built-in pipeline's `boxifyInputCells` exists only because the importer returns `BoxData["raw string"]`, and its `vizCellQ` blocklist exists only because the `ToBoxes[ToExpression[…, Defer]]` fix strands graphics cells. The rich parser emits the structural tree directly, so both the workaround and its exception disappear — and the cells the blocklist used to give up on are the ones that improve most.

### It is not a Claude plugin

No `.claude-plugin/`, no `plugin.json`, no `commands/`, no marketplace entry.
What it has is a bare `skills/` directory plus `install-skills.sh`, which **symlinks** each skill into `$HOME/.claude/skills` — the install location for *personal* skills, since `claude plugin install` applies only to marketplace-published plugins.

The 12 skills are one orchestrator (`create-wolfram-documentation`) plus eleven authoring skills, one per Wolfram publishing genre: `wolfram-symbol-page`, `wolfram-guide-page`, `wolfram-tech-note`, `wolfram-overview-page`, `wolfram-paclet`, `wolfram-function-resource`, `wolfram-data-repository`, `wolfram-example-repository`, `wolfram-demonstration`, `wolfram-prompt`, `wolfram-computational-essay`.

**Name collisions with this plugin's skills: zero** — every one of theirs is `create-wolfram-documentation` or `wolfram-*`. Mechanically they would coexist even on a clash, since plugin skills are addressed as `computational-research:<name>` while personal skills are unnamespaced.

The conflict is semantic, not nominal, which is why `install-skills.sh` stays unrun: their trigger descriptions are very broad ("whenever the user wants to create, write, or publish a Wolfram Language paclet") and would leave two plausible responders for "document my paclet" with nothing to arbitrate.

Licence: the user confirmed it is fine to depend on.
The repo itself still carries no `LICENSE` file (`license: null`) and no tags or releases, so pinning is by SHA.
A standing, non-blocking ask for an in-tree `LICENSE` is open with Nikolay Murzin.

Upstream cadence, corrected against an earlier "moves daily" reading: 277 commits since 2026-05-22 over 39 active days, but July runs 12 active days in 26 with 4- and 5-day gaps.
Authorship is no longer single-author (96 of the last 100 commits Nikolay Murzin, 4 Mads Bahrami), which mildly softens the bus-factor risk.

Two probes that do **not** work, recorded so they are not retried: `ResourceObject[...]` lookups fail from the MCP kernel even for known-published Function Repository entries, and curl against `resources.wolframcloud.com` returns the same 302 to an OAuth check for a published and an unpublished resource alike. Read the upstream README instead.

## Recover

Clone: https://github.com/WolframInstitute/MarkdownToNotebook
Target: MarkdownToNotebook
Commit: 204db7c924ad562757abd13fe390ca56b39a35c3

The clone sits at the project root, not under `Resources/`, matching the existing gitignored sibling clones `MathNotebook/` and `PureMath/`.

```bash
git clone https://github.com/WolframInstitute/MarkdownToNotebook.git
git -C MarkdownToNotebook checkout 204db7c
```

## See also

- [Status](../Status.md) — which engine `new-notebook` uses when
- [MathNotebook](MathNotebook.md) — the post-processing half of the `research-notebook` pipeline
- [PureMath](PureMath.md) — the existence proof at 1,480 pages, and where the shim-tax figure comes from
- [Progress Harvest](../Concepts/ProgressHarvest.md) — the harvest that added the traps and the Claude-side sections
- `Work/Done/2026-07-27-EvaluateMarkdownToNotebook.md` and `Work/Done/2026-07-27-AdoptMarkdownToNotebook.md` — the evaluation and adoption decisions behind this pin
