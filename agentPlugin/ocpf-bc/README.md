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
1. helps you choose **Full** (a complete app or solution end to end, three models, 14 steps),
   **Lite** (updating an existing app or a new app without a large footprint, one model, 7
   steps), or **Build-a-Feature** (quick customizations in minutes, no steps, six short documents
   written as the work happens — not vibe-coding, but lean on documentation), and offers
   `/ocpf-bc:analyze` first on an existing app nobody can explain,
2. installs the **latest** runbook from GitHub as `CLAUDE.md` and/or
   `.github/copilot-instructions.md`, and never overwrites an existing file (Full and Lite),
3. connects **Microsoft's AL tools**, with nothing to install, using the AL Language extension you already have,
4. begins the routine — or, for Build-a-Feature, asks *What do you want to build today?*

On a project that already follows the framework, `start` offers *Status*, *Check for a framework
update*, or *Build a feature in this project*.

**Project layout (since plugin 5.0.0, Full 5.0.0.0 / Lite 5.0.0.0; current 5.8.2 / 5.8.2.0):** everything the framework fetches
or keeps lives under one folder, `ocpfFramework/` (step files, templates, guides, patterns,
scripts, the marker, and per-developer `state/`); project documents go in `docs/` by phase
(`0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/`; Build-a-Feature keeps its six
documents flat in `docs/`); `ProjectProgress.md` stays in the root in every journey, with the step
table and the usage table. A project on an older plugin is
moved to this layout by `update-framework`'s migration.

**Model recommendations** (the `roles` skill offers these first; High effort only where judgment
matters most, because it makes every task slower): Full on Claude Code — Main Sonnet Medium,
Light Haiku Medium, Reasoning Opus High; Full on GitHub Copilot — Gemini 3.8 Flash Medium, Auto
Balanced, Claude Opus 5.5 High; Lite and Build-a-Feature — Sonnet Medium (Copilot: Gemini 3.8
Flash Medium). The generator and reviewer sub-agents run on the Main model; Build-a-Feature uses no
sub-agent; the `analyze` skill's analyst runs on the model you choose for the analysis.

## What's included

| Component | What it does |
|---|---|
| `start` skill | The one launching point: chooses Full, Lite, or Build-a-Feature by the kind of work, offers the `analyze` skill on an undocumented existing app, sets up the project, and begins; on an existing framework project offers status, an update check, or a feature build. |
| `analyze` skill | Documents an existing extension that is not well documented — a presumed FRD and TDD, an Object Register, Documentation with the app's flows and a schema of its tables and fields, and a Project Parameters sheet — into `requirements/existing/`, on a model (reasoning or daily driver) and effort the human chooses, through the `ocpf-analyst` sub-agent. Run first; every journey then reads the folder. |
| `build-a-feature` skill | The quick-customization journey: a table and its pages, a table / page / report extension, a processing report, an API page or query, a query, an enum or enum extension, a codeunit, a permission set, a role center — asked in one question, the proposed design written to `docs/DataModel.md` before the one confirmation box, written from the Standards Guide and the patterns library, compiled clean, documented as it compiles, the next object offered at every close, then an optional review on the Main model and a `.app`. Six short documents in a flat `docs/`; the publisher and ID range only ever from a box the human answered. Keeps the feature table in `ProjectProgress.md`, usage per object, and the dashboard. Reached through `start`. |
| `status` skill | Reports where a project stands: current step, exit gate, what's waiting on you. |
| `update-framework` skill | Checks for a newer runbook, shows what changed, and updates the project's copy only when you approve. The runbook also checks once per session. |
| `al-standards` skill | The OCPF AL Development Standards Guide, for writing and reviewing AL. The shared **Operations Guide** — the framework's procedures, cited as Ops § — is bundled with the `start` skill and fetched into each project. |
| `app-icon` skill | Draws the app icon when the human has none — *Create one for me* in every journey's identity box, or `/ocpf-bc:app-icon`: asks style (flat 2D or isometric 3D), colors (one, two, or a gradient), content (image only or a word mark), and a description in one box; the Main model writes the SVG to the standard (square, rounded corners, transparent background, 300 × 300), renders it with nothing installed (Quick Look, a headless Chrome or Edge, or a preview page with a *Save as PNG* button), shows it, and offers accept or another; the accepted icon lives in `images/` and becomes `app.json`'s logo. |
| `copilot-blueprint` skill | Fires on any ask for a Business Central Copilot feature — a *Suggest with Copilot* action, a `PromptDialog` page, a capability registration, Azure OpenAI — in any journey or none: fetches the OnlyBCFans BC Copilot Blueprint at the framework's pinned tag into a sibling folder and builds from its procedure and templates, never from memory. Full and Lite reach the Blueprint through their intake; this is what makes Build-a-Feature and plain chat reach it too. |
| `al-mcp-setup` skill | Connects Microsoft's AL tools with nothing to install. In GitHub Copilot Chat, the AL Language extension's tools are built in. In Claude Code and Copilot CLI, it registers the extension's bundled AL MCP Server (compile, build, symbols, diagnostics) for the project — the framework packages the app and the human uploads it, via a launcher that follows AL extension updates. |
| `notifications` skill | Asks how you'd like to be notified whenever the agent finishes a turn, asks a question, or waits for an approval — Claude app, sound, desktop notification, or none — remembers the answer, and applies it through each AI tool's own notifications and hooks. The runbook sets this up at its first step; the skill adds it to older projects. |
| `roles` skill | Asks which models do the work — Full: Main, Light, and Reasoning, each with a thinking effort; Lite: one — with the framework's recommendation first, and makes it take effect by writing project-local copies of the sub-agents (four in Full, two in Lite) with the chosen model and effort, then verifying every delegation. The runbook runs it at its first step. |
| `documents` skill | Writes any project document from its template with only the inputs its step names, into its `docs/` phase folder — including the Human Effort Estimate (from the Human Effort Baselines, or your own calibration file), the AI Effort Estimate (tokens, cost, wall-clock, read against the calibration store), Acknowledgements, and `ProjectProgress.md` for both editions. |
| `usage` skill | Records usage at every step boundary (`/ocpf-bc:usage --step <id>`): tokens per step and per model from Claude Code's transcripts, one row per model, priced at published rates **the script fetches itself** from Anthropic's pricing page (and GitHub's AI-credit price for Copilot) whenever a model has no rate, into `ProjectProgress.md`'s usage table in both editions. With GitHub Copilot (VS Code's chat or the CLI) it reads AI credits per step from the Copilot SDK's session journals instead, into a credits table — the human never types a figure. At project close, `--calibrate` exports the measurements to `~/.ocpf/calibration/` for the next project's estimate. |
| `dashboard` skill | Creates, refreshes, opens, and re-themes the project's live HTML dashboard (`/ocpf-bc:dashboard`; themes `brand` and `f1`): `ProjectDashboard.html` at the project root, tracked in git, rendered by a bundled script from state the framework already keeps, opened once in the default browser, explained once, then refreshed by hooks at zero token cost (every turn in Claude Code and the Copilot CLI; every step boundary in Copilot Chat). |
| `ocpf-reasoning` sub-agent | The full framework's Reasoning role: FRD/TDD drafting, Sanity Check, diagnosis, Gap-Fit, Code Review. Runs in the background. Carries no model of its own; the `roles` skill writes the project's copy with the chosen model. |
| `ocpf-light` sub-agent | The full framework's Light role: post-generation pre-flight checks and symbol verification, on each batch as its generator returns. Same: the project's copy carries the model. |
| `ocpf-generator` sub-agent | The Generator role, both editions: writes the AL files of exactly one batch from a narrow brief, so all batches can be generated at once — one generator per batch, in the background, on the Main model. Never touches the ChangeLog, Object Register, TDD, or another batch's files; reports files written, deviations, and open questions. |
| `ocpf-reviewer` sub-agent | The pre-review, both editions: between the first clean analyzer compile and the first package (Full Step 07 / Lite Step 5) it reads every file against the design, the Standards Guide, and plain logic, on the Main model, in the background, and reports findings with a root cause and a fix — no grades, no scorecard. The human decides every finding in one options box; each decision is recorded in the ChangeLog. The Code Review step still follows. |
| `ocpf-analyst` sub-agent | The `analyze` skill's reader: reads an existing extension in full and writes the six analysis files under `requirements/existing/`, on the model and effort the human chose for the analysis; writes nowhere else. |

## License

PolyForm Shield 1.0.0 — a source-available license: free to use, the source is open to read, and it may be used
to build free or commercial Business Central extensions, PTE or AppSource; what it reserves is
providing a competing product built from this framework. See
[LICENSE](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/LICENSE) and
[THIRD_PARTY_NOTICES.md](https://github.com/ajansari/ocpfBcAgenticDevFramework/blob/main/THIRD_PARTY_NOTICES.md).
