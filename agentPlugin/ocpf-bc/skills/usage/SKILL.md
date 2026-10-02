---
name: usage
description: Measure and record what an OCPF BC Agentic Development Framework project has consumed, in the unit its AI tool bills in - in Claude Code, input, output, cache-write, and cache-read tokens per step and per model from its session transcripts; in GitHub Copilot in VS Code, AI credits per step and per model from Copilot Chat's session files - sub-agents included in both, with elapsed time, turns, decisions asked, and cost at published prices fetched from the publisher - and refresh the usage table in ProjectProgress.md (both editions; one table per tool). Runs at every step boundary as /ocpf-bc:usage --step <id>; at project close, /ocpf-bc:usage --calibrate exports the measurements for the next project's AI Effort Estimate. Use when a step starts or closes, when the user asks "what has this cost", "how many tokens", "token usage by step", "how many credits", "Copilot credits by step", "update the usage table", or runs /ocpf-bc:usage.
---

# OCPF usage and cost

**Follow `Ops § Usage & Cost` in the project's Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`).
This skill does its parts: the timestamps, the measurement, the prices, the table — at every step
boundary — and, at project close, the calibration export.

## The step boundary ritual — `/ocpf-bc:usage --step <id>`

The normal invocation is at a step boundary, with the step id (Full Operating Rule 11, Lite
Operating Rule 9; Ops § Usage & Cost → *The step boundary ritual*). Step ids are the step file
names: `PRE-01`, `PRE-02`, `01` … `12`, `STEP-1` … `STEP-7`.

- **Step start:** append `{ "step", "startedAt" }` to `ocpfFramework/state/usage.json` and set the
  step's `ProjectProgress.md` row to `In Progress` — same moment, same message.
- **Step close, before the closing message (summary, then the pasted rows, then the Rule 6c box as its last thing):** set `completedAt`, run the
  measurement (Step 3 below), and write the step's rows into the usage table. **One row per model
  that ran in the step** — the Main model and every sub-agent model — never one row for the step
  with a single model. **Paste those rows into the closing message** so the human sees them without
  opening the file.
- **The exit gate is not met until the rows exist.** The next step does not start on a missing row;
  the `status` skill reports a missing row as a blocker.
- **Never hand-write a row, in either tool.** The script reads Claude Code's transcripts or
  Copilot Chat's session files and already aggregates per (step, model); a hand-written row is how
  a real project got one model for everything.
- **In Copilot, the step close is also the checkpoint.** `--step <id>` stores the cumulative
  credits per model in `usage.json`; the step's row is the difference from the checkpoint before.
  A step closed without it can't be separated from the next one later.

Without `--step`, refresh the whole table (every step). Same wording in Full and Lite.

## Step 1: Timestamps — `ocpfFramework/state/usage.json`

- **Missing?** Create it now with `aiTool` (`claude-code`, `copilot-chat`, or `copilot-cli` — the
  tool this session is running in, which decides the source and the table), `transcriptDir`
  (Claude Code: `~/.claude/projects/<key>` where `<key>` is the project's absolute path with every
  `/` replaced by `-`; Copilot: `null`), and an empty `steps` list. In a Copilot project the script
  adds `copilot.sessionDirs` and `copilot.checkpoints` itself; never edit those by hand. Earlier steps get `n/a — no timestamps` in the table; never back-fill a guess.
- **A step is starting or closing?** Append `{ "step", "startedAt" }` or set `completedAt`, ISO 8601
  UTC, the same moment the `ProjectProgress.md` row changes (both editions).
- Per developer, always gitignored (Ops § Repository Hygiene; the whole `ocpfFramework/state/`
  folder is).

## Step 2: Prices — `ocpfFramework/state/pricing.json`

If the file is missing, or a model in the transcripts has no row: **fetch the publisher's pricing
page now** and write the rates per million tokens with the source URL and today's date —
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

Options: `--json` for machine output, `--step <id>` for one step (omit it for the whole table),
`--transcripts <dir>` to point at the transcript folder, `--pricing <path>` and `--usage <path>` to
override the defaults `ocpfFramework/state/pricing.json` and `ocpfFramework/state/usage.json`. If
the transcript folder isn't where `usage.json` says, the script exits with a message naming the
folder it tried; find it (`ls ~/.claude/projects/`) and fix `transcriptDir` rather than guessing.
If `--step` returns no rows, the window's timestamps are wrong — fix them, don't type a row. Copy
the script into the project's `ocpfFramework/scripts/` only if the human wants to run it without
the plugin; `ocpfFramework/scripts/` is gitignored.

**GitHub Copilot Chat in VS Code** — the same script, a different source and a different table
(Ops § Usage & Cost → 2). Copilot bills in **AI credits**; VS Code records them per turn and per
model, sub-agents included, in the chat session files under its workspace storage. The script
finds the project's `chatSessions` folder, rebuilds each session, splits every turn's credits
between the Main model and its sub-agent calls, stores the step's checkpoint, prices the credits
from `pricing.json`'s `aiCredit`, and prints the **credits table** — ten columns, no token columns:

```
python3 <this skill's folder>/scripts/ocpf-usage.py --project "<project root>" --step <id>
pwsh   <this skill's folder>/scripts/ocpf-usage.ps1 -Project "<project root>" -Step <id>
```

- `--tool copilot-chat` overrides `usage.json`'s `aiTool`; `--sessions <dir>` names the
  `chatSessions` folder when the script can't find it (a remote, WSL, or dev-container window
  keeps it on the machine VS Code runs on).
- **The Total must equal the Session Cost** in the chat's Session Info popover (the
  context-window control in the chat input) — summed over the project's sessions. If the human
  reports a different figure, say so and look for a deleted session or a second VS Code window.
- **If the script can't read the session files** — a VS Code release changed its storage, or the
  files aren't on this machine — ask the human to open the Session Info popover and read
  *Session Cost*, then record that one number:
  `--step <id> --session-credits <n>` (PowerShell: `-SessionCredits <n>`). The row says *read from
  the popover by the human — no model breakdown*. Tell the human the model breakdown is lost for
  that step and why.
- **Never put tokens in a Copilot row.** The per-turn token counts in the session files are the
  context-window meter, not consumption; credits are never converted to tokens.
- **No checkpoints yet** (a project that started before this version): the script attributes by
  each turn's start time and says so in a note. Keep the note in the table's footnote.

**GitHub Copilot CLI** — the script doesn't read the CLI's store. Record the credits the human
reads in the CLI with `--tool copilot-chat --step <id> --session-credits <n>`, and say so.

## Step 4: Write the table

- **Both editions:** the second table of `ProjectProgress.md`, under the step table. The columns
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
  window, every started step has rows, one row per model, rows pasted into the closing message,
  Total and footnote current.

Then stop. Don't start the next step unless the human asks.

## Project close: `/ocpf-bc:usage --calibrate`

At Full Step 12 / Lite Step 7, after the last table refresh, run the script once more with
`--calibrate` (PowerShell: `-Calibrate`). It writes `~/.ocpf/calibration/<project>-<date>.json` —
outside every project, per developer — with, per step and per model, tokens by type, elapsed time,
turns, decisions, sub-agent calls, and the object counts by type read from
`docs/1-define/ObjectRegister.md` (Full) or the object table in `docs/2-design/DesignDoc.md` (Lite),
plus the measured output-token throughput. It prints the path; put that path in the closing
message and the ChangeLog entry. The next project's AI Effort Estimate (`documents` skill, Full
Step 03 / Lite Step 2) reads every file in that folder and derives its per-object and per-step
averages from them; three or more files move the estimate's margin from ±30 % to ±10 %. A
Copilot project's file carries AI credits per step and per model (`aiCredits`, `role`) with the
token fields `null`; say so. `--calibrate` exports the whole project and refuses `--step`.
