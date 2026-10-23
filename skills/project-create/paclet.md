# project-create: paclet type

Read after the shared questionnaire and environment check in [SKILL.md](SKILL.md).

## Design notebook and companion

Follow [the paclet design policy](paclet-design.md).
Help the user establish `<PacletName>1.nb` as the human-owned design and `<PacletName>1_notes.nb` as its concise companion during an authorized setup/design task.
Use actual editable notebooks, preserve any existing human notebook, and record the selected current pair in repository guidance.
In a multi-paclet repo, use a separate named pair per paclet.
Use the human design to guide implementation; do not silently advance its iteration or treat all notes as accepted API decisions.
The scaffold writes the root-level design notebook rules into repository guidance; it does not fabricate a completed design notebook.

## 1. Scaffold the paclet

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paclet.sh" \
    "<PacletName>" "<OrgName>" "<topic>" "<Author>" "<email>" "."
```

The script creates the repo root with the paclet directory (double nesting — `<PacletName>/<PacletName>/PacletInfo.wl`, `Kernel/`, `Tests/`), plus `run_tests.wls`, `README.md`, `.gitignore`, and `CLAUDE.md` — it prints what it made.
The package system is the same as paclet-dev's — see [paclet-dev.md § *Package system*](paclet-dev.md#package-system).

## 2. (Optional) Initialize wiki

If the user wants wiki support, run **wiki-init** inside `<PacletName>/`.

## 3. Create initial kernel module

Create at least one kernel module, add `PackageExport` declarations and `::usage` messages.
Each exported function is written to stand on its own — liftable out of the paclet and publishable to the Wolfram Function Repository unchanged, with no private helper it cannot do without; see the generated `CLAUDE.md` § *Exported functions*.
Present for review.

## 4. Create initial tests

Create test files in `<PacletName>/<PacletName>/Tests/`.
