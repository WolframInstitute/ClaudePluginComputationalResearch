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

- [ ] T2 — write the annotation grammar into `Wiki/Concepts/ItemFileFormat.md`; teach `/work` the routing table (presented with every task breakdown) and `/next-session` the parse-and-compare step.
- [ ] T3 — `auto-run.sh`: parse the annotation (validating effort itself — the CLI does not), pass `--model` and `--effort`, name the model used and the effort requested in the digest per task, add the escalation recommendation on halt; stub-test the parse, then one live mixed-model run on a cheap two-task item.
- [ ] T4 (human) — the operator rules on the routing table defaults and on warn-vs-halt for `/next-session` mismatch.

### Done

- [x] T1 (S1) — measured the headless surface; facts in [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md), Spec corrected in four places.

## Hand-off

Nothing in flight.
Read `Wiki/Concepts/AutonomousPipeline.md` and `AutoRunOperations.md` before touching the driver — the failure semantics there were bought with live halts, and the annotation must compose with them, not around them.
T1's measurements are in [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md); read it before T2 or T3 rather than re-measuring.

Three things it settled that change the remaining tasks.

**The parser owns effort validation, and only effort.** A bad model alias is caught by the CLI and by the driver's existing condition 3, for free. A bad effort is caught by nothing at all. So T2's grammar and T3's parse must treat the two fields asymmetrically, and the fail-closed check exists for the effort field's sake.

**T3 cannot report the effort a task actually ran at.** No output field carries it, and thinking-token counts are far too noisy to infer it. The digest column has to read *requested*.

**T3 must filter `modelUsage` before naming a model.** An auxiliary `claude-haiku-4-5` entry rides along on nearly every run, so `keys[0]` is often not the task's model; the entry with non-zero cache tokens is. The numbers still come from `.usage` alone, per the existing comment at `scripts/auto-run.sh:311`.

One question T1 could not answer with the instruments available: whether `effortLevel` in `~/.claude/settings.json` (`xhigh` on this machine) is inherited by a headless run. If it is, every unannotated autonomous task so far has been running at `xhigh`, and T2's "absent means inherit" needs to say inherit *what*.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-08-19 | Model routing is an item-file annotation, not a driver flag | The item is the contract the human writes; the driver and the skills both read it, so specs stay the single place where work is divided and priced |
| 2026-08-19 | Aliases (`sonnet`, `opus`) in annotations, never dated model ids | Ids rot with every release; aliases track the current tier |
| 2026-08-19 | (open — T4) `/next-session` on model mismatch: warn and stop, or warn and proceed | Stopping costs a restart; proceeding silently burns the wrong tier |

## Progress

- 2026-08-19 — item filed from the SyntheticInfrageometry walk-family session (operator request).
- **S1** 2026-08-19 T1 — measured `--model` and `--effort` on `claude -p`; both work, and the two fail in opposite directions. → [HeadlessModelSurface](../../Wiki/Concepts/HeadlessModelSurface.md)
