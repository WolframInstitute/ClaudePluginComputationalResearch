---
name: publish-paclet
description: >
  Build a Wolfram paclet, install locally, and publish to Wolfram Cloud with a
  public install URL. Use when the user says "publish paclet", "upload paclet",
  "deploy paclet", "release paclet", "push paclet to cloud", "share the paclet",
  or "make paclet available".
---

# Publish Paclet

Build a `.paclet` archive, install it locally, and upload it to Wolfram Cloud as a public object.
Produces a URL that anyone can use to install the paclet.
Publishing is externally visible — the [revise](../revise/SKILL.md) loop applies: present what will be uploaded and wait for the go-ahead.

## Kernel execution (license-aware)

Prefer the AgentTools MCP (`mcp__Wolfram__WolframLanguageEvaluator` and the other `mcp__Wolfram__*` tools) for build, install, and cloud upload; before any `wolframscript` fallback, check headroom per the authoritative policy in [`CLAUDE.md` § *Wolfram Kernel Execution Policy*](../../CLAUDE.md#wolfram-kernel-execution-policy).

## What you need

1. **Paclet name** — the CamelCase name matching the directory structure.
   If the user doesn't specify, detect from the project's CLAUDE.md or by scanning for `PacletInfo.wl` files.

## Pre-publish checklist

Before publishing, verify:

1. **Version bump** — check `PacletInfo.wl` version.
   If this is an update, the version should be higher than the last published version.
   Ask the user if they want to bump it.
2. **Lint code** — if `mcp__Wolfram__CodeInspector` is available, run it on each kernel file.
   Otherwise skip.
3. **Tests pass** — if test files exist (`Tests/*.wlt`), run them:
   - Preferred: `mcp__Wolfram__TestReport` (if available via MCP)
   - Fallback: `wolframscript -f <PacletName>/run_tests.wls`
4. **No uncommitted changes** — warn if there are uncommitted changes in the paclet's kernel files.
5. **Documentation** — `Documentation/` is bundled **by default** when it exists: a published paclet ships its docs.
   Pass `--no-docs` only when the user asks for a code-only release.
   If the paclet has no `Documentation/` yet, offer the [paclet-docs](../paclet-docs/SKILL.md) skill before publishing — a paclet with no reference pages is discoverable only by reading its source.
6. **Fixed staging lists in a project's own publish script** — if the paclet has its own `Scripts/Publish*.wls`, read what it stages.
   A hand-written script that copies a fixed directory list drops `Documentation/` (and anything else added since it was written) without a word.
   Fix the list, or say plainly that the docs will not ship.

## Step-by-step (preferred: MCP)

### 1. Build + install, with docs

Build and install locally via the evaluator exactly as in the [build-paclet](../build-paclet/SKILL.md) skill (`CreatePacletArchive` + `PacletInstall[..., ForceVersionInstall -> True]` in the persistent kernel), staging **every** top-level item — including `Documentation/`, which that skill's snippet leaves out by default (`withDocs = True` here).
Keep the resulting archive path.

Then, before anything is uploaded, run the [build-paclet § *Docs-resolution check*](../build-paclet/SKILL.md#docs-resolution-check) for every documented symbol; a page that resolves to `Null` is dead weight in the archive — stop and fix it rather than publish it.

### 2. Upload to Wolfram Cloud via the evaluator

Run in the persistent kernel with `mcp__Wolfram__WolframLanguageEvaluator` — mirrors [publish_paclet.wls](../../scripts/publish_paclet.wls):

```wolfram
CloudConnect[];
With[{obj = CloudObject["<PacletName>.paclet", Permissions -> "Public"]},
  CopyFile["<archivePath>", obj, OverwriteTarget -> True];
  First[obj]]
```

The returned string is the **public cloud URL** — stable across versions, since each publish overwrites the same cloud object.

> **Fallback (MCP unavailable, and a seat is free per the headroom check):** run
> `wolframscript -f "${CLAUDE_PLUGIN_ROOT}/scripts/publish_paclet.wls" "<PacletName>"`
> (or `Scripts/publish_paclet.wls`; add `--no-docs` to exclude `Documentation/`).
> The script prints `=== PACLET_URL: <url> ===` and, when docs were bundled, `=== DOCS_URL: <url> ===` — extract the URLs from those lines.

### 3. Deploy the documentation pages

A published `.paclet` serves the reader who installs it.
The reader who was just sent a link has nothing to open.
So deploy the doc pages as public cloud notebooks with an HTML index, via [deploy_paclet_docs.wl](../../scripts/deploy_paclet_docs.wl):

```wolfram
Get["${CLAUDE_PLUGIN_ROOT}/scripts/deploy_paclet_docs.wl"];
deployPacletDocs["<pacletDir>", "<PacletName>/Documentation"]
```

It returns `<|"IndexURL" -> …, "Pages" -> <|symbol -> url, …|>, "Failed" -> {…}|>`.
The second argument is a path under the connected cloud account; keep it stable across releases so the URL does not move.

Two things it does that matter:

- **Rewrites every `paclet:` link.** A page's own cross-links are `paclet:<Pub>/<Paclet>/ref/<Sym>` plus a web URL of `reference.wolfram.com/language/<Pub>/<Paclet>/ref/<Sym>.html` — a page that exists only for paclets shipped with the Wolfram Language. Both slots are repointed at the deployed sibling; links to built-in symbols keep their real `reference.wolfram.com` URL.
- **Deploys notebooks, not HTML.** `ExportString[nb, "HTML"]` rasterizes the cells into an image map and loses the links, so it is not an option.

Then check anonymously — the pages are for people who are not logged in:

```wolfram
URLRead[url, "StatusCode"]
```

200 for the index and for every page.
Whether the cloud notebook viewer makes the rewritten links clickable is a browser question; say that it is unverified rather than claiming it works.

### 4. Report to the user

After successful publish, report:

- **Paclet name and version** — from the build output
- **Cloud URL** — the public URL
- **Install command** — ready to copy:
  ```wolfram
  PacletInstall["<cloud-url>"]
  ```
- **Documentation URL** — the deployed index, and how many pages resolved in-product out of how many symbols
- **What still needs a human** — F1 and Documentation Center search after install, and click-through on the deployed pages

### 5. Update README (if applicable)

If the paclet has a `README.md`, check two links, not one:

- the install URL in the Installation section, against the new cloud URL
- a link to the deployed documentation index — this is the link to hand to someone who has not installed anything

Offer both edits; the README is the author's.

## Error handling

- **CloudConnect fails** — the user needs to authenticate.
  Have them evaluate `CloudConnect[]` via the MCP (or `wolframscript -c 'CloudConnect[]'`) interactively first.
- **Build fails** — same diagnostics as build-paclet skill.
- **Upload fails** — check cloud connectivity and permissions.

## Cloud object naming

The paclet is uploaded as `<PacletName>.paclet` in the user's cloud home.
This means each publish overwrites the previous version at the same URL — the URL is stable across versions.
