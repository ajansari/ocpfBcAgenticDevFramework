---
name: analyze
description: Analyze and document an existing Business Central AL extension that is NOT well documented - written by a human, vibe-coded, or built by an agent that doesn't document - before extending it with the OCPF BC Agentic Development Framework. Asks what the human already knows and which documents they can add to requirements/existing/, which model (a reasoning model or a daily driver) and which thinking effort should do the analysis, then reads app.json, every object under src/, and the translations, and writes a presumed FRD, a presumed TDD, an Object Register, a Documentation with the app's flows and a schema of its tables and fields, and a Project Parameters sheet into requirements/existing/ for the human to review. Use when the user says "document this app", "what does this extension do", "reverse-engineer this extension", "analyze this AL project", "I inherited this app", or runs /ocpf-bc:analyze; the start skill offers it on an existing extension, and Full / Lite offer it at their first step when the project extends an existing app.
---

# Analyze and document an existing extension

**Follow `Ops § Existing Apps` in the Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`;
the bundled copy in the `start` skill's `references/` when the project has none yet). That section
is the rule and the reason; this skill is the procedure.

**What this is for.** An AL extension already exists in the folder and nobody can hand you an FRD,
a TDD, or a document that explains it: a developer wrote it and left, a vibe-coding session
produced it, or an agent built it without documenting. Before anyone extends it — with Full, Lite,
or Build-a-Feature — the framework reads it and writes down what it finds, **presumed where it is
presumed**, into `requirements/existing/`, where the human reviews it and where the next journey's
first step reads it as input. This command is used **first**, before `/ocpf-bc:start` begins a
journey on the app; `start` offers it on an existing extension, and Full PRE-01 / Lite Step 1 offer
it when the intake says *Existing app*.

Throughout, when the human must **decide**, use the harness's options mechanism with the recommended
option first and a one-line reason on each (Ops § Asking and Approvals): `AskUserQuestion` in Claude
Code, `askQuestions` in GitHub Copilot Chat, `ask_user` in the Copilot CLI (add *I'll type it*
where a typed answer is possible). **Every question in this skill goes through that mechanism** —
none is asked in prose.

## Step 1: Check the folder

The workspace root must hold `app.json` and AL objects under `src/` (or wherever the project keeps
them — say where you found them). An AL: Go! scaffold with only `HelloWorld.al` has nothing to
analyze: say so and offer `/ocpf-bc:start` instead. If `ocpfFramework/framework.json` exists, this
is a framework project: the analysis still runs, but say that its documents already exist under
`docs/` and that this analysis is for the parts the framework did not build.

Say what you found in one short paragraph before asking anything: extension name and publisher
as `app.json` has them, version, ID ranges, how many objects of each type under `src/`, whether a
package exists, whether `Translations/` has target languages, and whether any `docs/` or README is
present. **Flag any value that is a template placeholder** (`ALProject1`, `Default publisher`,
`1.0.0.0` with no package, `50100–50149`) as "the AL template's default, not a decision" — never
present one as a fact about the app (Ops § Intake).

## Step 2: Ask, in two boxes

**Box 1 — what you know** (two questions):
1. **What can you tell me about this app?** — *I'll type what I know (recommended)* / *Nothing — work
   it out from the code* / *It is described in documents I'll add to `requirements/existing/`*.
   Free text is expected here: who uses it, what it is for, what is known to be broken, what must
   not change.
2. **Do you have documents about it?** — *Yes — I'll put them in `requirements/existing/` now
   (create the folder if it isn't there) and tell you when done* / *No documents*. Say that `.md`
   is best and that Word, PDF, and images are read too. On *Yes*, wait for the human's go-ahead,
   then list what you found in the folder before continuing.

**Box 2 — who does the analysis** (two questions). Say first, in one sentence, that the analysis
runs on a sub-agent so the chosen model can differ from this session's.
1. **Which model?** Offer four options at most, by kind, **recommended first**:
   - **A reasoning model — Claude Opus (recommended for an app you don't know, or a large or tangled one)**:
     deeper inference of purpose and rules from code; slower and dearer per token.
   - **A daily-driver model — Claude Sonnet**: faster and cheaper; right for a small or tidy app.
   - **In GitHub Copilot only, add the two GPT options the picker shows:** *GPT Sol* beside Opus as a
     reasoning model, *GPT Terra* beside Sonnet as a daily driver. **In Claude Code, offer the two
     Claude options only.** Copilot names are the picker's names on the day; if a name isn't in the
     picker, offer the nearest and say so.
2. **Thinking effort?** — **Medium (recommended)** / *High*. Say in the question's text: *High is
   more detail-oriented — it chases more rules and relations into the code — but can take 1.5× to
   3× longer and as many more tokens or credits.*

Record both answers (model as named, the harness identifier, the effort) in
`requirements/existing/README.md`'s header once the folder exists.

## Step 3: Make the chosen model the one that runs

The analysis is delegated to the **`ocpf-analyst`** sub-agent — the plugin bundles it in `agents/`
with no model of its own (Ops § Roles → *Enforcement*) — so the choice has to be carried, exactly as
the `roles` skill does for the project's other sub-agents:

- **Claude Code:** write `.claude/agents/ocpf-analyst.md` — the bundled body unchanged, with
  `model: <alias or full model ID>` and `effort: <medium|high>` added to the frontmatter. Claude
  Code loads a `.claude/agents/` folder that did not exist at session start only at the next
  session, so if the Agent tool doesn't offer `ocpf-analyst`, delegate to the plugin's
  `ocpf-bc:ocpf-analyst` instead — **and pass `model` on the call either way** (the per-call
  parameter wins; the effort is the session's in the fallback, say so).
- **GitHub Copilot (VS Code or CLI):** write `.github/agents/ocpf-analyst.agent.md` with
  `model: '<picker name>'` and `reasoningEffort: <medium|high>`; invoke it by name. In Copilot CLI
  `model:` isn't documented, so say the analysis may run on the session's model and rely on the
  report's first line.
- **A harness with no sub-agents** (Claude Chat, the github.com cloud agent): say so, ask the
  human to switch the session to the chosen model, and run the analysis yourself.

The definition is a framework file: add `.claude/agents/ocpf-analyst.md` and
`.github/agents/ocpf-analyst.agent.md` to the project's `.gitignore` with the other sub-agent
entries (Ops § Repository Hygiene) when the project keeps framework files out of git; on a
no-framework app, ask the one question (*Leave the framework's own files out of this repository?
(recommended)* / *Track them*) before writing anything, and apply the always-ignored block too.

## Step 4: Open the clock, then delegate

1. **Usage window first.** If `ocpfFramework/state/usage.json` doesn't exist, create it as the
   `usage` skill's Step 1 says (`aiTool`, `transcriptDir`, empty `steps`; `ocpfFramework/state/` is
   always gitignored). Append `{ "step": "AN0", "title": "Analyze existing app", "startedAt": "<now>" }`.
   The usage script fetches the chosen model's published rate itself at the `AN0` close (Ops §
   Usage & Cost → 3); fetch it by hand only when its note says it could not.
2. **Fetch the templates the analyst writes from** if the project has none:
   `documentTemplates/FRD.md`, `TDD.md`, `Documentation.md` into `ocpfFramework/documentTemplates/`
   (Ops § Fetched Companions, raw URLs; the `documents` skill's `references/` when GitHub is
   unreachable), and the Standards Guide into `ocpfFramework/standardsGuide/` so the analyst can cite
   it. Symbols: if `.alpackages/` is empty, download them for the app's `application` version (Ops §
   Symbols) so standard references can be verified; say so.
3. **Delegate, in the background, with a narrow brief** (Ops § Documents → *Briefing a drafting
   role*): the project root; the paths to `app.json`, `src/`, `Translations/`, `.alpackages/`; the
   human's typed notes verbatim; the list of documents found in `requirements/existing/`; the
   output shapes in this skill's `references/outputs.md` and the three template paths; the
   instruction to write only under `requirements/existing/` and to open the report with `Model:`.
   Never the conversation, never a whole guide.
4. **While it runs,** tell the human once what is happening and that a background sub-agent's
   permission prompts surface in the main session. Do nothing else to the project.

## Step 5: Check the report, close the clock, hand over

1. **Verify the first line.** The report's `Model:` must be the model the human chose. A mismatch
   stops here: say so, fix the definition or the call, rerun. Never accept documents from the wrong
   model and note it later.
2. **Open every file it wrote** and check: the six files exist under `requirements/existing/`;
   no template placeholder survives; every inferred statement is marked *(presumed)*; the Object
   Register lists every object under `src/` (count them yourself); the Documentation has the
   `erDiagram` block and the object-role table; the Project Parameters marks each value's source.
   Anything missing goes back to the analyst in one message, not fixed by hand.
3. **Close the window:** set `AN0`'s `completedAt`, run `/ocpf-bc:usage --step AN0`, and paste
   the rows into the closing message. If the project has a `ProjectProgress.md`, the rows go in
   its usage table like any step's; otherwise write them under a `## Usage` heading at the end of
   `requirements/existing/README.md`, so the cost of the analysis travels with its output.
4. **Hand over, in this order:** the analyst's five-line summary of what the extension is; the
   six files by path; the open questions, most important first; the usage rows; then the last
   box: **I'll review the documents now** / *Start a journey on this app — `/ocpf-bc:start`* /
   *Other*. In the message, say this, in the working language: *Review everything in
   `requirements/existing/` — correct anything that is presumed wrongly, and answer the open
   questions in the files themselves. If you now want to extend this app, put the new requirements
   in `requirements/` (`.md` recommended; Word, PDF, and images work too) and run `/ocpf-bc:start`:
   Full, Lite, and Build-a-Feature all read `requirements/existing/` as what the app already is and
   `requirements/` as what it should become.*

## What this skill never does

Never edits `src/`, `app.json`, or `docs/`; never compiles, packages, or publishes; never writes a
requirement as fact that the code only implies; never asks a question in prose; never records a
model that is not the one the report's first line names; never runs the analysis on the session's
model by default when the human chose another.
