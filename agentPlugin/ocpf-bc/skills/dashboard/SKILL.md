---
name: dashboard
description: Create, refresh, and open the live HTML dashboard of a Business Central project following the OCPF BC Agentic Development Framework - ProjectDashboard.html, the Build Map page that shows the app's name and icon, the phase and step the project is on, tokens or AI credits and cost so far, elapsed time split between agent and human, which models are working, the current step's exit gate, the question waiting on the human, a View Project Documents button that lists every project document by stage and opens it in a popup with its approval line and a download, a Documentation website button once the help site exists, and a Download latest .app link once the project is completed. Renders from state the framework already keeps, costs no tokens per refresh once its hooks are installed, and opens in the default browser. Use when a project reaches the point in PRE-01 / Lite Step 1 where app.json exists, when the user asks to "open the dashboard", "refresh the dashboard", "show the build map", "where is the dashboard file", or runs /ocpf-bc:dashboard, and to repair a project whose page stopped refreshing.
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
the usage script's JSON, (in Claude Code) the transcripts, and — since 6.0.0.0 (section 5) — every
file under `docs/` and `requirements/`, the sign-off lines inside them, `docs/index.html`, and `outputAppPackage/`.
**The agent never writes the HTML, never fills a number in by hand, and never writes an approval
into a document for the page's sake.** `ProjectProgress.md` stays the record; the documents stay
the record of their approvals; the page is a view of both.

## 1. First creation — in the setup batch, after the kickoff

The runbook calls this skill from PRE-01 (Lite Step 1; Build-a-Feature's setup) **in the setup
batch right after the kickoff's last box** (since 5.10.0.0 — Ops § Intake → *The kickoff boxes*),
once `app.json` has been written complete there, so the page has its name and icon to show. Before
5.10.0.0 it was created mid-intake, right after the identity box, which put a wait between two
questions. Steps 1 to 3 below run in the batch with no question; step 4's explanation question is
**the first question of the setup-done box**, which the runbook's step assembles — this skill
supplies the text.

1. **Place the scripts.** Copy `scripts/ocpf-dashboard.py` and `scripts/ocpf-dashboard.ps1`, the
   `usage` skill's `scripts/ocpf-usage.py` and `ocpf-usage.ps1` (the renderer calls it), and
   every file in `templates/` (`dashboard.html`, `dashboard-f1.html`) into the project's `ocpfFramework/scripts/` (already gitignored —
   Ops § Repository Hygiene). Byte for byte, from this plugin or from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/dashboard/<path>`
   (`main` is replaced by the environment variable `OCPF_FRAMEWORK_REF` when it is set — the
   framework's pre-release channel, Ops § Plugin; record the ref used in the marker's `ref`).
2. **Render once and open it:**
   ```
   python3 ocpfFramework/scripts/ocpf-dashboard.py --project "<root>" --open --toast "Your dashboard is live"
   pwsh   ocpfFramework/scripts/ocpf-dashboard.ps1 -Project "<root>" -Open -Toast "Your dashboard is live"   # Windows / PowerShell 7
   ```
   `--open` uses the operating system's default opener (`open`, `start`, `xdg-open`) — the page
   appears in the default browser once, now. Nothing else ever opens it unasked.
3. **Install the hooks** (section 2) with the interpreter the runner ladder found, then **prove
   them** (section 2a) — the Stop hook's exact command run once, the sidecar newer and carrying
   the app's name and the edition — so the header reads *Live* instead of *Refreshed* and the
   page shows this app, not *Untitled extension*. Prove the page is tracked:
   `git check-ignore -v ProjectDashboard.html ProjectDashboard-f1.html` must print nothing; if it prints a rule, fix
   `.gitignore` (Ops § Repository Hygiene) before going on, then `git add ProjectDashboard.html ProjectDashboard-f1.html`.
4. **Explain it, once, through the options mechanism** (Rule 6a) — as the first question of the
   setup-done box, with the notification check beside it (on request outside the kickoff, as its
   own box). One question, two options: **I understand** / *Other*
   (free text, for a question or a request). The question's text, in the working language:

   > **Your project now has a live dashboard.** I just opened it in your browser. It shows this
   > extension's name and icon, which phase and step we're on, tokens *(Copilot: AI credits)* and
   > cost so far, how the elapsed time splits between my work and yours, which models are working,
   > the current step's exit gate, and — when I'm waiting on you — the open question and where to
   > answer it. The **View Project Documents** button in the header lists every project document
   > by stage — click one to read it right there, with whether and by whom it was approved, read
   > from the document's own sign-off line, and a download; a **Documentation website** button
   > opens the help site once it is built — and once the project is completed its box offers the
   > latest package to download. It exists so you can see where the build stands at a glance without asking me, which
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
   > *(Copilot Chat in VS Code with its agent hooks off, or when no interpreter for the hooks was found on this machine:)* There are no working hooks here, so this page refreshes at every
   > step boundary rather than every turn; the header says *Refreshed* and when.
   >
   > *(Copilot Chat in VS Code, until its agent hooks are proven:)* Your VS Code may keep this page live
   > every turn through its agent hooks (a Preview feature); until they prove themselves at the first
   > step close, the page refreshes at every step boundary. I'll say which it turned out to be.

   Record the answer in `docs/0-project/ProjectMemory.md` (one line: dashboard explained, date). If
   the answer is free text, act on it before continuing.

The frontloaded identity answers and `app.json` write are the runbook's (PRE-01 / Lite Step 1); this
skill assumes `app.json` exists and renders what it finds. If it is called before `app.json` exists,
render anyway — the page says *Untitled extension* and corrects itself at the next refresh, **which
the proof in section 2a is there to guarantee**: on a real Windows project that "next refresh"
never came, because the hooks named an interpreter the machine lacked.

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
**The runner is chosen by a ladder, never assumed** (Ops § Dashboard → 3). Probe, in order, and
take the first whose version command answers: macOS and Linux `python3 --version`, then
`pwsh -NoProfile -Command $PSVersionTable.PSVersion.Major` (must answer `7`); **Windows** `pwsh`
first, then `python --version`, then `py -3 --version`, then `python3 --version` (a Microsoft
Store prompt or silence is a failure). Record the winner as `runner` in
`ocpfFramework/state/dashboard.json` (`python3` | `pwsh` | `python` | `py` | `none`) and write
every hook with it. Windows with `pwsh`: `"command": "pwsh"` (**PowerShell 7** — the twin uses
`??` and `ConvertFrom-Json -AsHashtable`, which Windows PowerShell 5.1 cannot parse),
`"args": ["-NoProfile", "-File",
"${CLAUDE_PROJECT_DIR}\\ocpfFramework\\scripts\\ocpf-dashboard.ps1", "-Project",
"${CLAUDE_PROJECT_DIR}", "-Quiet", "-Live"]`; the PreToolUse hook adds `"-WaitingJson", "-"` (a
lone `-` tells the script to read the hook's JSON from stdin) and the PostToolUse hook adds
`"-ClearWaiting"`; the unmatched PostToolUse hook adds `"-Throttle", "45"`. Windows without
`pwsh`: `"command": "python"` (or `"py"` with `"-3"` first in `args`), `"args":
["${CLAUDE_PROJECT_DIR}\\ocpfFramework\\scripts\\ocpf-dashboard.py", "--project",
"${CLAUDE_PROJECT_DIR}", "--quiet", "--live"]`, the same per-hook extras as the `sh -c` form; the
PreToolUse hook passes `"--waiting-json", "-"` so the script reads stdin itself (no `$(cat)`
without a shell). `pwsh` is not on every Windows machine and `python3` is usually not the
command there: a hook written to either without the ladder exits silently for the whole build.

`--quiet` makes every
failure silent and exit 0: a dashboard that can't render must never interrupt the agent. The
*Stop* hook re-renders after every turn; the **unmatched `PostToolUse` hook** (no `matcher`: every
tool call, including the sub-agents' own) re-renders *inside* a turn, at most once per 45 seconds
(`--throttle 45` returns at once when the page is younger than that). Without it a long turn — Main
waiting minutes on the Reasoning sub-agent — leaves the page frozen at the turn's start, which is
what happened on the first v5.2.0.0 project. Both read the transcripts for who is working and the
time split, and cost no tokens.

### 2a. Prove the hooks — before the explanation question

After the hooks are written, and again on every repair:

1. Note the sidecar's modification time: `ocpfFramework/state/dashboard-data.js`.
2. Run the **Stop hook's exact command** once from the shell — same interpreter, same arguments,
   `${CLAUDE_PROJECT_DIR}` replaced by the project root.
3. Read the sidecar again. The proof passes only when the file is newer **and** its `app.name`
   equals `app.json`'s `name` **and** its `framework.edition` equals the marker's `edition`
   (`full`, `lite`, or `feature`). *Untitled extension*, or the Full step map on a feature
   project, is a fail.
4. On a fail: run the same command without `--quiet` / `-Quiet` and read the error, step down the
   ladder, rewrite the hooks, and prove again. When nothing on the ladder runs: record
   `hooks: false` and `runner: none` in `dashboard.json`, say so in one sentence, and the
   explanation question's last paragraph says the page refreshes at every step close rather than
   every turn (the close render, section 2b).
5. On a pass: record `hooksVerified` (ISO timestamp) and `runner` in `dashboard.json`.

Why: on a real Windows Build-a-Feature project (October 2026) the hooks were written for `pwsh`
on a machine without it; `--quiet` made every run silent, and the page read *Untitled extension*
and *Full* from the first render until the journey's closing render — the only render that ever
happened. A hook is proven by running it, never by having written it.

### 2b. The close render — every tool, hooks or not

The step-close ritual (the `usage` skill, Ops § Usage & Cost → 5) ends by running the renderer
once with the recorded `runner`, on every AI tool and every journey — a step close in Full and
Lite, an `F` row's close in Build-a-Feature. Redundant while hooks work, the only refresh when they
don't (Copilot Chat with its hooks off or unproven included): the page is never more than one
close stale.

**GitHub Copilot CLI.** The same moments in `.github/hooks/ocpf-dashboard.json` (project level,
gitignored; the CLI's reference: `.github/hooks/*.json`, JSON `"version": 1`, each hook a
`command` with a `bash` and a `powershell` line and an optional `timeoutSec`) with the CLI's event
names — `agentStop`, `subagentStop` where available, and **one** `preToolUse` and **one**
`postToolUse` entry each. **Copilot's hooks have no matcher** (the reference lists
`version` / `type` / `bash` / `powershell` / `cwd` / `timeoutSec` / `env` and nothing else; VS
Code's page says its parser ignores a matcher), so every tool call reaches both entries, and
**the renderer does the matching itself**: it reads the hook input on stdin — `toolName` and
`toolArgs` — and records the question (`preToolUse`, `--waiting-json -`) or clears it
(`postToolUse`, `--clear-waiting -`; pwsh `-ClearWaiting -HookJson -`) only when `toolName` is
`ask_user` (the CLI; its `toolArgs` are `{"message", "requestedSchema": {"properties": {"<key>":
{"title", "enum": [...]}}}}` — one question, the enum its options) or `askQuestions` (Copilot
Chat; the `questions[]` shape). Any other tool is an ordinary render, and the same entry's
`--throttle 45` returns at once when the page is younger than that — so a long turn still
refreshes, and nothing renders twice per tool call. The filter reads Copilot's `toolName` only:
Claude Code's hook input carries `tool_name` (`AskUserQuestion`), which the harness has already
matched, and is never filtered. Each line runs the same script with `--quiet
--live`. The CLI's default `timeoutSec` is 30, enough for a render; the shape (`agentStop` and
`preToolUse` shown; `subagentStop` follows `agentStop`, `postToolUse` follows `preToolUse` with
`--clear-waiting -` / `-ClearWaiting -HookJson -` in place of `--waiting-json -` / `-WaitingJson -`):

```json
{
  "version": 1,
  "hooks": {
    "agentStop": [
      { "type": "command", "timeoutSec": 30, "cwd": ".",
        "bash": "python3 ocpfFramework/scripts/ocpf-dashboard.py --project . --quiet --live",
        "powershell": "pwsh -NoProfile -File ocpfFramework/scripts/ocpf-dashboard.ps1 -Project . -Quiet -Live" }
    ],
    "preToolUse": [
      { "type": "command", "timeoutSec": 30, "cwd": ".",
        "bash": "python3 ocpfFramework/scripts/ocpf-dashboard.py --project . --quiet --live --waiting-json - --throttle 45",
        "powershell": "pwsh -NoProfile -File ocpfFramework/scripts/ocpf-dashboard.ps1 -Project . -Quiet -Live -WaitingJson - -Throttle 45" }
    ]
  }
}
```

`"cwd": "."` is the repository root (the reference: relative to the repository root or absolute),
so the paths hold wherever the CLI was started. The harness picks the `bash` line on macOS and
Linux and the `powershell` line on Windows by platform; the runner ladder decides which
interpreter is written *inside* that line (a Mac without `python3` gets `pwsh -NoProfile -File
… .ps1` in its `bash` line). The explanation question's last paragraph is the conditioned one
(above, step 4).

**GitHub Copilot Chat in VS Code has agent hooks, in Preview** (VS Code's *Hooks* page, read
October 30, 2026): the same `.github/hooks/*.json` files, harness, and format as the Copilot CLI
— the harness also reads `.claude/settings.json` — and an administrator can disable them. Install
the same `.github/hooks/ocpf-dashboard.json` as for the CLI (the renderer's `toolName` check
covers Chat's `askQuestions` as it covers the CLI's `ask_user`). **The shell proof of section 2a proves the runner only — never that
VS Code fires hooks:** Preview off, or an administrator's policy, passes it every time. So on
Copilot Chat the proof has two parts. First the shell proof: record `runner`, and **`hooks:
false`**; write the hook file with `--live` anyway, and never pass `--live` on the agent's own
renders. Then the live proof, which is a read: a hook run's `--live` flips `hooks` to `true` in
`dashboard.json` by itself (the renderer does that at every `--live` run), so **at the first step
close after the install — before the close render — and at every session start, read
`dashboard.json`**: `hooks: true` means VS Code fired them — record `hooksVerified` now, the page
is live every turn; still `false` means the hooks are off or disabled — say so in one sentence
and stay on the fallback: the page refreshes **at every step boundary** — the `usage` skill's
step-close ritual runs the renderer after it writes the rows (both editions), and the Reasoning
role's measurement brief (Full) ends with the render command. Don't pass `--live` then; the header
says *Refreshed · <time> · at step close*, which is the truth. Offer the human a refresh whenever
they ask where things stand.

Record what was installed in `ocpfFramework/state/dashboard.json` (`hooks: true/false`, `theme`,
`tool`, `runner`, `hooksVerified`); the `status` skill reads it and reports hooks that were
never proven.

## 3. On request

- **Nothing to do for these** — they are on the page: tiles and the Journey panel collapse with their
  chevron (remembered per browser); the ticker has pause / resume and restart-from-newest buttons.
- **"Open the dashboard"** → render, then `--open`. Say the path.
- **"Refresh the dashboard"** → render without `--open`; say what changed if anything stands out.
- **"Where is the dashboard?"** → `ProjectDashboard.html` at the project root, and the right-click
  route. It is tracked: it shows as modified after every refresh, which is expected.
- **Theme — OnlyBCFans unless the human says "F1".** Open and name `ProjectDashboard.html`,
  always; never pass `--theme f1`, open `ProjectDashboard-f1.html`, or bring up the F1 page
  unless the human asked for it by name in this session (Ops § Dashboard → 4; the renderers
  open the OnlyBCFans page on `--open` whatever `dashboard.json` remembers). Two ship: `brand`
  (*OnlyBCFans*, the default) and `f1` (the trackside pit-wall view —
  Ferrari for Main, Mercedes / McLaren / Red Bull for the sub-agents, steps as laps, BOX BOX when a
  question waits). Both have a Day/Night switch. **Every render writes both pages** —
  `ProjectDashboard.html` and `ProjectDashboard-f1.html`, both at the root, both tracked (stage
  both) — so the human switches by opening the other one; the footer selector navigates.
  **"Use the F1 theme"** (the human's words) → run the renderer with `--theme f1 --open`
  (`-Theme f1 -Open`): it opens the F1 page on that call and records the preference in
  `ocpfFramework/state/dashboard.json` for the record. Every later open without `--theme` is the
  OnlyBCFans page again; say so. Both templates live in `ocpfFramework/scripts/`. Ops § Dashboard → 4.
- **Completed, and waiting on your test (v5.9.5.0; Ops § Dashboard → 6).** The data carries a
  `project.state`: `completed`, `testing`, `waiting`, `working`, or `idle`. **Build-a-Feature's
  *Done*** → run the renderer once more with `--close-project` (`-CloseProject`): it stamps
  `projectClosedAt` in `ocpfFramework/state/usage.json`, closes any open window there (the clocks
  stop), logs it in the feed, and renders — the page reads **Completed**, Main **finished**, every
  row closed, and the F1 page shows the chequered flag, the Ferrari on the finish line under
  confetti, and the trophy on the podium. A later object reopens the project by itself. **Full and
  Lite** close when the last step's row is `Completed` or when the usage script's `--calibrate`
  runs (it stamps the same marker). **During Step 12 / Step 7**, with no question open and Main
  idle, the page reads **Waiting on you · release testing** — derived by the page itself on its
  in-place refresh, since the last render usually happens while Main still counts as working.
  Both pages age *working* out 180 s after Main's last transcript event (`lastAt`), so a session
  that simply ended never stays green. `--close-project` is a no-op on a Full or Lite project
  (a Build-a-Feature run inside one never closes the host).
  The F1 page then shows AJ's render of the driver with the trophy and the chequered flag as the
  first panel of the right column, above the telemetry (`VICTORY_SRC` in `dashboard-f1.html`), and
  his trophy render stands on the podium in the cam (`TROPHY_SRC`, background removed); the agent
  never draws or replaces either.
- **Repair.** A project from v5.2.0.0 still has `ocpfFramework/state/dashboard.html`: render once
  (the page lands at the root), delete the old file, `git add ProjectDashboard.html`. A project
  whose hooks predate v5.3.2.0 lacks the unmatched `PostToolUse` hook: merge it (section 2) — its
  absence is why a page **freezes for a whole turn** (the step and the sub-agents only change at
  `Stop`). A page that shows the Reasoning or Light role idle while it is plainly working, or whose
  token totals lack that role's model: the renderer and the usage script are older than v5.3.2.0
  and read only the top-level session files, not `<session>/subagents/agent-*.jsonl` — refresh
  `ocpfFramework/scripts/` (`update-framework`). A page that no longer refreshes: check the hooks file still names the scripts, that
  `ocpfFramework/scripts/` still holds them (the `update-framework` skill refreshes them with the
  rest), and run the renderer once by hand to see its notes. **A page that reads *Untitled
  extension*, or shows the Full map on a feature project, while `app.json` and the marker are
  complete:** the hooks never ran — their interpreter is missing (`pwsh` on a Windows machine
  without PowerShell 7; `python3` on Windows) — so run the ladder and the proof (section 2a),
  rewrite the hooks with the runner that works, and record `runner` and `hooksVerified`. A page that opens blank: the browser
  blocked a `file://` script — none is needed for the first paint — so re-render and reopen. A
  page that paints but never updates: the renderer did not write
  `ocpfFramework/state/dashboard-data.js` (older than v5.3.5.0) — refresh `ocpfFramework/scripts/`.
  A document that will not open in the popup (*render the dashboard to read this here*) while
  `docs/` has the file: `ocpfFramework/state/docs/` is missing or stale (a renderer older than
  plugin 6.0.0 never writes it; a deleted folder is simply gone) — run the renderer once by hand,
  which recreates every sidecar; nothing else is needed, the folder is derived and ignored (section 5).

## 3b. Remediation rows

A remediation (Ops § Usage & Cost → 7) — window `07a` / `STEP-5a` with a title, and its row under
the base step in `ProjectProgress.md` — appears on the journey line after its base step as
`07a · Remediation`, in the base step's phase, with its own time, tokens, and cost and a fixed
three-line exit gate. Nothing to do here: the renderers read it from the window and the row.

## 3a. Build-a-Feature projects

On a marker with `"edition": "feature"` (Ops § Build-a-Feature) there are no steps: the renderers
build the rows from the usage windows and the feature table in `ProjectProgress.md` — one row per
object (`F01`, `F02`, …), plus `F00` intake, `FPK` package, `FRV` review — under the phases
*Intake · Build · Review · Package*, each row with its stage (*Asked → Confirmed → Built →
Compiled → Documented → Reviewed → Packaged*), object ID, time, and cost; the
estimate tile becomes *Objects built*; the exit-gate card shows the row's stage ladder; the roles
card shows Main alone. The data gains `phases` and, per row, `stage`, `kind`, `objectId`, and
`shippedIn`. First creation is the same (the `build-a-feature` skill calls this skill the moment
`app.json` exists, adding one sentence to the explanation question); hooks, the ladder, the
proof (section 2a), and the close render at every `F` row's close (section 2b) are the same. Renderers and templates older than plugin 5.5.0 show a feature project as an empty Full
map: refresh `ocpfFramework/scripts/` (`update-framework`).

## 3c. Time and cost — what the figures mean (v5.8.0.0)

- **Elapsed** is the union of every step window, from the first window's start to now (or to the
  last close) — a reopened step or a remediation open beside another step counts once. **The first
  window begins where its session began:** the renderer finds the Claude Code transcript (or the
  Copilot journaled session) whose span contains the recorded `startedAt` and moves the start back
  to that session's first event, so the clock starts with the first prompt even when the agent
  wrote `startedAt` minutes later; a note says so. Before 5.8.0.0 the clock started late and the
  tokens didn't — the two never matched.
- **Agent / You / Waiting add up to Elapsed exactly.** Waiting is the time an options box was
  open (its answer arrives as a tool result, which earlier versions counted as agent time); a
  window with no transcript event is the human's time. Ops § Usage & Cost → 8 has the table.
- **Cost** sums the usage script's rows; a model with no rate in `pricing.json` shows as *+
  unpriced* with the model named — never `$0` — and the notes say which model. The fix is the
  `usage` skill's Step 2 (fetch the publisher's prices), not a typed figure. Work outside every
  window (after the last close) is in the total and named in a note.

## 4. What the page can and cannot know

It shows only what is on disk and says so where it can't: *No estimate yet* before Step 03 / Lite
Step 2; *Agent / you split needs the Claude Code transcript* in Copilot; *as of the last journaled
checkpoint* for an open Copilot session; *none in progress* between steps. The exit-gate card is the
step file's wording — the gate is met when the agent says so in the closing message, never because
the page listed it. The page never takes an answer: the *Waiting on you* card says where to reply.
An approval shown in the documents popup is one that is already written in the document; the page
never adds, edits, or infers one.

## 5. View Project Documents, the Documentation website, and the completed box's download (6.0.0.0)

Both renderers read the following and write it into `dashboard-data.js`; the page draws it. The
agent does nothing here beyond rendering — there is no step, no question, and no file for it to
write. Ops § Dashboard has the human-facing account.

- **The button.** *View Project Documents*, in the header left of the Business Central mark, on
  the OnlyBCFans page (the F1 page is unchanged — its header has no room for it without a
  redesign). A click drops down the stages that hold a document: the `docs/` phase folders
  `0-project` … `4-prove` (Project, Define, Design, Build, Prove) first, then any other subfolder,
  then the flat files (Build-a-Feature's flat `docs/`), then `requirements/` (one level of
  subfolders, `requirements/existing/` included) — for the extensions `.md`, `.txt`, `.docx`,
  `.xlsx`, `.pdf`, `.png`, `.jpg`, `.svg`; the help site's own `index.html`, `build.py`,
  `site.json`, `template.html` and the `images/`, `assets/`, `screenshots/` folders are skipped.
  A stage opens to the documents that exist on disk; a document opens the popup. A project
  without a document yet shows the button disabled with *No documents yet*.
- **The Documentation website button**, beside it in the DESIGN phase's teal (`--b-teal`; *View
  Project Documents* stays neutral), appears once
  `docs/index.html` exists (the `html-docs` skill — Full Step 11, Lite Step 6, on request
  anywhere; the renderer's `helpSite` reads it) and opens the help site in a new tab through a
  relative link, which works on `file://`. Absent until then; nothing says when it comes.
- **The popup.** In-window, scrollable, focus-trapped, closed by *Esc*, the close button, or a
  click outside. Its header carries the title and path, the approval line — *Approved — <role>,
  <name>, <date>* or *Not yet approved* — a **Download** link to the file itself (a relative
  `download` link, which works on `file://`), and *open in a new tab*, which shows the same
  document full-page through the route `ProjectDashboard.html#doc=<slug>[&h=<heading-id>]`.
  Markdown is converted to HTML by the renderer itself (stdlib only, the whole text HTML-escaped
  first — a document is text, never passthrough HTML): headings with ids, tables, lists with
  checkboxes, fenced code (Mermaid shown as source), links — a link to another `docs/` or
  `requirements/` document opens in the same popup. **A `#doc=` slug is honoured only when the
  renderer's index holds it** — the page never builds a sidecar path from the hash or from a link
  inside a document, so a crafted `[x](#doc=../../x)` opens nothing and says so; every file path
  the page emits (sidecar, download, image, PDF, package, help site) is percent-encoded per
  segment, so a name holding `#`, `%`, `?`, or a space still loads. `.docx` and `.xlsx` are text-extracted
  (capped at 200 KB with a line saying so); `.txt` shows as is; an image shows inline; a PDF
  offers the download. A document whose sidecar is missing (a fresh clone: the sidecars are per
  machine) says *render the dashboard to read this here* and still offers the download.
- **The sidecars.** Each converted document is written once to
  `ocpfFramework/state/docs/<slug>.js` (`<slug>` is the path with every run of characters outside
  `A-Za-z0-9_-` turned into one `-`, plus the first six hex digits of the path's SHA-256 — e.g.
  `docs-2-design-FRD-md-fc5911` — so `a.b.md` and `a-b.md` never share a sidecar and the name is
  safe in a URL and on every file system; two paths that still collided would be named in
  `docs.note`), carrying `window.__ocpfDoc = {path, title, kind, html, …}`; the
  page loads it through a `<script>` tag on demand — the one load that works on `file://` in
  every browser. A sidecar is rewritten only when its source is newer or the converter version
  (`CONV` in the scripts) changed, so a render stays well under a second with forty documents;
  a sidecar whose source is gone is deleted on the next render (orphans never accumulate). The
  folder is derived, recreatable, and under the always-ignored `ocpfFramework/state/` — never
  stage it, never repair it by hand; a missing folder means *render once*.
- **The approval line.** Read from the **first twelve lines** of the document: `**Sign-off:**
  <role> — <name>, <date>` (the role optional; the header line of the FRD, TDD, Sanity Check, and
  Lite Design Doc templates) and `**Approved by:** <name>, <date>` (the Build Plan's), plus the
  rows of the Code Review's **§3 fix-batch table** (approver, date). A name or date still a
  `<placeholder>`, empty, or containing *pending* reads *Not yet approved*; anything else reads
  *Approved — role, name, date*. The line is shown for the documents that carry a sign-off (the
  FRD, TDD, Sanity Check, Build Plan, Code Review, and Lite Design Doc) and for any other document
  in which a line is found; a document nobody approves (the ChangeLog, the User Guide, a
  requirement) shows none. Read only: the page never writes a sign-off, and an approval the
  human gave in a box that no document records does not appear — the document is the record.
- **Download latest .app.** Inside the *Project completed* box only, once `outputAppPackage/`
  holds a `.app` (Ops § Packaging): the newest by the version in `<Name>_<a.b.c.d>.app` (file time
  as the fallback; a `.app` loose at the root or one folder down counts only when
  `outputAppPackage/` holds none), with version and size, as a direct `download` link that works
  on `file://`. Absent when no package exists; absent while the project is open.
- **The within-step progress bar** (the exit-gate card; the renderer's `progress`). Each gate item
  of the current step carries a verdict read from disk — ✓ a rule exists and holds, ○ it exists
  and fails, ? no rule — by the literal rules of Ops § Dashboard → 7 (*the honesty rule*); the
  label reads *n of m gate items met · k unreadable*, the bar fills by `n / m` with the percentage
  shown, never by a timer; Build-a-Feature shows the row's stage ladder (*n of 7 stages met*). A
  full bar closes nothing — the gate is met when the agent says so in the closing message (Rule 6c).
