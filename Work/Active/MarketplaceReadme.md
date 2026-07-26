# MarketplaceReadme

*[ LLM Generated ]*

> Type: refactor

## Spec

Origin: "I want you to make a super simple readme for the marketplace github page which just links the comptuationl research plugin"

`WolframInstitute/ClaudePluginMarketplace` currently tracks exactly one file, `.claude-plugin/marketplace.json` — there is **no** `README.md`, so the GitHub landing page is bare.
Add a minimal one: what the marketplace is, the two commands to add it and install the plugin, and a link out to the plugin repo.
Everything substantive stays in the plugin's own repo; this page is a signpost.

### Requirements

- One screen — target under 25 lines.
- The two `claude plugin` commands, copy-pasteable, matching what the plugin README already documents.
- A single-row table (or one bullet) linking to `WolframInstitute/ClaudePluginComputationalResearch`, with a one-line description — **not** the 90-word `marketplace.json` description.
- Link the blog post once, as further reading.
- Note the Claude Desktop GUI path in one line, since not everyone uses the CLI.
- MIT license line.
- Do **not** duplicate the skill/command tables, the MCP setup, or the disclaimer — those belong to the plugin repo.

### Design

```
# Wolfram Institute — Claude Plugins

<one sentence>

    claude plugin marketplace add WolframInstitute/ClaudePluginMarketplace
    claude plugin install computational-research@WolframInstitute

(Claude Desktop: install from the marketplace GUI.)

## Plugins

| Plugin | Description |
| computational-research | ... → link |

## License
MIT
```

### Edge cases & out of scope

- Do **not** edit `marketplace.json` in this item — no version bump, no description rewrite.
- Do **not** touch the plugin repo's own `README.md` — that is `DeclutterReadme`.
- The local clone is at the gitignored `ClaudePluginMarketplace/`; it is present and on `main` at `731a941`. Pull before editing in case the remote moved.
- Pushing to the marketplace repo is outward-facing: present the README for approval and confirm before `git push`.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T1 — Pull the marketplace clone, draft the README, present it, then commit and push on approval.

### Done

(completed tasks move here with the session that closed them)

## Progress

(no sessions yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|
