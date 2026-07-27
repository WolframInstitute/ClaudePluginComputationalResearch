# Status

## Current state

Wiki initialized 2026-07-27, during `AdoptMarkdownToNotebook` T4.
Scope is deliberately narrow: external dependencies and cross-cutting concepts.
Plugin architecture stays in `CLAUDE.md` / `README.md` so there is only one copy to keep current.

`new-notebook` has two conversion engines.
The built-in WL Markdown importer handles plain sources; the rich engine — [MarkdownToNotebook](Resources/MarkdownToNotebook.md) at a pinned SHA — handles sources with YAML frontmatter or LaTeX math.
Engine choice is auto-detected from the source, and falls back to the built-in engine whenever the clone is absent.

`research-notebook` uses the rich engine too, but only as the **parser half** of a two-half pipeline: the converter produces the cells, then `scripts/mathnotebook_post.wl` applies the MathNotebook environments, the equation numbering, and the citations.
The converter supplies none of those itself — see [MarkdownToNotebook](Resources/MarkdownToNotebook.md) for what it lacks and why the split is forced.
That skill generates **one-way** and detects `.nb` edits with a per-cell `CellID` fingerprint stored in `TaggingRules`; there is no `.nb` → `.md` transfer anywhere in the plugin.

The per-session cost of the `Work/` + `next-session` system is now measured, not assumed — see [Session Information Budget](Concepts/SessionInformationBudget.md).
The dominant term is the unconditional 27.7 kB of `CLAUDE.md` plus the loaded skill files, which exceeded the item file itself in 21 of 22 measured session starts.
`next-session`'s partial-read rule saves 22 % of item-file bytes and nothing at all before session 4.
No format changes have been made yet — `EvaluateWorkItemsEfficiency` T2 and T3 decide that.

## Recent changes

- 2026-07-27 — Measured the session information budget across all six closed work items; findings and the regeneration script live under `Wiki/Concepts/`.
- 2026-07-27 — Registered [MarkdownToNotebook](Resources/MarkdownToNotebook.md) as a resource and documented `new-notebook`'s rich mode.
- 2026-07-27 — Adopted the rich engine in `research-notebook` as the parser half of a two-half pipeline, and replaced its specced two-way sync with one-way generation plus fingerprint-based edit detection.

## Open questions

- Upstream `MarkdownToNotebook` has no `LICENSE` file and no tags.
  A standing, non-blocking ask for an in-tree licence is open with Nikolay Murzin.
  Adoption is not gated on it — the user confirmed the licence is fine, and pinning by SHA works today.
- The measured budget covers bookkeeping only.
  What a session spends reading the files it actually edits is unmeasured and may be the larger number; no method for capturing it exists yet.
