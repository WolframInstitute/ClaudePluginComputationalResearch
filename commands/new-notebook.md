Create or modify a Wolfram notebook using the `new-notebook` skill.

If arguments are provided (e.g., `/new-notebook graph curvature examples`), create a notebook on that topic.
Otherwise ask what the notebook should cover.

Uses the Markdown→notebook pipeline via the official Wolfram MCP.
Creates the Markdown source in Code/Artifacts/ and generates the .nb alongside it, sharing one dated stem. Everything outside an Artifacts/ folder is the human's and is never touched.
