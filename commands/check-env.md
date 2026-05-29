---
allowed-tools:
  - Bash
  - mcp__Wolfram__WolframLanguageEvaluator
  - mcp__Wolfram__CodeInspector
  - mcp__wolfram__ping
---
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` using the Bash tool and display the full output.

Then test MCP availability directly:

1. **Official Wolfram MCP** (primary): evaluate `1+1` with
   `mcp__Wolfram__WolframLanguageEvaluator`. Required for computation.
2. **WolframPacletDevelopment tools**: try calling `mcp__Wolfram__CodeInspector`
   on a trivial expression. If it works, the full tool set is available
   (ReadNotebook, WriteNotebook, SymbolDefinition, CodeInspector, TestReport,
   CreateSymbolDoc, EditSymbolDoc, EditSymbolDocExamples).
3. **Unofficial Wolfram MCP** (optional): call `mcp__wolfram__ping`. If
   available, its LSP tools can be used for code navigation.

After showing the output, summarize:
1. Whether the Wolfram kernel is available and working
2. Whether the official Wolfram MCP is available (required)
3. Which MCP profile is active (Wolfram vs WolframPacletDevelopment)
4. Whether the unofficial Wolfram MCP is available (optional, for LSP)
5. Whether this appears to be a **Cowork environment** (MCP succeeds but
   script reports no local kernel)
6. What to do if anything is missing

If WolframPacletDevelopment is not active, suggest switching by setting
`MCP_SERVER_NAME=WolframPacletDevelopment` in the MCP server config.

Also check whether Wiki/ exists in the current directory. If not, suggest running
init-wiki to set up the knowledge base.
