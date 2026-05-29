Manage prompt-provenance tracking using the `provenance` skill.

Provenance optionally records the prompts/intent behind generated artifacts
(notebooks, functions, wiki articles, work items) in an append-only
`Wiki/Prompts.md` ledger plus an embedded back-pointer in each artifact. It is
off by default, gated by a `Prompt tracking` toggle in the project's `CLAUDE.md`.

Interpret `$ARGUMENTS`:

- `on` / `off` — flip the toggle in `CLAUDE.md` (seed `Wiki/Prompts.md` and its
  `Wiki/Index.md` entry the first time it goes on).
- `status` (or no argument) — report whether tracking is on or off.
- `show` / `log` — print the `Wiki/Prompts.md` ledger.
- `backfill <artifact>` — append a ledger entry and embed a back-pointer for an
  artifact just produced, distilling the intent from the conversation.

Follow the format defined in the `provenance` skill.
