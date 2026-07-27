# Status

## Current state

Wiki initialized 2026-07-27, during `AdoptMarkdownToNotebook` T4.
Scope is deliberately narrow: external dependencies and cross-cutting concepts.
Plugin architecture stays in `ARCHITECTURE.md` / `README.md` so there is only one copy to keep current.

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
That loop is now built: `scripts/auto-run.sh` behind `/auto-run`, with the deferred gate in `revise` § *Autonomous mode* and the `> Autonomous: allowed` / `(human)` markers in `work`.
Every stop condition fires as specified against a stub `claude` in a fixture repo, and on 2026-07-28 the loop was trialled live on the throwaway item `AutoRunTrial`: two real wiki-prose tasks landed unattended, at $1.54 and $2.60, with zero permission denials on the default allowlist.
That trial found three defects a stub could not — a session cannot tell it is headless and has to be told, the caps had to move ahead of the `(human)` gate, and the digest was reporting a 1.01 M-token task as 30 tokens — all fixed and re-verified live.
It also priced the loop: per-task cost tracks turn count, not cold start, so the 31.5 k-token preamble is ~3 % of a real task and the `$5.00` default cost cap, not `--max-tasks 3`, is what actually bounds a run.
What remains untested is failure — `needs-human`, the liveness pair, and `permission-denied` have still only ever fired against a stub.
That run also exposed the one thing a stub could not: a headless session cannot observe that it is headless, and recorded in `## Hand-off` that it had run interactively.
The driver now states its own autonomy in `--append-system-prompt`, because absence of a user is not inferable from inside a session.
The trial's real input was ~1.01 M tokens, almost all cache reads, which puts the 31 k cold start in proportion: it is a small term inside a real task, not the dominant one.
Building it also re-measured the cold start at 31,187 input tokens against 31,479 before the preamble split — T6's 11.6 kB cut moved it ~1 %, so the pipeline's per-task floor is set by the configured MCP tool schemas, not by `CLAUDE.md`.

Operating that loop is now written down — see [The `/auto-run` operator runbook](Concepts/AutoRunOperations.md).
It is the practical half of the pipeline article: the stop-reason table read as instructions, how to grow the allowlist from a `permission-denied` halt, and why an `auto/<Item>` branch must be reviewed before the next run rather than after several.
Writing it against the script rather than the specification surfaced five small divergences — selection globs `Work/Active/` instead of reading the index, the `(human)` marker matches anywhere in a task line, `unparseable-output` quotes 1 kB of stdout plus 1 kB of stderr rather than 2 kB, `item-vanished` and `interrupted` are missing from the documented stop reasons, and exit codes are four-valued (`2` for preflight, which writes no digest, and `130` for an interrupt).
All five have since been reconciled into the pipeline article, so the two agree; the standing rule is that the script is the fact and the article is what gets corrected.

That preamble has now been cut — see [Preamble audit](Concepts/PreambleAudit.md).
Of this repo's 16.9 kB `CLAUDE.md`, 47 % was inventory: the Skills table was a third copy of content the harness already injects as 9.6 kB of skill descriptions, and the tables had drifted anyway (headings claimed 20 skills and 21 commands against 21 and 22 on disk) while consuming 18 of the file's 26 commits.
Inventory and reference moved to a read-on-demand `ARCHITECTURE.md`; `CLAUDE.md` is 5.3 kB and keeps only policy, taking the fixed preamble from 27.9 kB to 16.3 kB.

The `CLAUDE.md` the plugin *generates* has now had the same test — see [Generated preamble audit](Concepts/GeneratedPreambleAudit.md).
It came out 82 % policy before any cut, and the 7.2 kB code-style block that T6 flagged as the obvious suspect on size is fully justified by the test: nothing prompts a session to look up a style guide, and a violation is invisible afterwards.
The defects were in the small sections instead — `## Work` was a third copy of the `Work/README.md` every scaffold also writes, and the math template reproduced the deleted Skills table in miniature.
The finding worth the task is a **contradiction**: the user's global `~/.claude/CLAUDE.md` forbids comments unless asked while the template mandates a one-line summary per exported symbol, both auto-loaded, with no precedence stated. The template now states it.
Cutting the two duplicates saved only 230 B / 582 B, and the pipeline's ~1 %-per-11.6 kB result says a saving that size is not measurable — so the generated preamble is closed as audited, with the cuts justified as correctness rather than cost.

## Recent changes

- 2026-07-28 — Audited the *generated* project `CLAUDE.md` (T9): 82 % policy already, the code-style block exonerated, and a contradiction between two auto-loaded files fixed; see [Generated preamble audit](Concepts/GeneratedPreambleAudit.md).
- 2026-07-28 — Closed the throwaway trial item `AutoRunTrial` by doing its gated task interactively: `/auto-run` stays in `README.md`'s user-facing command list, with the row now naming the human review and merge that the deferred `revise` gate depends on.
- 2026-07-28 — Reconciled [the pipeline specification](Concepts/AutonomousPipeline.md) with `scripts/auto-run.sh` on all five divergences the runbook found, and recorded what the first real autonomous run established — including that a headless session cannot detect its own headlessness.
- 2026-07-28 — Wrote the `/auto-run` operator runbook against the script as built, recording five places it departs from its specification; see [The `/auto-run` operator runbook](Concepts/AutoRunOperations.md).
- 2026-07-28 — Trialled the autonomous pipeline live (T8) on the throwaway `AutoRunTrial`; two tasks landed, three defects fixed, and the loop's real per-task price measured for the first time.
- 2026-07-28 — Built the autonomous pipeline: `scripts/auto-run.sh`, `/auto-run`, `revise`'s autonomous mode, and the two eligibility markers; stop conditions verified against a stub, not yet against a real item.
- 2026-07-28 — Audited the auto-loaded preamble and split `CLAUDE.md` (−69 %) into policy plus a read-on-demand `ARCHITECTURE.md`; see [Preamble audit](Concepts/PreambleAudit.md).
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
