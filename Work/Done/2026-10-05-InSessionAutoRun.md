# InSessionAutoRun

*[ LLM Generated ]*

> Type: feature
<!-- Status is the folder: Active/ Backlog/ Done/ Dropped/. Move the file to change it. -->

## Spec

Origin: "When let to run autonomously, I don't have any control over the instances and the agents. […] I want to click somewhere and see a list of running agents working on my backlog and having some other orchestrating it and giving it backlog tasks." (2026-09-26, operator.)

### The problem

`/auto-run` spawns one headless `claude -p` process per task.
Headless processes are invisible to every surface the operator uses: the VS Code Agent map, the session list, agent view.
The operator cannot see which task is running, cannot read what a worker is doing, and cannot answer it.
The only signal is the digest, read after the run has stopped.

### What was missed in 2026-07-27

[AutonomousPipeline](../../Wiki/Concepts/AutonomousPipeline.md) rejected every in-session mechanism because each "enqueues the prompt back into the current session, so context accumulates".
It checked `CronCreate`, `/loop` and background tasks.
It did not check **subagents** (the `Agent` tool).
A subagent starts cold — its own context, none of the caller's history — which is exactly the property `claude -p` was chosen for.
The caller's context grows only by each worker's short final report.

What a subagent worker can and cannot do was probed in T1: [Subagent workers](../../Wiki/Concepts/AutonomousPipeline.md#subagent-workers--what-the-2026-07-27-survey-missed).

### The deliverable

A command, named **`/autolab`**, run in an ordinary chat.
That chat is the **orchestrator**; it does no task work itself.

0. **Preflight — permissions are settled before the operator leaves.**
   The orchestrator reads every queued task and its item's Spec and lists what the run will need: Bash command families (`wolframscript`, `git`, `python3`, …), MCP tools, web access, writes outside the repo.
   It checks the list against the settings files and the permission mode, and shows the operator **one list of what is missing**, approved once.
   The operator adds the approved rules with `/permissions`; the orchestrator never writes a settings file, re-reads the files to confirm the rules, and at the end lists them for removal; the digest names them.
   It also reports anything that would stop an unattended run outright — an untrusted workspace, a permission mode that prompts.
   After preflight nothing waits for the operator: a task that still hits an unapproved tool halts **its item only**, the others continue, and the summary lists what to approve next time.
1. **Select.** Glob `Work/Active/*.md` for items carrying `> Autonomous: allowed`, as now.
   Unlike `/auto-run`, several eligible items form a **queue** in the order the operator names them, or in `Work/README.md` order.
   The 2026-07-27 reason for refusing a queue — "a wrong autonomous ordering is invisible until the digest" — no longer holds when the operator watches the Agent map.
2. **Dispatch.** Per task, one background subagent named `<Item> Tk`, running `/computational-research:next-session <Item>` on the annotated model and effort.
   The autonomy notice that `auto-run.sh` puts in `--append-system-prompt` goes into the worker's prompt instead, and names the item's worktree: every Bash call starts with `cd <worktree> &&`, and file tools take absolute paths inside it.
3. **Verify.** When a worker returns, the orchestrator runs the checks `auto-run.sh` runs today: a new commit, a new box in `### Done`, `needs-human` in `## Hand-off`, a `(human)` gate on the next task, a dirty tree.
   Pass → dispatch the next task of that item.
   Fail → halt that item and tell the operator in the chat, naming the question or the fault.
4. **Isolate.** The orchestrator makes one git worktree per item, on `auto/<Item>`, under a local path outside the repo — even for a single item.
   Every worker of that item gets its path, so task 2 sees task 1's commits, and workers of different items never share a tree.
   The operator's own checkout is never switched, and the orchestrator reaches the worktrees with `git -C`, never `cd`.
5. **Report.** At the end, the digest `Work/Runs/<timestamp>-<Item>.md` as now, and a short summary in the chat: what landed on which branch, what waits for the operator.

The operator's surface is the chat plus the Agent map.
Nothing is started in a terminal.

### What changes against `/auto-run`

| | `/auto-run` | `/autolab` |
|---|---|---|
| worker | headless `claude -p` process | background subagent |
| visible | no | Agent map, live |
| steer a worker | no | message it (arrives at its next tool round); or stop it |
| items | exactly one | a queue; parallel with `--parallel N` |
| permissions | `--allow` flags, a halt names what was missing | preflight: one list the operator adds with `/permissions` before leaving, listed for removal after; a later denial halts that item only |
| model routing | `--model` from the annotation | `Agent` `model` from the annotation |
| effort routing | `--effort` from the annotation | five worker definitions `agents/autolab-worker-<effort>.md`, one per effort level, and `autolab-worker.md` for an unannotated effort, with the model overridden per task by the `Agent` `model` parameter |
| cost cap | dollars from the run JSON | tokens (`--max-tokens`), summed from each worker's completion notice, which carries no dollar figure |
| survives closing the chat | yes | no — workers live with the orchestrator |

`auto-run.sh` stays, unadvertised, as the headless path: cron can trigger it, and nothing else can.

### Constraints

- **Kernel seats and the shared kernel.** All subagents of one session share its Wolfram MCP kernel, so two workers evaluating at once can overwrite each other's definitions.
  Each `wolframscript` call takes a license seat, and parallel kernels have rebooted this machine before.
  Default `--parallel 1`; the command warns above 2.
- **Worktrees outside cloud-synced folders.** Git surgery inside Dropbox races the sync daemon (see `CLAUDE.md` § *MathNotebook*).
  Worktrees go under `~/.cache/autolab/<Repo>/<Item>`, not next to the repo — which is also why the `Agent` tool's own worktree isolation is not used.
- **No change to `next-session`'s protocol** beyond the source of the autonomy notice.
  A worker is a `next-session` session; the liveness checks stay load-bearing.
- **The `revise` gate stays deferred, not dropped:** branch + digest + the operator's merge.

### Risks

- The orchestrator's context grows by one report per task.
  A long queue may need the orchestrator itself restarted — measure in T4.
- `next-session` and the skills it calls name repo-relative paths (`Work/Active/<Item>.md`).
  A worker must translate each to the worktree; a `haiku` worker did so on a one-task scratch item, which is not yet evidence for a real item — watch in T4.
- Effort routing through agent definitions is documented but unmeasured, as it is headless: nothing reports the effort applied.
- Preflight predicts tool needs from task text, so it will miss some; the item-only halt and the "approve next time" list are what make a miss cheap.

## Tasks

(none left; T5 moved to [ParallelSessions](../Backlog/ParallelSessions.md) on 2026-10-05)

### Done

- [x] T1 (model: opus, effort: high — probes decide the design) — probe the five open mechanics and write the results into `Wiki/Concepts/AutonomousPipeline.md` as a new section, correcting "The harness cannot schedule this": (a) `Agent` `isolation: "worktree"` — which branch it creates, where, whether a second worker can continue the first's branch, what the worker's working directory is; else an orchestrator-made worktree plus absolute paths; (b) effort routing — does a plugin `agents/*.md` definition with an `effort:` field take effect; (c) whether a background worker's permission prompt reaches the operator in VS Code, and what a denial looks like to the orchestrator; (d) whether the orchestrator can message a running worker and get `notify_when_idle`; (e) what usage figure a returning worker reports, for the cap. Correct this Spec where it guessed. (S1)
- [x] T2 (human) — the operator rules on T1's corrections to the Spec. (S1)
- [x] T3 (model: opus, effort: high) — implement: `skills/autolab/SKILL.md` (the orchestrator protocol), `commands/autolab.md`, the autonomy notice moved into the worker prompt in `revise` § *Autonomous mode*, `commands/auto-run.md` pointing at `/autolab`, README and ARCHITECTURE rows. (S2)
- [x] T4 (model: sonnet, effort: high) — serial trial against a throwaway item of three tasks, one of which is built to halt `needs-human`: the Agent map shows each worker, the halt reaches the chat, the branch and digest are right. (S3)
- [x] T6 (human) — operator trial on a real item; rule on whether `/auto-run` is retired from the README. Real-item runs were made in this repo instead of SyntheticInfrageometry: `DocumentMemory` (5 tasks, [digest](../Runs/20261003-225304-DocumentMemory.md)) and `FolderRule` (3 tasks, [digest](../Runs/20261004-201549-FolderRule.md)), both `item-complete` with per-task routing. `/auto-run` is kept for scheduled runs (Decisions, 2026-09-26; README). (closed 2026-10-05)
- [x] T7 (model: sonnet, effort: medium) — release: shipped in 5.3.0 with the marketplace mirror; the blog's 5.3.0 paragraph carries the idea. (closed 2026-10-05)

## Hand-off

Closed 2026-10-05.
The T4 gap is gone: the `computational-research:autolab-worker-*` agent types are reachable, and two real items ran to completion under `/autolab` (T6).
The parallel trial (old T5, `--parallel 2`) never ran; it moved to [ParallelSessions](../Backlog/ParallelSessions.md), which already asks for a trial of several sessions at once.
`AutolabTrialT4` was dropped and its branch discarded.

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-09-26 | Workers are subagents, not background CLI sessions | The VS Code extension does not read `claude agents`; background CLI sessions never reach the Agent map (checked in the extension's code). Subagents do. |
| 2026-09-26 | The command is `/autolab` | Operator's choice: the lab that runs the backlog on its own. |
| 2026-09-26 | Permissions are settled in a preflight, before the operator leaves | Operator: "in the best scenario all permissions are asked and allowed before the human leaves the computer so that everything can be done autonomously." |
| 2026-09-26 | Effort via five agent definitions; worktrees in `~/.cache/autolab/`; a token cap | Plugin internals, left to the LLM by the operator (T2) |
| 2026-09-26 | The operator adds the preflight's rules with `/permissions`; the orchestrator never writes settings | In auto mode the classifier refused the orchestrator's settings write as self-modification (T3); operator's choice |
| 2026-09-26 | Keep `auto-run.sh` as the headless path | Only a process can be triggered by cron; the in-session driver dies with its chat. |
| 2026-10-05 | The parallel trial moves to `ParallelSessions`; this item closes | Serial runs on real items succeeded twice; parallelism is the subject of `ParallelSessions` (operator's choice) |
| 2026-09-26 | T4 substituted `general-purpose` subagents for the unreachable `autolab-worker-<effort>` agent types, rather than stopping to ask before proceeding | The gap (unpushed commits, stale marketplace cache) blocks only effort-via-agent-definition, which T1 had already flagged unmeasured; the rest of the loop — dispatch, verify, `needs-human` halt, worktree isolation — does not depend on it, so measuring that much live was worth more than halting T4 outright. |

## Progress

- 2026-09-26 — item filed from the Infrageometry session on agent visibility (operator request); four capability probes run.
- **S1** 2026-09-26 T1 — six probes run; Spec corrected (own worktrees, token cap, effort via agent definitions, prompts not relied on). → [Subagent workers](../../Wiki/Concepts/AutonomousPipeline.md#subagent-workers--what-the-2026-07-27-survey-missed)
- **S1** 2026-09-26 T2 — operator approved the corrected Spec and added the permission preflight (step 0).
- **S2** 2026-09-26 T3 — `/autolab` built: skill, command, six worker definitions, notice moved into the worker prompt. → [Subagent workers § Permissions](../../Wiki/Concepts/AutonomousPipeline.md#permissions--the-orchestrator-cannot-write-them)
- **S3** 2026-09-26 T4 — serial trial run by hand on `AutolabTrialT4` (plugin agents unreachable this session); halt confirmed live, loop otherwise measured. → [Subagent workers § The serial trial](../../Wiki/Concepts/AutonomousPipeline.md#the-serial-trial--a-plugin-agent-definition-is-not-reachable-until-it-is-pushed)
- 2026-10-05 — refined against the two real `/autolab` runs: T6, T7 closed with evidence; T5 moved to `ParallelSessions`; item done.
