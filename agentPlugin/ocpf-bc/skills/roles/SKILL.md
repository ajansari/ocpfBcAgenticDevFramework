---
name: roles
description: Ask which AI models do the work on a Business Central project following the OCPF BC Agentic Development Framework, and make the answer take effect. Full framework - six questions (Main, Light, and Reasoning model, each with a thinking effort); Lite - two (Main model and effort). Writes project-local copies of this plugin's ocpf-reasoning, ocpf-light, and ocpf-generator sub-agents with the chosen models and efforts (the generator inherits Main; Lite writes the generator only), records the assignment, and verifies the session model. Use when the runbook reaches the model questions at PRE-01 / Step 1, when the user asks to "choose models", "set the reasoning model", "which model runs the FRD", "use Opus for reasoning", or runs /ocpf-bc:roles, and to repair a project whose sub-agents were running on the wrong model.
---

# OCPF model and effort assignment

The runbook asks which models do the work at its first step, right after notifications (Full
PRE-01, Lite Step 1). This skill does that step, and makes the answer *take effect*, which is the
part that failed on a real project: the human chose Sonnet / Haiku / Opus, the sheet said so, and
every delegated task still ran on the session's model because nothing carried the choice into the
sub-agent definitions or the delegating calls.

**Follow `Ops § Roles` in the project's Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`) —
it's the version this project follows. If the project has no `ocpfFramework/opsGuide/` yet, use this plugin's
bundled copy in the `start` skill's `references/ocpfOperationsGuide.md`. The runbook's Operating
Rule 10 (Full) is the rule this skill implements.

## Step 1: Say what's running

State, in the question's own text, the model this session is running on (your system prompt names
it) and, in Claude Code, the session's effort if you know it. The **Main model is this session**:
only the human can change it — `/model <sonnet|opus|haiku>` and `/effort <low|medium|high>` in
Claude Code (VS Code extension and CLI alike), the model picker in Copilot Chat, `/model` in Copilot
CLI. You have no tool that switches it.

## Step 2: Ask, through the options mechanism

**Say this once, before the questions, in both editions:** *"A High thinking effort makes every
task slower: the model thinks longer before each answer, and a step can take noticeably more time.
The framework recommends High only where judgment matters most."*

Recommended answer first on every question, free-text entry always available. The recommendation
depends on the edition and the tool:

| Edition · tool | Main | Light | Reasoning |
|---|---|---|---|
| Full · Claude Code | **Sonnet, Medium** | **Haiku, Medium** | **Opus, High** |
| Full · GitHub Copilot | **Gemini 3.8 Flash, Medium** | **Auto, Balanced** | **Claude Opus 5.5, High** |
| Lite · Claude Code | **Sonnet, Medium** | — | — |
| Lite · GitHub Copilot | **Gemini 3.8 Flash, Medium** | — | — |

The **Generator role** (the `ocpf-generator` sub-agent, one per batch at Full Step 06 / Lite Step 4)
runs on the Main model and effort. It has no question of its own; say so in the Main question's
text. The Copilot names are the picker's names on September 27, 2026; if a name isn't in the
picker on the day, offer the nearest and say so.

**Full — six questions (Claude Code names shown; Copilot uses its picker's names):**

| # | Question | Options |
|---|---|---|
| 1 | Main model? (also runs the generator sub-agents) | *Sonnet (recommended)* / *Opus* / *Haiku* |
| 2 | Main thinking effort? | *Medium (recommended)* / *High* / *Low* |
| 3 | Light model? | *Haiku (recommended)* / *Sonnet* / *Opus* |
| 4 | Light thinking effort? | *Medium (recommended)* / *High* / *Low* |
| 5 | Reasoning model? | *Opus (recommended)* / *Sonnet* / *Haiku* |
| 6 | Reasoning thinking effort? | *High (recommended)* / *Medium* / *Low* |

- **Claude Code (VS Code or CLI):** `AskUserQuestion` takes four questions per box — ask 1–4, then
  5–6, back to back.
- **GitHub Copilot Chat in VS Code:** `askQuestions`, all six in one carousel. Offer the models by
  the names the model picker shows (for example *Gemini 3.8 Flash*, *Auto*, *Claude Opus 5.5*),
  because that string is what a `.agent.md` file's `model:` takes. *Balanced* is the picker's word
  for a medium effort.
- **GitHub Copilot CLI:** `ask_user`, one question at a time in this order, with *I'll type it* on
  each.
- **No sub-agents in this harness** (Claude Chat, Cowork, the github.com cloud agent): ask 1–2 only,
  say the Light, Reasoning, and Generator roles can't run here, and record `N/A — no sub-agents in
  this harness`.

**Lite — two questions, one box:** Main model (*Sonnet (recommended)* / *Opus* / *Haiku*) and Main
thinking effort (*Medium (recommended)* / *High* / *Low*). Lite continues with Step 3 for the
generator only, then Step 4.

If the Main answer differs from what the session is running, ask the human to switch now and
confirm the session shows the new model before you continue. Never record a Main model that isn't
the one doing the work.

## Step 3: Write the project-local sub-agent definitions

This plugin's bundled `ocpf-reasoning`, `ocpf-light`, and `ocpf-generator` carry **no `model:`** —
the same file is read by Claude Code (which wants an alias like `opus`) and by Copilot (which wants
a picker name) — so a delegation to them inherits the session's model. The project supplies the
model through its own copies. The templates are in this plugin's `agents/` folder, two folders
above this skill's own folder (`../../agents/ocpf-reasoning.agent.md`, `../../agents/ocpf-light.agent.md`,
`../../agents/ocpf-generator.agent.md`); if you can't read them, fetch the same files from
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/agents/`.

**Which definitions:** Full writes all three. Lite writes `ocpf-generator` only — Lite has no
Light or Reasoning role, but it generates its batches with the same generator sub-agent (one per
batch, in parallel when there are two). The generator's model and effort are the **Main** answers.

Write, for every harness the project uses (the same choice the runbook placement was made for —
`ocpfFramework/framework.json` → `placedAs`; `CLAUDE.md` means Claude Code, `.github/…` means Copilot):

- **Claude Code — `.claude/agents/ocpf-reasoning.md`, `.claude/agents/ocpf-light.md`, and
  `.claude/agents/ocpf-generator.md`.** The bundled body unchanged; frontmatter keeps `name:`,
  `description:`, and — on the reasoning and light definitions — `disallowedTools:` (the generator
  has none: it must Write), and gains two lines:
  ```yaml
  model: opus          # the recorded alias: sonnet | opus | haiku, or a full model ID
  effort: high         # the recorded effort: low | medium | high (Claude Code also accepts xhigh and max; the framework offers three)
  ```
  `effort:` on the definition is the **only** place a sub-agent's effort can be set — Claude Code
  has no per-call effort override.
- **GitHub Copilot — `.github/agents/ocpf-reasoning.agent.md`, `.github/agents/ocpf-light.agent.md`,
  and `.github/agents/ocpf-generator.agent.md`** (VS Code and Copilot CLI both read this folder;
  `model:` is documented for the IDE surfaces — in Copilot CLI it may be ignored, so there the
  `Model:` first-line check is the only guarantee, and you tell the human those roles may run on
  the CLI's session model). Same body; frontmatter gains
  ```yaml
  model: 'Claude Opus 5.5'   # the picker name, or an array of names in preference order
  reasoningEffort: high      # low | medium | high — Balanced in the picker is medium
  ```
  `reasoningEffort:` is honoured where the surface supports it (VS Code's agent files do; Copilot
  CLI has wanted `reasoning-effort` — Ops § Roles keeps that note). Where it isn't supported the
  effort is the session's: say so, and record the effort as `session` for that role.

Never overwrite a file that already exists and isn't one of these three (compare the `name:` line);
stop and ask. Tell the human which files were written.

**Run every delegation in the background** (Ops § Roles → *Enforcement*). None of the three roles
asks the human, so the background tool set costs nothing, and background is what makes parallel
batches and the overlapping pre-flight possible: one generator per batch at once, the light pass
on each batch as its generator returns. Foreground only when the very next action needs the result
and nothing else can proceed (an FRD draft). Tell the human once that, in Claude Code, permission
prompts from a background sub-agent still surface in the main session.

**Claude Code loads a new `.claude/agents/` folder only at the next session start.** It watches the
folder for changes, but only if the folder existed when the session began — so in the session that
creates it, the project-local agents may not be available yet. Check: if the Agent tool doesn't
know `ocpf-reasoning` (or, in Lite, `ocpf-generator`) as a `subagent_type`, then **for the rest of
this session** delegate to the plugin's `ocpf-bc:ocpf-reasoning` / `ocpf-bc:ocpf-light` /
`ocpf-bc:ocpf-generator` with the recorded alias in the Agent tool's `model` parameter on every call
(the per-call parameter overrides everything, so the model is still right), tell the human that the
effort for those roles will be the session's until the next session, and record that in
`docs/0-project/ChangeLog.md`. From the next session on, the project-local definitions apply — and
the model is still passed per call, belt and braces.

## Step 4: Record it

- **At once:** `docs/0-project/ProjectMemory.md` (Full) — a row per role, the generator included:
  model as named, harness identifier, effort, file it's materialized in. Lite: the **Main model &
  thinking effort** row of `docs/1-define/ProjectParameters.md` — written in the same step, so hold
  the answer until the block is persisted, and name the generator file beside it; Lite keeps no
  `ProjectMemory.md`.
- **When the sheet is written** (Full Step 01): §1.7's table, from the memory rows.
- **`.gitignore`:** the project-local definitions are framework files and follow the intake
  answer about framework files — `.claude/agents/ocpf-light.md`, `.claude/agents/ocpf-reasoning.md`,
  `.claude/agents/ocpf-generator.md`, `.github/agents/ocpf-light.agent.md`,
  `.github/agents/ocpf-reasoning.agent.md`, `.github/agents/ocpf-generator.agent.md` (Ops §
  Repository Hygiene has the block). If the intake question hasn't been asked yet (this skill runs
  before Step 01), add the entries when it is. Verify with `git check-ignore -v`.

## Step 5: Verify, every delegation

All three bundled agents open every report with `Model: <what they ran on>`. Before using anything
from a report, compare that line with the role's row in §1.7 (Lite: the Main row, for the
generator). A mismatch stops the step: say so to the human, fix the definition or the call, redo
the task on the right model. The ChangeLog entry that closes a delegated step names the model that
actually ran.

## Repairing a project

If a project's sub-agents have been running on the wrong model — `docs/1-define/ProjectParameters.md` §1.7
names one model, and the project-local definitions are missing or say another, or a sub-agent's
`Model:` line disagrees — do Steps 3–4 now, record the discrepancy in `docs/0-project/ChangeLog.md` as a
defect with its root cause (which steps ran on which model), and ask the human, through the options
mechanism, whether to redo the affected steps on the recorded model or accept the past work and
apply the assignment from here on. A project set up before plugin 5.0.0 has no `ocpf-generator`
definition: write it with the Main model and effort the project already recorded, no new question.
