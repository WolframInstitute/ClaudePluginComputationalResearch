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

- [ ] T1 — Clone to the gitignored path, inventory the repo, and classify the Wolfram side (resource function / paclet / loose code); record license, publication status, and recency.
- [ ] T2 — Evaluate the Claude side: is it a plugin? Catalogue its skills and commands, check name collisions against our 21, and determine how it is meant to be installed.
- [ ] T3 — Smoke-test the Markdown → notebook conversion on an existing source via the Wolfram MCP; feature-diff against our pipeline.
- [ ] T4 — Write the recommendation (depend / vendor / ignore) with an integration plan, and present it for approval.

### Done

(completed tasks move here with the session that closed them)

## Progress

(no sessions yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|
