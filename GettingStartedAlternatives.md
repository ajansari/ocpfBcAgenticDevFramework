# Getting Started — Alternative Ways

**Written for anyone who can't use, or doesn't want, the Visual Studio Code setup extension.** The
preferred path is in the [README](README.md#setup-plugin): install the
**OnlyCopilotFans Business Central Agentic Dev Framework - Setup** extension from the
[Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=ajansari.ocpf-bc-dev-setup)
(or [Open VSX](https://open-vsx.org/extension/ajansari/ocpf-bc-dev-setup)), then run
`/ocpf-bc:start`. Come here when:

- the extension doesn't work on your machine, or you can't install extensions at all;
- you work in the **Claude Code CLI** or the **GitHub Copilot CLI** rather than in Visual Studio Code;
- you run the agent somewhere else — github.com or the Claude apps;
- you'd rather not use the plugin and want to set the framework up **by hand**.

**Build-a-Feature** — the quick-customization journey (minutes, no steps, six short documents written as the work happens) — has no
runbook to copy: it lives in the plugin's `build-a-feature` skill and is reached through
`/ocpf-bc:start`. Without the plugin, follow *Ops § Build-a-Feature* in the Operations Guide with
the skill's reference files from `agentPlugin/ocpf-bc/skills/build-a-feature/references/` in this
repository. The same goes for `/ocpf-bc:analyze` (an existing app's documentation, *Ops § Existing
Apps*) and `/ocpf-bc:app-icon` (*Ops § Intake → The app icon*): plugin skills, with their procedure
written down in the Operations Guide for anyone working by hand.

Whichever way you install, **Step 2 is the same**: open your AL project folder and run
`/ocpf-bc:start` (or ask *"Start a Business Central project with the OCPF framework."*). The
README's [Step 2](README.md#setup-plugin) describes what happens next.

## Table of Contents

- [A. Install the agent plugin another way](#plugin)
- [B. Full Framework, by hand](#setup-full)
- [C. Lite Edition, by hand](#lite-edition)

<a id="plugin"></a>
## A. Install the agent plugin another way

**You only need ONE of these.** Each row installs the same `ocpf-bc` plugin the extension installs;
only the wiring differs.

| Your tool | How to install |
|---|---|
| ⭐ **Claude Code in VS Code** | **One-click shortcut:** paste this into your browser and it does the whole thing at once —<pre lang="text"><code>vscode://anthropic.claude-code/install-plugin?plugin=ocpf-bc&amp;marketplace=ajansari/ocpfBcAgenticDevFramework</code></pre>**OR** you can go to `/plugins` → **Marketplaces** → add `ajansari/ocpfBcAgenticDevFramework` → **Plugins** tab → **ocpf-bc** → **Install** (choose **User** scope) |
| ⭐ **GitHub Copilot Chat in VS Code** | **1.** Add the marketplace to your VS Code settings (JSON):<pre lang="json"><code>"chat.plugins.marketplaces": ["ajansari/ocpfBcAgenticDevFramework"]</code></pre>**2.** Extensions view → search `@agentPlugins` → **ocpf-bc** → **Install**.<br><br>Don't see agent plugins at all? Check that `chat.plugins.enabled` is turned on. |
| **Claude Code CLI** | `/plugin marketplace add ajansari/ocpfBcAgenticDevFramework`<br>`/plugin install ocpf-bc@onlycopilotfans` |
| **GitHub Copilot CLI** | `copilot plugin marketplace add ajansari/ocpfBcAgenticDevFramework`<br>`copilot plugin install ocpf-bc@onlycopilotfans` |
| Anywhere else | See **Other places you can run it**, below |

> **Good to know:** plugins installed in the Claude Code CLI and the VS Code extension are shared,
> and also show up in the Claude Desktop app's **Code** tab. VS Code picks up plugins installed by
> Copilot CLI automatically. So installing once usually covers your whole setup.

<details>
<summary><b>Other places you can run it</b> — github.com and the Claude apps</summary>

<br>

**GitHub.com (Copilot cloud agent)** — *not yet fully vetted.* In your **AL project's** repository,
commit `.github/copilot/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "onlycopilotfans": { "source": { "source": "github", "repo": "ajansari/ocpfBcAgenticDevFramework" } }
  },
  "enabledPlugins": { "ocpf-bc@onlycopilotfans": true }
}
```

| Thing to know | Detail |
|---|---|
| **Autonomous work** | The cloud agent works on its own toward a pull request. Use it for well-defined tasks against an approved design ("implement batch B3 per the TDD"), not the whole step-by-step routine with its approval gates. |
| **Network access** | Add `learn.microsoft.com` to the repository's Copilot **Internet access** allowlist. It isn't on the default list. |
| **Code review** | Optional **OCPF Code Reviewer** agent — copy [`agentPlugin/github/agents/ocpf-code-reviewer.agent.md`](agentPlugin/github/agents/ocpf-code-reviewer.agent.md) into your project's `.github/agents/` folder. It reviews your extension against the Standards Guide and writes `docs/4-prove/CodeReview.md`. |

**Claude apps (Chat and Cowork — web, desktop, mobile)** — *not yet fully vetted.* In Claude:
**Customize** → **Plugins** → **+** → **Add marketplace** → **Add from a repository**, enter
`ajansari/ocpfBcAgenticDevFramework`, then install **ocpf-bc**. There's no AL compiler or VS Code
project here, so it guides **DEFINE and DESIGN** and produces the documents; BUILD and PROVE
continue in VS Code.

</details>

Then go to the README's [Step 2 — Start a project](README.md#setup-plugin).

<a id="setup-full"></a>
## B. Full Framework, by hand

| Full framework file | Purpose |
|---|---|
| `fullVersion/Outline_OCPFBCAgenticDevFW.md` | A raw outline of the framework's Stages and Steps. Start here for a high-level understanding of how the framework is organized. |
| `fullVersion/BC_App_Build_Routine_Agent.md` | The agent instructions file to drop into any new AL project in Visual Studio Code — the **core**: operating rules, a stub per step, and the always-on disciplines. Review and adapt it as needed, then kick off the process with the prompt below. |
| `fullVersion/steps/` | One file per step (`PRE-01.md` … `12.md`). You don't copy these: the runbook fetches them into your project's `ocpfFramework/runbookSteps/` at its first step, with the guides and the document templates, so every session carries only the step it's on. |

### Setup by Tooling

Choose the setup that matches your development environment. Both paths use the same source file — only the filename and location change so each tool knows where to look for it.

**Claude Code plugin (Visual Studio Code)**
1. Copy `fullVersion/BC_App_Build_Routine_Agent.md` into your project's root folder.
2. Rename the copy to `CLAUDE.md`.
3. Open the project in VS Code with the Claude Code plugin active — it will automatically load `CLAUDE.md` as project instructions.

**GitHub Copilot Chat (Visual Studio Code)**
1. Create a `.github` subfolder in your project's root folder, if one doesn't already exist.
2. Copy `fullVersion/BC_App_Build_Routine_Agent.md` into that `.github` subfolder.
3. Rename the copy to `copilot-instructions.md`.
4. Copilot Chat will automatically pick up `copilot-instructions.md` for the workspace.

**Getting started prompt:**
> This AL project will follow the Agentic Development Framework outlined in `BC_App_Build_Routine_Agent.md` (may also be referred to as `CLAUDE.md` or `.github/copilot-instructions.md`). The project layout — `src/`, `docs/` by phase, and one `ocpfFramework/` folder for everything the framework fetches or keeps — is in the runbook. Please review this file and let's get started.

> 💡 **Don't copy the companion guides by hand.** PRE-01 — the very first step of the routine — fetches both from this repository into `ocpfFramework/standardsGuide/` and `ocpfFramework/opsGuide/` in your project, with the step files, templates, patterns, and scripts beside them, and places its changelog in `ocpfFramework/`. The fetched folders are gitignored, so they stay out of your project's remote.

> ⚠️ **One edition per project.** A project follows either the full framework or Lite — not both at once. If this project is an update to an existing app, or a new app without a large footprint, [Lite](#lite-edition) covers the same ground in 7 steps and 4 documents on one model; Full is for a complete app or solution built end to end.

<a id="lite-edition"></a>
## C. Lite Edition, by hand — for updating an existing app, or a new app without a large footprint

Not every extension needs the full 14-step routine. **Lite Edition** covers the same ground in **7 steps** and **4 documents**, on one model, for work that needs to move fast without giving up the discipline that keeps AI-generated AL correct.

**Use Lite when:**

- You are **updating an existing app**, or building a **new app without a large footprint**.
- **One AI model** doing all the work, in fewer steps, with leaner documents (a Design Doc, Docs, a Test Script), is the right trade: still a reliable agentic engineering process with quality outcomes — faster, cheaper, and with less detail than Full. Builds take one to two hours depending on complexity.

**Use the full framework when** the work is a **complete app or solution built end to end, or a major overhaul of a big existing app** — it needs the detailed requirements review, the FRD, TDD, and Sanity Check, full documentation, testing guides, and automated test scripts, on three models (Main / Reasoning / Light) for the highest-quality outcome, at least three to four hours end to end — or when the extension is heading to AppSource. **Use Build-a-Feature** (through `/ocpf-bc:start`, plugin only) for a quick, tactical customization in minutes: it is not vibe-coding, but it is lean on documentation and builds what you ask for rather than a holistic solution.

**What Lite trims — and what it doesn't.** Lite reduces *process*, never the AL rules: it merges the FRD, TDD and Sanity Check into a single `docs/2-design/DesignDoc.md`, folds the Testing Feedback Log and Roadmap into `docs/0-project/ChangeLog.md`, and drops the multi-model role split (it still asks which one model, at what thinking effort, does the work). It keeps the same `ProjectProgress.md` as Full, so a Lite project is tracked and measured the same way. Both editions fetch and apply the **same** OCPF AL Development Standards Guide — the same rules apply to a 5-file extension as to a 50-file one. Nothing is lost by switching later: `DesignDoc.md` maps directly onto the full framework's TDD, and `ChangeLog.md` carries straight over.

| Lite file | Purpose |
|---|---|
| `liteVersion/LITE_Outline_OCPFBCAgenticDevFW.md` | A one-page map of the Lite routine. Start here. |
| `liteVersion/LITE_BC_App_Build_Routine_Agent.md` | The Lite agent instructions file to drop into your AL project — the core; its seven step files in `liteVersion/steps/` are fetched into `ocpfFramework/runbookSteps/` at Step 1. |

### Lite Setup by Tooling

Same pattern as the full framework — only the source file changes.

**Claude Code plugin (Visual Studio Code)**
1. Copy `liteVersion/LITE_BC_App_Build_Routine_Agent.md` into your project's root folder.
2. Rename the copy to `CLAUDE.md`.
3. Open the project in VS Code with the Claude Code plugin active — it will automatically load `CLAUDE.md` as project instructions.

**GitHub Copilot Chat (Visual Studio Code)**
1. Create a `.github` subfolder in your project's root folder, if one doesn't already exist.
2. Copy `liteVersion/LITE_BC_App_Build_Routine_Agent.md` into that `.github` subfolder.
3. Rename the copy to `copilot-instructions.md`.
4. Copilot Chat will automatically pick up `copilot-instructions.md` for the workspace.

**Getting started prompt (Lite):**
> This AL project will follow the Lite Agentic Development Framework outlined in `LITE_BC_App_Build_Routine_Agent.md` (may also be referred to as `CLAUDE.md` or `.github/copilot-instructions.md`). The project layout — `src/`, `docs/` by phase, and one `ocpfFramework/` folder for everything the framework fetches or keeps — is in the runbook. Please review this file and let's get started.

> 💡 **Don't copy the companion guides by hand.** Step 1 — the very first step of the Lite routine — fetches both from this repository into `ocpfFramework/standardsGuide/` and `ocpfFramework/opsGuide/` in your project, with the step files, templates, patterns, and scripts beside them, and places its changelog in `ocpfFramework/`. The fetched folders are gitignored, so they stay out of your project's remote.

> ⚠️ **One edition per project.** A project follows either the full framework or Lite — not both at once. If a Lite project outgrows Lite mid-flight, swap in the full runbook in place of the Lite one; your `DesignDoc.md` and `ChangeLog.md` carry straight over.
