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

**Project layout (plugin 5.0.0, Full 5.0.0.0 / Lite 5.0.0.0):** everything the framework fetches
or keeps lives under one folder, `ocpfFramework/` (step files, templates, guides, patterns,
scripts, the marker, and per-developer `state/`); project documents go in `docs/` by phase
(`0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/`); `ProjectProgress.md` stays in the
root in both editions, with the step table and the usage table. A project on an older plugin is
moved to this layout by `update-framework`'s migration.

**Model recommendations** (the `roles` skill offers these first; High effort only where judgment
matters most, because it makes every task slower): Full on Claude Code — Main Sonnet Medium,
Light Haiku Medium, Reasoning Opus High; Full on GitHub Copilot — Gemini 3.8 Flash Medium, Auto
Balanced, Claude Opus 5.5 High; Lite — Sonnet Medium (Copilot: Gemini 3.8 Flash Medium). The
generator sub-agent runs on the Main model.

## What's included

| Component | What it does |
|---|---|
| `start` skill | Sets up a new project and begins the routine. |
| `status` skill | Reports where a project stands: current step, exit gate, what's waiting on you. |
| `update-framework` skill | Checks for a newer runbook, shows what changed, and updates the project's copy only when you approve. The runbook also checks once per session. |
| `al-standards` skill | The OCPF AL Development Standards Guide, for writing and reviewing AL. The shared **Operations Guide** — the framework's procedures, cited as Ops § — is bundled with the `start` skill and fetched into each project. |
| `al-mcp-setup` skill | Connects Microsoft's AL tools with nothing to install. In GitHub Copilot Chat, the AL Language extension's tools are built in. In Claude Code and Copilot CLI, it registers the extension's bundled AL MCP Server (compile, build, symbols, diagnostics, publish, tests) for the project, via a launcher that follows AL extension updates. |
| `notifications` skill | Asks how you'd like to be notified whenever the agent finishes a turn, asks a question, or waits for an approval — Claude app, sound, desktop notification, or none — remembers the answer, and applies it through each AI tool's own notifications and hooks. The runbook sets this up at its first step; the skill adds it to older projects. |
| `roles` skill | Asks which models do the work — Full: Main, Light, and Reasoning, each with a thinking effort; Lite: one — with the framework's recommendation first, and makes it take effect by writing project-local copies of the three sub-agents with the chosen model and effort, then verifying every delegation. The runbook runs it at its first step. |
| `documents` skill | Writes any project document from its template with only the inputs its step names, into its `docs/` phase folder — including the Human Effort Estimate (from the Human Effort Baselines, or your own calibration file), the AI Effort Estimate (tokens, cost, wall-clock, read against the calibration store), Acknowledgements, and `ProjectProgress.md` for both editions. |
| `usage` skill | Records usage at every step boundary (`/ocpf-bc:usage --step <id>`): tokens per step and per model from Claude Code's transcripts, one row per model, priced at published rates, into `ProjectProgress.md`'s usage table in both editions. With GitHub Copilot in VS Code it reads AI credits per step and per model from Copilot Chat's session files instead, into a credits table. At project close, `--calibrate` exports the measurements to `~/.ocpf/calibration/` for the next project's estimate. |
| `ocpf-reasoning` sub-agent | The full framework's Reasoning role: FRD/TDD drafting, Sanity Check, diagnosis, Gap-Fit, Code Review. Runs in the background. Carries no model of its own; the `roles` skill writes the project's copy with the chosen model. |
| `ocpf-light` sub-agent | The full framework's Light role: post-generation pre-flight checks and symbol verification, on each batch as its generator returns. Same: the project's copy carries the model. |
| `ocpf-generator` sub-agent | The Generator role, both editions: writes the AL files of exactly one batch from a narrow brief, so all batches can be generated at once — one generator per batch, in the background, on the Main model. Never touches the ChangeLog, Object Register, TDD, or another batch's files; reports files written, deviations, and open questions. |

## License

PolyForm Shield 1.0.0 — a source-available license: free to use, the source is open to read, and it may be used
to build free or commercial Business Central extensions, PTE or AppSource; what it reserves is
providing a competing product built from this framework. See
[LICENSE](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/LICENSE) and
[THIRD_PARTY_NOTICES.md](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/THIRD_PARTY_NOTICES.md).
