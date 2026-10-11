---
name: dashboard
description: Create, refresh, and open the live HTML dashboard of a Business Central project following the OCPF BC Agentic Development Framework - ProjectDashboard.html, the Build Map page that shows the app's name and icon, the phase and step the project is on, tokens or AI credits and cost so far, elapsed time split between agent and human, which models are working, the current step's exit gate, and the question waiting on the human. Renders from state the framework already keeps, costs no tokens per refresh once its hooks are installed, and opens in the default browser. Use when a project reaches the point in PRE-01 / Lite Step 1 where app.json exists, when the user asks to "open the dashboard", "refresh the dashboard", "show the build map", "where is the dashboard file", or runs /ocpf-bc:dashboard, and to repair a project whose page stopped refreshing.
---

# OCPF project dashboard — the Build Map page

**Follow `Ops § Dashboard` in the project's Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`).
This skill does the mechanics: first creation, the hooks that keep the page fresh, the one-time
explanation to the human, refreshes on request, and repair.

**What it is.** One HTML file, `ProjectDashboard.html` **at the project root,
beside `ProjectProgress.md`, tracked in git** (never under `ocpfFramework/`, never ignored — Ops §
Repository Hygiene; v5.2.0.0 wrote it to the always-ignored `ocpfFramework/state/` and it did not
persist with the project), rendered by the
bundled script from files the framework already writes — `app.json`, `framework.json`,
`state/usage.json`, `ProjectProgress.md`, the step files, `pricing.json`, the sub-agent definitions,
the usage script's JSON, and (in Claude Code) the transcripts. **The agent never writes the HTML and
never fills a number in by hand.** `ProjectProgress.md` stays the record; the page is a view of it.

## 1. First creation — the moment `app.json` exists

The runbook calls this skill from PRE-01 (Lite Step 1) **right after the three frontloaded identity
answers — extension name, publisher, app icon — are written to `app.json`**. That is the first
moment the page has a name and an icon to show; earlier it would be an empty shell.

1. **Place the scripts.** Copy `scripts/ocpf-dashboard.py` and `scripts/ocpf-dashboard.ps1`, the
   `usage` skill's `scripts/ocpf-usage.py` and `ocpf-usage.ps1` (the renderer calls it), and
   `templates/dashboard.html` into the project's `ocpfFramework/scripts/` (already gitignored —
   Ops § Repository Hygiene). Byte for byte, from this plugin or from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/dashboard/<path>`.
2. **Render once and open it:**
   ```
   python3 ocpfFramework/scripts/ocpf-dashboard.py --project "<root>" --open --toast "Your dashboard is live"
   pwsh   ocpfFramework/scripts/ocpf-dashboard.ps1 -Project "<root>" -Open -Toast "Your dashboard is live"   # Windows / PowerShell 7
   ```
   `--open` uses the operating system's default opener (`open`, `start`, `xdg-open`) — the page
   appears in the default browser once, now. Nothing else ever opens it unasked.
3. **Install the hooks** (section 2) so the page refreshes by itself, then re-render with `--live`
   so the header reads *Live* instead of *Refreshed*. Prove the page is tracked:
   `git check-ignore -v ProjectDashboard.html` must print nothing; if it prints a rule, fix
   `.gitignore` (Ops § Repository Hygiene) before going on, then `git add ProjectDashboard.html`.
4. **Explain it, once, through the options mechanism** (Rule 6a) — the next thing after the page
   opens, before any other question. One question, two options: **I understand** / *Other*
   (free text, for a question or a request). The question's text, in the working language:

   > **Your project now has a live dashboard.** I just opened it in your browser. It shows this
   > extension's name and icon, which phase and step we're on, tokens *(Copilot: AI credits)* and
   > cost so far, how the elapsed time splits between my work and yours, which models are working,
   > the current step's exit gate, and — when I'm waiting on you — the open question and where to
   > answer it. It exists so you can see where the build stands at a glance without asking me, which
   > also costs nothing: the page re-renders itself from files the framework already keeps, by
   > hooks, with no model call. `ProjectProgress.md` remains the written record.
   >
   > **The file:** `ProjectDashboard.html` at the root of this project, next to
   > `ProjectProgress.md`, tracked in git like any other project file — it is your view, and it
   > travels with the project. While open it refreshes its data in place every 30 seconds — no
   > page reload — and the header shows the seconds to the next refresh.
   >
   > **If you close the tab or window:** in VS Code's Explorer, right-click the file → **Open
   > Externally** *(when that entry isn't offered, **Reveal in Finder** / **Reveal in File
   > Explorer** and double-click the file)*, or ask me to "open the dashboard" and I will.
   >
   > *(Copilot Chat in VS Code only:)* Copilot Chat has no hooks, so this page refreshes at every
   > step boundary rather than every turn; the header says *Refreshed* and when.

   Record the answer in `docs/0-project/ProjectMemory.md` (one line: dashboard explained, date). If
   the answer is free text, act on it before continuing.

The frontloaded identity answers and `app.json` write are the runbook's (PRE-01 / Lite Step 1); this
skill assumes `app.json` exists and renders what it finds. If it is called before `app.json` exists,
render anyway — the page says *Untitled extension* and corrects itself at the next refresh.

## 2. Hooks — zero-token refresh

**Claude Code.** Merge into `.claude/settings.local.json` (per developer, gitignored — the same file
the notifications skill uses; keep every existing hook):

```json
{
  "hooks": {
    "Stop":        [ { "hooks": [ { "type": "command", "command": "sh", "args": ["-c", "python3 \"${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-dashboard.py\" --project \"${CLAUDE_PROJECT_DIR}\" --quiet --live"] } ] } ],
    "SubagentStop":[ { "hooks": [ { "type": "command", "command": "sh", "args": ["-c", "python3 \"${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-dashboard.py\" --project \"${CLAUDE_PROJECT_DIR}\" --quiet --live"] } ] } ],
    "PreToolUse":  [ { "matcher": "AskUserQuestion", "hooks": [ { "type": "command", "command": "sh", "args": ["-c", "python3 \"${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-dashboard.py\" --project \"${CLAUDE_PROJECT_DIR}\" --quiet --live --waiting-json \"$(cat)\""] } ] } ],
    "PostToolUse": [
      { "matcher": "AskUserQuestion", "hooks": [ { "type": "command", "command": "sh", "args": ["-c", "python3 \"${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-dashboard.py\" --project \"${CLAUDE_PROJECT_DIR}\" --quiet --live --clear-waiting"] } ] },
      { "hooks": [ { "type": "command", "command": "sh", "args": ["-c", "python3 \"${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-dashboard.py\" --project \"${CLAUDE_PROJECT_DIR}\" --quiet --live --throttle 45"] } ] }
    ]
  }
}
```
Windows: `"command": "pwsh"` (**PowerShell 7** — the twin uses `??` and `ConvertFrom-Json
-AsHashtable`, which Windows PowerShell 5.1 cannot parse; Ops § Tooling Checks records whether
`pwsh` is on the machine, and without it Python 3 runs the `.py`), `"args": ["-NoProfile", "-File",
"${CLAUDE_PROJECT_DIR}\\ocpfFramework\\scripts\\ocpf-dashboard.ps1", "-Project",
"${CLAUDE_PROJECT_DIR}", "-Quiet", "-Live"]`; the PreToolUse hook adds `"-WaitingJson", "-"` (a
lone `-` tells the script to read the hook's JSON from stdin) and the PostToolUse hook adds
`"-ClearWaiting"`; the unmatched PostToolUse hook adds `"-Throttle", "45"`. `--quiet` makes every
failure silent and exit 0: a dashboard that can't render must never interrupt the agent. The
*Stop* hook re-renders after every turn; the **unmatched `PostToolUse` hook** (no `matcher`: every
tool call, including the sub-agents' own) re-renders *inside* a turn, at most once per 45 seconds
(`--throttle 45` returns at once when the page is younger than that). Without it a long turn — Main
waiting minutes on the Reasoning sub-agent — leaves the page frozen at the turn's start, which is
what happened on the first v5.2.0.0 project. Both read the transcripts for who is working and the
time split, and cost no tokens.

**GitHub Copilot CLI.** The same five moments in `.github/hooks/ocpf-dashboard.json` (project
level, gitignored) with the CLI's event names — `agentStop`, `subagentStop` where available,
`preToolUse` / `postToolUse` matched on `ask_user`, and an unmatched `postToolUse` with
`--throttle 45` — each a `command` hook running the same script with `--quiet --live`.

**GitHub Copilot Chat in VS Code** has no hooks. The page refreshes **at every step boundary**: the
`usage` skill's step-close ritual runs the renderer after it writes the rows (both editions), and
the Reasoning role's measurement brief (Full) ends with the render command. Don't pass `--live`;
the header then says *Refreshed · <time> · at step close*, which is the truth. Offer the human a
refresh whenever they ask where things stand.

Record what was installed in `ocpfFramework/state/dashboard.json` (`hooks: true/false`, `theme`,
`tool`); the `status` skill reads it.

## 3. On request

- **"Open the dashboard"** → render, then `--open`. Say the path.
- **"Refresh the dashboard"** → render without `--open`; say what changed if anything stands out.
- **"Where is the dashboard?"** → `ProjectDashboard.html` at the project root, and the right-click
  route. It is tracked: it shows as modified after every refresh, which is expected.
- **Theme.** One theme ships today (*OnlyBCFans*, dark by default with a Day/Night switch in the
  header). The page carries a theme selector in its footer for the themes to come; more themes are
  templates in this skill's `templates/`, chosen by `theme` in `dashboard.json`.
- **Repair.** A project from v5.2.0.0 still has `ocpfFramework/state/dashboard.html`: render once
  (the page lands at the root), delete the old file, `git add ProjectDashboard.html`. A project
  whose hooks predate v5.3.2.0 lacks the unmatched `PostToolUse` hook: merge it (section 2) — its
  absence is why a page **freezes for a whole turn** (the step and the sub-agents only change at
  `Stop`). A page that shows the Reasoning or Light role idle while it is plainly working, or whose
  token totals lack that role's model: the renderer and the usage script are older than v5.3.2.0
  and read only the top-level session files, not `<session>/subagents/agent-*.jsonl` — refresh
  `ocpfFramework/scripts/` (`update-framework`). A page that no longer refreshes: check the hooks file still names the scripts, that
  `ocpfFramework/scripts/` still holds them (the `update-framework` skill refreshes them with the
  rest), and run the renderer once by hand to see its notes. A page that opens blank: the browser
  blocked a `file://` script — none is needed for the first paint — so re-render and reopen. A
  page that paints but never updates: the renderer did not write
  `ocpfFramework/state/dashboard-data.js` (older than v5.3.5.0) — refresh `ocpfFramework/scripts/`.

## 4. What the page can and cannot know

It shows only what is on disk and says so where it can't: *No estimate yet* before Step 03 / Lite
Step 2; *Agent / you split needs the Claude Code transcript* in Copilot; *as of the last journaled
checkpoint* for an open Copilot session; *none in progress* between steps. The exit-gate card is the
step file's wording — the gate is met when the agent says so in the closing message, never because
the page listed it. The page never takes an answer: the *Waiting on you* card says where to reply.
