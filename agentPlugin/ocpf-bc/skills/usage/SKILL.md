---
name: usage
description: Measure and record what an OCPF BC Agentic Development Framework project has consumed, in the unit its AI tool bills in - in Claude Code, input, output, cache-write, and cache-read tokens per step and per model from its session transcripts; in GitHub Copilot (VS Code's chat or the CLI), AI credits per step from the Copilot SDK's session journals - sub-agents included in both, with elapsed time, turns, decisions asked, and cost at published prices fetched from the publisher - and refresh the usage table in ProjectProgress.md (both editions; one table per tool). Runs at every step boundary as /ocpf-bc:usage --step <id>; at project close, /ocpf-bc:usage --calibrate exports the measurements for the next project's AI Effort Estimate. Use when a step starts or closes, when the user asks "what has this cost", "how many tokens", "token usage by step", "how many credits", "Copilot credits by step", "update the usage table", or runs /ocpf-bc:usage.
---

# OCPF usage and cost

**Follow `Ops § Usage & Cost` in the project's Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`).
This skill does its parts: the timestamps, the measurement, the prices, the table — at every step
boundary — and, at project close, the calibration export.

## The step boundary ritual — `/ocpf-bc:usage --step <id>`

The normal invocation is at a step boundary, with the step id (Full Operating Rule 11, Lite
Operating Rule 9; Ops § Usage & Cost → *The step boundary ritual*). Step ids are the step file
names: `PRE-01`, `PRE-02`, `01` … `12`, `STEP-1` … `STEP-7` — and, on the Build-a-Feature journey
(Ops § Build-a-Feature), the feature table's row ids: `F00` intake, `F01`, `F02`, … one per object,
`FPK` package, `FRV` review — and a **remediation** (Ops § Usage & Cost → 7): the base step plus a
letter, `07a` / `STEP-5a`, with a `title`. The ritual is the same at every row's start and close;
the window may carry a `title` the dashboard shows, which this skill ignores.

- **Step start:** append `{ "step", "startedAt" }` to `ocpfFramework/state/usage.json` and set the
  step's `ProjectProgress.md` row to `In Progress` — same moment, same message. **The first window
  of a project is opened as the routine's very first act**, before the working-language question
  (PRE-01, Lite Step 1, Build-a-Feature's `F00`, the `analyze` skill's `AN0`); the script also
  moves that window's start back to the first event of the session that opened it, so the tokens
  and the clock begin together, and says so in a note (Ops § Usage & Cost → 8).
- **Step close, before the closing message (summary, then the pasted rows, then the Rule 6c box as its last thing):** set `completedAt`, run the
  measurement (Step 3 below), and write the step's rows into the usage table. **One row per model
  that ran in the step** — the Main model and every sub-agent model — never one row for the step
  with a single model. **Paste those rows into the closing message** so the human sees them without
  opening the file.
- **The exit gate is not met until the rows exist.** The next step does not start on a missing row;
  the `status` skill reports a missing row as a blocker.
- **The step close ends by refreshing the dashboard — every tool, every journey** (Ops § Usage &
  Cost → 5; Ops § Dashboard → 3). After the rows, run the renderer once with the `runner`
  recorded in `ocpfFramework/state/dashboard.json`:
  `python3 ocpfFramework/scripts/ocpf-dashboard.py --project "<root>" --quiet` (or `pwsh` with
  the `.ps1`, or `python` / `py -3` with the `.py` on Windows). In Full on Copilot Chat the
  Reasoning role's measurement brief ends with the render command (below), so nothing more is
  needed. On Build-a-Feature an `F` row's close is a step close. Hooks do the same between closes
  in Claude Code and the Copilot CLI; when they don't (a missing interpreter), this is the only
  refresh, and the page is never more than one close stale.
- **Never hand-write a row, in either tool.** The script reads Claude Code's transcripts or the
  Copilot session journals and already aggregates per step (one row per model in Claude Code, one
  row per step in Copilot); a hand-written row is how a real project got one model for everything.
- **In Copilot, never ask the human for a number.** The journal holds the credits. A run that asks
  the human to read *Session Cost* from the Session Info popover while a journal exists is a bug
  in the run, not a step of the procedure.

Without `--step`, refresh the whole table (every step). Same wording in Full and Lite.

**Who runs the measurement.** The main role — except in a **GitHub Copilot in VS Code project on
the Full edition**, where the main role delegates Step 3 to the project-local `ocpf-reasoning`
sub-agent (Operating Rule 10 in force: the §1.7 model, in the background, the report's first line
verified against §1.7). The brief is four lines: the project root, the step id, the exact script
command, and *run it as printed and once more with `--json`, then run the dashboard renderer once;
return the table, every note, and the JSON `sessions` summary verbatim*. The main role then does Step 4 with what came back; a
report without the table, or with a row the script did not print, is rejected and rerun. Why: on
a real Copilot project the Main model skipped the script and asked the human for the popover
figure at every step; the measurement is a procedure with no judgment in it, which the Reasoning
role follows exactly, for a handful of requests' worth of credits. Claude Code, the Copilot CLI,
and Lite keep the main role running the script itself.

## Step 1: Timestamps — `ocpfFramework/state/usage.json`

- **Missing?** Create it now with `aiTool` (`claude-code`, `copilot-chat`, or `copilot-cli` — the
  tool this session is running in, which decides the source and the table), `transcriptDir`
  (Claude Code: `~/.claude/projects/<key>` — the session files `*.jsonl` **and** each session's sub-agent files `<id>/subagents/agent-*.jsonl`, which carry the Reasoning, Light, and Generator roles' usage — where `<key>` is the project's absolute path with every
  `/` replaced by `-`; Copilot: `null`), and an empty `steps` list. In a Copilot project the script
  adds `copilot.journalDirs` itself (and, on a pre-SDK chat, `copilot.sessionDirs` and
  `copilot.checkpoints`); never edit those by hand. Earlier steps get `n/a — no timestamps` in the table; never back-fill a guess.
- **A step is starting or closing?** Append `{ "step", "startedAt" }` or set `completedAt`, ISO 8601
  UTC, the same moment the `ProjectProgress.md` row changes (both editions).
- Per developer, always gitignored (Ops § Repository Hygiene; the whole `ocpfFramework/state/`
  folder is).

## Step 2: Prices — `ocpfFramework/state/pricing.json`

**The script fetches the prices itself (v5.8.0.0).** At every measurement, a Claude model with no
row in `pricing.json` is looked up on Anthropic's pricing page and written in with the source and
the date; a Copilot project with no `aiCredit` gets the credit's USD value from GitHub's page; the
printed notes say what was fetched, and a failed fetch is retried after an hour at most (Ops §
Usage & Cost → 3). Why: on a real project nobody wrote `pricing.json` until after the last window
closed, so every row of the build said *price unknown* and the dashboard read `$0` for Claude
Sonnet 5.5. **You step in only when the notes say the script could not:** the machine is offline
(fetch when online), the model is not on the page, or the publisher is one the script doesn't
cover — then **fetch the publisher's pricing page yourself** and write the rates per million
tokens with the source URL and today's date —
Anthropic `https://platform.claude.com/docs/en/about-claude/pricing`; Ollama cloud models
`https://ollama.com/pricing` (local Ollama models: `0`). **GitHub Copilot: the value of one AI
credit**, from `https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing`,
written as `"aiCredit": { "usd": <value>, "source": "<that URL>" }` — the usage table needs
nothing else from that page, because VS Code has already applied the per-model rates. Never type a
price from memory, and never hardcode one in this skill. Tell the human the prices are
published-rate equivalents even on a subscription or inside a plan's included credits.

## Step 3: Measure

**Claude Code** — run the bundled script; it reads the transcripts, dedupes by `requestId`, includes
sub-agent sidechains, attributes by timestamp to the `usage.json` windows, prices each row, and
prints the table in Markdown, one row per (step, model):

```
python3 <this skill's folder>/scripts/ocpf-usage.py --project "<project root>" --step <id>
pwsh   <this skill's folder>/scripts/ocpf-usage.ps1 -Project "<project root>" -Step <id>   # PowerShell 7+, untested on Windows
```

The same command measures a Copilot project — the script reads `aiTool` from `usage.json`.

The `analyze` skill's run on an existing app is the window `AN0` (Ops § Existing Apps); it is
measured like any step and its rows go in `ProjectProgress.md` when the project has one, else
under `## Usage` in `requirements/existing/README.md`.

Options: `--json` for machine output, `--step <id>` for one step (omit it for the whole table),
`--transcripts <dir>` to point at the transcript folder, `--pricing <path>` and `--usage <path>` to
override the defaults `ocpfFramework/state/pricing.json` and `ocpfFramework/state/usage.json`. If
the transcript folder isn't where `usage.json` says, the script exits with a message naming the
folder it tried; find it (`ls ~/.claude/projects/`) and fix `transcriptDir` rather than guessing.
If `--step` returns no rows, the window's timestamps are wrong — fix them, don't type a row. Copy
the script into the project's `ocpfFramework/scripts/` only if the human wants to run it without
the plugin; `ocpfFramework/scripts/` is gitignored.

**GitHub Copilot — VS Code's chat and the Copilot CLI** — the same script, a different source and
a different table (Ops § Usage & Cost → 2). Copilot bills in **AI credits**, and the Copilot SDK —
the engine under VS Code's agent mode since VS Code 1.139 and under the CLI — journals every
session at `~/.copilot/session-state/<id>/events.jsonl` (`%USERPROFILE%\.copilot\session-state`
on Windows): the project folder in `session.start`, the cumulative credits (`totalNanoAiu`,
1e9 to the credit) in `session.usage_checkpoint` and `session.shutdown`, every model request with
its timestamp. The script finds the project's sessions by folder, takes each session's last
journaled figure, splits it across the step windows by request share between the journaled
points, prices the credits from `pricing.json`'s `aiCredit`, and prints the **credits table** —
ten columns, no token columns, **one row per step** with every model named:

```
python3 <this skill's folder>/scripts/ocpf-usage.py --project "<project root>" --step <id>
pwsh   <this skill's folder>/scripts/ocpf-usage.ps1 -Project "<project root>" -Step <id>
```

- `--tool copilot-chat` or `--tool copilot-cli` overrides `usage.json`'s `aiTool` (the source is
  the same journal); `--journal <dir>` names the session-state folder when it is on another machine
  (a remote, WSL, or dev-container window keeps it there).
- **A checkpoint is written when the chat ends, not per turn.** So a step closed mid-chat gets its
  share by request count, and the figure settles at the next measurement after the chat ends. Say
  *as of the last checkpoint* in the closing message when the script notes an open session, and
  **re-run the measurement without `--step` at the next boundary** so earlier rows refresh.
- **The Total is the sum of the sessions' journaled figures**, equal to what the Session Info
  popovers showed once every session has ended. `--reconcile` adds the account's month-to-date AI
  credits from GitHub's billing API as a cross-check (needs `gh auth refresh -s user` once); it
  bounds the total, it never fills a row.
- **If the script finds no journal** for this folder, the session ran elsewhere: find its
  session-state folder and pass `--journal`. Only when no journal exists anywhere — never because
  reading one is inconvenient — does `--session-credits <n>` record a popover figure, and the row
  says so.
- **Never put tokens in a Copilot row.** The journal's token counts are per session, not per step,
  and the context meter is not consumption; credits are never converted to tokens.
- **A project that began on the pre-SDK chat** (VS Code before 1.139) also has
  `workspaceStorage/<hash>/chatSessions/*.jsonl` files with per-turn credits; the script reads
  those too, with the checkpoints they need, and the table carries both.

## Step 4: Write the table

- **Every journey:** the second table of `ProjectProgress.md`, under the step table (under the
  feature table on a Build-a-Feature project, or under both on a Full or Lite project the journey
  ran on — the `F` rows sit beside the step rows in the one usage table). The columns
  are fixed by the template (`ocpfFramework/documentTemplates/ProjectProgress.md`), **one set per
  AI tool: keep the table that matches `aiTool` and delete the other** — *Claude Code — tokens by
  type* (thirteen columns) or *GitHub Copilot — AI credits* (ten). A project that changed tools
  midway keeps both, each with the steps worked in that tool. Replace the whole table each time. (A Lite project started before Lite v5.0.0.0 kept the table in
  `docs/UsageReport.md`; the `update-framework` skill's migration moves it.)
- Fill *Senior AL dev est. (h)* from `docs/2-design/HumanEffortEstimate.md` once it exists — its
  rows carry the framework step each belongs to. The measured rows sit next to
  `docs/2-design/AiEffortEstimate.md`'s predicted ones; a step outside its ±30 % margin is worth a
  sentence in the closing message.
- Footnote: the pricing source URL and the date read. Lines outside every step window are reported
  as an *Unattributed* row, never dropped.
- Say in one line what changed since the last refresh, and what couldn't be measured and why.
- Work the template's *Before calling a refresh done* checklist: `In Progress` row matches the open
  window, every started step has rows, one row per model (Claude Code) or per step (Copilot), rows
  pasted into the closing message, Total and footnote current.

Then stop. Don't start the next step unless the human asks.

## Project close: `/ocpf-bc:usage --calibrate`

At Full Step 12 / Lite Step 7, after the last table refresh, run the script once more with
`--calibrate` (PowerShell: `-Calibrate`). It writes `~/.ocpf/calibration/<project>-<date>.json` —
outside every project, per developer — with, per step and per model, tokens by type, elapsed time,
turns, decisions, sub-agent calls, and the object counts by type read from
`docs/1-define/ObjectRegister.md` (Full) or the object table in `docs/2-design/DesignDoc.md` (Lite),
plus the measured output-token throughput. It prints the path; put that path in the closing
message and the ChangeLog entry. The export also stamps `projectClosedAt` in `usage.json` and
closes any window still open, so the dashboard reads *Completed* and its clocks stop (Ops §
Dashboard → 6) — not while a Full or Lite step is still `In Progress` in `ProjectProgress.md`:
then the script leaves the marker alone and prints a `*Note: projectClosedAt not stamped …*`
line after the path, so a mid-project export never reads as the close. Relay any such line to
the human; the path alone means the close happened. The next project's AI Effort Estimate (`documents` skill, Full
Step 03 / Lite Step 2) reads every file in that folder and derives its per-object and per-step
averages from them; three or more files move the estimate's margin from ±30 % to ±10 %. A
Copilot project's file carries AI credits per step (`aiCredits`, `role`) with the token fields
`null`; say so. `--calibrate` exports the whole project and refuses `--step`.
