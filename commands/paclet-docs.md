Generate Wolfram documentation for a paclet using the `paclet-docs` skill.

One symbol reference page per exported function, written through the official MCP
doc tools so it resolves via `?Symbol`, F1, and Documentation Center search.

Auto-detects the paclet directory (triple or double nesting).
Pass the paclet name as an argument if ambiguous (e.g. `/paclet-docs SyntheticInfrageometry`).

Guide pages are not generated — they are a human deliverable.
