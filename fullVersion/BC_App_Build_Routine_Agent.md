# BC App Build Routine — Agent Runbook

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

**Version:** 5.1.0.0
**Last Updated:** October 1, 2026

> Version history for this framework lives in `ocpfFramework/RunbookChangelog.md`, tracked
> independently of any one project built with it — check there for what changed between the version
> you have and the latest. If `ocpfFramework/RunbookChangelog.md` is not found, fetch it with the
> companions (Ops § Fetched Companions).

> **What this is:** A single, ordered routine an AI agent follows to build a new Business Central AL Per-Tenant Extension (PTE) from a business problem through to a tested, documented app deployed to production.
>
> **How the agent uses it:** Work the phases in order (DEFINE → DESIGN → BUILD → PROVE). Do not start a step until its predecessor's exit gate is met. Every step lists its **Inputs**, **Actions**, **Outputs**, and **Exit gate**. The *Project Parameters* block in Step 01 is the single source of truth for every name, ID, version, and quoting decision — never hardcode any of those values in AL; always derive them from that block. It is persisted as `docs/1-define/ProjectParameters.md`, not just discussed — every later step reads it from that file. At the start of every session, read `ocpfFramework/state/notifications.json` and keep notifying the human the way it says; if it's missing, ask how they want to be notified (ALL ALONG → Notifications).
>
> **Companion documents, both fetched at PRE-01 and kept for the life of the project:**
> - `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md` — the **OCPF AL Development Standards Guide**
>   (v1.11.0.0): the AL *rules* this sequence applies (Parts 1–11, Appendices A–E), cited below as
>   **Standards §**.
> - `ocpfFramework/opsGuide/ocpfOperationsGuide.md` — the **OCPF Operations Guide** (v5.1.0.0): the *procedures*
>   this sequence uses — asking, intake, project setup, the AL tools, tooling checks, analyzers,
>   symbols, editor sync, notifications, packaging, repository hygiene, translations, fetched
>   companions, documents, usage and cost, and the plugin — cited below as **Ops §**. Both editions
>   of the runbook share it unchanged.
> - `ocpfFramework/runbookSteps/` — **this runbook's step files**, one per step (`PRE-01.md` … `12.md`), fetched
>   from `fullVersion/steps/` at PRE-01 alongside the guides. **The step sections below are stubs;
>   the step file is the step.** Read it in full the moment the step starts — never work a step from
>   its stub or from memory — and brief a sub-agent with the step file and the named inputs, never
>   the whole runbook or a whole guide.
> - `ocpfFramework/documentTemplates/` — one template per project document (FRD, TDD, Sanity Check, Human Effort
>   Estimate and its Human Effort Baselines, AI Effort Estimate, Build Plan, ChangeLog, Gap
>   Analysis, Code Review, Documentation, User Guide, Human Unit Test Script, Deployment, Release
>   Test Results, Acknowledgements, Project Progress, and Lite's Design Doc, Docs, and Test Script —
>   the full list is Ops § Fetched Companions), fetched with the step files. A document is written
>   from its template, never from a structure improvised in the moment (Ops § Documents).
>
> **Everything the framework fetches or keeps lives under `ocpfFramework/` in the project root**
> — the companions above, `framework.json`, `state/` (per developer, always gitignored),
> `patterns/`, `scripts/`, and this runbook's own changelog. Its six-line `README.md` says so to
> anyone who opens the folder (Ops § Project Setup). The project's own files — `src/`, `docs/`,
> `requirements/`, `outputAppPackage/`, `ProjectProgress.md`, `app.json` — never go in there.
>
> **Read an Ops § section at the step that names it**, in that step's Actions or its exit gate.
> Don't load the whole guide at once, and don't work from memory of a section you haven't opened in
> this project. This runbook drives the *sequence*; neither companion repeats it, and it doesn't
> repeat them: ALL ALONG's sections keep a few lines of non-negotiables and point at the guide.
> See ALL ALONG → OCPF AL Development Standards Guide for fetching, refreshing, and version skew.
>
> **Prime directive for the agent:** An ambiguous input produces ambiguous code. If a step's inputs are incomplete or contradictory, stop and ask the human — do not invent rules to fill the gap.
>
> **Installed by the OCPF plugin?** If this project has an `ocpfFramework/framework.json` file, it was set up by the OnlyCopilotFans agent plugin. Read ALL ALONG → OCPF Plugin before anything else in this session: it adds a once-per-session framework update check, a Standards Guide fallback, one-step AL tool setup, ready-made sub-agents (light, reasoning, generator), and the `documents` and `usage` skills. Without that file, ignore that section. Everything else here works the same either way.

---

## Operating Rules (apply in every phase)

1. **Part 1 is authoritative.** Publisher, prefix, namespace, versions, ID ranges, localization — read them from the Project Parameters block (Step 01) and derive everything else. Never hardcode.
2. **Verify against BC symbol files, not memory.** Table numbers, `using` namespaces, field IDs, `ObsoleteState` — confirm each in the symbol file named in Parameter 1.4. Agent knowledge of BC table numbers is not reliable; the verification procedure is Standards Appendix B. The agent downloads those symbols itself at Step 01 §1.10 (ALL ALONG → Symbols); the human never has to. **The downloaded symbols are the source of truth and the *only* routine lookup.** Consult Microsoft Learn's Base Application or System Application reference (Standards Appendix B; links in ALL ALONG → Reference Sources) **only** when (a) symbols could not be downloaded, (b) the object, field, method, or event is not in the downloaded symbols, or (c) the task needs a code pattern, a snippet, or an event's signature to subscribe to it. Never as a second check on something the symbols already answered, and never "to be safe". Every Learn lookup costs time and tokens; say why it was needed when one happens. The downloaded symbols win when the two disagree.
3. **Phase large scope into batches.** A batch is a self-contained, reviewable increment (by module or document-type group) — designed to be independently correct even though, under Operating Rule 4, it is not compiled on its own to prove it. Define batch boundaries during DESIGN and record them in the TDD.
4. **Lint every batch as it's written; don't compile per batch.** Run Step 05's pre-flight checklist (in `ocpfFramework/runbookSteps/05.md`) on each batch as it's generated, both passes, including symbol verification (Operating Rule 2). The whole extension compiles and packages once, at Step 07, the moment Step 06 finishes — a real compile catches cross-file problems lint can't, and one pass keeps generation fast. After that, every code change anywhere in BUILD or PROVE goes through the same cycle: compile, package, deploy to a sandbox, test, fix, repeat. A human-requested spot-check compile mid-BUILD is extra, never a substitute. Gap-fill code, once written, gets its own pass through Steps 05–07. Treat any compile error as systemic: fix the rule or template, then every file it touched.
5. **Zero errors, zero warnings before PROVE.** A warning is a defect, not noise. Step 07's compile must reach 0/0, with the analyzers and nothing suppressed (ALL ALONG → Analyzers), before Step 08 begins.
6. **Human-in-the-loop is a feature — approve in batches, not one click at a time.** Pause for human approval before:
   - **generating code** — once, for the whole batch plan at Step 05, unless the human chose to be asked before each batch (how the batches run — all in parallel, one at a time, or ask per batch — is a Rule 6a decision asked once in the same step);
   - **applying root-cause fixes** — all the diagnoses from one test round or review, presented together for one decision (Step 07), with any fix that changes the FRD, TDD, or a design rule asked separately;
   - **finalizing any design document** — combined into fewer sign-offs when one person holds every approver role (PRE-01 *Approvers*);
   - **installing any tool or runtime.**

   An approved batch plan, in any batch mode, still stops by itself on any pre-flight failure or deviation from the TDD, and the human can say "stop" at any time. Why batched: approving each batch and each fix separately cost a typical run dozens of one-at-a-time waits without adding protection — every item is still listed and individually selectable before anything is applied.
6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human to *decide something* — pick between design options, approve a version bump, choose a name, resolve an ambiguity — present it through the interactive multiple-choice mechanism the agent's harness provides (e.g., in Claude Code, the `AskUserQuestion` tool — substitute whatever the actual harness offers), with the recommended option first and a short reason on each. A decision buried in a paragraph of chat is easy to miss: it reads like the agent finished and is idling, so the project silently stalls waiting on an answer nobody realised was owed.
    **Use it for decisions — and every step close is one.** Finishing a step and asking whether to start the next one is a decision (proceed / stop), and it always goes through the box: Rule 6c says exactly how, for every step of every phase, PRE-01 through Step 12. What does *not* go in the box is progress *inside* a step — a clean compile mid-round, a batch's pre-flight result, a draft handed back part-way — that is ordinary conversation, and wrapping it makes the box noise.
    **Every intake question counts as a decision, including the ones only the human can answer.**
    Names, publisher, prefix, namespace, localization, object ID ranges, and versions all go
    through the options mechanism. None is asked as an open-ended question or a numbered list in
    chat. When the answer is a value only the human knows, the mechanism's free-text entry carries
    it (in Claude Code, *Other*). Step 01 says what to offer as options for each question. Why: an
    open-ended chat question is easy to half-answer or skip past — exactly the failure this rule
    exists to prevent.
    **Two decisions this rule owns by name, so neither is ever asked in prose:** the
    parallel-batches question at Step 05 (*all batches in parallel* / *one at a time* / *ask before
    each*) and the release-candidate question at the end of Step 11 (*build v1.0.0.0 now* / *keep
    testing on 0.x builds*). Version bumps to the Major, Minor, or Build segment are Rule 6a
    decisions too; the Revision increment before every build is not — it's mechanical (ALL ALONG →
    Packaging & Versioning).
    **Which mechanism each harness offers, and the option-count limits, are Ops § Asking and
    Approvals.**
6b. **Don't install tooling without asking — and look harder first.** Before concluding a required
    compiler or runtime is missing, check whether the human's own IDE already provisions one
    privately: VS Code's AL extension gets its .NET runtime from a companion extension, not a system
    install (**Ops § Asking and Approvals** has the per-OS paths). For Node, the mermaid renderer,
    and PowerShell 7, the check and the per-OS install offers are **Ops § Tooling Checks** — an
    npx-cached mermaid-cli is never on `PATH`, so `which mmdc` is the wrong test. Installing
    anything is itself a human-in-the-loop decision, whatever a fallback elsewhere lists as
    available.
6c. **Every step closes through the options box — PRE-01 through Step 12, every phase, no exceptions.**
    When a step's own work is finished — its outputs written, its exit gate met, its usage rows
    recorded and pasted (Rule 11), and the end-of-step summary given — the **last thing in the
    closing message is a question through the interactive mechanism (Rule 6a)**, never a line of
    prose that waits for "continue". It asks one thing, with these two named options plus the
    mechanism's own free-text entry: **Proceed into Step <next> now (recommended)** / **Stop here**.
    Where the step produced something the human may want to look at first — a package to run, a
    document or findings to review — the *Stop here* option says what that is, and the message says
    how to resume ("say 'continue' or name the step"). At a phase boundary (Step 01 → 02 closes
    DEFINE, 04 → 05 closes DESIGN, 07 → 08 closes BUILD) the same box names the phase that closes
    and the one that opens. **Nothing of the next step starts until the human answers the box.**
    Each step file repeats this under its exit gate, with the next step named.

    Why this is a rule and not a preference: through v5.0.0.0 this rule applied "from Step 08
    onward" and said Steps 01–07 were "unaffected". A v5.0.0.0 run closed every DEFINE, DESIGN,
    and BUILD step with a plain prompt, the project sat waiting on an answer nobody realised was
    owed, and the agent explained that the box "was only needed from Step 8". Rule 6a's own
    reasoning — a decision in prose reads like the agent finished and is idling — holds at every
    step, so the box is mandatory at every one.

    **One boundary has its own box instead of this one:** the Step 11 → Step 12 hand-off, where
    Step 12's note *replaces* this check-in with the two-option hand-off message ("Perfect, I
    understand!" / "I have some questions."), followed by the one reminder message that note
    prescribes, which asks nothing. Send that box, not both.
6d. **Zero-install first — never turn setup into the human's job.** Before proposing any install,
    or any manual setup for the human (editing `PATH`, a shell profile, or an environment variable),
    work through the ladder in **Ops § Asking and Approvals** and stop at the first option that
    works: what the editor already provides, then what's already installed, then — only then — an
    install asked for under Rule 6b. The same ladder, applied to Node, mermaid, and PowerShell, is
    **Ops § Tooling Checks**; the outcome is recorded in `ocpfFramework/framework.json` → `tooling`.

    **Never hand the human a setup task the agent can do.** Connecting the AL tools, downloading
    symbols, keeping the editor's view current, and setting up notifications are the agent's job.
    The human's part is approving the AI tool's own prompts, and a browser sign-in when a tool
    reaches a live Business Central environment. **Never send the human to the Command Palette to
    set up the AL MCP Server** — the AL Language extension has no such command — and never route AL
    tooling through a third-party VS Code extension. The test: would a functional consultant with
    only VS Code and the AL extension have to do anything by hand? If yes, look again.
6e. **An interruption changes nothing about how questions are asked.** The human can dismiss a box
    (Escape in Claude Code), stop the agent mid-step, close the session, or come back days later.
    When they say "continue", "resume", "go on", name a step, or run the `status` skill and then
    ask to proceed, the agent first works out what is still unanswered, then asks for it the only
    way it ever asks — through the options box (Rule 6a) — and carries on under exactly the same
    rules, including the Rule 6c box at the end of the step and of every step after it:
    - **A dismissed or unanswered box is re-asked, not inferred.** An interrupted intake set
      (PRE-01, Step 01) resumes at the first question without a recorded answer, in the same box
      form, with the questions already answered skipped — never re-asked from the top, never
      defaulted silently. A dismissed Rule 6c box at a step boundary is sent again, as it was,
      before anything of the next step starts. A dismissed approval (Rule 6) is asked again before
      the thing it gates is done.
    - **What counts as answered is what is recorded:** `docs/1-define/ProjectParameters.md` and
      `app.json` for intake, the project's sign-offs and `docs/0-project/ProjectMemory.md` for
      decisions, `ProjectProgress.md` and `ocpfFramework/state/usage.json` for which step is open.
      Anything the human typed in chat instead of the box is recorded there first, then treated
      as answered. If the agent's memory of an answer isn't in a file, it isn't an answer.
    - **Resuming mid-step** never skips the step's close: finish the step's actions, meet its exit
      gate, record usage (Rule 11), then the Rule 6c box (mid-step, the framework update offer is
      held until the gate — Ops § Plugin). Resuming *at* a boundary — the human
      stopped right after a step closed — **always starts with that boundary's Rule 6c box, sent
      again**: nothing records whether the box was answered or dismissed, re-asking a *Stop here*
      is harmless, and inferring a *Proceed* is exactly what this rule forbids. The once-per-session
      framework update offer (Ops § Plugin) comes first, as its own box, and only then the re-asked
      Rule 6c box — reversed from a live boundary, because the box has not been answered yet and an
      update may change the next step's rules.
    - **"Continue" is not a blanket approval.** It reopens the routine; it answers no pending
      box. The one message that may both resume and answer is a choice typed in the mechanism's
      free-text entry.
    Why: an interruption is the moment the agent is most tempted to "just carry on" from memory
    — and the moment the project is most likely to be running on an assumption the human never
    made. Both editions follow this rule identically.
7. **Log every deviation immediately.** Any departure from FRD or TDD goes in the ChangeLog before the next batch starts (see *All Along*).
8. **Work in the human's chosen working language.** The very first question of the routine (PRE-01) asks which language the human wants to work in. From then on, every question, options box (Rule 6a), explanation, and status message is in that language. **Always in English, regardless:** this runbook and the Standards Guide, AL code, object and identifier names, commit messages, and the engineering documents (`FRD`, `TDD`, `SanityCheck`, `PostDevTDD`, `ChangeLog`, `GapAnalysis`, `CodeReview`, `ProjectMemory`) — so no second-language copy can drift from them. **Kept verbatim in their original language:** raw requirements (`requirements/`) and tester feedback (`docs/0-project/TestingFeedback.md`). When the human names a BC concept in their own language, map it to the standard object through the translation glossary (ALL ALONG → Translations & Terminology) rather than guessing.
9. **Every project document lives in `docs/`, in its phase subfolder — write the path, not just
   the name.** `docs/` is the home of every document this routine produces or maintains, laid out by
   phase, numbered so the folders sort in routine order:
   - `docs/0-project/` — `ChangeLog.md`, `ProjectMemory.md`, `Roadmap.md`, `TestingFeedback.md`,
     `Acknowledgements.md`;
   - `docs/1-define/` — `ProblemStatement.md`, `ProjectParameters.md`, `ObjectRegister.md`,
     `TranslationGlossary.md`;
   - `docs/2-design/` — `FRD.md`, `TDD.md`, `SanityCheck.md`, `HumanEffortEstimate.md`,
     `AiEffortEstimate.md`;
   - `docs/3-build/` — `BuildPlan.md`;
   - `docs/4-prove/` — `GapAnalysis.md`, `CodeReview.md`, `PostDevTDD.md`, `Documentation.md`,
     `UserGuide.md`, `HumanUnitTestScript.md`, `AutomatedTestScripts.md`, `Deployment.md`,
     `ReleaseTestResults.md`, and every translated copy beside its source
     (`docs/4-prove/UserGuide.fr-CA.md`).

   Create `docs/` and its five subfolders at PRE-01, before the first document is written.
   **`ProjectProgress.md` is the one document in the project root** (deliberately, ALL ALONG →
   Project Progress Tracker); the other things that belong in the root are the `requirements/`
   folder, `app.json`, `src/` (all AL source, the app icon in `src/logo/`), `Translations/`,
   `outputAppPackage/`, `ocpfFramework/`, and the tool folders (`.github/`, `.claude/`, `.vscode/`,
   `.alpackages/`). Nothing else. Every step file names its documents with the full `docs/<n>-<phase>/`
   prefix; a bare name anywhere (a chat message, an older document, a sub-agent's draft) still means
   that path. **Check at every exit gate:** list the project root and `docs/` itself, and if any
   document from this list is sitting there, move it with `git mv` (so history follows it), fix every
   link that pointed at the old path, and note the move in `docs/0-project/ChangeLog.md`. Why: on a real
   project the FRD, TDD, Sanity Check, gap analysis, and problem statement all landed in the root
   because the steps named the files without their folder, and every later reader had to hunt for
   them; a flat `docs/` with twenty files was the next thing readers hunted through.
10. **Delegate on the recorded model — and prove it.** Every Light-role, Reasoning-role, and
    Generator task (the **Role:** notes on Steps 02–04 and 06–09, and the Testing Feedback Log) is
    delegated to a sub-agent running the model and thinking effort recorded in §1.7, *never* left
    to the harness's default, which silently inherits the main session's model. **Full procedure
    and the per-harness mechanics: Ops § Roles → *Enforcement*.** The non-negotiables, in order:
    - **Materialize.** The assignment is asked at PRE-01 and written at once as three project-local
      sub-agent definitions carrying the chosen model and effort — light, reasoning, and the
      generator on the Main model (in a plugin project, the `roles` skill does it).
    - **Delegate to that definition, pass the model, and run it in the background.** Every
      delegation names the project-local sub-agent. In Claude Code, the Agent tool's `model`
      parameter also carries the recorded model on every single call — including the first-session
      fallback, when Claude Code hasn't loaded the new `.claude/agents/` folder yet and the plugin's
      own agent is used instead. In Copilot, the definition's `model:` line is the mechanism (VS
      Code); in Copilot CLI that line isn't documented, so say so and rely on the next bullet. None
      of the three roles asks the human, so every delegation runs as a background sub-agent —
      that's what makes parallel batches and overlapping pre-flight possible; foreground only when
      the very next action needs the result and nothing else can proceed (an FRD draft). In Claude
      Code a background sub-agent's permission prompts still surface in the main session.
    - **Verify from the report.** Every sub-agent report opens with the model it actually ran on.
      The main role compares that line against §1.7 before using anything from the report; a
      mismatch stops the step, is told to the human, and is fixed before the work is redone.
    - **Record what ran.** The ChangeLog entry for each delegated step names the model from that
      first line.

    Why: on a real project the human
    chose Sonnet / Haiku / Opus at intake, the sub-agent definitions carried no model, no delegation
    passed one, and every "Opus" task quietly ran on Sonnet — with the intake sheet saying otherwise.
11. **Record usage at every step boundary — the exit gate isn't met until the rows exist.** The
    procedure is **Ops § Usage & Cost → 5. The step boundary ritual**; the non-negotiables:
    - **Step start:** append `{ "step", "startedAt" }` to `ocpfFramework/state/usage.json` and set
      the step's `ProjectProgress.md` row to `In Progress` — same moment, same message.
    - **Step close, before the closing message (summary, then the pasted rows, then the Rule 6c box as its last thing):** set `completedAt`, run
      the measurement (plugin: `/ocpf-bc:usage --step <id>`; without the plugin, the Ops procedure),
      and write the step's rows into the usage table — **one row per model that ran in the step**,
      the Main model and every sub-agent model, never one row for the step with a single model.
      Paste those rows into the closing message so the human sees them without opening the file.
    - **The exit gate is not met until the rows exist.** The next step does not start on a missing
      row; the `status` skill reports a missing row as a blocker.
    - **Never hand-write a row, in either tool.** The script reads Claude Code's transcripts, or
      GitHub Copilot Chat's session files, and already aggregates per (step, model); a hand-written
      row is how a real project got one model for everything. **In Copilot the step close is also
      the checkpoint** that separates this step's AI credits from the next one's — a step closed
      without the measurement can't be separated later (Ops § Usage & Cost → 2).

---

# PHASE: DEFINE

Goal: turn a business need into a validated, complete scope and a filled-in parameter sheet — before any design work.

## PRE-01 — State the Problem

**Read `ocpfFramework/runbookSteps/PRE-01.md` in full before starting this step.** It carries the exact order of the
opening questions and the capture rules.

**In one line:** ask the working language, fetch both companion guides and the step files into
`ocpfFramework/`, ask how to be notified, ask which models do the work (six questions with the
per-harness recommendations — `roles` skill in a plugin project; three project-local sub-agents
written), ask the Copilot session settings if Copilot is in use, ask who approves, capture raw
requirements verbatim, create `docs/` with its phase subfolders, `ProjectProgress.md`, and
`ocpfFramework/state/usage.json`, then write `docs/1-define/ProblemStatement.md`.

**Outputs:** `ocpfFramework/` with its six-line `README.md`, `standardsGuide/`, `opsGuide/`, `runbookSteps/`, `documentTemplates/`, and `RunbookChangelog.md` (all fetched, the folder gitignored per Ops § Repository Hygiene), `ocpfFramework/state/usage.json` (PRE-01's `startedAt`, and its rows at the close), `ocpfFramework/state/copilot.json` and the Copilot keys in `.vscode/settings.json` (when Copilot is in use), `requirements/` (seeded, if any raw input was provided), `ProjectProgress.md` (seeded from its template, Full step table, project root), `docs/` with `0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/` (created), the model and effort assignment recorded in `docs/0-project/ProjectMemory.md` and materialized as three project-local sub-agent definitions — light, reasoning, generator (Ops § Roles), `docs/1-define/ProblemStatement.md` — purpose, scope, out-of-scope, target consumers, initial entity list, open questions.

**Exit gate:** Both companion guides are present, in `ocpfFramework/standardsGuide/` and `ocpfFramework/opsGuide/`, the step files in `ocpfFramework/runbookSteps/`, the templates in `ocpfFramework/documentTemplates/`, the changelog at `ocpfFramework/RunbookChangelog.md`, the `README.md` written, all gitignored. The Copilot session settings are written and recorded when Copilot is in use. `ocpfFramework/state/usage.json` holds PRE-01's `startedAt` and, at the close, its `completedAt`, and PRE-01's usage rows — one per model — are in `ProjectProgress.md` and pasted into the closing message (Operating Rule 11). The notification choice is recorded in `ocpfFramework/state/notifications.json`, applied, and tested (ALL ALONG → Notifications). The effort warning was said before the model questions, all six model and effort answers are recorded, the Main model and effort match what this session is actually running on, and the Light, Reasoning, and Generator sub-agent definitions exist in the project with the chosen model and effort set (Operating Rule 10). `docs/1-define/ProblemStatement.md` is in `docs/1-define/`, not the root or a flat `docs/` (Operating Rule 9). Functional Consultant signs off on the problem statement and initial entity list (Stage↔Step Map, Stage 1) — or, when **Approvers** is one person, this sign-off moves to the end of PRE-02 and is given together with that step's, on the problem statement and expanded list at once.

## PRE-02 — Structured Gap Analysis

**Read `ocpfFramework/runbookSteps/PRE-02.md` in full before starting this step.**

**In one line:** run the Standards Part 6 gap checklist over every entity — analytical detail
tables, posted/archived versions, lookups, secondary document types, modern vs. legacy tables, tax
tables, global vs. localized scope, regional terminology — and log every addition with its reason.

**Outputs:** Expanded, de-duplicated entity list with each entity tagged (analytical / master / setup / document / posted / lookup), R/W intent noted, and global-vs-localized noted. Gap log: what was added and why.

**Exit gate:** Technical Lead reviews the expanded list; all gaps are closed or explicitly deferred with reasoning (Stage↔Step Map, Stage 2). When **Approvers** is one person, this is one sign-off covering `docs/1-define/ProblemStatement.md` and the expanded list together (PRE-01's deferred sign-off included). This step's usage rows, one per model, are written before this message (Operating Rule 11).

## 01 — Populate the Intake Sheet (Project Parameters)

**Read `ocpfFramework/runbookSteps/01.md` in full before starting this step.** It holds the complete Project
Parameters block (§1.1–§1.10) — every parameter, its placeholder, and its guidance — and the
AppSource manifest set.

**In one line:** ask every parameter through the options mechanism, in the boxes **Ops § Intake**
lays out (identity and the app icon, naming, permission sets and IDs, onboarding, working setup,
languages, confirm), persist the confirmed sheet as `docs/1-define/ProjectParameters.md`, then set
up the AL project yourself — `app.json` (version `0.0.0.1` for a new app), `src/`, the icon, AL
tools, symbols, editor sync (§1.10, Ops § Project Setup).

**Outputs:** `docs/1-define/ProjectParameters.md` — the completed Project Parameters block (above, all placeholders replaced), persisted as its own tracked document so every later step, and every role under §1.7, reads it from disk rather than depending on conversation history; an empty **Object Register** (`docs/1-define/ObjectRegister.md`) seeded with the allocated ID ranges; the project's `.gitignore` populated per this section and per ALL ALONG → Repository Hygiene, and verified with `git check-ignore`; **`docs/1-define/TranslationGlossary.md`**, created with the regional terms PRE-02 listed (ALL ALONG → Translations & Terminology) — unless the project chose *US wording, no translation files*; `app.json` (with `version` from **Starting Version** and, when an icon was given, `logo`), `src/` (and `src/logo/AppLogo.png`, resized and committed, when an icon was given), and `.alpackages/` per §1.10.

**Exit gate:** Every question in this step was asked through the options mechanism (Ops § Intake), the app icon question included. `app.json` matches the sheet — `version` is `0.0.0.1` for a new app or the installed version for an existing one — and symbols for the target version are in `.alpackages/` (§1.10, Ops § Project Setup). `src/` exists, and `src/logo/AppLogo.png` is square, 300 px on a side unless the source was smaller, and named in `app.json`'s `logo` when the icon answer was *Yes*. No placeholder remains. **Approvers** is recorded (asked at PRE-01). Deployment Target is one allowed value. Namespace matches between 1.1 and 1.3, or both are correctly N/A if Use Namespace = `No`. Localization is set. If Permission Sets required = `Yes`, ≥ 2 IDs are reserved in the primary range. §1.6's three questions are each answered `Yes`/`No` with specifics recorded for any `Yes`. §1.7 carries the PRE-01 answers: every one of the three roles has a model, its harness identifier, and a thinking effort recorded — not model alone — and the Light, Reasoning, and Generator sub-agent definitions exist in the project with those values (Operating Rule 10). §1.8 is answered (or defaults to `Yes`), every entry from the Ops § Repository Hygiene block is in `.gitignore`, and `git check-ignore` confirms each existing framework file — `ocpfFramework/` and the sub-agent definitions included — is ignored. `docs/1-define/ProjectParameters.md` and `docs/1-define/ObjectRegister.md` are in `docs/1-define/`, and nothing from Operating Rule 9's list is in the project root or a flat `docs/`. §1.9: every target language is classified against Microsoft's live page and — unless source wording is *US wording, no translation files* — has a required-at-release answer and a named reviewer; source language and wording are recorded; any mismatch with `Localization` is resolved. Human confirms the sheet. This step's usage rows, one per model, are written before this message (Operating Rule 11).

---

# PHASE: DESIGN

Goal: a complete FRD and a self-sufficient TDD, both validated for BC feasibility and internal consistency, before any code.

## 02 — Craft the Functional Requirements Document (FRD)

**Read `ocpfFramework/runbookSteps/02.md` in full before starting this step.**

**Role:** drafted by the **reasoning role** — delegated on the §1.7 model, with the model passed
explicitly and verified from the report (Operating Rule 10) — fed
`docs/1-define/ProblemStatement.md`, the expanded entity list, and Project Parameters; the main role integrates
the draft (saves it, does the ChangeLog/ProjectMemory bookkeeping) and takes it to the human for
sign-off. Sign-off is unchanged either way — it's the human's, never the drafting role's.

**Outputs:** `docs/2-design/FRD.md`.

**Exit gate:** FRD + Dev Manager sign-off. Every DEFINE-phase entity is accounted for. No unverified platform assumptions remain (Stage↔Step Map, Stage 4). This step's usage rows, one per model, are written before this message (Operating Rule 11).

## 03 — Craft the Technical Design Document (TDD)

**Read `ocpfFramework/runbookSteps/03.md` in full before starting this step.**

**Role:** drafted by the **reasoning role** (Operating Rule 10 applies, as at Step 02), fed `docs/2-design/FRD.md`,
Project Parameters, and the symbol file; the main role integrates the draft and takes it to the
human for sign-off, same as Step 02.

**Outputs:** `docs/2-design/TDD.md`; updated **Object Register** with every planned object and its ID;
`docs/2-design/HumanEffortEstimate.md` (against the named baselines file);
`docs/2-design/AiEffortEstimate.md` (tokens, cost, wall-clock from BUILD on, margin, calibration read).

**Exit gate:** Technical Lead sign-off. Self-sufficiency check passes: no rule requires knowledge outside the document (Stage↔Step Map, Stage 5). `docs/2-design/HumanEffortEstimate.md` exists, covers every object in the register, names the baselines file it used, and states its assumptions. `docs/2-design/AiEffortEstimate.md` exists, covers every step from 05 to 12 per model and token type, prices from `ocpfFramework/state/pricing.json`, carries the 30-minute approval sentence, names its margin, and says what calibration it read. When **Approvers** is one person, the sign-off moves to Step 04 and is given once, on `docs/2-design/TDD.md` and `docs/2-design/SanityCheck.md` together — the self-sufficiency check still passes here first. This step's usage rows, one per model, are written before this message (Operating Rule 11).

## 04 — Sanity Check and Validation

**Read `ocpfFramework/runbookSteps/04.md` in full before starting this step.** It carries the canonical Sanity Check
checklist — the Standards Guide keeps no second copy.

**Role:** this review is done by the **reasoning role** (Operating Rule 10) —
same rationale as Step 09: fresh eyes catch what the author of the FRD/TDD is least likely to see
in their own work. The reasoning role reports findings; the main role resolves them and updates
the documents.

**Outputs:** `docs/2-design/SanityCheck.md` — every check, finding, resolution.

**Exit gate:** 0 blocking issues; every gap resolved; Technical Lead sign-off — when **Approvers** is one person, one sign-off on `docs/2-design/TDD.md` and `docs/2-design/SanityCheck.md` together, covering Step 03's too. Issues found here cost hours; the same issues found during BUILD cost days (Stage↔Step Map, Stage 6). This step's usage rows, one per model, are written before this message (Operating Rule 11).

---

# PHASE: BUILD

Goal: generate AL batch by batch, lint clean — including symbol verification — as you go, without compiling per batch. The whole extension compiles and packages once the TDD's planned batches are all written (Step 07), then keeps compiling and packaging every time a fix lands, as troubleshooting against a live sandbox iterates — fix root causes, not symptoms, when that surfaces anything.

## 05 — Plan the Code

**Read `ocpfFramework/runbookSteps/05.md` in full before starting this step.** It carries the pre-flight checklist
that Steps 06 and 08–09 reuse.

**In one line:** scaffold the project structurally (`src/`, analyzer settings, `.gitignore` block,
`ocpfFramework/scripts/` — not compiled, Operating Rule 4), fetch the BCQuality snapshot and the
patterns library, write the batch plan from the TDD with every ID and file name fixed, ask once how
the batches run (all in parallel — recommended — / one at a time / ask before each), and get
**one** approval for the whole plan (Operating Rule 6).

**Outputs:** `docs/3-build/BuildPlan.md` — the ordered batch plan, written from `ocpfFramework/documentTemplates/BuildPlan.md` (batches, the objects in each with their fixed IDs and `src/` file paths, their order and why, the batch mode chosen, the approval recorded by name); project scaffold with `src/`; pre-flight validation script/checklist (both passes); `tooling.pwsh` recorded in `ocpfFramework/framework.json` when translation tooling was agreed.

**Exit gate:** Batch order and the batch mode (parallel / one at a time / ask per batch) agreed with the human; every object in the plan has its ID and its `src/` file path, and no two batches share either; scaffold is structurally complete (`app.json` fields populated, dependencies declared, `src/` and its module folders created, analyzer settings and — for AppSource — `AppSourceCop.json` in place per Ops § Analyzers — not compiled, per Operating Rule 4); pre-flight checks ready; this step's usage rows written (Operating Rule 11).

## 06 — Code Generation

**Read `ocpfFramework/runbookSteps/06.md` in full before starting this step.**

**In one line:** generate every batch exactly per the TDD — one background generator per batch in
parallel mode, the main role batch by batch otherwise — lint each batch as it returns (Operating
Rule 4), log every deviation before the next batch (Operating Rule 7), commit each batch separately.

**Role:** in **parallel mode** (the Step 05 batch-mode answer), each batch is written by a
**generator sub-agent** — the project-local `ocpf-generator`, on the Main model and effort
(§1.7), one per batch, in the background — and pre-flighted by the **light role** as it returns;
the **main role** integrates: Object Register, ChangeLog, deviations, and every fix. In sequential
mode the main role generates each batch itself and the light role pre-flights it, as before.
Whatever the mode, the generator never edits the ChangeLog, the Object Register, the TDD, or
another batch's files — it writes its batch's files under `src/`, reads its brief only, and
reports deviations and open questions back. **Full procedure: Ops § Roles → *Generation speed*
and *Parallel batches*.**

**Outputs:** Generated AL files for every batch under `src/`, each lint-clean including symbol verification; updated Object Register; ChangeLog entries for any deviation, naming the generator's model where a batch was delegated (Operating Rule 10); one commit per batch. The extension is **not** compiled as part of this step (Operating Rule 4) — that happens next, in Step 07.

**Exit gate:** Every planned object generated at the ID and `src/` path the Build Plan fixed; each batch's pre-flight (including symbol verification and permission-set coverage) was clean before it was integrated — before the next began, in sequential mode; every generator's report opened with the Main model and was checked against §1.7 (Operating Rule 10); the Object Register and ChangeLog are current for every batch. No compile is required here — Step 07 compiles next. This step's usage rows — Main, light, and generator models each on their own row — are written before this message (Operating Rule 11).

## 07 — Compile and Package, Troubleshoot, Iterate

**Read `ocpfFramework/runbookSteps/07.md` in full before starting this step.**

**In one line:** the first full compile-and-package with the analyzers, then the continuous cycle —
increment the Revision, compile, package, say "Package built:", deploy to a sandbox, test, diagnose
(check `ocpfFramework/patterns/` first), fix, repeat — until 0 errors / 0 warnings (Operating Rule
5); root-cause fixes approved together per round (Operating Rule 6); translations drafted and
reviewed inside this cycle (Ops § Translations).

**Role:** root-cause diagnosis (the three questions below)
is done by the **reasoning role** (Operating Rule 10); the main role applies the resulting fix and does the
ChangeLog/TDD bookkeeping, and is also the one who compiles, packages, and (with the human)
gets each build onto the sandbox. Same division for any bug surfaced later during PROVE-phase
testing (see Testing Feedback Log, ALL ALONG) — diagnosis is a reasoning-role task, fixing is the
main role's.

**Outputs:** All batches compiling and packaging with **0 errors, 0 warnings**; one package per build in `outputAppPackage/`, each at its own Revision, each announced with the "Package built:" block; at least one package published and manually tested on a sandbox, with "last installed version" recorded; ChangeLog current; TDD updated for every rule change; an agent-run API test result for each round, if the human opted in at the first round and a connection was available; every target translation file synced, drafted, and passing technical checks, with the glossary current.

**Exit gate:** Full extension compiles clean, with the analyzers and nothing suppressed (Ops § Analyzers); the human confirms sandbox testing is clean; no known systemic issue outstanding; `app.json`'s version equals the last package built and no two packages in `outputAppPackage/` share a version; ChangeLog and TDD reconciled (Operating Rule 5); no translation unit in any language required at first release is in `needs-translation` or `needs-adaptation`, and the technical translation checks are clean. This step's usage rows, one per model, are written before this message (Operating Rule 11).

---

# PHASE: PROVE

Goal: prove the built code matches intent, is clean, is fully documented, and has passed a human-run release test — packaging and sandbox testing are already underway by this point (Step 07) and continue throughout, not a separate milestone reserved for PROVE.

## 08 — Gap-Fit Test, Fidelity Validation

**Read `ocpfFramework/runbookSteps/08.md` in full before starting this step.**

**Role:** this three-way comparison is done by the
**reasoning role** (Operating Rule 10); the main role records the resulting classification (Intentional / Oversight /
Spec stale) in `docs/4-prove/GapAnalysis.md`.

**Outputs:** `docs/4-prove/GapAnalysis.md` — every gap, its classification, its resolution. Gap-fill work items — built with the same discipline as main batches, drawing on the growth IDs each module block reserved (Standards §5.2): pre-flighted per Step 05, then compiled, packaged, and troubleshot per Step 07's pattern, as their own pass — the Step 07 compile-and-package that closed BUILD already ran and doesn't cover code that didn't exist yet (Operating Rule 4). Ad hoc gap-fill requested mid-project, outside a formal Step 08, follows the same pattern.

**Exit gate:** Every gap classified and resolved or scheduled — a Spec-stale gap is resolved *by being recorded* in `docs/4-prove/GapAnalysis.md`, and Step 10 applies it; every code-touching resolution recompiled, repackaged at a new Revision with the "Package built:" block, and retested; no unexplained divergence from FRD/TDD. This step's usage rows, one per model, are written before this message (Operating Rule 11).

## 09 — Code Review

**Read `ocpfFramework/runbookSteps/09.md` in full before starting this step.**

**Role:** this review is done by the **reasoning role** (Operating Rule 10) —
fresh eyes matter here specifically, since the agent that wrote the code is the one least likely
to notice its own batch-to-batch drift. The reasoning role reports findings and **grades the
scorecard** — eight dimensions, A–F, one line of evidence each; the main role records the grades,
applies every fix, and normalizes whatever drift the findings call out.

**Outputs:** `docs/4-prove/CodeReview.md` — §0 Scorecard (eight grades with evidence, the overall grade as the lowest), then findings by dimension, severity, and resolution. Findings that need a code fix are presented together for one approval, the way Step 07 presents a test round's diagnoses (design-rule changes asked separately). Fixes applied at the rule level where a pattern repeats, with ChangeLog entries. Any fix that touches code follows the same Step 07 cycle — increment the Revision, recompile, repackage with the "Package built:" block, redeploy to the sandbox, retest — before this step closes (Operating Rule 4); a comment/formatting-only fix does not need a fresh package. If a finding repeats across batches and looks generalizable beyond this project — not a one-off, project-specific defect — flag it to the human as a candidate for a new entry in the OCPF BC AL Patterns Library (ALL ALONG), the same way Step 07 does; this pass, reading every batch side by side, is one of the best places in the whole routine to actually notice that shape of repetition.

**Exit gate:** All critical findings resolved; dead-code scan 100% clean across every file (Standards §1.5); no obsolete references remain; any code fix from this step has been recompiled, repackaged at a new Revision, and retested; §0 Scorecard of `docs/4-prove/CodeReview.md` carries all eight grades with their evidence lines and the overall grade, graded by the reasoning role after the fixes landed, with no **F** left unaccepted. This step's usage rows, one per model, are written before this message (Operating Rule 11).

## 10 — Update Design Documents

**Read `ocpfFramework/runbookSteps/10.md` in full before starting this step.**

**In one line:** bring the design documents up to as-built — `docs/4-prove/PostDevTDD.md` from the TDD plus
every ChangeLog and Gap Analysis outcome (every *Spec stale* classification applied), the FRD
amended where scope moved, `docs/1-define/TranslationGlossary.md` and Parameter §1.9 brought up to date.

**Outputs:** `docs/4-prove/PostDevTDD.md` (as-built reference), updated `docs/2-design/FRD.md` (new baseline). Original TDD retained as historical context; ChangeLog is the bridge between them.

**Exit gate:** As-built TDD is complete enough to regenerate the system from; FRD reflects reality. The Dev Manager's review of both happens once, at the Step 11 → Step 12 hand-off, together with Step 11's documents — not as a separate wait here. This step's usage rows, one per model, are written before this message (Operating Rule 11).

## 11 — Document the Code

**Read `ocpfFramework/runbookSteps/11.md` in full before starting this step.**

**In one line:** write the five mandatory documents — `docs/4-prove/Documentation.md`,
`docs/4-prove/UserGuide.md`, `docs/4-prove/HumanUnitTestScript.md`, `docs/4-prove/Deployment.md`,
`docs/0-project/Acknowledgements.md` — offer automated test scripts (Ops § Automated Tests), never
ship a diagram you haven't seen render, then ask whether to build the release candidate v1.0.0.0
before handing off.

**Outputs:** `docs/4-prove/Documentation.md` (consumer/API reference, includes the Mermaid schema diagram), `docs/4-prove/HumanUnitTestScript.md`, **`docs/4-prove/UserGuide.md`** (end-user, Markdown), `docs/4-prove/Deployment.md`, `docs/0-project/Acknowledgements.md`, and `docs/4-prove/AutomatedTestScripts.md` (only if the human opted in above). Five mandatory documents — check all five exist before claiming the step is complete; the sixth is conditional. The release-candidate answer recorded, and — on yes — `outputAppPackage/<Name>_1.0.0.0.app` built and announced, with its ChangeLog entry; `tooling.mermaid` recorded in `ocpfFramework/framework.json`.

**Exit gate:** Reference is generated from actual code and current, and its diagram was seen to render (or the document says it could not be checked); test script executable by a non-developer; the human has been asked about Automated Test Scripts (Ops § Automated Tests; answer recorded either way); any AL test codeunits have been run and pass, or it's recorded why they couldn't be run; `docs/0-project/Acknowledgements.md` lists every resource the project used and nothing it didn't; the release-candidate question was asked and answered, and on yes the `1.0.0.0` package exists in `outputAppPackage/`; app ready to hand to Step 12 for release testing. This step's usage rows, one per model, are written before this message (Operating Rule 11).

## 12 — Release to Users for Testing

**Read `ocpfFramework/runbookSteps/12.md` in full before starting this step.** It carries the hand-off moment, the
green-team / red-team pass, and the release gate.

**In one line:** the Dev Manager reviews the as-built documents; the human runs the release test from
`docs/4-prove/HumanUnitTestScript.md` in every required language, plus the upgrade path unless this is the
first release; results go to `docs/4-prove/ReleaseTestResults.md`; feedback is logged verbatim and triaged; fixes
continue `1.0.0.1`, `1.0.0.2` …; the package that passes ships as it is, and the production deploy
is the human's.

**Role:** this is a **main-role** step end to end — confirming the publish, coordinating the human testers, recording results in `docs/4-prove/ReleaseTestResults.md`, and triaging findings via the Testing Feedback Log. Any diagnosis a finding needs still routes to the reasoning role first, same as everywhere else (Step 07, Testing Feedback Log).

**Outputs:** `docs/4-prove/ReleaseTestResults.md` — the Dev Manager's review (who, when, findings), every test case, its result, and a link to any ChangeLog issue it produced; the name of the package that passed, stated explicitly.

**Exit gate:** The Dev Manager has reviewed `docs/4-prove/PostDevTDD.md`, the FRD baseline, and Step 11's documents (recorded in `docs/4-prove/ReleaseTestResults.md`); all green-team tests pass; all red-team tests fail gracefully; the upgrade path passes, or this is the extension's first release (Standards §9.6); permission sets verified; every translated document §1.9 requires exists and has been reviewed; every language required at first release has passed its language pass and its state scan shows every unit `signed-off` or `final` (Ops § Translations). **If everything passes, the package that was actually tested is the one deployed to the production environment, as it is** — no rename, no copy, no bump, no rebuild — and that deploy is the human's, through Extension Management, never the agent's (Ops § Packaging); say explicitly which package passed. **Before that deploy, restate the "Package built:" block for this exact package** (ALL ALONG → Packaging & Versioning), its schema line judged against the last version installed in production — **Add** if this release is additive-only, **Force Sync** with the explicit data-loss warning if anything was removed, shrunk, retyped, or re-keyed since that release. `ProjectProgress.md`'s Step 12 row is `Completed`, its usage rows are written (Operating Rule 11), and the calibration file is exported to `~/.ocpf/calibration/` — by the agent if brought back in, by hand otherwise.

---

# ALL ALONG — Continuous Discipline (every phase, every step)

Run these in parallel with the phased work — they are not a final step.

**Each section below carries its non-negotiables and points at the Operations Guide for the
procedure.** Read the named **Ops §** section at the step that needs it.

## Document

- Keep every required project document current as work proceeds, not retroactively — this list is canonical; the Standards Guide keeps no second copy of it: `ProblemStatement`, `ProjectParameters`, `FRD`, `TDD`, `SanityCheck`, `HumanEffortEstimate`, `AiEffortEstimate`, `BuildPlan`, `PostDevTDD`, `ChangeLog`, `GapAnalysis` / `CodeReview`, `Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`, `Acknowledgements`, `AutomatedTestScripts` (if created), `ReleaseTestResults`, `TestingFeedback`, `Roadmap`, `ProjectMemory`, `ProjectProgress`, `TranslationGlossary` (unless Parameter §1.9 chose *US wording, no translation files*) — all five mandatory Step 11 outputs (`Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`, `Acknowledgements`) belong on this list, not just the first of them, as does `AutomatedTestScripts` if the human opted in at Step 11, and `ReleaseTestResults` (Step 12). `ProjectParameters` is produced at Step 01, right after `ProblemStatement` — it is the one entry on this list a project cannot proceed without, since every other document and every AL file derives its identity from it. **Every one of these lives in its `docs/` phase subfolder** (Operating Rule 9 has the layout) — the only document outside it is `ProjectProgress.md`, below.
- **Write every document from its template** in `ocpfFramework/documentTemplates/` (Ops § Documents) — the
  template fixes the headings and the checks; the step file says what goes in them. The Human
  Effort Estimate is written at Step 03 in the same pass as the TDD, for an experienced senior AL
  developer doing the same work, against the baselines in
  `ocpfFramework/documentTemplates/HumanEffortBaselines.md` — or the partner's own calibration
  file at `~/.ocpf/HumanEffortBaselines.md` when one exists — and is read next to the measured AI
  cost (ALL ALONG → Usage & Cost Tracking). The **AI Effort Estimate** (`docs/2-design/AiEffortEstimate.md`)
  is written in the same pass by the main role: tokens per step, model, and token type, cost at
  the fetched prices, and a wall-clock estimate from BUILD on that counts every approval at 30
  minutes; its margin is ±30 % until three measured projects sit in `~/.ocpf/calibration/`.
- Maintain the **Object Register** as a standalone artifact, `docs/1-define/ObjectRegister.md` — every object, its ID, module, source table, and R/W status — updated as objects are planned and built. Never use an object ID outside the ranges allocated at Parameter 1.2; the allocation strategy the register records is Standards Part 5.

## Track Changes — the ChangeLog

Every deviation from FRD or TDD — human or agent — is logged **before the next batch begins**. It is the ground truth for what was actually built and why. Entry format (canonical — the Standards Guide keeps no second copy):

```
## Issue <BatchID>-<SeqNo> — <Short Description>
**Problem:** What was wrong or missing.
**Root cause:** Why it happened.
**Resolution:** What was changed.
**Files affected:** List of changed files or template rules.
**Updated:** TDD, FRD, or both — yes/no.
```

**Name the person, not a role.** When a decision, a "hold off," or a preference is attributed to a human, write their actual name ("AJ decided X") — never a generic placeholder like "the human" or "the user." A role-noun silently assumes exactly one person exists on the project; the moment there's a second contributor, "the human decided X" stops answering the only question that phrase exists to answer — decided by *whom*. This applies throughout the TDD, FRD, and ChangeLog, not just here.

## Retain Explanations

- When the agent flags something (an obsolete field, an ambiguous name, a scope question), record the flag, **who** decided and what they decided, and the reasoning — not just the outcome.
- Every root-cause fix records the diagnosis, not only the patch, so the same class of error cannot recur in a later batch.
- Commit each batch to version control separately, before the next begins, with a message that references its ChangeLog entries.

## Testing Feedback Log

Human testing and review surfaces real feedback from Step 07 onward — sandbox testing is already
mandatory there, in BUILD, not something that waits for PROVE — and continues throughout PROVE
(and sometimes earlier still, on a demo). It's a list of things to change, in the tester's own
words, not yet triaged into decisions.
This is distinct from both of the above: the ChangeLog records *decisions and reasoning*; the
Step 12 test-run record (`docs/4-prove/ReleaseTestResults.md`) captures the human-run green-team/red-team
pass/fail (with an earlier, optional agent-run pass at Step 07 if the human opted in there and a route was
available there). Neither preserves what the human actually said before it becomes a summary of
what the human said.

- Record every testing/feedback session in `docs/0-project/TestingFeedback.md` — date, what was tested, and the
  tester's findings/requests **verbatim**, before they are triaged.
- Triage each item explicitly: implement now (its own ChangeLog Issue), schedule for later
  (`docs/0-project/Roadmap.md`), or reject (record why, in the same log).
- **Link it one way:** each ChangeLog Issue or `docs/0-project/Roadmap.md` item names the `docs/0-project/TestingFeedback.md`
  entry it came from. The raw ask stays traceable to its decision without writing the same finding
  three times with back-links in both directions; a search finds the reverse.
- **Role (§1.7):** diagnosing *why* a reported bug happens is a **reasoning-role** task, same as
  Step 07 — including Step 07's own first move: **check `ocpfFramework/patterns/` (ALL ALONG → OCPF BC AL
  Patterns Library) for an already-documented match before diagnosing from scratch.** The **main
  role** applies the fix once the diagnosis is confirmed, and separately owns
  the triage act itself — recording the implement/schedule/reject decision in `docs/0-project/TestingFeedback.md`.
  The ChangeLog Issue or Roadmap item names this entry (above); the feedback entry carries no
  back-link. Don't skip straight to a patch on
  a guess — this is exactly where a wrong first diagnosis is cheapest to catch, and a wrong one
  should stay in the log marked superseded, not be quietly deleted, the same as any other
  ChangeLog correction.

## Project Memory — `docs/0-project/ProjectMemory.md` (required, in-repo)

Continuity must not depend on which agent, machine, or tool picks the project up next.
`docs/0-project/ProjectMemory.md` is a required project artifact, committed to version control like every
other document here — **not** an agent's own external/cross-session memory feature, which is
tied to one machine's file path and invisible to git, to a teammate, and to any other tool or
agent that opens this repo.

- **Keep it short — an anchor, not a narrative.** Where each live document lives, any decision
  awaiting sign-off, and a one-line pointer per past milestone. **It doesn't carry the current
  step:** `ProjectProgress.md` owns that, and this file points at it, so there's no second copy to
  keep in sync. The full story of *why* a decision was made belongs in `docs/0-project/ChangeLog.md`;
  `docs/0-project/ProjectMemory.md` just says *where to look*. If it starts reading like a second ChangeLog, trim it.
- **Every row in "Open decisions" names who it's awaiting** — `(awaiting: <name>)`. This is not
  redundant with `git blame`: blame tells you who last edited the line, not who the project is
  actually waiting on for a forward-looking decision. With a single contributor every row will
  say the same name — write it anyway, so the convention is already in place the day a second
  person joins.
- **Keep a "Standing preferences" list** — the things this human has said once and shouldn't be
  asked again: how they want to be notified, whose sign-off a given decision needs, a house naming
  habit, a tool they don't want used. Each row records the preference, the date, and who gave it.
  Without this, every preference expressed mid-project is lost at the next session boundary and
  the human is asked a second time — which is how a framework that asks well starts to feel like
  one that nags. A preference that contradicts a Project Parameter doesn't override it: raise the
  conflict.
- Update it at the close of every step or batch, the same moment the ChangeLog gets its entry, and whenever a document moves, a decision opens or closes, or a milestone lands.
- If the executing agent *also* has its own persistent cross-session memory capability, that
  memory may point at `docs/0-project/ProjectMemory.md` (e.g. "always read this file first") but must not
  duplicate its content. A fact that lives only in an agent's private memory and nowhere in
  `docs/0-project/ProjectMemory.md` or the other project documents does not count as recorded — the file
  in the repo is the one a different agent, a teammate, or a fresh clone can actually read.

## Project Progress Tracker — `ProjectProgress.md` (required, in-repo, **project root**)

No mechanism available to any agent running this framework writes to a persistent UI element
outside its own conversation (no status bar, no external dashboard); even where a specific
harness *does* expose something like that, it wouldn't travel with the repo the way a file does.
`ProjectProgress.md` is the durable, host-agnostic substitute — the same reasoning that already
justifies `docs/0-project/ProjectMemory.md` existing instead of relying on an agent's own non-shared cross-session
memory (previous section).

**Lives in the project root, always — not `docs/`.** Every other required document in this list lives under `docs/`; this one is
deliberately the exception, so it's the first thing visible on opening the repo, no navigation
needed — that's the whole point of it being a fast, at-a-glance status check. **Both editions keep
one:** since Lite 5.0.0.0 a Lite project has the same file, from the same template (the template
carries a step table per edition; keep yours, delete the other), so a `status` check or a usage
refresh reads the same place whichever edition built the project.

This is **not** a narrative document and must not become one — that is exactly what
`docs/0-project/ProjectMemory.md` is already for. It is **two tables, nothing else**: the step table below,
and beneath it the usage table (ALL ALONG → Usage & Cost Tracking), refreshed at every exit gate.

| Phase | Step | Status |
|---|---|---|
| DEFINE | PRE-01 — State the Problem | *(blank / `In Progress` / `Completed`)* |
| … | *(one row per step, PRE-01 through 12 — the full routine, not only the numbered steps)* | |

- **Create it as the very first artifact of the whole routine** — the moment PRE-01 begins, before
  `docs/1-define/ProblemStatement.md` itself is even finished — with every row blank except PRE-01, marked
  `In Progress`. A project that already has `docs/0-project/ProjectMemory.md` but no `ProjectProgress.md` (e.g.
  one that adopts this framework version mid-project) gets one backfilled from the ChangeLog the
  next time any step closes.
- **This file is the only record of which step is current.** Update it when a step starts and when
  its exit gate is met — and at the same moment append the step's start or completion timestamp to
  `ocpfFramework/state/usage.json` and, at the close, write the step's usage rows (Operating Rule
  11; ALL ALONG → Usage & Cost Tracking), so the usage table can attribute what was
  spent to the step it was spent on. `docs/0-project/ProjectMemory.md` points here rather than repeating it.
- Leave a step's row blank until it actually starts; don't pre-fill future steps as blank
  placeholders with any other text, and don't mark a step `Completed` before its own exit gate is
  actually met (that step's own **Exit gate** line — in its step file, copied verbatim into the
  stub above — is the test, not "the agent moved on").
- Close the file with the same standing note every project ships it with: that asking, in plain
  language, **"Where are we in the process? What's next?"** always gets a direct answer from this
  file (plus `docs/0-project/ProjectMemory.md` and `docs/0-project/ChangeLog.md` for the reasoning behind it) — whether or not
  an agent session happens to be running at that exact moment.
- **While a step is actively `In Progress` and the agent is doing multi-part work within it**
  (e.g. applying a dozen Code Review findings), narrate a live plan in the conversation itself —
  what's planned, what's done, what's left — as ordinary text; no tool or file update is needed
  for this finer-grained, in-session view. `ProjectProgress.md` tracks step-level status only,
  never sub-step task lists.

## Usage & Cost Tracking — `ProjectProgress.md`, second table

**Full procedure: Ops § Usage & Cost.** Read it at PRE-01 (when the timestamps start) and at every
exit gate (when the table is refreshed). In a plugin project the `usage` skill (`/ocpf-bc:usage
--step <id>`) does the measuring. **Both editions keep the table in `ProjectProgress.md`** — Lite
no longer has a separate usage report.

- **The step boundary ritual is Operating Rule 11** (Ops § Usage & Cost → 5): at the start,
  append the step's `startedAt` to `ocpfFramework/state/usage.json` and set its row to `In
  Progress`; at the close, before the exit-gate message, set `completedAt`, measure, write the
  rows, and paste them into the closing message. **One row per model that ran in the step** — the
  Main model and every sub-agent model (light, reasoning, generator) — never one row per step. The
  exit gate is not met until the rows exist, and a row is never hand-written.
- **Every step start and every exit gate is timestamped** in `ocpfFramework/state/usage.json` — the same moment
  `ProjectProgress.md` changes. Without the timestamps nothing can be attributed to a step.
- **Measured, never estimated.** In Claude Code the per-request usage — input, output, cache-write,
  and cache-read tokens, per model, sub-agents included — is read from the session transcripts the
  tool writes on disk (Ops § Usage & Cost names the path). **GitHub Copilot bills in AI credits**,
  and VS Code records them per turn and per model, sub-agents included, in the chat session files
  it keeps on disk: the usage table reads those, and is a **different table** — AI credits and
  cost per model, no token columns, because Copilot Chat records no token totals by type. If the
  session files can't be read, the human reads *Session Cost* in the Session Info popover and the
  script records that one number. Never invent a token figure, and never convert credits to
  tokens.
- **Cost uses published prices, fetched, dated, and cited** — the publisher's own pricing page (or
  Ollama's for its cloud models; local Ollama models cost `$0`), stored in `ocpfFramework/state/pricing.json` with
  the source URL and the date read. Prices are never hardcoded in the runbook or the skill.
- **Refresh the second table of `ProjectProgress.md` at every exit gate:** one row per step and
  model — input, output, cache write, cache read, cost, elapsed time, turns, human decisions asked,
  sub-agent calls (web requests noted) — with the human effort estimate (`docs/2-design/HumanEffortEstimate.md`, Step 03)
  and the AI effort estimate (`docs/2-design/AiEffortEstimate.md`) alongside once they exist, so the
  AI cost of a step can be read next to the hours a senior AL developer would bill and next to what
  was predicted.
- **Say what couldn't be measured.** A step worked in a tool that exposes no usage gets `n/a` and
  the reason, not a blank and not a guess.
- **At project close (Step 12), the `usage` skill also exports the calibration file** —
  `~/.ocpf/calibration/<project>-<date>.json`: per step and model, tokens by type, elapsed, turns,
  decisions, and the object counts by type — outside every project, so the next project's AI
  Effort Estimate reads measured averages instead of the template's placeholders.

## Translations & Terminology

**Full procedure: Ops § Translations** — the glossary, the translation cycle inside Step 07, review
and approval, and the release gate. Read it at Step 01 §1.9, at Step 07's first full build, and at
Step 12's gate. Everything here is skipped for a project whose §1.9 chose *US wording, no
translation files*, except Operating Rule 8 and Standards §1.7.

- **The glossary is `docs/1-define/TranslationGlossary.md`**, created at Step 01 and filled only by Standards
  Appendix D, never from model memory.
- **The agent drafts; a named human approves.** Drafts are `needs-review-translation`; only the
  language's reviewer approves, and every approval is logged in the ChangeLog by name (Standards
  §8.7).
- **The release gate at Step 12 is a plain state scan:** every unit in every language required at
  first release is `signed-off` or `final`. A tool's own check never stands in for it.
- **Changed source text invalidates approval** — affected units go back through drafting and review,
  even for a one-word fix.
- **Roles (§1.7):** terminology verification is the light role's, drafting the main role's;
  approving is never an AI role's.

## Packaging & Versioning

**Full procedure: Ops § Packaging, including its *Version numbers* subsection.** Read it at Step
07's first package, and again at the Step 11 release-candidate question. The non-negotiables:

- **Name and location are fixed:** `<ExtensionName, spaces → underscores>_<version>.app` in
  **`outputAppPackage/`** in the project root, with `name` and `version` read from `app.json` at
  build time. Say the folder once at intake, and the exact path every time a build completes.
- **Built packages are git-tracked, never gitignored.** No `outputAppPackage/` or blanket `*.app`
  entry in `.gitignore`.
- **The agent never publishes to a production environment.** Before every publish, state the target
  environment and type; if it isn't a sandbox, stop and ask. Never force a destructive schema change
  (`ForceSync`, `Recreate`, `forceUpgrade`) without a separate approval naming what can be lost. The
  production deploy at Step 12 is the human's, through Extension Management (Ops § Packaging).
- **Version numbers.** A **new app** starts at `0.0.0.1` (the Step 01 parameter default). An
  **existing app** starts from the version installed in the target environment (asked at intake,
  confirmed on the Extension Management page) and continues from it. **The first build of a new
  app is `0.0.0.1` as written; an existing app's first build increments from the installed
  version; every build after the first increments the fourth segment (Revision) in `app.json`
  first — mechanical, no approval** — then build (the test is in Ops § Packaging → *Version
  numbers*). **Never build twice at one version.** If
  `outputAppPackage/<Name>_<version>.app` already exists, increment again; the framework's
  `al-analyze` scripts refuse to overwrite an existing output file (exit code 4, naming the file).
  Why: testers upload packages as PTEs through Extension Management, and a version already
  installed can never be uploaded again.
- **Major, Minor, and Build bumps are proposed and approved (Rule 6a), never a silent `app.json`
  edit**, with the reasoning stated. Push back on a bump that doesn't match what changed. The
  Revision increment is the one exception: it happens on every build without asking.
- **Never delete or overwrite a package. NEVER.** No `rm`, no tidying, not even before a build.
  Every build has its own version, so every package has its own file; there is no legitimate
  overwrite any more.
- **The release candidate is asked for, once, at the end of Step 11** (Rule 6a): *build v1.0.0.0
  now (recommended)* / *keep testing on 0.x builds*. Fixes during release testing continue
  `1.0.0.1`, `1.0.0.2` …, and **the package that passes Step 12 ships as it is** — no rename, no
  copy, no bump after the fact; say explicitly which package passed. For an existing app the
  release candidate is the next Minor (or Major) from the starting version, proposed.
- **After every build, the fixed message, on its own lines** (Steps 06–12):

  ```
  Package built: outputAppPackage/<Name>_<version>.app (previous build <version-1>)
  Schema: additive only → upload with Schema Sync Mode = Add
     or: <what was removed / shrunk / retyped / re-keyed> → upload with Schema Sync Mode = Force Sync
         (Microsoft: test a forced sync in a sandbox first; it can lose data in <where>)
  Upload: Extension Management → Manage → Upload Extension, choose the file, set Schema Sync Mode, Deploy.
  ```

  The schema line compares the objects against the **last package installed in a tenant** — the
  main role records "last installed version" in `docs/0-project/ProjectMemory.md` and the ChangeLog
  each time the human confirms an upload.

## Repository Hygiene — What Stays Out of the Project's Remote

**Full procedure: Ops § Repository Hygiene.** Read it at §1.8, at §1.10, and at Step 05's scaffold.

**The `.gitignore` block is two groups, and Ops § Repository Hygiene has the exact text to paste.**

**Group one — always kept out of git tracking, not a per-project choice:** `.claude/settings.local.json`,
`ocpfFramework/state/` (every developer's own `usage.json`, `pricing.json`, `notifications.json`,
`copilot.json`, `previous/`), `ocpfFramework/standardsGuide/`, `ocpfFramework/opsGuide/`,
`ocpfFramework/runbookSteps/`, `ocpfFramework/documentTemplates/`, `ocpfFramework/patterns/`,
`ocpfFramework/scripts/`, `.alpackages/`, `*.g.xlf`, and Microsoft's translation files. The BCQuality snapshot
lives outside the project root entirely, so there's nothing to ignore.

**Never ignored:** `docs/`, `requirements/`, `src/`, `ProjectProgress.md`, `Translations/*.xlf`,
`*.app`, and every package in `outputAppPackage/`.

**Group two — gitignored by default, with the §1.8 intake question — by exact path, every one:**
the whole `ocpfFramework/` folder (which now holds the changelog, the schematics, and the runbook
when `CLAUDE.md` already existed), this runbook under whatever name it was placed (`CLAUDE.md`,
`.github/copilot-instructions.md`, `.github/instructions/ocpf-framework.instructions.md`), and the
three project-local sub-agent definitions (`.claude/agents/ocpf-light.md`, `ocpf-reasoning.md`,
`ocpf-generator.md`; `.github/agents/ocpf-*.agent.md`). With the intake answer *No, track them*,
only group one is written. **Verify with `git check-ignore -v` on each file that exists** — an
entry that isn't there, or doesn't match, is found by that command, not by re-reading `.gitignore`.

**If any of this is already tracked,** add the entry, then untrack with `git rm --cached` (the files
stay on disk) — and check for a remote first, since collaborators will see the files as deleted.

## AL MCP Server

**Full procedure: Ops § AL Tools.** Read it at §1.10, the first time the tools are needed.

- The AL Language extension provides the tools with **nothing to install**: built into GitHub
  Copilot Chat, and as its bundled AL MCP Server for Claude Code, Copilot CLI, or any other MCP
  host. With the OCPF plugin, `al-mcp-setup` does the bootstrap in one step.
- **The human only approves the AI tool's own prompts.** The extension has no Command Palette
  command for this, and no third-party bridge extension is ever installed or used.
- A server registered mid-session appears only in the next session; until then, use the one-shot
  helper rather than stopping or asking for a restart.
- Prefer the MCP build/publish/symbol tools over ad hoc terminal calls — except the analysis
  compile (ALL ALONG → Analyzers).

## Analyzers

**Full procedure: Ops § Analyzers.** Read it at Step 05, when the analyzer settings are scaffolded,
and at Step 07's compile.

- The mandatory compile runs with **CodeCop**, **UICop**, and exactly one of
  **PerTenantExtensionCop** (SaaS/OnPrem PTE) or **AppSourceCop** (AppSource) — never both.
- `.vscode/settings.json` (and `AppSourceCop.json` for AppSource) is created at Step 05's scaffold
  (`ocpfFramework/runbookSteps/05.md`); a Copilot request-limit key written at PRE-01 is merged, never overwritten.
- Outside GitHub Copilot Chat, run `ocpfFramework/scripts/al-analyze.*`. The AL MCP Server's `al_build` never
  applies analyzers (observed on AL extension 18.0.2732683; re-verify on a newer release), and its
  `al_compile` only does so with one exact argument shape — anything
  else returns a clean pass on failing code (**Ops § Analyzers**). Never treat an `al_compile`
  result as the mandatory compile: it produces no `.app`.
- **Read the warnings, not just the result.** The compiler succeeds with warnings; `al-analyze`
  exits `3` on them. Any warning fails Operating Rule 5.
- **Zero warnings means zero:** no `#pragma warning disable`, and the framework ships no ruleset.

## Symbols

**Full procedure: Ops § Symbols.** Read it at §1.10, and again after any dependency or version
change.

- **The agent downloads symbols; the human never does.** Global sources need no sign-in; a sandbox
  download (one browser sign-in) covers non-AppSource dependencies and localized projects.
- The AL MCP Server's global download is **W1 only**.
- **Confirm symbols by using them** — a symbol search or a compile — never by unpacking
  `SymbolReference.json`.
- Sandbox-downloaded packages carry Microsoft's own source and translation files: read them, never
  commit them (Standards §8.5).

## Keeping the Editor in Sync

**Full procedure: Ops § Editor Sync.** Read it at §1.10 and after every clean compile.

- The symptom is red marks in VS Code that the latest compile didn't report — usually after
  `app.json` changed on disk or symbols were downloaded outside VS Code.
- **Detect** it by reading the Problems panel (`al_getdiagnostics`, or the IDE diagnostics tool);
  **fix** it by re-downloading symbols in Copilot Chat, or by asking the human, at the end of the
  reply, to run **Developer: Reload Window**.
- **Never change code that compiles clean just to clear stale marks.**

## Notifications — Tell the Human When It's Their Turn

**Full procedure: Ops § Notifications.** Read it at PRE-01, right after the working language.

- **Ask once, as one multi-select question:** *Claude app*, *Sound*, *Desktop notification*, any
  combination, or *No notifications* — offering only what works for this AI tool, operating system,
  and sign-in.
- **Record the answer in `ocpfFramework/state/notifications.json`** — per developer, always gitignored — and read
  it at the start of every session. Ask again when it's missing.
- **Apply it** through each tool's own notifications and hooks, never a script-raised banner on
  macOS. With *Claude app*, explain Remote Control and what it stores before turning it on, and end
  every turn that hands the ball back with a short push.
- **Test once**, and fix or drop whatever didn't arrive.

## OCPF AL Development Standards Guide

The companion rules document — `ocpfALDevStandardsGuide.md`, v1.11.0.0 — holds the AL rules this
runbook cites as **Standards §**, from PRE-02 onward. Its sibling, the **Operations Guide**
(`ocpfOperationsGuide.md`, v5.1.0.0), holds the procedures, cited as **Ops §**.

**Fetch both at PRE-01, before anything else needs them** — `ocpfFramework/standardsGuide/` and `ocpfFramework/opsGuide/` in
this project's root, both always gitignored — **and, in the same fetch, this runbook's step files
into `ocpfFramework/runbookSteps/` and the document templates into `ocpfFramework/documentTemplates/`**, from `fullVersion/steps/`
and `documentTemplates/` in the framework repository, both always gitignored too. A step file whose
`**Runbook version:**` line doesn't match this runbook's version is skew: say so and refetch. **Full procedure: Ops § Fetched Companions**, which
also covers refreshes, the plugin's offline copies, and what to do when GitHub is unreachable.

**Neither is optional.** A missing copy is a real gap, not a degraded-but-workable state: say so
and ask the human for a copy rather than working from memory of what a rule says. **Version skew is
named, not papered over** — both carry their own version, tracked in `ocpfFramework/RunbookChangelog.md`.

## Reference Sources — Microsoft Learn and AL Guidelines

**The list, with what each is for: Ops § Reference Sources.** Microsoft Learn's Base Application
and System Application references, the translation-files and country/language pages, Microsoft's
terminology collection and style guides, and AL Guidelines. None are fetched; all are consulted
online.

- **Symbols first, Learn only when necessary (Operating Rule 2).** The downloaded symbols are the
  only routine lookup. The Base Application and System Application references are consulted
  **only** when symbols could not be downloaded, when the object, field, method, or event isn't in
  them, or when the task needs a code pattern, a snippet, or an event's signature to subscribe to
  it — never as a second check on something the symbols already answered, never "to be safe", and
  always with a stated reason when it happens. The other Learn pages the framework reads live
  (countries and languages, the runtime table, the translation pages) are unaffected.
- **Precedence:** downloaded symbols beat Microsoft Learn on anything symbol-verifiable; the
  Standards Guide beats AL Guidelines on any AL rule. Surface a conflict rather than reconciling it
  silently.
- **If the agent has no web access, say so** rather than answering from memory of a reference.

## Tooling Checks — Node, mermaid, PowerShell

**Full procedure: Ops § Tooling Checks.** Read it at Step 05 (translation tooling, PowerShell) and
at Step 11 (the mermaid renderer), and whenever a script needs `pwsh`.

- **Same zero-install ladder as Rule 6d:** what's already there first, then an install offered
  under Rule 6b, per OS, never applied without a yes.
- **Mermaid:** `node --version`, then `npx --yes @mermaid-js/mermaid-cli --version` — never
  `which mmdc`; an npx-cached package is never on `PATH`, which is the false "not installed" a real
  project hit.
- **PowerShell 7 (`pwsh`):** needed by the XLIFF Sync module and the usage script's `.ps1` port;
  recommended, not required, by BCQuality. The framework's own `.ps1` helpers run on Windows
  PowerShell 5.1.
- **Record the outcome** in `ocpfFramework/framework.json` → `"tooling"` (`mermaid`, `pwsh`), so
  the check isn't repeated every session and the `status` skill can report it.

## BCQuality Knowledge Snapshot

**Full procedure: Ops § Fetched Companions.** Read it at Step 05, when the snapshot is fetched, and
at Step 09, when it's used.

- A curated third-party knowledge base for BC AL code quality, fetched once per project at Step 05
  and refreshed only when the human asks.
- **It lives outside the AL project's root** — `alc` would otherwise try to compile its illustrative
  snippets — so there's nothing to gitignore.
- At Step 09 it's an independent review pass whose findings are integrated like any other, never
  applied blind.

## OCPF BC AL Patterns Library

**Full procedure: Ops § Fetched Companions.** Read it at Step 05, when the library is fetched.

- The human's own cross-project collection of BC AL patterns, each from a real bug found and fixed:
  fetched once into `ocpfFramework/patterns/` inside the project root, always gitignored, refreshed only on
  request, and merged rather than overwritten.
- **Using it — before writing, and before diagnosing.** At Step 06, before generating any child list
  or list part, setup page, or wizard, read Standards Part 11 and the matching pattern files; the
  batch plan (Step 05) names which batches this applies to. At Step 07, and for any testing-feedback
  report during PROVE, check whether `ocpfFramework/patterns/` already documents this class of problem before
  diagnosing from scratch.
- A fix that looks likely to recur on future projects is a candidate for a new pattern — flag it to
  the human rather than adding one unilaterally.

## OCPF Plugin (Optional)

**Full procedure: Ops § Plugin.** Read it at the start of a session in a plugin-installed project.

**This section applies only when `ocpfFramework/framework.json` exists** — the plugin's `start`
skill creates it (its `layout` field says `ocpfFramework-1`; its `tooling` field is ALL ALONG →
Tooling Checks). Without that file, skip it entirely.

- **Once per session,** compare the project's `runbookVersion` against the latest published runbook
  and offer **Update now / Not now / Skip this version**. Never replace the project's runbook
  without an explicit yes. On a project set up before 5.0.0.0, the `update-framework` skill also
  moves the files into the `ocpfFramework/` and `docs/<n>-<phase>/` layout and logs every move.
- **What the plugin adds:** offline copies of the runbooks and both companions, one-step AL tool
  setup, notification setup, the `ocpf-light`, `ocpf-reasoning`, and `ocpf-generator` sub-agents
  as the templates for §1.7's project-local definitions (the plugin's own copies carry **no
  model** — they'd inherit the session's; Ops § Roles → *Enforcement* says how the project's
  copies get one; the generator runs on the Main model and effort, no extra question), and the
  `status`, `al-standards`, `notifications`, `roles`, `documents` (writes any project document
  from its template, both effort estimates and the Acknowledgements included), and `usage`
  (measures tokens and cost per step and model, refreshes the usage table, and exports the
  calibration file at close) skills.
- **Optional github.com reviewer:** offer `ocpf-code-reviewer` once at Step 09 if the project is on
  GitHub and the team uses Copilot; its report is a Step 09 input like any other.

## Stage ↔ Step Map

The classic ten-stage BC development model, mapped onto this runbook's steps. Several exit gates
above cite it as **Stage↔Step Map, Stage N**. It is kept here, in the runbook, for teams and
documents that still speak in those stage numbers — the Standards Guide no longer carries a copy
of the lifecycle, since the phase/step sequence is the runbook's own concern.

| Stage | This runbook step |
|---|---|
| 1 — Problem Space | PRE-01 |
| 2 — Gap Analysis | PRE-02 |
| 3 — Architecture | 01 (parameters) + 03 (module grouping, ID allocation, phase plan) |
| 4 — FRD | 02 |
| 5 — TDD | 03 |
| 6 — SanityCheck | 04 |
| 7 — Implementation | 05 + 06 + 07 (07 also carries the first compile-and-package cycle and its optional API test pass — see Operating Rule 4) |
| 8 — Code Review | 08 + 09 |
| 9 — Documentation | 10 + 11 |
| 10 — Deployment | 12 (sandbox, human-run release test) → production deploy of that same package, per `docs/4-prove/Deployment.md` |

---

*Routine created by AJ Ansari, Microsoft MVP, OnlyCopilotFans. Update this runbook when the framework or the standards change.*

