# Generating Wolfram paclet documentation

*[ LLM Generated ]*

How this plugin authors real Wolfram documentation pages into a paclet, what actually verifies them, and the traps that make a doc page look built when it is not.

Harvested 2026-07-28 from the closed item `PacletDocumentation` (six sessions, 2026-07-27) — see [Progress Harvest](ProgressHarvest.md).
Backs the `paclet-docs`, `build-paclet`, and `publish-paclet` skills.

## The engine choice, and what it cost

Two markdown-to-doc-page engines were available: the official Wolfram MCP doc tools, and [MarkdownToNotebook](../Resources/MarkdownToNotebook.md), which [PureMath](../Resources/PureMath.md) drives across 1,480 pages.
The user chose the **official MCP tools** — `CreateSymbolDoc`, `EditSymbolDoc`, `EditSymbolDocExamples`, `CheckPaclet` — to avoid depending on a repo that then had no licence and no pinnable release.

The stated cost was the **guide-page gap**: the official set has no `CreateGuideDoc`, and `EditSymbolDoc`'s `setRelatedGuides` can only link to a guide it cannot create.
That cost was then annulled from the other side — guide pages left scope entirely, on the user's judgement that grouping a paclet's functions by role and writing its abstract is editorial judgement about what the paclet *is*, and therefore a human deliverable.

`paclet-docs` may link to an author-written guide and may offer a draft function list as plain text on request. It never writes the guide.

## Five ways a generated doc page ships broken

All five surfaced in a dry run on a scratchpad copy before anything was written into a real repo, and all five would have shipped broken documentation.

**1. `CheckPaclet` is not a paclet linter.**
It wraps `Wolfram`PacletCICD`CheckPaclet`, whose first definition is `CheckPaclet[dir_File?DirectoryQ] := CheckPaclet[findDefinitionNotebook@dir]` — it wants a Paclet *Repository* definition notebook.
Against a plain paclet it answers `CheckPaclet::invfile` and the MCP wrapper dies with `AgentTools::Internal::UnhandledDownValues::formatCheckResult`.
A workflow whose only verification gate is `CheckPaclet` has no verification gate.

**2. `CreateSymbolDoc` does not declare the `Documentation` extension.**
It writes the page and leaves `PacletInfo.wl` alone, so the URI resolves to `Null` — the page exists and is unreachable, the silent failure mode that makes doc bugs expensive.
Fix by adding to `PacletInfo.wl`:

```wolfram
{ "Documentation", "Root" -> "Documentation", "Language" -> "English" }
```

**3. `Information` cannot verify a doc page.**
It prints `::usage` from the kernel. A symbol with a full usage line and **no page at all** passes it, so it is a check that cannot fail.
The real check is `Documentation`ResolveLink`, which must return an existing file under the installed paclet — after `CreatePacletArchive` + `PacletInstall`, a real install, not a `PacletDirectoryLoad`.

**4. `pacletName` must not repeat the publisher.**
Passing `"WolframInstitute/MathNotebook"` alongside `publisherID` produces `WolframInstitute/WolframInstitute/MathNotebook/ref/…`.

**5. One statement per code block.**
Two become a `Defer[a, b]` visible in the rendered input cell. `a; b` on one line is fine.

## There is no unevaluated code block

A ` ```wl-input ` fence is evaluated like any other and its output is written into the page.
On `NotebookPut[ImportLaTeXDocument["paper.tex"]]` it wrote `NotebookPut[WolframInstitute`MathNotebook`PackageScope`latexToNotebook[$Failed]]` — an internal symbol presented to the reader as a result.

This is not a tooling wart to work around; it is a constraint on which paclets can have generated examples at all.
19 of MathNotebook's 21 symbols act on the front-end selection, an open notebook, or the network, so no evaluated example of them means anything.
Those pages ship with Usage and Details & Options and an **empty** Basic Examples section, which was the user's call when asked.

**A paclet's public API shape decides whether generated reference docs can carry examples, and a front-end-driven paclet cannot.** Ask before promising examples.

`EditSymbolDocExamples` returns its generated content as Markdown, so read it back and check the examples produced what was expected — an example that errored still writes a page.

## The fixed staging list was the real defect

Scoped as "wire `Documentation/` into build and publish", the task found something larger.

`paclet_common.wl` staged `PacletInfo.wl` + `Kernel/` + `Tests/` and nothing else.
Building MathNotebook through the plugin therefore installed it with **no `FrontEnd/` and no `Assets/`** — no palette, no stylesheets: a paclet that loads and is missing most of what it is for.
`Documentation/` was only the latest victim.

Staging is now every top-level item except dotfiles and `build/`, with `Documentation/` the one conditional entry, so a paclet that adds a directory tomorrow ships it.

The evidence had been sitting in the downstream repo the whole time: MathNotebook's own `CLAUDE.md` said "do not use the generic recipe here", which is the shape of a bug that has been **worked around rather than reported**.
Worth reading a paclet's own notes *about this plugin*, not just its code.

Docs default: **on for publish, off for build** (`publish_paclet.wls --no-docs`, `build_paclet.wls --with-docs`).

## Deploying docs so a zero-install reader can read them

Retiring `demo-notebook` was safe only because documentation can be published twice — shipped in the paclet for the installed reader, and deployed to a public URL for everyone else. PureMath does exactly this.
`scripts/deploy_paclet_docs.wl` does it here, called automatically by `publish_paclet.wls` when docs were bundled, printing `=== DOCS_URL: … ===` beside `=== PACLET_URL: … ===`.

Two findings shaped that script:

- **Cross-links must be rewritten or you publish Wolfram-branded 404s.** A generated page's own links carry a web URL of `reference.wolfram.com/language/<Publisher>/<Paclet>/ref/<Sym>.html` — an address that exists only for paclets shipped *with* the Wolfram Language. Links come in two forms: `TemplateBox[{label, "paclet:…", url}, "TextRefLink"]` in prose, and `ButtonBox[…, ButtonData -> "paclet:…"]` in Usage and See Also. A rule for one silently leaves the other; after both rules, no `paclet:` string survives in a rewritten page.
- **`ExportString[nb, "HTML"]` is not an option for static pages.** It rasterizes the cells into a ~10 kB image map and drops every link. The pages therefore deploy as cloud notebooks plus an HTML index.

Verification: `URLRead[url, "StatusCode"]` over **every** deployed page, not a sample. It costs seconds and catches a permissions miss that sampling would not.

## What still needs a human

Two things are not verifiable headlessly, and the skills say so rather than letting a headless check stand in for them:

- **F1 and Documentation Center search.** Every URI resolving from a real install is necessary and not sufficient.
- **Click-through on deployed pages.** The pages serve 200 to an anonymous reader and every `paclet:` link is rewritten to an absolute URL, but whether the cloud notebook viewer turns those into working links is a browser question.

## The target page structure

```
Symbol: frontmatter (Template: Symbol, Name, Context, Paclet, URI,
        Keywords, SeeAlso, RelatedGuides)
        ## Usage             <code>[Symbol]()</code>[*args*], one line per signature
        ## Details & Options
        ## Basic Examples    ```wl cells, expected results as <!-- => … --> comments
        ## Possible Issues
```

`paclet-docs` takes the public API from the `"Symbols"` list in `PacletInfo.wl` in preference to `Names[context <> "*"]` — that list is the author's own statement of what is public — and says which source it used.
It generates **one page first** and gets its shape approved before the rest, because page shape is wrong in the same way thirty times.

## See also

- [MathNotebook](../Resources/MathNotebook.md) — the paclet these tools were exercised against, 21/21 URIs resolving
- [PureMath](../Resources/PureMath.md) — the reference implementation, which took the other engine
- [MarkdownToNotebook](../Resources/MarkdownToNotebook.md) — the engine not chosen here
- [Progress Harvest](ProgressHarvest.md) — where this article came from
- `Work/Done/2026-07-27-PacletDocumentation.md` — the six sessions behind it
