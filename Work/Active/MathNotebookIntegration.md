# MathNotebookIntegration

*[ LLM Generated ]*

> Type: investigation

## Spec

Origin: "we need another work item to incorporate https://github.com/WolframInstitute/MathNotebook to create research notebooks with proper references, math, and theorem etc. environments" / "I think that research notebooks could use MathNotebook."

Make `research-notebook` actually produce a typeset mathematical document: numbered theorem-family environments, properly typeset displayed math, and real citations resolving to a References section.

The starting point is not greenfield — it is a **reconciliation**.
`skills/research-notebook/SKILL.md` already instructs the LLM to use MathNotebook (lines 88–113, 144) and asserts specifics that have never been checked against the repo:

- `Needs[ "WolframInstitute`MathNotebook`" ]`, installed via `PacletInstall[ "WolframInstitute/MathNotebook" ]`
- stylesheet at `FrontEnd`FileName[ { "MathNotebook" }, "AMSArticle.nb" ]`
- cell styles `Definition`, `Conjecture`, `Question`, `Observation`, `Remark`, `Citation`
- the stylesheet supplying automatic numbering

Every one of those is an assumption.
This item verifies them, corrects the skill where they are wrong, and implements the parts that are merely described — above all the Markdown-marker → environment-cell post-processing and the citation → References path, neither of which exists as code today.

### Requirements

- Clone the repo to a gitignored path; record license, recency, and whether it is a paclet, a stylesheet-only repo, or something else.
- Establish the **real** install path. Confirm whether `PacletInstall["WolframInstitute/MathNotebook"]` resolves at all, or whether it needs a GitHub URL / local build / submodule. If it does not resolve, the skill's install snippet is broken and must be replaced.
- Enumerate the **actual** stylesheet file name and cell-style names. Produce a correction list against the six styles the skill currently names, plus whatever theorem-family styles exist that it doesn't use (`Theorem`, `Lemma`, `Proposition`, `Corollary`, `Proof`, …).
- **Theorem environments:** implement the post-processing that converts a `**Definition.**`-style opening marker in a Text cell into the matching environment cell with the marker stripped. Verify through the Wolfram MCP that numbering is produced by the stylesheet and increments correctly.
- **Math:** reconcile the skill's current displayed-equation convention (a `wolfram` fence starting with `FormBox[…]` → `DisplayFormula` cell) with whatever the stylesheet expects. If MathNotebook defines its own equation environment, prefer it and update the skill.
- **References:** determine what `Citation` actually does — whether there is a bibliography mechanism or only a text style. Implement the `[tag]` → References-section path and tie it to the `cite` skill and `Paper/references.bib` when the project has one.
- End-to-end: build one real research notebook using the environments, cloud-deploy it, and **confirm in a browser that the styles survive deployment**.
- Rewrite the affected parts of `research-notebook/SKILL.md` to match verified reality, and tick its line-320 checklist item only once it is true.

### Design / risks

- **Custom stylesheet vs. `CloudDeploy` is the main technical risk.** Cloud-published notebooks routinely lose private/paclet stylesheets, which would leave every environment cell unstyled and unnumbered in the one place readers actually look. Test this early — it may force embedding the style definitions in the notebook rather than referencing the paclet.
- If the paclet must be installed for the notebook to render, a cloud reader has no paclet. Embedded `StyleDefinitions` is then the only correct answer, not the fallback.
- Numbering that depends on front-end evaluation may not survive headless build; check whether numbers are static or dynamic.

### Kernel execution (license-aware)

All evaluation goes through the official Wolfram MCP's persistent kernel.
Check `$MaxLicenseProcesses - $LicenseProcesses > 0` before any `wolframscript`.

### Edge cases & out of scope

- `demo-notebook` is **out of scope** — it moves to documentation pages instead (see `PacletDocumentation`).
- Lean export of the resulting statements stays with the `lean` skill.
- If the repo is private or empty, stop and report rather than inferring an API from the name — and note that the skill is currently shipping instructions for a paclet that may not be installable.

## Tasks

One unchecked box ≈ one focused session.

- [ ] T1 — Clone and inspect MathNotebook; verify installability; enumerate the real stylesheet and cell-style names; write the correction list against `research-notebook/SKILL.md`.
- [ ] T2 — Test the `CloudDeploy` styling risk first: deploy a throwaway notebook using the stylesheet and confirm environments render for a reader without the paclet. Decide referenced vs. embedded `StyleDefinitions`.
- [ ] T3 — Implement marker → environment-cell post-processing; verify rendering and numbering via the MCP.
- [ ] T4 — Reconcile the displayed-math convention with the stylesheet; verify typeset output.
- [ ] T5 — Implement the citation → References path, tied to `cite` and `references.bib`.
- [ ] T6 — End-to-end build of one real research notebook; update `research-notebook/SKILL.md` to verified reality.

### Done

(completed tasks move here with the session that closed them)

## Progress

(no sessions yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|
