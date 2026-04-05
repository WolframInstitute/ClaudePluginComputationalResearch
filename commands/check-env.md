---
allowed-tools:
  - Bash
  - mcp__wolfram__ping
---
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` using the Bash tool and display the full output.

Then, **always** test MCP availability directly by calling `mcp__wolfram__ping`.

After showing the output, summarize:
1. Whether the Wolfram kernel is available and working
2. Whether the Wolfram MCP server is detected (locally via script **and** remotely via ping)
3. Whether this appears to be a **Cowork environment** (MCP ping succeeds but script
   reports no local MCP)
4. What to do if anything is missing

If both kernel and MCP are available, confirm the environment is ready.

Also check whether Wiki/ exists in the current directory. If not, suggest running
wiki-init to set up the knowledge base.
