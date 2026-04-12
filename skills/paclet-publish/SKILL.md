---
name: paclet-publish
description: >
  Build a Wolfram paclet, install locally, and publish to Wolfram Cloud with a
  public install URL. Use when the user says "publish paclet", "upload paclet",
  "deploy paclet", "release paclet", "push paclet to cloud", "share the paclet",
  or "make paclet available".
---

# Publish Paclet

Build a `.paclet` archive, install it locally, and upload it to Wolfram Cloud
as a public object. Produces a URL that anyone can use to install the paclet.

## What you need

1. **Paclet name** — the CamelCase name matching the directory structure.
   If the user doesn't specify, detect from the project's CLAUDE.md or by
   scanning for `PacletInfo.wl` files.

## Pre-publish checklist

Before publishing, verify:

1. **Version bump** — check `PacletInfo.wl` version. If this is an update,
   the version should be higher than the last published version. Ask the user
   if they want to bump it.
2. **Lint code** — if `mcp__Wolfram__CodeInspector` is available, run it on
   each kernel file. Otherwise skip.
3. **Tests pass** — if test files exist (`Tests/*.wlt`), run them:
   - Preferred: `mcp__Wolfram__TestReport` (if available via MCP)
   - Fallback: `wolframscript -f <PacletName>/run_tests.wls`
4. **No uncommitted changes** — warn if there are uncommitted changes in the
   paclet's kernel files.
5. **Generate documentation** — if `mcp__Wolfram__CreateSymbolDoc` is
   available, offer to generate or update documentation notebooks for
   exported symbols before publishing.

## Step-by-step

### 1. Run the publish script

```bash
wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/publish_paclet.wls" "<PacletName>"
```

If the project has its own copy in `Scripts/`:
```bash
wolframscript -f Scripts/publish_paclet.wls "<PacletName>"
```

### 2. Parse the output

The script prints a line:
```
=== PACLET_URL: <url> ===
```

Extract the URL from this line. This is the public cloud URL.

### 3. Report to the user

After successful publish, report:

- **Paclet name and version** — from the build output
- **Cloud URL** — the public URL
- **Install command** — ready to copy:
  ```wolfram
  PacletInstall["<cloud-url>"]
  ```
- **README update** — suggest updating the paclet's README.md with the install
  URL if it differs from the current one.

### 4. Update README (if applicable)

If the paclet has a `README.md`, check whether the install URL in the
Installation section matches the new cloud URL. If not, offer to update it.

## Error handling

- **CloudConnect fails** — the user needs to authenticate. Tell them to run
  `wolframscript -c 'CloudConnect[]'` interactively first.
- **Build fails** — same diagnostics as paclet-build skill.
- **Upload fails** — check cloud connectivity and permissions.

## Cloud object naming

The paclet is uploaded as `<PacletName>.paclet` in the user's cloud home.
This means each publish overwrites the previous version at the same URL —
the URL is stable across versions.
