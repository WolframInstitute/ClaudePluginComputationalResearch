# new-project: paclet-dev type

Read after the shared questionnaire and environment check in [SKILL.md](SKILL.md).

## 1. Scaffold the dev repo

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-paclet-dev.sh" \
    "<DevRepoName>" "<PacletName1,PacletName2>" \
    "<OrgName>" "<GitHubUser>" "<topic>" "<Author>" "<email>" "."
```

The script creates one submodule directory per paclet (each with the paclet root, `run_tests.wls`, `README.md`, `.gitignore`), plus `Code/` for experimental work, `Scripts/recover_resources.sh`, `.gitmodules`, `.gitignore`, and `CLAUDE.md` — it prints what it made.

### Triple nesting convention

The paclet name appears three times in the path — submodule, paclet, main loader (`PacletName/PacletName/Kernel/PacletName.wl`); detection is specified once in [build-paclet § *Detecting the paclet directory*](../build-paclet/SKILL.md#detecting-the-paclet-directory).

- Level 1 (`PacletName/`): the git submodule directory in the dev repo
- Level 2 (`PacletName/PacletName/`): the actual paclet root containing PacletInfo.wl, Kernel/, Tests/
- The submodule repo root also has `run_tests.wls`, `README.md`, `.gitignore`

### Package system

Uses `Package[]` / `PackageExport` / `PackageScope` (not BeginPackage/EndPackage).

Main loader (`Kernel/PacletName.wl`):

```wolfram
Package["OrgName`PacletName`"]

PackageExport[SymbolOne]
PackageExport[SymbolTwo]

ClearAll["OrgName`PacletName`**`*", "OrgName`PacletName`*"]
```

Each kernel module:

```wolfram
Package["OrgName`PacletName`"]

PackageScope[helperName]

(* definitions *)
```

Usage.wl — all `::usage` strings, also starts with `Package["OrgName`PacletName`"]`.

## 2. Initialize the wiki

Use **init-wiki** inside `<DevRepoName>/`.
The domain folders should reflect the paclet's subject matter.

## 3. Create initial kernel modules

For each paclet, create at least one kernel module beyond the main loader:

- `<PacletName>/<PacletName>/Kernel/<ModuleName>.wl` — core functionality

Each module starts with:

```wolfram
Package["<OrgName>`<PacletName>`"]
```

Add corresponding `PackageExport` declarations in the main loader.
Add `::usage` messages in `Usage.wl`.

Present the code to the user for review (revision workflow).

## 4. Create experimental code

Populate `Code/` with exploratory scripts that use the paclet:

```wolfram
PacletDirectoryLoad[ "<PacletName>/<PacletName>" ]
Needs[ "<OrgName>`<PacletName>`" ]

(* experimental code here *)
```

## 5. Create initial tests

For each kernel module, create a test file:

- `<PacletName>/<PacletName>/Tests/<ModuleName>Tests.wlt`

Use `VerificationTest[...]` format.
Test files mirror kernel files: `NameTests.wlt` tests `Name.wl`.

## 6. Download reference papers

Same as [research.md](research.md) step 5.

## 7. Create initial wiki articles and notebook

Same as [research.md](research.md) steps 4 and 6.

## 8. Git setup guidance

After scaffolding, tell the user:

- The directory structure and triple-nesting convention
- How to initialize git repos (dev repo + each paclet as separate repo)
- How to set up submodules once the org repos exist on GitHub
- How to load paclets during development

Example git setup:

```bash
cd <DevRepoName> && git init && git config core.hooksPath .githooks
# (.githooks/commit-msg enforces Conventional Commits — scaffolded already)
# For each paclet (each becomes its own repo, so activate its hook too):
cd <PacletName> && git init && git config core.hooksPath .githooks && git remote add origin git@github.com:<OrgName>/<PacletName>.git && cd ..
# Then register submodules and set up dev repo remote
git remote add origin git@github.com:<GitHubUser>/<DevRepoName>.git
```

The scaffold drops `.githooks/commit-msg` into each repo; `core.hooksPath` is set automatically when the scaffold runs inside an existing repo, otherwise run `git config core.hooksPath .githooks` once after `git init`.
