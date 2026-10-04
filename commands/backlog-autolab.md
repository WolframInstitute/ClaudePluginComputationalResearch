Orchestrate an autonomous run of the `Work/` backlog from this chat, using the `backlog-autolab` skill.

Arguments: `[<Item> ...] [--repo <path>] [--parallel N] [--max-tasks N] [--max-minutes M] [--max-tokens T] [--dry-run]` — $ARGUMENTS

This chat is the orchestrator and does no task work itself.
It selects the eligible items, settles permissions in one preflight, makes one worktree per item on `auto/<Item>` under `~/.cache/autolab/`, and dispatches one background worker per task, visible in the Agent map.
It verifies every task, halts only the item that fails, tells you here at once, and ends with a digest per item in `Work/Runs/`.

Use `--dry-run` first if you have not run it before.
The workers end when this chat closes; for a run that must outlive it, use `/backlog-run-scheduled`.
