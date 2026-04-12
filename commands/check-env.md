---
allowed-tools:
  - Bash
  - mcp__Wolfram__WolframLanguageEvaluator
  - mcp__wolfram__ping
---
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` using the Bash tool and display the full output.

Then test MCP availability directly:

1. **Official Wolfram MCP** (primary): evaluate `1+1` with
   `mcp__Wolfram__WolframLanguageEvaluator`. This is required for notebook
   generation and computation.
2. **Unofficial Wolfram MCP** (optional): call `mcp__wolfram__ping`. If
   available, its LSP tools (hover_info, find_definition, find_references,
   get_diagnostics, document_symbols) can be used for code navigation.

After showing the output, summarize:
1. Whether the Wolfram kernel is available and working
2. Whether the official Wolfram MCP is available (required)
3. Whether the unofficial Wolfram MCP is available (optional, for LSP)
4. Whether this appears to be a **Cowork environment** (MCP succeeds but
   script reports no local kernel)
5. What to do if anything is missing

If both kernel and official MCP are available, confirm the environment is ready.

Also check whether Wiki/ exists in the current directory. If not, suggest running
wiki-init to set up the knowledge base.
