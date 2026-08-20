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

- [ ] T3 — `auto-run.sh`: parse the annotation (validating effort itself — the CLI does not), pass `--model` and `--effort`, name the model used and the effort requested in the digest per task, add the escalation recommendation on halt; stub-test the parse, then one live mixed-model run on a cheap two-task item.
- [ ] T4 (human) — the operator rules on the routing table defaults and on warn-vs-halt for `/next-session` mismatch.

### Done

- [x] T2 (S2) — the annotation grammar written into [ItemFileFormat](../../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation); `/work` routes and presents the table, `/next-session` compares tiers.
- [x] T1 (S1) — measured the headless surface; facts in [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md), Spec corrected in four places.

## Hand-off

The annotation is a format rule as of S2 — grammar and rationale in [ItemFileFormat § *The per-task routing annotation*](../../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation), normative form in `work` § *The routing annotation*, comparison step in `next-session` step 3.
T3 implements the driver half; nothing is in flight.
Read `Wiki/Concepts/AutonomousPipeline.md` and `AutoRunOperations.md` before touching the driver, and [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md) instead of re-measuring the flags.

Three things S2 settled that T3 should not re-derive.

**Extraction is anchored, and the anchoring is the whole trick.**
Take the first `([^)]*)` group after the task id, then read `model:` and `effort:` out of that group.
Checked against the driver's own idioms on a fixture: the existing `awk` selection and the `TASK_ID` `sed` at `scripts/auto-run.sh:270` are unaffected, and `(human)` still matches.
A greedy `(\(.*\))` breaks on a `)` in the task body, and an unanchored match reads an `effort:` mentioned in the body's prose as a field.

**Only the effort needs validating** — the five levels, before spawning.
A bad model is already the driver's condition 3, for free.

**The version bump and the blog post belong to T3, not to S2.**
Both would have described a feature `/auto-run` still ignores.
When T3 lands: bump `.claude-plugin/plugin.json` and mirror it to the marketplace, and give the blog post a one-paragraph ideas-only entry — the idea is that a spec now prices the work it divides, not that two flags got passed.

`/next-session`'s mismatch behaviour is provisionally **warn and stop**; T4 rules on it, and flipping it is a two-line edit in step 3.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-19 | Model routing is an item-file annotation, not a driver flag | The item is the contract the human writes; the driver and the skills both read it, so specs stay the single place where work is divided and priced |
| 2026-08-19 | Aliases (`sonnet`, `opus`) in annotations, never dated model ids | Ids rot with every release; aliases track the current tier |
| 2026-08-19 | (open — T4) `/next-session` on model mismatch: warn and stop, or warn and proceed | S2 wrote warn-and-stop provisionally, so the skill is coherent today; stopping costs a restart; proceeding silently burns the wrong tier |
| 2026-08-20 | The annotation is plain parens anchored after the task id, not italics after the task title as the precedent had it | Anchored there it extracts as one `[^)]*` group, so a `)` or an `effort:` in the task body can neither widen it nor fake a field; the italic mid-prose form cannot be parsed that way |
| 2026-08-20 | The routing table pairs the cheap tiers with a **high** effort, never a cheap one | Tier and effort are separate decisions, and the only measurement on the cheap end is sonnet answering a two-step arithmetic question wrong in two of three runs at `low` |

## Progress

- 2026-08-19 — item filed from the SyntheticInfrageometry walk-family session (operator request).
- **S1** 2026-08-19 T1 — measured `--model` and `--effort` on `claude -p`; both work, and the two fail in opposite directions. → [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md)
- **S2** 2026-08-20 T2 — the routing annotation became a format rule, with the grammar anchored so it parses with `sed`. → [the per-task routing annotation](../../Wiki/Concepts/ItemFileFormat.md#the-per-task-routing-annotation)
