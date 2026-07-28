---
name: paclet-docs
description: >
  Generate real Wolfram documentation for a paclet — one symbol reference page
  per exported function, written into the paclet's Documentation tree through the
  official MCP doc tools so it resolves in-product via ?Symbol, F1, and the
  Documentation Center. Use when the user says "document the paclet", "paclet
  docs", "symbol pages", "reference pages", "document these functions", "write
  docs for X", or the /paclet-docs command. Guide pages are deliberately not
  generated — they are a human deliverable.
---

# Paclet Docs

Generate a symbol reference page for each exported function of a paclet, in the
paclet's own `Documentation/` tree, so a Wolfram user meets the paclet the way
they meet built-in functions: `?Symbol`, F1, Documentation Center search.

## Guide pages are out of scope — Critical

**Do not generate a guide page.** Grouping a paclet's functions by role, naming
the groups, and writing the abstract is editorial judgement about what the paclet
*is*, and it reads better written by the author. The official MCP doc tools have
no guide-page tool either, so there is nothing to automate here.

What you may do:

- If the author has **already written** a guide page, link every symbol page to
  it (`relatedGuides` on creation, or `EditSymbolDoc` with `setRelatedGuides`).
- If asked, offer a **draft function list** — the symbols grouped by role, one
  line each — as plain text for the author to paste into their own guide. Offer
  it; do not write the guide.

## What you need

1. **Paclet name or directory.** Detect as `build-paclet` does — dev repo
   (triple nesting) `<PacletName>/<PacletName>/PacletInfo.wl`, standalone
   (double nesting) `<PacletName>/PacletInfo.wl`, or a direct path containing
   `PacletInfo.wl`. Resolve the absolute `<pacletDir>` once.
2. **The exported symbols.** Prefer the `"Symbols"` list in the `Kernel`
   extension of `PacletInfo.wl` — it is the author's own statement of the public
   API. Only fall back to `Needs[ "<Org>`<Paclet>`" ]` then
   `Names[ "<Org>`<Paclet>`*" ]` when that list is absent, and say which source
   you used.
3. **Publisher ID and context**, read from `PacletInfo.wl`
   (`"PublisherID"`, `"PrimaryContext"`).

## Kernel execution (license-aware)

Everything here runs through the official AgentTools MCP — one persistent kernel,
no extra license seat. There is no `wolframscript` fallback: the doc tools are
MCP-only.

## Never read or hand-edit the page files

Doc pages are `.nb` files, and a `PreToolUse` hook blocks reading them. Author
and edit them **only** through the MCP doc tools. If a page needs changing, use
`EditSymbolDoc` / `EditSymbolDocExamples` — never open the notebook.

## Step-by-step

### 1. Agree the scope before generating anything

List the symbols you found and the source you found them in, then **stop and get
agreement** on the list and on which sections each page will carry. Generating
thirty pages the author did not want is thirty pages of `.nb` to delete.

Follow the [revise](../revise/SKILL.md) protocol: **generate one page first**,
show it, and only continue once its shape is approved. Page shape is the kind of
thing that is wrong in the same way thirty times.

### 2. Create each symbol page

`mcp__Wolfram__CreateSymbolDoc` writes the page into the correct place in the
paclet doc tree. Its content arguments are **Markdown**, and code blocks in
`basicExamples` are evaluated automatically:

- `usage` — one bullet per signature, the symbol in backticks and arguments in
  italics: ``- `GraphInteriorForm[g]` gives the interior form of the graph *g*``.
  One bullet per genuinely distinct signature, not per option.
- `notes` — `Details & Options`; each paragraph becomes one note cell. State
  argument types, defaults, and what the symbol does *not* do.
- `basicExamples` — the smallest example that shows the function working, then
  one or two that show a real use. Follow the project's example house style
  (`wi:sw-example` when it is available).
- `seeAlso`, `keywords`, `relatedGuides`, `techNotes`, `relatedLinks`,
  `newInVersion` as available.

Pass `pacletDirectory`, `symbolName`, `pacletName`, `publisherID`, and `context`
explicitly rather than relying on defaults.
**`pacletName` must not repeat the publisher.** `"WolframInstitute/MathNotebook"`
together with `publisherID -> "WolframInstitute"` yields the URI
`WolframInstitute/WolframInstitute/MathNotebook/ref/…`, which resolves to nothing.
Pass the bare name.

Two authoring rules that are wrong silently:

- **One statement per ` ```wl ` block.** Two statements are wrapped in a
  `Defer[a, b]` that is *visible* in the input cell. `a; b` on one line is one
  statement and is fine.
- **Backticks auto-link built-ins only.** A backticked symbol from the paclet
  itself renders as literal backticks; write it as
  `[Symbol](paclet:<Pub>/<Paclet>/ref/<Symbol>)`.

For richer pages, add sections afterwards with `mcp__Wolfram__EditSymbolDocExamples`
(`Scope`, `Options`, `Applications`, `PropertiesRelations`, `PossibleIssues`,
`NeatExamples`) and adjust metadata with `mcp__Wolfram__EditSymbolDoc`
(`setUsage`, `setNotes`, `addNote`, `setDetailsTable`, `setSeeAlso`,
`setKeywords`, `setHistory`).

`EditSymbolDocExamples` returns the generated content as Markdown — read it back
and check the examples actually produced what you expected. An example that
errored still writes a page.

**Every code block is force-evaluated; there is no way to show unevaluated
input.** A ` ```wl-input ` fence is evaluated like any other, and its output cell
is written into the page. For a symbol that acts on the front end selection, an
open notebook, or the network, that output is an error or an internal
`PackageScope` expression dressed up as a result — worse than no example.

So for such symbols, **ship the page with no Basic Examples**. Usage plus
`Details & Options` stating what the symbol acts on is an honest page; a
fabricated or failed example is not. Say in the report which symbols got no
examples and why.

### 3. Declare the `Documentation` extension — the page is inert without it

`CreateSymbolDoc` writes the page but does **not** touch `PacletInfo.wl`. Unless
the paclet declares the extension, every page is dead weight: the file exists,
it opens, and the `paclet:` URI resolves to nothing. Add it if absent:

```wolfram
{ "Documentation", "Root" -> "Documentation", "Language" -> "English" }
```

### 4. Verify it resolves in-product — the only test that counts

A malformed or undeclared page fails **silently**. So verify, do not assume.

Build and install with docs bundled — `CreatePacletArchive` then
`PacletInstall[ archive, ForceVersionInstall -> True ]` — and resolve every URI:

```wolfram
Documentation`ResolveLink[ "paclet:<Pub>/<Paclet>/ref/<Symbol>" ]
```

It must return the path of an existing file **under the installed paclet**, not
under your source tree. `Null` means the page is not wired: check the
`Documentation` extension, then `pacletName` / `publisherID`, then the URI.

**Do not use `Information` or `?Symbol` as the test.** They print the `::usage`
string from the kernel, which a paclet with a `Usage.wl` has whether or not any
documentation exists — on MathNotebook, `ConvertMathCells` showed a full usage
line while having no page at all. It is a test that cannot fail.

`mcp__Wolfram__CheckPaclet` is **not** a paclet linter and does not belong here.
It wraps `Wolfram`PacletCICD`CheckPaclet`, which requires a Paclet *Repository*
definition notebook; against a plain paclet directory it returns
`CheckPaclet::invfile` and the MCP wrapper dies with an unhandled-downvalues
internal error. Use it only for a paclet being submitted to the Paclet
Repository.

**F1 and Documentation Center search need a human.** They are the acceptance
criterion and they are not verifiable headlessly. Ask the author to press F1 on
one symbol and search the Documentation Center for it, and say plainly that this
step is outstanding until they do.

## Report

Say which symbols got pages, which sections each carries, which symbols got no
examples and why, how many URIs resolved out of how many symbols, and that F1 /
Documentation Center confirmation is still owed to the author.

Also check how the paclet is **published**. A hand-written publish script that
stages a fixed list of directories will silently drop `Documentation/`; flag it
rather than assuming the docs ship.

## Shipping the pages

[publish-paclet](../publish-paclet/SKILL.md) bundles `Documentation/` by default,
verifies every URI resolves from the install, and then deploys the pages as public
cloud notebooks with an HTML index
([deploy_paclet_docs.wl](../../scripts/deploy_paclet_docs.wl)) so a reader who has
installed nothing can still read them. That deployed index is the link to put in
the README.
