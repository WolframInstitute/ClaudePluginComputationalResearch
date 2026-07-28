---
name: build-paclet
description: >
  Build a Wolfram paclet archive and install it locally. Use when the user says
  "build paclet", "build the paclet", "install paclet locally", "make paclet",
  "create paclet archive", or "test the paclet install".
---

# Build Paclet

Build a `.paclet` archive from the paclet source and install it locally.

## What you need

1. **Paclet name** — the CamelCase name matching the directory structure.
   If the user doesn't specify, detect from the project's CLAUDE.md or by scanning for `PacletInfo.wl` files.

## Kernel execution (license-aware)

Prefer the AgentTools MCP (`mcp__Wolfram__WolframLanguageEvaluator` and the other `mcp__Wolfram__*` tools) for the whole build; before any `wolframscript` fallback, check headroom per the authoritative policy in [`CLAUDE.md` § *Wolfram Kernel Execution Policy*](../../CLAUDE.md#wolfram-kernel-execution-policy).

## Detecting the paclet directory

- **Dev repo** (triple nesting): `<PacletName>/<PacletName>/PacletInfo.wl`
- **Standalone** (double nesting): `<PacletName>/PacletInfo.wl`
- **Direct path**: if given a path containing `PacletInfo.wl`, use it directly

Resolve the absolute `<pacletDir>` (the directory containing `PacletInfo.wl`) once, then use it in the build below.

## Step-by-step (preferred: MCP)

### 1. Lint (optional)

Use `mcp__Wolfram__CodeInspector` on each kernel file to catch syntax/style issues before building.

### 2. Build + install via the evaluator

Run the build in the persistent kernel with `mcp__Wolfram__WolframLanguageEvaluator` — same logic as [paclet_common.wl](../../scripts/paclet_common.wl), no new process:

```wolfram
Module[{src = "<pacletDir>", withDocs = False, tmp, items, archive},
  tmp = FileNameJoin[{$TemporaryDirectory, FileBaseName[src] <> "-build"}];
  If[DirectoryQ[tmp], DeleteDirectory[tmp, DeleteContents -> True]];
  CreateDirectory[tmp];
  items = Select[FileNameTake /@ FileNames["*", src],
    ! StringStartsQ[#, "."] && # =!= "build" &];
  If[! withDocs, items = DeleteCases[items, "Documentation"]];
  Scan[{item} |-> With[{from = FileNameJoin[{src, item}], to = FileNameJoin[{tmp, item}]},
      If[DirectoryQ[from], CopyDirectory[from, to], CopyFile[from, to]]], items];
  Scan[DeleteFile, FileNames[".DS_Store", tmp, Infinity]];
  archive = CreatePacletArchive[tmp];
  DeleteDirectory[tmp, DeleteContents -> True];
  PacletInstall[archive, ForceVersionInstall -> True]]
```

`PacletInstall` returns the installed paclet object — report its `"Name"`, `"Version"`, and `"Location"`, plus the archive path, and say which top-level items were staged.

**Stage every top-level item, not a fixed list.**
A paclet may ship `FrontEnd/` (palettes, stylesheets), `Assets/`, `Documentation/` or anything else its `PacletInfo.wl` declares.
An earlier version of this recipe copied only `Kernel/` and `Tests/`, which silently installed MathNotebook with no palette and no stylesheets — the paclet loaded, so nothing looked wrong.
Dotfiles and `build/` are repo artifacts and stay out.

**Documentation is excluded by default here** for fast iterative builds — set `withDocs = True` (or pass `--with-docs` to the script) to include it.
`publish-paclet` is the opposite: it bundles docs by default, since a published paclet should ship them.

### 3. Test (optional)

Use `mcp__Wolfram__TestReport` on test files (`.wlt`) — faster and integrated, and it runs in the same persistent kernel.

### 4. Verify it loads

```wolfram
Needs["<OrgName>`<PacletName>`"]
```

via the evaluator.
If it errors, check `PacletInfo.wl` validity, that `Kernel/` has the main loader, and kernel-file syntax (`mcp__Wolfram__CodeInspector`).

If docs were bundled, also run the [docs-resolution check](#docs-resolution-check) below on at least one page.

## Docs-resolution check

The canonical verification that bundled documentation actually resolves — `paclet-docs` and `publish-paclet` reference it here.
After installing with docs bundled, run `PacletDataRebuild[]`, then for every documented symbol:

```wolfram
Documentation`ResolveLink["paclet:<Pub>/<Paclet>/ref/<Symbol>"]
```

Each must return the path of an existing file **under the installed paclet** (`$UserBasePacletsDirectory`), not under the source tree.
`Null` means the page is not wired: check the `Documentation` extension in `PacletInfo.wl`, then `pacletName` / `publisherID`, then the URI (see the [paclet-docs](../paclet-docs/SKILL.md) skill).
**Do not substitute `Information` or `?Symbol`** — they print the kernel's `::usage` string whether or not a page exists (on MathNotebook, `ConvertMathCells` showed a full usage line while having no page at all); it is a test that cannot fail.

## Fallback: wolframscript (MCP unavailable)

Only if the MCP is unavailable **and** a license seat is free (see the headroom check above):

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/build_paclet.wls" "<PacletName>"
```

If the project has its own copy in `Scripts/`, use `Scripts/build_paclet.wls`.
Add `--with-docs` to bundle the `Documentation/` directory.
The script prints the paclet directory, archive path, installed name/version, and install location.
Verify with `wolframscript -c 'Needs["<OrgName>`<PacletName>`"]'`.

## When to use

- Before publishing — always build and test locally first
- After editing kernel files — rebuild to pick up changes
- When the user wants to test the paclet in a clean environment
