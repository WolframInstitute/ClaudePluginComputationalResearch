# EvaluateMarkdownToNotebook

*[ LLM Generated ]*

> Type: investigation

## Spec

Origin: "Then I want you to evaluate if we can use https://github.com/WolframInstitute/MarkdownToNotebook. You should clone it and check if we can use the resource function or we should just take some functions from that. It also contains multitude of skills for claude. I dont how they are supposed to be used. Is it a claude plugin?"

Evaluate `WolframInstitute/MarkdownToNotebook` as a replacement for, or supplement to, this plugin's home-grown Markdown → notebook pipeline (`new-notebook`, `research-notebook`, `demo-notebook`, `scripts/generate_notebooks.wls`, `scripts/build_demo_notebook.wls`).
The deliverable is a **written recommendation with an integration plan**, not an implementation.

Three questions to answer:

1. **What is the Wolfram side?**
   A published Function Repository resource function we can call as `ResourceFunction["MarkdownToNotebook"][...]`, a paclet, or loose `.wl` files we would have to vendor?
   Which of these does it support, and is it actually more capable than what we already do through the Wolfram MCP?
2. **Depend, vendor, or ignore?**
   If it is a resource function, depending on it is cheap but adds a network/repository dependency and gives up control of the cell-style rules the plugin relies on (the `Title/Section/Subsection/Text/Item/ItemNumbered/Input` set that MCP is known to render).
   If we vendor, which specific functions, and under what license?
3. **What is the Claude side?**
   Is it a Claude *plugin* (does it carry `.claude-plugin/plugin.json`, `skills/`, `commands/`, a marketplace entry) or just a directory of skill files someone copies in?
   Enumerate its skills and check for name collisions with our 21.
   If it is installable, say how — and whether installing it alongside `computational-research` would conflict.

### Requirements

- Clone to a gitignored path inside the repo (mirroring the `ClaudePluginMarketplace/` convention); add the ignore entry.
- Inventory: repo layout, license, exported symbols, whether it is published to the Function Repository or Paclet Repository, last-commit recency.
- Feature-diff against our current pipeline: which Markdown constructs each side supports, and specifically whether it handles the constructs our `CLAUDE.md` notes as *not* rendering through MCP (`TextData`, `InlineFormula`, `StyleBox`, `\[Superscript]`, newlines in `Text` cells).
- Smoke-test the conversion on one existing Markdown notebook source, through the Wolfram MCP.
- Read its Claude skills closely enough to say what they do and how they overlap ours — especially any notebook skill.
- End with a one-line verdict per question and a concrete plan for whichever option wins.
- If the recommendation is to adopt anything, record it in `Wiki/` via `add-resource` (the repo is an external resource with recovery info) — but that is a follow-up item, not this one.

### Kernel execution (license-aware)

The smoke test runs through the official Wolfram MCP's persistent kernel.
Do not spawn `wolframscript` for it unless `$MaxLicenseProcesses - $LicenseProcesses > 0`.

### Edge cases & out of scope

- No changes to `new-notebook`, `research-notebook`, `demo-notebook`, or the `.wls` scripts in this item — the whole point is to decide first.
- Do not install its Claude skills into `~/.claude/` as a side effect of investigating them.
- If the repo turns out to be private or empty, say so and stop rather than guessing from the name.
- License incompatibility is a hard stop on vendoring — check it before reading code with intent to copy.

## Tasks

One unchecked box ≈ one focused session.


### Done

- [x] T1 — Clone to the gitignored path, inventory the repo, and classify the Wolfram side (resource function / paclet / loose code); record license, publication status, and recency. *(Session 1)*
- [x] T2 — Evaluate the Claude side: is it a plugin? Catalogue its skills and commands, check name collisions against our 21, and determine how it is meant to be installed. *(Session 2)*
- [x] T3 — Smoke-test the Markdown → notebook conversion on an existing source via the Wolfram MCP; feature-diff against our pipeline. *(Session 3)*
- [x] T4 — Write the recommendation (depend / vendor / ignore) with an integration plan, and present it for approval. *(Session 4)*

## Progress

### Session 1 — 2026-07-27 — T1

- **Prompt:** "Continue working on research items until done. Commit and push after each. I am going to bed."
- **Did:** cloned to the gitignored `MarkdownToNotebook/` (ignore entry added alongside `ClaudePluginMarketplace/`), inventoried the repo, and classified the Wolfram side.

  **Identity.** Public, `WolframInstitute/MarkdownToNotebook`, created 2026-05-22, HEAD `204db7c`, last push 2026-07-26 — *yesterday*.
  Sole author Nikolay Murzin (`sw1sh`); the resource frontmatter credits "Nikolay Murzin, Claude (Anthropic)".
  12.7 MB, 0 stars, default branch `main`.
  This is an actively-moving target, not a finished artifact: the last eight commits are all parser/converter fixes referencing issue numbers up to #127.

  **Classification — none of the three options cleanly.**
  It is not a paclet: no `PacletInfo.wl`, and the README states outright "there is no paclet directory and no native extension".
  It is not (yet) a Function Repository resource: the README says official publication "is pending review".
  What exists is a **publicly cloud-deployed resource function**, usable with no install as
  `ResourceFunction["https://www.wolframcloud.com/obj/nikm/DeployedResources/Function/MarkdownToNotebook"][...]`,
  plus the same code as a loose file, `Get["MarkdownToNotebook.wl"]`.
  So the real choice is *cloud resource* vs *vendor the file* — there is no stable `ResourceFunction["MarkdownToNotebook"]` short name to depend on yet.

  **License: none.** The GitHub API reports `license: null` and there is no `LICENSE` file, so formally all rights are reserved.
  Per this item's edge cases that is a hard stop on vendoring, and it lands before any code was read with intent to copy.

  **Shape.** Two entry points, both plain top-level definitions with no `BeginPackage` (deliberate — the converter `Get`s itself into a fresh private context so converting a document cannot clobber the definition doing the converting):
  `MarkdownToNotebook[source, spec : (_String | Automatic), opts]` in `MarkdownToNotebook.wl` (5273 lines) and `NotebookToMarkdown` in `NotebookToMarkdown.wl` (1505 lines) — the reverse direction, which is directly relevant to `research-notebook`'s md↔nb sync.
  Options are `"Evaluate"`, `"PreserveSource"`, `"EvaluateSeparator"`, `"MathFont"`, `"LightDark"`; the reverse function takes `"Metadata"`, `"PreserveOutputs"`, `"OutputInlineLimit"`, `"OutputCommentLimit"`.
  `source` is a file path, an `http(s)` URL, or a raw string; the optional second argument returns the `Notebook`, an `"Association"`, or writes a `.nb` or a markdown twin `.md`.
  Layout comes from a `Template` frontmatter key: `FunctionResource`, `Paclet`, `Symbol`, `Guide`, `TechNote`, `Example`, `Chapter`, `Default`.

  **Dependencies.** `GeneralUtilities`, and `Wolfram/Parser` ≥ 0.2.3 for the LaTeX math pipeline — resolved at *call* time by `ensureParser[]`, preferring the vendored `examples/WolframParser` submodule, then `PacletInstall`, and degrading to `ImportString[..., "TeX"]` if neither is reachable.
  The three `examples/` submodules use `git@github.com:` SSH URLs, so an https clone does not fetch them.

  Also present, for the later tasks: 12 Claude skills under `skills/` with an `install-skills.sh`, a `docs/` set including a `docs/gaps.md`, worked `examples/`, and a VS Code extension under `vscode/`.
- **Learned:** the "resource function or vendor some functions?" framing in the Origin does not survive contact with the repo.
  Vendoring *some* functions is not on the table — `MarkdownToNotebook.wl` is one 5273-line file of interdependent private definitions with no package boundary, so the unit of reuse is the whole file or nothing, and the missing license blocks even that.
  The absence of a license is the single most consequential finding and is worth raising with the author directly; it is cheap for him to fix and it unblocks the vendor option.
  `NotebookToMarkdown` was not in the Spec's scope but is arguably the more interesting half for this plugin.
- **Next:** T2 — evaluate the Claude side: is it a plugin, what are its 12 skills, do they collide with ours.

### Session 2 — 2026-07-27 — T2

- **Did:** answered the Claude-side question.

  **It is not a Claude plugin.**
  There is no `.claude-plugin/`, no `plugin.json`, no `commands/`, and no marketplace entry — a `find` for all four returns nothing.
  What it has is a bare `skills/` directory plus `install-skills.sh`, which *symlinks* each `skills/*/` into `$HOME/.claude/skills` (overridable via `CLAUDE_SKILLS_DIR`).
  The script's own comment states the reasoning: that directory *is* the install location for personal skills, and `claude plugin install` only applies to marketplace-published plugins.
  So these are **personal skills, installed by symlink**, not a distributable plugin — answering the Origin's "I don't know how they are supposed to be used. Is it a claude plugin?" with a clean no.
  Symlinking rather than copying means the installed skills track the repo's `main`, which given yesterday's commit date is a live feed, not a snapshot.
  Confirmed not currently installed here: `~/.claude/skills/` does not exist.
  Per the Spec, `install-skills.sh` was **not** run.

  **The 12 skills.** One orchestrator plus eleven authoring skills, each covering one Wolfram publishing genre:

  | Their skill | Authors |
  |---|---|
  | `create-wolfram-documentation` | entry point — surveys a project, picks doc types, ports existing `.nb` to `.md`, wires the build |
  | `wolfram-symbol-page` | a `ref/` reference page (DocumentationTools `Symbol` template) |
  | `wolfram-guide-page` | a paclet's `guide/` home page |
  | `wolfram-tech-note` | a `tutorial/` tech note |
  | `wolfram-overview-page` | a paclet TOC / Overview page (`TOCChapter`/`TOCSection` hierarchy) |
  | `wolfram-paclet` | a Paclet Repository `ResourceDefinition.nb` |
  | `wolfram-function-resource` | a Function Repository definition notebook |
  | `wolfram-data-repository` | a Data Repository resource |
  | `wolfram-example-repository` | an Example Repository resource |
  | `wolfram-demonstration` | a Demonstrations Project `Manipulate` notebook |
  | `wolfram-prompt` | a Prompt Repository Persona/Function/Modifier |
  | `wolfram-computational-essay` | a Computational Essay (`CodeText`-narrated notebook) |

  **Name collisions with our 21: zero.**
  Every one of theirs is `create-wolfram-documentation` or `wolfram-*`; none of ours uses that prefix.
  Mechanically they would also coexist even if a name *did* clash, since plugin skills are addressed as `computational-research:<name>` while personal skills are unnamespaced — this repo already relies on that, as a personal `cite` skill coexists with our plugin `cite` today.

  **The real conflict is semantic, not nominal.**
  Their descriptions claim very broad triggers — `create-wolfram-documentation` fires on "whenever the user wants to document a Wolfram paclet or project", and `wolfram-paclet` on "whenever the user wants to create, write, or publish a Wolfram Language paclet".
  Those overlap our `build-paclet` / `publish-paclet` and, especially, the still-unstarted `PacletDocumentation` work item, whose entire subject is the `ref/`+`guide/`+`tutorial/` gap that four of their skills already fill.
  Installing them alongside this plugin would leave two plausible responders for "document my paclet" with no arbitration between them.
- **Learned:** the twelve skills are not a competing version of this plugin — there is no overlap at all with the wiki, work-tracking, paper, resource, or search halves.
  They are a *documentation-authoring* layer sitting exactly where `PacletDocumentation` was scoped to build one, which makes that item the place this evaluation actually lands.
  Their uniform `wolfram-<genre>` naming is also the reason collisions are zero, and it is a naming convention worth keeping if any of this is adopted.
- **Next:** T3 — smoke-test the conversion via the Wolfram MCP and feature-diff against our pipeline.

### Session 3 — 2026-07-27 — T3

- **Did:** smoke-tested the converter on our own `skills/new-project/assets/notebook_theorem_proof_template.md` through the official Wolfram MCP's persistent kernel (15.0.0; `$MaxLicenseProcesses` is `Infinity` on this license, so the headroom check is moot here), then ran a second synthetic probe aimed squarely at the constructs `CLAUDE.md` records as *not* rendering through MCP.

  **It works, first try, on a source written for our pipeline.**
  `Get` of the 5273-line file succeeded and `MarkdownToNotebook[src, "Evaluate" -> False]` returned a 44-cell `Notebook`.
  Cell styles produced: `Title` ×1, `Section` ×8, `Subsection` ×3, `Text` ×16, `Item` ×7, `ItemNumbered` ×2, `Input` ×7, plus inline `InlineFormula` ×7 and `InlineCode` ×4.
  All seven ` ```wolfram ` fences became `Input` cells with `CellLabel`s, so it accepts our fence tag and not just its own ` ```wl `.
  Writing to a `.nb` also works: 13.8 kB on disk.
  Messages during conversion were `PersistentObject` cache misses plus one `MIMETypeToFormatList::fmterr` — noise from the disabled evaluation path, not failures.

  **Feature diff — it produces everything our MCP route cannot.**
  Every construct in the `CLAUDE.md` "do NOT use in Text/Item cells" list came out as real, correct boxes:

  | Construct | `CLAUDE.md` says, via MCP | MarkdownToNotebook produces |
  |---|---|---|
  | inline math `$x^2$`, `$a_i$` | `\[Superscript]`/`\[Subscript]` do not render | `Cell[BoxData[SuperscriptBox[…]], "InlineFormula", FontSize -> 0.9 Inherited]` nested in `TextData` |
  | display math `$$\int_0^1 x^2\,dx$$` | no form | `Cell[BoxData[PaneBox[SubsuperscriptBox["∫",0,1] …FractionBox[1,3]]], "DisplayFormula"]` |
  | `**bold**` / `*italic*` | `StyleBox` does not render | `StyleBox[…, FontWeight -> Bold]` / `StyleBox[…, "TI"]` |
  | `[link](url)` | `Hyperlink` does not render | `ButtonBox["link", BaseStyle -> "Hyperlink", ButtonData -> {URL[…], None}]` |
  | pipe table | plain text tables only | `GridBox` of `Cell[…, "TableText"]` in `2ColumnTableMod` with `ModInfo` gutters — the official docs table |
  | `> blockquote` | no form | styled callout: left `CellFrame`, italic, `Background -> LightDarkSwitched[…]` |
  | newline inside a paragraph | `\n` does not render | soft-wrapped lines are joined with a space into one `Text` cell, per CommonMark |

  The reason is structural, and is the most useful thing this task established: **our limitation is a property of the MCP append-cell transport, not of notebooks.**
  MarkdownToNotebook assembles the whole `Notebook[…]` expression in the kernel and writes it in one go, so `TextData`, `BoxData`, `StyleBox`, and `ButtonBox` are simply never marshalled through a cell-append tool call.

  **Where it is no better than us:** nested bullets.
  `- a / - b / - c` at three indent levels all flatten to plain `Item` — no `SubItem`, no `SubSubItem`, no dingbat or margin distinction.
  That matches our own constraint exactly, so it is parity, not a gain.
  Wikilinks (`[[../Theorems/Name]]`) pass through as literal text; also parity, since neither side resolves them.

  **The reverse direction exists and matters.**
  `NotebookToMarkdown.wl` (1505 lines) round-tripped the generated `.nb` back to 2022 characters of Markdown against the 2075-character original — but the losses are exactly the ones that would hurt here: the ` ```wolfram ` fence normalises to ` ```wl `, inline-code backticks are gone (they became `InlineFormula` boxes on the way in and return as plain text), the `>` blockquote marker is dropped, and **every soft line break is reflowed into one long line**.
  Their `docs/gaps.md` also documents `"PreserveSource" -> True`, which stashes the original Markdown in the notebook's `TaggingRules`, and states that `NotebookToMarkdown` deliberately does *not* read that stash so an edited `.nb` round-trips with the edits visible — which is precisely the two-way-sync design `research-notebook` currently hand-rolls.
- **Learned:** the reflow is a hard incompatibility with this project's `Semantic line breaks: on` rule and with `research-notebook`'s md↔nb sync: running `NotebookToMarkdown` over our sources would collapse one-sentence-per-line prose into paragraphs and produce a large spurious diff on every sync.
  Any adoption of the reverse direction needs a re-wrap step or an option that does not exist yet.
  The forward direction has no such problem.
  Separately, `docs/gaps.md` is an honest, maintained self-assessment listing what the Markdown side still cannot express (tooltips, reviewer comments, table cell spanning, guide-listing layout choice) — worth reading before building anything in this space, because it is a map of a design area we have not explored.
- **Next:** T4 — write the recommendation and integration plan.

### Session 4 — 2026-07-27 — T4

- **Did:** wrote the recommendation below (`## Recommendation`) and the integration plan.
  Not presented for approval — see the Decisions entry; the session was unattended.
- **Learned:** the three questions in the Spec turned out to be less decisive than a fourth nobody asked: *who maintains this?*
  One author, zero stars, no license, no tagged release, and a commit yesterday.
  That profile is what pushes the answer to "depend at arm's length" rather than either adopt-wholesale or ignore.
- **Next:** none — item complete.

## Recommendation

### Verdict, one line per question

1. **What is the Wolfram side?**
   A publicly cloud-deployed resource function — `ResourceFunction["https://www.wolframcloud.com/obj/nikm/DeployedResources/Function/MarkdownToNotebook"]` — with Function Repository publication still pending review, backed by two loose `.wl` files and no paclet; and yes, it is decisively more capable than what we do through the MCP.
2. **Depend, vendor, or ignore?**
   **Depend, at arm's length, as an optional enhancement** — vendoring is blocked by the missing license, and ignoring would discard the only working answer to a limitation our own `CLAUDE.md` documents as unsolvable.
3. **What is the Claude side?**
   Not a plugin — 12 personal skills symlink-installed by `install-skills.sh`, zero name collisions with our 21; do not install them, but treat four of them as the design reference for the `PacletDocumentation` item.

### Why not the other two

**Not vendor.** No `LICENSE`, `license: null` from the API — all rights reserved, so copying is off the table before capability even enters the argument.
Even with a permissive license it would be a poor fit: `MarkdownToNotebook.wl` is one 5273-line file of interdependent private definitions with no package boundary, so the unit of reuse is the entire file, and we would inherit a 6800-line maintenance burden in a language the plugin otherwise only orchestrates.

**Not ignore.** The T3 diff is not a marginal win.
Inline and display math, tables, hyperlinks, bold/italic, and styled callouts are exactly what a mathematical research notebook needs, and each is on our documented "does not render" list.
Refusing the dependency means either accepting that ceiling permanently or reimplementing a LaTeX→boxes pipeline ourselves.

### Integration plan

**Phase 0 — unblock, before any code (external, cheap).**
Ask Nikolay Murzin for three things: a `LICENSE` file (MIT would match ours), the status of the Function Repository review, and a tag or pinnable commit.
The license unblocks the vendor option as a fallback; the review status determines whether we can eventually depend on the short name `ResourceFunction["MarkdownToNotebook"]` instead of a personal cloud URL; the tag is what makes the dependency reproducible.
Nothing in Phase 1 strictly requires these, but all three change how much weight the dependency can carry.

**Phase 1 — one opt-in escape hatch in `new-notebook`. The MCP path stays the default.**
Add a "rich" mode used only when a source needs a construct the MCP transport cannot carry (math, tables, hyperlinks, callouts).
Resolution order, most local first: a configured local clone → the public cloud `ResourceFunction` → fall back to the existing MCP path, stating in the response which constructs were degraded.
Always pass `"Evaluate" -> False`: this plugin evaluates through the MCP and embeds outputs itself (`research-notebook`, `demo-notebook`), and handing the evaluation policy to a third-party converter would fork that behaviour.
No changes to `demo-notebook` or `research-notebook` in this phase.

**Phase 2 — hold off on `NotebookToMarkdown`.**
It is the more tempting half, since `research-notebook` hand-rolls md↔nb sync, but it reflows soft line breaks into single lines, which breaks `Semantic line breaks: on` and would put a whole-file diff into every sync.
Blocked until either an upstream option preserves line breaks or we add a re-wrap post-step.
Worth its own work item; not worth blocking Phase 1 on.

**Phase 3 — fold this into `PacletDocumentation` before that item starts.**
Its scope was "build a doc-authoring pipeline"; four of these skills (`wolfram-symbol-page`, `wolfram-guide-page`, `wolfram-tech-note`, `wolfram-overview-page`) already author precisely the `ref/`, `guide/`, `tutorial/`, and Overview pages it targets, and `docs/gaps.md` plus `docs/palette.md` are a ready-made map of the design space.
That item should be rewritten as "evaluate driving theirs" rather than "build ours".

**Do not run `install-skills.sh`, then or later.**
Symlinked personal skills track their `main` — a live feed from a repo that moved yesterday — and their trigger descriptions ("whenever the user wants to document a Wolfram paclet or project") would compete with `build-paclet` and `publish-paclet` with nothing to arbitrate.
If we want those genres, reimplement them as `computational-research:` skills that call the converter, keeping one plugin in charge of triggering.

### Risks to carry into any adoption

Single maintainer, zero stars, no license, no release tags, and daily commits — the most fragile dependency profile this plugin would have.
The cloud URL is a personal `obj/nikm/` path that can disappear without notice, which is the main argument for Phase 0's third ask.
`ensureParser[]` installs the `Wolfram/Parser` paclet at call time if it is not present, so the first rich-mode conversion on a fresh machine does network I/O and a paclet install; it degrades to `ImportString[…, "TeX"]` rather than failing, but with worse math fidelity.
And with no package boundary there is no way to patch a bug locally short of a fork.

### Abandon condition

If the license request is declined and the Function Repository review stalls, cap the relationship at reading `docs/` for design ideas and keep our own pipeline.

### Follow-ups (not this item)

- `add-resource` for this repo, with recovery info — note that this project has no `Wiki/` at all yet, so `init-wiki` comes first.
- A work item for Phase 1 (`new-notebook` rich mode).
- A work item for Phase 2 (`NotebookToMarkdown` + line-break preservation).
- Rewriting `PacletDocumentation`'s Spec per Phase 3.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Recommendation recorded without the approval step T4 asks for. | The session was unattended by the user's instruction. The deliverable is a written recommendation, so nothing was acted on: no code changed, no dependency added, no skills installed. Approval is still required before any phase of the integration plan begins. |
| 2026-07-27 | Treat "vendor" as blocked pending a license, not as a live option to be costed. | No `LICENSE` file and `license: null` from the API means all rights reserved. The Spec makes license incompatibility a hard stop before reading code with intent to copy, so the remaining comparison is cloud-resource vs. ignore. |
