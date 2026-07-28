# new-project: paclet type

Read after the shared questionnaire and environment check in [SKILL.md](SKILL.md).

## 1. Scaffold the paclet

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paclet.sh" \
    "<PacletName>" "<OrgName>" "<topic>" "<Author>" "<email>" "."
```

The script creates the repo root with the paclet directory (double nesting — `<PacletName>/<PacletName>/PacletInfo.wl`, `Kernel/`, `Tests/`), plus `run_tests.wls`, `README.md`, `.gitignore`, and `CLAUDE.md` — it prints what it made.
The package system is the same as paclet-dev's — see [paclet-dev.md § *Package system*](paclet-dev.md#package-system).

## 2. (Optional) Initialize wiki

If the user wants wiki support, run **init-wiki** inside `<PacletName>/`.

## 3. Create initial kernel module

Create at least one kernel module, add `PackageExport` declarations and `::usage` messages.
Present for review.

## 4. Create initial tests

Create test files in `<PacletName>/<PacletName>/Tests/`.
