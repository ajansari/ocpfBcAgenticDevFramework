# ocpf-bc: OCPF BC Agentic Development Framework plugin

The agent plugin for the **OnlyCopilotFans Business Central Agentic Development Framework**, a
guided DEFINE → DESIGN → BUILD → PROVE routine for building Microsoft Dynamics 365 Business Central
AL per-tenant extensions the right way. It's *simple enough for functional consultants* and
*robust enough for pro developers*.

Full documentation and install steps for every tool are in the framework's
[README](https://github.com/ajansari/ocpfBcAgenticDevFramework#readme).

## Quick start

In an AL project folder (or a new, empty one):

```
/ocpf-bc:start
```

Or just ask: *"Start a Business Central project with the OCPF framework."*

The `start` skill:
1. helps you choose **Full** (14 steps) or **Lite** (7 steps),
2. installs the **latest** runbook from GitHub as `CLAUDE.md` and/or
   `.github/copilot-instructions.md`, and never overwrites an existing file,
3. connects **Microsoft's AL tools**, with nothing to install, using the AL Language extension you already have,
4. begins the routine.

## What's included

| Component | What it does |
|---|---|
| `start` skill | Sets up a new project and begins the routine. |
| `status` skill | Reports where a project stands: current step, exit gate, what's waiting on you. |
| `update-framework` skill | Checks for a newer runbook, shows what changed, and updates the project's copy only when you approve. The runbook also checks once per session. |
| `al-standards` skill | The OCPF AL Development Standards Guide, for writing and reviewing AL. |
| `al-mcp-setup` skill | Connects Microsoft's AL tools with nothing to install. In GitHub Copilot Chat, the AL Language extension's tools are built in. In Claude Code and Copilot CLI, it registers the extension's bundled AL MCP Server (compile, build, symbols, diagnostics, publish, tests) for the project, via a launcher that follows AL extension updates. |
| `ocpf-reasoning` sub-agent | The full framework's Reasoning role: FRD/TDD drafting, Sanity Check, diagnosis, Gap-Fit, Code Review. |
| `ocpf-light` sub-agent | The full framework's Light role: post-generation pre-flight checks and symbol verification. |

## License

MIT. See [LICENSE](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/LICENSE) and
[THIRD_PARTY_NOTICES.md](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/THIRD_PARTY_NOTICES.md).
