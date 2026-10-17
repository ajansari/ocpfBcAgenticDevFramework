# OCPF BC Agentic Development Framework — User Guide

**The OnlyCopilotFans Business Central Agentic Development Framework**

*by AJ Ansari*

**Last Updated:** Friday, October 17, 2026
**Covers:** Full runbook v5.8.0.0 · Lite v5.8.0.0 · Standards Guide v1.12.1.0 · Operations Guide
v5.8.0.0 · `ocpf-bc` agent plugin v5.8.0 · Visual Studio Code setup extension v0.0.17

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
| **The framework** | The runbook (Full or Lite), its step files, the document templates, the **Standards Guide**, and the **Operations Guide**. This is the content the AI agent follows. | The public GitHub repository, `ajansari/ocpfBcAgenticDevFramework`, on its `main` branch. | Full 5.8.0.0 · Lite 5.8.0.0 · Standards 1.12.1.0 · Ops 5.8.0.0 |
| **The agent plugin** `ocpf-bc` | Fourteen skills (the `/ocpf-bc:` commands), five sub-agent definitions, the AL tooling helper scripts, the dashboard renderer, and an *offline fallback copy* of the framework. Installed once per machine into Claude Code or GitHub Copilot. | Same repository, folder `agentPlugin/ocpf-bc`, published as a plugin marketplace. | 5.8.0 |
| **The Visual Studio Code setup extension** | A bootstrapper and extension pack, published to the Visual Studio Marketplace and Open VSX. Installs the AL toolchain and the agent extensions, wires your agent to the plugin marketplace, and adds six Command Palette commands. It contains **no framework content**. | A separate repository, published as [`ajansari.ocpf-bc-dev-setup`](https://marketplace.visualstudio.com/items?itemName=ajansari.ocpf-bc-dev-setup) (also on [Open VSX](https://open-vsx.org/extension/ajansari/ocpf-bc-dev-setup)). | 0.0.17 |
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
| **OnlyCopilotFans Business Central Agentic Dev Framework - Setup** | `ajansari.ocpf-bc-dev-setup` | [Listing](https://marketplace.visualstudio.com/items?itemName=ajansari.ocpf-bc-dev-setup) | [Listing](https://open-vsx.org/extension/ajansari/ocpf-bc-dev-setup) | Extension pack and first-run walkthrough. Installs the AL toolchain and the agent extensions, wires your agent to the framework's plugin marketplace, keeps the `ocpf-bc` plugin current, and adds the six **OCPF BC** Command Palette commands (Section 4). Ships no framework content. |

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
Add `full`, `lite`, or `feature` to skip the journey question.

| | What happens | What you do |
|---|---|---|
| **1** | **Checks the folder.** If the project already follows the framework, it offers `status`, `update-framework`, or *Build a feature in this project* instead. It never starts Full or Lite twice. An existing extension that never used the framework is recognised too — and if nobody can explain it (no FRD, TDD, design doc, or README), it offers to **analyze and document it first** (`/ocpf-bc:analyze`, below) before you choose a journey. | Nothing, or say yes to the analysis. |
| **2** | **Full, Lite, or Build-a-Feature.** It asks about the kind of work — not a file count — and recommends a journey. **Full:** a complete app or solution end to end, or a major overhaul of a big existing app; the full requirements, design, documentation, and testing trail on three models; at least three to four hours. **Lite:** updating an existing app, or a new app without a large footprint; one model, fewer steps, leaner documents; one to two hours. **Build-a-Feature:** quick, tactical customizations — a table and its pages, a field on a page, a processing report, an API, a role center — in minutes, not vibe-coding but lean on documentation (six short documents in a flat `docs/`); ideal for a PoC or prototype; recommended first on an existing extension. | Confirm or override. Lite's documents carry straight over into Full if you switch later; a Build-a-Feature extension is an existing app to Lite or Full. |
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
   **Gemini 3.8 Flash Medium**. The agent then writes project-local sub-agent definitions carrying
   those choices — reasoning and light in Full, and in both editions the generator and the reviewer,
   which run on the Main model — so delegated work actually runs on the models you picked.
4. **Copilot only:** the agent-mode request limit (150 recommended), written to the workspace's
   `.vscode/settings.json`, and how tool approvals should work, written to your own user settings
   unless you explicitly choose to share them with the team.
5. **The fetched companions.** The Standards Guide, the Operations Guide, the step files, and the
   document templates come into `ocpfFramework/`, all gitignored.
6. **The problem itself:** purpose, scope, out of scope, who uses it, initial entities. Then, in
   Full, the gap analysis and the Project Parameters sheet: publisher, prefix, namespace, ID
   ranges, countries and languages, and the starting version (`0.0.0.1` for a new app; for an
   existing app, the version installed in the target environment).
7. **An app icon?** *Use `images/<file>`* when you put one in `images/`, *Yes — I'll provide an
   image*, **Create one for me**, or *No icon* (type *Later* if you want; for AppSource it is a
   release blocker). On yes, give the path: PNG, square, 300 × 300 px is ideal. The agent copies it
   to `src/logo/AppLogo.png`, resizing a larger image with what the machine has and padding a
   non-square one rather than cropping it, and sets `"logo"` in `app.json`. On *Create one for me*
   the `app-icon` command asks the style, colors, content, and description, draws the icon to the
   standard, shows it, and uses it only once you accept it.

AL source lives under `src/` (subfolders per module are fine); the app icon under `src/logo/`, with the
image you brought, or the one the agent drew, kept in `images/`. Raw requirements go in `requirements/`.

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
Linux) or **Cmd+Shift+P** (Mac) and type **OCPF** to see all six. They sit under the category
**OCPF BC**.

| Command | What it does | Use it when |
|---|---|---|
| **OCPF BC: New AL Project + Framework** | Runs Microsoft's AL project wizard (the AL Language extension's own). Waits for the new project to exist, including across the window reload the wizard can trigger, then rolls into the kickstart flow below. Cancel the wizard and nothing further happens. | You have no AL project yet. |
| **OCPF BC: Kickstart Framework Here** | For an AL project already open. Verifies Git, asks which agent will run the framework (Claude Code, GitHub Copilot, or both), wires it, then opens the chat panel pointed at `/ocpf-bc:start`. It deliberately stops there: fetching framework files is the agent's job, which keeps the extension independent of framework releases. | You have an existing AL project and want the framework in it. |
| **OCPF BC: Set Up Claude Code** | Installs the Claude Code extension if missing, then checks Claude Code's own record of installed plugins. If `ocpf-bc` is already installed it says so, with version and scope, and stops (a **Reinstall anyway** button is there if you need it); otherwise it opens Claude Code's plugin-install dialog pointed at the framework's marketplace. You confirm the `ocpf-bc` install and its scope; nothing installs until you do. Re-runnable. | You changed agents, reinstalled Claude Code, or setup did not finish. |
| **OCPF BC: Update the ocpf-bc Plugin** | Runs the plugin freshness check on demand: repairs Claude Code's marketplace cache, turns on Claude Code's auto-update for the framework's marketplace, compares the installed plugin with the latest on GitHub, and updates it through Claude Code's CLI when that is on the machine (otherwise it names the two clicks: `/plugin` → `ocpf-bc` → Update). Also updates the Copilot CLI's copy when that CLI is installed. The same check runs by itself on every Visual Studio Code start, at most once every six hours. | The agent lacks a command the documentation mentions, or you want the plugin current now. |
| **OCPF BC: Set Up GitHub Copilot** | Installs the GitHub Copilot Chat extension if missing, registers the framework's marketplace in your user settings (`chat.plugins.marketplaces`), makes sure `chat.plugins.enabled` is on, and offers to open the Extensions view filtered to `ocpf-bc` so you can click Install. Re-runnable. | Same situations, Copilot path. |
| **OCPF BC: Check Git Installation** | Verifies `git` is on your PATH. If missing, shows an **Install Git** button that runs the right installer in a terminal you can watch: `winget install Git.Git` on Windows, `xcode-select --install` on Mac, a package-manager hint on Linux. Nothing installs silently. | Confirming a machine is ready, or after installing Git. |

The **Set up the OCPF BC Framework** walkthrough (Help → Open Walkthrough) is the setup commands
as a guided checklist: choose your agent, check Git, start a project.

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
| `/ocpf-bc:start` | The one launching point: chooses Full, Lite, or Build-a-Feature by the kind of work (a complete solution; an update or a modest new app; a quick customization), offers the analysis below on an undocumented existing app, fetches the latest runbook from GitHub (Full and Lite), places it, connects the AL tools, begins. Accepts `full`, `lite`, or `feature`. Never overwrites a file; on a project already on the framework it offers status, an update check, or a feature build instead of starting again. | "start a Business Central project", "kick off an AL project", "add a table to my extension" |
| `/ocpf-bc:analyze` | For an existing extension that is not well documented — written by a person, vibe-coded, or built by an agent that doesn't document. Asks what you already know and whether you have documents to add to `requirements/existing/`, which model does the analysis (a reasoning model such as Claude Opus, or a daily driver such as Claude Sonnet; in Copilot also GPT Sol and GPT Terra) and at which effort (Medium recommended; High is more detail-oriented but 1.5× to 3× longer and dearer), then reads `app.json`, every object, and the translations and writes a **presumed FRD**, a **presumed TDD**, an **Object Register**, **Documentation** that explains the app, its flows, and a schema of its tables and fields and how they connect — which objects are created or extended, the processing reports, API pages, permission sets, assisted-setup wizards, number series, role centers — and a **Project Parameters** sheet, all into `requirements/existing/` for you to review. Run it first; then put new requirements in `requirements/` and start a journey. | "document this app", "what does this extension do", "I inherited this extension" |
| `/ocpf-bc:build-a-feature` *(also through `start`)* | The quick-customization journey: opens the clock, asks *What do you want to build today?* (the one free-text question), **writes the proposed design to `docs/DataModel.md` before asking you to confirm it** in one box, writes the object from the Standards Guide and the patterns library, compiles clean with the analyzers, documents it the moment it compiles, offers the natural next object at every close (a table offers its list and card pages, an API page, permission grants; a role center comes with its cues and profile), then offers to review the code against the Standards Guide, BCQuality, and the AL Guidelines and to package a `.app` (new app `0.0.0.1`, existing app incremented; `1.0.0.0` once you say the package is tested and approved). One model does everything. Six short documents in a flat `docs/` — problem statement, feature register, data model, documentation, changelog, sandbox install guide. The publisher and the ID range are only ever what you chose in a box, never inferred. `ProjectProgress.md` keeps one row per object; usage is measured per object; the dashboard shows the objects with their stage and cost. | "just add a table", "add a field to the Customer Card", "I need an API page for", "a role center for", "quick mod" |
| `/ocpf-bc:app-icon` | Draws the app icon when you have none — the *Create one for me* option of every journey's identity box, or on its own. Asks in one box: flat 2D or isometric 3D; one color, two colors, or a two-color gradient, and which; an image only or a word mark with an image; anything it must show or avoid (or its best understanding of the app). The Main model writes the icon as an SVG to the standard — square, rounded corners, transparent background, 300 × 300, legible at 32 px — renders it to PNG with nothing installed (macOS Quick Look, a headless Chrome or Edge, or a preview page with a *Save as PNG* button), opens it, and asks **Accept** or *Make another*. The accepted icon is kept in `images/` and copied to `src/logo/AppLogo.png`, which `app.json` names. | "make me an app icon", "I don't have a logo", "design an icon for this app" |
| `/ocpf-bc:status` | Reports where the project stands: phase, step, exit gate, what is waiting on you, edition and version, AL tools, tooling checks, models, notifications, and last usage total. Reads `ProjectProgress.md` in both editions, and reports a closed step with no usage row as a blocker. Accurate in a fresh session. | "where are we", "what's next", "what step are we on" |
| `/ocpf-bc:documents <name>` | Writes any project document from its template into its phase folder under `docs/` (flat on Build-a-Feature): FRD, TDD, Sanity Check, Human Effort Estimate (with its baselines), AI Effort Estimate, Build Plan, ChangeLog, Gap Analysis, Code Review (with its scorecard), Documentation, User Guide, Human Unit Test Script, Deployment, Sandbox Install, Automated Test Guide, Release Test Results, Acknowledgements, Project Progress, Lite's Design Doc, Docs, and Test Script, and Build-a-Feature's Feature Register, Data Model, and Documentation. Reads only the inputs the step names and briefs the reasoning sub-agent narrowly where the step delegates. The routine normally invokes it for you. | "write the FRD", "draft the TDD", "create the build plan" |
| `/ocpf-bc:usage --step <id>` | The step boundary ritual. At a step's start, the runbook timestamps it and marks its `ProjectProgress.md` row *In Progress*; at its close, before the exit-gate message, this command measures what the step consumed — input, output, cache-write, and cache-read tokens per model in Claude Code, or AI credits per step in GitHub Copilot, read from the Copilot SDK's session journal, VS Code's chat and the CLI alike (sub-agents included in both), elapsed time, turns, decisions asked, and cost at published API prices — which the script fetches itself from Anthropic's pricing page (and the AI credit's value from GitHub's) the first time a model appears, so no row is ever "price unknown" on a connected machine — and writes **one row per model that ran in the step** into the usage table in `ProjectProgress.md`, in both editions. The exit gate is not met until the rows exist, and a row is never typed by hand. Run without `--step` for the whole project; at project close it also exports a calibration file to `~/.ocpf/calibration/` for the AI effort estimator. | "what has this cost", "how many tokens", "update the usage table" |
| `/ocpf-bc:roles` | Says once that a High thinking effort makes every task slower, then asks which models do the work (Full: Main, Light, Reasoning, each with a thinking effort; Lite: one), offering the recommended pair first, and makes it take effect by writing the project-local sub-agent copies — reasoning and light (Full), and the generator and the reviewer on the Main model (both editions) — with the chosen model and effort, then verifies the session model. The runbook runs it at the first step; run it by hand to change or repair the assignment. | "choose models", "use Opus for reasoning", "which model runs the FRD" |
| `/ocpf-bc:notifications` | Turns on "your turn" notifications: Claude app push, sound, desktop notification, or none. Records the answer in `ocpfFramework/state/notifications.json` and applies it through the tool's own settings and hooks. Nothing to install. The runbook does this at the first step; use the command on an older project or to repair. | "notify me when you're done", "alert me when it's my turn" |
| `/ocpf-bc:al-mcp-setup` | Connects the agent to Microsoft's AL tools (build, compile, symbols, diagnostics) using the AL Language extension already on the machine. Nothing installed, no PATH edits. In Copilot Chat there is nothing to do; in Claude Code and Copilot CLI it registers the bundled AL MCP Server. `start` normally does this for you. | "connect the AL tools", "why can't you compile" |
| `/ocpf-bc:copilot-blueprint` | Fires by itself whenever you ask for a Business Central Copilot feature — a *Suggest with Copilot* action, a PromptDialog page, a capability registration, Azure OpenAI — in any journey, or with no project open: fetches the OnlyBCFans BC Copilot Blueprint into a sibling folder outside the project and builds the feature from its verified procedure and templates, never from memory. | "Add a Suggest with Copilot action to the Sales Order page", "build a Copilot feature" |
| `/ocpf-bc:al-standards` | Loads the OCPF AL Development Standards Guide: naming and abbreviations, object ID allocation, API page design, field inclusion, anti-patterns, events, upgrade code, multilanguage and XLIFF rules, parent-child pages and number series. The routine applies it automatically; run it directly for an ad-hoc review. | "check this AL against OCPF standards" |
| `/ocpf-bc:dashboard` | Creates, refreshes, or opens the project's live dashboard, `ProjectDashboard.html` at the project root (tracked in git, so it persists with the project) — the Build Map page with the app's name and icon, phase and step, tokens or AI credits and cost, the agent / you time split, who is working, the exit gate, and the open question. The runbook calls it at PRE-01 / Lite Step 1 the moment `app.json` exists; it opens the page once, installs the zero-token refresh hooks, and asks the one explanation question. Reopen a closed page with right-click → **Open Externally** in VS Code's Explorer, or ask for it. |
| `/ocpf-bc:update-framework` | Checks whether a newer runbook has been published, summarises every changelog entry between your version and the latest, says whether any touches a step you have already completed, and updates the project's copy only after you choose **Update now**. Backs up the old copy first. On a project from an older layout (Full before 5.0.0.0, Lite before 5.0.0.0) it also runs the migration: moves the framework files into `ocpfFramework/`, the documents into the `docs/` phase folders, rewrites the `.gitignore` block and the tool paths, creates Lite's `ProjectProgress.md` from the old usage report, and lists every move in the ChangeLog. | "is there a newer runbook", "update the framework" |

Five sub-agents ship with the plugin: **ocpf-reasoning** (Full: FRD and TDD drafting, Sanity
Check, root-cause diagnosis, Gap-Fit, Code Review), **ocpf-light** (Full: post-generation pre-flight
checks and symbol verification), **ocpf-generator** (both editions: writes the AL files of one
batch from a narrow brief, one generator per batch in parallel, on the Main model),
**ocpf-reviewer** (both editions: the pre-review — one read of every file between the first clean
compile and the first package, on the Main model; its findings are decided in one options box and
recorded in the ChangeLog; the Code Review step still follows), and **ocpf-analyst** (the `analyze`
command's reader, on the model you choose for the analysis; writes only under
`requirements/existing/`). Each opens its report with the model it actually ran on, and the main
agent checks that line before using anything. They carry no model of their own; the `roles` skill
(and, for the analyst, the `analyze` skill) writes the project's copies with the chosen model.

---

## 6. What lands in your project

Every journey places the same framework files and differs in the documents it produces. The
project root holds only what the tools require, plus `ProjectProgress.md` and the live dashboard
pages (all tracked); everything the framework fetches or keeps lives in one folder,
`ocpfFramework/`, and every project document lives under `docs/` — in a phase folder on Full and
Lite, flat on Build-a-Feature.

```
app.json  .gitignore  CLAUDE.md  .github/  .claude/  .vscode/  .alpackages/  Translations/
src/                 all AL source; subfolders per module allowed; the app icon in src/logo/
docs/                project documents — by phase (Full, Lite; below), flat (Build-a-Feature)
requirements/        raw input you handed over, verbatim; requirements/existing/ holds an analyzed app's record
images/              the icon you brought, or the one the agent drew for you (optional)
outputAppPackage/    every built package
ProjectProgress.md   every journey: the step (or object) tracker and the usage and cost table
ProjectDashboard.html, ProjectDashboard-f1.html   the live dashboard, OnlyBCFans and F1 themes
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
| `ocpfFramework/standardsGuide/`, `ocpfFramework/opsGuide/` | The two companion guides, each with a `SNAPSHOT.json` naming the commit fetched. The Standards Guide comes from its own repository, [ajansari/ocpfBCALStandards](https://github.com/ajansari/ocpfBCALStandards), at the tag the framework pins; the prelude `README.md` beside it says which. | Never |
| `ocpfFramework/patterns/`, `ocpfFramework/scripts/` | The fetched patterns library and the AL tooling, notification, usage, and dashboard scripts with the dashboard templates. | Never |
| `ocpfFramework/state/` | Each developer's own: `usage.json` (step timestamps), `pricing.json` (prices the usage script fetched), `notifications.json`, `copilot.json` (Copilot session settings), `dashboard.json` (hooks and theme), `feature.json` (Build-a-Feature's parameters with their sources), and `previous/` (backups of the runbook made before each approved update). | Never |

Outside that folder:

| Path | What it is | In Git? |
|---|---|---|
| `CLAUDE.md` and/or `.github/copilot-instructions.md` | The runbook core: operating rules, a stub per step, the always-on disciplines. Loaded on every request. If the file already existed when you started, the runbook sits at `ocpfFramework/BC_App_Build_Routine_Agent.md` (or the Lite name) and `CLAUDE.md` holds one import line, or it is placed as `.github/instructions/ocpf-framework.instructions.md` for Copilot. | With the framework files |
| `.claude/agents/ocpf-*.md` or `.github/agents/ocpf-*.agent.md` | The project-local sub-agent copies carrying your chosen models: `ocpf-reasoning`, `ocpf-light`, `ocpf-generator`, and `ocpf-reviewer` in Full; `ocpf-generator` and `ocpf-reviewer` in Lite (both on the Main model); `ocpf-analyst` when `/ocpf-bc:analyze` ran, on the model you chose for it. | With the framework files |
| `.vscode/settings.json`, `.mcp.json` | The analyzers the framework turns on, the AL tools connection, and, with Copilot, the request limit (the approval keys go to your user settings unless you chose to share them). | Yes |
| `.alpackages/`, `*.g.xlf` | Downloaded symbols and generated translation files. | Never |
| `src/`, `Translations/*.xlf`, `outputAppPackage/`, `requirements/`, `images/`, `docs/`, `ProjectProgress.md` | Your extension, its translations, every package built, your raw input (and `requirements/existing/`, the analysis of an existing app), your icon source, and every project document. | Always |

**The `.gitignore` defaults.** The first step writes two blocks. The first is always written: the
fetched folders under `ocpfFramework/` (guides, steps, templates, patterns, scripts), `ocpfFramework/state/`,
`.claude/settings.local.json`, `.alpackages/`, and `*.g.xlf`. The second is written unless you
answer *No, track them* at the first step: the whole `ocpfFramework/` folder, the runbook copies,
and the sub-agent files, so the framework stays out of your project's remote by default. The
framework never ignores `docs/`, `requirements/`, `images/`, `outputAppPackage/`, `*.app`,
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
| `docs/4-prove/` | `GapAnalysis.md` (08), `CodeReview.md` (09), `PostDevTDD.md` (10), `Documentation.md`, `UserGuide.md`, `HumanUnitTestScript.md`, `AutomatedTestScripts.md`, `AutomatedTestGuide.md`, `Deployment.md` (11), `ReleaseTestResults.md` (12), `SandboxInstall.md` (07, §1 rewritten every build) | `Docs.md`, `TestScript.md`, `AutomatedTestGuide.md` (Step 6), `SandboxInstall.md` (Step 5) |

Lite keeps no Project Memory, and only two sub-agent files — the generator and the reviewer, both on the Main model — because one model does all the work.
There is no separate usage report in either edition; the usage table is in `ProjectProgress.md`.

**Build-a-Feature keeps `docs/` flat** — no phase folders — with six short documents written as the
work happens: `ProblemStatement.md`, `FeatureRegister.md` (the parameters with the box you answered
for each, the object register, decisions), `DataModel.md` (the schema — on disk before you are asked
to confirm a design), `Documentation.md` (what it does, how to use it, each object, how they fit,
API, permissions, limitations), `ChangeLog.md`, and `SandboxInstall.md`. When Build-a-Feature runs on
a Full or Lite project, the same files go into that project's phase folders beside its own.

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

**PowerShell is missing, or a `.ps1` helper will not run.** The notification and AL launcher
helpers run on Windows PowerShell 5.1, which every Windows machine has. PowerShell 7 (`pwsh`) is
needed by the dashboard renderer's and the usage script's `.ps1` twins (where it is absent and
Python 3 is present, the `.py` twins run instead), by the XLIFF Sync module, and is recommended, not
required, by BCQuality. The framework checks `pwsh --version` and, if it is missing, offers the install with
your approval: `winget install --id Microsoft.PowerShell --source winget` on Windows, the `.pkg`
from the PowerShell releases page on macOS, Microsoft's package repository on Ubuntu and Debian,
`sudo dnf install powershell` on RHEL and Fedora. The outcome is recorded under `tooling` in
`ocpfFramework/framework.json`.

**The agent does not upload packages — you do.** Every build ends with a "Package built:" block that
names the file and points at `docs/4-prove/SandboxInstall.md`, written with the first package: both
of Microsoft's upload routes (the Admin Center's Manage Apps, or Extension Management, which
Microsoft retires in 2027 release wave 1) step by step, and a §1 the agent rewrites after every build
with that build's file, version, and Schema Sync Mode. Tell the agent the version and environment you
installed; nothing counts as "on the sandbox" until you do. When the project has AL test codeunits,
`docs/4-prove/AutomatedTestGuide.md` does the same for the test app: which Microsoft test apps to
install once, and how to run each test one at a time on the AL Test Tool page and what to report.
If you are a developer and you *tell* the agent to publish or to run the tests, it will — a publish
only after it confirms you mean a DEV extension to a named sandbox, a test run only against a
sandbox, never production. It never offers either, and neither becomes the routine.

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
