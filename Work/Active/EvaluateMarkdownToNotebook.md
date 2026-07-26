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

- [ ] T2 — Evaluate the Claude side: is it a plugin? Catalogue its skills and commands, check name collisions against our 21, and determine how it is meant to be installed.
- [ ] T3 — Smoke-test the Markdown → notebook conversion on an existing source via the Wolfram MCP; feature-diff against our pipeline.
- [ ] T4 — Write the recommendation (depend / vendor / ignore) with an integration plan, and present it for approval.

### Done

- [x] T1 — Clone to the gitignored path, inventory the repo, and classify the Wolfram side (resource function / paclet / loose code); record license, publication status, and recency. *(Session 1)*

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

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-27 | Treat "vendor" as blocked pending a license, not as a live option to be costed. | No `LICENSE` file and `license: null` from the API means all rights reserved. The Spec makes license incompatibility a hard stop before reading code with intent to copy, so the remaining comparison is cloud-resource vs. ignore. |
