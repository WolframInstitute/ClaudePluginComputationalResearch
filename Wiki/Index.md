# Wiki Index

Knowledge base for ComputationalResearch — the plugin itself, not a research project.
Updated after each substantial step.

The plugin's architecture — skills, scripts, commands, templates — is documented in [CLAUDE.md](../CLAUDE.md) and [README.md](../README.md), not mirrored here.
This wiki carries what those two files are the wrong place for: external dependencies and their recovery info, and cross-cutting concepts.

## Status

- [Status](Status.md) — current state

## Work

Execution state (specs, tasks, per-session progress) lives in the top-level `Work/` folder, not the Wiki.
See [Work/README.md](../Work/README.md).

## Concepts

- [Session Information Budget](Concepts/SessionInformationBudget.md) — what a `next-session` run must read before it can work, measured from git history
- [Progress vs Wiki](Concepts/ProgressWikiSplit.md) — where the durable knowledge actually is: ~53 kB in `## Progress`, 6.6 kB harvested, and what the misplacement costs to read
- [The work item file format](Concepts/ItemFileFormat.md) — the five sections, the one-fact-one-destination rule, and why `## Progress` is one line per session and read by nobody

## Resources

- [MarkdownToNotebook](Resources/MarkdownToNotebook.md) — Markdown→notebook converter backing `new-notebook`'s rich mode; pinned by SHA
