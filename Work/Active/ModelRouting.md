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

- [ ] T4 (human) — the operator rules on the routing table defaults and on warn-vs-halt for `/next-session` mismatch.

### Done

- [x] T3 (S3) — the driver routes each task from its annotation, validates the effort itself, names the model used and the effort requested per verdict, and recommends the escalation on a halt; [stub-tested](../../scripts/test-auto-run-routing.sh) in 44 assertions and [trialled live on two tiers](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke).
- [x] T2 (S2) — the annotation grammar written into [ItemFileFormat](../../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation); `/work` routes and presents the table, `/next-session` compares tiers.
- [x] T1 (S1) — measured the headless surface; facts in [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md), Spec corrected in four places.

## Hand-off

The feature is complete and shipped as 4.14.0 (marketplace mirrored, blog entry drafted in the author's live clone, unpushed).
Only **T4** remains, and it is `(human)`: the operator rules on the routing table's defaults and on warn-vs-halt for a `/next-session` tier mismatch.

Two of T4's inputs are no longer priors.
[The routing trial](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke) priced the table's middle and cheapest rows on real tasks: `sonnet` closed one for $0.64 against $1.54–$4.09 on the default tier, and `haiku` produced a correct deliverable for $0.07 and then failed the session protocol, ticking its box in place.
So the case for routing mechanical work to `sonnet` is now evidence, and the case against `haiku` for anything that must drive `next-session` is a live counterexample rather than a worry.
The `fable` row and the expensive half of the table are still untested.

Three things are left over for whoever takes T4 or files what follows it.

**The merge is outstanding.** `auto/ModelRoutingTrial` carries the trial's four commits, including one of S3's own — the driver leaves the repo on `auto/<Item>` and never returns, so a commit made after a run lands there. After merging, `Wiki/Concepts/RoutingTrial.md` is scratch that has been harvested and should be deleted.

**Neither repo is pushed.** `main` is five commits ahead of `origin`, and the marketplace clone one.

**A per-task cost ceiling is now buyable and was not before.** `--max-budget-usd` is a per-process dollar cap, so a cheap tier could carry a cheap ceiling; the driver's `--max-cost` is still a whole-run cap, which is a routing decision left unenforced. Not filed as a task — it is a new idea rather than a gap in this Spec.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-19 | Model routing is an item-file annotation, not a driver flag | The item is the contract the human writes; the driver and the skills both read it, so specs stay the single place where work is divided and priced |
| 2026-08-19 | Aliases (`sonnet`, `opus`) in annotations, never dated model ids | Ids rot with every release; aliases track the current tier |
| 2026-08-19 | (open — T4) `/next-session` on model mismatch: warn and stop, or warn and proceed | S2 wrote warn-and-stop provisionally, so the skill is coherent today; stopping costs a restart; proceeding silently burns the wrong tier |
| 2026-08-20 | The annotation is plain parens anchored after the task id, not italics after the task title as the precedent had it | Anchored there it extracts as one `[^)]*` group, so a `)` or an `effort:` in the task body can neither widen it nor fake a field; the italic mid-prose form cannot be parsed that way |
| 2026-08-20 (S3) | The driver validates the effort and passes the model through unchecked | The two halves fail in opposite directions: an unrecognised model exits 1 with `is_error` at zero cost and trips condition 3, while an unrecognised effort succeeds at the default and warns only on stderr — so the check exists for the effort's sake and the model's is free |
| 2026-08-20 (S3) | A paren group with no `key:` in it is not an annotation; one that has a `key:` must parse completely | `(human)` and a closed box's `(S2)` sit in the same anchored position and must pass through, while `(modle: sonnet)` must halt rather than inherit the default silently |
| 2026-08-20 | The routing table pairs the cheap tiers with a **high** effort, never a cheap one | Tier and effort are separate decisions, and the only measurement on the cheap end is sonnet answering a two-step arithmetic question wrong in two of three runs at `low` |

## Progress

- 2026-08-19 — item filed from the SyntheticInfrageometry walk-family session (operator request).
- **S1** 2026-08-19 T1 — measured `--model` and `--effort` on `claude -p`; both work, and the two fail in opposite directions. → [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md)
- **S2** 2026-08-20 T2 — the routing annotation became a format rule, with the grammar anchored so it parses with `sed`. → [the per-task routing annotation](../../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation)
- **S3** 2026-08-20 T3 — the driver reads the annotation and spawns each task on the tier it names; trialled live, where the cheap tier did the work and fumbled the bookkeeping. → [the routing trial](../../Wiki/Concepts/AutonomousPipeline.md#the-routing-trial--what-two-tiers-cost-and-what-the-cheap-one-broke), [the routing table's first datum](../../Wiki/Concepts/ItemFileFormat.md#the-routing-table-is-a-prior-not-a-result)
