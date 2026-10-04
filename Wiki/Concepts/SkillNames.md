# Skill and command names

*[ LLM Generated ]*

Since version 6.0.0 every skill and command is named `<area>-<word>`, with a further word only where one is needed.
The area is the README section the skill belongs to, so typing `/<area>-` lists the whole area.
The backlog family carries an item's whole life: `backlog-add`, `backlog-refine`, `backlog-info`, `backlog-board`, `backlog-run`, `backlog-autolab`, `backlog-run-scheduled`, `backlog-review`.
You refine an item (`backlog-refine`) and revise a document (`document-revise`).

The rename is a clean break: no alias stubs, so a stale name resolves to nothing.
Projects scaffolded earlier keep the old names in their own `CLAUDE.md` and `Work/README.md`; they are not rewritten.

## Old to new

| Area | Before 6.0.0 | From 6.0.0 |
|---|---|---|
| backlog | `work` | `backlog-add` |
| | `refine` | `backlog-refine` |
| | (new) | `backlog-info` |
| | `board` | `backlog-board` |
| | `next-session` | `backlog-run` |
| | `autolab` | `backlog-autolab` |
| | `auto-run` | `backlog-run-scheduled` |
| | (new) | `backlog-review` |
| project | `new-project`, `load-project`, `check-env`, `clean` | `project-create`, `project-load`, `project-check-env`, `project-clean` |
| | `start-tour`, `provenance` | `project-tour`, `project-provenance` |
| document | `revise` | `document-revise` |
| wiki | `init-wiki`, `check-wiki`, `update-wiki` | `wiki-init`, `wiki-check`, `wiki-update` |
| | `add-resource`, `search-math`, `search-wolfram` | `wiki-add-resource`, `wiki-search-math`, `wiki-search-wolfram` |
| notebook | `new-notebook` | `notebook-create` |
| paclet | `build-paclet`, `publish-paclet`, `paclet-docs` | `paclet-build`, `paclet-publish`, `paclet-docs` |
| paper | `new-paper`, `new-research-notebook`, `new-research-note` | `paper-create`, `paper-create-notebook`, `paper-create-note` |
| | `cite`, `journal`, `lean` | `paper-cite`, `paper-journal`, `paper-lean` |

Scripts keep their file names (`scripts/auto-run.sh`, `scripts/check-env.sh`).

## Where it came from

Work item [BacklogLifecycle](../../Work/Active/BacklogLifecycle.md): the operator asked for expressive names that start alike, for all skills, and for every step of an item's life to have a skill with a plain name.
