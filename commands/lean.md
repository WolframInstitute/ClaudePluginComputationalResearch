Drive a Lean / Mathlib formalization session using the `lean-bridge` skill.

Requires the `lean-lsp` MCP. Reads goal state, searches Mathlib for closing
lemmas, tries tactics without editing, verifies proofs, and maintains a
formalization checklist in `Work/`.

Pass the file path or theorem name as arguments
(e.g., `/lean Lean/MyProject/Basic.lean` or `/lean MyNS.my_theorem`).

If a math-research project's `Lean/` directory doesn't exist yet, the skill
will guide you through scaffolding it (`lake new <Project> math`).
