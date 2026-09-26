# AutoSetup

*[ LLM Generated ]*

> Type: feature
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: "Actually i think we need some setup skill that downloads and installs all this stuff the mcp servers and so on based on user preferences - this should be then also in goals Autosetup plugin..." (2026-09-26, operator.)

Today a new user reads the README's server table and installs each piece by hand.
The deliverable is a `setup` skill and command that asks what the user wants, installs it, and checks that it answers.

### Requirements

- **Ask first.** The skill asks which parts the user wants — the client (Claude Code or Desktop), the optional servers, Lean, LaTeX or Typst — and shows the plan before it installs anything.
- **Detect before installing.** Whatever is already present is reported and left alone.
- **Install what can be installed without an account:** the official Wolfram MCP through `InstallMCPServer`, the two arXiv servers, the `lean-lsp` server, and the optional unofficial Wolfram server.
- **Guide what cannot:** Wolfram Engine or Mathematica needs a Wolfram account and a license, so the skill links the download and waits.
- **Respect the license seats.** Installing the Wolfram server runs a kernel; the skill checks headroom first, per the kernel policy.
- **Verify at the end** through the same checks as `check-env`, and report what works and what does not.
- **Idempotent.** A second run changes nothing and says so.

### Design questions for T1

- Where the user's choices are kept, so a second run and `check-env` know what was chosen — the global settings, the project's `CLAUDE.md`, or not at all.
- How each server is installed on macOS and Linux today, and which installer each one needs (`uv`, `npm`, a paclet).
- Whether `check-env` becomes the verification half of `setup` or stays separate.
- `check-env.sh` still looks for an npm `wolfram-mcp` package, while the official server is a paclet; confirm and correct.

### Out of scope

- Windows, until someone tests it.
- Installing Wolfram Engine or Mathematica itself.
- Configuring API keys or accounts for any service.

## Tasks

- [ ] T1 (model: opus, effort: xhigh — design-critical) — survey how each dependency installs today, answer the design questions in a `Wiki/Concepts/AutoSetup.md` article, and correct this Spec where it guessed.
- [ ] T2 (human) — operator rules on the design and the list of choices offered.
- [ ] T3 (model: opus, effort: xhigh — cross-cutting) — implement the skill, the command and any script, reusing `check-env` for verification.
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

- **S0** 2026-09-26 — item filed from the operator's request; draft Spec awaiting approval.
