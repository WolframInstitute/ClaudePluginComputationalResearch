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

Called as the **local file at a pinned SHA**, via `Get`, with `Template: Default` and `"Evaluate" -> False`.
Not called as the deployed cloud resource: that lives on a personal `obj/nikm/` path that can disappear, and reports `"Version" -> None` with no `"LatestUpdate"`, so drift is undetectable.

Deliberately **not** used by [research-notebook](../../skills/research-notebook/SKILL.md), in either direction.
Forward, the `Default` template emits no `Author` or `Abstract` cells and none of the MathNotebook theorem environments that skill specifies.
Backward, the round-trip content loss above would corrupt its Markdown source on every sync.

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
