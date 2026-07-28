# new-project: math-research type

Read after the shared questionnaire and environment check in [SKILL.md](SKILL.md).
Also check whether `lean` is on `PATH` if the user wants Lean — warn (don't fail) if it's not.

## 1. Scaffold the project

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold-math-project.sh" \
    "<ProjectName>" "<topic>" "." "<Author>" "<email>" "<CodeDir>" "<WithLean=0|1>"
```

The script creates the math variant of `CLAUDE.md` (see `math_claude_template.md`), `<CodeDir>/Tools.wl`, `Resources/`, `Scripts/` (recover + notebook helpers), `Wiki/{Theorems,Definitions,Domains}/` with `_template.md` and `categories.md` seeds, `Work/README.md`, and `Lean/` only if `WithLean=1` — it prints what it made.

## 2. Initialize the wiki

Run **init-wiki** inside `<ProjectName>/`.
It will create `Index.md`, `Status.md`, `Concepts/`, `Resources/`.
The `Theorems/`, `Definitions/`, `Domains/` directories already exist and should be left alone.

## 3. Adapt the domain taxonomy

Read `Wiki/Domains/categories.md` and prune it to the project's actual scope.
Anything not touched should be deleted — the file is a working catalogue, not a master reference.
Add cross-links to the wiki articles you'll create next.

## 4. Seed initial definitions and theorems

For each central concept:

- Copy `Wiki/Definitions/_template.md` to `Wiki/Definitions/<Term>.md` and fill in Notation / Prerequisites / Statement / Properties / Examples / References.

For each central theorem the project wants to prove or use:

- Create `Wiki/Theorems/<Name>.md` with a precise statement, hypotheses, proof outline (math-level), status field (`open | outlined | proved | formalised`), and cross-links to required definitions.

Use **search-math** to find authoritative external references for each.

## 5. Create initial code files

Same as [research.md](research.md) step 3.
Code in `<CodeDir>/` is for computing examples, counterexamples, and visualisations — it is *not* the source of truth for the math.

## 6. Download reference papers

Same as [research.md](research.md) step 5.
For math-research projects, prefer using **arxiv-latex-mcp** to read papers so equations are exact.

## 7. Create initial notebook (theorem-proof template)

If a central theorem already has an outlined proof, use **new-notebook** with the `theorem-proof` template type to produce a working notebook around it (Setup → Statement → Proof → Corollaries → Examples).

## 8. (Optional) Initialize Lean

If `WithLean=1` was set:

1. Tell the user to run `cd <ProjectName>/Lean && lake new <ProjectName> math` themselves — this skill does not run `lake` on their behalf.
2. Once the lakefile exists, invoke **lean** to set up a `Work/Backlog/Formalize-<topic>.md` formalization checklist for the first theorem.

## 9. Paper (if requested)

Same as [research.md](research.md) step 7.
