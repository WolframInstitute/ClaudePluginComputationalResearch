# AuditFixes

*[ LLM Generated ]*

> Type: refactor

## Spec

Origin: "Evaluate functionality of this paclet … Propose improvements. My goal is simplicity, mathematical clarity and perfect organization." (2026-07-28 audit session; follow-up: "the research notebook skill should remain in some form — definitions first, then theorems, then symbols and functions used, then the relevant code calls.")

Fix the defects and structural debt found by the 2026-07-28 full plugin audit.
The mechanical layer passed every test (inventory, wiring, scaffolds, compiles, live scripts); the fixes target the hook, cross-skill contradictions, duplicated policy prose, three oversized skills, and the unreachable `revise` protocol.
`research-notebook` is kept and restructured to the user's canonical document order.

### Requirements

**Bugs (correctness):**

- `hooks/check-nb-read.sh` reads `$1`/`$2` but PreToolUse hooks deliver JSON on stdin — it has never blocked anything. Rewrite to read stdin, emit the block message on stderr with exit 2, and add `"matcher": "Read"` to `hooks.json`.
- `new-project` step "gitignore `NotebooksLLM/`" would ignore the `.md` sources that `new-notebook` calls the source of truth; align with `init-wiki`'s `NotebooksLLM/*.nb`.
- Provenance injection lives only in `generate_notebooks.wls` (the fallback path); the preferred MCP path and `research-notebook` never write `TaggingRules`, so the toggle silently no-ops. Specify the injection on the MCP path in `new-notebook`/`research-notebook` and make it coexist with the `"ResearchNotebook"` fingerprint key.
- `init-wiki` seeds "All articles are **draft** until reviewed" into Index.md, contradicting `revise`, its own CLAUDE.md template, and its own no-status-headers rule; drop the line.
- Sweep the small inconsistencies: two stale section cross-references in `research-notebook`; `update-wiki`/README promising the abolished "log"; `new-project`'s stale closing skills list and `<ProjectName>1.nb` naming; the two spellings of the `[ LLM Generated ]` marker (standardise on the spaced form everywhere); `research-notebook`'s pre-checked checklist box; retired `demo-notebook` mentions in `paclet-docs` and `publish-paclet`; `init-wiki`'s CLAUDE.md template missing the Provenance and Scientific-journal toggle sections; `new-project` questionnaire never asking about the journal it advertises.

**Deduplication (one policy, one file):**

- License-headroom block (7 near-copies): CLAUDE.md is authoritative; each skill keeps one sentence + pointer.
- Semantic-line-breaks paragraph (7 copies): same treatment.
- "One fact, one destination" table: keep in `work`, `next-session` links it.
- Wiki article + Status.md skeletons: keep in `update-wiki` (with the marker), `init-wiki` links them; they have already drifted.
- Paclet-directory detection, triple-nesting convention, and `Documentation`ResolveLink` verification each stated once (`build-paclet` or a shared sibling doc), referenced elsewhere.

**Skill splits (read-on-demand siblings, per the existing `next-session/paclet-worktree.md` convention):**

- `new-notebook` 713 → ~200 core; siblings `pipeline-builtin.md`, `pipeline-rich.md`, `templates.md`, `markdown-mapping.md`; delete the internally triplicated `boxifyInputCells`/`markInitCells`/`addLLMSubtitle` copies (~150 lines).
- `new-project` 524 → ~120 core (questionnaire, depth, mode detection, after-scaffolding); one sibling per project type; drop the directory trees that duplicate what the scaffold scripts create.
- `research-notebook` 567 → ~300 core; siblings for fingerprint forensics, MathNotebook install/environments, output embedding.

**research-notebook restructure (user-mandated):**

- The skill remains; the generated document's canonical order becomes:
  1. list of definitions,
  2. list of theorems (with conjectures/evidence subsumed here),
  3. list of symbols and functions used,
  4. the relevant code calls.
- Evict the graph-displacement domain math ("Multivaluedness…", `Displacement`, `C6`, 729 displacements) and the hard-coded Infrageometry references to a Wiki article in their home project.
- Rename its internal "revision protocol" language (which means the fingerprint mechanism) so it cannot be confused with the `revise` skill.

**revise reachability:**

- Name the `revise` skill in project CLAUDE.md as the protocol every session follows.
- Add one-line `revise` links to the skills that re-derive it (`scaffold-paper`, `lean`, `publish-paclet`, `new-notebook`, `research-notebook`, `update-wiki`), deleting the redundant paraphrases they carry.

**Skill skeleton standardisation:**

- One fixed section layout (When to use / Steps / Integration with other skills / When NOT to use) applied to all 21 skills; unify the five names currently used for the integration section and the four step-numbering styles.

### Edge cases & out of scope

- Skill renames (`new-notebook`→`notebook`, `paclet-docs`→`document-paclet`, `work`→`work-item`, `revise`→`revision-protocol`) are **out of scope** — breaking, deferred to a major version, and the user has not approved them.
- `MarkdownToNotebook`/`MathNotebook` clones, scripts, and templates are untouched except where a skill's prose references them.
- Each session updates ARCHITECTURE.md/README.md counts as it goes; the final task bumps the plugin version and syncs the marketplace repo.

## Tasks

One unchecked box ≈ one focused session — small enough to finish, report, and commit in a single sitting.

- [ ] T1 — Fix the `.nb`-read hook (stdin JSON, stderr, exit 2, `matcher: Read`) and verify with a piped-JSON test.
- [ ] T2 — Fix the contradictions: NotebooksLLM gitignore, init-wiki draft line, abolished-log mentions, marker spelling, stale skill lists and naming in `new-project`, stale cross-references, pre-checked box, `demo-notebook` mentions, missing toggles in init-wiki's template, journal question in the questionnaire.
- [ ] T3 — Design and specify the provenance injection on the MCP path (coexisting with the fingerprint key); update `provenance`, `new-notebook`, `research-notebook`.
- [ ] T4 — Deduplicate the policy prose: license block, semantic-line-breaks, one-fact table, wiki skeletons, paclet conventions, ResolveLink verification.
- [ ] T5 — Split `new-project` into core + four project-type siblings.
- [ ] T6 — Split `new-notebook` into core + four siblings; delete the triplicated WL functions.
- [ ] T7 — Restructure `research-notebook`: new canonical document order (definitions → theorems → symbols/functions → code calls), evict domain math to the home project's Wiki, split siblings, rename the fingerprint "revision protocol" language. (human)
- [ ] T8 — Make `revise` reachable: CLAUDE.md line + links in the six re-deriving skills, deleting their paraphrases.
- [ ] T9 — Apply the standard skill skeleton across all 21 skills; update ARCHITECTURE.md "How to Add a New Skill" to require it.
- [ ] T10 — Final sweep: re-run the audit's mechanical checks, bump plugin version, sync marketplace repo, update the blog post draft for review.

### Done

(completed tasks move here with the session that closed them)

## Hand-off

Overwritten each session, not appended to: what the next session must know that is not yet true anywhere else.

(nothing yet)

## Decisions

| Date | Decision | Rationale |
|---|---|---|
| 2026-07-28 | Keep `research-notebook`; document order fixed to definitions → theorems → symbols/functions → code calls | User mandate in the audit follow-up |
| 2026-07-28 | Skill renames deferred out of scope | Breaking change; needs a major version and explicit user approval |

## Progress

Append-only audit trail, **one line per session**, newest at the bottom.
