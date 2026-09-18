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
| `al-standards` skill | The OCPF AL Development Standards Guide, for writing and reviewing AL. The shared **Operations Guide** — the framework's procedures, cited as Ops § — is bundled with the `start` skill and fetched into each project. |
| `al-mcp-setup` skill | Connects Microsoft's AL tools with nothing to install. In GitHub Copilot Chat, the AL Language extension's tools are built in. In Claude Code and Copilot CLI, it registers the extension's bundled AL MCP Server (compile, build, symbols, diagnostics, publish, tests) for the project, via a launcher that follows AL extension updates. |
| `notifications` skill | Asks how you'd like to be notified whenever the agent finishes a turn, asks a question, or waits for an approval — Claude app, sound, desktop notification, or none — remembers the answer, and applies it through each AI tool's own notifications and hooks. The runbook sets this up at its first step; the skill adds it to older projects. |
| `roles` skill | Asks which models do the work — Full: Main, Light, and Reasoning, each with a thinking effort; Lite: one — and makes it take effect by writing project-local copies of the two sub-agents with the chosen model and effort, then verifying every delegation. The runbook runs it at its first step. |
| `ocpf-reasoning` sub-agent | The full framework's Reasoning role: FRD/TDD drafting, Sanity Check, diagnosis, Gap-Fit, Code Review. Carries no model of its own; the `roles` skill writes the project's copy with the chosen model. |
| `ocpf-light` sub-agent | The full framework's Light role: post-generation pre-flight checks and symbol verification. Same: the project's copy carries the model. |

## License

MIT. See [LICENSE](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/LICENSE) and
[THIRD_PARTY_NOTICES.md](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/THIRD_PARTY_NOTICES.md).
