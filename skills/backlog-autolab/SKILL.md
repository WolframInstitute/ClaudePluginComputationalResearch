---
name: backlog-autolab
description: >
  Work the Work/ backlog autonomously from an ordinary chat, where the operator
  can watch it: this chat becomes the orchestrator and dispatches one background
  subagent per task, each a cold backlog-run run in the item's own git worktree
  on work/<Item>, visible live in the Agent map and steerable by message. Settles
  permissions in one preflight before the operator leaves, queues several
  eligible items, verifies every task the way backlog-run-scheduled does, halts only the item
  that fails, and ends with a digest per item. Use when the user says "autolab",
  "run the backlog", "let the agents work the backlog", "work these items
  autonomously here", "work the queue while I'm away", or runs /backlog-autolab.
---

# Autolab

This chat becomes the **orchestrator** of an autonomous run.
It does no task work itself.
Each task is done by a background subagent — a **worker** — which starts cold, as a fresh session does, and runs `backlog-run` for one task in its item's worktree.
The operator watches the workers in the Agent map, and reads halts in this chat.

Why subagents and not `claude -p`, and what a worker can and cannot do: [Wiki/Concepts/AutonomousPipeline.md § *Subagent workers*](../../Wiki/Concepts/AutonomousPipeline.md#subagent-workers--what-the-2026-07-27-survey-missed).
The headless driver `scripts/auto-run.sh` stays for cron, the one trigger a chat cannot serve.

## When to use

- The operator wants items worked unattended and wants to see and steer the workers.
- Several eligible items should run as a queue, or side by side.
- Not for one interactive task — that is `backlog-run`.

## Arguments

`/backlog-autolab [<Item> ...] [--repo <path>] [--parallel N] [--max-tasks N] [--max-minutes M] [--max-tokens T] [--dry-run]`

| argument | default | meaning |
|---|---|---|
| `<Item> ...` | every eligible item | the queue, in the order given |
| `--repo` | the git root of this session's directory | the repo whose `Work/` is run |
| `--parallel` | `1` | items in flight at once; each item still runs its tasks in order |
| `--max-tasks` | `3` | tasks per item |
| `--max-minutes` | `90` | wall clock per item |
| `--max-tokens` | `4000000` | tokens per item, summed from the workers' completion notices — provisional until T4 of `InSessionAutoRun` measures a real task |
| `--dry-run` | off | selection and preflight only; no worktree, no worker |

## Steps

The orchestrator follows two rules throughout.
It reaches other trees with `git -C <path>` and absolute paths, **never `cd`**: one `cd` in this shell moves the session's working directory for good.
And it never cleans up after a failure — no `git reset`, no `git worktree remove --force`, no branch deletion.

### 1. Select

- Resolve the repo; stop if it is not a git repository or has no `Work/`.
- **Named items**: each must be `Work/Ready/<Item>.md`, where the folder is the operator's approval, or `Work/Active/<Item>.md` carrying `> Autonomous: allowed`.
  Any that is not stops the run before anything starts, naming it — the operator is still at the keyboard, and nothing has cost anything yet.
- **No items named**: every `Work/Active/*.md` carrying the marker, then every `Work/Ready/*.md`, each group in `Work/README.md` order, then any not listed there, alphabetically.
  None → stop and say so.
- Each item's branch is `work/<Item>`, the one name every session uses ([backlog-run § *Claim it*](../backlog-run/SKILL.md#claim-it)); when only an unmerged `auto/<Item>` exists, made before the rename, that is the item's branch until it is merged, and `<branch>` below is whichever applies.
- Read each item's state from `<branch>` when it exists (`git -C <repo> show <branch>:Work/Active/<Item>.md` — a Ready item an earlier session started is in `Active/` there), since earlier unmerged work lives there; else from the checkout.
- An item is **not runnable**, and is reported and left out, when its first unchecked task carries `(human)`, when its `## Hand-off` already holds a `needs-human` line, or when that task's routing annotation does not parse.
  The annotation grammar is in [backlog-add § *The routing annotation*](../backlog-add/SKILL.md#the-routing-annotation); `model` must be one of `haiku`, `sonnet`, `opus`, `fable`, since those are the values the `Agent` tool takes.

### 2. Preflight — settle permissions before the operator leaves

After this step nothing waits for the operator.
Every worker is part of this session, so its permissions come from this session's settings — `~/.claude/settings.json` and the `.claude/settings.json` and `.claude/settings.local.json` of the directory this chat was opened in — never from the target repo's.

1. **List what the run needs.**
   Read each queued item's `## Spec` and its unchecked tasks up to the task cap, and name the Bash command families, MCP tools, web access and writes they imply.
   Every run needs, beyond that:
   - `Skill`, and `git` `status`, `add`, `commit`, `mv`, `log`, `diff`, `show`, `rev-parse`;
   - `Read`, `Edit` and `Write` on `~/.cache/autolab/**`, which lies outside this session's directory;
   - the Wolfram MCP tools, when a task touches Wolfram code (see `CLAUDE.md` § *Wolfram Kernel Execution Policy*).
2. **Check the list** against the `allow`, `ask` and `deny` rules of the three files.
   A need that matches an `ask` rule counts as missing: unattended, nobody answers it.
3. **Check the permission mode**, from this session's own context and `defaultMode`:
   - `default` — every uncovered call prompts, so the run cannot be left; stop and say so;
   - `acceptEdits` — every Bash call needs a rule;
   - `auto` — an uncovered call goes to the classifier, which can deny it; list the needs anyway, since a rule skips the classifier;
   - `bypassPermissions` — nothing to add; say that only the branch bounds the run.
4. **Present one list** — the missing rules as one block ready to paste, and every blocker.
   Blockers also include: `--parallel` above `2` (workers share one Wolfram kernel, and parallel kernels have rebooted this machine); a checkout with uncommitted changes (the run branches from `HEAD` and will not see them); a repo with `.gitmodules` (submodules in a worktree are untried).
5. **The operator adds the rules**, with `/permissions`, to this project's local settings.
   The orchestrator never writes a settings file itself: in auto mode the classifier refuses that as self-modification (measured 2026-09-26).
6. **Re-read the three files** and confirm each rule is there.
   A rule the operator declined is noted; the items that need it still run, and halt alone if they hit it.

With `--dry-run`, stop here and show the queue: per item the branch, the worktree path, the next task and its routing.

### 3. Isolate — one worktree per item

The worktree is `~/.cache/autolab/<Repo>/<Item>`, `<Repo>` being the repo folder's name.
It lives outside the repo because git surgery inside a cloud-synced folder races the sync daemon, and the `Agent` tool's own `isolation: "worktree"` is not used for the same reason.

This is the claim of [backlog-run § *Claim it*](../backlog-run/SKILL.md#claim-it), held by the orchestrator for the whole run.

- `<branch>` exists → `git -C <repo> worktree add <path> <branch>`.
- Otherwise → `git -C <repo> worktree add -b work/<Item> <path> HEAD`.
- If git refuses because the branch is already used by a worktree, another session holds the item: halt it `worktree-busy`, naming that worktree, and never work in it.
  That includes a worktree left at `<path>` by an earlier run; the operator releases it with `git worktree remove <path>`.

The operator's checkout is never switched.

**Start a Ready item** the way `auto-run.sh` does, in the worktree and on its branch: `git mv Work/Ready/<Item>.md Work/Active/<Item>.md`, add `> Autonomous: allowed` on the line after `> Type:` unless it is there, and commit `chore(work): start <Item> from Ready`.
The marker keeps the item eligible for later runs once it has left `Ready/`; an item with no `> Type:` line halts `bad-annotation`.
In the operator's checkout the item stays in `Ready/` until the branch is merged.

### 4. Dispatch

Per task, record the worktree's `HEAD`, the number of boxes in the item's `### Done`, and the time, then make one `Agent` call:

| parameter | value |
|---|---|
| `description` | `<Item> Tk` — the label in the Agent map |
| `subagent_type` | `computational-research:autolab-worker-<effort>` from the annotation; `computational-research:autolab-worker` when it names no effort |
| `model` | the annotation's model; omitted when it names none, so the worker inherits this session's |
| `run_in_background` | `true` |
| `prompt` | the [worker prompt](#the-worker-prompt), filled in |

Keep up to `--parallel` items in flight, one worker each.
Then **end the turn**: a completion notice wakes the orchestrator, so it neither polls nor waits.

While workers run, the operator talks to the orchestrator in this chat.
To steer a worker, send it a message with `SendMessage` (it arrives at the worker's next tool round); to stop one, `TaskStop`, which halts its item `stopped`.

### 5. Verify — on every completion notice

Add the notice's `subagent_tokens` to the item's total, then check, in this order.
Every check reads the worktree with `git -C` and absolute paths.

| check | halt reason |
|---|---|
| the report says `outcome: denied` | `permission-denied` — record the rule under *approve next time* |
| the report says `outcome: fault`, or the worker ended in an error | `fault` |
| the tree is dirty, ignoring `Work/Runs/` | `dirty-tree` |
| `HEAD` did not move | `no-commit` |
| the item file is in none of `Work/Active/<Item>.md`, `Work/UnderReview/<Item>.md`, `Work/Done/*-<Item>.md` | `item-vanished` |
| `### Done` gained no box | `no-box` |
| `## Hand-off` holds `needs-human` | `needs-human` |
| no unchecked task remains | `item-complete` — the success exit |
| a cap is reached | `cap-tasks`, `cap-minutes` or `cap-tokens` |
| the next task carries `(human)` | `task-gated` |
| the next task's annotation does not parse | `bad-annotation` |

Nothing tripped → dispatch the item's next task (step 4).
A halt → tell the operator **at once**, in one short message: the item, the reason, and for `needs-human` the question quoted.
For `fault`, `no-commit` or `no-box` on a `haiku` or `sonnet` worker, add the escalation — the annotation to re-run the task at — since a cheap tier fails by producing confident wrong output that a re-run at the same tier repeats.
Then dispatch the next queued item into the free slot.

The halt stops **that item only**; the others run on.

### 6. Report

When no item is in flight and the queue is empty:

1. **One digest per item** — `Work/Runs/<YYYYMMDD-HHMMSS>-<Item>.md` in the operator's checkout, gitignored — in the shape `auto-run.sh` writes: item, branch, worktree, times, tasks run, stop reason, tokens; per task the verdict, the model routed, the effort **requested** (nothing reports the effort applied), tokens, tool uses and duration; the commits and files since the run began (`git -C <worktree> log --oneline <start>..HEAD`); the `## Hand-off` before and after.
   Plus two lists: the rules the operator added for this run, and the rules to approve next time.
2. **The worktrees** — a clean one is removed with `git -C <repo> worktree remove <path>`, no `--force`; its branch stays.
   A dirty one stays, and the summary names its path.
3. **A short summary in the chat**, per item: the branch, its commits, the stop reason.
   Then what waits for the operator: review each finished item with `/backlog-review <Item>`, which merges `<branch>` (the merge is the `document-revise` approval), answer each hand-off question, remove this run's rules with `/permissions`, and add the rules to approve next time.

## The worker prompt

The autonomy notice that `auto-run.sh` puts into the system prompt goes at the top of the worker's prompt instead: a session cannot tell it is unattended unless it is told ([document-revise § *Autonomous mode*](../document-revise/SKILL.md#autonomous-mode--the-gate-is-deferred-not-dropped)).
Fill in `<Item>`, `<Tk>`, `<branch>`, `<Worktree>` (absolute) and `<Home>` (this session's directory, where a worker's Bash starts):

```
You are an autonomous worker dispatched by /backlog-autolab. No user reads this transcript; the orchestrator reads only your final report.

Item: <Item>. Task: <Tk>. Branch: <branch>. Worktree: <Worktree>.
The worktree is the repository you work in. Never touch any other checkout.
- Your Bash working directory resets to <Home> on every call. Start every Bash command with `cd <Worktree> &&`.
- Give file tools absolute paths under <Worktree>. Every repo-relative path a skill names — Work/Active/<Item>.md, Wiki/..., Code/... — means <Worktree>/<that path>.

Invoke the Skill tool with skill `computational-research:backlog-run` and args `<Item>`, and do exactly that one task.
Follow the document-revise skill's section "Autonomous mode — the gate is deferred, not dropped": do not stop to present; commit unconditionally on <branch> in the worktree; if the task turns on a decision you would otherwise ask about, write the question into ## Hand-off on a line containing `needs-human:`, commit, and stop.
If a tool call is denied, do not work around it: write `needs-human: permission — <Tool(pattern)>` into ## Hand-off, commit, and stop.

End with exactly these four lines and nothing else:
task: <Tk>
commit: <short sha of your last commit, or none>
outcome: done | needs-human | denied | fault
note: <one line — for denied, the Tool(pattern) that was refused>
```

The four-line report is a budget, not a style: the orchestrator's context grows by every word a worker returns.

## Integration with other skills

- `backlog-run` is what each worker runs; its protocol is unchanged, and its commit and box are what step 5 checks.
- `document-revise` § *Autonomous mode* governs every worker; the gate is deferred to branch, digest and merge.
- `backlog-add` writes the markers and the routing annotations the queue reads.
- The worker definitions are `agents/autolab-worker*.md` in this plugin — one per effort level, and one that inherits.
- `backlog-run-scheduled` is the headless path, for cron.

## When NOT to use

- A single task the operator wants to watch closely — run `/backlog-run` in a fresh chat.
- A run that must outlive this chat: workers end when it closes. Use `/backlog-run-scheduled`, or cron.
- Creating or re-scoping items — that is `backlog-add`.
