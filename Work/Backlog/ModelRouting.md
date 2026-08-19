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
- **`/work`** assigns model + effort per task when breaking a Spec into tasks, from a routing table presented with the breakdown (revise protocol — the user rules on it):
  mechanical sweeps / renames / doc passes → sonnet; design-critical semantics, cross-cutting refactors, proofs → opus; bulk trivial classification → haiku; fable only on explicit user request.
- **`/next-session`** parses the next task's annotation and compares it against the model the session is actually running (the session knows its model from its own system prompt).
  On mismatch it must not silently burn the wrong tier — see the warn-vs-halt decision below.
- **`/auto-run`** reads the next unchecked task's annotation and passes `--model <alias>` to that task's `claude -p` spawn; the digest's per-task table names the model used.
  Effort headless is unverified — measure what the CLI supports before designing around it (flag, settings key, or nothing).
- **Escalation on halt.** A task that halts under a cheap model should not be blindly re-run on the same model; the digest recommends the escalation explicitly (sonnet → opus) so the human's one decision is yes/no, not diagnosis.
- **Fail closed.** An unparseable annotation halts selection with a message, like the `> Autonomous: allowed` gate — a typo must not silently route to the default.

### What already exists (do not rebuild)

- Cold-per-task context clearing, the `auto/<Item>` branch gate, the digest, and per-model cost telemetry (`modelUsage` in `--output-format json`) — all in `scripts/auto-run.sh` and specified in `Wiki/Concepts/AutonomousPipeline.md`.
- The measured-not-assumed rule for `claude -p` behavior (same article) applies to every CLI claim this item adds.

## Tasks

- [ ] T1 — measure the headless surface: `--model` alias handling on `claude -p`, whether effort is controllable headless (flag / settings file / not at all), and what the json output reports about the model actually used; file the facts as a wiki article and correct this Spec where it guessed.
- [ ] T2 — write the annotation grammar into `Wiki/Concepts/ItemFileFormat.md`; teach `/work` the routing table (presented with every task breakdown) and `/next-session` the parse-and-compare step.
- [ ] T3 — `auto-run.sh`: parse the annotation, pass `--model`, name the model in the digest per task, add the escalation recommendation on halt; stub-test the parse, then one live mixed-model run on a cheap two-task item.
- [ ] T4 (human) — the operator rules on the routing table defaults and on warn-vs-halt for `/next-session` mismatch.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Fresh item; nothing in flight.
Read `Wiki/Concepts/AutonomousPipeline.md` and `AutoRunOperations.md` before touching the driver — the failure semantics there were bought with live halts, and the annotation must compose with them, not around them.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-19 | Model routing is an item-file annotation, not a driver flag | The item is the contract the human writes; the driver and the skills both read it, so specs stay the single place where work is divided and priced |
| 2026-08-19 | Aliases (`sonnet`, `opus`) in annotations, never dated model ids | Ids rot with every release; aliases track the current tier |
| 2026-08-19 | (open — T4) `/next-session` on model mismatch: warn and stop, or warn and proceed | Stopping costs a restart; proceeding silently burns the wrong tier |

## Progress

- 2026-08-19 — item filed from the SyntheticInfrageometry walk-family session (operator request).
