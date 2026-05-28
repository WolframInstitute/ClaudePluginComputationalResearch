---
name: paclet-build
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

## How it works

The script auto-detects the paclet directory layout:
- **Dev repo** (triple nesting): `<PacletName>/<PacletName>/PacletInfo.wl`
- **Standalone** (double nesting): `<PacletName>/PacletInfo.wl`
- **Direct path**: if given a path containing `PacletInfo.wl`, uses it directly

## Step-by-step

### 1. Run the build script

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/build_paclet.wls" "<PacletName>"
```

If the project has its own copy in `Scripts/`:
```bash
wolframscript -f Scripts/build_paclet.wls "<PacletName>"
```

**Documentation is excluded by default** for fast iterative builds. To bundle the
paclet's `Documentation/` directory into the archive, add `--with-docs`:
```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/build_paclet.wls" "<PacletName>" --with-docs
```

### 2. Report results

The script outputs:
- Paclet directory used
- Archive file path (`.paclet`)
- Installed name and version
- Install location

If the build fails, check:
- `PacletInfo.wl` exists and is valid
- `Kernel/` directory exists with at least the main loader
- No syntax errors in kernel files (run `wolframscript -c 'Needs["Org\`Paclet\`"]'`)

### 3. Verify

After building, optionally verify the paclet loads:

```bash
wolframscript -c 'Needs["<OrgName>`<PacletName>`"]; Print["OK"]'
```

## Pre-build checks (via MCP)

If the official Wolfram MCP has `WolframPacletDevelopment` tools available:

1. **Lint code** — use `mcp__Wolfram__CodeInspector` on each kernel file
   to catch syntax errors and style issues before building.
2. **Run tests** — use `mcp__Wolfram__TestReport` on test files (`.wlt`)
   instead of calling `wolframscript -f run_tests.wls`. Faster and
   integrated.

These are optional enhancements — the build script works without them.

## When to use

- Before publishing — always build and test locally first
- After editing kernel files — rebuild to pick up changes
- When the user wants to test the paclet in a clean environment
