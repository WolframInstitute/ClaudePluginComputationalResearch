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

## Recent changes

- 2026-07-27 — Registered [MarkdownToNotebook](Resources/MarkdownToNotebook.md) as a resource and documented `new-notebook`'s rich mode.
- 2026-07-27 — Adopted the rich engine in `research-notebook` as the parser half of a two-half pipeline, and replaced its specced two-way sync with one-way generation plus fingerprint-based edit detection.

## Open questions

- Upstream `MarkdownToNotebook` has no `LICENSE` file and no tags.
  A standing, non-blocking ask for an in-tree licence is open with Nikolay Murzin.
  Adoption is not gated on it — the user confirmed the licence is fine, and pinning by SHA works today.
