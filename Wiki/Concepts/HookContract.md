# The Claude Code hook contract

*[ LLM Generated ]*

Claude Code hooks receive the tool call as JSON on **stdin**, not as positional arguments.
A hook script that reads `$1`/`$2` runs without error and always sees empty values — it is silently inert, which is why such a bug can survive indefinitely: the failure mode is "allows everything", indistinguishable from working until someone pipes test input.

## Details

The stdin JSON for a `PreToolUse` hook carries `tool_name` and `tool_input` (plus session metadata); for a `Read` call the path is `tool_input.file_path`.

To **block** the call, the hook exits with code 2 and writes the explanation to **stderr** — stdout is not surfaced to the model on a block.
Exit 0 allows the call.
Malformed input should fail open (exit 0) so a harness change never bricks every tool call.

Scope a hook to one tool with a `"matcher"` field on the `hooks.json` entry (e.g. `"matcher": "Read"`); without it the command runs on **every** tool use.

The plugin's `hooks/check-nb-read.sh` (blocks direct reads of `.nb` files) was inert from its introduction until 2026-07-28 for exactly the positional-argument reason; the 2026-07-28 audit found it by piping test JSON.
Its test set doubles as the reference check for any future hook:
a `.nb` path must exit 2 with the message on stderr, a non-`.nb` path must exit 0, and a non-JSON stdin must exit 0.

## See also

- [The autonomous next-session pipeline](AutonomousPipeline.md) — the other place the plugin depends on harness behavior that must be verified live rather than assumed
