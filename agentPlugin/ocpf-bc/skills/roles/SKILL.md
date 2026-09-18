---
name: roles
description: Ask which AI models do the work on a Business Central project following the OCPF BC Agentic Development Framework, and make the answer take effect. Full framework - six questions (Main, Light, and Reasoning model, each with a thinking effort); Lite - two (Main model and effort). Writes project-local copies of this plugin's ocpf-reasoning and ocpf-light sub-agents with the chosen model and effort, records the assignment, and verifies the session model. Use when the runbook reaches the model questions at PRE-01 / Step 1, when the user asks to "choose models", "set the reasoning model", "which model runs the FRD", "use Opus for reasoning", or runs /ocpf-bc:roles, and to repair a project whose sub-agents were running on the wrong model.
---

# OCPF model and effort assignment

The runbook asks which models do the work at its first step, right after notifications (Full
PRE-01, Lite Step 1). This skill does that step, and — for Full — makes the answer *take effect*,
which is the part that failed on a real project: the human chose Sonnet / Haiku / Opus, the sheet
said so, and every delegated task still ran on the session's model because nothing carried the
choice into the sub-agent definitions or the delegating calls.

**Follow `Ops § Roles` in the project's Operations Guide** (`opsGuide/ocpfOperationsGuide.md`) —
it's the version this project follows. If the project has no `opsGuide/` yet, use this plugin's
bundled copy in the `start` skill's `references/ocpfOperationsGuide.md`. The runbook's Operating
Rule 10 (Full) is the rule this skill implements.

## Step 1: Say what's running

State, in the question's own text, the model this session is running on (your system prompt names
it) and, in Claude Code, the session's effort if you know it. The **Main model is this session**:
only the human can change it — `/model <sonnet|opus|haiku>` and `/effort <low|medium|high>` in
Claude Code (VS Code extension and CLI alike), the model picker in Copilot Chat, `/model` in Copilot
CLI. You have no tool that switches it.

## Step 2: Ask, through the options mechanism

Recommended answer first, free-text entry on every question.

**Full — six questions:**

| # | Question | Options |
|---|---|---|
| 1 | Main model? | *Sonnet (recommended)* / *Opus* / *Haiku* |
| 2 | Main thinking effort? | *High (recommended)* / *Medium* / *Low* |
| 3 | Light model? | *Haiku (recommended)* / *Sonnet* / *Opus* |
| 4 | Light thinking effort? | *High (recommended)* / *Medium* / *Low* |
| 5 | Reasoning model? | *Opus (recommended)* / *Sonnet* / *Haiku* |
| 6 | Reasoning thinking effort? | *High (recommended)* / *Medium* / *Low* |

- **Claude Code (VS Code or CLI):** `AskUserQuestion` takes four questions per box — ask 1–4, then
  5–6, back to back.
- **GitHub Copilot Chat in VS Code:** `askQuestions`, all six in one carousel. Offer the models by
  the names the model picker shows (for example *Claude Sonnet 5*, *Claude Opus 5*, *Claude Haiku
  4.5*), because that string is what a `.agent.md` file's `model:` takes.
- **GitHub Copilot CLI:** `ask_user`, one question at a time in this order, with *I'll type it* on
  each.
- **No sub-agents in this harness** (Claude Chat, Cowork, the github.com cloud agent): ask 1–2 only,
  say the Light and Reasoning roles can't run here, and record `N/A — no sub-agents in this harness`.

**Lite — two questions, one box:** Main model (*Sonnet (recommended)* / *Opus* / *Haiku*) and Main
thinking effort (*High (recommended)* / *Medium* / *Low*). Lite stops after Step 4 below.

If the Main answer differs from what the session is running, ask the human to switch now and
confirm the session shows the new model before you continue. Never record a Main model that isn't
the one doing the work.

## Step 3: Write the project-local sub-agent definitions (Full)

This plugin's bundled `ocpf-reasoning` and `ocpf-light` carry **no `model:`** — the same file is
read by Claude Code (which wants an alias like `opus`) and by Copilot (which wants a picker name) —
so a delegation to them inherits the session's model. The project supplies the model through its
own copies. The templates are in this plugin's `agents/` folder, two folders above this skill's
own folder (`../../agents/ocpf-reasoning.agent.md` and `../../agents/ocpf-light.agent.md`); if you
can't read them, fetch the same two files from
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/agents/`.

Write, for every harness the project uses (the same choice the runbook placement was made for —
`.ocpf/framework.json` → `placedAs`; `CLAUDE.md` means Claude Code, `.github/…` means Copilot):

- **Claude Code — `.claude/agents/ocpf-reasoning.md` and `.claude/agents/ocpf-light.md`.** The
  bundled body unchanged; frontmatter keeps `name:`, `description:`, and `disallowedTools:`, and
  gains two lines:
  ```yaml
  model: opus          # the recorded alias: sonnet | opus | haiku, or a full model ID
  effort: high         # the recorded effort: low | medium | high (Claude Code also accepts xhigh and max; the framework offers three)
  ```
  `effort:` on the definition is the **only** place a sub-agent's effort can be set — Claude Code
  has no per-call effort override.
- **GitHub Copilot — `.github/agents/ocpf-reasoning.agent.md` and `.github/agents/ocpf-light.agent.md`**
  (VS Code and Copilot CLI both read this folder; `model:` is documented for the IDE surfaces —
  in Copilot CLI it may be ignored, so there the `Model:` first-line check is the only guarantee,
  and you tell the human those roles may run on the CLI's session model). Same body; frontmatter
  gains
  ```yaml
  model: 'Claude Opus 5'   # the picker name, or an array of names in preference order
  ```
  Copilot has no effort field on an agent definition: say so, and record the effort as `session`.

Never overwrite a file that already exists and isn't one of these two (compare the `name:` line);
stop and ask. Tell the human which files were written.

**Claude Code loads a new `.claude/agents/` folder only at the next session start.** It watches the
folder for changes, but only if the folder existed when the session began — so in the session that
creates it, the project-local agents may not be available yet. Check: if the Agent tool doesn't
know `ocpf-reasoning` as a `subagent_type`, then **for the rest of this session** delegate to the
plugin's `ocpf-bc:ocpf-reasoning` / `ocpf-bc:ocpf-light` with the recorded alias in the Agent tool's
`model` parameter on every call (the per-call parameter overrides everything, so the model is
still right), tell the human that the effort for those roles will be the session's until the next
session, and record that in `docs/ChangeLog.md`. From the next session on, the project-local
definitions apply — and the model is still passed per call, belt and braces.

## Step 4: Record it

- **At once:** `docs/ProjectMemory.md` (Full) — a row per role: model as named, harness identifier,
  effort, file it's materialized in. Lite: the **Main model & thinking effort** row of
  `docs/ProjectParameters.md` — written in the same step, so hold the answer until the block is
  persisted; Lite keeps no `ProjectMemory.md`.
- **When the sheet is written** (Full Step 01): §1.7's three-row table, from the memory rows.
- **`.gitignore`:** the project-local definitions are framework files and follow the intake
  answer about framework files — `.claude/agents/ocpf-light.md`, `.claude/agents/ocpf-reasoning.md`,
  `.github/agents/ocpf-light.agent.md`, `.github/agents/ocpf-reasoning.agent.md` (Ops § Repository
  Hygiene has the block). If the intake question hasn't been asked yet (this skill runs before
  Step 01), add the entries when it is. Verify with `git check-ignore -v`.

## Step 5: Verify, every delegation (Full)

Both bundled agents open every report with `Model: <what they ran on>`. Before using anything from
a report, compare that line with the role's row in §1.7. A mismatch stops the step: say so to the
human, fix the definition or the call, redo the task on the right model. The ChangeLog entry that
closes a delegated step names the model that actually ran.

## Repairing a project

If a project's sub-agents have been running on the wrong model — `docs/ProjectParameters.md` §1.7
names one model, and the project-local definitions are missing or say another, or a sub-agent's
`Model:` line disagrees — do Steps 3–4 now, record the discrepancy in `docs/ChangeLog.md` as a
defect with its root cause (which steps ran on which model), and ask the human, through the options
mechanism, whether to redo the affected steps on the recorded model or accept the past work and
apply the assignment from here on.
