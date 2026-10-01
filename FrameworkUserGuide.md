# OCPF BC Agentic Development Framework — User Guide

**The OnlyCopilotFans Business Central Agentic Development Framework**

*by AJ Ansari*

**Last Updated:** Thursday, October 1, 2026
**Covers:** Full runbook v5.0.0.0 · Lite v5.0.0.0 · Standards Guide v1.11.0.0 · Operations Guide
v5.0.0.0 · `ocpf-bc` agent plugin v5.0.0 · Visual Studio Code setup extension v0.0.10

> This guide is for the person driving a project with the framework: a Business Central
> functional consultant or an AL developer working in Visual Studio Code with Claude Code or GitHub Copilot.
> It explains the moving parts, every command you can run, and how updates work. For what the
> framework *is* and why, start at the [official website](https://ajansari.github.io/ocpfBcAgenticDevFramework/).
> For install tables and release notes, see the [README](README.md).

## Table of Contents

1. [The parts, and how they fit together](#1-the-parts-and-how-they-fit-together)
2. [Setting up, three ways](#2-setting-up-three-ways)
3. [A project, start to finish](#3-a-project-start-to-finish)
4. [Visual Studio Code Command Palette commands (setup extension)](#4-visual-studio-code-command-palette-commands)
5. [Agent plugin commands (`/ocpf-bc:`)](#5-agent-plugin-commands)
6. [What lands in your project](#6-what-lands-in-your-project)
7. [Updates: the plugin, the framework, and the setup extension](#7-updates)
8. [Working without the plugin](#8-working-without-the-plugin)
9. [Troubleshooting](#9-troubleshooting)
10. [Where to get help](#10-where-to-get-help)

---

## 1. The parts, and how they fit together

Four things carry the name OCPF. They are versioned separately, update separately, and it helps to
know which one you are looking at.

| Part | What it is | Where it lives | Version today |
|---|---|---|---|
| **The framework** | The runbook (Full or Lite), its step files, the document templates, the **Standards Guide**, and the **Operations Guide**. This is the content the AI agent follows. | The public GitHub repository, `ajansari/ocpfBcAgenticDevFramework`, on its `main` branch. | Full 5.0.0.0 · Lite 5.0.0.0 · Standards 1.11.0.0 · Ops 5.0.0.0 |
| **The agent plugin** `ocpf-bc` | Nine skills (the `/ocpf-bc:` commands), three sub-agent definitions, the AL tooling helper scripts, and an *offline fallback copy* of the framework. Installed once per machine into Claude Code or GitHub Copilot. | Same repository, folder `agentPlugin/ocpf-bc`, published as a plugin marketplace. | 4.0.0 |
| **The Visual Studio Code setup extension** | A bootstrapper and extension pack, published to the Visual Studio Marketplace and Open VSX. Installs the AL toolchain and the agent extensions, wires your agent to the plugin marketplace, and adds five Command Palette commands. It contains **no framework content**. | A separate repository, published as [`ajansari.ocpf-bc-dev-setup`](https://marketplace.visualstudio.com/items?itemName=ajansari.ocpf-bc-dev-setup) (also on [Open VSX](https://open-vsx.org/extension/ajansari/ocpf-bc-dev-setup)). | 0.0.10 |
| **Your project's copy** | The runbook and companions fetched into one AL project, pinned at the version fetched. | Your AL project folder: `CLAUDE.md` or `.github/copilot-instructions.md`, plus one `ocpfFramework/` folder holding the step files, templates, both guides, patterns, scripts, the changelog, the plugin's marker, and each developer's state. | Whatever was current when you started, until you approve an update |

The chain of responsibility is simple:

1. **The setup extension** gets a bare Visual Studio Code ready: AL Language, Claude Code and/or Copilot Chat,
   Git, and the plugin marketplace registered. It then hands you to the agent's chat.
2. **The agent plugin** gives the agent its commands. Its `start` command fetches the framework.
3. **The framework** is what the agent actually follows, step by step, for the life of the project.

The setup extension never needs an update when the framework changes. The plugin only needs one
when its skills change. Every new project gets the newest framework regardless of either.
Section 7 explains this in full.

---

## 2. Setting up, three ways

You need one of these. All three end at the same place: the `ocpf-bc` plugin installed in your
agent, and an AL project folder open in Visual Studio Code.

### 2a. The Visual Studio Code setup extension (recommended for a fresh machine)

OnlyCopilotFans publishes its Visual Studio Code extensions under the publisher **AJ Ansari -
OnlyCopilotFans** (`ajansari`), on both the Visual Studio Marketplace and Open VSX. This is the
current list.

| Extension | Identifier | Visual Studio Marketplace | Open VSX | What it does |
|---|---|---|---|---|
| **OnlyCopilotFans Business Central Agentic Dev Framework - Setup** | `ajansari.ocpf-bc-dev-setup` | [Listing](https://marketplace.visualstudio.com/items?itemName=ajansari.ocpf-bc-dev-setup) | [Listing](https://open-vsx.org/extension/ajansari/ocpf-bc-dev-setup) | Extension pack and first-run walkthrough. Installs the AL toolchain and the agent extensions, wires your agent to the framework's plugin marketplace, and adds the five **OCPF BC** Command Palette commands (Section 4). Ships no framework content. |

To install:

1. In Visual Studio Code, open the Extensions view and search for **OnlyCopilotFans**, or open the
   Marketplace listing above and click **Install**. On VSCodium or another Open VSX client, search
   the same name. Or from Quick Open (**Ctrl+P**, **Cmd+P** on Mac), paste:
   ```
   ext install ajansari.ocpf-bc-dev-setup
   ```
2. The extension pack installs the AL Language extension (required) and, alongside it, Claude Code,
   GitHub Copilot Chat, Insert GUID, AL Code Outline, Markdown Preview Enhanced, and Rainbow CSV.
   Every pack member other than AL Language can be uninstalled individually. Installing an agent
   extension needs no subscription; using one does.
3. The **Set up the OCPF BC Framework** walkthrough opens. Follow its three steps: choose your
   agent, check Git, start a project. Each button runs one of the Command Palette commands in
   Section 4.
4. When the chat panel opens, send:
   ```
   /ocpf-bc:start
   ```

### 2b. Install the plugin directly (already have Visual Studio Code and AL set up)

Pick the one row that matches your tool.

| Your tool | How |
|---|---|
| **Claude Code in Visual Studio Code** | **One-click:** paste this into your browser's address bar and confirm the install in Visual Studio Code:<pre lang="text"><code>vscode://anthropic.claude-code/install-plugin?plugin=ocpf-bc&amp;marketplace=ajansari/ocpfBcAgenticDevFramework</code></pre>**Or by hand,** in Claude Code:<br>1. Run `/plugins` → **Marketplaces** → add this marketplace:<pre lang="text"><code>ajansari/ocpfBcAgenticDevFramework</code></pre>2. **Plugins** tab → **ocpf-bc** → **Install** (choose **User** scope). |
| **GitHub Copilot Chat in Visual Studio Code** | 1. Add the marketplace to your Visual Studio Code settings (JSON):<pre lang="json"><code>"chat.plugins.marketplaces": ["ajansari/ocpfBcAgenticDevFramework"]</code></pre>2. Extensions view → search `@agentPlugins` → **ocpf-bc** → **Install**.<br><br>No agent plugins listed at all? Turn on this setting:<pre lang="json"><code>"chat.plugins.enabled": true</code></pre> |
| **Claude Code CLI** | 1. Add the marketplace:<pre lang="text"><code>/plugin marketplace add ajansari/ocpfBcAgenticDevFramework</code></pre>2. Install the plugin:<pre lang="text"><code>/plugin install ocpf-bc@onlycopilotfans</code></pre> |
| **GitHub Copilot CLI** | 1. Add the marketplace:<pre lang="text"><code>copilot plugin marketplace add ajansari/ocpfBcAgenticDevFramework</code></pre>2. Install the plugin:<pre lang="text"><code>copilot plugin install ocpf-bc@onlycopilotfans</code></pre> |

Plugins installed in the Claude Code CLI and the Visual Studio Code extension are shared, and appear in the
Claude Desktop app's Code tab. Visual Studio Code picks up plugins installed by Copilot CLI. Installing once
usually covers the whole machine.

### 2c. Manual, no plugin

Copy the runbook into your project by hand as `CLAUDE.md` or `.github/copilot-instructions.md`,
and start the agent with the "Getting started prompt" from the README's manual sections. The
framework behaves the same. You lose the `/ocpf-bc:` commands, the automatic update check, and the
one-step AL tooling setup. Section 8 covers what to do instead.

---

## 3. A project, start to finish

### What `/ocpf-bc:start` does

Open your AL project folder, or an empty folder for a new extension, and send `/ocpf-bc:start` in
the agent's chat. Or say it in words: *"Start a Business Central project with the OCPF framework."*
Add `full` or `lite` to skip the edition question.

| | What happens | What you do |
|---|---|---|
| **1** | **Checks the folder.** If the project already follows the framework, it stops and offers `status` or `update-framework` instead. It never starts twice. | Nothing. |
| **2** | **Full or Lite.** It asks about scope and recommends an edition. Lite: roughly 5 to 10 AL files, one person, one model. Full: more objects, several sign-off roles, split models, or AppSource. | Confirm or override. Lite's documents carry straight over into Full if you switch later. |
| **3** | **Where the runbook goes.** `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for Copilot, or both for a mixed team. | Nothing, unless a file with that name already exists. Then it asks; it never overwrites. |
| **4** | **Fetches the latest runbook** and its changelog from GitHub, byte for byte, and records the commit and version in `ocpfFramework/framework.json`. If GitHub is unreachable it uses the plugin's bundled copy and tells you so, naming the version. | Nothing. |
| **5** | **Connects Microsoft's AL tools.** In Copilot Chat they are built into the AL Language extension. In Claude Code and Copilot CLI, it registers the extension's bundled AL MCP Server for the project. Nothing is installed; no PATH edits. | Approve the connection once when asked. |
| **6** | **Begins the routine** at the first step: PRE-01 (Full) or Step 1 (Lite). | See the first hour, below. |

### The first hour is interactive. Stay for it.

The first step asks for everything the design will depend on, the way a kickoff meeting with a
newly hired developer would. In order:

1. **Your working language.** You can work with the agent in your own language.
2. **How to be notified** when it is your turn: Claude app push, sound, desktop notification, or
   none. The agent sets this up itself and remembers it per project.
3. **Which models do the work.** The agent first says, once: *a High thinking effort makes every
   task slower — the model thinks longer before each answer, and a step can take noticeably more
   time; the framework recommends High only where judgment matters most.* Full then asks six
   questions: Main, Light, and Reasoning model, each with a thinking effort. Recommended in Claude
   Code: **Sonnet Medium / Haiku Medium / Opus High**; in GitHub Copilot: **Gemini 3.8 Flash Medium
   / Auto Balanced / Claude Opus 5.5 High** (the picker's names; if one is not in the picker that
   day, the agent offers the nearest and says so). Lite asks two: recommended **Sonnet Medium** or
   **Gemini 3.8 Flash Medium**. Full then writes project-local sub-agent definitions (reasoning,
   light, and the generator, which runs on the Main model) carrying those choices, so delegated
   work actually runs on the models you picked.
4. **Copilot only:** the agent-mode request limit (150 recommended) and how tool approvals should
   work. Written to the workspace's `.vscode/settings.json`.
5. **The fetched companions.** The Standards Guide, the Operations Guide, the step files, and the
   document templates come into `ocpfFramework/`, all gitignored.
6. **The problem itself:** purpose, scope, out of scope, who uses it, initial entities. Then, in
   Full, the gap analysis and the Project Parameters sheet: publisher, prefix, namespace, ID
   ranges, countries and languages, and the starting version (`0.0.0.1` for a new app; for an
   existing app, the version installed in the target environment).
7. **An app icon?** *Yes — I'll provide an image*, *No icon*, or *Later* (for AppSource it is a
   release blocker). On yes, give the path: PNG, square, 300 × 300 px is ideal. The agent copies it
   to `src/logo/AppLogo.png`, resizing a larger image with what the machine has and padding a
   non-square one rather than cropping it, and sets `"logo"` in `app.json`.

AL source lives under `src/` (subfolders per module are fine); the app icon under `src/logo/`.

Answer the option boxes, correct anything the agent suggests, and say more rather than less.
Anything vague here flows downstream into a requirement the FRD never captured and code that
compiles cleanly and does the wrong thing.

### After that, step away

From the DESIGN phase on (Full Step 02, the FRD; Lite Step 2, the Design Doc) the agent works in
longer stretches and comes back only to approve a document, choose between options, or answer a
question. With Claude Code and the Claude app notification, you can read the question and answer
it from your phone.

### The phases

| Phase | Full (14 steps) | Lite (7 steps) |
|---|---|---|
| **DEFINE** | PRE-01 State the Problem · PRE-02 Gap Analysis · 01 Project Parameters | 1 Define the Problem and Lock Parameters |
| **DESIGN** | 02 FRD · 03 TDD, Human and AI Effort Estimates · 04 Sanity Check | 2 Design Doc and Self-Check |
| **BUILD** | 05 Plan the Code · 06 Code Generation · 07 Compile, Package, Troubleshoot | 3 Plan and Scaffold · 4 Generate · 5 Compile, Package, Test |
| **PROVE** | 08 Gap-Fit Test · 09 Code Review · 10 Update Design Docs · 11 Document · 12 Release for Testing | 6 Review, Gap-Check, Finalize Docs · 7 Release for Testing |

Every step has an exit gate. The agent does not start a step until the previous gate is met, and it
pauses for your approval before generating code, before deploying, and at each sign-off. Zero
compile errors and zero warnings are required before PROVE begins.

### Resuming later, or on another device

Send `/ocpf-bc:status`. It reads the project's own files, not chat memory, and reports the phase,
step, exit gate, what is waiting on you, and whether the AL tools and notifications are set. Then
carry on.

---

## 4. Visual Studio Code Command Palette commands

These come from the **setup extension**, not the plugin. They prepare the machine and the project;
they never touch framework content. Open the Command Palette with **Ctrl+Shift+P** (Windows and
Linux) or **Cmd+Shift+P** (Mac) and type **OCPF** to see all five. They sit under the category
**OCPF BC**.

| Command | What it does | Use it when |
|---|---|---|
| **OCPF BC: New AL Project + Framework** | Runs Microsoft's AL project wizard (the AL Language extension's own). Waits for the new project to exist, including across the window reload the wizard can trigger, then rolls into the kickstart flow below. Cancel the wizard and nothing further happens. | You have no AL project yet. |
| **OCPF BC: Kickstart Framework Here** | For an AL project already open. Verifies Git, asks which agent will run the framework (Claude Code, GitHub Copilot, or both), wires it, then opens the chat panel pointed at `/ocpf-bc:start`. It deliberately stops there: fetching framework files is the agent's job, which keeps the extension independent of framework releases. | You have an existing AL project and want the framework in it. |
| **OCPF BC: Set Up Claude Code** | Installs the Claude Code extension if missing, then checks Claude Code's own record of installed plugins. If `ocpf-bc` is already installed it says so, with version and scope, and stops (a **Reinstall anyway** button is there if you need it); otherwise it opens Claude Code's plugin-install dialog pointed at the framework's marketplace. You confirm the `ocpf-bc` install and its scope; nothing installs until you do. Re-runnable. | You changed agents, reinstalled Claude Code, or setup did not finish. |
| **OCPF BC: Set Up GitHub Copilot** | Installs the GitHub Copilot Chat extension if missing, registers the framework's marketplace in your user settings (`chat.plugins.marketplaces`), makes sure `chat.plugins.enabled` is on, and offers to open the Extensions view filtered to `ocpf-bc` so you can click Install. Re-runnable. | Same situations, Copilot path. |
| **OCPF BC: Check Git Installation** | Verifies `git` is on your PATH. If missing, shows an **Install Git** button that runs the right installer in a terminal you can watch: `winget install Git.Git` on Windows, `xcode-select --install` on Mac, a package-manager hint on Linux. Nothing installs silently. | Confirming a machine is ready, or after installing Git. |

The **Set up the OCPF BC Framework** walkthrough (Help → Open Walkthrough) is the same five
commands as a guided checklist.

**Requirements:** Visual Studio Code 1.96 or later, Git, and a Claude or GitHub Copilot subscription for the
agent you choose to use.

---

## 5. Agent plugin commands

These come from the **`ocpf-bc` plugin**. Type them in the agent's chat panel in Claude Code or
GitHub Copilot Chat, or in either CLI. The commands are identical in every tool. Each one is a
skill, so you can also ask for it in words; the phrases in the last column are examples the plugin
recognises.

| Command | What it does | Say it in words |
|---|---|---|
| `/ocpf-bc:start` | Starts a project: chooses Full or Lite, fetches the latest runbook from GitHub, places it, connects the AL tools, begins the routine. Accepts `full` or `lite`. Never overwrites a file and never starts a project twice. | "start a Business Central project", "kick off an AL project" |
| `/ocpf-bc:status` | Reports where the project stands: phase, step, exit gate, what is waiting on you, edition and version, AL tools, tooling checks, models, notifications, and last usage total. Reads `ProjectProgress.md` in both editions, and reports a closed step with no usage row as a blocker. Accurate in a fresh session. | "where are we", "what's next", "what step are we on" |
| `/ocpf-bc:documents <name>` | Writes any project document from its template into its phase folder under `docs/`: FRD, TDD, Sanity Check, Human Effort Estimate (with its baselines), AI Effort Estimate, Build Plan, ChangeLog, Gap Analysis, Code Review (with its scorecard), Documentation, User Guide, Human Unit Test Script, Deployment, Release Test Results, Acknowledgements, Project Progress, and Lite's Design Doc, Docs, and Test Script. Reads only the inputs the step names and briefs the reasoning sub-agent narrowly where the step delegates. The routine normally invokes it for you. | "write the FRD", "draft the TDD", "create the build plan" |
| `/ocpf-bc:usage --step <id>` | The step boundary ritual. At a step's start, the runbook timestamps it and marks its `ProjectProgress.md` row *In Progress*; at its close, before the exit-gate message, this command measures what the step consumed — input, output, cache-write, and cache-read tokens per model in Claude Code, or AI credits per model in GitHub Copilot in VS Code (sub-agents included in both), elapsed time, turns, decisions asked, and cost at published API prices fetched from the publisher — and writes **one row per model that ran in the step** into the usage table in `ProjectProgress.md`, in both editions. The exit gate is not met until the rows exist, and a row is never typed by hand. Run without `--step` for the whole project; at project close it also exports a calibration file to `~/.ocpf/calibration/` for the AI effort estimator. | "what has this cost", "how many tokens", "update the usage table" |
| `/ocpf-bc:roles` | Says once that a High thinking effort makes every task slower, then asks which models do the work (Full: Main, Light, Reasoning, each with a thinking effort; Lite: one), offering the recommended pair first, and makes it take effect by writing the three project-local sub-agent copies — reasoning, light, and the generator on the Main model — with the chosen model and effort, then verifies the session model. The runbook runs it at the first step; run it by hand to change or repair the assignment. | "choose models", "use Opus for reasoning", "which model runs the FRD" |
| `/ocpf-bc:notifications` | Turns on "your turn" notifications: Claude app push, sound, desktop notification, or none. Records the answer in `ocpfFramework/state/notifications.json` and applies it through the tool's own settings and hooks. Nothing to install. The runbook does this at the first step; use the command on an older project or to repair. | "notify me when you're done", "alert me when it's my turn" |
| `/ocpf-bc:al-mcp-setup` | Connects the agent to Microsoft's AL tools (build, compile, symbols, diagnostics, publish, tests) using the AL Language extension already on the machine. Nothing installed, no PATH edits. In Copilot Chat there is nothing to do; in Claude Code and Copilot CLI it registers the bundled AL MCP Server. `start` normally does this for you. | "connect the AL tools", "why can't you compile" |
| `/ocpf-bc:al-standards` | Loads the OCPF AL Development Standards Guide: naming and abbreviations, object ID allocation, API page design, field inclusion, anti-patterns, events, upgrade code, multilanguage and XLIFF rules, parent-child pages and number series. The routine applies it automatically; run it directly for an ad-hoc review. | "check this AL against OCPF standards" |
| `/ocpf-bc:update-framework` | Checks whether a newer runbook has been published, summarises every changelog entry between your version and the latest, says whether any touches a step you have already completed, and updates the project's copy only after you choose **Update now**. Backs up the old copy first. On a project from an older layout (Full before 5.0.0.0, Lite before 5.0.0.0) it also runs the migration: moves the framework files into `ocpfFramework/`, the documents into the `docs/` phase folders, rewrites the `.gitignore` block and the tool paths, creates Lite's `ProjectProgress.md` from the old usage report, and lists every move in the ChangeLog. | "is there a newer runbook", "update the framework" |

Three sub-agents ship with the plugin — the first two for the Full framework, the generator for both editions: **ocpf-reasoning** (FRD and TDD
drafting, Sanity Check, root-cause diagnosis, Gap-Fit, Code Review), **ocpf-light** (post-
generation pre-flight checks and symbol verification), and **ocpf-generator** (writes the AL files
for one batch, so batches can be generated in parallel). None carries a model of its own. The
`roles` command writes your project's copies with the models you chose; the generator takes the
Main model. You do not invoke them directly; the runbook delegates to them, in the background.
In Claude Code, permission prompts from a background sub-agent still surface in the main session.

---

## 6. What lands in your project

The two editions place the same framework files and differ in the documents they produce. The
project root holds only what the tools require; everything the framework fetches or keeps lives
in one folder, `ocpfFramework/`, and every project document lives in a phase folder under
`docs/`.

```
app.json  .gitignore  CLAUDE.md  .github/  .claude/  .vscode/  .alpackages/  Translations/
src/                 all AL source; subfolders per module allowed; the app icon in src/logo/
docs/                project documents, by phase (below)
requirements/        raw input you handed over, verbatim
outputAppPackage/    every built package
ProjectProgress.md   both editions: the step tracker and the usage and cost table
ocpfFramework/       everything the framework fetches or keeps (below)
```

### `ocpfFramework/`, both editions

| Path | What it is | In Git? |
|---|---|---|
| `ocpfFramework/README.md` | Six fixed lines saying what the folder is and that its contents are fetched, not edited. | With the framework files |
| `ocpfFramework/framework.json` | The plugin's marker: edition, runbook version, source, commit, layout, where copies were placed, any skipped update, AL tools and tooling-check outcomes. | With the framework files |
| `ocpfFramework/RunbookChangelog.md` (Full) or `LITE_RunbookChangeLog.md` (Lite) | The framework's version history. | With the framework files |
| `ocpfFramework/runbookSteps/` | One file per step: `PRE-01.md` … `12.md` (Full) or `STEP-1.md` … `STEP-7.md` (Lite). The step file is the step; the agent reads it in full when the step starts. | Never |
| `ocpfFramework/documentTemplates/` | One template per project document. | Never |
| `ocpfFramework/standardsGuide/`, `ocpfFramework/opsGuide/` | The two companion guides, each with a `SNAPSHOT.json` naming the commit fetched. | Never |
| `ocpfFramework/patterns/`, `ocpfFramework/scripts/` | The fetched patterns library and the AL tooling, notification, and usage helper scripts. | Never |
| `ocpfFramework/state/` | Each developer's own: `usage.json` (step timestamps), `pricing.json` (fetched prices), `notifications.json`, `copilot.json` (Copilot session settings), and `previous/` (backups of the runbook made before each approved update). | Never |

Outside that folder:

| Path | What it is | In Git? |
|---|---|---|
| `CLAUDE.md` and/or `.github/copilot-instructions.md` | The runbook core: operating rules, a stub per step, the always-on disciplines. Loaded on every request. If the file already existed when you started, the runbook sits at `ocpfFramework/BC_App_Build_Routine_Agent.md` (or the Lite name) and `CLAUDE.md` holds one import line, or it is placed as `.github/instructions/ocpf-framework.instructions.md` for Copilot. | With the framework files |
| `.claude/agents/ocpf-*.md` or `.github/agents/ocpf-*.agent.md` | The project-local sub-agent copies carrying your chosen models: `ocpf-reasoning`, `ocpf-light`, and `ocpf-generator` in Full; `ocpf-generator` only in Lite (it runs on the Main model). | With the framework files |
| `.vscode/settings.json`, `.mcp.json` | The analyzers the framework turns on, the AL tools connection, and, with Copilot, the request limit and approval keys. | Yes |
| `.alpackages/`, `*.g.xlf` | Downloaded symbols and generated translation files. | Never |
| `src/`, `Translations/*.xlf`, `outputAppPackage/`, `requirements/`, `docs/`, `ProjectProgress.md` | Your extension, its translations, every package built, your raw input, and every project document. | Always |

**The `.gitignore` defaults.** The first step writes two blocks. The first is always written: the
fetched folders under `ocpfFramework/` (guides, steps, templates, patterns, scripts), `ocpfFramework/state/`,
`.claude/settings.local.json`, `.alpackages/`, and `*.g.xlf`. The second is written unless you
answer *No, track them* at the first step: the whole `ocpfFramework/` folder, the runbook copies,
and the sub-agent files, so the framework stays out of your project's remote by default. The
framework never ignores `docs/`, `requirements/`, `outputAppPackage/`, `*.app`,
`Translations/*.xlf`, `ProjectProgress.md`, or `src/`.

### Documents, both editions

All tracked. Translated copies sit beside their source (`UserGuide.fr-CA.md`, `Docs.fr-CA.md`,
`TestScript.fr-CA.md`).

| Folder | Full | Lite |
|---|---|---|
| Project root | `ProjectProgress.md` — PRE-01; the step tracker and the usage and cost table, one row per step and model, written at every step boundary | `ProjectProgress.md` — Step 1; the same tracker and table |
| `docs/0-project/` | `ChangeLog.md`, `ProjectMemory.md` (every decision from PRE-01 on), `Roadmap.md`, `TestingFeedback.md`, `Acknowledgements.md` (Step 11) | `ChangeLog.md` (the single running log, from Step 1 on; carries the code review scorecard at Step 6), `Acknowledgements.md` (Step 6) |
| `docs/1-define/` | `ProblemStatement.md` (PRE-01), `ProjectParameters.md`, `ObjectRegister.md`, `TranslationGlossary.md` (Step 01) | `ProblemStatement.md`, `ProjectParameters.md` (Step 1) |
| `docs/2-design/` | `FRD.md` (Step 02), `TDD.md`, `HumanEffortEstimate.md`, `AiEffortEstimate.md` (Step 03), `SanityCheck.md` (Step 04) | `DesignDoc.md`, `HumanEffortEstimate.md`, `AiEffortEstimate.md` (Step 2; the Design Doc is updated in place at Step 6) |
| `docs/3-build/` | `BuildPlan.md` (Step 05) | — |
| `docs/4-prove/` | `GapAnalysis.md` (08), `CodeReview.md` (09), `PostDevTDD.md` (10), `Documentation.md`, `UserGuide.md`, `HumanUnitTestScript.md`, `AutomatedTestScripts.md`, `Deployment.md` (11), `ReleaseTestResults.md` (12) | `Docs.md`, `TestScript.md` (Step 6) |

Lite keeps no Project Memory, and only one sub-agent file — the generator, on the Main model — because one model does all the work.
There is no separate usage report in either edition; the usage table is in `ProjectProgress.md`.

---

## 7. Updates

Three things update, on three different schedules. Knowing which is which answers most questions.

### 7a. A new project always gets the latest framework

`/ocpf-bc:start` does not copy the framework out of the plugin. It fetches the runbook from the
GitHub repository's `main` branch at the moment you run it, and records the commit it came from.
At the first step, the runbook then fetches its own step files, the templates, and both guides
from the same place. So:

- A project started today gets today's framework, **even if your plugin was installed months ago
  and never updated.**
- The plugin's bundled copy of the framework is used only when GitHub cannot be reached, and the
  agent says so plainly, naming the bundled version. A stale start never happens silently.

### 7b. An existing project keeps its version until you say otherwise

Once fetched, a project's runbook is pinned. The rules do not change halfway through a step
without your say. Every session, before resuming work, the agent reads the version line of the
latest published runbook (the first kilobyte, not the whole file) and compares it with the
project's. If there is a newer one, and it is not one you chose to skip, it tells you at the next
step boundary and offers three choices:

| Choice | What happens |
|---|---|
| **Update now** | The agent summarises every changelog entry in between, flags any that touch a step you have completed, backs up the current copy to `ocpfFramework/state/previous/`, replaces the runbook, the changelog, the step files, the templates, and the two guides with the versions the new runbook expects, updates the marker, records the change in `docs/0-project/ChangeLog.md` (and Project Memory in Full), and re-reads the runbook before continuing. When the project is on an older layout (Full before 5.0.0.0, Lite before 5.0.0.0), the same approval also moves its files into `ocpfFramework/` and the `docs/` phase folders, rewrites the `.gitignore` block and the tool paths, creates Lite's `ProjectProgress.md` from the old usage report, and lists every move in the ChangeLog. |
| **Not now** | Nothing changes. It asks again next session. |
| **Skip this version** | It records the skipped version and stays quiet until something newer is published. |

You can also ask at any time with `/ocpf-bc:update-framework`. The agent recommends **Update now**
unless you are mid-way through a step whose rules the new version changes; then it recommends
finishing the step first. Nothing needs to be set up; it needs only internet access to
`raw.githubusercontent.com`.

### 7c. The plugin updates through your tool's plugin mechanism

The plugin is a separate package, cached by your tool. It changes when its **skills** change: a
new command, a fix to how `start` or `documents` behaves, new AL tooling scripts, or a refreshed
offline copy. A framework release on its own does not require a plugin update, and a plugin update
never changes a project's pinned runbook.

| Tool | Automatic? | To turn on automatic updates | To check by hand |
|---|---|---|---|
| **Claude Code** (Visual Studio Code, CLI, Desktop) | **Off by default** for third-party marketplaces like this one | `/plugin` → **Marketplaces** → **onlycopilotfans** → **Enable auto-update**. Updates then install in the background and you are prompted to run `/reload-plugins`. | `/plugin marketplace update onlycopilotfans`, then `/plugin update ocpf-bc@onlycopilotfans` |
| **GitHub Copilot Chat in Visual Studio Code** | **On,** when Visual Studio Code's `extensions.autoUpdate` is on (the default). Checked every 24 hours. | Nothing to do | Command Palette → **Extensions: Check for Extension Updates** |
| **GitHub Copilot CLI** | **Off** for added marketplaces, but `/plugin` shows when an update is available | Add `"autoUpdate": true` to the `onlycopilotfans` entry under `extraKnownMarketplaces` in `~/.copilot/settings.json` | `copilot plugin update ocpf-bc` |

**When does a stale plugin matter?** Only when a framework release depends on new skill behaviour.
The plugin's [CHANGELOG](agentPlugin/ocpf-bc/CHANGELOG.md) says so when it does. The clearest
case so far is plugin 5.0.0, which taught `update-framework` the migration to the `ocpfFramework/`
layout that runbook 5.0.0.0 (Lite 5.0.0.0) introduced; before it, plugin 3.0.0 taught it to fetch
the step files and templates of runbook 4.0.0.0. If the agent behaves as though a documented command or feature
does not exist, update the plugin first, then try again.

### 7d. The setup extension updates like any Visual Studio Code extension

Visual Studio Code updates it automatically with the rest of your extensions. It ships no framework content
and no version numbers, so a framework release never requires an extension update. It changes only
if the repository or plugin is renamed, if Microsoft or Anthropic change the settings keys or
install links it uses, or if the extension pack list changes.

### Summary

| What | How you get the latest | Frequency |
|---|---|---|
| Framework, new project | `/ocpf-bc:start` fetches it | Every new project, automatically |
| Framework, existing project | Once-per-session check, applied on **Update now** | Offered each session, applied when you say |
| Agent plugin | Your tool's plugin update (see 7c) | Depends on the tool and your auto-update setting |
| Setup extension | Visual Studio Code extension auto-update | Automatic |

---

## 8. Working without the plugin

Everything in the framework works from a hand-copied runbook. The differences:

| With the plugin | Without |
|---|---|
| `/ocpf-bc:start` fetches and places the runbook | Download the runbook from the repository and save it as `CLAUDE.md` or `.github/copilot-instructions.md`; start with the README's "Getting started prompt" |
| Once-per-session update check | Run `/ocpf-bc:update-framework` if the plugin is installed later, or compare the version line yourself against the repository |
| `al-mcp-setup` connects the AL tools in one step | Follow Ops § AL Tools in the Operations Guide; the agent still does the work |
| `documents` writes from templates | The runbook still fetches the templates at the first step and writes from them; the skill only makes the briefing narrower |
| `usage` measures tokens and cost | Follow Ops § Usage & Cost by hand |
| `roles`, `notifications` | The runbook asks the same questions at its first step and follows Ops § Roles and Ops § Notifications |

The Operations Guide and the Standards Guide are fetched into the project either way. The plugin
adds convenience and offline fallback; it adds no rules.

---

## 9. Troubleshooting

**The agent started on a bundled runbook, not the latest.** GitHub was unreachable when you ran
`start`. The agent will have said so and named the version. Once online, the next session's check
offers the newer one. Or run `/ocpf-bc:update-framework`.

**`/ocpf-bc:` commands are not recognised.** The plugin is not installed in this tool, or agent
plugins are off. Claude Code: `/plugins` → **Plugins** should list `ocpf-bc`. Copilot Chat: check
`chat.plugins.enabled` and the `chat.plugins.marketplaces` entry, then the `@agentPlugins` filter
in the Extensions view. The setup extension's **Set Up Claude Code** and **Set Up GitHub Copilot**
commands redo the wiring.

**The agent says it cannot compile, or cannot see AL diagnostics.** Run `/ocpf-bc:al-mcp-setup`.
In Copilot Chat, make sure the AL Language extension is active (open any `.al` file). In Claude
Code, approve the AL MCP Server connection when prompted.

**Delegated work ran on the wrong model (Full).** Run `/ocpf-bc:roles`. It rewrites the
project-local sub-agent files with the recorded model and effort and verifies them.
`/ocpf-bc:status` shows whether those files exist and match.

**Red squiggles in AL files, but the code compiles and the agent reports no errors.** The AL
language service is out of sync with disk. Command Palette → **Developer: Reload Window**.

**Git not detected after installing it.** Visual Studio Code only finds new programs at startup. Close and
reopen Visual Studio Code completely, then run **OCPF BC: Check Git Installation** again. If Git then asks who
you are, run once:

```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

**Copilot stops with "Copilot has been working on this problem for a while…"** The agent-mode
request limit is too low for a design step. The first step asks for it (150 recommended) and
writes it to `.vscode/settings.json`; raise it there if you chose the default.

**Two runbook copies disagree.** A mixed team placed both `CLAUDE.md` and
`.github/copilot-instructions.md`. `update-framework` updates every path recorded in
`ocpfFramework/framework.json`, so run it once and both copies match again.

**The agent says mermaid is "not installed", but diagrams rendered before.** An older runbook
looked for `mmdc` on the PATH, and packages run through `npx` are never on the PATH, so the check
failed on a machine that had it. The framework now checks `node --version` and then
`npx --yes @mermaid-js/mermaid-cli --version` (no network when the package is cached), and records
the outcome in `ocpfFramework/framework.json` under `tooling`. If Node itself is missing, the
agent offers the install for your operating system (`winget install --id OpenJS.NodeJS.LTS` on
Windows, the LTS package from nodejs.org on macOS, the distro package on Linux) and runs it only
with your approval.

**PowerShell is missing, or a `.ps1` helper will not run.** The framework's own `.ps1` helpers run
on Windows PowerShell 5.1, which every Windows machine has. PowerShell 7 (`pwsh`) is needed only by
the XLIFF Sync module and the usage script's `.ps1` port, and is recommended, not required, by
BCQuality. The framework checks `pwsh --version` and, if it is missing, offers the install with
your approval: `winget install --id Microsoft.PowerShell --source winget` on Windows, the `.pkg`
from the PowerShell releases page on macOS, Microsoft's package repository on Ubuntu and Debian,
`sudo dnf install powershell` on RHEL and Fedora. The outcome is recorded under `tooling` in
`ocpfFramework/framework.json`.

**Extension Management refuses the upload: the same version cannot be uploaded twice.** A version
already installed in a tenant can never be uploaded again, which is why the framework never builds
twice at one version. A new app's first build goes out at `0.0.0.1` as written; before every build
after it the agent reads the version from `app.json`, increments the fourth segment (Revision) —
`0.0.0.2`, `0.0.0.3`, and so on — writes it back, then builds. An existing app's first build
increments from the version already installed, and every later build increments again; if the output file already exists it increments again, and the build scripts refuse to
overwrite an existing package. If you hit this message, a package was built outside the routine:
ask the agent to build again and it will increment the Revision as usual. Major, Minor, and Build
bumps, and the `1.0.0.0` release candidate, are still proposed and approved. Every build's closing
message names the package, the previous build, and the Schema Sync Mode the upload needs.

---

## 10. Where to get help

- **Official website:** <https://ajansari.github.io/ocpfBcAgenticDevFramework/>
- **Repository and README:** <https://github.com/ajansari/ocpfBcAgenticDevFramework>
- **Issues** (framework, plugin, and setup extension alike):
  <https://github.com/ajansari/ocpfBcAgenticDevFramework/issues>. Include what you ran and what you
  saw.
- **Release notes:** [fullVersion/RunbookChangelog.md](fullVersion/RunbookChangelog.md),
  [liteVersion/LITE_RunbookChangeLog.md](liteVersion/LITE_RunbookChangeLog.md),
  [agentPlugin/ocpf-bc/CHANGELOG.md](agentPlugin/ocpf-bc/CHANGELOG.md)
- **Setup extension listings:**
  [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=ajansari.ocpf-bc-dev-setup) ·
  [Open VSX](https://open-vsx.org/extension/ajansari/ocpf-bc-dev-setup)

---

*Licensed under the PolyForm Shield 1.0.0 license — source-available, free to use. See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).*
