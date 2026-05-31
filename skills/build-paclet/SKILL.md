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
   If the user doesn't specify, detect from the project's CLAUDE.md or by
   scanning for `PacletInfo.wl` files.

## Kernel execution (license-aware)

Prefer the AgentTools MCP (`mcp__Wolfram__WolframLanguageEvaluator` and the
other `mcp__Wolfram__*` tools) for the whole build — it reuses one persistent
kernel and consumes no extra license seat. Only fall back to `wolframscript` if
the MCP is unavailable, and before spawning it check headroom via the MCP:

```wolfram
With[{free = $MaxLicenseProcesses - $LicenseProcesses}, free]
```

If `free <= 0`, do **not** spawn `wolframscript` — it will fail with a license
error. Build through the MCP instead, or tell the user a seat must be freed.

## Detecting the paclet directory

- **Dev repo** (triple nesting): `<PacletName>/<PacletName>/PacletInfo.wl`
- **Standalone** (double nesting): `<PacletName>/PacletInfo.wl`
- **Direct path**: if given a path containing `PacletInfo.wl`, use it directly

Resolve the absolute `<pacletDir>` (the directory containing `PacletInfo.wl`)
once, then use it in the build below.

## Step-by-step (preferred: MCP)

### 1. Lint (optional)

Use `mcp__Wolfram__CodeInspector` on each kernel file to catch syntax/style
issues before building.

### 2. Build + install via the evaluator

Run the build in the persistent kernel with
`mcp__Wolfram__WolframLanguageEvaluator` — same logic as
[paclet_common.wl](../../scripts/paclet_common.wl), no new process:

```wolfram
Module[{src = "<pacletDir>", tmp, archive},
  tmp = FileNameJoin[{$TemporaryDirectory, FileBaseName[src] <> "-build"}];
  If[DirectoryQ[tmp], DeleteDirectory[tmp, DeleteContents -> True]];
  CreateDirectory[tmp];
  CopyFile[FileNameJoin[{src, "PacletInfo.wl"}], FileNameJoin[{tmp, "PacletInfo.wl"}]];
  CopyDirectory[FileNameJoin[{src, "Kernel"}], FileNameJoin[{tmp, "Kernel"}]];
  If[DirectoryQ[FileNameJoin[{src, "Tests"}]],
     CopyDirectory[FileNameJoin[{src, "Tests"}], FileNameJoin[{tmp, "Tests"}]]];
  (* Add Documentation/ only when the user asked to bundle docs: *)
  (* CopyDirectory[FileNameJoin[{src,"Documentation"}], FileNameJoin[{tmp,"Documentation"}]]; *)
  archive = CreatePacletArchive[tmp];
  DeleteDirectory[tmp, DeleteContents -> True];
  PacletInstall[archive, ForceVersionInstall -> True]]
```

`PacletInstall` returns the installed paclet object — report its `"Name"`,
`"Version"`, and `"Location"`, plus the archive path.

**Documentation is excluded by default** for fast iterative builds. When the
user wants docs bundled, uncomment the `Documentation/` copy line.

### 3. Test (optional)

Use `mcp__Wolfram__TestReport` on test files (`.wlt`) — faster and integrated,
and it runs in the same persistent kernel.

### 4. Verify it loads

```wolfram
Needs["<OrgName>`<PacletName>`"]
```

via the evaluator. If it errors, check `PacletInfo.wl` validity, that `Kernel/`
has the main loader, and kernel-file syntax (`mcp__Wolfram__CodeInspector`).

## Fallback: wolframscript (MCP unavailable)

Only if the MCP is unavailable **and** a license seat is free (see the headroom
check above):

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/build_paclet.wls" "<PacletName>"
```

If the project has its own copy in `Scripts/`, use `Scripts/build_paclet.wls`.
Add `--with-docs` to bundle the `Documentation/` directory. The script prints
the paclet directory, archive path, installed name/version, and install
location. Verify with `wolframscript -c 'Needs["<OrgName>`<PacletName>`"]'`.

## When to use

- Before publishing — always build and test locally first
- After editing kernel files — rebuild to pick up changes
- When the user wants to test the paclet in a clean environment
