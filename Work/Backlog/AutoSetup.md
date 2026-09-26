# Automatic setup

*[ LLM Generated ]*

> Type: feature
> Waiting on: you — a `/refine` sitting on the Summary, Motivation and Acceptance criteria, and the open questions.
<!-- Status is the folder: Backlog/ Ready/ Active/ UnderReview/ Done/ Dropped/. Move the file to change it. -->

## Summary

A new user runs one command, says which parts they want, and the plugin installs them and checks that they work.
It covers the Wolfram and arXiv servers, Lean, and LaTeX or Typst.

## Motivation

- Today a new user reads a table of servers and installs each one by hand.
- The steps differ between servers and between machines, and a missed one shows up only later, as a skill that fails.
- The environment check looks for the wrong Wolfram server, so it cannot confirm that a setup worked.

## Acceptance criteria

The README's *Setup* section and its first goal are true:

- One command asks what the user wants and shows the plan before installing anything.
- It installs the chosen servers and tools, and leaves alone what is already there.
- For Wolfram Engine or Mathematica, which need an account, it links the download and waits.
- It checks free license seats before starting a kernel.
- It ends by checking that each part answers, and says what works and what does not.
- A second run changes nothing and says so.

## Prompt history

- 2026-09-26 — "Actually i think we need some setup skill that downloads and installs all this stuff the mcp servers and so on based on user preferences - this should be then also in goals Autosetup plugin..."

## Technical details

### Requirements

- Installs without an account: the official Wolfram MCP through `InstallMCPServer`, the two arXiv servers, the `lean-lsp` server, and the optional unofficial Wolfram server.
- Installing the Wolfram server runs a kernel, so headroom is checked first, per the kernel policy.
- Verification reuses the checks of `check-env`.

### Edge cases & out of scope

- Windows, until someone tests it.
- Installing Wolfram Engine or Mathematica itself.
- API keys or accounts for any service.
- `check-env.sh` looks for an npm `wolfram-mcp` package and a `wolfram-mcp` binary, while the official server is the AgentTools paclet configured in `~/.claude.json`; it also tests with the unofficial server's `ping` tool. Correcting it is part of T3.
- The `WolframLanguage` profile of the official server lacks the symbol-page tools `paclet-docs` needs; the setup must offer the profile that has them.

### Open questions

1. Where the user's choices are kept, so a second run and `check-env` know them: the global settings, the project's `CLAUDE.md`, or nowhere.
2. Whether `check-env` becomes the verification half of `setup` or stays a separate command.
3. Which installer each server needs on macOS and Linux today (`uv`, `npm`, a paclet) — T1 answers it, but the list of choices offered is yours.

## Tasks

- [ ] T1 (model: opus, effort: xhigh — design-critical) — survey how each dependency installs today, answer the open questions in a `Wiki/Concepts/AutoSetup.md` article, and correct the Technical details where they guessed.
- [ ] T2 (human) — operator rules on the design and the list of choices offered.
- [ ] T3 (model: opus, effort: xhigh — cross-cutting) — implement the skill, the command and any script, and correct `check-env` to find the official server.
- [ ] T4 (human) — trial on a machine or user account with nothing installed.
- [ ] T5 (model: sonnet, effort: high — doc pass) — README (the *Setup* section: link the skill in its table, replace the manual install line), ARCHITECTURE, the blog post, and a version bump.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item; nothing in flight.

## Decisions

| Date | Decision | Rationale |
|---|---|---|

## Progress

- **S0** 2026-09-26 — item filed from the operator's request; draft awaiting `/refine`.
