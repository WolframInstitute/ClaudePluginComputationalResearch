# ModelRouting

*[ LLM Generated ]*

> Type: refactor
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: "My goal would be to spend time on writing specs and dividing work, and then letting claude run automatically, automatically switching models and clearing contexts between tasks." (2026-08-19, during the SyntheticInfrageometry walk-family design session.)

The pipeline already clears context — `/auto-run` spawns one cold `claude -p` per task — but every task runs on the machine's default model.
That wastes money in one direction and quality in the other: a mechanical rename sweep does not need Opus, and a cross-cutting semantic change should not silently run on whatever the user last set with `/model`.
The missing piece is a **per-task model contract**: the item file says which model (and effort) each task wants, `/work` writes it when dividing the work, `/next-session` checks it, and `/auto-run` acts on it.

Precedent: `SyntheticInfrageometry/Work/Active/WalkFamilyRefactor.md` (2026-08-19) hand-annotated four tasks with `*(model: Sonnet 5, effort high — ~90% mechanical)*` and a startup ritual (`/clear`, `/model`, `/effort`, `/next-session`).
This item turns that hand convention into a format rule and closes the loop headless.

### Requirements

- **Annotation grammar.** A task box may carry `(model: haiku | sonnet | opus | fable, effort: low | medium | high | xhigh | max)` immediately after its title, both fields optional; absent means inherit the session/default model.
  Must be greppable by `auto-run.sh` and readable as prose — the annotation doubles as documentation of why the task is routed where it is (a dash-clause after the fields carries the reason).
  Use CLI aliases, never dated model ids — ids rot, aliases track.
  All four aliases are confirmed valid headless ([T1](../../Wiki/Concepts/HeadlessModelSurface.md#--model-takes-aliases-and-all-four-tiers-resolve)), and `haiku` is the instance that justifies the rule: it is the one tier whose resolved id carries a release date.
- **`/work`** assigns model + effort per task when breaking a Spec into tasks, from a routing table presented with the breakdown (revise protocol — the user rules on it):
  mechanical sweeps / renames / doc passes → sonnet; design-critical semantics, cross-cutting refactors, proofs → opus; bulk trivial classification → haiku; fable only on explicit user request.
  That table is a **prior, not a measurement** — T1 deliberately did not test it, and T1's one relevant datum cuts against the cheap end: at `--effort low` sonnet answered a two-step arithmetic question wrong in two of three runs, at full confidence and with nothing in the output to flag it. T4 rules on the table.
- **`/next-session`** parses the next task's annotation and compares it against the model the session is actually running (the session knows its model from its own system prompt).
  On mismatch it must not silently burn the wrong tier — see the warn-vs-halt decision below.
- **`/auto-run`** reads the next unchecked task's annotation and passes `--model <alias>` and `--effort <level>` to that task's `claude -p` spawn.
  Both flags are measured and work headless ([T1](../../Wiki/Concepts/HeadlessModelSurface.md)); effort is *also* settable as the `effortLevel` settings key, which is not the spelling this Spec would have guessed.
  The digest's per-task table names the model **used** — recoverable from `modelUsage`, but only after filtering the auxiliary `claude-haiku-4-5` entry that rides along on nearly every run — and the effort **requested**, because no output field reports the effort actually applied.
- **Escalation on halt.** A task that halts under a cheap model should not be blindly re-run on the same model; the digest recommends the escalation explicitly (sonnet → opus) so the human's one decision is yes/no, not diagnosis.
- **Fail closed, and the two halves are not symmetric.** An unparseable annotation halts selection with a message, like the `> Autonomous: allowed` gate — a typo must not silently route to the default.
  A bad **model** is already caught for free: the CLI returns exit 1 with `is_error`, `terminal_reason: api_error` and zero cost, which trips the driver's existing condition 3.
  A bad **effort** is caught by nothing — the run proceeds at default effort, exits 0, and warns only on stderr — so the parser must validate the five levels itself before spawning.

### What already exists (do not rebuild)

- Cold-per-task context clearing, the `auto/<Item>` branch gate, the digest, and per-model cost telemetry (`modelUsage` in `--output-format json`) — all in `scripts/auto-run.sh` and specified in `Wiki/Concepts/AutonomousPipeline.md`.
- The measured-not-assumed rule for `claude -p` behavior (same article) applies to every CLI claim this item adds.

## Tasks

### Done

- [x] T4 (S4) — the operator ruled: `haiku` off the default table, and the `/next-session` tier mismatch halts rather than warns; propagated to [`work` § step 3](../../skills/work/SKILL.md#3-decompose-into-tasks) and [ItemFileFormat](../../Wiki/Concepts/ItemFileFormat.md#the-routing-table-and-what-ruling-on-it-settled).
- [x] T3 (S3) — the driver routes each task from its annotation, validates the effort itself, names the model used and the effort requested per verdict, and recommends the escalation on a halt; [stub-tested](../../scripts/test-auto-run-routing.sh) in 44 assertions and [trialled live on two tiers](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke).
- [x] T2 (S2) — the annotation grammar written into [ItemFileFormat](../../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation); `/work` routes and presents the table, `/next-session` compares tiers.
- [x] T1 (S1) — measured the headless surface; facts in [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md), Spec corrected in four places.

## Hand-off

The item is complete: the feature shipped as 4.14.0 and T4's two rulings are in force and propagated.
Nothing here blocks, but four things outlive the item and belong to whoever picks up the pipeline next.

**The merge is outstanding.** `auto/ModelRoutingTrial` carries the trial's four commits, including one of S3's own — the driver leaves the repo on `auto/<Item>` and never returns, so a commit made after a run lands there. After merging, `Wiki/Concepts/RoutingTrial.md` is scratch that has been harvested and should be deleted, and `ModelRoutingTrial.md`'s Spec carries one link to this session's renamed anchor (`#the-routing-table-is-a-prior-not-a-result` → `#the-routing-table-and-what-ruling-on-it-settled`) that was deliberately left for the merge rather than fixed on `main`. Check `find .git -type f -flags +dataless | wc -l` reads 0 first — S4 found 2009 dataless placeholders under `.git`, where `git branch -a` silently omitted this very branch ([runbook](../../Wiki/Concepts/AutoRunOperations.md#landing-autoitem-on-main)).

**Neither repo is pushed.** `main` is ahead of `origin` (6 commits as of S4), and the marketplace clone one.

**Two rows of the routing table are still unmeasured.** The ruling retired the cheap end on evidence; the `opus` row remains a prior and `fable` has never been run. Pricing the expensive half needs a task whose tier is what is being measured, which is a new item rather than a gap in this Spec.

**A per-task cost ceiling is now buyable and was not before.** `--max-budget-usd` is a per-process dollar cap, so a cheap tier could carry a cheap ceiling; the driver's `--max-cost` is still a whole-run cap, which is a routing decision left unenforced. Not filed as a task — it is a new idea rather than a gap in this Spec.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-19 | Model routing is an item-file annotation, not a driver flag | The item is the contract the human writes; the driver and the skills both read it, so specs stay the single place where work is divided and priced |
| 2026-08-19 | Aliases (`sonnet`, `opus`) in annotations, never dated model ids | Ids rot with every release; aliases track the current tier |
| 2026-08-20 (T4) | `/next-session` on model mismatch **halts**, it does not warn and proceed | Ratifies what S2 wrote provisionally. Fail-closed is already the rule for the annotation parser and the effort validator, so warn-and-proceed would make the tier the one routing field that fails open; a restart is cheaper than the wrong-tier run the item exists to prevent |
| 2026-08-20 | The annotation is plain parens anchored after the task id, not italics after the task title as the precedent had it | Anchored there it extracts as one `[^)]*` group, so a `)` or an `effort:` in the task body can neither widen it nor fake a field; the italic mid-prose form cannot be parsed that way |
| 2026-08-20 (S3) | The driver validates the effort and passes the model through unchecked | The two halves fail in opposite directions: an unrecognised model exits 1 with `is_error` at zero cost and trips condition 3, while an unrecognised effort succeeds at the default and warns only on stderr — so the check exists for the effort's sake and the model's is free |
| 2026-08-20 (S3) | A paren group with no `key:` in it is not an annotation; one that has a `key:` must parse completely | `(human)` and a closed box's `(S2)` sit in the same anchored position and must pass through, while `(modle: sonnet)` must halt rather than inherit the default silently |
| 2026-08-20 | The routing table pairs the cheap tiers with a **high** effort, never a cheap one | Tier and effort are separate decisions, and the only measurement on the cheap end is sonnet answering a two-step arithmetic question wrong in two of three runs at `low` |
| 2026-08-20 (T4) | `haiku` loses its default row and joins `fable` as explicit-request-only; `sonnet` and `opus` are the whole default table | The pipeline has no cheap tasks in the relevant sense — every routed task runs through `/next-session`, which always ends in bookkeeping. haiku did the work correctly for $0.07 and then failed the protocol, so its saving of $0.57 against sonnet is set against a halt costing a human round-trip. Its context window being a fifth of the others' against a ~31 kB cold start makes that structural, not unlucky |
| 2026-08-20 (T4) | The haiku row's `medium` effort was a defect, not a position | It contradicted this table's own high-effort rule three rows above it; removing the row retires the contradiction with it |

## Progress

- 2026-08-19 — item filed from the SyntheticInfrageometry walk-family session (operator request).
- **S1** 2026-08-19 T1 — measured `--model` and `--effort` on `claude -p`; both work, and the two fail in opposite directions. → [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md)
- **S2** 2026-08-20 T2 — the routing annotation became a format rule, with the grammar anchored so it parses with `sed`. → [the per-task routing annotation](../../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation)
- **S3** 2026-08-20 T3 — the driver reads the annotation and spawns each task on the tier it names; trialled live, where the cheap tier did the work and fumbled the bookkeeping. → [the routing trial](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke), [the routing table's first datum](../../Wiki/Concepts/ItemFileFormat.md#the-routing-table-and-what-ruling-on-it-settled)
- **S4** 2026-08-20 T4 — the operator ruled on the routing table and the mismatch rule; `haiku` is off the default table and a tier mismatch now halts. → [the routing table ruling](../../Wiki/Concepts/ItemFileFormat.md#the-routing-table-and-what-ruling-on-it-settled), [the OneDrive placeholder hazard](../../Wiki/Concepts/AutoRunOperations.md#landing-autoitem-on-main)
