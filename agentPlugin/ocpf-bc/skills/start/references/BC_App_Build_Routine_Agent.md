# BC App Build Routine — Agent Runbook

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

**Version:** 2.15.0.0
**Last Updated:** September 15, 2026

> Version history for this framework lives in `RunbookChangelog.md`, tracked independently of any
> one project built with it — check there for what changed between the version you have and the
> latest. If `RunbookChangelog.md` is not found, create one.

> **What this is:** A single, ordered routine an AI agent follows to build a new Business Central AL Per-Tenant Extension (PTE) from a business problem through to a tested, documented app deployed to production.
>
> **How the agent uses it:** Work the phases in order (DEFINE → DESIGN → BUILD → PROVE). Do not start a step until its predecessor's exit gate is met. Every step lists its **Inputs**, **Actions**, **Outputs**, and **Exit gate**. The *Project Parameters* block in Step 01 is the single source of truth for every name, ID, version, and quoting decision — never hardcode any of those values in AL; always derive them from that block. It is persisted as `docs/ProjectParameters.md`, not just discussed — every later step reads it from that file. At the start of every session, read `.ocpf/notifications.json` and keep notifying the human the way it says; if it's missing, ask how they want to be notified (ALL ALONG → Notifications).
>
> **Companion document:** `standardsGuide/ocpfALDevStandardsGuide.md` — the **OCPF AL Development Standards Guide** (v1.7.0.0). This runbook drives the *sequence*; that guide holds the detailed AL *rules* the sequence applies (Parts 1–8, Appendices A–D). References below point to it as **Standards §**. It is fetched into the project at PRE-01 and kept for the life of the project — see ALL ALONG → OCPF AL Development Standards Guide for the fetch, refresh, and `.gitignore` policy. **Neither document restates the other:** this runbook names each AL rule in one line where a checklist applies it and cites **Standards §**; the rule's rationale, limits, tool behavior, and reference links live only in the guide. The intake sheet, the phase/step sequence, every checklist, the compile cadence, and the ChangeLog format live only here; AL coding rules, API page design, field inclusion, naming, ID allocation, gap analysis, and anti-patterns live only there.
>
> **Prime directive for the agent:** An ambiguous input produces ambiguous code. If a step's inputs are incomplete or contradictory, stop and ask the human — do not invent rules to fill the gap.
>
> **Installed by the OCPF plugin?** If this project has a `.ocpf/framework.json` file, it was set up by the OnlyCopilotFans agent plugin. Read ALL ALONG → OCPF Plugin before anything else in this session: it adds a once-per-session framework update check, a Standards Guide fallback, one-step AL tool setup, and ready-made sub-agents. Without that file, ignore that section. Everything else here works the same either way.

---

## Operating Rules (apply in every phase)

1. **Part 1 is authoritative.** Publisher, prefix, namespace, versions, ID ranges, localization — read them from the Project Parameters block (Step 01) and derive everything else. Never hardcode.
2. **Verify against BC symbol files, not memory.** Table numbers, `using` namespaces, field IDs, `ObsoleteState` — confirm each in the symbol file named in Parameter 1.4. Agent knowledge of BC table numbers is not reliable; the verification procedure is Standards Appendix B. The agent downloads those symbols itself at Step 01 §1.10 (ALL ALONG → Symbols); the human never has to. **Fallback when the downloaded symbols don't answer the question:** Microsoft Learn's Base Application and System Application reference (Standards Appendix B; links in ALL ALONG → Reference Sources). The downloaded symbols win when the two disagree.
3. **Phase large scope into batches.** A batch is a self-contained, reviewable increment (by module or document-type group) — designed to be independently correct even though, under Operating Rule 4, it is not compiled on its own to prove it. Define batch boundaries during DESIGN and record them in the TDD.
4. **Lint every batch as it's written; don't compile per batch.** Run Step 05's pre-flight checklist on each batch as it's generated, both passes, including symbol verification (Operating Rule 2). The whole extension compiles and packages once, at Step 07, the moment Step 06 finishes — a real compile catches cross-file problems lint can't, and one pass keeps generation fast. After that, every code change anywhere in BUILD or PROVE goes through the same cycle: compile, package, deploy to a sandbox, test, fix, repeat. A human-requested spot-check compile mid-BUILD is extra, never a substitute. Gap-fill code, once written, gets its own pass through Steps 05–07. Treat any compile error as systemic: fix the rule or template, then every file it touched.
5. **Zero errors, zero warnings before PROVE.** A warning is a defect, not noise. Step 07's compile must reach 0/0, with the analyzers and nothing suppressed (ALL ALONG → Analyzers), before Step 08 begins.
6. **Human-in-the-loop is a feature — approve in batches, not one click at a time.** Pause for human approval before:
   - **generating code** — once, for the whole batch plan at Step 05, unless the human chose to be asked before each batch;
   - **applying root-cause fixes** — all the diagnoses from one test round or review, presented together for one decision (Step 07), with any fix that changes the FRD, TDD, or a design rule asked separately;
   - **finalizing any design document** — combined into fewer sign-offs when one person holds every approver role (PRE-01 *Approvers*);
   - **installing any tool or runtime.**

   An approved run-through still stops by itself on any pre-flight failure or deviation from the TDD, and the human can say "stop" at any time. Why batched: approving each batch and each fix separately cost a typical run dozens of one-at-a-time waits without adding protection — every item is still listed and individually selectable before anything is applied.
6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human to *decide something* — pick between design options, approve a version bump, choose a name, resolve an ambiguity — present it through the interactive multiple-choice mechanism the agent's harness provides (e.g., in Claude Code, the `AskUserQuestion` tool — substitute whatever the actual harness offers), with the recommended option first and a short reason on each. A decision buried in a paragraph of chat is easy to miss: it reads like the agent finished and is idling, so the project silently stalls waiting on an answer nobody realised was owed.
    **Use it only for decisions.** Do *not* wrap ordinary progress in it — finishing a step and waiting to be told to start the next one, reporting a clean compile, or handing back a result is normal conversation, not a decision point. Over-using the box makes it noise, which defeats the purpose.
    **Every intake question counts as a decision, including the ones only the human can answer.**
    Names, publisher, prefix, namespace, localization, object ID ranges, and versions all go
    through the options mechanism. None is asked as an open-ended question or a numbered list in
    chat. When the answer is a value only the human knows, the mechanism's free-text entry carries
    it (in Claude Code, *Other*). Step 01 says what to offer as options for each question. Why: an
    open-ended chat question is easy to half-answer or skip past — exactly the failure this rule
    exists to prevent.
    **The mechanism, per harness:**
    - **Claude Code — `AskUserQuestion`:** up to four questions per box, 2–4 options each, with a
      free-text *Other* added automatically; multi-select where several answers apply.
    - **GitHub Copilot Chat in VS Code — the `askQuestions` tool:** several questions in one
      carousel, each single-select, multi-select, or free text.
    - **GitHub Copilot CLI — the `ask_user` tool:** a choice question there takes no typed answer,
      so add an explicit *I'll type it* choice and follow it with a free-text question.
    - **Anything else:** its closest equivalent. Where the mechanism takes one question at a time,
      ask the same questions one after another. Only when a harness has no question mechanism at
      all, ask one question per message with its options labelled, and say why.
6b. **Don't install tooling without asking — and look harder first.** Before concluding a required compiler/runtime is missing and reaching for an install, check whether the human's own IDE already provisions one privately for the tool in question — e.g., VS Code's AL extension gets its .NET runtime from a companion ".NET Install Tool" extension, not a system-wide install, at a path that differs by OS: `~/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/` on macOS, `~/.config/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/` on Linux, `%APPDATA%\Code\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\` on Windows — check the one matching the actual machine, not just the first one you think of, *before* assuming none exists. If the human's own editor can already do the thing you're about to install a tool for, that's a strong signal the tool already exists somewhere you haven't looked. Installing anything is itself a human-in-the-loop decision (rule 6) regardless of what a fallback option elsewhere in this runbook lists as available — on a real project the agent skipped the search, wrongly installed a fresh runtime, and had to remove it.
6c. **From Step 08 onward, check in only after a step that hands the human something to act on.**
    When a PROVE step's own work is finished — its outputs written, its exit gate met, and the
    normal end-of-step summary given — decide which kind of step just closed:
    - **It produced a new package, or a document or findings the human must review or decide on**
      (typically Steps 08 and 09 when they changed code or left findings open): close with a second
      message that puts the choice through the interactive mechanism (Rule 6a) — proceed directly
      into the next step now, or stop here so the human has room to review, run, or publish what was
      produced. State how to resume when ready (e.g., "say 'continue' or name the step to run next").
    - **It produced nothing the human needs to act on yet** (Step 10's as-built documents, which are
      reviewed at the Step 11 → Step 12 hand-off; Step 08 or 09 when nothing changed): say so in one
      line — e.g., "Step 10 done; starting Step 11 — say stop to pause" — and continue.

    This is a deliberate, narrow exception to Rule 6a's own "don't wrap ordinary progress in a
    decision box" guidance, used only where "keep going or pause" is a genuine decision. Steps
    01–07 are unaffected — Operating Rule 6's own approval gates already pace BUILD. **The Step
    11 → Step 12 boundary is a special case of this rule, not an addition to it** — see Step 12's
    own note on the hand-off moment, which replaces this generic check-in for that one specific
    transition.
6d. **Zero-install first — never turn setup into the human's job.** Before proposing *any* install (runtime, SDK, CLI, package, extension) or *any* manual
    setup step for the human (editing `PATH`, a shell profile, or an environment variable), work
    through this order and stop at the first option that works:
    1. **What the human's editor and extensions already provide.** For AL, the **AL Language
       extension** provides the AL tools in two ways, with nothing to install:
       - **In GitHub Copilot Chat in VS Code,** its tools are built in (`al_build`, `al_publish`,
         `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`, `al_getnextobjectid`,
         `al_symbolrelations`, and debugging tools).
       - **For any other MCP host** (Claude Code, Copilot CLI), its bundled AL MCP Server
         (`altool launchmcpserver`) runs on the .NET runtime VS Code already provisioned for it.
         See ALL ALONG → AL MCP Server.
    2. **What's already installed on the machine,** on `PATH` or in standard install locations.
    3. **Only then, an install:** asked for under Rule 6b, using the vendor's standard installer.

    **Never ask the human to edit `PATH`, a shell profile, or environment variables.** If a tool
    needs a path or variable, put it in the configuration or launcher script *you* create.

    **The test before proposing any setup:** would a functional consultant who has only VS Code and
    the AL Language extension have to do anything by hand? If yes, look again.

    **Never hand the human a setup task the agent can do itself.** Connecting the AL tools,
    downloading symbols, and keeping the editor's view current are the
    agent's job (ALL ALONG → AL MCP Server, Symbols, and Keeping the Editor in Sync). The human's
    part is limited to:
    - approving the AI tool's own permission prompts, and
    - a browser sign-in when a tool reaches a live Business Central environment.

    Ask for more only when something is actually broken and the agent has run out of options.
    Then name the exact command, and first confirm it exists: for an AL command, check the AL
    Language extension's `package.json` (`contributes.commands`). **Never send the human to the
    Command Palette to set up the AL MCP Server.** The AL Language extension has no command that
    sets one up or registers one. **Never route AL tooling through a third-party VS Code
    extension** the human would have to install first.

    **Why this is a rule, not advice:** a step a developer shrugs off can stop a functional
    consultant cold, and an agent reaching for an install or a dead-end Command Palette trip in
    front of a client makes the whole framework look careless — this has already happened four
    separate times (`RunbookChangelog.md`).
7. **Log every deviation immediately.** Any departure from FRD or TDD goes in the ChangeLog before the next batch starts (see *All Along*).
8. **Work in the human's chosen working language.** The very first question of the routine (PRE-01) asks which language the human wants to work in. From then on, every question, options box (Rule 6a), explanation, and status message is in that language. **Always in English, regardless:** this runbook and the Standards Guide, AL code, object and identifier names, commit messages, and the engineering documents (`FRD`, `TDD`, `SanityCheck`, `PostDevTDD`, `ChangeLog`, `GapAnalysis`, `CodeReview`, `ProjectMemory`) — so no second-language copy can drift from them. **Kept verbatim in their original language:** raw requirements (`requirements/`) and tester feedback (`TestingFeedback.md`). When the human names a BC concept in their own language, map it to the standard object through the translation glossary (ALL ALONG → Translations & Terminology) rather than guessing.

---

# PHASE: DEFINE

Goal: turn a business need into a validated, complete scope and a filled-in parameter sheet — before any design work.

## PRE-01 — State the Problem

**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**
- **Ask the working language first — before any other question or action in the routine**
  (Operating Rule 8). Ask it in English, through the options mechanism (Rule 6a), with English
  listed first and a free-text choice for any other language. Continue the rest of the engagement
  in the language chosen. Record it in `ProjectMemory.md` immediately; Step 01 §1.9 carries it
  into `docs/ProjectParameters.md`.
- **Ask how to be notified, right after the working language** (ALL ALONG → Notifications): Claude app, sound, desktop notification, any combination, or none. Record the answer in `.ocpf/notifications.json` and apply it now, so every question from here on — the approvers question included — reaches the human even when they've stepped away.
- **Ask who approves, next** (Rule 6a), because it decides how many sign-offs follow — starting
  with this step's own. *Who signs off on the design documents?* **One person for every role**
  (the Functional Consultant, Technical Lead, and Dev Manager sign-offs are all the same
  reader) / **Separate people for different roles**. Record it in `ProjectMemory.md`; Step 01 §1.1
  carries it into `docs/ProjectParameters.md` as **Approvers**. With one approver, sign-offs that
  are serial waits on the same reader are combined: PRE-01's with PRE-02's, and Step 03's with Step
  04's. The FRD sign-off (Step 02) stays separate, since the TDD is written from it.
- **Fetch the OCPF AL Development Standards Guide into the project, before anything else needs
  it**. Every phase from PRE-02 onward cites it as **Standards §**
  — PRE-02's own gap-analysis checklist is Standards Part 6 — so it has to be on disk from the
  first step, not fetched at Step 05 alongside the other libraries. Get
  `standardsGuide/ocpfALDevStandardsGuide.md` from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/` into a `standardsGuide/` folder in this
  project's root, and **add `standardsGuide/` to this project's `.gitignore`** — see ALL ALONG →
  OCPF AL Development Standards Guide for the full fetch, refresh, and hygiene policy, and say so
  plainly to the human rather than fetching silently.
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
- Before anything else, create `ProjectProgress.md` (ALL ALONG → Project Progress Tracker), **in
  the project root — always, not `docs/`** — one row per step of the whole
  routine, every row blank except this one, marked `In Progress`. It's the first project document of
  the engagement (only the notification settings come before it).
- Write a problem statement: what business outcome is required, who the consumers are (users, other systems, AI tools, BI/reporting), which **countries and languages** the users work in (countries confirmed once in Step 01's first box, languages in §1.9), and what is explicitly out of scope.
- Capture the domain vocabulary the design will anchor to (entity names, categories, known pain points).
- Produce an initial entity/object list from stakeholder domain knowledge.
- As the agent: identify duplicates, ambiguous terms, and outdated/legacy terminology in the initial list; ask clarifying questions about scope and consumer use cases. Do not resolve ambiguities silently.

**Outputs:** `standardsGuide/` (fetched, gitignored), `requirements/` (seeded, if any raw input was provided), `ProjectProgress.md` (seeded, project root), `ProblemStatement.md` — purpose, scope, out-of-scope, target consumers, initial entity list, open questions.

**Exit gate:** The Standards Guide is present in `standardsGuide/` and gitignored. The notification choice is recorded in `.ocpf/notifications.json`, applied, and tested (ALL ALONG → Notifications). Functional Consultant signs off on the problem statement and initial entity list (Stage↔Step Map, Stage 1) — or, when **Approvers** is one person, this sign-off moves to the end of PRE-02 and is given together with that step's, on the problem statement and expanded list at once.

## PRE-02 — Structured Gap Analysis

**Inputs:** `ProblemStatement.md` and the initial entity list.

**Actions:** Run the gap analysis checklist against standard BC modules (Standards Part 6). For every transactional entity, check each category:
- **Analytical detail tables** — sub-ledgers, detailed ledger entries, value entries, registers, audit trails (Standards §6.1).
- **Posted / archived versions** — the posted equivalent of every open document, header *and* lines (Standards §6.2).
- **Reference / lookup tables** — payment terms/methods, currencies, countries, UoM, locations, shipment methods, item categories, salesperson/purchaser codes (Standards §6.3).
- **Secondary document types** — quotes, blanket orders, return orders alongside orders (Standards §6.4).
- **Modern vs. legacy tables** — replace legacy price tables etc. with current equivalents; use modern entity names (Standards §6.5).
- **Tax framework tables** — decide per the target localization; do not assume (Standards §6.6).
- **Global vs. localized scope** — mark each entity as global or jurisdiction-specific.
- **Regional terminology** — for every standard BC concept the extension will name in captions or messages, note whether its wording differs across the countries named in `ProblemStatement.md` (for example VAT / GST / Tax; Credit Memo / CR/Adj Note; County / State — Microsoft's actual US and Australian terms). Don't resolve the terms here — list them; Step 01 §1.9 creates the translation glossary and Standards Appendix D verifies each term.

**Outputs:** Expanded, de-duplicated entity list with each entity tagged (analytical / master / setup / document / posted / lookup), R/W intent noted, and global-vs-localized noted. Gap log: what was added and why.

**Exit gate:** Technical Lead reviews the expanded list; all gaps are closed or explicitly deferred with reasoning (Stage↔Step Map, Stage 2). When **Approvers** is one person, this is one sign-off covering `ProblemStatement.md` and the expanded list together (PRE-01's deferred sign-off included).

## 01 — Populate the Intake Sheet (Project Parameters)

**Inputs:** Expanded entity list; platform/tenant constraints from the stakeholder. (The BC symbol file for the target version is an output of this step: the agent downloads it at §1.10.)

**Actions:** Complete **every** field below. Replace every placeholder. These values override all defaults for the rest of the routine. **This block is the authoritative source** — the single source of truth for every name, ID, version, prefix, namespace, and quoting decision in the project. The Standards Guide deliberately keeps no copy of it and defers to whatever is filled in here (Standards, "Authoritative-source rule"); nothing in AL code hardcodes a value that belongs in this block.

**Ask first, don't infer — and ask interactively** (Operating Rule 6a). Every question in this step
goes through the options mechanism Rule 6a names for this harness, never as an open-ended question
or a numbered list in chat. **Use as few boxes as the questions allow:** a box holds up to four
questions, each with its own options, and questions share a box only when none depends on another's
answer. Where the harness asks one question at a time, ask the same questions in the same order.

**Before the first box,** read `ProblemStatement.md` for suggestions, and read Microsoft's live
*Country/Regional Availability and Supported Languages* page (§1.9) so every country and language
offered is one Business Central supports.

**Option counts.** `AskUserQuestion` needs 2–4 options per question, and every harness's free-text
entry covers anything else. With only one suggestion, pair it with *I'll type it*. With more than
four candidates (countries, languages), offer the four most likely and say in the question that
others can be typed.

**A suggestion is a candidate the human picks, never an answer recorded on their behalf.**
Nothing goes into `docs/ProjectParameters.md` until the human has selected or typed it. Build
suggestions only from what the human said or confirmed, never from an email domain or a guess at
house style — an inferred publisher and prefix once forced a full-project rename.

| Box | Questions | Options to offer (free-text entry always available, Rule 6a) |
|---|---|---|
| **1 — Identity** | 1. What is the Extension Name? | Up to three names built from the problem statement's own wording, each labelled as a suggestion. |
| | 2. Who is the Publisher? | Only names the human has already written or uploaded, quoted verbatim, each with where it came from. If there are none: *I'll type it* / *Decide after the other questions* — then ask it again, alone, before Box 2. |
| | 3. What is the Deployment Target? | *SaaS PTE* / *OnPrem PTE* / *AppSource*, the best fit for the problem statement first. |
| | 4. Which countries will users work in? *(multi-select)* | The countries `ProblemStatement.md` names that Business Central is available in. **Countries are asked only here** — Localization and §1.9 reuse the answer. |
| **2 — Naming** *(built from Box 1)* | 5. What AL object prefix should be used? | Two or three short lowercase prefixes built from the name and publisher. |
| | 6. Which namespace? | `<Publisher>.<ExtensionShort>` built from Box 1 *(recommended)* / one alternative spelling / *No namespace* (only for a deliberate reason, e.g. a BC version that predates namespaces). One answer records both **Use Namespace** and **Namespace**. |
| | 7. What Localization applies? | Up to three of the Box 1 countries as codes (e.g. `US`), then `W1`. |
| | 8. Which Business Central version? | The current Business Central online major version *(recommended)* and the one before it, looked up on Microsoft Learn, never from memory. A sandbox the human already has is the natural choice. Don't ask for `runtime`: read it from Microsoft Learn's [Choose runtime version in AL](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-choosing-runtime) table (runtime `17.0` ships with Business Central 28.0). |
| **3 — Permission sets & IDs** *(built from Box 2)* | 9. What Permission Set App Code identifies this extension? | Two or three uppercase codes built from the name that fit `13 − (prefix length)` characters (e.g. `NAICS`). The question says the code must differ from every other extension using this prefix (Standards §5.4). |
| | 10. Do other extensions already use this prefix? | *No, this is the first* / *Yes — I'll type their App Codes or permission set names*. If one matches answer 9, ask 9 again, alone. If the human isn't sure, recommend a more specific code. |
| | 11. Which Object ID range? | Complete ranges, each with its size: any range the human's material names (e.g. *80300–80339 — 40 IDs*); *50100–50149 — 50 IDs*, described as "the AL template's default: only if no range has been assigned to you"; or type one as `start–end`. A typed range whose start is above its end is asked again. |
| | 12. Is there another Object ID range? | *No* / *Yes*. Each *Yes* opens a box with questions 11 and 12 again, for the next range. |
| **4 — Onboarding** *(§1.6)* | 13–15. Assisted Setup Wizard? Role Center Activity Cues? Departments / "My Business Central" placement? | *No* / *Yes* for each, with §1.6's one-line description of what it is. A box of follow-ups then asks the specifics of each *Yes*, offering choices drawn from the problem statement. |
| | 16. Permission Sets required? *(only if the entity list has no new table)* | *No — the extension adds no tables* / *Yes*. Not asked when the extension owns a table: then it's `Yes` (§1.2). |
| **5 — Working setup** | 17. Split work across models? *(§1.7)* | *One model for everything (recommended)* / *Recommended split* / *Customize each role*. |
| | 18. Leave this framework's own files out of the project's repository? *(§1.8)* | *Yes (recommended)* / *No, track them*, with §1.8's one-sentence explanation in the question. |
| | 19. Which language is the AL source text written in? *(§1.9)* | *`en-US` (recommended)*, with Standards §8.1's reason in one sentence, or another language typed in. |
| **6 onward — Languages** *(§1.9)* | The per-country, per-language, and document questions in §1.9. | As §1.9 lists. |
| **Last — Confirm** | 20. Is this sheet right? | Show the complete sheet first — every Object ID range with its size and the derived permission set names. *Confirm the sheet* / *Change something* (then ask only the questions being changed). |

**Why question 9 exists**: permission sets named from the prefix alone (`OCPF - READ`) collided
across every extension built with that prefix (Standards §5.4).

**Once the human confirms the sheet, the agent sets up the AL project before DESIGN** — §1.10.

**Tell the human, at intake, where their built packages will live.** This framework always
writes `.app` packages to a fixed folder named **`outputAppPackage/`** in the project root —
never `out/`, `output/`, or anything ad hoc (see ALL ALONG → Packaging & Versioning for the full
naming rule, the never-delete-a-previous-package policy, and the Schema Sync Mode / Force Sync
guidance that goes with every completed build). Mention this once, plainly, during intake —
before Step 07 ever produces the first package — so where their files will land is established
up front, not discovered by surprise the first time a build finishes.

### 1.1 Extension Identity

| Parameter | Placeholder | Guidance & Example |
|---|---|---|
| **Extension Name** | `<ExtensionName>` | App name, not the object prefix. No AL quotes. Written to `app.json "name"`. Example: `ACME APIs` |
| **Publisher** | `<Publisher>` | No AL quotes here. Written to `app.json "publisher"`. Example: `Contoso` |
| **Deployment Target** | `<DeploymentTarget>` | One of the allowed values below. Governs `app.json` and `launch.json`. |
| **Use Namespace (y/n)** | `<UseNamespace>` | Whether this project's AL objects declare a `namespace`. Default `Yes` — omit it only for a deliberate reason (e.g. a target AL/BC version that predates namespaces). If `No`, the `Namespace` row below is N/A and no generated file gets a `namespace` line. |
| **Namespace** | `<Publisher>.<ExtensionShort>` | N/A if Use Namespace = `No`. Otherwise no quotes; PascalCase segments, no spaces. Example: `Contoso.AcmeAPIs` |
| **Localization** | `<Localization>` | No quotes. **Set once here** — Part 5 derives all field/table inclusion from this value. Examples: `W1`, `NA`, `EU`, `US`. |
| **Approvers** | `<Approvers>` | `One person` or `Separate roles`. Asked at PRE-01, not here (it governs PRE-01's own sign-off); recorded here. With `One person`, the PRE-01 + PRE-02 sign-offs and the Step 03 + Step 04 sign-offs are each given once, together (Operating Rule 6). |

**Deployment Target — allowed values (choose exactly one):**
- `AppSource` — Microsoft AppSource distribution.
- `SaaS PTE` — Business Central SaaS per-tenant extension.
- `OnPrem PTE` — on-premises per-tenant extension.

**Quoting reference — applies to every AL and config file in the project:**

| Context | Quote style | Example |
|---|---|---|
| `app.json` / `launch.json` values | Standard JSON strings | `"publisher": "Contoso"` |
| AL string property values | Single quotes | `APIPublisher = 'contoso';` |
| AL object names | Double quotes | `page 90800 "acmeCustomers"` |
| BC source field names containing spaces | Double quotes on the field name | `Rec."Document No."` |

**Worked example:**
- `Extension Name = ACME APIs`
- `Publisher = Contoso`
- `Deployment Target = SaaS PTE`
- `Use Namespace = Yes`
- `Namespace = Contoso.AcmeAPIs`
- `Localization = W1`

### 1.2 Object ID Allocation

Collected by Box 3's questions 11–12 — one row per range, in the order given:

| Block | From | To | Notes |
|---|---|---|---|
| **Primary allocation** | `<fromObjectId>` | `<toObjectId>` | The first range given; the main scope. |
| **Additional allocation 1** *(if any)* | `<additionalFrom1>` | `<additionalTo1>` | Second range, if the human answered *Yes* to "another range?" |
| **Additional allocation N** *(if any)* | … | … | Repeat one row per further "yes" — there is no fixed limit. |

| Parameter | Value | Guidance |
|---|---|---|
| **Permission Sets required?** | `Yes` / `No` | `No` only when the extension introduces zero new tables of its own, e.g. a pure page or report extension (Standards §5.3). The moment the project owns a table, it's `Yes` — not asked (Box 4, question 16). If `Yes`, reserve ≥ 2 IDs inside the primary range. |

> **Rule:** Never use object IDs outside the allocated ranges. Maintain the object register as a separate project artifact. If the project plans any new table, `Permission Sets required` must be `Yes` and they must be planned before code generation — do not accept `No` alongside a table in the entity list without flagging the contradiction back to the human.

**Worked example** (two ranges): Box 3 — the human types `90800–90899` and answers *Yes* to
"another range?" → the next box — the human types `91500–91549` and answers *No*. The confirmation
sheet shows "90800–90899 — 100 IDs" and "91500–91549 — 50 IDs". Final: Primary `90800`–`90899`;
Additional allocation 1 `91500`–`91549`; Permission Sets required = `Yes`.

### 1.3 Naming & API Parameters

> These values govern every AL object, API registration, and permission set. Do not hardcode them — derive all names from this table. **These parameters directly control the entity-naming patterns used in Standards Part 2.**

| Parameter | Placeholder | Guidance & Example |
|---|---|---|
| **AL Object Prefix** | `<prefix>` | Short, lowercase, no quotes. Used in page names and identifiers. Example: `acme` |
| **APIPublisher** | `'<apiPublisher>'` | Derived, not asked: the Publisher in camelCase (Standards §2.7). Single quotes in AL page metadata. Example: `'contoso'` |
| **APIGroup Prefix** | `<prefix>` | The AL Object Prefix; each group name follows it in PascalCase, no underscore (Standards §2.7). Example: `acme` |
| **APIVersion** | `'v<Major>.<Minor>'` | Single quotes in AL. Example: `'v1.0'` |
| **Namespace** | `<Publisher>.<ExtensionShort>` | Same value as Section 1.1; N/A if Use Namespace = `No`. Example: `Contoso.AcmeAPIs` |
| **Permission Set App Code** | `<APPCODE>` | Uppercase letters or digits, no spaces, unique among **every** extension that uses this prefix (Standards §5.4). At most `13 − (prefix length)` characters, so every name fits the 20-character limit. Example: `SALESAPI` |
| **Permission Set Names** | `<PREFIX> <APPCODE>, VIEW` / `<PREFIX> <APPCODE>, EDIT` | Derived, not asked: `<PREFIX>` is the AL Object Prefix in uppercase. No AL quotes here. Example: `ACME SALESAPI, VIEW` (19 characters) |

**Entity-naming patterns** — all derived from the prefix above, all camelCase per Standards §2.7 (examples use prefix `acme`):

| Element | Pattern | Example |
|---|---|---|
| `APIGroup` | `'<prefix><PascalCaseGroupName>'` | `'acmeCoreFinancial'` |
| `EntityName` (singular) | `<prefix><PascalCaseSingular>` | `'acmeGeneralLedgerEntry'` |
| `EntitySetName` (plural) | `<prefix><PascalCasePlural>` | `'acmeGeneralLedgerEntries'` |
| `ODataKeyFields` | `SystemId` | Always. On every page. |
| Page object name | Same as `EntitySetName`, in double quotes | `page 90801 "acmeGeneralLedgerEntries"` |

- `EntitySetName` and `EntityName` must be ≤ 30 characters **including** the prefix. Apply abbreviations from Standards §4.2 as needed.
- **Singleton tables** (e.g., General Ledger Setup, Company Information): set `EntityName = EntitySetName`. The OData response is a single-entry collection.
- **Legacy vs. modern names:** use the modern BC name in entity identifiers. Example: Table 167 "Job" → `EntityName = '<prefix>Project'`.

### 1.4 Platform & Runtime

| Parameter | Placeholder | Guidance & Example |
|---|---|---|
| **AL Runtime** | `<major.minor>` | No quotes. Set in `app.json "runtime"`. Example: `16.0` |
| **BC Application Minimum** | `<major.minor.build.revision>` | No quotes. Set in `app.json` dependencies. Example: `27.0.0.0` |
| **Recommended BC Version** | `<BC version>` | Informational; validation target. Example: `27.5+` |
| **Symbol Source** | `<BC symbol file version>` | Symbol file used for verification (Standards Appendix B), including whether it's W1 or localized and where it came from. Filled in by the agent at §1.10, not asked. Example: `BC v27.5, W1, Microsoft public symbol feed` |

> Localization is **not** repeated here — it is set once in Section 1.1.

### 1.5 Feature Flags (Fixed — Not a Parameter)

`NoImplicitWith` is **enabled and enforced** on every project. This is a given, not a choice — do not change it.

| Flag | Status | Reason |
|---|---|---|
| `NoImplicitWith` | **Enabled (enforced)** | Requires every field source to be prefixed with `Rec.`, which prevents silent field-scoping bugs where an unqualified field name resolves to the wrong record. Enforcing it project-wide keeps all generated AL consistent and removes a whole class of ambiguous references. |

### 1.6 Onboarding & Discoverability

> These decisions shape real objects — a wizard page, Role Center cue fields, department/Tell Me
> entries — so they're asked at intake (Box 4), not part-way through DESIGN when the object
> inventory is already being drafted around their absence.

The three questions, each *No* / *Yes* with this description, and the specifics of a *Yes* asked in
one follow-up box:

1. Should this extension include an **Assisted Setup Wizard**? If yes, what should it configure
   (e.g., number series, default setup values, sample/demo data, permission set assignment)?
2. Should the Role Center get **Activity Cues** (the numeric tiles summarizing counts that need
   attention — e.g., overdue items, unpaid records)? If yes, which cues, each one's underlying
   filter, and what it opens when clicked?
3. Should this extension be **findable via Departments / "My Business Central"** (the role-based
   menu and Tell Me search surface — a different discovery path than the Role Center)? If yes,
   under which department/category, and which pages should appear there?

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Assisted Setup Wizard** | `<AssistedSetupYN>` | `Yes`/`No`. If `Yes`, list exactly what it configures — not a bare yes. |
| **Activity Cues** | `<ActivityCuesYN>` | `Yes`/`No`. If `Yes`, list each cue: what it counts, its filter, and its drill-through target. |
| **Departments / My Business Central placement** | `<DepartmentsYN>` | `Yes`/`No`. If `Yes`, name the department/category and which pages appear there. |

A `No` to any of these is a valid, final answer — not a placeholder to revisit later. Record the
answer and reasoning in `ProblemStatement.md` or the Project Parameters sheet; a `Yes` answer's
specifics feed the FRD (Step 02) object inventory and the TDD (Step 03) per-object spec directly.

### 1.7 Model & Effort Assignment (Optional)

> Ask once, at intake, before DESIGN begins — Step 02/03 authorship depends on the answer.
> If the human has no preference, skip this: everything runs through the main model, as if this
> section didn't exist.

The executing agent can't switch its own model mid-session, but it *can* delegate a
self-contained task to a subagent running a different model, get a result back, and act on it —
a mechanism-agnostic capability, not tied to any one harness. This runbook uses exactly that, for
three fixed roles, kept deliberately generic (no vendor/model names) since it travels to projects
on other harnesses:

Ask it as Box 5's question 17, one question with three options:
- ***One model for everything (recommended)*** — no role assignment; this section doesn't apply.
- ***Recommended split*** — name the models this harness actually offers: a capable general model
  for Main, a fast lower-cost model for Light, the strongest reasoning model for Reasoning, High
  thinking effort for all three. Recorded exactly as named.
- ***Customize each role*** — then ask each role's **model** and **thinking effort** as two
  separate questions, never one merged question: one box with the three model questions (Main,
  Light, Reasoning), then one box with the effort question for each role whose chosen model has an
  effort setting. Every effort question offers **High first, as recommended, for every role,
  regardless of the model chosen** — see the rule below. A role whose model has no effort setting
  isn't asked; record `N/A` rather than leaving it blank.

If the harness can't run sub-agents at all, don't ask: say that everything runs through one model
and record `No`.

What each role is *for*, so the human is choosing a model (and confirming or overriding High) with
the actual job in mind:

1. **Main role** — does the bulk of the work: all BUILD code generation, all actual code edits
   (including applying what the other two roles report), and end-to-end ownership of the
   project's continuity documents — ChangeLog, Object Register, ProjectMemory, and
   `TestingFeedback.md` itself (recording sessions verbatim, then logging the triage decision —
   implement / schedule / reject — once the reasoning role's diagnosis below confirms it). A
   capable general-purpose model is the right fit here.
2. **Light role** — fast, cheap, checklist-driven verification only: the Step 05
   **post-generation** pre-flight pass in full (see Step 05 for the actual list — don't
   re-enumerate it here, it drifts). Notably includes **symbol verification**, deliberately not
   given to the reasoning role: it's a lookup against ground truth, not a judgment call, so the
   fast/cheap role handles it fine. Reports findings; never edits code itself. A fast, lower-cost
   model is the right fit here.
3. **Reasoning role** — heavier-reasoning, fresh-eyes work: Sanity Check (Step 04), Code Review
   (Step 09), Gap-Fit Test (Step 08), FRD authorship (Step 02), TDD authorship (Step 03), and
   root-cause troubleshooting/diagnosis (Step 07, and diagnosing *why* a PROVE-phase testing-feedback
   report is real, before the main role triages and records it). Reports findings, drafts, or
   diagnoses; never edits code or the continuity documents itself. A stronger-reasoning model is
   the right fit here.

**High is the recommended default thinking effort for all three roles — always, regardless of
which model is assigned to which role.** This is a quality-first framework: Operating Rule 5
already requires zero errors and zero warnings before PROVE, and every one of the three roles'
jobs — generating and editing AL, verifying against ground truth, or doing fresh-eyes review —
benefits from more thinking effort, not less. Present High as the recommended option, with that
reasoning, through the interactive mechanism (Rule 6a) for every role's effort question. A human
who wants to trade some of that for speed or cost may still choose Medium — most plausibly for the
**Light** role, whose checklist-matching work has the smallest marginal benefit from extra effort
of the three — and that's a legitimate, explicit override, not a mistake to talk them out of. The
point is that the *default offered* is High everywhere; a lower setting is something the human
opts into, never something the framework assumes on their behalf.

**Not every model or harness exposes a thinking-effort dial.** If a role's assigned model has no
such setting, record `N/A` for that role rather than leaving it blank — a blank reads as "not yet
asked," `N/A` reads as "asked, and the model has no dial to turn."

**Worked example** (Main and Reasoning accept the recommended default; Light is overridden for
cost — a realistic mix, not a rule that Light must always be lowered):

| Role | Model | Thinking Effort |
|---|---|---|
| Main | Sonnet | High |
| Light | Haiku | Medium *(human overrode the recommended High, for cost)* |
| Reasoning | Opus | High |

**The division of labor is fixed regardless of which physical models are assigned to each role.**
The light and reasoning roles investigate, draft, or diagnose; the main role is the *only* one
that edits code and the *only* one that owns the continuity documents end to end. This keeps one
consistent author/style across the codebase — the same discipline Step 09 already asks for
internally ("early and late batches often drift — normalize") — and keeps root-cause tracing in
one continuous thread instead of fragmenting across cold hand-offs. A role holder's output is
always relayed back and integrated by the main role; never applied blind.

**How to delegate a role in practice** (adapt to whatever mechanism the executing agent's own
harness provides for running a task under a different model, **and set that role's configured
thinking effort when the mechanism allows it** — the same way the model itself is set): hand the
role-holder the specific inputs its task needs — the relevant project documents, the code or
finding in question, the standing checklist — plus a pointer to this runbook itself, since every
rule in it applies to whichever role is acting, not only the main role.

**When the OCPF plugin is installed**: the plugin ships the Light
and Reasoning roles as ready-made sub-agents, `ocpf-light` and `ocpf-reasoning`. In Claude Code
they appear as `ocpf-bc:ocpf-light` and `ocpf-bc:ocpf-reasoning`. They already carry this
section's division of labor: they report, draft, or diagnose, and are denied file-editing tools.
If role assignment is configured, delegate each role's tasks to its sub-agent, passing the
configured model and thinking effort where the harness allows a per-delegation override.
Where it doesn't, tell the human which model the sub-agent will actually run on. Harnesses that
can't run sub-agents at all include Claude Chat, Microsoft Copilot Cowork, and the github.com cloud
agent. This doesn't change the
default: with no role assignment, everything still runs through the main model.

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Model/role assignment** | `<ModelRolesYN>` | `No` (default — one model for everything) or a 3-row table: Main role / Light role / Reasoning role → the **model and thinking effort** (High recommended / Medium / N/A) assigned to each — from *Recommended split*, or asked as two separate questions per role under *Customize*. |

### 1.8 Framework File Tracking (`.gitignore`)

Box 5's question 18. Explain `.gitignore` in the question itself, since many people directing a
build have never needed to know Git: *"`.gitignore` lists files Git leaves out of commits and
pushes — they stay on disk and work normally. Should this framework's own files (this runbook, its
changelog, and its schematics) be left out of this project's repository?"*
- ***Yes, leave them out (recommended)*** — the framework is distributed from its own repository;
  its methodology isn't part of what the client receives.
- ***No, track them*** — a teammate cloning the project sees exactly how it was built.

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Framework files in `.gitignore`?** | `<FrameworkGitignoreYN>` | `Yes` (**default, recommended**) excludes this runbook, its changelog, and its schematics (if present) from this project's git tracking. `No` tracks them alongside the project's own code. In a project set up by the OCPF plugin, the same answer also covers the `.ocpf/` folder (ALL ALONG → OCPF Plugin). |

This choice covers only those framework files. `standardsGuide/`, `patterns/`, `.alpackages/`, and
the agent's tooling scripts are always gitignored, and the BCQuality snapshot lives outside the
project — none of that is asked (ALL ALONG → Repository Hygiene).

### 1.9 Languages & Translation

> Asked in the working language (Operating Rule 8), as Box 5's question 19 and the boxes after
> it. The rules each answer applies are Standards Part 8.

**Microsoft's live page is the only source for countries and languages:** *Country/Regional
Availability and Supported Languages* —
<https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations>.
Read it before Box 1, never answer from memory or from a copy (Microsoft updates it several times a
year), and if it can't be reached, say so and ask the human rather than guessing.

**1. Languages, per country — Box 6.** One multi-select question per country from Box 1 (up to
four per box), offering **only the languages Business Central supports in that country**, each
showing the three-letter ID BC people recognize and the culture code that will be recorded (e.g.
*"French (Canada) — FRC → `fr-CA`"*). Countries aren't asked again.
- **Classify each chosen language** per Standards §8.8 — Microsoft-translated, partner-translated,
  or not supported by BC — and say what that means in one sentence:
  - **Partner-translated:** ask, in the next box, which partner localization or language app the
    customer uses, since it becomes that language's terminology source.
  - **Not supported by BC** (including every right-to-left language): don't offer it. If the human
    types it, say plainly that BC's own interface won't appear in that language and offer the
    country's English instead. Only if the human insists, record it as outside platform support,
    and ask them to confirm with the partner localization first.
- **Cross-check against §1.1 `Localization`.** If they don't line up — `Localization = AU` with no
  `en-AU`, or the reverse — raise the mismatch rather than accepting it.

**2. Source language — Box 5, question 19.** Offer **`en-US` first, labelled recommended**, with the
reason in one sentence (Standards §8.1). If the human isn't sure, it's `en-US`. If they choose
another language, state the consequences from Standards §8.1 before recording it.

**3. Source wording.**
- **Any target other than `en-US` alone:** source wording is Microsoft's W1 English (Standards
  §8.1). Say so and explain the one-line reason — every market's wording then comes from its own
  translation file.
- **`en-US` is the only target language and §1.1 Deployment Target isn't `AppSource`** (AppSource
  requires translation files — Standards §8.10): ask, recommended option first:
  - *W1 wording in source, plus an `en-US` translation file (recommended)* — another market later
    needs no source changes.
  - *US wording directly in source, no translation files* — simpler now; adding any other market
    later means revising source strings.

**4. For each target language — two questions, so two languages per box:** is it **required at
first release** (*Required at first release* / *Can follow later*)? And **who reviews it?** Offer
names the human has already mentioned, or *I'll type it* — a named person who reads the language
fluently, never a role, never the agent (Standards §8.7). A partner-translated language's app
question (item 1) joins the same box. Skip this for a project that chose *US wording, no
translation files*.

**5. Documents** — two questions, only when there's a target language other than the source.
- *Which user-facing documents are translated into each required language?* (multi-select):
  *`UserGuide` (recommended)* / *`Deployment` (recommended)* / *None*. Engineering documents stay
  in English only (Operating Rule 8).
- *Do testers need a translated `HumanUnitTestScript`?* *No — they run the language pass from the
  English script, which names the terms each language should show (recommended when testers read
  English)* / *Yes, one per required language*.

Translated documents are produced at Step 12, once the functional test pass is green, so fixes
found in testing don't make them stale.

**Order after Box 6:** ask item 3 first, in its own box together with item 6's two questions,
because its answer decides whether items 4 and 5 are asked at all. Then items 4 and 5, up to four
questions per box.

**6. Beyond the interface** — *No* / *Yes* each, with the specifics of a *Yes* as free text.
- Do customer-facing documents (invoices, emails) need to follow the **customer's** language
  rather than the user's (Standards §8.9)?
- Does the extension store user-entered text that needs **per-language versions** (the translation
  table pattern, Standards §8.9)?

*API page and query caption locking isn't asked here — no objects exist yet. It's decided at Step
03, once the object inventory does.*

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Working language** | `<WorkingLanguage>` | From PRE-01. |
| **Target languages** | table | One row per language: culture code · three-letter ID · country · support case (Microsoft / partner / not supported by BC) · required at first release (Yes/No) · reviewer (name) · terminology source (Microsoft, or the named partner app). |
| **Source language** | `<SourceLanguage>` | `en-US` unless the human chose otherwise, with the consequences noted. |
| **Source wording** | `<SourceWording>` | `W1` (with a translation file per target, `en-US` included) or `US, no translation files` (only when `en-US` is the sole target). |
| **Document languages** | table | Document → languages. |
| **Customer-language documents** | `<CustomerLanguageDocsYN>` | `Yes`/`No`, with which documents if `Yes`. |
| **Translatable data** | `<TranslatableDataYN>` | `Yes`/`No`, with which tables/fields if `Yes`. |
| **Translation tooling** | `<TranslationTooling>` | Decided at Step 05. |

### 1.10 AL Project File, AL Tools & Symbols (the agent's job, before DESIGN)

> Operating Rule 2 verifies every design decision against downloaded symbols, so symbols have to
> be on disk before Step 02, not first appear at Step 07. Nothing here needs the human beyond the
> AI tool's own approval prompts (Operating Rule 6d).

Once the human confirms the sheet, and before Step 02:

1. **Write `app.json` once, complete, from the confirmed sheet.** Include the name, publisher,
   version, every `idRanges` entry from §1.2, `platform`, `application`, and `runtime` from §1.4,
   and the `features` Step 05 lists. If `app.json` already exists (for example, the human ran
   **AL: Go!**), keep its `id` GUID and replace the rest. Don't change `idRanges`, `platform`,
   `application`, `runtime`, or `dependencies` again without re-running step 4 below.
2. **Connect the AL tools** if this session doesn't have them yet (ALL ALONG → AL MCP Server).
3. **Download symbols** (ALL ALONG → Symbols). Confirm `.alpackages/` holds Base Application and
   System Application for the §1.4 major version. Record the result as §1.4's **Symbol Source**.
   Add `.alpackages/` to `.gitignore` now (ALL ALONG → Repository Hygiene).
4. **Keep the editor in sync** (ALL ALONG → Keeping the Editor in Sync). If VS Code's AL
   extension loaded this project before the agent changed `app.json`, the editor keeps showing
   the old ID ranges and missing symbols as red errors. Refresh it now, while no `.al` file
   exists yet.

**Outputs:** `docs/ProjectParameters.md` — the completed Project Parameters block (above, all placeholders replaced), persisted as its own tracked document so every later step, and every role under §1.7, reads it from disk rather than depending on conversation history; an empty **Object Register** artifact seeded with the allocated ID ranges; the project's `.gitignore` populated per this section and per ALL ALONG → Repository Hygiene; **`docs/TranslationGlossary.md`**, created with the regional terms PRE-02 listed (ALL ALONG → Translations & Terminology) — unless the project chose *US wording, no translation files*; `app.json` and `.alpackages/` per §1.10.

**Exit gate:** Every question in this step was asked through the options mechanism. `app.json` matches the sheet, and symbols for the target version are in `.alpackages/` (§1.10). No placeholder remains. **Approvers** is recorded (asked at PRE-01). Deployment Target is one allowed value. Namespace matches between 1.1 and 1.3, or both are correctly N/A if Use Namespace = `No`. Localization is set. If Permission Sets required = `Yes`, ≥ 2 IDs are reserved in the primary range. §1.6's three questions are each answered `Yes`/`No` with specifics recorded for any `Yes`. §1.7 is answered or explicitly skipped — if configured, every one of the three roles has both a model and a thinking effort (or `N/A`) recorded, not model alone. §1.8 is answered (or defaults to `Yes`) and `.gitignore` reflects it. §1.9: every target language is classified against Microsoft's live page and — unless source wording is *US wording, no translation files* — has a required-at-release answer and a named reviewer; source language and wording are recorded; any mismatch with `Localization` is resolved. Human confirms the sheet.

---

# PHASE: DESIGN

Goal: a complete FRD and a self-sufficient TDD, both validated for BC feasibility and internal consistency, before any code.

## 02 — Craft the Functional Requirements Document (FRD)

**Role:** if §1.7 role assignment is configured, drafted by the **reasoning role**, fed
`ProblemStatement.md`, the expanded entity list, and Project Parameters; the main role integrates
the draft (saves it, does the ChangeLog/ProjectMemory bookkeeping) and takes it to the human for
sign-off. Sign-off is unchanged either way — it's the human's, never the drafting role's.

**Inputs:** `ProblemStatement.md`, expanded entity list + gap log, `docs/ProjectParameters.md`.

**Actions:** Write the FRD in business language — *what* the extension does and *why*, not *how*. It must capture:
- Purpose and scope; explicit out-of-scope list.
- Business objectives and the value delivered.
- Target consumers (users, systems, AI tools, reports).
- Platform requirements (BC version, deployment model, compatibility) — from Parameters 1.1 and 1.4.
- Design rules — the non-negotiable constraints governing every object.
- Entity / object inventory — every object with source table, type, and read vs. read/write designation (use the mutability rules in Standards §2.2).
- Non-functional requirements — compilation cleanliness, performance, compliance, deployment.
- **Languages and markets** — from Parameter §1.9: every target language, whether it's required at first release, customer-language document requirements, and any translatable business data. Written as requirements ("Australian users see Australian BC terminology throughout"), not as tooling.

Then **review and validate against the DEFINE artifacts:** every entity in the expanded list appears in the FRD inventory (or is listed as deferred with a reason); every consumer use case from PRE-01 is addressed. For every platform capability the FRD assumes, verify BC can actually do it — do not write requirements based on assumed platform behavior.

**Outputs:** `FRD.md`.

**Exit gate:** FRD + Dev Manager sign-off. Every DEFINE-phase entity is accounted for. No unverified platform assumptions remain (Stage↔Step Map, Stage 4).

## 03 — Craft the Technical Design Document (TDD)

**Role:** if §1.7 role assignment is configured, drafted by the **reasoning role**, fed `FRD.md`,
Project Parameters, and the symbol file; the main role integrates the draft and takes it to the
human for sign-off, same as Step 02.

**Inputs:** `FRD.md`, `docs/ProjectParameters.md`, BC symbol file (Parameter 1.4).

**Actions:** Translate the FRD's *what* into a precise *how*. The TDD must be self-sufficient: a developer or agent who has never seen the project must be able to produce every object correctly from the TDD alone — no rule it applies may require knowledge that lives outside the document. Include:
- **System identity** — Publisher, namespace, prefix, APIPublisher, APIGroup prefix, APIVersion, AL runtime, BC minimum, object ID ranges (all from Part 1).
- **Module grouping** — cluster entities into cohesive functional modules; assign each module a contiguous ID sub-block with a growth buffer (min 20% unallocated) and a tail block for cross-module additions (Standards §5.1–§5.2).
- **Batch / phase plan** — which modules or document-type groups are built in which order; smallest and simplest batch first (Operating Rule 3).
- **Per-object spec** — for every object: ID, type, name, source table name *and* verified source table number, `PageType`, `APIPublisher`, `APIGroup`, `EntityName`, `EntitySetName`, `ODataKeyFields = SystemId`, and exactly one of `DelayedInsert = true` / `Editable = false` per Standards §2.2.
- **Per-field spec** — every field by source name and camelCase identifier, with each conversion decision shown (Standards §4.1); which fields are excluded and why (Standards Part 3, driven by the Localization parameter); abbreviations applied (Standards §4.2); reserved-keyword resolutions (Standards §4.3).
- **Computed-field pattern, decided per field, not defaulted:** state for each calculated-looking field whether it's a `FlowField` or a stored field seeded by a trigger that never overwrites a user's value (Standards Part 7).
- **`SourceTableView` filters** — for every document-type-filtered page, with the correct `const()` quoting (quote only multi-word enum values) (Standards §2.3).
- **`using` directives** — the exact namespace for every object, copied from the symbol file (Standards §1.1, §3.4).
- **Standard object template** — the exact AL API page pattern every generated object must follow (Standards §1.3).
- **Design patterns beyond the Standards Guide** — where the design needs a pattern the Standards Guide doesn't cover (error handling, events, facades, no. series, and similar), consult AL Guidelines (ALL ALONG → Reference Sources) and cite the specific guideline in the TDD rather than inventing one.
- **Translatable text** — per Standards Part 8: every message, error, and confirmation planned as a `Label` with its AA0074 suffix and a `Comment` for each placeholder; which labels are `Locked`; `MaxLength` where length is constrained; source wording per Parameter §1.9 and the glossary; translation file names (`Translations/<ExtensionName>.<culture>.xlf`, one per target language). Reference the glossary — don't copy it into the TDD.
- **API caption locking — decided interactively, per object** (Standards §8.6). Skip if the project has no API pages or queries. Once the object inventory is complete, and before any code exists:
  1. **Classify** every `PageType = API` page and `QueryType = API` query as **Business**, **Technical — admin**, or **Technical — internal plumbing**, with a one-line reason each. Put anything that reasonably fits more than one group in an **Unsure** list — typically the extension's own setup table, integration mapping or staging tables, dashboard queries, and technical objects where admin vs. plumbing isn't clear.
  2. **Show the classification**, grouped, one object per line.
  3. **Resolve each Unsure object first**, one at a time (Rule 6a): *Business* / *Technical — admin* / *Technical — internal plumbing*. Doing this first means each group question below is asked against its final list.
  4. **Ask about Business** (Rule 6a): *Translatable (recommended)* / *Locked*. The recommendation text must cite Microsoft's precedent from Standards §8.6 — e.g. "Microsoft's API v2.0 leaves all 1,526 captions on its business pages and queries translatable."
  5. **Ask about Technical** (Rule 6a): *Admin translatable, internal plumbing locked (recommended)* / *All technical translatable* / *All technical locked* — citing both §8.6 precedents, and listing which objects fall under admin and which under plumbing.
  6. Skip any question whose group is empty. **Record per object** in the per-object spec: group, locked `Yes`/`No`, and who decided — by name.

  Any API page or query added later (gap-fill, testing feedback) goes through steps 1–6 for the new objects only.
- **Special design notes** — singletons (`EntityName = EntitySetName`), header/line pairs as two top-level pages, high-volume tables, naming conflicts.
- **Permission sets** — if Parameter 1.2 = `Yes`: a read-only set and a read/write set (including the read-only set), IDs from the allocated range, named from Parameter 1.3 (Standards §5.3–§5.4). **Each table's `tabledata` grant ships in the same batch that introduces the table** (Standards §5.3).

**Outputs:** `TDD.md`; updated **Object Register** with every planned object and its ID.

**Exit gate:** Technical Lead sign-off. Self-sufficiency check passes: no rule requires knowledge outside the document (Stage↔Step Map, Stage 5). When **Approvers** is one person, the sign-off moves to Step 04 and is given once, on `TDD.md` and `SanityCheck.md` together — the self-sufficiency check still passes here first.

## 04 — Sanity Check and Validation

**Role:** if §1.7 role assignment is configured, this review is done by the **reasoning role** —
same rationale as Step 09: fresh eyes catch what the author of the FRD/TDD is least likely to see
in their own work. The reasoning role reports findings; the main role resolves them and updates
the documents.

**Inputs:** `FRD.md`, `TDD.md`, BC symbol file.

**Actions:** Run a formal structured review — not a read-through — answering: **(A)** Can BC actually do everything the FRD asks? **(B)** Does the TDD fully and correctly implement the FRD? What will the object structure look like when built? Record each check, its finding, and any resolution in a document. Work the checklist — this is the canonical sanity-check list; the Standards Guide deliberately keeps no second copy of it:

- [ ] Every FRD entity maps to at least one TDD object.
- [ ] Every TDD object has a valid ID inside an allocated range (Parameter 1.2).
- [ ] Every source table number is verified against the symbol file (not estimated).
- [ ] Every field complies with the Localization parameter and Standards Part 3.
- [ ] Every obsolete / pending field is excluded.
- [ ] Every `using` namespace is sourced from the symbol file.
- [ ] All document-type-filtered pages use the correct `const()` quoting pattern.
- [ ] All entity names ≤ 30 characters and camelCase, with `APIPublisher` and `APIGroup` camelCase too (Standards §2.7); all field identifiers ≤ 30 characters.
- [ ] Read vs. read/write designations match the mutability rules in Standards §2.2.
- [ ] Growth buffers are planned within each module block (Standards §5.2).
- [ ] Permission sets are planned if enabled (Parameter 1.2), with every table's `tabledata` grant enumerated per set and assigned to the batch that introduces its table (Standards §5.3); names and App Code from Parameter 1.3, each name ≤ 20 characters (Standards §5.4).
- [ ] Every target language in Parameter §1.9 is supported by BC in its country (checked against Microsoft's live page), has a named reviewer, and has a terminology source.
- [ ] Every regional term PRE-02 listed is in the translation glossary, verified per Standards Appendix D or marked for reviewer attention.
- [ ] Every API page and API query has a recorded group and caption-locking decision, with the decider named (Step 03; Standards §8.6).
- [ ] Every planned message, error, and confirmation is a `Label`, and every placeholder label has a `Comment` (Standards §8.3).
- [ ] Every entity's deletion behavior (block-if-referenced / cascade / allow) is explicitly decided and stated — not left to whatever the template defaults to. This includes fields on *other* tables (including standard BC tables extended via `tableextension`) that reference this entity by `TableRelation`: deciding a table's deletion behavior means re-checking every known referencing field, not just this app's own child tables.

**Outputs:** `SanityCheck.md` — every check, finding, resolution.

**Exit gate:** 0 blocking issues; every gap resolved; Technical Lead sign-off — when **Approvers** is one person, one sign-off on `TDD.md` and `SanityCheck.md` together, covering Step 03's too. Issues found here cost hours; the same issues found during BUILD cost days (Stage↔Step Map, Stage 6).

---

# PHASE: BUILD

Goal: generate AL batch by batch, lint clean — including symbol verification — as you go, without compiling per batch. The whole extension compiles and packages once the TDD's planned batches are all written (Step 07), then keeps compiling and packaging every time a fix lands, as troubleshooting against a live sandbox iterates — fix root causes, not symptoms, when that surfaces anything.

## 05 — Plan the Code

**Inputs:** `TDD.md` (module grouping + batch plan), Object Register.

**Actions:**
- Confirm the object build order: which objects are built in which batch, smallest/simplest module first (Operating Rule 3).
- **Agree how to run the batches, once** (Rule 6a): **Run through all batches, stopping on any pre-flight failure or TDD deviation (recommended)** / **Ask me before each batch**. Record the answer in `ProjectMemory.md`. This one approval replaces a separate approval before every batch (Operating Rule 6); Step 06 follows it.
- Within a batch, order objects so lookup/reference tables precede the entities that reference them.
- Prepare the scaffold: confirm `app.json` still matches `docs/ProjectParameters.md` (written at §1.10: name, publisher, ID ranges, runtime, BC dependency, `"features": ["NoImplicitWith", "TranslationFile"]` — `TranslationFile` on every project, Standards §8.2), `launch.json`, folder structure per module, a `Translations/` folder, `.gitignore` populated per §1.8 and ALL ALONG → Repository Hygiene (including `*.g.xlf` and `.alpackages/`), and the analyzer files: `.vscode/settings.json` with the analyzers for Parameter 1.1 Deployment Target, plus `AppSourceCop.json` if it's AppSource (ALL ALONG → Analyzers). Confirm the compile script (`scripts/al-analyze.*`) is present unless this is GitHub Copilot Chat in VS Code, and copy or fetch it if not. If `app.json` has to change here, follow ALL ALONG → Keeping the Editor in Sync.
- **Agree the translation tooling** (Rule 6a; skip if Parameter §1.9 chose *US wording, no translation files*). Recommend the **XLIFF Sync** PowerShell module (`XliffSync`) as the agent's headless sync and checks, with the **XLIFF Sync** VS Code extension for reviewers. Offer **NAB AL Tools** as the alternative for developers who already use it. Before installing PowerShell, the module, or any extension, look for an existing installation first and ask (Operating Rules 6, 6b). Record the choice in Parameter §1.9. Whatever the tooling, the release gate (ALL ALONG → Translations & Terminology) is the same state scan.
- Bootstrap the BCQuality knowledge snapshot and the OnlyCopilotFans (OCPF) BC AL Patterns
  library for this project if not already done (ALL ALONG) — both are one-time-per-project setup,
  cheapest to do alongside the rest of the scaffold rather than as an afterthought once BUILD is
  underway. (Two things are **not** in this group, because DEFINE and DESIGN already needed them:
  the Standards Guide, fetched at PRE-01, and the AL tools and symbols, set up at Step 01 §1.10.
  Confirm `standardsGuide/` is present and gitignored, the AL tools respond, and `.alpackages/`
  holds the target version's symbols, rather than redoing any of it.)
- Write the pre-flight validation checks to run for each batch — this is the canonical checklist every other reference to "the Step 05 checklist" in this runbook means; if you're re-stating it elsewhere, point here rather than re-enumerating. Split into two passes, since some checks are only possible before generation and some only after:
  - **Pre-generation** (on the TDD's planned names/fields, before any file exists — main role): identifier length ≤ 30, entity/EntitySet name length ≤ 30, API names camelCase (Standards §2.7), reserved-keyword scan, localization field-range filter, `ObsoleteState` filter.
  - **Post-generation** (on the actual generated files — light role, if §1.7 role assignment is configured): required-property presence; the file named after its object (Standards §1.8); **no multilanguage (ML) properties and no `TextConst`** (Standards §1.7); **translatable text** — no string literal in a user-facing message, AA0074 suffixes, a `Comment` on every placeholder label (Standards §8.3–§8.4); **API caption locking** matches the per-object decision recorded at Step 03 (Standards §8.6); `Rec.`-qualification (`NoImplicitWith`); no empty triggers, `// TODO`, or commented-out fields (Standards §1.5); 4-space indentation, no tabs (Standards §1.6); **permission set names** from Parameter 1.3, ≤ 20 characters, captions ≤ 30 (Standards §5.4); `tabledata` coverage for every table the batch introduces (Standards §5.3; vacuously satisfied if none); and **symbol verification** of every reference to a standard object, method, property, or enum value (Operating Rule 2, Standards Appendix B). The analyzer-enabled compile at Step 07 proves several of these again (ALL ALONG → Analyzers); checking here keeps the next batch from building on a gap.

**Outputs:** Batch plan (ordered), project scaffold, pre-flight validation script/checklist (both passes).

**Exit gate:** Batch order and the run-through choice agreed with the human; scaffold is structurally complete (`app.json` fields populated, dependencies declared, folders created, analyzer settings and — for AppSource — `AppSourceCop.json` in place per ALL ALONG → Analyzers — not compiled, per Operating Rule 4); pre-flight checks ready.

## 06 — Code Generation

**Inputs:** `TDD.md`, `docs/ProjectParameters.md`, symbol file, batch plan, pre-flight checks.

**Actions — per batch, in order:**
1. **Approval, per the Step 05 run-through choice.** Before the first batch, the batch plan approval from Step 05 applies. If the human chose **Ask me before each batch**, pause for approval before each one. Otherwise continue from batch to batch without asking, and stop for approval only when a pre-flight check fails in a way the TDD doesn't already answer, or generation has to deviate from the TDD (log the deviation per Operating Rule 7 first). The human can say "stop" at any point.
2. Extract source-table and field data for this batch's objects from the symbol file.
3. Run the Step 05 **pre-generation** pre-flight pass on the planned names/fields (main role — this is TDD housekeeping, distinct from the file-level lint in Action 5 below); fix the TDD before generating if anything fails.
4. Generate the batch's AL files from the standard template (Standards §1.3), substituting only Step 01 parameter values. Every file: one `namespace` (omitted entirely if Parameter 1.1 `Use Namespace` = `No`), one `using` (from symbol file), `ODataKeyFields = SystemId`, exactly one of `DelayedInsert = true` / `Editable = false`, and `Caption` + `ToolTip` + `ApplicationArea = All` on every field (Standards §1.1–§1.4, §2.1–§2.6). Captions and ToolTips written as self-describing schema for API consumers (Standards §2.5–§2.6), in single-language label syntax only — never `CaptionML`, `ToolTipML`, any other ML property, or `TextConst` (Standards §1.7). Every message a `Label` per Standards §8.3, source wording per Parameter §1.9 and the glossary, API caption locking per the Step 03 decision (Standards §8.6). **Source text only** — no translation file is created or edited during generation; translation starts at Step 07, once a build has produced `.g.xlf`. No dead code, no empty triggers, no commented-out fields, no `// TODO` (Standards §1.5).
5. **Run the Step 05 post-generation pre-flight pass on the batch immediately** — dot the i's, cross the t's on each file as you go, plus a manual read against the AZ AL Dev Tools rules (Standards Appendix C). If §1.7 role assignment is configured, this pass is done by the **light role** — it reports findings only, it does not edit code; the main role applies every fix. **Do not invoke the AL compiler** (Operating Rule 4).
6. Do not proceed to the next batch until this one's pre-flight (including symbol verification and Standards §5.3 permission-set coverage) is clean. Once every batch in the plan is generated, move to Step 07 (Operating Rule 4).

**Outputs:** Generated AL files for every batch, each lint-clean including symbol verification; updated Object Register; ChangeLog entries for any deviation. The extension is **not** compiled as part of this step (Operating Rule 4) — that happens next, in Step 07.

**Exit gate:** Every planned object generated; each batch's pre-flight (including symbol verification and permission-set coverage) was clean before the next began. No compile is required here — Step 07 compiles next.

## 07 — Compile and Package, Troubleshoot, Iterate

**Role:** if §1.7 role assignment is configured, root-cause diagnosis (the three questions below)
is done by the **reasoning role**; the main role applies the resulting fix and does the
ChangeLog/TDD bookkeeping, and is also the one who compiles, packages, and (with the human)
gets each build onto the sandbox. Same division for any bug surfaced later during PROVE-phase
testing (see Testing Feedback Log, ALL ALONG) — diagnosis is a reasoning-role task, fixing is the
main role's.

**Inputs:** Every batch from Step 06 (lint-clean, not yet compiled); the symbol-verified lint findings accumulated across BUILD; `TDD.md`; ChangeLog.

**Actions:** First, **compile the whole extension once, with the analyzers this framework requires, then package it** (Operating Rule 4; ALL ALONG → Analyzers — check for an already-provisioned runtime before installing anything, Operating Rule 6b). This is Operating Rule 4's mandatory compile-and-package. Package naming, location (`outputAppPackage/`), the never-delete rule, and Schema Sync Mode/Force Sync guidance all apply from this very first package onward (ALL ALONG → Packaging & Versioning) — there is no "not a real package yet" grace period.

**After every compile with 0 errors, check what the human's editor shows** (ALL ALONG → Keeping
the Editor in Sync). If VS Code still marks AL errors the compiler
didn't report, such as an object ID "outside the allowed ranges" or a symbol that "is missing",
the editor's view is stale, not the code. Refresh the view; never change code that compiles
clean to make stale red marks go away.

**From here, Step 07 is a cycle, not a single event.** Packaging is not a milestone held back for later — it happens every time the extension changes during troubleshooting:
1. Publish the current package to a BC sandbox tenant.
2. Test it — manually, by the human, unless the optional agent-run API pass below is in play.
3. For every error, warning, or reported problem, **first check `patterns/` (ALL ALONG → OCPF BC AL Patterns Library)** for a matching, already-documented pattern — a previously-solved bug class should be a fast recognition, not a fresh investigation. If nothing matches, ask the three questions (Operating Rule 4's systemic-signal discipline):
   - **One-off or pattern?** Search all generated files for the same class of issue before fixing one instance.
   - **Where did it come from?** Trace to the generation rule, the TDD template, or the source data.
   - **What rule should have caught it?** Fix that rule or the pre-flight check.
4. **Approve the round's fixes together, then apply them.** Once every problem from this test round has a diagnosis, present them all in one message — each listed separately with its root cause, the rule or template it traces to, and the proposed fix — and ask once (Rule 6a): **Apply all** / **Apply selected** (the human names which) / **Discuss first**. Nothing is applied before that answer. **A diagnosis that would change the FRD, the TDD, or a design rule gets its own separate box**, never folded into the bulk approval. Then fix each approved **root cause** (rule / template / filter), regenerate the affected files, and log each issue + resolution in the ChangeLog before moving on. Update the TDD whenever a rule changes.
5. **Compile and package again, with the same analyzers**, redeploy to the sandbox, retest. Repeat steps 1–5 until the extension compiles with 0 errors / 0 warnings and the human confirms sandbox testing is clean.

**Translations are part of this cycle, from the first full build onward** (skip if Parameter §1.9
chose *US wording, no translation files*). The cheap, mechanical work runs on every build; the
work that goes stale whenever captions and messages change waits until the source text settles.

**Every build that produces a new `.g.xlf`, before packaging:**
1. **Full build only** — Incremental Build off, no RAD publish (Standards §8.2).
2. **Sync** every target file in `Translations/` from `.g.xlf` with the agreed tooling (e.g.
   `Sync-XliffTranslations`). New units arrive as `needs-translation`; changed source text drops
   its unit to `needs-adaptation` (Standards §8.7).
3. **Verify terminology** for any BC term new to source text since the last build, per Standards
   Appendix D (`al_searchtranslations` first where the AL MCP Server is connected), and update the glossary (light role, if §1.7 is configured — it's a lookup against
   ground truth, like symbol verification). Terms already in the glossary aren't looked up again.
4. **Run the problem checks** (e.g. `Test-XliffTranslations -checkForProblems`) and fix each
   finding at its root — often the source label, not the translation. Missing translations aren't
   a finding yet: drafting hasn't run.
5. **Optional, early:** a pseudo-translation pass — a throwaway target file whose text is
   deliberately longer and accented — surfaces hard-coded strings and truncation before real
   translations exist. Never package it for anyone but the developer.

**Once the source text is stable — draft and test each language.** "Stable" means three moments:
the first build the human confirms clean on the sandbox, again before this step closes, and again
after any later fix that changes source text (Steps 08, 09, and 12 send those back here). Drafting
earlier only means redrafting every unit a caption or message change sends to `needs-adaptation`.
1. **Draft** every unit in `needs-translation` or `needs-adaptation`, using the glossary. Set each
   drafted unit to `needs-review-translation` (main role). The agent never sets `signed-off`.
2. **Run the full technical checks** with every rule enabled (e.g. `Test-XliffTranslations
   -checkForMissing -checkForProblems`) and fix findings at their root.
3. **Package, publish, and test in each language** — the tester switches **My Settings →
   Language** (and **Region** for formats) and walks the changed pages, messages, and reports.
   Look for untranslated text, which usually means a hard-coded string; truncation; and the wrong
   regional term.

Reviewers can review in parallel as drafts land (ALL ALONG → Translations & Terminology); approval
isn't required to close this step, only to release at Step 12.

**The API test checklist** — defined once, here, and used three times over the rest of the routine: optionally by the agent at the end of this step (below), as the source Step 11 writes `HumanUnitTestScript.md` from, and authoritatively by humans at Step 12 (Release to Users for Testing):
- **Green-team (happy path):** `$metadata` returns the expected schema; read a collection; read a single record by `SystemId`; create a record on an editable endpoint; update a field; confirm a read-only endpoint rejects writes. Endpoint URL shapes are in Standards Appendix A.
- **Red-team (boundary):** write to a read-only endpoint; send a non-existent field; send an invalid key; delete a record with dependencies; call with missing permissions — confirm each fails *gracefully with a clean, actionable error*.

**Optional, once things are stable: agent-run API testing via a live MCP connection.** Offer the human an automated pass over the app's own API pages, using the checklist above, run directly by the agent against the published sandbox — but only if, and because, the human can supply a working connection (e.g., the AL MCP Server actually connected per ALL ALONG → AL MCP Server, or another authenticated MCP endpoint that reaches the sandbox's API). This is optional and conditional, never assumed to be available:
- **If no working connection is available, say so plainly and suggest a manual alternative instead of leaving it undone** — testing the API by hand via **Postman**, or through a low-code caller like **Power Automate**, **Power Apps**, or **Copilot Studio**.
- This is a cheap, early pass, not a substitute for the authoritative one: the same checklist runs again at Step 12, by a human, after Code Review and documentation have had their say — whether or not this optional agent-run pass ever happened.

**Outputs:** All batches compiling and packaging with **0 errors, 0 warnings**; at least one package published and manually tested on a sandbox; ChangeLog current; TDD updated for every rule change; an agent-run API test result, if a live MCP connection was available and the human opted in; every target translation file synced, drafted, and passing technical checks, with the glossary current.

**Exit gate:** Full extension compiles clean; the human confirms sandbox testing is clean; no known systemic issue outstanding; ChangeLog and TDD reconciled (Operating Rule 5); no translation unit in any language required at first release is in `needs-translation` or `needs-adaptation`, and the technical translation checks are clean.

---

# PHASE: PROVE

Goal: prove the built code matches intent, is clean, is fully documented, and has passed a human-run release test — packaging and sandbox testing are already underway by this point (Step 07) and continue throughout, not a separate milestone reserved for PROVE.

## 08 — Gap-Fit Test, Fidelity Validation

**Role:** if §1.7 role assignment is configured, this three-way comparison is done by the
**reasoning role**; the main role applies the resulting classification (Intentional / Oversight /
Spec stale) to the actual documents.

**Inputs:** `FRD.md`, `TDD.md`, the built AL, ChangeLog.

**Actions:** Run a formal three-way comparison — FRD vs. TDD vs. as-built. Answer: does the written code follow the TDD and the FRD? What changed? Why? For each gap:
- Object in the FRD but not built — intentional or oversight?
- Object built but not in the FRD — scope creep or gap fill?
- Rule in the FRD the TDD did not implement — TDD gap.
- Rule implemented differently from the TDD — is there a ChangeLog entry?
- Implementation decision that contradicts the FRD — FRD update needed.
- **Languages** — a language the FRD requires at first release without a complete, synced translation file; a translation file for a language no longer in scope; an API page or query whose caption locking doesn't match its recorded decision.

Classify every gap as **Intentional** (document the reasoning), **Oversight** (fix now or schedule), or **Spec stale** (code is right, update the FRD/TDD).

**If a gap is classified Oversight and needs a code fix, apply the same Step 07 cycle before closing this step** — present every Oversight fix from this step for one approval, the way Step 07 presents a test round's diagnoses, then fix the root cause, compile and package again, redeploy to the sandbox, retest. A documentation-only correction (Spec stale, or Intentional-with-a-doc-update) does not require a new package; a code change does, every time, no matter how small — packaging is still the default rhythm here, not something reserved for a later step (Operating Rule 4).

**Outputs:** `GapAnalysis.md` — every gap, its classification, its resolution. Gap-fill work items — built with the same discipline as main batches, drawing on the growth IDs each module block reserved (Standards §5.2): pre-flighted per Step 05, then compiled, packaged, and troubleshot per Step 07's pattern, as their own pass — the Step 07 compile-and-package that closed BUILD already ran and doesn't cover code that didn't exist yet (Operating Rule 4). Ad hoc gap-fill requested mid-project, outside a formal Step 08, follows the same pattern.

**Exit gate:** Every gap classified and resolved or scheduled; every code-touching resolution recompiled, repackaged, and retested; no unexplained divergence from FRD/TDD.

## 09 — Code Review

**Role:** if §1.7 role assignment is configured, this review is done by the **reasoning role** —
fresh eyes matter here specifically, since the agent that wrote the code is the one least likely
to notice its own batch-to-batch drift. The reasoning role reports findings; the main role applies
every fix and normalizes whatever drift the findings call out.

**Inputs:** The full built extension; `TDD.md`; Standards Parts 1, 2, 4, and 7.

**Actions:** Comprehensive review across all objects. Check for:
- **Code quality** — every object follows the standard template; structure, naming, and formatting identical across all batches (early and late batches often drift — normalize).
- **Dead code** — empty triggers, commented-out blocks, placeholder `// TODO` (Standards §1.5).
- **Redundant code** — duplicate field exposures, duplicate `using` directives, objects more complex than needed.
- **"Marked for obsoletion"** — any reference to a field, table, procedure, or event with `ObsoleteState = Pending` or `Removed`; any subscription to an obsolete event (Standards §3.2–§3.3).
- **Standards compliance** — run the full Anti-Patterns table (Standards Part 7) against the codebase.
- **Deprecated multilanguage syntax** — `TranslationFile` is on for every project (Standards §8.2), so a clean compile already proves the whole codebase is free of `CaptionML`, `ToolTipML`, and the rest via `AL0424` — this bullet is a confirmation, not the only defense. If the last compile was 0/0 with nothing suppressed, note that, and search only files changed since that compile (Standards §1.7).
- **Translations** (skip if Parameter §1.9 chose *US wording, no translation files*) — run the full technical translation checks across every target file with all rules enabled (e.g. `Test-BcAppXliffTranslations -translationRulesEnableAll`). Then review against Standards Part 8:
  - no hard-coded user-facing strings;
  - every placeholder label has a `Comment`;
  - `Locked` used only where §8.3 and the Step 03 decisions say;
  - glossary terms used consistently in every language;
  - text likely to truncate in longer languages (German typically runs about 30% longer than English);
  - report layouts free of typed-in user-facing text.

  Re-verify API caption locking independently against the Step 03 records — don't just trust Step 06's pre-flight.
- **Best practices** — required metadata present, correct `DelayedInsert` / `Editable` per data mutability, permission set names built from the App Code per Standards §5.4. `Rec.`-qualification (`NoImplicitWith`) and every table's `tabledata` coverage (`PTE0004`) are already proven by the last 0/0 compile — confirm it ran with the analyzers this framework requires (ALL ALONG → Analyzers) and nothing is suppressed, rather than re-deriving either check by hand.
- **AL Guidelines best-practice pass** (ALL ALONG → Reference Sources) — read the built code against AL Guidelines' current *Best Practices* and *Vibe Coding Rules* for anything the Standards Guide doesn't already cover. The Standards Guide wins on any conflict; surface a conflict to the human rather than silently picking a side.
- **BCQuality knowledge-backed review** (ALL ALONG) — invoke the local BCQuality snapshot's
  `skills/entry.md` dispatch flow against the built extension as an additional, independent pass
  alongside the Standards Anti-Patterns check above. Integrate its findings the same way as every
  other finding here: knowledge-backed findings and the agent's own findings both surface, fixes
  land through the normal ChangeLog/root-cause discipline, nothing is applied blind.

**Outputs:** `CodeReview.md` — findings by dimension, severity, and resolution. Findings that need a code fix are presented together for one approval, the way Step 07 presents a test round's diagnoses (design-rule changes asked separately). Fixes applied at the rule level where a pattern repeats, with ChangeLog entries. Any fix that touches code follows the same Step 07 cycle — recompile, repackage, redeploy to the sandbox, retest — before this step closes (Operating Rule 4); a comment/formatting-only fix does not need a fresh package. If a finding repeats across batches and looks generalizable beyond this project — not a one-off, project-specific defect — flag it to the human as a candidate for a new entry in the OCPF BC AL Patterns Library (ALL ALONG), the same way Step 07 does; this pass, reading every batch side by side, is one of the best places in the whole routine to actually notice that shape of repetition.

**Exit gate:** All critical findings resolved; dead-code scan 100% clean across every file (Standards §1.5); no obsolete references remain; any code fix from this step has been recompiled, repackaged, and retested.

## 10 — Update Design Documents

**Inputs:** `TDD.md`, `FRD.md`, ChangeLog, `GapAnalysis.md`, `CodeReview.md`.

**Actions:**
- Produce a new **as-built TDD version** (`PostDevTDD.md`) reflecting the architecture as actually implemented: final system identity, final object inventory with all properties, every naming convention and abbreviation as applied, all special cases and exceptions, and a deviation summary that references the ChangeLog.
- Produce a new **FRD baseline** for future development: fold in every implementation decision that diverged from the original FRD — even where the implementation is better — so the next planning session starts from truth, not a stale spec.
- Bring **`docs/TranslationGlossary.md`** and Parameter §1.9 up to date with what was actually built: every term in use, every language actually shipped, and the final API caption-locking decisions (recorded in `PostDevTDD.md`).

**Outputs:** `PostDevTDD.md` (as-built reference), updated `FRD.md` (new baseline). Original TDD retained as historical context; ChangeLog is the bridge between them.

> **Why the two documents are treated differently — there is deliberately no `PostDevFRD.md`.**
> The TDD gets a *new* file because the gap between "what we told it to build" and "what got
> built" is itself information worth keeping side by side; the original TDD is also the artifact
> the code was generated from, so it stays as evidence. Requirements are not like that: there is
> exactly one current answer to "what should this app do," and a second, stale copy of it is
> actively misleading to the next planner — which is the whole point of re-baselining. So the FRD
> is updated **in place**, not duplicated.
>
> **Because the FRD is updated in place, add a pointer to its pre-BUILD version** in the FRD's
> own header — the commit hash that holds it, plus how to list its revisions. Otherwise the
> original TDD sits in `docs/` where anyone finds it while the original FRD is only reachable by
> someone who already knows to go looking, which is the one thing this asymmetry genuinely costs.

**Exit gate:** As-built TDD is complete enough to regenerate the system from; FRD reflects reality. The Dev Manager's review of both happens once, at the Step 11 → Step 12 hand-off, together with Step 11's documents — not as a separate wait here.

## 11 — Document the Code

**Inputs:** `PostDevTDD.md`, the built AL, any agent-run API test result from Step 07 (if a live MCP connection was available there — optional, may not exist).

**Actions:**
- **Generate the reference documentation from the code, not from memory.** Parse every API page: extract IDs, source tables, editability, filters, and every field's identifier / source name / description / R/W status. Produce a structured reference — one section per object, one row per field — plus: a **quick-start** guide (get the API working fast — auth, one request, one response; not the full install procedure, see `Deployment.md` below for that), authentication and URL patterns (Standards Appendix A), `$filter` / `$select` examples, create/update/delete examples, explicit limitations, common integration patterns, troubleshooting table.
- **Draw the schema as a Mermaid diagram**, generated from the actual objects, not from memory. Include every table this app owns *and* every standard/base table it touches — via `TableRelation`, `tableextension`, or a `pageextension`'s `RunPageLink` — so a reader sees the whole relationship graph, not just the app's own corner of it. An ER diagram (`erDiagram`) is the usual fit; note cardinality and which side is the standard object.
- **Render the diagram to prove it parses — never ship one you have not seen render.** Markdown happily stores a syntactically invalid diagram: it looks fine in the source file and simply fails to draw wherever it is finally viewed, so the defect is invisible until a reader hits it. Extract the fenced block and run it through a renderer (e.g. `npx @mermaid-js/mermaid-cli -i diagram.mmd -o diagram.svg`, or whatever renderer is already available — this may download a package on first run, so Operating Rule 6b applies: confirm one is already usable, or ask, rather than installing anything unprompted); a parse error exits non-zero and names the line. On a real project a diagram shipped with `PK_FK` as a key constraint — not valid Mermaid, which accepts `PK`, `FK`, `UK`, or comma-separated `PK,FK` — and never rendered anywhere until it was actually tested.
- **Write the human unit test script** — a step-by-step manual test walkthrough a person can execute: endpoint by endpoint, the happy-path (green-team) and boundary (red-team) cases per the checklist defined in Step 07, expected result for each, written against this app's actual endpoints. A well-written test script is ~70% of a user guide. This is the script Step 12 will actually run.
- **Ask the human whether they also want Automated Test Scripts created**, alongside — not
  instead of — the Human Unit Test Script. This is a genuine question, not a default: automated
  scripts imply an ongoing maintenance commitment as the app evolves, which a one-time manual
  script doesn't carry.
  **"Automated Test Scripts" has two genuinely different meanings — ask which, don't assume the
  API-only one.** The two real options:
  - **AL Test Framework (native).** Business Central's own automated-testing mechanism: a test
    codeunit (`Subtype = Test`) per feature area, with `[Test]`-attributed methods and the
    platform's test libraries (`Library Assert`, `Library - Random`, etc.), exercising the app's
    actual business logic — tables, codeunits, pages — directly in AL, not limited to whatever
    happens to be reachable over an API. Run via the in-client **Test Tool** page during
    development, and headlessly in CI (e.g., AL-Go for GitHub's built-in test pipeline, or
    `BcContainerHelper`'s `Run-TestsInBcContainer`). Conventionally shipped as its own **test
    app** — a separate `app.json` depending on the extension under test — in a `test/` (or
    similarly named) folder alongside the main extension's source, not mixed into it; it needs
    its own object ID range, distinct from Parameter 1.2's, noted in the Object Register the same
    as any other range.
  - **API-level automation.** External HTTP tooling (a Postman/Newman collection, a Playwright
    suite, or similar) exercising the OData API surface from outside BC — the same requests
    `Documentation.md` and `HumanUnitTestScript.md` Part B already describe by hand.
  Ask **which of the two, or both** — a project with substantial internal business logic may want
  AL test codeunits regardless of whether it exposes an API at all (it's the only one of the two
  that can exercise logic never surfaced through the API — a page's own validation, a report, an
  internal codeunit); a project that's mostly a thin API surface over standard BC tables may get
  more value from API-level automation instead. Recommend **AL Test Framework** as the default
  when the human has no preference and the extension has any nontrivial business logic — it's the
  platform's own idiomatic mechanism. If API-level automation is chosen (alone or alongside),
  recommend a **Postman collection** as its default — lowest friction for OData/API testing, no
  separate runtime to maintain. For whichever is chosen, also ask what should trigger a re-run
  (every build, only before a release, or on a CI schedule) and where the artifacts should live
  (this repo vs. a separate test-automation repo). If created, write a companion
  `AutomatedTestScripts.md` — a **separate document from `HumanUnitTestScript.md`** — naming
  which kind(s) were created, what they cover, how to run them, and how to keep them current as
  the app (not just its API) changes.
- Write the **user guide** as `UserGuide.md` — **Markdown, in the repo, always** (HTML with `@media print` rules only as an *additional* branded/print deliverable, never instead of the Markdown). This is a **separate document from `Documentation.md`** and must not be folded into it: `Documentation.md` is the integration/API reference written for a developer or BI consumer, whereas the user guide is written for the person clicking around in Business Central — what the feature is for, how to do each task in order, what each field means in business terms, and what to do when something is refused. If the only "user guide" produced is an API reference, this action has not been done.
- Write one-page **deployment instructions** as `Deployment.md`, for an administrator: version requirements, install procedure, which permission sets map to which roles, verification steps, uninstall. If this release renames any permission set (for example, moving an older extension to Standards §5.4 names), list which users must be reassigned after the upgrade. Distinct from `Documentation.md`'s quick-start: this is the full admin install/upgrade/uninstall procedure, not a fast path to a first API call. If Parameter §1.9 has more than one language, include which Microsoft language apps (or partner language apps) an administrator must install for each language, and that the Allowed Languages list should include them.
- **AppSource listing text** — only if §1.1 Deployment Target = `AppSource` (Standards §8.10). Draft, in English, the offer description's closing *Supported Countries/Regions* paragraph (the countries from Parameter §1.9) and *Supported Languages* paragraph (only languages whose translation files ship with every unit approved at Step 12). Write both into `Deployment.md`, and state plainly that the markets selected in Partner Center must match the countries paragraph. Every listed country needs its own test at Step 12.
- **Languages in the test script.** When there's more than one required language, `HumanUnitTestScript.md` gains a **language pass**: the key pages, messages, errors, and customer-facing documents walked once per required language. Each pass records the tester's name and a pass/fail per case, with checks for untranslated text, truncation, regional terminology, and regional formats. Each case names the glossary terms the tester should see in their language, so a tester who reads English can run the pass from this script without a translated copy.
- **Translated documents aren't produced here.** Step 12 produces them once its functional test pass is green, so a fix found in testing doesn't make every translated copy stale along with the English one.

**Outputs:** `Documentation.md` (consumer/API reference, includes the Mermaid schema diagram), `HumanUnitTestScript.md`, **`UserGuide.md`** (end-user, Markdown), `Deployment.md`, and `AutomatedTestScripts.md` (only if the human opted in above). Four mandatory documents — check all four exist before claiming the step is complete; the fifth is conditional.

**Exit gate:** Reference is generated from actual code and current; test script executable by a non-developer; the human has been asked about Automated Test Scripts (answer recorded either way); app ready to hand to Step 12 for release testing.

## 12 — Release to Users for Testing

> **The hand-off moment — mark it, don't slide into it.** The instant
> Step 11's four outputs are done and this step is about to begin, the agent's own work in this
> routine is effectively finished: everything from here is a human running tests and deciding
> whether to ship. Send a formal message for this specific transition — this **replaces**, it
> does not add to, the ordinary Rule 6c step-completion check-in for this one boundary — through
> the interactive mechanism (Rule 6a), with exactly two named options plus the mechanism's own
> free-text/Other entry: **"Perfect, I understand!"** and **"I have some questions."** The
> message itself must: (a) congratulate the human on reaching this point; (b) state plainly that
> this is the logical end of the agentic development framework's own work — Step 12 runs
> entirely by human hands from here; (c) say concretely what they need to do next — the Dev
> Manager reviews `PostDevTDD.md`, the FRD baseline, and Step 11's documents (the one PROVE
> review, which replaces separate reviews at Steps 10 and 11), and testers run
> `HumanUnitTestScript.md` and record results in `ReleaseTestResults.md`; and (d) say how to bring
> the agent back in — when testing surfaces something to fix, when the functional pass is green
> and translated documents are due (if §1.9 requires any), or once everything passes and it's time
> to mark the release candidate.
>
> **Worked example** (from the pilot project):
> > 🎉 We've reached the logical end of the OnlyCopilotFans Agentic Development Framework's own
> > work on *Bootcamp Registration Tracking*. Every step the agent can carry end-to-end — DEFINE
> > through PROVE Steps 08–11 — is complete: built, gap-tested, code-reviewed, documented, and
> > packaged as `Bootcamp_Registration_Tracking_0.0.5.1.app`. What's left, Step 12, is
> > intentionally human-run: the Dev Manager reviews `docs/PostDevTDD.md`, the FRD baseline, and
> > the Step 11 documents, and your testers work through `docs/HumanUnitTestScript.md` end to end
> > and record results in `docs/ReleaseTestResults.md`. When something needs a fix, or once
> > everything passes and you're ready to mark the release candidate, just tell me and I'll pick
> > it back up.
>
> Options shown: **Perfect, I understand!** / **I have some questions** (free text also
> available, as with any use of Rule 6a's mechanism).

**Role:** if §1.7 role assignment is configured, this is a **main-role** step end to end — confirming the publish, coordinating the human testers, recording results in `ReleaseTestResults.md`, and triaging findings via the Testing Feedback Log. Any diagnosis a finding needs still routes to the reasoning role first, same as everywhere else (Step 07, Testing Feedback Log).

**Inputs:** The most recently built package (from Step 07/08/09's ongoing compile-and-package cycle, or a fresh repackage if Step 09's Code Review found something needing a code fix since the last one — Steps 10 and 11 are documentation-only and never trigger a repackage on their own); `HumanUnitTestScript.md`; `AutomatedTestScripts.md` (if created); `UserGuide.md`; `Deployment.md`.

**Actions:**
- Confirm the latest package is published to a BC sandbox tenant — republish if anything changed since the last publish.
- Real users/testers — not the agent, not a simulated pass — run `HumanUnitTestScript.md` end to end: every green-team (happy path) case and every red-team (boundary) case, executed by hand this time (Step 07 may have already run the same checklist once, automatically, as an early check — this is the authoritative pass). Testers work from `UserGuide.md` for how each feature is supposed to behave; the sandbox install itself is a live dry run of `Deployment.md`'s procedure — confirm it matches what a real admin would follow.
- Verify permission sets as part of the same pass: the read-only set grants read on all pages; the read/write set includes it plus write on the editable pages; the underlying `D365` base permissions consumers also need are confirmed (Standards §5.3).
- If `AutomatedTestScripts.md` was created at Step 11, also run those and record results the same way.
- **AppSource: test in every listed country** (Standards §8.10) — Microsoft notes each country's base code differs. Publish to a sandbox of each country in the Supported Countries/Regions paragraph and run at least the green-team cases there. Confirm the Supported Languages paragraph still matches the languages that pass the gate below.
- **Translated documents, once the functional pass is green** (the green-team and red-team cases above pass in the source language). Bring the agent back to produce each document in each language Parameter §1.9 lists for it, named `<Document>.<culture>.md` (e.g. `docs/UserGuide.fr-CA.md`). It uses the glossary for every BC term, and each file's header names its English source and the date it was translated from, since the English version stays canonical. Each is reviewed by that language's named reviewer before the language pass that uses it.
- **Language passes, by people who speak each language.** For every language required at first release, a tester fluent in that language runs `HumanUnitTestScript.md`'s language pass in a sandbox with the matching language app installed. Microsoft-translated languages need Microsoft's language app; partner-translated languages need the partner's. Record results per language in `ReleaseTestResults.md`. Wording findings go through the Testing Feedback Log like any other finding.
- **Translation approval — the release gate** (skip if Parameter §1.9 chose *US wording, no translation files*). For every language required at first release, the named reviewer approves the translations (ALL ALONG → Translations & Terminology). Then run the **state scan**: every translation unit in every required language must be `signed-off` or `final` (Standards §8.7). Record the scan result — language, unit count, approved count, reviewer — in `ReleaseTestResults.md`. Any fix after approval that changes source text sends the affected units back through Step 07's translation cycle and review.
- Record every finding via the Testing Feedback Log (ALL ALONG) — verbatim, then triaged: implement now (its own ChangeLog Issue, fixed via the Step 07 cycle — fix, compile and package again, redeploy, retest), schedule (`Roadmap.md`), or reject.
- **If a fix here changes any object, field, or behavior, treat the artifacts Steps 09–11 already produced as stale, not as already covered:** re-run the affected parts of Step 09 (Code Review on the changed files), Step 10 (as-built TDD/FRD), and Step 11 (regenerate `Documentation.md` and its ER diagram from the now-changed code — Step 11's own rule is "from the code, not from memory," and that's now-changed code), plus any translated document already produced from an English document the fix changed. A trivial fix might touch none of these; say explicitly which ones a given fix actually requires re-running, rather than skipping the check by default.
- Repeat until every green-team test passes and every red-team test fails gracefully.

**Outputs:** `docs/ReleaseTestResults.md` — the Dev Manager's review (who, when, findings), every test case, its result, and a link to any ChangeLog issue it produced.

**Exit gate:** The Dev Manager has reviewed `PostDevTDD.md`, the FRD baseline, and Step 11's documents (recorded in `ReleaseTestResults.md`); all green-team tests pass; all red-team tests fail gracefully; permission sets verified; every translated document §1.9 requires exists and has been reviewed; every language required at first release has passed its language pass and its state scan shows every unit `signed-off` or `final`. **If everything passes, the package that was actually tested is the one deployed to the Production company** — bump its Build segment (e.g. `0.0.5.0` → `0.0.5.1`) or copy it to an immutable filename first (ALL ALONG → Packaging & Versioning) so the shipped artifact stays permanently identifiable and is never itself overwritten by a later cycle build; this is marking the release candidate, not building a new one — no code is recompiled and no new testing is required to do it. **Before that deploy, restate the Schema Sync Mode assessment for this exact package** (ALL ALONG → Packaging & Versioning) — **Add** if this release is additive-only, **Force Sync** with an explicit data-loss warning if anything was removed, shrunk, retyped, or re-keyed since the last production release.

---

# ALL ALONG — Continuous Discipline (every phase, every step)

Run these in parallel with the phased work — they are not a final step.

## Document

- Keep every required project document current as work proceeds, not retroactively — this list is canonical; the Standards Guide keeps no second copy of it: `ProblemStatement`, `ProjectParameters`, `FRD`, `TDD`, `SanityCheck`, `PostDevTDD`, `ChangeLog`, `GapAnalysis` / `CodeReview`, `Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`, `AutomatedTestScripts` (if created), `ReleaseTestResults`, `TestingFeedback`, `Roadmap`, `ProjectMemory`, `ProjectProgress`, `TranslationGlossary` (unless Parameter §1.9 chose *US wording, no translation files*) — all four mandatory Step 11 outputs (`Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`) belong on this list, not just the first of them, as does `AutomatedTestScripts` if the human opted in at Step 11, and `ReleaseTestResults` (Step 12). `ProjectParameters` is produced at Step 01, right after `ProblemStatement` — it is the one entry on this list a project cannot proceed without, since every other document and every AL file derives its identity from it.
- Maintain the **Object Register** as a standalone artifact — every object, its ID, module, source table, and R/W status — updated as objects are planned and built. Never use an object ID outside the ranges allocated at Parameter 1.2; the allocation strategy the register records is Standards Part 5.

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
Step 12 test-run record (`ReleaseTestResults.md`) captures the human-run green-team/red-team
pass/fail (with an earlier, optional agent-run pass at Step 07 if a live MCP connection was
available there). Neither preserves what the human actually said before it becomes a summary of
what the human said.

- Record every testing/feedback session in `TestingFeedback.md` — date, what was tested, and the
  tester's findings/requests **verbatim**, before they are triaged.
- Triage each item explicitly: implement now (its own ChangeLog Issue), schedule for later
  (`Roadmap.md`), or reject (record why, in the same log).
- Cross-reference in both directions: the `TestingFeedback.md` entry links to the ChangeLog
  Issue(s) or Roadmap item(s) it produced, so the raw ask and the eventual decision both remain
  traceable independently.
- **Role (§1.7):** diagnosing *why* a reported bug happens is a **reasoning-role** task, same as
  Step 07 — including Step 07's own first move: **check `patterns/` (ALL ALONG → OCPF BC AL
  Patterns Library) for an already-documented match before diagnosing from scratch.** The **main
  role** applies the fix once the diagnosis is confirmed, and separately owns
  the triage act itself — recording the implement/schedule/reject decision in `TestingFeedback.md`
  and cross-referencing the ChangeLog/Roadmap entry it produced. Don't skip straight to a patch on
  a guess — this is exactly where a wrong first diagnosis is cheapest to catch, and a wrong one
  should stay in the log marked superseded, not be quietly deleted, the same as any other
  ChangeLog correction.

## Project Memory — `docs/ProjectMemory.md` (required, in-repo)

Continuity must not depend on which agent, machine, or tool picks the project up next.
`docs/ProjectMemory.md` is a required project artifact, committed to version control like every
other document here — **not** an agent's own external/cross-session memory feature, which is
tied to one machine's file path and invisible to git, to a teammate, and to any other tool or
agent that opens this repo.

- **Keep it short — an anchor, not a narrative.** Current phase/step, where each live document
  lives, any decision awaiting sign-off, and a one-line pointer per past milestone. The full
  story of *why* a decision was made belongs in `ChangeLog.md`; `ProjectMemory.md` just says
  *where to look*. If it starts reading like a second ChangeLog, trim it.
- **Every row in "Open decisions" names who it's awaiting** — `(awaiting: <name>)`. This is not
  redundant with `git blame`: blame tells you who last edited the line, not who the project is
  actually waiting on for a forward-looking decision. With a single contributor every row will
  say the same name — write it anyway, so the convention is already in place the day a second
  person joins.
- Update it at the close of every step or batch — the same moment the ChangeLog gets its entry.
- If the executing agent *also* has its own persistent cross-session memory capability, that
  memory may point at `docs/ProjectMemory.md` (e.g. "always read this file first") but must not
  duplicate its content. A fact that lives only in an agent's private memory and nowhere in
  `docs/ProjectMemory.md` or the other project documents does not count as recorded — the file
  in the repo is the one a different agent, a teammate, or a fresh clone can actually read.

## Project Progress Tracker — `ProjectProgress.md` (required, in-repo, **project root**)

No mechanism available to any agent running this framework writes to a persistent UI element
outside its own conversation (no status bar, no external dashboard); even where a specific
harness *does* expose something like that, it wouldn't travel with the repo the way a file does.
`ProjectProgress.md` is the durable, host-agnostic substitute — the same reasoning that already
justifies `ProjectMemory.md` existing instead of relying on an agent's own non-shared cross-session
memory (previous section).

**Lives in the project root, always — not `docs/`.** Every other required document in this list lives under `docs/`; this one is
deliberately the exception, so it's the first thing visible on opening the repo, no navigation
needed — that's the whole point of it being a fast, at-a-glance status check.

This is **not** a narrative document and must not become one — that is exactly what
`ProjectMemory.md` is already for. It is one table, nothing else:

| Phase | Step | Status |
|---|---|---|
| DEFINE | PRE-01 — State the Problem | *(blank / `In Progress` / `Completed`)* |
| … | *(one row per step, PRE-01 through 12 — the full routine, not only the numbered steps)* | |

- **Create it as the very first artifact of the whole routine** — the moment PRE-01 begins, before
  `ProblemStatement.md` itself is even finished — with every row blank except PRE-01, marked
  `In Progress`. A project that already has `ProjectMemory.md` but no `ProjectProgress.md` (e.g.
  one that adopts this framework version mid-project) gets one backfilled from the ChangeLog the
  next time any step closes.
- **Update it at the exact same moments `ProjectMemory.md`'s "Current position" is updated** — a
  step starting, a step's exit gate being met — never on a separate schedule. The two files must
  never disagree about which step is current.
- Leave a step's row blank until it actually starts; don't pre-fill future steps as blank
  placeholders with any other text, and don't mark a step `Completed` before its own exit gate is
  actually met (that step's own **Exit gate** line in this runbook is the test, not "the agent
  moved on").
- Close the file with the same standing note every project ships it with: that asking, in plain
  language, **"Where are we in the process? What's next?"** always gets a direct answer from this
  file (plus `ProjectMemory.md` and `ChangeLog.md` for the reasoning behind it) — whether or not
  an agent session happens to be running at that exact moment.
- **While a step is actively `In Progress` and the agent is doing multi-part work within it**
  (e.g. applying a dozen Code Review findings), narrate a live plan in the conversation itself —
  what's planned, what's done, what's left — as ordinary text; no tool or file update is needed
  for this finer-grained, in-session view. `ProjectProgress.md` tracks step-level status only,
  never sub-step task lists.

## Translations & Terminology

The discipline that keeps an extension's translations correct, reviewed, and current across
every step. The *rules* are Standards Part 8;
this section is *how the routine applies them*. Everything here is skipped for a project whose
Parameter §1.9 chose *US wording, no translation files*, except Operating Rule 8 and Standards
§1.7.

**The translation glossary — `docs/TranslationGlossary.md`.** Created at Step 01, current at every
step after. One table, one row per standard BC concept the extension names:

| BC concept | Source term (W1) | `<culture>` term *(one column per target language)* | Source of each term (Microsoft file + version, partner app, or style guide) | Status (`verified` / `reviewer attention`) |
|---|---|---|---|---|

- Every row is filled by Standards Appendix D — never from model memory.
- Update it the moment a new BC term appears in source text (Step 06 onward), and at Step 10.
- It works in both directions. When the human names a concept in their own language (Operating
  Rule 8), find the standard object through it.

**Roles (§1.7).** If role assignment is configured:
- **Terminology verification** is the **light role's** job — a lookup against Microsoft's files,
  like symbol verification.
- **Drafting translations and updating target files** is the **main role's**, since the files are
  deliverables.
- **Approving translations** is never an AI role's.

**Review and approval.**
- **Each language's named reviewer** (Parameter §1.9) approves its translations. There are two
  ways to do it:
  - the reviewer edits and approves in the translation tooling directly, setting `signed-off`; or
  - the reviewer tells the agent, explicitly, which units or which reviewed batch they approve, and
    the agent sets `signed-off` on exactly those units.
- **Either way, log each approval in `ChangeLog.md`** — reviewer by name, language, units
  approved, date. The agent never sets `signed-off` on its own judgment, and never on units the
  reviewer didn't name (Standards §8.7).
- **Bulk approval is fine, with a named scope.** For a same-language file (`en-US` source →
  `en-US` target), most units are unchanged copies. The agent may list the unchanged units that
  contain no glossary term and ask the reviewer to approve that list in one decision (Rule 6a).
  Adapted units and units containing glossary terms are reviewed individually.
- **Reviewers can work in parallel** from the first drafts at Step 07 (drafting waits for stable
  source text) through Step 11. Approval is only *required* at the Step 12 gate.

**The release gate — a state scan, independent of tooling.** Before Step 12 closes, for every
language required at first release: count the translation units in its target file whose state
isn't `signed-off` or `final`. The gate passes only at zero. It's a plain scan of the XLIFF file,
never a tool's check (Standards §8.7).

**Source changes invalidate approval** (Standards §8.7): affected units go back through drafting
and review before the gate can pass again — even at Step 12, even for a one-word fix.

**Languages that can follow later.** A target language not required at first release is still
synced every build, so it never falls behind structurally. Drafting and review can wait. It joins
the gate for whichever release it's required in; record that in `Roadmap.md`.

**Licensing.**
- XLIFF Sync and NAB AL Tools are MIT-licensed tools the human installs; nothing from them is
  copied into a project.
- Microsoft's translation files are read for terminology and never committed (ALL ALONG →
  Repository Hygiene).
- Credits are in the framework's `THIRD_PARTY_NOTICES.md`.

## Packaging & Versioning

Packaging starts at Step 07 and recurs with every code change after it (Operating Rule 4).
Version bumps stay separately gated — see below.

**Package naming and location — fixed, not a judgment call.** Every package is named
`<ExtensionName, spaces → underscores>_<version>.app` — read `name` and `version` from `app.json`
at build time, never hardcoded in the build script or typed by hand. Example: extension name
`IP Tracking`, version `1.0.0.0` → `IP_Tracking_1.0.0.0.app`. It is written to a fixed output
folder named **`outputAppPackage/`** in the project root — every project uses this exact folder
name, not `out/`, `output/`, or anything improvised. **Say so twice, not once:** mention the
folder name once, plainly, at intake (Step 01 — before any package exists), and state the exact
path again, plainly, every time a build actually completes — e.g. "Package built:
`outputAppPackage/IP_Tracking_1.0.0.0.app`." Don't bury either mention inside a longer status
paragraph; it's the one thing the human needs in order to go find the file. Confirm `app.json`
identity, runtime, and dependencies still match Part 1 before every build, the same check every
time — cheap, and it catches drift before it reaches a package.

**Every package this project builds — `outputAppPackage/*.app` — is git-tracked, never
gitignored.** Track every built `.app` the same way as any other project deliverable — never delete
one (see below), and never delete its git history either. The one exception is downloaded
dependency symbols in `.alpackages/`, which are not this project's packages and are always
gitignored (ALL ALONG → Repository Hygiene). Do not add an `outputAppPackage/` or a blanket `*.app`
entry to `.gitignore` at Step 05 scaffolding (a blanket `*.app` entry would hide built packages
too), and if one is ever found already present (e.g. a
project built on an older copy of this framework), remove it and `git add` the packages it was
hiding — checking first, per Repository Hygiene's own untracking caution, whether the project has
a remote that would show collaborators a sudden batch of "new" files.

**Never delete — or overwrite — a package from a *different* version. NEVER.** A repackage at a
new version writes a new, uniquely-named file next to the old ones — it does not replace,
overwrite, or "clean up" anything already in the output folder, even one that looks superseded.
This applies to the build script itself and to the agent running it: no `rm`, no "let me tidy
this up first," not even as a seemingly-harmless pre-build habit — a habitual `rm -f` run before a
build has deleted a previous version's package on a real project, recoverable only because the
source (not the output folder) was git-tracked. Pruning old packages, if it ever happens, is a
decision the human makes explicitly, never an automatic or "helpful" action by the agent.

**This protection is per-version, not per-file.** Package filenames derive only from
`<ExtensionName>_<version>`, so under the Step 07/08/09 cycle's "repackage every fix" default,
consecutive builds *at the same version* legitimately write the same filename — that is expected
overwriting within an in-progress version, not the destructive deletion the rule above exists to
prevent. **The never-delete protection applies across versions; it does not require every interim
cycle build at one version to be individually preserved.** What must be preserved is the specific
package that
actually passes Step 12 (Release to Users for Testing) — the one that ships to production. To
keep that package permanently identifiable and never itself silently overwritten by a later
same-version cycle build: once a build passes Step 12, bump the **Build** segment (e.g.
`0.0.5.0` → `0.0.5.1`) before it's treated as the release candidate, or copy it to an immutable
filename outside the normal cycle path. Either way, say explicitly which package is "the one that
passed" once Step 12 closes — don't leave it to be inferred from a timestamp.

**Package by default during the Step 07/08/09 compile-and-package cycle — stop asking whether to, once that cycle is underway.** From the moment Step 07 opens, every fix that touches code gets recompiled and repackaged as a matter of course, before redeploying to the sandbox for the next test round — this is the default rhythm of BUILD/PROVE, not an occasional offer. Outside that cycle — a doc-only edit, a repackage requested out of the blue, a meaningful unit of change that didn't itself require a code fix — use judgment the same way as before: if the change was significant enough for its own ChangeLog entry and commit, it's significant enough to offer a fresh package for; don't ask after every trivial or doc-only edit.

**Version bumps require a proposal and approval — never a silent edit to `app.json`.** Propose
a specific bump with reasoning, then wait for confirmation before changing anything:
- **Major** — a breaking or structural change (e.g. renaming the whole extension, removing
  something a consumer could already be relying on). Rare, especially pre-release.
- **Minor** — new features, fields, or objects added in a backward-compatible way. This is the
  common case for a testing-feedback batch.
- **Build** — a repackage of the same feature set with no new functionality — a re-verification
  build, an environment change, or simply "package this again as-is."
- **Revision** — a small correction or hotfix discovered while testing a specific package, with
  no new features.

**Push back on a premature ask — don't just comply.** This is about requests *outside* the
Step 07/08/09 cycle, where packaging with known open issues is the whole point (that's how you
test them) — not about the cycle's own default behavior. If asked to package outside that cycle
while known compile errors or an unfinished batch stand, or asked for a version bump that doesn't
match the size of what actually changed (a one-field tweak billed as Major; a breaking change
billed as a Revision), say so plainly and recommend the right action instead of silently doing
what was literally asked. If the human insists anyway, get an explicit override and proceed — but
the mismatch must be named first, not absorbed silently.

**Flag Schema Sync Mode / Force Sync on every completed build, not just when asked.** Uploading
a `.app` to a Business Central Online tenant through the **Extension Management** page (or the
admin center) offers a **Schema Sync Mode** choice: **Add** (the default — warns and refuses the
upload if the new schema is incompatible; no data loss) or **Force Sync** (overwrites the schema
even when the change is destructive — table/field removals, a changed primary key, an
incompatible data-type or length change — and can cause data loss; Microsoft's own guidance is to
test a forced sync in a sandbox before ever doing one against production). Before or right after
handing over a completed package, check what this build actually changed against the schema:
additions only (new tables/fields, code-only changes) sync fine under the default **Add** mode;
anything removed, shrunk, retyped incompatibly, or with an altered key needs **Force Sync**, and
that needs saying plainly — e.g. "This build only adds fields — upload with the default **Add**
sync mode" or "This build removes `<field>` — you'll need **Force Sync** on upload, and it may
lose data in `<what>`." Never assume the human already knows which mode a given build needs, and
never let a schema-breaking change go out the door without this warning attached. (The separate
`schemaUpdateMode` setting in `launch.json` — `Synchronize` / `Recreate` / `ForceSync` — is a
related but different mechanism for local F5 dev-publish only, explicitly never meant for
production; don't conflate the two when explaining this to the human.)

## Repository Hygiene — What Stays Out of the Project's Remote

Some things a project needs locally to build or review with this framework are not the client's
deliverable and should never end up in the project's own git remote (its GitHub, Azure DevOps, or
similar hosting), even though they sit in the working directory like any other file.

**Always kept out of the project's git tracking — not a choice, not asked about per project:**
- **`.claude/settings.local.json`** and **`.ocpf/notifications.json`** — each developer's own
  Claude Code settings and notification choice (ALL ALONG → Notifications). Added to
  `.gitignore` at PRE-01, when the choice is made, even when §1.8 tracks the framework's files.
- The fetched OCPF AL Development Standards Guide (ALL ALONG → OCPF AL Development Standards
  Guide) — lives **inside** the project root, in `standardsGuide/`, so it needs its own
  `.gitignore` entry to get this result. Added at PRE-01, when the guide itself is fetched. Same
  reasoning as the patterns library below: it's AJ Ansari's own cross-project methodology,
  refetchable at will from `https://github.com/ajansari/ocpfBcAgenticDevFramework/`, not part of
  the client's deliverable.
- The fetched BCQuality knowledge snapshot (ALL ALONG → BCQuality Knowledge Snapshot) — lives
  **outside the AL project's own root folder entirely** (see that section for why: `alc` would
  otherwise try to compile its illustrative code snippets), so it isn't even a candidate for this
  project's git tracking, let alone something to gitignore. BCQuality is a review aid with no
  reproducibility requirement — it can be refetched at will, and a client's repo has no reason to
  carry an 800-file third-party knowledge snapshot regardless of where it physically sits.
- Any local tooling helper script this framework's own bootstrap creates for the executing
  agent's convenience — e.g., an AL MCP Server launcher wrapper — typically under a `scripts/`
  folder (ALL ALONG → AL MCP Server). This is the framework's own plumbing, not part of what the
  client is paying to receive.
- The fetched OCPF BC AL Patterns library (ALL ALONG → OCPF BC AL Patterns Library) — lives
  **inside** the project root, in `patterns/` (unlike BCQuality, nothing in it is `.al`, so there's
  no compile-breaking reason to push it outside), but is still always excluded from this project's
  git tracking, same reasoning as BCQuality: it's AJ Ansari's own portable, cross-project
  methodology, refetchable at will from `https://github.com/ajansari/ocpfBCALPatterns`, not
  something a client's repo has any reason to carry a copy of.
- **`*.g.xlf`** — the compiler regenerates it on every build (Standards §8.2). The per-language
  target files in `Translations/` **are** deliverables and always tracked.
- **`.alpackages/`** — downloaded dependency symbols, refetched in seconds by ALL ALONG → Symbols,
  so there's no reproducibility reason to track them. Add it to `.gitignore` at Step 01 §1.10,
  when symbols are first downloaded. Symbols downloaded from a sandbox are full Microsoft packages,
  not just symbols: checked on BC 28.4, Base Application carried 8,579 Microsoft source files and
  System Application carried translation files for 26 languages — Microsoft's proprietary content
  (Standards §8.5), never to be committed. (Symbols from Microsoft's public feed are symbol-only,
  but the folder is ignored either way, so the answer never depends on where they came from.)
  Microsoft's AL-Go templates for per-tenant and AppSource apps gitignore `.alpackages/` too.
- **Microsoft's translation files**, read for terminology verification (Standards Appendix D) —
  Microsoft's proprietary content. Read them where they are, inside the gitignored `.alpackages/`
  packages, or extract them outside the project's tracked tree. Never commit them.

**Gitignored by default, human can opt out at intake (Step 01 §1.8):** this runbook itself, its
changelog, and its schematics, if generated — and, in a project set up by the OCPF plugin, the
`.ocpf/` folder (its marker file and backups of earlier runbook copies; ALL ALONG → OCPF Plugin).
§1.8 has the question and both options' reasons.

**If any of the above is already tracked when this policy is adopted** (e.g., a project that
started before this section existed): add the entries to `.gitignore`, then actually untrack them
(`git rm --cached`, not `git rm` — the files stay on disk) so the ignore rule takes effect; adding
an entry to `.gitignore` alone does nothing for a file Git is already tracking. Check whether the
project has ever been pushed to a remote (GitHub, Azure DevOps, or wherever) before doing this —
if it has, untracking rewrites what a `git pull` shows collaborators (files appearing "deleted")
even though nothing was deleted locally; say so plainly before proceeding if a remote exists, per
Operating Rule 6.

## AL MCP Server

The AL Language extension ships a standalone MCP server (`altool launchmcpserver`) exposing AL
build/publish/symbol/diagnostic tools over the Model Context Protocol, so any MCP-capable agent —
not only VS Code — can drive them directly instead of shelling out to the compiler by hand. It is
not a background service: nothing runs until an MCP host spawns it, and it exits when the host
tears it down.

**Zero-install first (Operating Rule 6d).** Everything this
section needs is already on the machine of anyone developing AL in VS Code.
- **GitHub Copilot Chat in VS Code:** the AL Language extension's tools are already built in
  (`al_build`, `al_publish`, `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`,
  `al_getnextobjectid`, `al_symbolrelations`, debugging tools). There's nothing to bootstrap: use
  them. Bootstrap the full server below only if you need a tool that set doesn't have, such as
  `al_compile`, `al_run_tests`, or the translation tools.
- **Claude Code, Copilot CLI, or any other MCP host:** bootstrap below, using the AL extension's
  bundled `altool` and the .NET runtime VS Code already provisioned for it. Nothing is installed.
  If this session already has the server's tools (`al_compile`, `al_addproject`, …), don't register
  a duplicate; add this project with `al_addproject`.
- **With the OCPF plugin:** its `al-mcp-setup` skill does this bootstrap in one step.
  - It copies the launcher, the one-shot helper, and the analyzer compile script into
    `scripts/`: `al-mcp.sh`, `al-mcp-call.sh`, and `al-analyze.sh` on macOS/Linux, or
    `al-mcp.cmd`, `al-mcp-resolve.ps1`, `al-mcp-call.ps1`, `al-analyze.cmd`, and
    `al-analyze-resolve.ps1` on Windows. The launcher finds the newest AL extension and its runtime at every launch, so
    extension updates never break it.
  - It adds `al` to the project's `.mcp.json` and records the outcome as `alMcp` in
    `.ocpf/framework.json`.
- **Microsoft's `al` .NET tool on NuGet** (`Microsoft.Dynamics.BusinessCentral.Development.Tools`,
  same `launchmcpserver`) is for cloud sessions and machines without VS Code only. Install it in
  the cloud environment's setup script, not by asking the human.

**When the AL tools are needed:** from Step 01 §1.10, which downloads symbols before DESIGN. Not
from Step 05.

**The human approves; the agent does everything else** (Operating Rule 6d).
- **No Command Palette.** The AL Language extension has no command that sets up or registers
  the AL MCP Server. Its only MCP commands sign in to two separate servers, Profiling and
  Snapshot debugging (verified in AL Language extension 18.0's `package.json`).
- **No third-party bridge extensions.** One example is *AL Language Model Tools — MCP Bridge*, a
  community VSIX. It isn't on the Marketplace, needs VS Code relaunched with a proposed API
  enabled, and is set up from the Command Palette. Don't install, configure, or register one, and
  don't depend on one that's already registered. A consultant won't have it.
- **The human's only part:** approving the AI tool's permission prompts. That includes the prompt
  Claude Code shows once for a new project MCP server, at the start of the next session.

**Bootstrap once per new project** (idempotent — check for an existing registration before
adding a duplicate):
1. **Get the launcher.** With the plugin, the `al-mcp-setup` skill copies it. Without the plugin,
   download these files byte for byte into the project's `scripts/` folder from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/al-mcp-setup/scripts/<file>`:
   - **macOS or Linux:** `al-mcp.sh`, `al-mcp-call.sh`, `al-analyze.sh`
   - **Windows:** `al-mcp.cmd`, `al-mcp-resolve.ps1`, `al-mcp-call.ps1`, `al-analyze.cmd`,
     `al-analyze-resolve.ps1`

   The launcher uses Microsoft's `al` tool if it's on `PATH` and runs. Otherwise it uses the
   newest AL Language extension's `altool` on the .NET runtime VS Code provisioned for it. It needs
   no `PATH` edit, no `DOTNET_ROOT`, and no absolute path in any config. Add `scripts/` to
   `.gitignore` (ALL ALONG → Repository Hygiene): it's this framework's plumbing, not the client's
   deliverable. **If GitHub isn't reachable,** write the equivalent yourself. Locate `altool` in
   the AL extension's `bin/` folder. On Windows, run `altool.exe` directly. On macOS or Linux, run
   `altool.dll` on the runtime VS Code provisioned (check its storage path for the actual OS,
   Operating Rule 6b). Run it as `launchmcpserver --transport stdio`.
2. **Check it:** `sh scripts/al-mcp.sh --help` (Windows: `scripts\al-mcp.cmd --help`) prints the
   `launchmcpserver` usage. If it prints an `OCPF AL MCP launcher:` message instead, that says
   what's missing. When the AL extension has never started on this machine, its .NET runtime isn't
   provisioned yet. That's the one broken case where the human helps: open this project folder in
   VS Code, where the AL extension starts because `app.json` exists, then check again.
3. **Register it** with a relative launcher path. Claude Code and Copilot CLI read `.mcp.json`
   in the project root; add the `al` entry and never overwrite other servers:
   - **macOS or Linux:** `{ "mcpServers": { "al": { "command": "sh", "args": ["scripts/al-mcp.sh"] } } }`
   - **Windows:** `{ "mcpServers": { "al": { "command": "cmd.exe", "args": ["/c", "scripts\\al-mcp.cmd"] } } }`
   - **Other MCP hosts:** the same command in that host's configuration format.

   **Consequence to document, not paper over:** if that config is committed but `scripts/` is
   gitignored, a fresh clone points at a script that isn't there yet. Say so in the project's setup
   notes, and re-run this bootstrap on the new machine.
4. **Keep working in this session — no restart.** Claude Code and Copilot CLI load MCP servers
   when a session starts, so a server registered mid-session isn't available until the next
   session. Don't stop, and don't ask the human to restart. Until the `al` tools appear, call any
   of them through the one-shot helper. It starts the same server with this project loaded, runs
   one tool, prints the JSON-RPC response, and exits:
   ```
   sh scripts/al-mcp-call.sh . al_downloadsymbols '{"globalSourcesOnly":true}'
   sh scripts/al-mcp-call.sh . al_compile '{"options":{"onlyErrors":true}}'
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\al-mcp-call.ps1 . al_getpackagedependencies
   ```
   Each call reloads the project, so it takes a few seconds. Measured on macOS: symbol download in
   under 10 seconds, compile in about 5.
5. **Verify** with a call that isn't a compile, such as `al_getpackagedependencies`, or by listing
   tools once they appear (the first compile is Step 07's, Operating Rule 4).
6. Tools reaching a live BC cloud environment (publish, downloading non-global symbols) trigger
   an interactive sign-in the first time they're needed, cached for the session; log out when the
   task reaching the cloud is done.

`launchmcpserver` also accepts AL project paths as positional arguments, and flags for package
cache path, ruleset, and output folder. Check `--help` against the installed version rather than
assuming a fixed flag set, since this surface grows between AL extension releases. **Its
`--codeanalyzers` flag, and the `al_build`/`al_compile` tools' own `codeAnalyzers` argument, are
not reliable** — see ALL ALONG → Analyzers.

**Standing use during development:** once registered, prefer the MCP build/publish/symbol tools
over an ad hoc terminal compiler invocation where the harness makes both available — they're the
first-party path and are kept current with the extension, where a hand-rolled wrapper script
isn't. **The one exception is the analysis compile itself** (ALL ALONG → Analyzers): use the
launcher script there, not `al_build`/`al_compile`. Re-verify the tool surface (names, arguments)
against the installed version rather than trusting a prior project's notes about it, since this is
actively developed and can change between AL extension releases.

## Analyzers

**The mandatory Step 07 compile runs with Microsoft's bundled code analyzers engaged — not a plain
compile.** They ship with the AL Language extension; nothing is installed (Operating Rule 6d).
Every project runs **CodeCop** and **UICop**, plus exactly one of these, chosen by Parameter 1.1
Deployment Target:

| Deployment Target | Third analyzer |
|---|---|
| `SaaS PTE` or `OnPrem PTE` | **PerTenantExtensionCop** |
| `AppSource` | **AppSourceCop** |

- **Never both PerTenantExtensionCop and AppSourceCop.** Microsoft documents their rules as
  incompatible (*"Make sure to enable only one of these at a time"*).
- **AppSourceCop needs `AppSourceCop.json`** in the project root — at minimum
  `{ "mandatoryAffixes": ["<prefix>"] }` with Parameter 1.3's AL Object Prefix — or the compile
  fails with `AS0054`.
- **Both files are created at Step 05's scaffold:** `.vscode/settings.json` with
  `"al.enableCodeAnalysis": true` and `"al.codeAnalyzers"` set to the three analyzers above, and
  `AppSourceCop.json` when Deployment Target is AppSource. The settings also give the human live
  analyzer feedback in the editor.

**What the compile then proves:** `PTE0004` / `AS0103` (a table missing a matching permission set,
Standards §5.3), `PTE0008` / `AS0062` (a page control or action missing `ApplicationArea`),
`AA0074` (a `Label` missing its suffix, Standards §8.4), `AA0101` (API names not camelCase,
Standards §2.7), `AA0215` (a file not named per Standards §1.8), and `AL0424` (ML syntax,
Standards §1.7). It doesn't replace symbol verification (Operating Rule 2), permission set App Code uniqueness across extensions (Standards §5.4), or any judgment a
compiler can't make, such as caption quality or the Step 03 caption-locking decisions.

**How to run it** (verified on AL Language extension 18.0.2732683; re-verify on a newer release by
compiling a table with no permission set and confirming `PTE0004` appears):
- **GitHub Copilot Chat in VS Code:** the built-in `al_build` tool, which reads the
  `.vscode/settings.json` analyzers when its `codeAnalyzers` argument is omitted.
- **Claude Code, Copilot CLI, or any other MCP host: not the AL MCP Server's
  `al_build`/`al_compile`** — they don't apply analyzers, whether passed as the `codeAnalyzers`
  argument, the `--codeanalyzers` launch flag, or workspace settings. Run
  `scripts/al-analyze.sh <project folder> <output .app path> [pte|appsource]` instead (Windows:
  `scripts\al-analyze.cmd`, same arguments; the profile defaults to `pte`). The plugin's
  `al-mcp-setup` skill copies it into `scripts/`. Without the plugin, or if `scripts/` doesn't have
  it, fetch it beside the launcher (ALL ALONG → AL MCP Server, step 1) from
  `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/al-mcp-setup/scripts/al-analyze.sh`
  (Windows: `al-analyze.cmd` and `al-analyze-resolve.ps1`).
- **Read the warnings, not just the result.** The compiler succeeds with warnings, and so does
  `al_build`. `al-analyze` exits `0` only with no errors and no warnings, `3` when it compiled with
  warnings, and `1` when the compile failed. Any warning fails Operating Rule 5.

**Zero warnings means zero, honestly.** No `#pragma warning disable` around a real defect, and no
ruleset. The framework ships none: every CodeCop, UICop, and profile rule stays on, and a project
that follows the Standards Guide compiles clean under them. A suppressed or downgraded warning
counts as an unresolved one under Rule 5.

## Symbols

**The agent downloads symbols; the human never does** (Operating Rule 6d). First at Step 01 §1.10, then whenever the dependencies change. Stop at the first option
that works:
1. **GitHub Copilot Chat in VS Code:** the AL extension's own `al_downloadsymbols` tool, with
   `globalSourcesOnly: true` unless option 3 applies. It runs inside VS Code, so VS Code's AL
   workspace reloads afterwards.
2. **Any other agent:** the AL MCP Server's `al_downloadsymbols` with `globalSourcesOnly: true`.
   If this session can't see the server yet, call it through the one-shot helper (ALL ALONG → AL
   MCP Server, step 4).
3. **From the sandbox,** when global sources aren't enough: `al_downloadsymbols` without
   `globalSourcesOnly`, using the `launch.json` environment. The first time, it opens a browser
   sign-in, which is the human's part. Use this route when:
   - the project depends on a per-tenant or partner app that isn't on AppSource,
   - `Localization` isn't `W1` and option 1 isn't available (see below), or
   - the global download fails.

**Verified September 15, 2026, AL Language extension 18.0:**
- `globalSourcesOnly: true` downloads from Microsoft's public symbol feed and AppSource. It needs
  no Business Central connection and no sign-in. Tested for BC 27: System, Application, System
  Application, Business Foundation, and Base Application in under 10 seconds.
- It takes the newest build of `app.json`'s major version (`27.0.0.0` → 27.5), unless
  `enforceMinorVersion: true` is set.
- **The AL MCP Server's global download is W1 only.** It has no country option and ignores
  `al.symbolsCountryRegion`. VS Code's own download supports country-specific packages through
  that setting (AL extension changelog). So, for a localized project:
  - **In Copilot Chat:** set `"al.symbolsCountryRegion"` in `.vscode/settings.json` to the
    lowercase country code (for example `"us"`) before option 1.
  - **Elsewhere:** W1 symbols are enough to start DESIGN. Download from the sandbox (option 3)
    before verifying any country-specific table or field.

**Confirm symbols by using them, never by unpacking them.** Search for a known object with
`al_symbolsearch` (the `Customer` table, for example), or compile. A package's
`SymbolReference.json` can look far emptier than what the compiler resolves. On a real project,
reading it led an agent to declare good symbols unusable and design from Microsoft Learn instead.

**Download again** after adding a dependency, changing `platform` or `application`, or switching
to localized symbols. Then follow Keeping the Editor in Sync.

## Keeping the Editor in Sync

**The symptom** (seen on both editions): the extension compiles
clean, but VS Code still marks objects red. The usual messages say an object ID isn't within the
allowed ranges, or a referenced symbol is missing. The marks stay until the window is reloaded or
VS Code restarts. The code is fine; VS Code's AL language server is working from old information.
- **`app.json` changed outside the editor.** The AL extension doesn't always re-read `app.json`
  when something other than the editor changes it. ID ranges updated by `git pull` have stayed
  stale until VS Code restarted ([microsoft/vscode#147111](https://github.com/microsoft/vscode/issues/147111),
  attributed to the AL extension). An agent writing `app.json` on disk is the same situation. On
  the real Lite project, **AL: Go!** created `app.json` with its default range, the AL extension
  loaded it, and the agent then wrote the project's own range.
- **Symbols downloaded outside VS Code.** After a download, the AL MCP Server reloads its own
  workspace. VS Code's language server runs in a separate process and isn't told.

**Prevent it:**
1. Write `app.json` once, complete, at Step 01 §1.10, and download symbols in the same pass,
   before any `.al` file exists.
2. After that, change `idRanges`, `dependencies`, `platform`, `application`, or `runtime` only
   when the project needs it, and run the check below each time.
3. In Copilot Chat, download symbols with the AL extension's own tool (Symbols, option 1).

**Detect it — the agent checks, the human doesn't have to notice:**
- **When:** after each change listed above, and after every compile that reports 0 errors.
- **How:**
  - **GitHub Copilot Chat in VS Code:** `al_getdiagnostics` with severity `error` reads the
    Problems panel.
  - **Claude Code in VS Code:** the IDE integration's `getDiagnostics` tool
    (`mcp__ide__getDiagnostics`) reads the same panel.
- **Stale** means the panel shows AL errors that the latest compile (`al-analyze`, `al_build`, or `al_compile`) didn't
  report.
- **Where the agent can't read the editor** (for example, a terminal-only session), tell the human
  once, at the first clean compile, what stale marks look like and the fix below.
- **At §1.10 there are no `.al` files to mark yet.** So if `app.json` existed before the agent
  changed its ranges or versions, treat the editor as stale and fix it then.

**Fix it:**
1. **In Copilot Chat,** run the AL extension's own `al_downloadsymbols` once. It reloads VS
   Code's AL workspace. Check again.
2. **Anywhere else, or if the marks remain,** ask the human to reload the window. No agent tool
   can do it: Claude Code's IDE tools don't run editor commands, and the AL extension has no
   reload command. Put the request at the end of the reply, never mid-task, as one short message
   in the working language, for example:
   > VS Code is still showing errors from before I updated the project; the code itself compiles
   > clean. To refresh it, press Ctrl+Shift+P (Cmd+Shift+P on a Mac) and run **Developer: Reload
   > Window**. It takes a few seconds, and your files aren't touched. If the chat panel closes,
   > reopen it and continue this conversation from its history.

   **Developer: Reload Window** is built into VS Code, so it's always there (Operating Rule 6d).
   When the human continues, check the panel again.

Never change code that compiles clean just to clear stale marks.

## Notifications — Tell the Human When It's Their Turn

**The human chooses at intake how to be notified every time the agent finishes a turn, asks a
question, or waits for an approval, and the choice persists** — so no time is lost because nobody
noticed the ball was in their court. The AI tool's own notifications and hooks do the work. It's
the agent's job to set up (Operating Rule 6d); nothing is installed. In documents mode (no files
can be written), say that notifications aren't available there and skip this.

**1. Ask at PRE-01, right after the working language** (Rule 6a), as one multi-select question:
*"Would you like to be notified at the end of every turn and whenever a question or approval is
waiting? Choose any."* Offer only the options that can work here — check the environment first:

| Option | Offer it when |
|---|---|
| *Claude app* — a push to your phone | Claude Code signed in through a claude.ai Pro, Max, Team, or Enterprise account, with none of `ANTHROPIC_BASE_URL` (pointing anywhere but `api.anthropic.com`), `DISABLE_TELEMETRY`, `DO_NOT_TRACK`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, or `DISABLE_GROWTHBOOK` set. Not with an API key, Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, or a Claude apps gateway. If the sign-in can't be checked, say in the option that it needs a claude.ai subscription, and on Team or Enterprise an Owner must have enabled Remote Control. |
| *Sound* — a short sound on this computer | Always. On Linux it needs `paplay` or `canberra-gtk-play`; without them it's the terminal bell, which Claude Code's VS Code extension can't ring. |
| *Desktop notification* | GitHub Copilot Chat in VS Code or GitHub Copilot CLI (their own notifications). Claude Code on Windows or Linux, or in iTerm2, WezTerm, Ghostty, Warp, or Kitty on any OS (the terminal's own notification, found from `TERM_PROGRAM`, `KITTY_WINDOW_ID`, or `TERM`, and only when `CLAUDE_CODE_ENTRYPOINT` is `cli` — the VS Code extension can inherit `TERM_PROGRAM` from the terminal that opened VS Code; inside tmux, the terminal isn't detected). **Not for Claude Code's VS Code extension or VS Code's terminal on macOS:** there's no suitable notification there, and a banner raised from a script opens Script Editor when clicked. |
| *No notifications* | Always. If it's chosen with anything else, ask again. |

**With *Claude app*, explain Remote Control before going further** (Rule 6): pushes arrive only
while Remote Control is connected; while it's connected, the session's transcript — messages,
responses, and tool activity — is stored on Anthropic's servers; and organizations with
requirements such as Zero Data Retention can't use it. Then ask (Rule 6a): **Only when I turn it on**
(run `/remote-control`, or use the VS Code extension's Remote Control command, before stepping
away) / **Every Claude Code session on this machine** (all projects, until turned off in `/config`
or the VS Code extension's settings: **Enable Remote Control for all sessions**).

**2. Record the answer in `.ocpf/notifications.json`** in the project root — per developer, and
always gitignored (ALL ALONG → Repository Hygiene), whatever §1.8 says about the framework's other
files:

```json
{
  "notifyWhen": "every turn end, question, and approval",
  "channels": ["claudeApp", "sound", "desktop"],
  "remoteControl": "perSession",
  "userSettingsWritten": [],
  "aiTools": ["claude-code"],
  "os": "macos",
  "decidedOn": "2026-09-15"
}
```

`channels` holds any of `claudeApp`, `sound`, and `desktop`, or nothing for *No notifications*;
`remoteControl` is `perSession` or `allSessions`, present only with `claudeApp`;
`userSettingsWritten` lists each user-level setting the agent wrote and its earlier value (step 3); `aiTools` holds any
of `claude-code`, `copilot-chat`, and `copilot-cli`; `os` is `macos`, `windows`, or `linux`.

**At the start of every session, read it:**
- **Missing** — a developer new to the project, a fresh clone, or a project started before this
  section: ask the question before the next step.
- **The current AI tool isn't in `aiTools`:** apply the recorded kinds for this tool (step 3),
  ask only about a kind this tool adds, and add the tool to `aiTools`.
- **The human asks to change it:** ask again, undo what the dropped kinds set up (step 3, *Removing
  a kind*), apply the new ones, and rewrite the file.

**3. Apply it, per AI tool in use:**

| Choice | Claude Code (VS Code extension or terminal) | GitHub Copilot Chat in VS Code | GitHub Copilot CLI |
|---|---|---|---|
| **Claude app** | `"inputNeededNotifEnabled": true` and `"agentPushNotifEnabled": true` in `.claude/settings.local.json`; with *Every session*, also `"remoteControlAtStartup": true` in `~/.claude/settings.json`; and a push from the agent at every turn end (step 4) | — | — |
| **Sound** | Hooks in `.claude/settings.local.json` running `ocpf-notify` with `sound` | VS Code user settings: `"accessibility.signals.chatResponseReceived": { "sound": "on" }` and `"accessibility.signals.chatUserActionRequired": { "sound": "on", "announcement": "auto" }` | Hooks in `~/.copilot/hooks/ocpf-notify.json` running `ocpf-notify` with `sound` |
| **Desktop notification** | The same hooks, with `desktop` added | VS Code user settings: `"chat.notifyWindowOnResponseReceived": "always"` and `"chat.notifyWindowOnConfirmation": "always"`; clicking one opens the chat session | Built in and on by default; nothing to set up |

- **Where each file lives, and what to tell the human.** `.claude/settings.local.json` is this
  developer's, for this project only: merge into it, and add it to `.gitignore`.
  `~/.claude/settings.json`, `~/.copilot/hooks/`, and VS Code's user `settings.json` (macOS
  `~/Library/Application Support/Code/User/`, Windows `%APPDATA%\Code\User\`, Linux
  `~/.config/Code/User/`) are outside the project: before writing, say plainly that the setting
  applies to every project on this machine (and that `agentPushNotifEnabled` also syncs to the
  human's Claude account), then let the AI tool ask. Merge, keeping every existing setting and
  comment. Claude Code honors `remoteControlAtStartup` only from user settings, never from a
  project.
- **The script.** Add `scripts/` to `.gitignore` now if it isn't there, then copy `ocpf-notify.sh`
  (macOS/Linux) or `ocpf-notify.ps1` (Windows, untested on Windows) into it — from the plugin's
  `notifications` skill, or byte for byte from `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/notifications/scripts/<file>`. It takes `sound`, `desktop`, or both
  (`-Sound`, `-Desktop` on Windows). For Claude Code it returns the terminal's own notification or
  bell as hook output; sounds and Windows notifications run in the background. It always exits 0.
- **Remember what was written outside the project.** When writing a user-level setting, add
  `{ "key": "<setting>", "previous": <its earlier value, or null if it wasn't set> }` to
  `userSettingsWritten` in the record. If the human already had a different value, ask before
  replacing it. If they already had the same value, leave it theirs and don't record it.
- **Removing a kind.** *Claude app*: remove the two push settings, and if `remoteControlAtStartup`
  is in `userSettingsWritten`, put back its `previous` value, or remove the key when that's `null`
  (don't write `false`, so an organization's default still applies). *Sound* or *Desktop
  notification*: rewrite the Claude Code hooks with only the kinds left (remove them when none
  are), and put back each VS Code user setting in `userSettingsWritten` the same way. The Copilot CLI hooks read the record
  every time, so they need no change.
- **Not chosen:** leave each tool's defaults alone, and say what still happens by default: Claude
  Code notifies in iTerm2, Ghostty, and Kitty when it looks like the human is away; Copilot Chat
  notifies while VS Code isn't focused; Copilot CLI notifies while its terminal isn't focused and
  can be silenced only with `COPILOT_DISABLE_DESKTOP_NOTIFICATIONS` — never ask the human to edit a
  shell profile for it.

Claude Code hooks, macOS or Linux — exec form (`command` plus `args`), so no shell quotes the path.
Keep only the kinds the record chose, one array element each (`"sound"`, `"desktop"`):

```json
{
  "hooks": {
    "Stop": [ { "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.sh", "sound", "desktop", "Your turn: the agent finished"] } ] } ],
    "PreToolUse": [ { "matcher": "AskUserQuestion", "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.sh", "sound", "desktop", "A question is waiting for your answer"] } ] } ],
    "Notification": [ { "matcher": "permission_prompt", "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.sh", "sound", "desktop", "An approval is waiting for you"] } ] } ]
  }
}
```

On Windows, each hook runs PowerShell the same way, with only the chosen switches and each hook's
own message; `-ExecutionPolicy Bypass` lets it run the local script on a default Windows PowerShell
5.1 machine:

```json
{ "type": "command", "command": "powershell.exe", "args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.ps1", "-Sound", "-Desktop", "-Message", "Your turn: the agent finished"] }
```

GitHub Copilot CLI sound hooks (user-level, so each command runs only in a project whose record
chose `sound`; they read `.ocpf/notifications.json` relative to where the CLI starts, so start it
from the project root):

```json
{
  "version": 1,
  "hooks": {
    "agentStop": [
      { "type": "command", "timeoutSec": 15,
        "bash": "grep -qs '\"sound\"' .ocpf/notifications.json && sh scripts/ocpf-notify.sh sound </dev/null >/dev/null; exit 0",
        "powershell": "if ((Test-Path .ocpf/notifications.json) -and (Get-Content .ocpf/notifications.json -Raw) -match '\"sound\"') { & powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ocpf-notify.ps1 -Sound }" }
    ],
    "notification": [
      { "type": "command", "timeoutSec": 15,
        "bash": "grep -Eq '\"notification_type\" *: *\"(permission_prompt|elicitation_dialog)\"' && grep -qs '\"sound\"' .ocpf/notifications.json && sh scripts/ocpf-notify.sh sound </dev/null >/dev/null; exit 0",
        "powershell": "$n = [Console]::In.ReadToEnd(); if ($n -match '\"notification_type\"\\s*:\\s*\"(permission_prompt|elicitation_dialog)\"' -and (Test-Path .ocpf/notifications.json) -and (Get-Content .ocpf/notifications.json -Raw) -match '\"sound\"') { & powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ocpf-notify.ps1 -Sound }" }
    ]
  }
}
```

**4. With *Claude app*, end every turn that hands the ball back with a push** naming what the human
needs to do — work finished, a result to review, a decision asked in prose (in Claude Code, the push
notification tool). Unlike the other kinds, this depends on the agent remembering, so suggest
pairing *Claude app* with *Sound*. Questions and approvals push by themselves. Claude Code skips
pushes while the human is focused on the session. With *Only when I turn it on*, remind the human
to connect Remote Control before stepping away. Tell the human to install the Claude app, sign in
with the same account, and allow its notifications; the phone is theirs to set up.

**5. Test once:** trigger each chosen kind and ask (Rule 6a) *Did each one arrive, and did clicking
a notification take you to the session?* Fix or drop what didn't, and update the record.

**Verified September 2026:** in Claude Code 2.1.272, the `Stop` hook and a `PreToolUse` hook on
`AskUserQuestion` both fired, and the hooks block ran the script with `$CLAUDE_PROJECT_DIR`
resolved. From documentation, not tested here: Claude Code's hook `terminalSequence` output, push
settings, and Remote Control requirements (Anthropic); the VS Code settings and sounds (Microsoft's
documentation and VS Code's source); the Copilot CLI's notifications and hooks (GitHub's
documentation and changelog). Claude Code's VS Code extension has no notifications of its own
(anthropics/claude-code issues #57230 and #29928). Windows and Linux weren't tested. Tools with
neither notifications nor hooks (Claude Chat, Microsoft Copilot Cowork) can't notify; say so, and
record `"channels": []`.

## OCPF AL Development Standards Guide

The runbook's companion rules document —
`ocpfALDevStandardsGuide.md`, v1.7.0.0 — is distributed from this framework's own repository and
fetched into every project that runs this routine, so the rules the runbook cites are on disk and
readable for the life of the engagement rather than assumed to be in the agent's memory. This is
the third of three fetched knowledge sources, alongside BCQuality and the OCPF BC AL Patterns
Library, but it is the only one that is **not** optional and **not** deferred to Step 05: the
runbook cites it as **Standards §** from PRE-02 onward, so a missing copy is a real gap, not a
degraded-but-workable state.

**Fetch — at PRE-01, before anything else in the routine needs it:**
- Fetch `standardsGuide/ocpfALDevStandardsGuide.md` from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/` — the `standardsGuide/` folder on the
  default branch — into a folder named **`standardsGuide/`** in this project's root.
- **Lives INSIDE the project root**, same as `patterns/` and unlike BCQuality: it is a single
  Markdown file with no `.al` objects in it, so there is no `alc` compile-breaking reason to push
  it outside the project tree (ALL ALONG → BCQuality Knowledge Snapshot explains why that one is
  different).
- Write a small `SNAPSHOT.json` alongside it recording the source repo, ref, commit SHA, and
  fetch timestamp, so a later refresh has something to diff against and report — same convention
  as BCQuality and the patterns library.
- **Tell the human you're doing this.** Not a silent background fetch.
- **If the repo isn't reachable** (network unavailable, or the file has moved), say so plainly
  and ask the human for a copy rather than proceeding from memory of what the standards say. This
  is a stricter failure mode than the patterns library's — an absent patterns library degrades
  gracefully, an absent standards guide means every `Standards §` citation in the rest of the
  routine points at nothing.
  **Exception, when the OCPF plugin is installed**: the plugin
  bundles a copy of the guide in its `al-standards` skill. Use that copy instead of stopping, per
  ALL ALONG → OCPF Plugin. Record `"source": "ocpf-bc plugin bundle"` and the bundled guide's
  version in `SNAPSHOT.json`, and tell the human plainly that the bundled copy was used and which
  version it is. Offer a refresh from GitHub once the network is back. Without the plugin, the
  rule above stands.

**Always gitignored — not a per-project choice.** Add `standardsGuide/` to this project's
`.gitignore` at PRE-01, the same policy and for the same reason as `patterns/` and the BCQuality
snapshot (ALL ALONG → Repository Hygiene): it is AJ Ansari's own portable, cross-project
methodology, refetchable at will, and not part of what a client is paying to receive when this
framework builds their extension. It is therefore **not** governed by the §1.8 intake question —
that question covers only the runbook, its changelog, and its schematics.

**Refresh only when the human explicitly asks** (e.g. "refresh the standards guide," "get the
latest standards"). Re-run the fetch, overwrite the local copy, and report plainly: "updated from
`<old sha>` to `<new sha>`" or "already up to date."

**Version skew is worth naming, not papering over.** The guide carries its own version number
(v1.7.0.0 as of runbook v2.15.0.0) and is versioned independently of this runbook, with
both tracked in `RunbookChangelog.md`. If a fetched guide's version doesn't match what this
runbook expects, say so — don't silently reconcile a citation that doesn't resolve.

## Reference Sources — Microsoft Learn and AL Guidelines

Alongside the three fetched knowledge sources (the
Standards Guide, BCQuality, the Patterns Library) and the AL MCP Server, the framework grounds its
work in these references. None are fetched into the project — they're consulted online, so
there's nothing to bootstrap, gitignore, or refresh. If the agent has no web access, say so
plainly rather than answering from memory of what a reference says.

| Reference | What it's for | Where the routine uses it |
|---|---|---|
| **BC Base Application docs** (Microsoft Learn) — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application> | Every standard Base App table, field, and datatype/size | Operating Rule 2 fallback; Standards Appendix B |
| **BC System Application docs** (Microsoft Learn) — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application> | The System Application modules (Language, Translation, Email, Telemetry, and others) — check here before building something the platform already provides | Operating Rule 2 fallback; Standards Appendix B; Step 03 design |
| **Working with translation files** (Microsoft Learn) — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files> | How XLIFF translation works in AL; why ML properties are banned | Standards §1.7, Part 8 |
| **Country/Regional Availability and Supported Languages** (Microsoft Learn) — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations> | Where BC is available, who localizes each country, and which languages Microsoft or partners translate. **Read live every time** — never from memory or a copy | Step 01 §1.9; Standards §8.8 |
| **Microsoft Terminology Collection** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-terminology> | Microsoft product terminology in about 100 languages, when BC's own translation files have no match | Standards §8.5, Appendix D |
| **Microsoft Localization Style Guides** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides> | Tone, formality, punctuation, and formats per language | Standards §8.5, Appendix D |
| **AL Guidelines** — <https://alguidelines.dev> (source: <https://github.com/microsoft/alguidelines>, MIT) | Community-driven, Microsoft-hosted AL best practices, design patterns, and agent-oriented *Vibe Coding Rules* | Step 03 (patterns beyond the Standards Guide); Step 09 (best-practice pass) |

**Precedence.** The downloaded symbol file beats Microsoft Learn on anything symbol-verifiable
(Operating Rule 2). The Standards Guide beats AL Guidelines on any AL rule. Surface a conflict to
the human rather than silently reconciling it.

**AL Guidelines' legacy *C/AL Coding Guidelines* pages are never followed** (Standards §1.7).

**Credit.** Every third-party resource this framework references, fetches, or recommends — with
its license and what that license asks of us — is listed in `THIRD_PARTY_NOTICES.md` at the root
of the framework repository.

## BCQuality Knowledge Snapshot

BCQuality (`microsoft/BCQuality` on GitHub) is a curated knowledge base and skill library for BC
AL code quality — not an MCP server, not a running endpoint, just markdown knowledge files (the
non-obvious platform rules: CodeCop specifics, security/performance/privacy footguns, etc.) plus
skills that define how an agent should search and apply that knowledge during review. It
augments review judgment; it does not replace it — an agent's own findings are still valid and
should still be surfaced even without a knowledge-file citation.

**Snapshot strategy — one-time per project, refreshed only on request:**
- Do **not** install it as a plugin, even where the host supports one, and do not keep one
  long-lived copy shared unrefreshed across many unrelated projects — that's how it goes stale
  for all of them at once.
- Do fetch a full, current snapshot from the repo's default branch exactly once, at Step 05
  (alongside the rest of the project scaffold — see Step 05's own bootstrap bullet). **Put it
  OUTSIDE the AL project's own root folder** — e.g. a sibling directory such as
  `../<ProjectName>.bcquality/`, never anywhere under the same tree as `app.json`. This is not a
  style preference: `alc` recursively compiles every `.al` file it finds under the project root,
  with no built-in exclusion mechanism, and BCQuality's own knowledge base ships illustrative
  `.good.al`/`.bad.al` snippets that are deliberately incomplete fragments, not real compilable
  objects — nesting the snapshot inside the project root breaks every subsequent compile with
  hundreds of syntax errors that have nothing to do with the project's own code. (A real project
  did exactly this and only found out when a compile that had been working suddenly produced 470+
  errors, none of them in its own files.) This also matches BCQuality's own documented integration
  pattern, which already uses two separate directories — one for its own checkout, one for the
  app being reviewed — never one nested inside the other. Mirror the repo's own layout inside that
  sibling folder (`skills/`, `microsoft/`, `community/`, `custom/`, `docs/`), via a shallow clone
  (`git clone --depth 1`) rather than fetching hundreds of files individually. **Tell the human
  you're doing this** — it's not a silent background check. Strip `.git` from the snapshot
  (it's a content copy, not a live checkout) — **but never strip its `LICENSE` file**: BCQuality
  is MIT-licensed, and MIT requires the copyright and permission notice to stay with every copy
  (see the framework repository's `THIRD_PARTY_NOTICES.md`) — and write a small `SNAPSHOT.json` alongside it
  recording the commit SHA and fetch timestamp, so a refresh later has something to diff against
  and report.
- **Never committed, and there's nothing to gitignore.** The snapshot doesn't live inside the
  project's git-tracked tree at all — it's outside the AL project root entirely (see the
  snapshot-strategy bullets above), a stronger guarantee than a `.gitignore` entry. BCQuality is a
  review aid fetched from a public repo with no reproducibility requirement — it can be refetched
  at will, and there's no reason for a client's or shared remote
  repository (GitHub, Azure DevOps, etc.) to carry an 806-file, third-party knowledge snapshot. See
  ALL ALONG → Repository Hygiene.
- Refresh **only** when the human explicitly asks (e.g. "refresh BCQuality," "get the latest").
  Re-run the fetch in full, overwrite the existing snapshot, and report plainly: "updated from
  `<old sha>` to `<new sha>`" or "already up to date." The repo is under active development with
  breaking changes possible at any time — that's expected, and exactly why refreshes are
  human-triggered rather than silent.

**Using the snapshot — this is a documented protocol, not something to improvise (verify against
the snapshot's own `docs/agent-consumption.md` before relying on a paraphrase, including this
one, since the repo's own conventions are the authority and can move):**
1. Read `skills/entry.md` from the local snapshot and follow it with an explicit task-context
   (goal, inputs available, technologies, BC version, enabled layers) — resolving BCQuality's own
   instructions/knowledge against the snapshot root, and the actual review target against the
   project's own files. Entry returns a **dispatch record** naming which action skill(s) to run;
   if it returns `no-match` or `failed`, return that record as-is rather than inventing a review.
2. Read the meta-skill contracts (`skills/read.md`, `skills/do.md`, and `skills/write.md` only if
   authoring new knowledge) on demand, not upfront.
3. Invoke each dispatched action skill from the snapshot's layers (`microsoft/skills/`,
   `community/skills/`); for a full code review this is typically the super-skill at
   `microsoft/skills/review/al-code-review.md`, which composes per-domain leaf skills
   (security, performance, privacy, style, etc.) under the same folder.
4. Each action skill runs the same four-step pattern (Source → Relevance → Worklist → Action),
   filtering knowledge files by frontmatter (`bc-version`, `domain`, `technologies`, `countries`,
   `application-area`) across every enabled layer, higher-precedence layers suppressing lower per
   `read.md`. A prebuilt `knowledge-index.json` accelerates discovery when present; when absent
   (the normal state for a static snapshot with no indexer run against it), skills fall back to
   plain path-based discovery by domain folder — review still works either way.
5. Findings come back in the shape `do.md` defines: outcome (`completed` / `not-applicable` /
   `no-knowledge` / `partial` / `failed`), findings with a human-readable `domain` label, structured
   `references` (knowledge-file path, optional commit SHA) for knowledge-backed findings, an empty
   `references: []` for the agent's own findings (capped at `medium` confidence), and a
   `suppressed` list of anything layer precedence overrode. Integrate this into the project the
   same way any other Code Review finding is integrated (Step 09) — never applied blind.

No network access is needed for any of the above once the snapshot exists; only the initial fetch
and an explicit refresh touch the network.

## OCPF BC AL Patterns Library

**OCPF** = **OnlyCopilotFans** — the abbreviation used throughout this section and wherever else
this runbook refers to it.

The OnlyCopilotFans BC AL Patterns library (`ajansari/ocpfBCALPatterns` on GitHub, public —
confirmed reachable September 13, 2026 via `git ls-remote` and its rendered README, not assumed) is
AJ Ansari's own curated collection of reusable Business Central AL coding patterns — each one
extracted from a real bug found and fixed on a past project, then generalized: symptom, verified
root cause (against Microsoft Learn, not memory), the fix, a worked example, and caveats, all in
one self-contained Markdown file per pattern. It is content, not a service — no MCP tools, no
running endpoint, just files — and it is **AJ's own accumulated, cross-project material**, which
is what distinguishes it from BCQuality: BCQuality is a third-party platform-wide knowledge base
this framework consumes; this library is the human's own portable lessons, meant to travel with
him from engagement to engagement and grow every time a new recurring bug class gets documented.

**Fetch strategy — one-time per project, refreshed only on request (same cadence as BCQuality):**
- Fetch from `https://github.com/ajansari/ocpfBCALPatterns` at Step 05, alongside the AL MCP
  Server and BCQuality bootstrap — one-time project setup, not an afterthought once BUILD starts.
- **Unlike BCQuality, this lives INSIDE the project root**, in a folder named `patterns/`. Every
  file in the library is Markdown with embedded AL code, not a real `.al` object — so there is no
  `alc` compile-breaking risk the way there was with BCQuality's illustrative snippets, and
  nothing forces this one outside the project tree.
- **If the repo isn't reachable** (not yet pushed, made private, network unavailable), say so
  plainly and continue — an absent or unreachable library is not a blocker to the rest of Step 05,
  the same way a missing AL MCP Server connection isn't (ALL ALONG → AL MCP Server).
- Get the repo's `README.md` and every pattern file it lists, via a shallow clone
  (`git clone --depth 1`) with `.git` stripped, same as BCQuality — a content snapshot, not a live
  checkout — keeping its `LICENSE` file, same as BCQuality. Write a small `SNAPSHOT.json` inside `patterns/` recording the source repo, ref,
  commit SHA, and fetch timestamp, so a later refresh has something to diff against and report.
- **Merge behavior — this is not a plain overwrite, and the README case is a specific,
  human-specified exception:**
  - If `patterns/` doesn't exist yet, create it and copy the fetched content in directly.
  - If `patterns/` already exists and already has its own `README.md` (e.g., a human-created
    pattern file was already dropped in before the shared library was ever fetched), **do not
    overwrite that README.md — append the fetched repo's `README.md` content to the end of the
    existing one instead**, under a fixed, recognizable delimiter:
    ```
    ---
    ## Upstream README — ajansari/ocpfBCALPatterns @ <commit SHA>
    ```
    followed by the fetched README's full content. That delimiter is what makes a **refresh**
    idempotent: find and replace the block from that heading to the end of the file, rather than
    appending a second copy underneath the first — never append the same upstream block twice. If
    `patterns/` exists but has no `README.md` yet, just write the fetched one as
    `patterns/README.md` directly, no delimiter needed.
  - Pattern files themselves: add any that aren't already present under `patterns/`. If a
    same-named pattern file already exists locally with different content, **do not silently
    overwrite it** — ask which the human wants (rename, replace, or keep the local one), per
    **Operating Rule 6a**, as a selectable options box, not a prose question.
- **Always gitignored — same *policy* as BCQuality and `scripts/`, though the *mechanism* differs
  from BCQuality's** (ALL ALONG → Repository Hygiene): BCQuality lives outside the project root
  entirely, so it isn't even a candidate for git tracking; `patterns/` lives inside the root, so it
  genuinely needs its own `.gitignore` entry to get the same result. Either way, not a per-project
  choice — this is the human's own portable methodology, not part of what a client is paying to
  receive, and it's refetchable at will with no reproducibility requirement.
- **Tell the human you're doing this** — it's not a silent background fetch, same principle as
  BCQuality.
- Refresh **only** when the human explicitly asks (e.g. "refresh patterns," "get the latest
  patterns"). Re-run the fetch, apply the same merge behavior above (never blind-overwrite), and
  report plainly what changed — new pattern files added, or "already up to date."

**Using the library:** before diagnosing a bug from scratch at Step 07 (Compile and Package,
Troubleshoot, Iterate) or in the Testing Feedback Log's reasoning-role diagnosis (ALL ALONG — see
that section's own role bullet, which carries the same check), check whether `patterns/` already
documents this class of problem — that is the entire point of the library existing: turning a
previously-solved bug into a fast recognition instead of a fresh investigation. If a fix produced
during this project looks like it will recur on future projects (not a one-off, project-specific
defect), that's a candidate for a new pattern file — flag it to the human rather than deciding
unilaterally to add one, since contributing back to a shared, cross-project library is the
human's call, not the agent's.

## OCPF Plugin (Optional)

This framework is also distributed as an agent plugin,
`ocpf-bc`, from the same repository (`agentPlugin/ocpf-bc`, listed in
`.claude-plugin/marketplace.json`). It works in Claude Code, the Claude apps, GitHub Copilot (VS
Code, Copilot CLI, github.com), and Microsoft Copilot Cowork. The plugin is **optional**. Copying
this runbook into a project by hand, as `CLAUDE.md` or `.github/copilot-instructions.md`, is still
fully supported and behaves exactly as it always has.

**This section applies only when `.ocpf/framework.json` exists in the project root.** The plugin's
`start` skill creates it when it installs this runbook. It records:
- the edition and runbook version,
- where the runbook copies were placed (`placedAs`),
- the source and commit they came from,
- the plugin version,
- a version the human chose to skip (`declinedUpdateVersion`),
- the AL MCP Server outcome (`alMcp`).

Without that file, skip this section entirely. The `.ocpf/` folder follows the §1.8 framework-files
answer, except `.ocpf/notifications.json`, which is always gitignored (ALL ALONG → Notifications).

**Framework update check, once per session.** At the start of each session, before resuming work:
1. Read `runbookVersion` and `declinedUpdateVersion` from `.ocpf/framework.json`.
2. Read the `**Version:**` line of the latest published runbook. Download it; don't summarize it.
   - Full: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/BC_App_Build_Routine_Agent.md`
   - Lite: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_BC_App_Build_Routine_Agent.md`
3. Compare versions numerically, part by part.
   - **Latest is newer and isn't the skipped version:** tell the human in a sentence or two and
     offer **Update now / Not now / Skip this version** through the options mechanism (Rule 6a).
     "Update now" follows the plugin's `update-framework` skill:
     - summarize the changelog entries in between, flagging any that touch a completed step,
     - back up each current copy to `.ocpf/previous/`,
     - replace every copy in `placedAs` and the project's `RunbookChangelog.md`,
     - update the marker,
     - record the change in `ChangeLog.md` and `docs/ProjectMemory.md`,
     - re-read the runbook before continuing.
   - **Current:** say nothing.
   - **GitHub unreachable:** mention it in one line and carry on.

**Never replace the project's runbook without an explicit yes.** A project keeps the rules it
started with until the human chooses otherwise, the same principle as Operating Rule 6.

**What else the plugin changes, and where each is defined:**
- **Standards Guide fallback:** a bundled copy is used when GitHub is unreachable at PRE-01 (ALL
  ALONG → OCPF AL Development Standards Guide).
- **AL MCP Server:** the plugin's `al-mcp-setup` skill connects the AL tools with nothing to
  install. It uses the AL extension's built-in tools in Copilot Chat, or registers the extension's
  bundled AL MCP Server for other MCP hosts (ALL ALONG → AL MCP Server; Operating Rule 6d).
- **Sub-agents:** `ocpf-reasoning` and `ocpf-light` carry the §1.7 Reasoning and Light roles
  (Step 01 §1.7).
- **Other skills:** `status` reports where the project stands. `al-standards` makes the Standards
  Guide available for ad hoc AL questions.

**Optional github.com reviewer.** The repository also ships a GitHub Copilot custom agent for
github.com: `agentPlugin/github/agents/ocpf-code-reviewer.agent.md`. It reviews the extension
against Step 09 and the Standards Guide, writes `CodeReview.md`, and never edits AL.
- **When to offer it:** once, at Step 09, if the project is hosted on GitHub and the team uses
  Copilot.
- **If the human wants it:** copy the file into the project's `.github/agents/`. This file **must
  be tracked** in git, or github.com can't see it.
- **Inside this routine,** its report is a Step 09 input like any other finding: the main role
  still applies every fix through the Step 07 cycle.

---

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
| 10 — Deployment | 12 (sandbox, human-run release test) → production deploy of that same package, per `Deployment.md` |

---

*Routine created by AJ Ansari, Microsoft MVP, OnlyCopilotFans. Update this runbook when the framework or the standards change.*

