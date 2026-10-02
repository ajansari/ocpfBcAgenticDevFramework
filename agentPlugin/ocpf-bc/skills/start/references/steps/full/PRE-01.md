# BC App Build Routine — PRE-01 — State the Problem

**Runbook version:** 5.1.0.0 · Full edition · Phase: DEFINE

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**
- **Ask the working language first — before any other question or action in the routine**
  (Operating Rule 8). Ask it in English, through the options mechanism (Rule 6a), with English
  listed first and a free-text choice for any other language. Continue the rest of the engagement
  in the language chosen. Record it in `docs/0-project/ProjectMemory.md` immediately; Step 01 §1.9 carries it
  into `docs/1-define/ProjectParameters.md`.
- **Create `ocpfFramework/` in the project root, then fetch both companion guides into it, before
  anything else needs them** — the Standards Guide into `ocpfFramework/standardsGuide/` and the
  Operations Guide into `ocpfFramework/opsGuide/`, from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/`. **In the same fetch, get this
  runbook's step files** (`fullVersion/steps/*.md`) into `ocpfFramework/runbookSteps/`, the
  document templates (`documentTemplates/*.md`) into `ocpfFramework/documentTemplates/`, and this
  runbook's changelog (`fullVersion/RunbookChangelog.md`) as `ocpfFramework/RunbookChangelog.md` —
  each from its raw URL,
  `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/<folder>/<file>`
  (Ops § Fetched Companions has the file list). Write the six-line `ocpfFramework/README.md`
  (Ops § Project Setup gives the text) so anyone opening the folder knows what it is. Everything
  the framework fetches or keeps lives under this one folder — `state/`, `patterns/`, `scripts/`
  join it at their steps — and the `.gitignore` block (Ops § Repository Hygiene) covers all of it;
  paste the always-ignored group now, and the intake-dependent group at Step 01 §1.8. Check each
  step file's `**Runbook version:**` line against this runbook's version. Every phase from PRE-02
  onward cites them (PRE-02's own gap-analysis checklist is Standards Part 6, and this step's
  notification and intake procedures are Ops §), so they have to be on disk from the first step.
  Say so plainly rather than fetching silently. **Full procedure, including the plugin's offline
  copies and what to do when GitHub is unreachable: ALL ALONG → OCPF AL Development Standards
  Guide.**
- **Ask how to be notified, right after the working language** (Ops § Notifications — read it now): Claude app, sound, desktop notification, any combination, or none. Record the answer in `ocpfFramework/state/notifications.json` and apply it now, so every question from here on — the approvers question included — reaches the human even when they've stepped away.
- **Ask which models do the work, right after notifications — before any document is drafted**
  (Rule 6a; **Ops § Roles — read it now**). **Say this first, once, before the questions:** *"A
  High thinking effort makes every task slower: the model thinks longer before each answer, and a
  step can take noticeably more time. The framework recommends High only where judgment matters
  most."* Six questions, each with the recommended pair offered first and free-text entry for
  anything else — the recommendation depends on the AI tool:
  - **Claude Code:** Main **Sonnet, Medium**; Light **Haiku, Medium**; Reasoning **Opus, High**.
  - **GitHub Copilot:** Main **Gemini 3.8 Flash, Medium**; Light **Auto, Balanced**; Reasoning
    **Claude Opus 5.5, High**. Copilot names are the picker's names on the day; if one isn't in
    the picker, offer the nearest and say so.

  The questions: **Main model**, **Main thinking effort** (*High* / *Medium* / *Low*), **Light
  model**, **Light thinking effort**, **Reasoning model**, **Reasoning thinking effort**. Ask them
  on one page where the harness allows six questions in a box; in Claude Code, whose
  `AskUserQuestion` takes four questions per box, ask Main + Light in the first box and Reasoning
  in the second, back to back. Say which model this session is running on before asking — the Main
  model *is* this session's model, and only the human can change it (`/model` and `/effort` in
  Claude Code; the model picker in Copilot): if they choose a different Main model or effort, ask
  them to switch now and confirm before continuing. Then **materialize the assignment immediately**
  (Ops § Roles → *Enforcement*): **three** project-local sub-agent definitions — the Light and
  Reasoning roles with their chosen model and effort, and the **generator** (`ocpf-generator`, used
  by Step 06 for parallel batches) on the Main model and effort, no extra question — so Step 02's
  first delegation already runs on the right model. **In a plugin project, run the plugin's
  `roles` skill** (`/ocpf-bc:roles`) — it asks, writes all three, records, and checks in one go, in
  Claude Code and Copilot alike. Record all six answers, and the harness identifier each maps to,
  in `docs/0-project/ProjectMemory.md` now; Step 01 §1.7 carries them into
  `docs/1-define/ProjectParameters.md`. Asked here, not at Step 01, so the answer exists before the
  first delegated task rather than after the sub-agent definitions were already used with no model
  set.
- **If GitHub Copilot is one of the AI tools on this project, ask the two Copilot session-settings
  questions now** (Rule 6a; **Ops § Asking and Approvals → *GitHub Copilot session settings***):
  the agent-mode request limit (*150 — recommended* / *100* / *leave the default*) and tool
  approvals (*Ask each time* / *Allow the framework's own commands* / *Allow everything*, with its
  warning). Write the answers to `.vscode/settings.json` and record them in `ocpfFramework/state/copilot.json`.
  Skip this in Claude Code alone; its permissions are its own prompts.
- **Start the usage clock:** the moment `ProjectProgress.md` is created below, create
  `ocpfFramework/state/usage.json` with PRE-01's `startedAt` (Operating Rule 11; ALL ALONG → Usage
  & Cost Tracking; Ops § Usage & Cost → 5). If the AI tool is Claude Code, note the transcript
  folder the usage skill will read. At this step's close the same rule applies for the first time:
  set `completedAt`, measure, and write PRE-01's rows — one per model — before the exit-gate
  message.
- **Ask who approves, next** (Rule 6a), because it decides how many sign-offs follow — starting
  with this step's own. *Who signs off on the design documents?* **One person for every role**
  (the Functional Consultant, Technical Lead, and Dev Manager sign-offs are all the same
  reader) / **Separate people for different roles**. Record it in `docs/0-project/ProjectMemory.md`; Step 01 §1.1
  carries it into `docs/1-define/ProjectParameters.md` as **Approvers**. With one approver, sign-offs that
  are serial waits on the same reader are combined: PRE-01's with PRE-02's, and Step 03's with Step
  04's. The FRD sign-off (Step 02) stays separate, since the TDD is written from it.
- **Capture any raw requirements input verbatim, before any interpretation happens**. If the human has pasted raw requirements text in chat, or uploaded a file, this is
  the frozen, ground-truth source the rest of DEFINE works from — preserve it untouched, the same
  role a project's own `requirements/<name>.md` already plays once DEFINE is done with it:
  - Create a `requirements/` folder in the project root if one doesn't already exist. It is a
    normal, git-tracked project artifact — never add it to `.gitignore`.
  - **Pasted text in chat:** save it as its own Markdown file in `requirements/` (a descriptive
    name, e.g. `<short-topic-slug>-requirements.md`), with a brief header noting exactly who
    provided it and the date/time, then the raw text **verbatim** below — do not edit, clean up,
    reformat, or summarize it in this copy. If a same-named capture already exists from an
    earlier drop, don't overwrite it — add a date suffix instead, so every capture is preserved
    independently (the same never-delete discipline as `outputAppPackage/`).
  - **An uploaded file:** save an unmodified copy of that exact file into `requirements/`, under
    its original filename (or a de-duplicated variant on a name collision) — no wrapper, no
    reformatting.
  - This isn't a one-time, PRE-01-only action — apply the same capture the moment any later raw
    requirements/scope input arrives too (a change request, a follow-up drop of new material),
    not only at kickoff.
- Before anything else, create the `docs/` folder with its five phase subfolders — `0-project/`,
  `1-define/`, `2-design/`, `3-build/`, `4-prove/` (Operating Rule 9 has what goes where — every
  document from here on is written into one of them) — and `ProjectProgress.md` from
  `ocpfFramework/documentTemplates/ProjectProgress.md` (ALL ALONG → Project Progress Tracker), **in
  the project root — always, not `docs/`** — keeping the *Full* step table and deleting the *Lite*
  one, one row per step of the whole routine, every row blank except this one, marked `In
  Progress`, with the empty usage table beneath it. It's the first project document of the
  engagement apart from `docs/0-project/ProjectMemory.md`, which already holds the working-language
  and model-assignment entries (the notification settings live in `ocpfFramework/state/`, outside
  `docs/`).
- Write a problem statement: what business outcome is required, who the consumers are (users, other systems, AI tools, BI/reporting), which **countries and languages** the users work in (countries confirmed once in Step 01's first box, languages in §1.9), and what is explicitly out of scope.
- Capture the domain vocabulary the design will anchor to (entity names, categories, known pain points).
- Produce an initial entity/object list from stakeholder domain knowledge.
- As the agent: identify duplicates, ambiguous terms, and outdated/legacy terminology in the initial list; ask clarifying questions about scope and consumer use cases. Do not resolve ambiguities silently.

**Outputs:** `ocpfFramework/` with its six-line `README.md`, `standardsGuide/`, `opsGuide/`, `runbookSteps/`, `documentTemplates/`, and `RunbookChangelog.md` (all fetched, the folder gitignored per Ops § Repository Hygiene), `ocpfFramework/state/usage.json` (PRE-01's `startedAt`, and its rows at the close), `ocpfFramework/state/copilot.json` and the Copilot keys in `.vscode/settings.json` (when Copilot is in use), `requirements/` (seeded, if any raw input was provided), `ProjectProgress.md` (seeded from its template, Full step table, project root), `docs/` with `0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/` (created), the model and effort assignment recorded in `docs/0-project/ProjectMemory.md` and materialized as three project-local sub-agent definitions — light, reasoning, generator (Ops § Roles), `docs/1-define/ProblemStatement.md` — purpose, scope, out-of-scope, target consumers, initial entity list, open questions.

**Exit gate:** Both companion guides are present, in `ocpfFramework/standardsGuide/` and `ocpfFramework/opsGuide/`, the step files in `ocpfFramework/runbookSteps/`, the templates in `ocpfFramework/documentTemplates/`, the changelog at `ocpfFramework/RunbookChangelog.md`, the `README.md` written, all gitignored. The Copilot session settings are written and recorded when Copilot is in use. `ocpfFramework/state/usage.json` holds PRE-01's `startedAt` and, at the close, its `completedAt`, and PRE-01's usage rows — one per model — are in `ProjectProgress.md` and pasted into the closing message (Operating Rule 11). The notification choice is recorded in `ocpfFramework/state/notifications.json`, applied, and tested (ALL ALONG → Notifications). The effort warning was said before the model questions, all six model and effort answers are recorded, the Main model and effort match what this session is actually running on, and the Light, Reasoning, and Generator sub-agent definitions exist in the project with the chosen model and effort set (Operating Rule 10). `docs/1-define/ProblemStatement.md` is in `docs/1-define/`, not the root or a flat `docs/` (Operating Rule 9). Functional Consultant signs off on the problem statement and initial entity list (Stage↔Step Map, Stage 1) — or, when **Approvers** is one person, this sign-off moves to the end of PRE-02 and is given together with that step's, on the problem statement and expanded list at once.

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, end the closing message with the options box: **Proceed into PRE-02 now (recommended)** / **Stop here** (say what there is to review and how to resume). Nothing of PRE-02 starts until the human answers.
