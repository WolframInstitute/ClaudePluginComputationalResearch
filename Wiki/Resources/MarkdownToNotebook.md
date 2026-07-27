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

Do **not** run the repo's `install-skills.sh`.
Its symlinked skills track upstream `main` — a live feed — and their trigger descriptions compete with `build-paclet` / `publish-paclet` with nothing to arbitrate.

Licence: the user confirmed it is fine to depend on.
The repo itself still carries no `LICENSE` file (`license: null`) and no tags or releases, so pinning is by SHA.

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
- [Work/Active/AdoptMarkdownToNotebook.md](../../Work/Active/AdoptMarkdownToNotebook.md) — the evaluation and adoption decisions behind this pin
