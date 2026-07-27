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

The item file format that follows from those two measurements is now decided and in force — see [The work item file format](Concepts/ItemFileFormat.md).
Five sections and no others: `## Spec`, `## Tasks`, a new overwritten `## Hand-off`, `## Decisions`, and a `## Progress` that is one line per session and read by nobody.
One fact, one destination — filing to `Wiki/` discharges the obligation to narrate the fact in Progress.
With Progress out of the read path, `## Spec` and `## Decisions` turn out to be 70–95 % of what a session opens, so both are now bounded: the Spec is corrected in place rather than amended, and a reversal edits the `Decisions` row it reverses.
`next-session` lost its partial-read rule (the format makes the read flat) and its 2.3 kB paclet-worktree procedure, which moved to a read-on-demand sibling — the file is 613 B smaller than before despite gaining the rules.

The unattended loop over that format is now specified — see [The autonomous next-session pipeline](Concepts/AutonomousPipeline.md).
None of the harness schedulers can drive it: `CronCreate`, `/loop`, and background tasks all enqueue into the running session, so context accumulates rather than clearing.
One headless `claude -p` per task is the only mechanism that starts genuinely cold, and it costs a measured 31,479 input tokens of preamble each time — which puts T6's `CLAUDE.md` audit ahead of implementation rather than after it.
`revise`'s human gate is deferred rather than dropped: autonomous work lands on `auto/<Item>`, a gitignored per-run digest is the "present" step, and the human's merge is the "approve".
Eligibility is opt-in and fail-closed, and the driver verifies each run by new commit plus newly checked box — because an unprefixed plugin slash command headless is a zero-cost no-op that reports success.

## Recent changes

- 2026-07-27 — Specified the autonomous pipeline in [The autonomous next-session pipeline](Concepts/AutonomousPipeline.md); rejected all three harness schedulers as drivers and deferred the `revise` gate to a branch plus digest.
- 2026-07-27 — Decided the work item file format in [The work item file format](Concepts/ItemFileFormat.md) and revised `work`, `next-session`, and the templates to match.
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
