---
name: publish-paclet
description: >
  Build a Wolfram paclet, install locally, and publish to Wolfram Cloud with a
  public install URL. Use when the user says "publish paclet", "upload paclet",
  "deploy paclet", "release paclet", "push paclet to cloud", "share the paclet",
  or "make paclet available".
---

# Publish Paclet

Build a `.paclet` archive, install it locally, and upload it to Wolfram Cloud
as a public object. Produces a URL that anyone can use to install the paclet.

## Kernel execution (license-aware)

Prefer the AgentTools MCP (`mcp__Wolfram__WolframLanguageEvaluator` and the
other `mcp__Wolfram__*` tools) for build, install, and cloud upload — it reuses
one persistent kernel and consumes no extra license seat. Only fall back to
`wolframscript` if the MCP is unavailable, and before spawning it check headroom
via the MCP:

```wolfram
With[{free = $MaxLicenseProcesses - $LicenseProcesses}, free]
```

If `free <= 0`, do **not** spawn `wolframscript` — it will fail with a license
error. Publish through the MCP instead, or tell the user a seat must be freed.

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
   exported symbols before publishing. Documentation is **not bundled by
   default** — pass `--with-docs` (see below) to include it in the published paclet.

## Step-by-step (preferred: MCP)

### 1. Build + install

Build and install locally via the evaluator exactly as in the
[build-paclet](../build-paclet/SKILL.md) skill (`CreatePacletArchive` +
`PacletInstall[..., ForceVersionInstall -> True]` in the persistent kernel).
Keep the resulting archive path.

### 2. Upload to Wolfram Cloud via the evaluator

Run in the persistent kernel with `mcp__Wolfram__WolframLanguageEvaluator` —
mirrors [publish_paclet.wls](../../scripts/publish_paclet.wls):

```wolfram
CloudConnect[];
With[{obj = CloudObject["<PacletName>.paclet", Permissions -> "Public"]},
  CopyFile["<archivePath>", obj, OverwriteTarget -> True];
  First[obj]]
```

The returned string is the **public cloud URL** — stable across versions, since
each publish overwrites the same cloud object.

> **Fallback (MCP unavailable, and a seat is free per the headroom check):** run
> `wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/publish_paclet.wls" "<PacletName>"`
> (or `Scripts/publish_paclet.wls`; add `--with-docs` to bundle `Documentation/`).
> The script prints `=== PACLET_URL: <url> ===` — extract the URL from that line.

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

- **CloudConnect fails** — the user needs to authenticate. Have them evaluate
  `CloudConnect[]` via the MCP (or `wolframscript -c 'CloudConnect[]'`)
  interactively first.
- **Build fails** — same diagnostics as build-paclet skill.
- **Upload fails** — check cloud connectivity and permissions.

## Cloud object naming

The paclet is uploaded as `<PacletName>.paclet` in the user's cloud home.
This means each publish overwrites the previous version at the same URL —
the URL is stable across versions.
