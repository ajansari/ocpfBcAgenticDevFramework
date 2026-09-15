---
name: start
description: Start a new Microsoft Dynamics 365 Business Central AL extension project with the OnlyCopilotFans (OCPF) BC Agentic Development Framework. Guides the choice between the Full framework (14 steps) and Lite (7 steps), installs the latest runbook into the project, connects Microsoft's AL tools with nothing to install, then begins the routine. Use when the user asks to "start a Business Central project", "start a BC extension", "use the OCPF framework", "set up the agentic development framework", "kick off an AL project", or runs /ocpf-bc:start (optionally with "full" or "lite").
---

# Start an OCPF BC Agentic Development Framework project

This skill automates the framework's manual setup: download the runbook, rename it to `CLAUDE.md`
or `.github/copilot-instructions.md`, and begin. It adds three things on top:
- it helps choose Full or Lite,
- it always installs the **latest** published runbook,
- it connects the AL tools with nothing to install.

It never overwrites an existing file.

Repository: `https://github.com/ajansari/ocpfBcAgenticDevFramework` (default branch `main`).

Throughout, when you need the human to **decide** something, use the harness's selectable options
mechanism, with the recommended option first and a short reason on each: `AskUserQuestion` in
Claude Code, the `askQuestions` tool in GitHub Copilot Chat in VS Code, or `ask_user` in GitHub
Copilot CLI (its choice questions take no typed answer, so add an *I'll type it* choice where a
typed answer is possible). Ordinary progress updates are plain messages.

## Step 1: Work out where you're running

Decide which of these applies before asking anything:

- **Project mode.** You can read and write files in a local or cloud workspace, for example Claude
  Code, GitHub Copilot in VS Code, Copilot CLI, or a cloud coding session. Continue with Step 2.
- **Documents mode.** You can't write into a code project, for example Claude Chat, Claude Cowork
  without a connected project folder, or Microsoft Copilot Cowork. Skip to
  [Documents mode](#documents-mode-no-code-project) at the end.

## Step 2: Check the folder

1. Confirm the workspace root with the human if it's unclear. It should be the AL project's root:
   a folder with `app.json`, or an empty or new folder for a new extension.
2. **Already set up?** Look for `.ocpf/framework.json`, or a `CLAUDE.md`,
   `.github/copilot-instructions.md`, `BC_App_Build_Routine_Agent.md`, or
   `LITE_BC_App_Build_Routine_Agent.md` whose first lines contain `# BC App Build Routine`. If
   found, this project already follows the framework. Don't start again. Tell the human, and offer
   the `status` skill (where the project stands) or the `update-framework` skill (check for a newer
   runbook).

## Step 3: Choose the edition

Ask the human to choose, recommending based on what they've told you. If you don't know enough,
ask about scope first.

- **Lite (7 steps, 4 documents).** For roughly 5–10 AL files, one person driving it, and one AI
  model doing the work, with no separate Dev Manager, Technical Lead, and Functional Consultant
  sign-offs.
- **Full (14 steps).** Choose it the moment any Lite condition stops holding: more than ~10
  objects, multiple sign-off roles, splitting work across Main, Light, and Reasoning models (the
  plugin's `ocpf-reasoning` and `ocpf-light` sub-agents), or heading to AppSource.

Mention that nothing is lost by switching later: Lite's `DesignDoc.md` and `ChangeLog.md` carry
straight over into the full framework. A project follows one edition, never both.

If the human invoked the skill with `full` or `lite`, confirm that choice instead of asking from
scratch.

## Step 4: Choose where the runbook goes

Ask which AI tools will work on this project. Pre-select the one you're running in.

| Choice | File placed |
|---|---|
| Claude Code | `CLAUDE.md` in the project root |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Both | Both files, identical copies |

**Never overwrite.** If a target file already exists and isn't this runbook, stop and ask:

- **For `CLAUDE.md`:**
  - **Recommended:** save the runbook as `BC_App_Build_Routine_Agent.md` (or
    `LITE_BC_App_Build_Routine_Agent.md`) in the project root. Then add one line,
    `@BC_App_Build_Routine_Agent.md` (the matching filename), at the top of the existing
    `CLAUDE.md`. Claude Code imports the referenced file.
  - **Alternative:** cancel and let the human sort out the existing file.
- **For `.github/copilot-instructions.md`:**
  - **Recommended:** save the runbook as `.github/instructions/ocpf-framework.instructions.md`, with
    this frontmatter added above the runbook text so Copilot applies it to every request:
    ```
    ---
    applyTo: "**"
    ---
    ```
  - **Alternative:** cancel.

## Step 5: Get the latest runbook

**Tell the human what you're doing.** Fetch from GitHub first; the copies bundled in this plugin
are only a fallback.

1. **Fetch the chosen edition and its changelog** from the default branch:

   | Edition | Runbook | Changelog |
   |---|---|---|
   | Full | `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/BC_App_Build_Routine_Agent.md` | `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/RunbookChangelog.md` |
   | Lite | `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_BC_App_Build_Routine_Agent.md` | `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_RunbookChangeLog.md` |

   Download the files **byte for byte**, with a terminal tool such as `curl -fsSL <url> -o <file>`
   where one is available. Don't retype or summarize them. A summarizing web-fetch tool isn't
   acceptable for writing the runbook file. Download straight to the final paths from Step 6, or,
   if you download to temporary files first, move them into place and delete the temporaries.
   Leave no stray files in the project.
2. **Record the commit** the files came from. Use
   `git ls-remote https://github.com/ajansari/ocpfBcAgenticDevFramework refs/heads/main`, or
   `https://api.github.com/repos/ajansari/ocpfBcAgenticDevFramework/commits/main` (the `sha`
   field). If neither works, record `unknown`.
3. **Read the version** from the runbook's `**Version:**` line near the top.
4. **If GitHub isn't reachable**, or the download is empty or doesn't start with
   `# BC App Build Routine`:
   - use the bundled copies in this skill's `references/` folder (same filenames),
   - and **tell the human plainly**, naming the bundled version from its `**Version:**` line. For
     example: "GitHub wasn't reachable, so I used the runbook bundled with the plugin, version X.
     Once you're online, the framework will offer any newer version."

   Never proceed silently on a bundled copy.

## Step 6: Place the files

1. **Runbook:** write the runbook to the file(s) chosen in Step 4.
2. **Changelog:** write it to the project root as `RunbookChangelog.md` (Full) or
   `LITE_RunbookChangeLog.md` (Lite). The runbook expects it there.
3. **Marker:** create `.ocpf/framework.json`:
   ```json
   {
     "framework": "OCPF BC Agentic Development Framework",
     "edition": "full | lite",
     "runbookVersion": "<from the **Version:** line>",
     "source": "github | plugin-bundle",
     "repository": "https://github.com/ajansari/ocpfBcAgenticDevFramework",
     "ref": "main",
     "commitSha": "<sha or unknown>",
     "fetchedAt": "<ISO 8601 timestamp>",
     "placedAs": ["CLAUDE.md", ".github/copilot-instructions.md"],
     "changelogFile": "RunbookChangelog.md | LITE_RunbookChangeLog.md",
     "pluginVersion": "<version from this plugin's .claude-plugin/plugin.json, or unknown>",
     "declinedUpdateVersion": null,
     "alMcp": "not-checked"
   }
   ```
   The plugin manifest is two folders above this skill's own folder (`../../.claude-plugin/plugin.json`).
   This marker is what turns on the runbook's plugin-only behavior (ALL ALONG → OCPF Plugin): the
   once-per-session update check, the Standards Guide fallback, and the one-step AL tool setup.
4. **Don't touch `.gitignore` here.** The runbook asks the human about framework files at intake
   (full §1.8, Lite Step 1) and applies the answer to the runbook, its changelog, and `.ocpf/`.

## Step 7: Connect the AL tools

Follow the `al-mcp-setup` skill. It connects Microsoft's AL tools **with nothing to install**,
using the AL Language extension already on the machine:
- **In GitHub Copilot Chat,** the extension's built-in tools are already there.
- **Elsewhere,** it says what it's doing (no question — connecting the tools is the agent's job),
  then registers the extension's bundled AL MCP Server for the project.

It records the outcome in `.ocpf/framework.json` (`alMcp`). If the human postpones it, or you
skip the skill for any reason, set `"alMcp": "deferred"` yourself so the marker never stays at
`not-checked`. Never install anything or ask the human to edit `PATH` or a shell profile here
(runbook Operating Rule 6d).

## Step 8: Mention staying up to date

Once, briefly:
- Each session, the framework checks GitHub for a newer runbook and asks before applying it.
- Plugin updates depend on the tool. In Claude Code, auto-update for third-party marketplaces is
  off by default: `/plugin` → **Marketplaces** → `onlycopilotfans` → **Enable auto-update**. In
  VS Code's Copilot Chat, plugins update with extension auto-update. In Copilot CLI, run
  `copilot plugin update ocpf-bc`.

Don't change the human's editor or tool settings yourself unless they ask you to. Choosing a
notification kind at the runbook's first step counts as asking, for the settings that kind needs.

## Step 9: Begin the routine

1. **Read the placed runbook in full now.** A `CLAUDE.md` or `copilot-instructions.md` written
   mid-session may not auto-load until the next session.
2. **Follow it from the first step:** PRE-01 for Full, Step 1 for Lite. This is exactly what the
   manual "Getting started prompt" does. The runbook's first question is the human's working
   language. Right after it, the runbook asks how the human wants to be notified when it's their
   turn (ALL ALONG → Notifications), using this plugin's `notifications` skill scripts.
3. **Note the Standards Guide.** The runbook fetches it from GitHub at that first step. If GitHub
   is unreachable, it uses the copy bundled with this plugin's `al-standards` skill, as the
   runbook's ALL ALONG → OCPF Plugin section describes.

## Documents mode (no code project)

On Claude Chat, Claude Cowork, or Microsoft Copilot Cowork, the framework's BUILD and PROVE phases
aren't possible. There's no AL compiler, VS Code project, or Git. Say so plainly, then offer the
part that is:

1. **Choose the edition** (Step 3).
2. **Get the runbook text:** fetch it (Step 5) if the environment can reach GitHub, otherwise use
   the bundled copy in `references/` and name its version.
3. **Work DEFINE and DESIGN with the human, following the runbook's rules:**
   - **Full:** PRE-01 through Step 04: problem statement, gap analysis, project parameters, FRD,
     TDD, Sanity Check.
   - **Lite:** Steps 1–2: parameters and `DesignDoc.md`.
4. **Produce each document as a file** the human can save, for example to OneDrive in Copilot
   Cowork, or downloaded from Claude.
5. **Explain the hand-off.** In a VS Code AL project, run this skill again; it detects nothing is
   set up yet. Put the saved documents where the runbook expects them before continuing from the
   next step.
