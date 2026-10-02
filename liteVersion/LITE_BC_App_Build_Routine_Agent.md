# BC App Build Routine — Lite Agent Runbook

## OnlyCopilotFans Agentic Dev Framework — Lite Edition

**Version:** 5.1.0.0 (Lite, derived from the full framework v5.1.0.0 — from this release the Full and Lite runbooks, the Operations Guide, and the plugin share one version number)
**Last Updated:** October 1, 2026

> Version history for this edition lives in `ocpfFramework/LITE_RunbookChangeLog.md`, tracked
> independently of the full framework's own `fullVersion/RunbookChangelog.md` (though a change to
> one often has to be reflected in the other) and of any one project built with it. Diagrams for
> this routine live in `ocpfFramework/LITE_RunbookSchematics.md`. If either file is not found,
> create it. Everything the framework fetches or keeps lives under `ocpfFramework/` in the project
> root (Ops § Project Setup has the layout and the six-line `ocpfFramework/README.md`).

> This is the lightweight sibling of the full **OCPF BC Agentic Development Framework**
> (`fullVersion/BC_App_Build_Routine_Agent.md`, in the same repo). Same author, same underlying
> discipline — half the steps, one model doing all the work, and no ceremony that a
> 10-files-or-fewer project doesn't need.

> **Companion documents, both fetched at Step 1 and shared unchanged with the full framework:**
> - `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md` — the **OCPF AL Development Standards Guide**
>   (v1.11.0.0), cited as **Standards §**. Lite is *not* a reduced set of AL rules: the same rules
>   apply to a 5-file extension as to a 50-file one. What Lite reduces is *process*.
> - `ocpfFramework/opsGuide/ocpfOperationsGuide.md` — the **OCPF Operations Guide** (v5.1.0.0), cited as
>   **Ops §**: the procedures this routine uses — asking, intake, project setup, AL tools,
>   tooling checks, analyzers, symbols, editor sync, notifications, packaging, repository hygiene,
>   translations, fetched companions, documents, usage and cost, and the plugin.
> - `ocpfFramework/runbookSteps/` — **this runbook's step files**, one per step (`STEP-1.md` … `STEP-7.md`),
>   fetched from `liteVersion/steps/` at Step 1 alongside the guides. **The step sections below are
>   stubs; the step file is the step.** Read it in full the moment the step starts, never from the
>   stub or from memory.
> - `ocpfFramework/documentTemplates/` — one template per document (Design Doc, Human Effort Estimate
>   with its Baselines, AI Effort Estimate, ChangeLog, Docs, Test Script, Project Progress,
>   Acknowledgements — the full set is Ops § Fetched Companions), fetched with the step files;
>   every document is written from its template (Ops § Documents).
>
> **Read an Ops § section at the step that names it**, in that step's Actions or its exit gate —
> not the whole guide at once, and never from memory of a section you haven't opened here. This
> runbook states each rule in short form where you need it and cites the guides for the full
> version.
>
> **When to use Lite:** a Business Central AL Per-Tenant Extension with **10 or fewer AL files** —
> typically a handful of API pages over standard tables, maybe one or two new tables, a single
> developer or functional consultant driving it, one AI model doing the work. **Graduate to the full
> framework** the moment any of these stops being true: the object count grows past ~10, the project
> needs multiple sign-off roles (Dev Manager, Technical Lead, Functional Consultant as separate
> people), you want to split work across more than one AI model, or the extension is heading to
> AppSource, which tends to demand the fuller documentation trail. Nothing is lost by switching
> later — Lite's Design Doc and ChangeLog map directly onto the full framework's TDD and ChangeLog.
>
> **How the agent uses it:** work the phases in order (DEFINE → DESIGN → BUILD → PROVE). Don't
> start a step until its predecessor's exit gate is met. The *Project Parameters* block in Step 1
> is the single source of truth for every name, ID, version, and quoting decision — never hardcode
> any of those values in AL; always derive them from that block. It is persisted as
> `docs/1-define/ProjectParameters.md`, not just discussed — every later step reads it from
> that file. At the start of every session, read `ocpfFramework/state/notifications.json` and keep notifying the
> human the way it says; if it's missing, ask how they want to be notified (ALL ALONG →
> Notifications).
>
> **One model does everything.** Lite drops the full framework's Main/Light/Reasoning role split.
> There's no delegation to configure — the executing agent plans, generates, reviews, and documents,
> in that order, within each step. Step 1 still asks which model and thinking effort that one
> agent runs on, and confirms the session matches (Ops § Roles). The one exception is speed, not
> judgment: with two batches, Step 4 may run one background **generator** sub-agent per batch, on
> that same model and effort (ALL ALONG → OCPF Plugin; Ops § Roles → *Parallel batches*).
>
> **Every project document lives in `docs/`, by phase.** Created at Step 1, before the first
> document is written, with these subfolders — the same five as Full; Lite writes nothing into `3-build/`:
>
> ```
> docs/
>   0-project/   ChangeLog.md  Acknowledgements.md
>   1-define/    ProblemStatement.md  ProjectParameters.md
>   2-design/    DesignDoc.md  HumanEffortEstimate.md  AiEffortEstimate.md
>   4-prove/     Docs.md  TestScript.md  and translated copies beside their source
>                (Docs.fr-CA.md, TestScript.fr-CA.md)
> ```
>
> Of the routine's own outputs, only `requirements/`, `app.json`, `src/` (all AL source; the app
> icon in `src/logo/`), `Translations/`, `outputAppPackage/`, `ProjectProgress.md` (deliberately at
> the root — ALL ALONG → Project Progress Tracker), and `ocpfFramework/` stay in the project root.
> Every step names its documents with the `docs/` prefix; a bare name still means the `docs/`
> path. At every exit gate, list the root: a document sitting there is moved with `git mv` and the
> move noted in `docs/0-project/ChangeLog.md`. On a real project the design documents landed in the
> root because the steps named files without their folder.
>
> **Prime directive:** an ambiguous input produces ambiguous code. If a step's inputs are
> incomplete or contradictory, stop and ask the human — do not invent rules to fill the gap.
>
> **Installed by the OCPF plugin?** If this project has a `ocpfFramework/framework.json` file, it was set
> up by the OnlyCopilotFans agent plugin. Read ALL ALONG → OCPF Plugin before anything else in this
> session: it adds a once-per-session framework update check, a Standards Guide fallback,
> one-step AL tool setup, the generator sub-agent, and the `documents` and `usage` skills. Without
> that file, ignore that section. Everything else here works the same either way.

### Setup

Same as the full framework: drop this file into the project root and rename it so your tool picks
it up automatically — `CLAUDE.md` for the Claude Code plugin in VS Code, or
`.github/copilot-instructions.md` for GitHub Copilot Chat. If a `CLAUDE.md` already exists, keep
this file as `ocpfFramework/LITE_BC_App_Build_Routine_Agent.md` and give `CLAUDE.md` the single
line `@ocpfFramework/LITE_BC_App_Build_Routine_Agent.md`. Keep this file itself as your master
copy elsewhere if you maintain more than one project.

You don't need to copy the Standards Guide by hand — Step 1 fetches it from the framework
repository into `ocpfFramework/standardsGuide/` and gitignores it there, with everything else the
framework fetches or keeps under `ocpfFramework/`.

**Or use the OCPF plugin** (optional). The framework is also an agent plugin, `ocpf-bc`, for
Claude Code, GitHub Copilot, and other tools; the repository's `README.md` has install steps. Its
`start` skill does this setup for you: it helps choose Lite or Full, installs the latest runbook,
and checks the AL MCP Server tooling. See ALL ALONG → OCPF Plugin.

**Getting started prompt:**
> This AL project (10 files or fewer) will follow the Lite Agentic Development Framework outlined
> in `LITE_BC_App_Build_Routine_Agent.md` (may also be referred to as `CLAUDE.md` or `.github/copilot-instructions.md`). Please review this file and let's get started.

---

## Operating Rules (apply in every phase)

1. **The Project Parameters block (Step 1) is authoritative.** Publisher, prefix, namespace,
   versions, ID range, localization — read them from there and derive everything else. Never
   hardcode.
2. **Verify against BC symbol files, not memory.** Table numbers, `using` namespaces, field IDs,
   `ObsoleteState` — confirm each in the symbol file named in the Parameters block. Agent
   knowledge of BC table numbers is not reliable. The agent downloads those symbols itself at
   the end of Step 1 (ALL ALONG → Symbols); the human never has to. **The downloaded symbols are
   the source of truth and the only routine lookup.** Consult Microsoft Learn's Base Application
   or System Application reference (**Standards Appendix B**; links in ALL ALONG → Reference
   Sources) **only** when (a) symbols could not be downloaded, (b) the object, field, method, or
   event is not in the downloaded symbols, or (c) the task needs a code pattern, a snippet, or an
   event's signature to subscribe to it. Never as a second check on something the symbols already
   answered, and never "to be safe". Every Learn lookup costs time and tokens; say why it was
   needed when one happens. The downloaded symbols win when the two disagree.
3. **Treat the whole extension as one batch — two only if there's a natural split** (e.g., "setup
   + master data" vs. "documents"). At 10 files or fewer there is rarely a reason for the full
   framework's multi-batch phasing. Order objects within the batch so lookup/reference tables
   precede the entities that reference them.
4. **Lint everything as it's written; don't compile until generation is finished.** Run Step 3's
   pre-flight checklist on every object as it's generated, both passes, including symbol
   verification (Rule 2) — in parallel mode, the post-generation pass runs per batch as each
   generator returns (Step 4). The whole extension compiles and packages once, at Step 5, the moment
   Step 4 finishes. After that, every code change goes through the same cycle: compile, package,
   deploy to a sandbox, test, fix, repeat. Treat any compile error as systemic: fix the rule, then
   every file it touched.
5. **Zero errors, zero warnings before PROVE.** A warning is a defect. Step 5's compile must reach
   0/0, with the analyzers and nothing suppressed (ALL ALONG → Analyzers), before Step 6 begins.
6. **Human-in-the-loop is a feature — approve in batches, not one click at a time.** Pause for
   human approval before:
   - **generating code** — once, for the batch plan at Step 3, which covers both batches when there
     are two (in parallel or one at a time), unless the human chose to be asked before each batch;
   - **applying root-cause fixes** — all the diagnoses from one test round or review, presented
     together for one decision (Step 5), with any fix that changes a design rule in `docs/2-design/DesignDoc.md`
     asked separately;
   - **finalizing the Design Doc;**
   - **installing any tool or runtime.**

   An approved run-through still stops by itself on any pre-flight failure or deviation from
   `docs/2-design/DesignDoc.md`, and the human can say "stop" at any time.
   6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human
       to *decide* something — pick a design option, approve a version bump, resolve an ambiguity —
       present it through the interactive multiple-choice mechanism the agent's harness provides
       (e.g., Claude Code's `AskUserQuestion`), recommended option first with a short reason. **Every
       step close is a decision too** (proceed / stop) and always goes through it — Rule 6c says
       how, for Steps 1–7. What stays out is progress *inside* a step (a clean compile mid-round,
       a batch's pre-flight result) — that's just noise. **Every intake question counts as a decision**, including values only the human
       knows: names, publisher, prefix, namespace, localization, ID ranges, versions. Ask them
       through the options mechanism, never as open-ended questions or a numbered list in chat;
       the mechanism's free-text entry (Claude Code: *Other*) carries a typed answer. Step 1 says
       what to offer. Step 3's parallel-batches question and Step 6's release-candidate question
       are decisions of this kind too. **Which mechanism each harness offers, and the option-count
       limits, are Ops § Asking and Approvals.**
   6b. **Don't install tooling without asking — and look harder first.** Before concluding a
       required compiler/runtime is missing, check whether the human's own IDE already provisions
       one privately (e.g., VS Code's AL extension gets its .NET runtime from a companion
       extension, not a system install). Installing anything is itself a human-in-the-loop
       decision regardless of what a fallback elsewhere in this runbook lists as available. The
       checks and per-OS install offers for Node, mermaid-cli, and PowerShell 7 are **Ops §
       Tooling Checks** — never `which mmdc`.
   6c. **Every step closes through the options box — Steps 1 through 7, every phase, no
       exceptions.** When a step's own work is finished — outputs written, exit gate met, usage
       rows recorded and pasted (Rule 9), summary given — the **last thing in the closing message
       is a question through the selectable-options mechanism (Rule 6a)**, never a prose prompt
       that waits for "continue": **Proceed into Step <next> now (recommended)** / **Stop here**,
       plus the mechanism's free-text entry. Where the step produced something the human may want
       to look at first (Step 5's tested package, Step 2's Design Doc, Step 6's findings), the
       *Stop here* option says what that is, and the message says how to resume. At a phase
       boundary (Step 1 → 2 closes DEFINE, 2 → 3 closes DESIGN, 5 → 6 closes BUILD) the box names
       the phase that closes and the one that opens. **Nothing of the next step starts until the
       human answers the box.** Each step file repeats this under its exit gate.
       Why: through v5.0.0.0 this rule applied "from Step 5 onward" and said Steps 1–4 were
       "unaffected"; a v5.0.0.0 run closed the early steps with a plain prompt and stalled on an
       answer nobody realised was owed. A decision in prose reads like idling at every step.
       **The Step 6 → Step 7 boundary has its own box instead of this one** — see Step 7's hand-off
       note, which replaces this generic check-in for that one transition (its one closing
       reminder message, which asks nothing, is part of that note). Don't do both.
   6d. **Zero-install first — never turn setup into the human's job.** Before proposing any
       install, or any manual setup (editing `PATH`, a shell profile, or an environment variable),
       work through the ladder in **Ops § Asking and Approvals**: what the editor already provides,
       then what's already installed, then — only then — an install asked for under Rule 6b
       (tooling: Ops § Tooling Checks).

       **Never hand the human a setup task the agent can do.** Connecting the AL tools, downloading
       symbols, keeping the editor's view current, and setting up notifications are the agent's job;
       the human approves the AI tool's prompts and signs in when a tool reaches a live Business
       Central environment. **Never send the human to the Command Palette to set up the AL MCP
       Server** — the AL Language extension has no such command — and never route AL tooling through
       a third-party VS Code extension.
   6e. **An interruption changes nothing about how questions are asked.** The human can dismiss a
       box (Escape in Claude Code), stop the agent mid-step, close the session, or come back later.
       On "continue", "resume", a named step, or `status` followed by "go on", the agent first
       works out what is still unanswered, then asks for it through the options box (Rule 6a) —
       never in prose, never inferred — and carries on under the same rules, including the Rule 6c
       box at the end of the step and of every step after it.
       - **A dismissed or unanswered box is re-asked, not inferred.** An interrupted Step 1 intake
         resumes at the first question without a recorded answer, questions already answered
         skipped, never re-asked from the top and never defaulted silently. A dismissed Rule 6c box
         at a boundary is sent again before anything of the next step starts; a dismissed approval
         (Rule 6) is asked again before the thing it gates is done.
       - **Answered means recorded:** `docs/1-define/ProjectParameters.md` and `app.json` for intake,
         sign-offs, `docs/0-project/ChangeLog.md`, and the recorded answers in
         `docs/2-design/DesignDoc.md` for decisions, `ProjectProgress.md` and
         `ocpfFramework/state/usage.json` for which step is open. An answer typed in chat instead
         of the box is recorded first, then counts. Not in a file, not an answer.
       - **Resuming mid-step** never skips the step's close: finish the actions, meet the exit
         gate, record usage (Rule 9), then the Rule 6c box (mid-step, the framework update offer
         is held until the gate — Ops § Plugin). Resuming at a boundary **always starts
         with that boundary's Rule 6c box, sent again** — nothing records whether it was answered
         or dismissed, and inferring a *Proceed* is what this rule forbids. The once-per-session
         framework update offer (Ops § Plugin) comes first, as its own box, then the re-asked box
         — reversed from a live boundary, because the box has not been answered yet.
       - **"Continue" is not a blanket approval** — it reopens the routine and answers no pending
         box; only a choice typed in the mechanism's free-text entry can do both.
       This rule is identical in the Full edition.
7. **Log every deviation immediately.** Any departure from the Design Doc — human or agent — goes
   in `docs/0-project/ChangeLog.md` before the next batch starts.
8. **Work in the human's chosen working language.** The first question of Step 1 asks which
   language the human wants to work in. Every later question, options box, and explanation is in
   that language. **Always in English, regardless:** this runbook, the Standards Guide, AL code
   and names, commit messages, `docs/2-design/DesignDoc.md`, and `docs/0-project/ChangeLog.md`. **Kept verbatim in their
   original language:** raw requirements and tester feedback. When the human names a BC concept in
   their own language, map it through the glossary in `docs/2-design/DesignDoc.md` rather than guessing.
9. **Record usage at every step boundary — the ritual is Ops § Usage & Cost → 5.** At a step's
   start, append `{ "step", "startedAt" }` to `ocpfFramework/state/usage.json` and set the step's
   `ProjectProgress.md` row to `In Progress` — same moment, same message. At its close, before the
   closing message (summary, then the pasted rows, then the Rule 6c box as its last thing): set
   `completedAt`, run the measurement (plugin:
   `/ocpf-bc:usage --step <id>`; without the plugin, the Ops procedure), and write the step's rows
   into the usage table — **one row per model that ran in the step** (the Main model, and every
   sub-agent model), never one row for the step with a single model. Paste those rows into the
   closing message so the human sees them without opening the file. **The exit gate is not met
   until the rows exist**; the next step does not start on a missing row, and the `status` skill
   reports one as a blocker. **Never hand-write a row, in either tool** — the script reads Claude
   Code's transcripts, or GitHub Copilot Chat's session files, and already aggregates per (step,
   model); a hand-written row is how a real project got one model for everything. **In Copilot
   the step close is also the checkpoint** that separates this step's AI credits from the next
   one's — a step closed without the measurement can't be separated later (Ops § Usage & Cost →
   2).

---

# PHASE: DEFINE

Goal: turn a business need into a validated scope and a filled-in parameter sheet — before any
design work.

## STEP 1 — Define the Problem & Lock Parameters

**Read `ocpfFramework/runbookSteps/STEP-1.md` in full before starting this step.** It carries the opening questions in
order and the complete **Project Parameters** table.

**In one line:** ask the working language, fetch both companion guides, the step files, and the
templates into `ocpfFramework/`, ask how to be notified, ask the Main model and effort (`roles`
skill in a plugin project), ask the Copilot session settings if Copilot is in use, create `docs/`
and its phase folders and `ProjectProgress.md` (Step 1 row `In Progress`), capture raw
requirements verbatim, write the problem statement and entity list with a quick gap check, then
fill every parameter — the app icon included — through the options mechanism (Ops § Intake) and
set up the AL project yourself (Ops § Project Setup), AL source under `src/`.

**Outputs:** `ocpfFramework/` with its six-line `README.md`; `ocpfFramework/standardsGuide/`, `ocpfFramework/opsGuide/`, `ocpfFramework/runbookSteps/`, and `ocpfFramework/documentTemplates/` (all fetched, gitignored); `ocpfFramework/state/usage.json` (Step 1's start timestamp) and `ProjectProgress.md` (seeded, project root, Lite step table only, Step 1 `In Progress`); `ocpfFramework/state/copilot.json` and the Copilot keys in `.vscode/settings.json` (when Copilot is in use); `requirements/` (if any raw input was
captured); `docs/` with `0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/` (created before the first document); `docs/1-define/ProblemStatement.md` (purpose, scope, out-of-scope, entity list, open questions);
`docs/1-define/ProjectParameters.md` (the completed Project Parameters block, all placeholders
replaced, the Main model and effort, version, and app icon answer included);
`.gitignore` populated per the table above and verified with `git check-ignore`; `app.json`; `src/`
(with `src/logo/AppLogo.png` when an icon was given); and `.alpackages/`.

**Exit gate:** Every question was asked through the options mechanism. `app.json` matches the
sheet (version `0.0.0.1` for a new app, the installed version for an existing one; `logo` set when an icon was given), `src/` exists, and the target version's symbols are in `.alpackages/` (Ops § Project Setup). Both companion guides are present, in `ocpfFramework/standardsGuide/` and
`ocpfFramework/opsGuide/`, and gitignored. The notification choice is recorded in
`ocpfFramework/state/notifications.json`, applied, and tested. `docs/1-define/ProjectParameters.md` exists, in `docs/`, with no placeholder remaining, and the Main model and effort recorded there match what this session is running on. Every `.gitignore` entry from the framework-files row is present and `git check-ignore` confirms each existing framework file — `ocpfFramework/LITE_RunbookChangeLog.md` included — is ignored. Nothing from the `docs/` list is in the project root; `ProjectProgress.md` is, with only the Lite step table and the Step 1 row `In Progress`. Deployment Target
is one allowed value. Namespace is consistent or correctly N/A. If
Permission Sets required = `Yes`, ≥ 2 IDs are reserved. Onboarding questions are each answered.
Every target language is classified against Microsoft's live page and, unless source wording is
*US wording, no translation files*, has a required-at-release answer and a named reviewer; source
language and wording are recorded. Human confirms the sheet.

---

# PHASE: DESIGN

Goal: one self-sufficient Design Doc, sanity-checked, before any code.

## STEP 2 — Write the Design Doc & Self-Check

**Read `ocpfFramework/runbookSteps/STEP-2.md` in full before starting this step.** It carries the Design Doc's two
halves, the API caption-locking questions, and the self-check list.

**In one line:** write **one** self-sufficient document, `docs/2-design/DesignDoc.md` — Part A what and why,
Part B how, glossary included — using the `documents` template; produce
**`docs/2-design/HumanEffortEstimate.md`** and **`docs/2-design/AiEffortEstimate.md`** in the same
pass (ALL ALONG → Usage & Cost Tracking); then run the self-check.

**Outputs:** `docs/2-design/DesignDoc.md`; an **Object Register** table (inside `docs/2-design/DesignDoc.md` is fine at this
scale — every planned object with its ID, source table, and R/W status); `docs/2-design/HumanEffortEstimate.md`;
`docs/2-design/AiEffortEstimate.md`.

**Exit gate:** Human sign-off. Self-check passes with 0 blocking issues. No rule requires
knowledge outside the document. `docs/2-design/HumanEffortEstimate.md` exists, covers every object, names
its baselines source, and states its assumptions. `docs/2-design/AiEffortEstimate.md` exists, covers every step
from Step 3 on, states its margin and the 30-minute approval assumption. This step's usage rows, one per model, are written before this message (Operating Rule 9).

---

# PHASE: BUILD

Goal: generate AL, lint clean — including symbol verification — then compile, package, test, and
fix in a loop until clean.

## STEP 3 — Plan & Scaffold

**Read `ocpfFramework/runbookSteps/STEP-3.md` in full before starting this step.** It carries the pre-flight checklist
Steps 4 and 6 reuse.

**In one line:** scaffold the project structurally (analyzer settings, `.gitignore` block, `ocpfFramework/scripts/`
— not compiled, Operating Rule 4), fetch the BCQuality snapshot and the patterns library, write the
batch plan with every ID and file name fixed, ask how two batches run (parallel / one at a time /
ask before each), and get one approval for it.

**Outputs:** Batch plan, project scaffold, the pre-flight checklist.

**Exit gate:** Batch plan approved with every ID and file name fixed (and, with two batches, the
generation mode recorded);
scaffold structurally complete, analyzer settings and (for AppSource) `AppSourceCop.json` in place per Ops § Analyzers
(not compiled — Operating Rule 4); pre-flight checklist ready. This step's usage rows, one per model, are written before this message (Operating Rule 9).

## STEP 4 — Generate the Code

**Read `ocpfFramework/runbookSteps/STEP-4.md` in full before starting this step.**

**In one line:** generate exactly per `docs/2-design/DesignDoc.md` — one batch at a time, or both
at once through one background generator per batch on the Main model — lint each batch as it
lands, log every deviation in `docs/0-project/ChangeLog.md` before the next batch, commit each
batch separately.

**Outputs:** Every AL file under `src/`, lint-clean including symbol verification; ChangeLog entries for any
deviation from `docs/2-design/DesignDoc.md` (a generator's reported deviations included). The extension is **not** compiled yet.

**Exit gate:** Every planned object generated and pre-flight-clean; in parallel mode, every
generator's report integrated and its model line checked; permission-set coverage
verified. A clean compile is not required to close this gate — Step 4 hands off directly into
Step 5's mandatory compile-and-package. This step's usage rows, one per model, are written before this message (Operating Rule 9).

## STEP 5 — Compile, Package, Test & Iterate

**Read `ocpfFramework/runbookSteps/STEP-5.md` in full before starting this step.**

**In one line:** the first full compile-and-package with the analyzers, then the cycle — increment
the Revision, compile, package (the fixed *Package built* message after every build), deploy to a
sandbox, test, diagnose (check `ocpfFramework/patterns/` first), fix, repeat — to 0 errors /
0 warnings; translations drafted and reviewed inside this cycle (Ops § Translations).

**Outputs:** All files compiling and packaging with **0 errors, 0 warnings**; every build's package
in `outputAppPackage/`, one file per version, none overwritten; at least one package
published and manually tested on a sandbox; `docs/0-project/ChangeLog.md` current (last installed
version included); `docs/2-design/DesignDoc.md` updated for every rule change.

**Exit gate:** Full extension compiles clean, with the analyzers and nothing suppressed (Ops § Analyzers); human confirms sandbox testing is clean; no known
systemic issue outstanding; no unit in a language required at first release is
`needs-translation` or `needs-adaptation`, and translation checks are clean. This step's usage rows, one per model, are written before this message (Operating Rule 9).

---

# PHASE: PROVE

Goal: confirm the built code matches the Design Doc, is clean, is documented, and has passed a
human-run release test.

## STEP 6 — Review, Gap-Check & Finalize Docs

**Read `ocpfFramework/runbookSteps/STEP-6.md` in full before starting this step.**

**In one line:** gap-check the built code against `docs/2-design/DesignDoc.md`, review it against the
Standards Guide, AL Guidelines, and BCQuality and grade the eight-dimension scorecard into the
ChangeLog, apply the fixes through the compile cycle, bring the Design Doc to as-built, write
`docs/4-prove/Docs.md`, `docs/4-prove/TestScript.md`, and `docs/0-project/Acknowledgements.md`
(`documents` templates), then ask whether to build the release candidate v1.0.0.0 now.

**Outputs:** `docs/2-design/DesignDoc.md` (updated in place, glossary included), `docs/4-prove/Docs.md`, and `docs/4-prove/TestScript.md`.
Together with `docs/0-project/ChangeLog.md` from Step 1 onward, that's Lite's four maintained documents; translated
documents follow at Step 7. Also: the code-review scorecard in this step's ChangeLog entry,
`docs/0-project/Acknowledgements.md`, and — if the human said yes — the release candidate
`outputAppPackage/<Name>_1.0.0.0.app`. Step 1's `docs/1-define/ProblemStatement.md` and
`docs/1-define/ProjectParameters.md` are also tracked, but written once at kickoff rather than kept current.

**Exit gate:** Every gap classified and resolved or explicitly deferred (logged in
`docs/0-project/ChangeLog.md`); dead-code scan clean; no obsolete references; `docs/4-prove/Docs.md`'s diagram renders;
`docs/4-prove/TestScript.md` is executable by a non-developer; translation checks clean; any AL test codeunits
have been run and pass, or it's recorded why they couldn't be; the eight-dimension scorecard is in
the ChangeLog entry; `docs/0-project/Acknowledgements.md` exists with one row per resource used;
the release-candidate question is answered and, on yes, `1.0.0.0` is built. This step's usage rows, one per model, are written before this message (Operating Rule 9).

## STEP 7 — Release for Testing

**Read `ocpfFramework/runbookSteps/STEP-7.md` in full before starting this step.** It carries the hand-off moment and
the release gate.

**In one line:** the human runs `docs/4-prove/TestScript.md` in every required language, plus the upgrade
path unless this is the first release; every finding goes to `docs/0-project/ChangeLog.md` verbatim and is
triaged; fixes continue `1.0.0.1`, `1.0.0.2` …; the release candidate that passes ships as it is;
the production deploy is the human's.

**Outputs:** `docs/0-project/ChangeLog.md` updated with every test finding and its resolution.

**Exit gate:** All green-team tests pass; all red-team tests fail gracefully; the upgrade path
passes, or this is the first release (**Standards §9.6**); permission sets
verified; every translated document Step 1 asked for exists and has been reviewed; every required
language has passed its language pass and its state scan shows every unit `signed-off` or `final`
(Ops § Translations).
**If everything passes, the package that was actually tested ships as it is** — the release
candidate, or the last `1.0.0.x` fix build that passed — to Production, by the human through
Extension Management, never the agent (Ops § Packaging). No rename, no copy, no rebuild: every
build already has its own version and file, so the shipped artifact is permanently identifiable.
**Before that deploy, restate the Schema Sync Mode assessment for this exact package** in the
fixed *Package built* message block (ALL ALONG → Packaging & Versioning) — **Add** if this release
is additive-only, **Force Sync** with an explicit data-loss warning if anything was removed,
shrunk, retyped, or re-keyed since the last package installed in that tenant. Then set the Step 7
row of `ProjectProgress.md` to `Completed`, refresh the usage table, and export the calibration
file (the hand-off note above).

---

# ALL ALONG — Continuous Discipline

Run these throughout, not as a final step.

**Each section below carries its non-negotiables and points at the Operations Guide for the
procedure.** Read the named **Ops §** section at the step that needs it.

## ChangeLog.md — the single running log

Lite merges what the full framework splits across a ChangeLog, a Testing Feedback Log, and a
Roadmap into **one file**. Every deviation from `docs/2-design/DesignDoc.md`, every diagnosed root cause, and
every piece of testing feedback goes here, before the next batch or the next test round begins.
Entry format:

```
## <Type: Issue / Feedback / Deferred> <SeqNo> — <Short Description>
**Problem:** What was wrong, missing, or requested.
**Root cause:** Why it happened (Issue/Feedback only).
**Resolution:** What was changed, or why it was deferred/rejected.
**Files affected:** List of changed files.
**Design Doc updated:** yes/no.
```

**Name the person, not a role.** When a decision or preference is attributed to a human, write
their actual name — never a generic "the human" or "the user." The moment a second contributor
joins the project, a role-noun stops answering the only question that phrase exists to answer.

Commit each batch to version control separately, before the next begins, with a message that
references its `docs/0-project/ChangeLog.md` entries.

## Project Progress Tracker — `ProjectProgress.md` (required, in-repo, **project root**)

No agent running this framework can write to a persistent status element outside its own
conversation, and nothing like that would travel with the repo anyway. `ProjectProgress.md` is the
durable, host-agnostic substitute: the first thing visible on opening the repo, no navigation
needed.

**Lives in the project root, always — not `docs/`.** Every other document lives under `docs/`;
this one is deliberately the exception, so a glance answers "where are we?"

It is **two tables, nothing else** — the step table (Lite's seven rows), and beneath it the usage
table (next section). Not a narrative: the reasoning behind a status lives in
`docs/0-project/ChangeLog.md`.

| Phase | Step | Status |
|---|---|---|
| DEFINE | STEP-1 — Define the Problem & Lock Parameters | *(blank / `In Progress` / `Completed`)* |
| … | *(one row per step, STEP-1 through STEP-7)* | |

- **Create it as the very first artifact of the routine** — the moment Step 1 begins, from
  `ocpfFramework/documentTemplates/ProjectProgress.md` (keep the *Lite* step table, delete the
  *Full* one), every row blank except Step 1, marked `In Progress`. A project that adopts this
  version mid-way gets one backfilled from the ChangeLog the next time any step closes.
- **This file is the only record of which step is current.** Set the row to `In Progress` when a
  step starts and `Completed` when its exit gate is met — and at the same moment append the step's
  start or completion timestamp to `ocpfFramework/state/usage.json` (Operating Rule 9), so the
  usage table can attribute what was spent to the step it was spent on.
- Leave a step's row blank until it actually starts; never mark a step `Completed` before its own
  exit gate is met (the step file's **Exit gate** paragraph is the test, not "the agent moved on").
- Close the file with the standing note every project ships it with: asking **"Where are we in
  the process? What's next?"** always gets a direct answer from this file (plus
  `docs/0-project/ChangeLog.md` for the reasoning), whether or not an agent session is running.
- **Within a step**, narrate multi-part work in the conversation as ordinary text; this file tracks
  step-level status only, never sub-step task lists.

## Usage & Cost Tracking — `ProjectProgress.md`, second table

**Full procedure: Ops § Usage & Cost.** Read it at Step 1 (when the timestamps start) and at every
step boundary (Operating Rule 9 — the ritual is Ops § Usage & Cost → 5). The usage table is the
second table of `ProjectProgress.md`. In a plugin project the `usage` skill
(`/ocpf-bc:usage --step <id>`) does the measuring.

- **Every step start and every exit gate is timestamped** in `ocpfFramework/state/usage.json` — the
  same moment `ProjectProgress.md` changes; nothing can be attributed to a step without them.
- **Measured, never estimated.** Claude Code's per-request usage — input, output, cache-write, and
  cache-read tokens per model, sub-agents included — is read from its session transcripts on disk.
  **GitHub Copilot bills in AI credits**, and VS Code records them per turn and per model,
  sub-agents included, in the chat session files it keeps on disk: the usage table reads those,
  and is a **different table** — AI credits and cost per model, no token columns, because Copilot
  Chat records no token totals by type. If the session files can't be read, the human reads
  *Session Cost* in the Session Info popover and the script records that one number. Never invent
  a token figure, never convert credits to tokens, and never hand-write a row.
- **Cost uses published prices, fetched, dated, and cited** — stored in `ocpfFramework/state/pricing.json` with the
  source URL and the date read; never hardcoded.
- **Write the rows at every step close, one row per model that ran in the step** — model, input,
  output, cache write, cache read, cost, elapsed time, turns, human decisions asked, sub-agent calls
  (the generator sub-agents and the skills' delegations) — next to the hours from
  `docs/2-design/HumanEffortEstimate.md` and the estimate from `docs/2-design/AiEffortEstimate.md`
  (Step 2) once they exist.
- **Say what couldn't be measured** — `n/a` with the reason, never a blank or a guess.
- **At Step 7's close,** the `usage` skill exports the project's calibration file to
  `~/.ocpf/calibration/<project>-<date>.json`, which future AI Effort Estimates read.

## Packaging & Versioning

**Full procedure: Ops § Packaging** (and its *Version numbers* subsection). Read it at Step 5's
first package and before Step 6's release-candidate question. The non-negotiables:

- **Fixed name and location:** `<ExtensionName, spaces → underscores>_<version>.app` in
  **`outputAppPackage/`**, read from `app.json` at build time. Say the exact path every time a build
  completes, in the fixed message block:

  ```
  Package built: outputAppPackage/<Name>_<version>.app (previous build <version-1>)
  Schema: additive only → upload with Schema Sync Mode = Add
     or: <what was removed / shrunk / retyped / re-keyed> → upload with Schema Sync Mode = Force Sync
         (Microsoft: test a forced sync in a sandbox first; it can lose data in <where>)
  Upload: Extension Management → Manage → Upload Extension, choose the file, set Schema Sync Mode, Deploy.
  ```

  The schema line compares the objects against the last package installed in a tenant; record
  "last installed version" in `docs/0-project/ChangeLog.md` each time the human confirms an upload.
- **Version numbers.** A new app starts at **`0.0.0.1`** (Step 1's default); an existing app
  starts from the version installed in the target environment and continues from it. **The first
  build of a new app is `0.0.0.1` as written; an existing app's first build increments from the
  installed version; every build after the first increments first — mechanically and without
  approval:** read the version from `app.json`, increment the fourth segment (Revision), write it
  back, then build (the test is in Ops § Packaging → *Version numbers*). **Never build
  twice at one version**: if `outputAppPackage/<Name>_<version>.app` already exists, increment
  again; `ocpfFramework/scripts/al-analyze.*` refuses to overwrite an existing output file (exit
  code 4). Why: testers upload packages as PTEs through Extension Management, and a version already
  installed can never be uploaded again.
- **The release candidate is `1.0.0.0`**, asked at the end of Step 6 (Rule 6a) and built there;
  fixes during release testing continue `1.0.0.1`, `1.0.0.2` …; **the package that passes Step 7
  ships as it is** — no rename, no copy, no rebuild. Existing app: the RC is the next Minor (or
  Major) from the starting version, proposed.
- **Built packages are tracked, never gitignored** — no blanket `*.app` entry.
- **The agent never publishes to a production environment.** Before every publish, state the target
  environment and type; if it isn't a sandbox, stop and ask. Never force a destructive schema change
  (`ForceSync`, `Recreate`, `forceUpgrade`) without a separate approval naming what can be lost. The
  production deploy at Step 7 is the human's, through Extension Management (Ops § Packaging).
- **Never delete or overwrite any package.** Every build has its own version, so every build has
  its own file; nothing is ever tidied.
- **Major, Minor, and Build bumps are proposed and approved** (Rule 6a), never a silent `app.json`
  edit; only the Revision increment is mechanical.
- **Flag Schema Sync Mode on every completed build**, in the message block above: **Add** for
  additive-only, **Force Sync** with a data-loss warning otherwise.

## OCPF AL Development Standards Guide

Two companions are fetched at Step 1 and kept for the life of the project: the **Standards Guide**
(`ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`, v1.11.0.0), cited as **Standards §**, and the
**Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`, v5.1.0.0), cited as **Ops §** and shared
unchanged with the full framework.

**Full procedure: Ops § Fetched Companions** — fetching, refreshing, the plugin's offline copies,
and what to do when GitHub is unreachable.

- Both live inside the project root and are **always gitignored** — not covered by Step 1's
  framework-files question. **Fetched with them, and ignored the same way:** this runbook's step
  files into `ocpfFramework/runbookSteps/` (from `liteVersion/steps/`) and the document templates into
  `ocpfFramework/documentTemplates/`. A step file whose `**Runbook version:**` line doesn't match this runbook is
  skew: say so and refetch.
- **Neither is optional:** a missing copy is a real gap. Say so and ask the human for a copy rather
  than working from memory of a rule.
- **Version skew is named, not papered over.**

## Repository Hygiene

**Full procedure: Ops § Repository Hygiene.** Read it at Step 1 and Step 3.

**Always gitignored, not a per-project choice (the first block in Ops § Repository Hygiene):**
`.claude/settings.local.json`, `ocpfFramework/state/` (each developer's `usage.json`,
`pricing.json`, `notifications.json`, `copilot.json`, `previous/`), `ocpfFramework/standardsGuide/`,
`ocpfFramework/opsGuide/`, `ocpfFramework/runbookSteps/`, `ocpfFramework/documentTemplates/`,
`ocpfFramework/patterns/`, `ocpfFramework/scripts/`, `.alpackages/`, `*.g.xlf`, and Microsoft's
translation files. BCQuality lives outside the project root entirely.

**Always tracked, never ignored:** `docs/` (all of it), `requirements/`, `src/`, `ProjectProgress.md`,
`Translations/*.xlf`, `app.json`, and every package in `outputAppPackage/` (no `*.app` entry).

**Gitignored by default, with Step 1's question — the second block, by exact filename, every one:**
`ocpfFramework/` as a whole (which now holds `LITE_RunbookChangeLog.md`, `LITE_RunbookSchematics.md`,
`framework.json`, and the runbook itself when `CLAUDE.md` already existed), this runbook under
whatever name it was placed (`CLAUDE.md`, `.github/copilot-instructions.md`,
`.github/instructions/ocpf-framework.instructions.md`), and the project-local sub-agent
definitions (`.claude/agents/ocpf-light.md`, `ocpf-reasoning.md`, `ocpf-generator.md`;
`.github/agents/ocpf-*.agent.md`). With *No, track them*, only the first block is written. Step 1's
parameter table (in `ocpfFramework/runbookSteps/STEP-1.md`) has the list; Ops § Repository Hygiene
has the block to paste. **Verify with `git check-ignore -v`** on each file that exists — that
command, not a re-read of `.gitignore`, is what proves an entry works. **Never the project's own
`docs/0-project/ChangeLog.md`**, one of Lite's four maintained documents.

**`docs/` is where every document lives** — see the header note. At every exit gate, list the root:
a document sitting there is moved with `git mv`, and the move is noted in `docs/0-project/ChangeLog.md`.

**If a project built on an earlier Lite version has `docs/0-project/ChangeLog.md` in `.gitignore`,** remove that
entry and commit the file — earlier wording said "this runbook and `docs/0-project/ChangeLog.md`" when it meant the
framework's changelog. Check for a remote first: collaborators will see the file as newly added.

**If any of this is already tracked,** add the entry, then untrack with `git rm --cached` — checking
for a remote first, since collaborators will see the files as deleted.

## AL MCP Server

**Full procedure: Ops § AL Tools.** Read it at the end of Step 1, when the tools are first needed.

- Nothing is installed: Copilot Chat has the AL tools built in; Claude Code and Copilot CLI use the
  extension's bundled AL MCP Server. With the plugin, `al-mcp-setup` does it in one step.
- **The human only approves the AI tool's prompts.** No Command Palette command exists for this, and
  no third-party bridge extension is used.
- A server registered mid-session appears only next session; until then use the one-shot helper.

## Analyzers

**Full procedure: Ops § Analyzers.** Read it at Step 3's scaffold and at Step 5's compile.

- The mandatory compile runs **CodeCop**, **UICop**, and exactly one of **PerTenantExtensionCop**
  (SaaS/OnPrem PTE) or **AppSourceCop** (AppSource) — never both.
- `.vscode/settings.json`, and `AppSourceCop.json` for AppSource, are created at Step 3.
- Outside Copilot Chat, run `ocpfFramework/scripts/al-analyze.*`. The AL MCP Server's `al_build` never applies
  analyzers (observed on AL extension 18.0.2732683; re-verify on a newer release), and its
  `al_compile` only does so with one exact argument shape — anything else
  returns a clean pass on failing code, and it produces no `.app` (**Ops § Analyzers**).
- **Read the warnings, not just the result** — `al-analyze` exits `3` on warnings, and any warning
  fails Rule 5. No suppressions, and no ruleset.

## Symbols

**Full procedure: Ops § Symbols.** Read it at the end of Step 1.

- **The agent downloads symbols; the human never does.** Global sources need no sign-in; a sandbox
  download (one browser sign-in) covers non-AppSource dependencies and localized projects.
- The AL MCP Server's global download is **W1 only**.
- **Confirm symbols by using them**, never by unpacking `SymbolReference.json`. A sandbox download
  carries Microsoft's own source and translation files: read them, never commit them.

## Keeping the Editor in Sync

**Full procedure: Ops § Editor Sync.** Read it at the end of Step 1 and after every clean compile.

- Red marks the latest compile didn't report mean the editor's view is stale, usually after
  `app.json` changed on disk or symbols were downloaded outside VS Code.
- **Detect** with the diagnostics tool; **fix** by re-downloading symbols in Copilot Chat, or by
  asking the human, at the end of the reply, to run **Developer: Reload Window**.
- **Never change code that compiles clean to clear stale marks.**

## Notifications

**Full procedure: Ops § Notifications.** Read it at Step 1, right after the working language.

- **Ask once, as one multi-select question:** *Claude app*, *Sound*, *Desktop notification*, any
  combination, or *No notifications* — offering only what works for this tool, OS, and sign-in.
- **Record it in `ocpfFramework/state/notifications.json`** (per developer, always gitignored) and read it at the
  start of every session; ask again when it's missing.
- **Apply it** through each tool's own notifications and hooks — never a script-raised banner on
  macOS — and test it once.

## Reference Sources — Microsoft Learn and AL Guidelines

**The list: Ops § Reference Sources** — Microsoft Learn's Base Application and System Application
references, the translation-files and country/language pages, Microsoft's terminology collection and
style guides, and AL Guidelines. Consulted online; nothing is fetched.

- **Precedence:** the downloaded symbols are the source of truth and the **only** routine lookup.
  Consult Microsoft Learn's Base Application or System Application reference **only** when (a)
  symbols could not be downloaded, (b) the object, field, method, or event is not in the downloaded
  symbols, or (c) the task needs a code pattern, a snippet, or an event's signature to subscribe
  to it. Never as a second check on something the symbols already answered, and never "to be
  safe"; say why it was needed when one happens (Operating Rule 2). The Standards Guide beats AL
  Guidelines on any AL rule. Surface a conflict rather than picking a side silently.
- The other Learn pages read live — countries and languages, the runtime table, the translation
  pages — are unaffected.
- **No web access? Say so** rather than answering from memory.

## BCQuality Knowledge Snapshot

**Full procedure: Ops § Fetched Companions.** Read it at Step 3, when the snapshot is fetched, and
at Step 6, when it's used.

- A third-party BC AL code-quality knowledge base, fetched once at Step 3 and refreshed only on
  request.
- **It lives outside the project root** — `alc` would otherwise compile its illustrative snippets —
  so there's nothing to gitignore.
- At Step 6 it's an independent review pass whose findings are integrated like any other, never
  applied blind.

## OCPF BC AL Patterns Library

**Full procedure: Ops § Fetched Companions.** Read it at Step 3, when the library is fetched.

- The human's own cross-project BC AL patterns, fetched once into `ocpfFramework/patterns/`, always gitignored,
  refreshed only on request, and merged rather than overwritten.
- **Using it — before writing, and before diagnosing.** At Step 4, before generating any child list
  or list part, setup page, or wizard, read Standards Part 11 and the matching pattern files (Step 3
  marks those objects). At Step 5 or 7, check whether `ocpfFramework/patterns/` already documents a problem
  before diagnosing from scratch.
- A fix likely to recur on future projects is a candidate for a new pattern — flag it, don't add it
  unilaterally.

## Translations & Terminology

**Full procedure: Ops § Translations** — the glossary, the cycle inside Step 5, review and approval,
and the release gate. Read it at Step 1, at Step 5's first full build, and at Step 7's gate. Skip
everything here if Step 1 chose *US wording, no translation files*.

- **The glossary lives in `docs/2-design/DesignDoc.md`** and is filled only by **Standards Appendix D**, never from
  model memory.
- **The agent drafts, a named person approves.** Every approval is logged in `docs/0-project/ChangeLog.md` by name
  (**Standards §8.7**).
- **The release gate is a plain state scan:** every unit in every language required at first release
  is `signed-off` or `final`.
- **Changed source text invalidates approval** — the unit goes back through drafting and review.

## Permission Sets

- **Required the moment this project owns one table** (**Standards §5.3**).
- **Coverage is verified at the pre-flight checks in Steps 3 and 4**, so a gap doesn't wait for the
  compile. Step 6 relies on the last 0/0 compile, after confirming it ran with the analyzers and
  nothing was suppressed (ALL ALONG → Analyzers).
- **Named for this extension, not just the prefix:** `<PREFIX> <APPCODE>, VIEW` and
  `<PREFIX> <APPCODE>, EDIT`, 20 characters or fewer (**Standards §5.4**).

## OCPF Plugin (Optional)

**Full procedure: Ops § Plugin.** Read it at the start of a session in a plugin-installed project.

**Applies only when `ocpfFramework/framework.json` exists** — the plugin's marker, which its `start`
skill creates (with `"layout"` and `"tooling"` fields). Without that file, skip this section.

- **Once per session,** compare the project's runbook version against the latest published Lite
  runbook and offer **Update now / Not now / Skip this version**. Never replace the runbook without
  an explicit yes.
- **What the plugin adds:** offline copies of the runbooks, both companions, the step files, and the
  templates; one-step AL tool setup; notification setup; the `ocpf-generator` sub-agent (the
  `roles` skill writes the project-local copy on the Main model and effort — Step 4 uses it for
  parallel batches); and the `status` (reads `ProjectProgress.md`), `al-standards`,
  `notifications`, `roles` (asks Lite's two model questions), `documents` (writes any document from
  its template), and `usage` (`--step <id>` at every boundary; the calibration export at Step 7)
  skills. (The `ocpf-light` and `ocpf-reasoning` sub-agents belong to the full framework's role
  split, which Lite doesn't use.)

## Tooling Checks — Node, mermaid, PowerShell

**Full procedure: Ops § Tooling Checks** — the same zero-install ladder as Rule 6d. Read it at Step
3 (PowerShell 7 for the XLIFF Sync module and the usage script's `.ps1` port) and Step 6 (Node and
mermaid-cli for the ER diagram). Check `node --version` and `npx --yes @mermaid-js/mermaid-cli
--version`, never `which mmdc` — npx-cached packages are never on `PATH`. Record the outcome in
`ocpfFramework/framework.json` → `"tooling"`. Any install is offered under Rule 6b, per OS, never
done silently.

## Step Map — Lite vs. Full Framework

| Lite step | Full framework equivalent |
|---|---|
| Step 1 — Define & Lock Parameters | PRE-01, PRE-02, Step 01 |
| Step 2 — Design Doc & Self-Check | Step 02 (FRD), Step 03 (TDD), Step 04 (Sanity Check) |
| Step 3 — Plan & Scaffold | Step 05 |
| Step 4 — Generate the Code | Step 06 |
| Step 5 — Compile, Package, Test & Iterate | Step 07 |
| Step 6 — Review, Gap-Check & Finalize Docs | Step 08 (Gap-Fit), Step 09 (Code Review), Step 10 (Update Docs), Step 11 (Document) |
| Step 7 — Release for Testing | Step 12 |

**Shared with the full framework, not reduced:** the OCPF AL Development Standards Guide. Both
editions fetch the same v1.11.0.0 file and apply the same AL rules — Lite differs only in process.

**Document count:** 4 maintained documents (`docs/2-design/DesignDoc.md`, `docs/0-project/ChangeLog.md`, `docs/4-prove/Docs.md`,
`docs/4-prove/TestScript.md`), plus `ProjectProgress.md` (project root, both tables), Step 1's two
kickoff artifacts (`docs/1-define/ProblemStatement.md`, `docs/1-define/ProjectParameters.md`), two
estimates (`docs/2-design/HumanEffortEstimate.md`, `docs/2-design/AiEffortEstimate.md`), and
`docs/0-project/Acknowledgements.md` (Step 6), versus the full framework's 25 (`ProblemStatement`,
`ProjectParameters`, `FRD`, `TDD`, `SanityCheck`, `HumanEffortEstimate`, `AiEffortEstimate`,
`BuildPlan`, `ObjectRegister`, `ChangeLog`, `ProjectMemory`, `ProjectProgress`, `GapAnalysis`,
`CodeReview`, `PostDevTDD`, `Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`,
`AutomatedTestScripts`, `ReleaseTestResults`, `TestingFeedback`, `Roadmap`, `TranslationGlossary`,
`Acknowledgements`). Lite keeps its translation glossary inside `docs/2-design/DesignDoc.md`; translated copies
of `docs/4-prove/Docs.md` and `docs/4-prove/TestScript.md` don't count as separate documents.

---

*Lite Edition derived from the OCPF BC Agentic Development Framework, created by AJ Ansari,
Microsoft MVP, OnlyCopilotFans. Update this runbook when the full framework changes in a way that
should flow down to Lite.*
