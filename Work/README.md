# Work

Execution state for ComputationalResearch — what's being built now.
Each file is one **work item**: a Spec, Tasks (one ≈ one session), a Hand-off for the next session, and a one-line Progress log.
Durable knowledge lives in `Wiki/`.

An item's **status is its folder** — there is no status field:

| Folder | Meaning | Names |
|---|---|---|
| `Active/` | in progress | `<Name>.md` |
| `Backlog/` | proposed / not started (drafts live here) | `<Name>.md` |
| `Done/` | completed | `YYYY-MM-DD-<Name>.md` (completion date) |
| `Dropped/` | abandoned / superseded | `YYYY-MM-DD-<Name>.md` (drop date) |

Changing status is a `git mv`.
Names are clean while an item is live and get a date prefix when archived, so `Done/` and `Dropped/` read chronologically.

Run `/next-session` in a **fresh** session to work the next task of an active item — clean context per task is the whole point.
Use `/work` to create a new item.

## Active

The one thing the folders can't show — each in-progress item and its next task.
`Backlog/`, `Done/`, and `Dropped/` are not mirrored here; browse the folders.

| Item | Next task |
|---|---|
| — | nothing active |

`ExercisePaperStyle` completed on 2026-08-21 after four tasks. It started on 2026-08-20 and ran the shared writing guide against a real document on both of its paths: T1 as a notebook and T2 as a scaffolded LaTeX paper, the same mathematics — equidistance and odd girth over the SyntheticInfrageometry primitives — re-set so that a finding appearing on both paths is the guide's and a finding on one is that generator's. T1 found [seven writing rules and three build defects](../Wiki/Concepts/PaperStyleExercise.md), two of the seven being rules of `style.md` that contradict each other. T2 confirmed five of those as path-independent, added four the notebook could not show — chiefly that the guide gives the *Ruliology* calls' supporting code no home outside a notebook's Initialization section — and turned up [seven defects in the LaTeX build path](../Wiki/Concepts/PaperStyleExercise.md#the-build-path--six-defects-in-the-shipped-template), the worst being that `\cref` mislabels every non-theorem and that the obvious fix makes multi-references silently lose entries.
T3 [answered all of it](../Wiki/Concepts/PaperStyleExercise.md#what-t3-corrected) in the shipped guide, generators and templates: nothing that failed was a threshold, so the three flagged numbers keep their values and gain a scope, and the corrected templates were re-scaffolded and compiled on both formats.
T4 — the operator's own read — paid for itself twice over before it ruled on anything: it caught the QED square sitting at mid-height in every proof longer than one line, cell furniture the front end centres in all seven MathNotebook stylesheets, and in the course of fixing it [three stale fingerprint entries](../Wiki/Concepts/PaperStyleExercise.md#what-the-t4-read-found) that would have made the drift gate refuse to regenerate any notebook carrying a picture.
[The ruling itself](../Wiki/Concepts/PaperStyleExercise.md#the-ruling) came from four read passages and overturned exactly one rule, the only finding of the whole exercise that was a rule's substance rather than its scope: a definition gets an example, with a picture that shows the phenomenon, where the guide had said definitions rarely take one and that the alternation floods the page.
The example budget lost its floor — every example on both paths was two lines and every one was approved — while the 25-word cap and the tier boundaries stand, the latter gaining `Question` alongside `Conjecture` and an outlook to hold them.
Neither document is deployed and both now fail the rule they produced, so bringing them into line is a fresh item's work.
`ExampleEveryDefinition` completed on 2026-08-21 after two tasks, in the session that closed `ExercisePaperStyle`: six examples into each of the two exercise documents, one per definition that has an object to show, verified on a kernel and approved from a contact sheet before either document was touched.
Its three findings are all the build path's, the sharpest being that [the stale graphics fingerprint](../Wiki/Concepts/PaperStyleExercise.md#exercising-the-corrected-rule) comes from stamping the in-memory notebook instead of the round-tripped one — now fixed, with the build re-importing to confirm zero drift before it declares success.
`JournalAsPaperSink`, filed the same day as `ExercisePaperStyle` (2026-08-18), stays in `Backlog/`: it resolves the tier rules depending on a journal that is off by default, and T1 gave it one data point — nothing in that session fell below the settled tier, so the gap did not bite.
One more sits there from an operator session on 2026-08-19: `WorkDashboard`, a read-only local web dashboard over a project's `Wiki/` + `Work/` trees.
`ModelRouting` was filed the same day and started immediately — T1 [measured the headless surface](../Wiki/Concepts/HeadlessModelSurface.md), T2 made the [annotation](../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation) a format rule, and T3 gave `/auto-run` its half and [trialled it live on two tiers](../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke): `sonnet` closed a real task for a quarter to a tenth of the default tier's price, while `haiku` produced a correct deliverable for $0.07 and then failed the session protocol.
It completed on 2026-08-20 after four tasks, when T4 — the operator's own `(human)` call — took `haiku` off the default routing table and made a `/next-session` tier mismatch halt rather than warn; the `opus` row is still a prior and `fable` is still untested.
The one thing left open by the items below is whether `/auto-run` should stop inheriting the user's `~/.claude/settings.json` allow rules — recorded as an open question in [Wiki/Status.md](../Wiki/Status.md#open-questions), not yet filed as an item, because it changes the pipeline's security posture rather than fixing it.

`ModelRoutingTrial` completed on 2026-08-20 after two tasks — the throwaway that gave `ModelRouting` T3 a live mixed-model run. A two-task run on two tiers (`haiku`, then `sonnet`) showed `auto-run.sh` routes per task rather than per run, each session reading its own tier off its own system prompt. Its branch merged the same day, which was the `revise` approval; the scratch article it produced was harvested into [the pipeline article](../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke) and deleted.
`AuditFixes` completed on 2026-07-28 after ten tasks: the inert `.nb`-read hook fixed, the cross-skill contradictions and duplicated policy prose removed, three oversized skills split into cores plus read-on-demand siblings, `research-notebook` restructured to the user-mandated canonical order, the `revise` protocol made reachable, the standard skill skeleton applied to all 21 skills, and the plugin bumped to 4.9.0 with the marketplace synced.
`HardenAutoRun` completed on 2026-07-28 after two tasks: all four never-live `/auto-run` stop conditions fired against real sessions, `--allowedTools` turned out to only ever *add* to the settings files, and the driver gained the Wolfram MCP defaults.
`AutoRunHaltTrial` was dropped on 2026-07-28: the crash-test dummy `HardenAutoRun` drove, whose five tasks were sabotage rather than work — `Dropped/` rather than `Done/` for exactly that reason.
`EvaluateWorkItemsEfficiency` completed on 2026-07-28 after nine tasks: the per-session budget is measured, the item file format is decided and in force, both auto-loaded preambles are audited, the unattended pipeline is built and trialled live, and T5's harvest moved the closed items' durable content into `Wiki/`.
`AutoRunTrial` completed on 2026-07-28: the throwaway item that gave `EvaluateWorkItemsEfficiency` T8 a real item to drive, closing with its `(human)` task done interactively.
`AdoptMarkdownToNotebook` completed on 2026-07-27: `new-notebook` gained an auto-detected rich conversion engine, and `research-notebook` now uses that engine as the parser half of a two-half pipeline with MathNotebook post-processing, generating one-way from a readable `.md`.
`PacletDocumentation` completed on 2026-07-27; paclet presentation moved from a hand-built cloud notebook to real Wolfram documentation, bundled on publish and deployed publicly.
