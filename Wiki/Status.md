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

Where that budget goes is also measured — see [Progress vs Wiki](Concepts/ProgressWikiSplit.md).
About 65 % of `## Progress` prose is durable content that belongs in `Wiki/`, ~53 kB of it across the seven items, against 6.6 kB actually harvested; ~30 kB sits below the tail read at the items' final sessions.
Most of that is a backlog rather than a broken skill — `Wiki/` postdates 21 of the 24 Progress blocks, and all three blocks that could harvest did.
The live defect is that filing to `Wiki/` does not stop the fact being re-narrated in Progress.
No format changes have been made yet — `EvaluateWorkItemsEfficiency` T3 decides that.

## Recent changes

- 2026-07-27 — Audited where the durable knowledge in `Work/` actually belongs; classified all 127 `Learned` claim-lines plus an 18 % sample of `Did`, in [Progress vs Wiki](Concepts/ProgressWikiSplit.md).
- 2026-07-27 — Measured the session information budget across all six closed work items; findings and the regeneration script live under `Wiki/Concepts/`.
- 2026-07-27 — Registered [MarkdownToNotebook](Resources/MarkdownToNotebook.md) as a resource and documented `new-notebook`'s rich mode.
- 2026-07-27 — Adopted the rich engine in `research-notebook` as the parser half of a two-half pipeline, and replaced its specced two-way sync with one-way generation plus fingerprint-based edit detection.

## Open questions

- Upstream `MarkdownToNotebook` has no `LICENSE` file and no tags.
  A standing, non-blocking ask for an in-tree licence is open with Nikolay Murzin.
  Adoption is not gated on it — the user confirmed the licence is fine, and pinning by SHA works today.
- The measured budget covers bookkeeping only.
  What a session spends reading the files it actually edits is unmeasured and may be the larger number; no method for capturing it exists yet.
- The durable share of `## Did` (66.8 %) is extrapolated from an 18 % sample, not classified exhaustively.
  Its 60 kB is too large to hand-classify in one session, so the ~40 kB figure derived from it carries sampling error that the `Learned` numbers do not.
