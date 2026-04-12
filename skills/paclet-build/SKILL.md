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

## When to use

- Before publishing — always build and test locally first
- After editing kernel files — rebuild to pick up changes
- When the user wants to test the paclet in a clean environment
