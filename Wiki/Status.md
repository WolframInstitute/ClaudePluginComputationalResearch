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
Failure has since been tested too, and it moved more than the happy path did — see the paragraph below.
That run also exposed the one thing a stub could not: a headless session cannot observe that it is headless, and recorded in `## Hand-off` that it had run interactively.
The driver now states its own autonomy in `--append-system-prompt`, because absence of a user is not inferable from inside a session.
The trial's real input was ~1.01 M tokens, almost all cache reads, which puts the 31 k cold start in proportion: it is a small term inside a real task, not the dominant one.
Building it also re-measured the cold start at 31,187 input tokens against 31,479 before the preamble split — T6's 11.6 kB cut moved it ~1 %, so the pipeline's per-task floor is set by the configured MCP tool schemas, not by `CLAUDE.md`.

Operating that loop is now written down — see [The `/auto-run` operator runbook](Concepts/AutoRunOperations.md).
It is the practical half of the pipeline article: the stop-reason table read as instructions, how to grow the allowlist from a `permission-denied` halt, and why an `auto/<Item>` branch must be reviewed before the next run rather than after several.
Writing it against the script rather than the specification surfaced five small divergences — selection globs `Work/Active/` instead of reading the index, the `(human)` marker matches anywhere in a task line, `unparseable-output` quotes 1 kB of stdout plus 1 kB of stderr rather than 2 kB, `item-vanished` and `interrupted` are missing from the documented stop reasons, and exit codes are four-valued (`2` for preflight, which writes no digest, and `130` for an interrupt).
All five have since been reconciled into the pipeline article, so the two agree; the standing rule is that the script is the fact and the article is what gets corrected.

The four failure conditions have now fired against real sessions — see [the failure trial](Concepts/AutonomousPipeline.md#the-failure-trial--what-four-live-halts-cost-and-changed).
Five runs against a second throwaway (`AutoRunHaltTrial`, now in `Work/Dropped/`) tripped `needs-human`, `no-commit`, `no-box`, and `permission-denied` for $12.60; every one reported `subtype: success`, confirming that the CLI's verdict on a session carries no information and the driver is right to verify rather than trust.
The important result is a failure to fail: **`--allowedTools` is added to the settings files rather than replacing them**, so the driver's allowlist is a floor and bounds nothing, and with 248 blanket allow rules at user level `permission-denied` is nearly unreachable — the supervised trial's "zero denials" had measured the settings' permissiveness, not the tasks' needs.
Tripping it took a tool the settings do not name (`mcp__Wolfram__SymbolDefinition`).
The driver's defaults now carry the seven official Wolfram MCP tools outright instead of waiting to be told, the runbook's four wrong claims are fixed, and what makes an unattended run safe is the branch-plus-merge gate rather than the allowlist.
`no-commit` and `no-box` turned out to be unprovokable by a well-behaved session — they guard harness faults and malformed item files, not misjudgement — and `needs-human` is reachable only after liveness passes, so a session that follows `revise` and stops mid-task halts as `no-box` instead.

That preamble has now been cut — see [Preamble audit](Concepts/PreambleAudit.md).
Of this repo's 16.9 kB `CLAUDE.md`, 47 % was inventory: the Skills table was a third copy of content the harness already injects as 9.6 kB of skill descriptions, and the tables had drifted anyway (headings claimed 20 skills and 21 commands against 21 and 22 on disk) while consuming 18 of the file's 26 commits.
Inventory and reference moved to a read-on-demand `ARCHITECTURE.md`; `CLAUDE.md` is 5.3 kB and keeps only policy, taking the fixed preamble from 27.9 kB to 16.3 kB.

The `CLAUDE.md` the plugin *generates* has now had the same test — see [Generated preamble audit](Concepts/GeneratedPreambleAudit.md).
It came out 82 % policy before any cut, and the 7.2 kB code-style block that T6 flagged as the obvious suspect on size is fully justified by the test: nothing prompts a session to look up a style guide, and a violation is invisible afterwards.
The defects were in the small sections instead — `## Work` was a third copy of the `Work/README.md` every scaffold also writes, and the math template reproduced the deleted Skills table in miniature.
The finding worth the task is a **contradiction**: the user's global `~/.claude/CLAUDE.md` forbids comments unless asked while the template mandates a one-line summary per exported symbol, both auto-loaded, with no precedence stated. The template now states it.
Cutting the two duplicates saved only 230 B / 582 B, and the pipeline's ~1 %-per-11.6 kB result says a saving that size is not measurable — so the generated preamble is closed as audited, with the cuts justified as correctness rather than cost.

The legacy harvest that T2 identified is now done — see [The Progress harvest](Concepts/ProgressHarvest.md).
30.9 kB of wiki content came out of 97 kB of closed-item `## Progress`: three new articles ([MathNotebook](Resources/MathNotebook.md), [Paclet Documentation](Concepts/PacletDocumentation.md), [PureMath](Resources/PureMath.md)) and a substantial extension of [MarkdownToNotebook](Resources/MarkdownToNotebook.md).
Per T3's rule nothing was pruned: the closed blocks stay as the audit trail, each gains a one-line `> Harvested:` pointer, and six claims that are false today gained `> Superseded:` markers — three of them cases where the refutation already existed elsewhere in the corpus and the reader had to reconstruct the order to know which won.
The 30.9-vs-53 kB gap is deduplication, dropped narration, and collapsed contradictions rather than loss; what the wiki genuinely does not carry is chronology, which is why the blocks were kept.

## Recent changes

- 2026-07-30 — Audited `research-notebook` against MathNotebook **0.1.20** and corrected four stale claims: the paclet **does** have a bibliography engine now (parses BibTeX, formats, sorts four ways, audits, labels) — reachable only from `ImportLaTeXDocument`, and it still numbers nothing, which is why the Markdown path keeps building its own References; the `Reference` gutter is 205 pt uniformly across all seven sheets so the short-key rule weakens to "under ~25 characters"; `PlainArticle` now declares `Reference` itself and defers exactly six styles to `Default.nb`; and the twelve environments share one counter under six of the seven sheets, not `ComplexSystems`. Also newly recorded: an environment is a **multi-cell block** whose continuation cells keep the same style, so a `Text` cell after a display equation breaks both the margin and the LaTeX export. [MathNotebook](Resources/MathNotebook.md) refreshed to `5f68f30`.
- 2026-07-30 — Rewrote `research-notebook` § *Examples* on the user's authoring rules: the definition/example and claim/example alternation as the document's rhythm, bare graphics (no `PlotLabel`, legend, frame or title), example objects one size up from trivial and spread across categories rather than one family at three sizes, and a `GraphicsRow` of three or a `GraphicsGrid` as the default layout. The fold mechanism is now the measured one — see [Folded cell groups](Concepts/FoldedCellGroups.md); two alternatives were built and rejected first.
- 2026-07-28 — `AuditFixes` T10 closed the item: the audit's mechanical checks re-run clean (21 skills, 23 commands, 28 scripts, all inter-skill links resolve, hook and JSON syntax pass), the plugin is bumped to 4.9.0 with the marketplace repo synced, and the blog post gained a draft Version-4.9 history entry awaiting the author's review.
- 2026-07-28 — `AuditFixes` T9 applied the standard skill skeleton to all 21 skills: every `SKILL.md` now carries `## When to use`, `## Steps` (numbered `### 1. Title`), `## Integration with other skills`, and `## When NOT to use`; the five integration-section names and four step-numbering styles are unified, and ARCHITECTURE.md § *How to Add a New Skill* now requires the skeleton.
- 2026-07-28 — `AuditFixes` T8 made the `revise` protocol reachable: the project `CLAUDE.md` now names it as the protocol every session follows, and the six skills that re-derived it (`scaffold-paper`, `lean`, `publish-paclet`, `new-notebook`, `research-notebook`, `update-wiki`) carry one-line links to it instead of paraphrases.
- 2026-07-28 — `AuditFixes` T7 restructured `research-notebook` to the user-mandated canonical order (definitions → theorems with conjectures/evidence subsumed → symbols and functions used → code calls, then questions and literature), renamed the fingerprint's "revision protocol" language to *drift detection* so it cannot be confused with the `revise` skill, split three read-on-demand siblings (`fingerprint.md`, `mathnotebook.md`, `output-embedding.md`; core 567 → 413 lines), and evicted the graph-displacement domain math to [Set-valued naming](Concepts/DisplacementNaming.md) — parked here because the Infrageometry home project has no wiki yet.
- 2026-07-28 — `AuditFixes` T6 split `new-notebook` into a 215-line core (hard rules, two-layer architecture, engine auto-detection, backtick escaping, style rules) plus four read-on-demand siblings (`pipeline-builtin.md`, `pipeline-rich.md`, `templates.md`, `markdown-mapping.md`); `boxifyInputCells`/`markInitCells`/`addLLMSubtitle` — previously stated three times each — are now defined once, in `pipeline-builtin.md`'s complete call (713 → 559 lines total).
- 2026-07-28 — `AuditFixes` T5 split `new-project` into a 159-line core (questionnaire, depth, mode detection, after-scaffolding) plus four read-on-demand project-type siblings (`research.md`, `math-research.md`, `paclet-dev.md`, `paclet.md`), per the `next-session/paclet-worktree.md` convention; the directory trees that duplicated the scaffold scripts' output are gone.
- 2026-07-28 — `AuditFixes` T4 deduplicated the six blocks of policy prose that had drifted into near-copies: the license-headroom check (7 copies) now points at `CLAUDE.md` § *Wolfram Kernel Execution Policy*, the semantic-line-breaks paragraph (7 copies) at its *Source formatting* rule, the one-fact table lives only in `work`, the article/Status skeletons only in `update-wiki`, and paclet-directory detection plus the new canonical *Docs-resolution check* only in `build-paclet`; net −110 lines across 15 files.
- 2026-07-28 — `AuditFixes` T3 specified provenance injection on the MCP path: the prompt-tracking toggle no longer no-ops outside the batch fallback, and the `"Provenance"` and `"ResearchNotebook"` `TaggingRules` keys coexist via a merge-by-key stamp helper (canonical in `provenance`, verified on the AgentTools kernel). See [The notebook TaggingRules registry](Concepts/TaggingRulesRegistry.md).
- 2026-07-28 — `AuditFixes` T2 swept the ten cross-skill contradictions: the `[ LLM Generated ]` marker is now the spaced form everywhere (the notebook pipeline still normalizes the legacy unspaced spelling), `new-project` gitignores `NotebooksLLM/*.nb` instead of the whole folder, `init-wiki` lost its draft-status seed line and gained the Provenance/journal toggle sections, the questionnaire asks about the journal it advertises, and the stale cross-references, pre-checked box, abolished-log promises, and retired `demo-notebook` mentions are gone.
- 2026-07-28 — Full plugin audit passed the mechanical layer (inventory, wiring, scaffolds, compiles, live scripts) and opened `AuditFixes` (ten tasks); T1 fixed the `.nb`-read hook, inert since introduction because it read positional arguments where the harness delivers stdin JSON. See [The Claude Code hook contract](Concepts/HookContract.md).
- 2026-07-28 — Closed `HardenAutoRun`: tripped all four never-live `/auto-run` stop conditions against real sessions, found that `--allowedTools` only ever *adds* to the settings files (so the allowlist bounds nothing and `permission-denied` is nearly unreachable here), gave the driver the Wolfram MCP defaults, and fixed four wrong claims in the runbook. See [the failure trial](Concepts/AutonomousPipeline.md#the-failure-trial--what-four-live-halts-cost-and-changed).
- 2026-07-28 — Harvested the closed items' Progress blocks into `Wiki/` (T5), closing `EvaluateWorkItemsEfficiency`; three new articles plus six `> Superseded:` markers. See [The Progress harvest](Concepts/ProgressHarvest.md).
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

The headless model/effort surface is measured — see [The headless model and effort surface](Concepts/HeadlessModelSurface.md).
`--model` takes all four tier aliases and `--effort` takes the five levels, both on `claude -p`, so per-task routing is buildable; but the two flags fail in opposite directions, a bad effort value being accepted silently, and no output field reports the effort a run actually applied.
The annotation that carries those facts into the item file is now a format rule — see [The per-task routing annotation](Concepts/ItemFileFormat.md#the-per-task-routing-annotation).
A task box may name `(model: …, effort: … — reason)` immediately after its id; `/work` routes each task as it writes it and presents the routing table with the breakdown, and `/next-session` states the annotation, compares tiers rather than id strings, and halts on an effort outside the five levels.
The anchoring is load-bearing: extracted as the first `([^)]*)` group after the task id it parses with `sed`, leaves the driver's existing task selection and `(human)` gate untouched, and cannot be widened by a `)` in the task body.
`/auto-run` now acts on it: each task is spawned with the `--model` and `--effort` its own annotation names, the parse validates the effort itself (a bad model already halts for free, a bad effort would succeed silently at the default), and a typo halts the run as `bad-annotation` before anything is spawned.
Each digest verdict names the model **used** and the effort **requested**, and a halt where the session ran and closed nothing carries an escalation recommendation.

That was trialled live on two tiers — see [the routing trial](Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke).
The annotation reaches a real headless session: each task recorded the tier off its own system prompt and agreed with the driver's reading of `modelUsage`.
The economics are now measured rather than assumed — `sonnet` closed a real task for $0.64 against $1.54–$4.09 on the default tier, and `haiku` ran one for $0.07.
The cheap tier's failure mode is the finding: haiku produced its deliverable correctly, committed it, and then ticked its box in place instead of moving it into `### Done`, halting as `no-box`.
So the liveness pair guards more than harness faults after all, and it is what makes cheap routing safe to try.
T4 then ruled on the routing table and closed the item.
`haiku` loses its default row and joins `fable` as explicit-request-only: every task the pipeline routes runs through `/next-session`, which always ends in bookkeeping, so a tier that does the work well and the paperwork badly saves $0.57 and risks a halt costing a human round-trip.
The `/next-session` tier mismatch is ruled **halt, not warn** — fail-closed, matching the annotation parser and the effort validator, and already what S2 had written provisionally.
The `opus` row is still a prior and `fable` is still untested, so the table stands at one measured row and one assumed one.

The shared paper writing guide has now been run against a real document on both of its paths — see [Running the paper style guide against a real document](Concepts/PaperStyleExercise.md).
`ExercisePaperStyle` T1 built a short paper on equidistance and odd girth from the SyntheticInfrageometry paclet's own primitives, proved in full and checked over all 995 connected graphs with at most seven vertices, and T2 re-set the same mathematics as a scaffolded LaTeX paper so that the two paths could be differenced.
Two of `style.md`'s rules turn out to contradict each other: the 8-sentence proof trigger against the ban on shattering an argument into tiny lemmas, and the required 3-paragraph introduction against "never two prose paragraphs in a row".
Five more fought the mathematics, of which the sharpest is that "one deduction per sentence" plus "name the tag it rests on" puts 14 proof sentences over the 25-word cap.
Of the three numbers the Spec flagged as unmeasured, one example per result and 3–10 line examples both held, and the sentence cap is the one that fails.
The build path gave up three defects too, the costly one being that the converter's 19-digit `CellID`s are dropped by `Export` — so the drift fingerprint covered 8 cells of 71 until they were stripped and reassigned.

Differencing the two paths is what the re-setting bought.
Five of T1's findings recur unchanged in LaTeX, including the two 26- and 27-word abstract sentences and the same 14 over-long proof deductions, which settles them as `style.md`'s rather than the notebook generator's.
Four are the LaTeX path's alone, the substantive one being that the guide gives the code behind a *Ruliology* call no home: a notebook keeps it in an Initialization section, LaTeX has none, and writing it into *Ruliology* buried the four one-line calls that section exists to carry.
Re-setting also caught a forward reference in T1's notebook that the checklist already forbade and nobody had checked, because a notebook tag is inert text while `\cref` is not.

T3 has now answered all of it in the shipped files — see [what T3 corrected](Concepts/PaperStyleExercise.md#what-t3-corrected).
Nothing that failed was a threshold: on both paths it was a rule's **scope**, so the 25-word cap is now a rule about connecting prose, the never-two-paragraphs rule is one about prose between statements, and the proof trigger counts a run of deductions rather than a proof.
The three numbers the Spec flagged therefore stand unchanged for the operator's read, one of them corrected in meaning — the example budget counts rendered lines, which is what a reader sees.
Two of T1's findings changed under re-measurement: `Export` turns out to drop a *19-digit* `CellID` and keep a small one, and the `AssignCellIDs` pass order is immaterial (measured identical), so the real defect there was that the order `mathnotebook_post.wl` documents did not evaluate at all.
The template fixes are compiled rather than reasoned: scaffolded from the corrected assets, LaTeX and Typst both build clean, and the five-label `\cref` that silently lost two entries now prints all five with the right names.
The operator's read at T4 has since produced two build-path defects of its own — see [what the T4 read found](Concepts/PaperStyleExercise.md#what-the-t4-read-found).
The QED square was the `Proof` style's right-hand cell frame label, which the front end centres vertically, so it sat at mid-height on every proof past one line in all seven MathNotebook stylesheets; it is now a `QED` character style written at the end of the proof's last paragraph, which is what the paclet's own Complex Systems templates already did.
The sheets turned out to be generated, so the fix went into `Scripts/BuildStyleSheets.wls` and all seven were regenerated from it.
Fixing it surfaced the sharper one: three of the notebook's fingerprint entries were stale, and since a false positive in the drift gate is indistinguishable from a real edit and the documented response is to stop, any research notebook carrying a picture would have refused to regenerate.
[The ruling T4 exists for](Concepts/PaperStyleExercise.md#the-ruling) then closed the item, from four read passages chosen to put a number or a boundary in front of a page.
Exactly one rule was overturned rather than rescoped, and it is the one the whole exercise was written to enforce: § *Examples* had definitions rarely taking an example and called the `Definition, Example` alternation a source of flooding, and a continuous read of a five-definition section with no picture in it says otherwise — a definition gets an example, whose picture shows the phenomenon and stays bare.
The example budget lost its floor, since every example on both paths is two lines and every one was approved; a budget no approved instance satisfies is not a budget.
The 25-word cap stands as T3 scoped it — the abstract's long sentences read fine — and so do the four tiers, with `Question` joining `Conjecture` in *Open and central* and both gathered in an outlook at the end of the paper.
Both exercise documents now fail the rule they produced, which is a fresh item's work rather than a correction to this one.

The LaTeX templates gave up seven defects, and two of them make a paper wrong rather than ugly: `macros_template.sty` numbers every environment on the shared `theorem` counter, so cleveref cites a definition as "by Theorem 2.4", and the `aliascnt` fix for that makes cleveref silently drop entries from a multi-reference list unless `nosort` is set with it — measured at five labels in, three out.

## Open questions

- Upstream `MarkdownToNotebook` has no `LICENSE` file and no tags.
  A standing, non-blocking ask for an in-tree licence is open with Nikolay Murzin.
  Adoption is not gated on it — the user confirmed the licence is fine, and pinning by SHA works today.
- The measured budget covers bookkeeping only.
  What a session spends reading the files it actually edits is unmeasured and may be the larger number; no method for capturing it exists yet.
- The durable share of `## Did` (66.8 %) is extrapolated from an 18 % sample, not classified exhaustively.
  Its 60 kB is too large to hand-classify in one session, so the ~40 kB figure derived from it carries sampling error that the `Learned` numbers do not.
- Should `/auto-run` stop inheriting the user's settings?
  Passing a minimal `--settings` file would make `--allowedTools` bound a run as the pipeline specification originally claimed, instead of merely flooring it.
  `HardenAutoRun` left it alone because that is a change of security posture rather than a correction, and its Spec scoped it to maintenance.
  Meanwhile an unattended session can run any shell command not on the settings' 17-entry `ask` list, and the `auto/<Item>` branch plus the human merge is what actually contains it.
- Is `effortLevel` in `~/.claude/settings.json` inherited by a headless `claude -p` run?
  It is `xhigh` on this machine, so if it is inherited then every unattended task run so far has been at `xhigh` rather than at a default, and `ModelRouting`'s "absent means inherit" has to name what it inherits.
  The grammar's answer meanwhile is that a routed task names both fields, so nothing depends on the inherited value.
  Thinking-token counts are the only available instrument and are too noisy to answer it — the same prompt with no effort flag produced 0, 74, and 172 thinking tokens across three runs.
