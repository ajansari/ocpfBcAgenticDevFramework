# BC App Build Routine — Lite Agent Runbook

## OnlyCopilotFans Agentic Dev Framework — Lite Edition

**Version:** 2.3.0.0 (Lite, derived from the full framework v3.4.0.0)
**Last Updated:** September 18, 2026

> Version history for this edition lives in `LITE_RunbookChangeLog.md`, tracked independently of
> the full framework's own `fullVersion/RunbookChangelog.md` (though a change to one often has to
> be reflected in the other) and of any one project built with it. Diagrams for this routine live
> in `LITE_RunbookSchematics.md`. If either file is not found, create it.

> This is the lightweight sibling of the full **OCPF BC Agentic Development Framework**
> (`fullVersion/BC_App_Build_Routine_Agent.md`, in the same repo). Same author, same underlying
> discipline — half the steps, one model doing all the work, and no ceremony that a
> 10-files-or-fewer project doesn't need.

> **Companion documents, both fetched at Step 1 and shared unchanged with the full framework:**
> - `standardsGuide/ocpfALDevStandardsGuide.md` — the **OCPF AL Development Standards Guide**
>   (v1.9.0.0), cited as **Standards §**. Lite is *not* a reduced set of AL rules: the same rules
>   apply to a 5-file extension as to a 50-file one. What Lite reduces is *process*.
> - `opsGuide/ocpfOperationsGuide.md` — the **OCPF Operations Guide** (v1.3.0.0), cited as
>   **Ops §**: the procedures this routine uses — asking, intake, project setup, AL tools,
>   analyzers, symbols, editor sync, notifications, packaging, repository hygiene, translations,
>   fetched companions, and the plugin.
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
> `docs/ProjectParameters.md`, not just discussed — every later step reads it from
> that file. At the start of every session, read `.ocpf/notifications.json` and keep notifying the
> human the way it says; if it's missing, ask how they want to be notified (ALL ALONG →
> Notifications).
>
> **One model does everything.** Lite drops the full framework's Main/Light/Reasoning role split.
> There's no delegation to configure — the executing agent plans, generates, reviews, and documents,
> in that order, within each step. Step 1 still asks which model and thinking effort that one
> agent runs on, and confirms the session matches (Ops § Roles).
>
> **Every project document lives in `docs/`.** `docs/ProblemStatement.md`, `docs/ProjectParameters.md`,
> `docs/DesignDoc.md`, `docs/ChangeLog.md`, `docs/Docs.md`, `docs/TestScript.md`, and every translated
> copy — created at Step 1, before the first document is written. Of the routine's own outputs, only
> `requirements/`, `app.json`, the AL source, `Translations/`, and `outputAppPackage/` stay in the
> project root. Every step names
> its documents with the `docs/` prefix; a bare name still means the `docs/` path. At every exit
> gate, list the root: a document sitting there is moved with `git mv` and the move noted in
> `docs/ChangeLog.md`. On a real project the design documents landed in the root because the steps
> named files without their folder.
>
> **Prime directive:** an ambiguous input produces ambiguous code. If a step's inputs are
> incomplete or contradictory, stop and ask the human — do not invent rules to fill the gap.
>
> **Installed by the OCPF plugin?** If this project has a `.ocpf/framework.json` file, it was set
> up by the OnlyCopilotFans agent plugin. Read ALL ALONG → OCPF Plugin before anything else in this
> session: it adds a once-per-session framework update check, a Standards Guide fallback, and
> one-step AL tool setup. Without that file, ignore that section. Everything else here works
> the same either way.

### Setup

Same as the full framework: drop this file into the project root and rename it so your tool picks
it up automatically — `CLAUDE.md` for the Claude Code plugin in VS Code, or
`.github/copilot-instructions.md` for GitHub Copilot Chat. Keep this file itself as your master
copy elsewhere if you maintain more than one project.

You don't need to copy the Standards Guide by hand — Step 1 fetches it from the framework
repository into `standardsGuide/` and gitignores it there.

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
   the end of Step 1 (ALL ALONG → Symbols); the human never has to. **Fallback** when the
   downloaded symbols don't answer: Microsoft Learn's Base Application and System Application
   reference (**Standards Appendix B**; links in ALL ALONG → Reference Sources). The downloaded
   symbols win when the two disagree.
3. **Treat the whole extension as one batch — two only if there's a natural split** (e.g., "setup
   + master data" vs. "documents"). At 10 files or fewer there is rarely a reason for the full
   framework's multi-batch phasing. Order objects within the batch so lookup/reference tables
   precede the entities that reference them.
4. **Lint everything as it's written; don't compile until generation is finished.** Run Step 3's
   pre-flight checklist on every object as it's generated, both passes, including symbol
   verification (Rule 2). The whole extension compiles and packages once, at Step 5, the moment
   Step 4 finishes. After that, every code change goes through the same cycle: compile, package,
   deploy to a sandbox, test, fix, repeat. Treat any compile error as systemic: fix the rule, then
   every file it touched.
5. **Zero errors, zero warnings before PROVE.** A warning is a defect. Step 5's compile must reach
   0/0, with the analyzers and nothing suppressed (ALL ALONG → Analyzers), before Step 6 begins.
6. **Human-in-the-loop is a feature — approve in batches, not one click at a time.** Pause for
   human approval before:
   - **generating code** — once, for the batch plan at Step 3, which covers both batches when there
     are two, unless the human chose to be asked before the second;
   - **applying root-cause fixes** — all the diagnoses from one test round or review, presented
     together for one decision (Step 5), with any fix that changes a design rule in `docs/DesignDoc.md`
     asked separately;
   - **finalizing the Design Doc;**
   - **installing any tool or runtime.**

   An approved run-through still stops by itself on any pre-flight failure or deviation from
   `docs/DesignDoc.md`, and the human can say "stop" at any time.
   6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human
       to *decide* something — pick a design option, approve a version bump, resolve an ambiguity —
       present it through the interactive multiple-choice mechanism the agent's harness provides
       (e.g., Claude Code's `AskUserQuestion`), recommended option first with a short reason. Don't
       wrap ordinary progress (finishing a step, reporting a clean compile) in this — that's just
       noise. **Every intake question counts as a decision**, including values only the human
       knows: names, publisher, prefix, namespace, localization, ID ranges, versions. Ask them
       through the options mechanism, never as open-ended questions or a numbered list in chat;
       the mechanism's free-text entry (Claude Code: *Other*) carries a typed answer. Step 1 says
       what to offer. **Which mechanism each harness offers, and the option-count limits, are
       Ops § Asking and Approvals.**
   6b. **Don't install tooling without asking — and look harder first.** Before concluding a
       required compiler/runtime is missing, check whether the human's own IDE already provisions
       one privately (e.g., VS Code's AL extension gets its .NET runtime from a companion
       extension, not a system install). Installing anything is itself a human-in-the-loop
       decision regardless of what a fallback elsewhere in this runbook lists as available.
   6c. **From Step 5 onward, check in only after a step that hands the human something to act
       on.** Step 5 always does (a tested package): once its exit gate is met, put the choice
       through the selectable-options mechanism (Rule 6a) — proceed directly into Step 6, or stop
       here so the human has room to review, run, or publish the package. State how to resume. A
       step that produces nothing the human must act on yet gets one line instead (e.g., "done;
       starting Step 6 — say stop to pause"). Steps 1–4 are unaffected — Rule 6's own approval
       gates pace them.
       **The Step 6 → Step 7 boundary is a special case of this rule, not an addition to it** —
       see Step 7's own hand-off note, which replaces this generic check-in for that one
       transition. Don't do both.
   6d. **Zero-install first — never turn setup into the human's job.** Before proposing any
       install, or any manual setup (editing `PATH`, a shell profile, or an environment variable),
       work through the ladder in **Ops § Asking and Approvals**: what the editor already provides,
       then what's already installed, then — only then — an install asked for under Rule 6b.

       **Never hand the human a setup task the agent can do.** Connecting the AL tools, downloading
       symbols, keeping the editor's view current, and setting up notifications are the agent's job;
       the human approves the AI tool's prompts and signs in when a tool reaches a live Business
       Central environment. **Never send the human to the Command Palette to set up the AL MCP
       Server** — the AL Language extension has no such command — and never route AL tooling through
       a third-party VS Code extension.
7. **Log every deviation immediately.** Any departure from the Design Doc — human or agent — goes
   in `docs/ChangeLog.md` before the next batch starts.
8. **Work in the human's chosen working language.** The first question of Step 1 asks which
   language the human wants to work in. Every later question, options box, and explanation is in
   that language. **Always in English, regardless:** this runbook, the Standards Guide, AL code
   and names, commit messages, `docs/DesignDoc.md`, and `docs/ChangeLog.md`. **Kept verbatim in their
   original language:** raw requirements and tester feedback. When the human names a BC concept in
   their own language, map it through the glossary in `docs/DesignDoc.md` rather than guessing.

---

# PHASE: DEFINE

Goal: turn a business need into a validated scope and a filled-in parameter sheet — before any
design work.

## STEP 1 — Define the Problem & Lock Parameters

**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**
- **Ask the working language first — before anything else** (Operating Rule 8). Ask in English,
  through the options mechanism, with English listed first and free text for any other language.
  It's asked alone, so every later box can be in the language chosen. Continue in the language
  chosen.
- **Fetch both companion guides first, before anything else needs them.** Get
  `standardsGuide/ocpfALDevStandardsGuide.md` into `standardsGuide/` and
  `opsGuide/ocpfOperationsGuide.md` into `opsGuide/`, from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/`, and **add both folders to
  `.gitignore`** — see ALL ALONG → OCPF AL Development Standards Guide. The gap check below leans on
  Standards Part 6, and this step's notification and intake procedures are Ops §, so neither can
  wait for Step 3 the way the other fetched libraries do. Tell the human you're doing it.
- **Ask how to be notified, right after the working language** (Ops § Notifications — read it now): Claude app, sound,
  desktop notification, any combination, or none. Record it in `.ocpf/notifications.json` and
  apply it, so every later question reaches the human even when they've stepped away.
- **Ask which model does the work, right after notifications** (Rule 6a; **Ops § Roles — read
  it now**). Two questions in one box, recommended answer first and free-text entry for anything
  else: **Main model** (*Sonnet — recommended*) and **Main thinking effort** (*High — recommended* /
  *Medium* / *Low*). Say which model this session is running on before asking: in Lite the one
  model *is* this session, and only the human can change it (`/model` and `/effort` in Claude Code;
  the model picker in Copilot). If they choose something other than what's running, ask them to
  switch now and confirm before continuing — never record a model that isn't the one doing the
  work. The answer goes in the Project Parameters below. Asked here, not in the intake boxes, so
  it's settled before the first document is drafted. In a plugin project the plugin's `roles` skill
  (`/ocpf-bc:roles`) asks and records it.
- **Create the `docs/` folder now** — every document from here on is written there (see the
  header note; only `requirements/` and the build outputs stay in the root).
- **Capture any raw requirements input verbatim, before interpreting it.** If the human pastes raw
  requirements in chat, or uploads a file, save it untouched in a `requirements/` folder (a
  descriptive filename, or the file's own name for an upload) before doing anything else with it.
  Never commit this folder to `.gitignore`. Re-apply this the moment any later requirements or
  change-request input arrives, not only at kickoff.
- Write a short problem statement: what business outcome is required, who the consumers are
  (users, other systems, AI tools, BI/reporting), which countries and languages they work in, and
  what's explicitly out of scope. Capture the domain vocabulary the design will anchor to —
  including any standard BC term whose wording differs between those countries (for example VAT /
  GST / Tax; Credit Memo / CR/Adj Note — Microsoft's actual US and Australian terms).
- Produce an initial entity/object list — at 10 files or fewer this is usually a handful of
  tables/pages, not a multi-page inventory. As the agent, run a **quick gap check** against
  standard BC modules before treating the list as final: is there a posted/archived counterpart
  for every open document? A lookup table already standard in BC instead of a new one? A modern
  table instead of a legacy one? Mark anything genuinely uncertain rather than guessing. **The
  full checklist, with the actual entity-by-entity tables, is Standards Part 6** — worth a read
  rather than a skim even on a small project, since a missed posted counterpart or a legacy price
  table costs far more to add after BUILD than before it.
- Identify duplicates, ambiguous terms, and outdated terminology; ask clarifying questions about
  scope and consumer use cases. Do not resolve ambiguities silently.
- **Populate the Project Parameters block below, and persist it as `docs/ProjectParameters.md`.** Complete every field; replace every placeholder. These values override all
  defaults for the rest of the routine, and every later step reads them from that file rather than
  from conversation history.

**Ask first, don't infer — and ask interactively** (Rule 6a). **How to ask — the boxes, what to
offer for each question, and the language questions — is Ops § Intake. Read it before the first
box.** In short: every question goes through the options mechanism, grouped into as few boxes as the
questions allow (identity, naming, permission sets and IDs, onboarding, setup and languages, then
the translation questions); countries are asked once; a suggestion is a candidate the human picks,
never an answer recorded for them; and the whole sheet is confirmed once at the end. Lite asks only
the Main model and effort — already asked above, right after notifications — not the full
framework's Light and Reasoning questions.

**The Permission Set App Code question exists because** permission sets named from the prefix alone
(`OCPF - READ`) collided across every extension with that prefix (**Standards §5.4**).

**Tell the human where their built packages will land:** always `outputAppPackage/` in the project
root (ALL ALONG → Packaging & Versioning). Mention it once, plainly, now.

### Project Parameters

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Extension Name** | `<ExtensionName>` | No AL quotes. → `app.json "name"`. |
| **Publisher** | `<Publisher>` | No AL quotes. → `app.json "publisher"`. |
| **Deployment Target** | `<DeploymentTarget>` | One of: `AppSource`, `SaaS PTE`, `OnPrem PTE`. **`AppSource` adds a block of mandatory `app.json` parameters and narrows the ID range** — read **Ops § Intake → *The AppSource questions*** before Box 3, and **Standards Appendix E**. |
| **AppSource manifest set** *(only if Deployment Target = `AppSource`)* | — | `brief`, `description`, `url`, `logo`, `privacyStatement`, `EULA`, `help`, `contextSensitiveHelpUrl`, and `applicationInsightsConnectionString` where given. Each is **mandatory for submission** — a missing one is a rejected submission, not a warning. `name`, `publisher`, and `version` must match the Partner Center offer exactly. Anything deferred is recorded as a release blocker. |
| **Use Namespace (y/n)** | `<UseNamespace>` | Default `Yes`. If `No`, no generated file gets a `namespace` line. |
| **Namespace** | `<Publisher>.<ExtensionShort>` | N/A if Use Namespace = `No`. PascalCase, no spaces. |
| **Localization** | `<Localization>` | E.g. `W1`, `NA`, `EU`, `US`. Drives field/table inclusion. |
| **AL Object Prefix** | `<prefix>` | Short, lowercase. Used in page names/identifiers. |
| **APIPublisher / APIGroup Prefix / APIVersion** | — | Derived: the Publisher in camelCase (`'contoso'`), the prefix followed by a PascalCase group name (`'acmeCoreFinancial'`, no underscore), and `'v1.0'` — same values everywhere (**Standards §2.7**). |
| **Permission Set App Code** | `<APPCODE>` | Uppercase letters or digits, no spaces, unique among every extension that uses this prefix, at most `13 − (prefix length)` characters (**Standards §5.4**). |
| **Permission Set Names** | `<PREFIX> <APPCODE>, VIEW` / `<PREFIX> <APPCODE>, EDIT` | Derived: `<PREFIX>` is the AL Object Prefix in uppercase. Each ≤ 20 characters, e.g. `OCPF NAICS, VIEW`. |
| **Object ID range(s)** | — | Primary + any Additional, from Box 3. **The range belongs to the Deployment Target** (**Standards §5.5**): PTE work uses 50,000–99,999; `AppSource` uses only a range Microsoft registered to this publisher (70,000,000–74,999,999 for a new publisher), never 50,000–99,999. |
| **Permission Sets required?** | `Yes`/`No` | `No` only if the extension owns **zero new tables** (**Standards §5.3**); otherwise `Yes`, not asked. If `Yes`, reserve ≥ 2 IDs in the primary range. |
| **AL Runtime / BC Application Minimum / Symbol Source** | — | BC version from Box 2; runtime from Microsoft Learn. Symbol Source is filled in by the agent after downloading: version, W1 or localized, and where from. |
| **Onboarding extras** | `Yes`/`No` each | Assisted Setup Wizard? Role Center Activity Cues? Departments/"My Business Central" placement? Box 4; `No` to any is a final answer, not a placeholder — most small extensions answer `No` to all three, but ask anyway. |
| **Framework files in `.gitignore`?** | `Yes` (default) | Box 5, asked as: *"`.gitignore` lists files Git leaves out of commits and pushes — they stay on disk and work normally. Should this framework's own files be left out of this project's repository?"* With `Yes`, these exact entries go into `.gitignore` — by name, every one, not "the framework files" in the agent's head: the runbook under whatever name it was given (`CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/ocpf-framework.instructions.md`, `LITE_BC_App_Build_Routine_Agent.md` — only the ones that exist), `LITE_[Rr]unbook[Cc]hange[Ll]og.md` (both spellings the changelog has shipped under; a case-sensitive entry misses one on Linux and in CI), `LITE_RunbookSchematics.md`, and `.ocpf/` (with `.ocpf/notifications.json` always ignored). **Then prove it:** `git check-ignore -v <file>` on each file that exists, and `git status --porcelain` on the root; a framework file still showing means the entry is wrong. On a real project the changelog was left out and shipped to the client's remote. **Never the project's own `docs/ChangeLog.md`**, which is always committed. The full block is Ops § Repository Hygiene. |
| **Working language** | — | From the first question of this step. |
| **Main model & thinking effort** | `<MainModel>` / `<MainEffort>` | Asked right after notifications (Ops § Roles): the model this one agent runs on (recommended Sonnet) and its thinking effort (High recommended / Medium / Low). Recorded as the human named them, plus the harness's own identifier (e.g. `sonnet`). Must match what the session is actually running — the human switches the session, not the agent. Lite has no Light or Reasoning rows. |
| **Target languages** | table | Box 5, for the countries from Box 1 — Lite groups the setup and language questions together (Ops § Intake) — never asked again (rules: **Standards §8.8**). Classify each chosen language as Microsoft-translated, partner-translated (ask which partner app, in the next box — it's the terminology source), or not supported by BC (every right-to-left language included). Don't offer an unsupported language; if typed, offer the country's English instead, and only record it if the human insists. Then, unless source wording is *US wording, no translation files*, per language, two questions: *Required at first release* / *Can follow later*; and who reviews it — names the human mentioned, or *I'll type it*; a named fluent person, never the agent. Flag any mismatch with **Localization**. |
| **Source language** | `en-US` (default) | Offer `en-US` first, labelled recommended, with the one-line reasons in **Standards §8.1**. If the human chooses another, state the consequences before recording it. |
| **Source wording** | `W1` | Microsoft's W1 English wording in source, with one translation file per target language (`en-US` included). Only when `en-US` is the **sole** target **and Deployment Target isn't `AppSource`** (AppSource requires translation files — **Standards §8.10**), also offer *US wording in source, no translation files* — simpler now, but another market later means changing source strings. |
| **Documents in other languages** | per document | Only with a target language other than the source. Two questions: translate `docs/Docs.md`'s user-guide section into each required language (*Yes (recommended)* / *No*); and does `docs/TestScript.md` need a translated copy (*No — testers run the language pass from the English script, which names the terms they should see (recommended when testers read English)* / *Yes*)? `docs/DesignDoc.md` and `docs/ChangeLog.md` stay English. Translated documents are produced at Step 7, once the functional test pass is green. |
| **Customer-language documents / translatable data** | `Yes`/`No` each | Two questions: do invoices or emails follow the customer's language? Does the extension store user-entered text needing per-language versions? (**Standards §8.9**) |

**Quoting reference** (applies everywhere): `app.json`/`launch.json` use standard JSON strings;
AL string property values use single quotes (`APIPublisher = 'contoso';`); AL object names use
double quotes (`page 90800 "acmeCustomers"`); BC field names with spaces use double quotes
(`Rec."Document No."`).

**Entity-naming patterns** (prefix `acme` as example, all camelCase — **Standards §2.7**):
`APIGroup = 'acmeCoreFinancial'`, `EntityName = 'acmeGeneralLedgerEntry'`,
`EntitySetName = 'acmeGeneralLedgerEntries'`,
`ODataKeyFields = SystemId` always. Both names ≤ 30 characters including the prefix — when one
doesn't fit, shorten it with the BC standard abbreviations in **Standards §4.2**, not with
improvised ones (`Gen`, `Bus`, `Prod`, `CrMemo`, `Dtld`…; **Standards §4.4** has worked examples
of the long names that need it). Singleton tables (e.g. a setup table): `EntityName =
EntitySetName`. Use modern BC names, not legacy ones (e.g. table "Job" → `EntityName =
'<prefix>Project'`).

`NoImplicitWith` is enabled and enforced on every project — not a choice.

> **This block is authoritative, and the Standards Guide defers to it.** The guide deliberately
> keeps no copy of these parameters, so the two can never drift apart — everything it says about
> names, IDs, prefixes, and versions means "whatever is filled in here."

**Once the human confirms the sheet, set up the AL project before DESIGN** — the agent's job, never
the human's (Rule 6d). **Full procedure: Ops § Project Setup.**
1. **Write `app.json` once, complete,** from the sheet, keeping an existing `id` GUID.
2. **Connect the AL tools** if this session doesn't have them (ALL ALONG → AL MCP Server).
3. **Download symbols**, record the Symbol Source, and gitignore `.alpackages/` (ALL ALONG →
   Symbols).
4. **Keep the editor in sync** (ALL ALONG → Keeping the Editor in Sync).

**Outputs:** `standardsGuide/` and `opsGuide/` (both fetched, gitignored), `requirements/` (if any raw input was
captured), `docs/ProblemStatement.md` (purpose, scope, out-of-scope, entity list, open questions),
`docs/ProjectParameters.md` (the completed Project Parameters block, all placeholders
replaced, the Main model and effort included), `docs/` itself (created before the first document),
`.gitignore` populated per the table above and verified with `git check-ignore`, `app.json`, and
`.alpackages/`.

**Exit gate:** Every question was asked through the options mechanism. `app.json` matches the
sheet, and the target version's symbols are in `.alpackages/` (Ops § Project Setup). Both companion guides are present, in `standardsGuide/` and
`opsGuide/`, and gitignored. The notification choice is recorded in
`.ocpf/notifications.json`, applied, and tested. `docs/ProjectParameters.md` exists, in `docs/`, with no placeholder remaining, and the Main model and effort recorded there match what this session is running on. Every `.gitignore` entry from the framework-files row is present and `git check-ignore` confirms each existing framework file — `LITE_RunbookChangeLog.md` included — is ignored. Nothing from the `docs/` list is in the project root. Deployment Target
is one allowed value. Namespace is consistent or correctly N/A. If
Permission Sets required = `Yes`, ≥ 2 IDs are reserved. Onboarding questions are each answered.
Every target language is classified against Microsoft's live page and, unless source wording is
*US wording, no translation files*, has a required-at-release answer and a named reviewer; source
language and wording are recorded. Human confirms the sheet.

---

# PHASE: DESIGN

Goal: one self-sufficient Design Doc, sanity-checked, before any code.

## STEP 2 — Write the Design Doc & Self-Check

**Inputs:** `docs/ProblemStatement.md`, `docs/ProjectParameters.md`, BC symbol file.

**Actions:** Write **one** document — `docs/DesignDoc.md` — that does the job the full framework splits
across an FRD and a TDD. It must be self-sufficient: someone who's never seen the project should
be able to produce every object correctly from this document alone. Two halves, one file:

**Part A — What & Why (business language):**
- Purpose, scope, explicit out-of-scope list; business objectives; target consumers.
- Platform requirements (BC version, deployment model) from the Parameters.
- Entity/object inventory: every object, its source table, and read vs. read/write designation —
  set read vs. read/write from actual data mutability, not preference (**Standards §2.2** has the
  category-by-category table: master data and open documents editable, posted entries and
  registers read-only).
- Non-functional requirements: compilation cleanliness, performance, compliance.
- Languages and markets: every target language, what's required at first release,
  customer-language documents, translatable data.

**Part B — How (technical):**
- System identity: Publisher, namespace, prefix, APIPublisher/APIGroup/APIVersion, AL runtime, BC
  minimum, object ID range(s) — all copied from the Step 1 Parameters, not restated by memory.
  Assign IDs sequentially and **leave a handful unallocated at the end of the range** rather than
  spending it all — those are what gap-fill work at Step 6 draws on (**Standards §5.2**; Lite
  skips the full framework's module sub-blocks, but not the buffer).
- **Per-object spec** — for every object: ID, type, source table name *and* verified source table
  number, `PageType`, `APIGroup`, `EntityName`, `EntitySetName`, `ODataKeyFields = SystemId`, and
  exactly one of `DelayedInsert = true` / `Editable = false`.
- **Per-field spec** — source name and camelCase identifier for every field (conversion rules:
  **Standards §4.1**); which fields are excluded and why (**Standards Part 3**, driven by the
  Localization parameter, and **§3.2** for obsolete fields); abbreviations applied (**§4.2**); reserved-keyword resolutions (**§4.3** — `area` →
  `areaCode`, and the rest).
- **Computed-field pattern, decided per field:** state for each calculated-looking field whether
  it's a `FlowField` or a stored field seeded by a trigger that never overwrites a user's value
  (**Standards Part 7**).
- `SourceTableView` filters for any document-type-filtered page, with correct `const()` quoting —
  quote multi-word enum values, never single-word ones; either mistake is a parser error
  (**Standards §2.3**).
- `using` directives — exact namespace per object, copied from the symbol file (**Standards §1.1**,
  **§3.4**).
- Design patterns the Standards Guide doesn't cover (error handling, events, no. series, and
  similar): consult AL Guidelines (ALL ALONG → Reference Sources) and cite the guideline used,
  rather than inventing a pattern.
- Permission sets, if required (see Step 1): a read-only set and a read/write set (which includes
  the read-only set), with every table's `tabledata` grant enumerated per set — not just "sets
  exist" — named from `docs/ProjectParameters.md`, each ≤ 20 characters with a caption ≤ 30
  (**Standards §5.3–§5.4**).
- **Upgrade and data migration** — needed from the second version onward, and whenever this version
  changes what existing data must look like: the upgrade codeunits, the trigger each uses, and the
  upgrade tag guarding each one; the two-version obsolete cycle for any field being replaced
  (**Standards Part 9**). **"No upgrade code needed" is written down with its reason**, not left
  silent.
- **Events** — which events this extension publishes (its extension points) and which Microsoft
  events it subscribes to, each verified in the symbol file (**Standards Part 10**).
- Special notes: singletons, header/line pairs, naming conflicts, deletion behavior for each
  entity (block-if-referenced / cascade / allow) — including any *other* table (standard BC
  included) that references this entity by `TableRelation`.
- **Translatable text** (**Standards §8.3**): every message a `Label` with an AA0074 suffix and a
  `Comment` for each placeholder; which labels are `Locked`; translation file names
  (`Translations/<ExtensionName>.<culture>.xlf`).
- **Translation glossary** — a table in `docs/DesignDoc.md` (skip if the project chose *US wording, no
  translation files*): BC concept · W1 source term · one column per target language · where each
  term came from · status (`verified` / `reviewer attention`). Fill every row with **Standards
  Appendix D** — Microsoft's own translations first — never from model memory.
- **API caption locking — decided interactively** (**Standards §8.6**; skip if there are no API
  pages or queries):
  1. Classify every API page and API query as **Business**, **Technical — admin**, or **Technical
     — internal plumbing**, each with a one-line reason. List anything that could go more than one
     way as **Unsure**.
  2. Ask about each Unsure object first (*Business* / *Technical — admin* / *Technical — internal
     plumbing*).
  3. Ask about Business: *Translatable (recommended)* / *Locked*.
  4. Ask about Technical: *Admin translatable, plumbing locked (recommended)* / *All translatable* /
     *All locked*.

  Each recommendation cites Microsoft's precedent from §8.6. Skip empty groups. Record the group,
  the locked decision, and who decided, per object in Part B. Repeat for any API object added
  later.

**Self-check, before calling this step done** (same agent, same pass — no separate reviewer role
in Lite, but don't skip the checklist just because there's no one else to hand it to):
- [ ] Every entity from Step 1 maps to at least one object here (or is explicitly deferred).
- [ ] Every object has a valid ID inside the allocated range.
- [ ] Every source table number is verified against the symbol file — not estimated.
- [ ] Every field complies with the Localization parameter; every obsolete/pending field excluded.
- [ ] Every `using` namespace is sourced from the symbol file.
- [ ] All entity/field names ≤ 30 characters.
- [ ] Read vs. read/write designations match actual data mutability.
- [ ] Permission sets are fully enumerated if required, and named with this extension's App Code
      (**Standards §5.4**).
- [ ] Every entity's deletion behavior is explicitly decided, not left to a template default.
- [ ] Every target language has a named reviewer; every regional term is in the glossary, verified
      or marked for reviewer attention.
- [ ] Every API page and query has a recorded group and caption-locking decision.

**Outputs:** `docs/DesignDoc.md`; an **Object Register** table (inside `docs/DesignDoc.md` is fine at this
scale — every planned object with its ID, source table, and R/W status).

**Exit gate:** Human sign-off. Self-check passes with 0 blocking issues. No rule requires
knowledge outside the document.

---

# PHASE: BUILD

Goal: generate AL, lint clean — including symbol verification — then compile, package, test, and
fix in a loop until clean.

## STEP 3 — Plan & Scaffold

**Inputs:** `docs/DesignDoc.md`, Object Register.

**Actions:**
- Confirm the batch plan from Operating Rule 3 (one batch, or two on a natural split) and object
  order within it (lookups before the things that reference them). **This is the one approval to
  generate code** (Rule 6). With two batches, ask once (Rule 6a): **Run through both batches,
  stopping on any pre-flight failure or Design Doc deviation (recommended)** / **Ask me before
  the second batch**. Record the answer in `docs/ChangeLog.md`.
- Prepare the scaffold: confirm `app.json` (written at the end of Step 1) still matches
  `docs/ProjectParameters.md` — name, publisher, ID ranges, runtime, BC dependency,
  `"features": ["NoImplicitWith", "TranslationFile"]` (**Standards §8.2**) — then `launch.json`,
  folder structure, a `Translations/` folder, `.gitignore` per Step 1 and Ops § Repository Hygiene (plus `*.g.xlf` and
  `.alpackages/`), and the analyzer files: `.vscode/settings.json` with the analyzers for the
  Deployment Target, plus `AppSourceCop.json` for AppSource (ALL ALONG → Analyzers). Outside GitHub
  Copilot Chat, confirm `scripts/al-analyze.*` is present, and copy or fetch it if not. If
  `app.json` has to change, follow ALL ALONG → Keeping the Editor in Sync.
- **Agree the translation tooling** (skip if *US wording, no translation files*). Recommend the
  XLIFF Sync PowerShell module (`XliffSync`) for the agent, plus the XLIFF Sync VS Code extension
  for reviewers. Offer NAB AL Tools as the alternative. Look for existing installations first, and
  ask before installing anything (Rule 6b).
- Bootstrap the BCQuality knowledge snapshot and the OCPF BC AL Patterns library (both ALL
  ALONG) — one-time-per-project setup, cheapest done now alongside the rest of the scaffold. (The
  Standards Guide, the AL tools, and symbols are **not** in this group: Step 1 already set them
  up, since DEFINE and DESIGN need them. Confirm `standardsGuide/` is present and gitignored, the
  AL tools respond, and `.alpackages/` holds the target version's symbols, rather than redoing
  any of it.)
- Write the pre-flight checklist for each object — one list, run twice per object since one model
  is doing both passes:
  - **Pre-generation** (on the planned name/fields): identifier length ≤ 30, API names camelCase
    (**Standards §2.7**), reserved-keyword scan, localization field-range filter, `ObsoleteState`
    filter.
  - **Post-generation** (on the actual file): `Caption`, `ToolTip`, and `ApplicationArea = All`
    on every field (**Standards §1.4**); the file named after its object (**§1.8**); no ML
    properties and no `TextConst` (**§1.7**); translatable text — no string literal in a user-facing message, AA0074 suffixes, a `Comment`
    on every placeholder label (**§8.3–§8.4**); API caption locking matches the Step 2 decision
    (**§8.6**); `Rec.`-qualification (**§1.2**); no empty triggers, `// TODO`, or commented-out
    fields (**§1.5**); 4-space indentation, no tabs (**§1.6**); `tabledata` coverage for any table
    the object introduces (**§5.3**); permission set names from the App Code, ≤ 20 characters
    (**§5.4**); and **symbol verification** for every standard reference (**Appendix B**). The
    analyzer-enabled compile at Step 5 proves several of these again (ALL ALONG → Analyzers).

**Outputs:** Batch plan, project scaffold, the pre-flight checklist.

**Exit gate:** Batch plan approved (and, with two batches, the run-through choice recorded);
scaffold structurally complete, analyzer settings and (for AppSource) `AppSourceCop.json` in place per Ops § Analyzers
(not compiled — Operating Rule 4); pre-flight checklist ready.

## STEP 4 — Generate the Code

**Inputs:** `docs/DesignDoc.md`, `docs/ProjectParameters.md`, symbol file, batch plan, pre-flight checklist.

**Actions — per object, in order:**
1. **Approval came at Step 3** — don't ask again per object. With two batches, pause before the
   second only if the human chose that. Stop and ask on any pre-flight failure the Design Doc
   can't resolve, or any deviation from `docs/DesignDoc.md`.
2. Extract source-table and field data for this object from the symbol file.
3. Run the pre-generation pre-flight pass; fix the Design Doc before generating if anything fails.
4. Generate the AL file **from the standard template in Standards §1.3**, substituting only Step 1
   parameter values: one `namespace` (omitted entirely if `Use Namespace` = `No`), one `using`
   (from the symbol file), `ODataKeyFields = SystemId`, exactly one of `DelayedInsert = true` /
   `Editable = false`, `Caption` + `ToolTip` + `ApplicationArea = All` on every field. No dead
   code, no empty triggers, no commented-out fields, no `// TODO` (**Standards §1.1–§1.5**).
   Write `Caption` and `ToolTip` as self-describing schema for API consumers, not UI filler — they
   flow into OData `$metadata` and are what a developer or AI agent reads when discovering the
   endpoint (**Standards §2.5–§2.6**). Single-language label syntax only — never `CaptionML`,
   `ToolTipML`, any other ML property, or `TextConst` (**Standards §1.7**). Messages as `Label`s
   (**§8.3**), W1 source wording from the glossary, API caption locking per Step 2 (**§8.6**).
   **Source text only** — no translation file is touched until Step 5.
5. Run the post-generation pre-flight pass immediately on this file. **Do not invoke the AL
   compiler** (Operating Rule 4).
6. Don't move to the next object until this one's pre-flight, including symbol verification, is
   clean.
- **Before moving past this step, verify permission-set coverage explicitly** across every table
  generated (**Standards §5.3**; vacuously satisfied if the extension owns no tables).

**Outputs:** Every AL file, lint-clean including symbol verification; ChangeLog entries for any
deviation from `docs/DesignDoc.md`. The extension is **not** compiled yet.

**Exit gate:** Every planned object generated and pre-flight-clean; permission-set coverage
verified. A clean compile is not required to close this gate — Step 4 hands off directly into
Step 5's mandatory compile-and-package.

## STEP 5 — Compile, Package, Test & Iterate

**Inputs:** Every generated file (lint-clean, not yet compiled); accumulated lint findings;
`docs/DesignDoc.md`; `docs/ChangeLog.md`.

**Actions:** First, **compile the whole extension once, with the analyzers this framework
requires, then package it** (ALL ALONG → Analyzers; check for an already-provisioned runtime
before installing anything — Rule 6b). This is Rule 4's mandatory compile-and-package. Package
naming, location (`outputAppPackage/`), and the never-delete rule apply from this very first package
on (**read Ops § Packaging now**).

**After every compile with 0 errors, check what the human's editor shows** (ALL ALONG → Keeping
the Editor in Sync). Red marks the compiler didn't report, like an object ID outside the allowed
ranges, mean the editor's view is stale, not the code. Refresh the view; never change code that
compiles clean to clear them.

**From here it's a cycle, not a single event:**
1. Publish the current package to a BC sandbox tenant.
2. Test it — manually, by the human, unless the human took the agent-run API pass below, in which
   case the agent publishes and runs the checklist first and reports what it found.
3. For every error or problem, **first check `patterns/`** (ALL ALONG → OCPF BC AL Patterns
   Library) for a matching, already-documented pattern. If nothing matches, ask: is this a one-off
   or a pattern (search every generated file for the same class of issue)? Where did it come from
   — the generation rule, the Design Doc, or the source data? What rule should have caught it?
4. **Approve the round's fixes together, then apply them.** Once every problem from this test
   round has a diagnosis, present them all in one message — each listed separately with its root
   cause and proposed fix — and ask once (Rule 6a): **Apply all** / **Apply selected** / **Discuss
   first**. Nothing is applied before that answer. A diagnosis that would change a design rule in
   `docs/DesignDoc.md` gets its own separate box. Then fix each approved **root cause**, regenerate the
   affected files, and log the issue + resolution in `docs/ChangeLog.md` before moving on. Update
   `docs/DesignDoc.md` whenever a rule changes.
5. **Compile and package again**, redeploy, retest. Repeat until 0 errors / 0 warnings and the
   human confirms sandbox testing is clean.

**Translations run inside this cycle** (skip if *US wording, no translation files*). **The cycle is
Ops § Translations — read it at the first full build.** In short: every build syncs the target
files, verifies any new BC term, and runs the problem checks; drafting, the full checks, and
per-language testing wait until the source text is stable — the first build the human confirms clean
on the sandbox, again before this step closes, and again after any later fix that changes source
text.

**API test checklist** (used here, and again at Step 7 — endpoint URL shapes are in **Standards
Appendix A**):
- **Green-team (happy path):** `$metadata` returns the expected schema; read a collection; read a
  single record by `SystemId`; create a record on an editable endpoint; update a field; confirm a
  read-only endpoint rejects writes.
- **Red-team (boundary):** write to a read-only endpoint; send a non-existent field; send an
  invalid key; delete a record with dependencies; call with missing permissions — each should
  fail *gracefully with a clean, actionable error*.

**Ask once, at the first round: should the agent run the API checks before the human tests?**
(Rule 6a; record the answer in `docs/ChangeLog.md` and honor it for every later round.)
- ***Yes — publish and run the checks each round.*** The agent publishes and works the checklist
  above against the sandbox. **It needs two things**: one Microsoft browser sign-in per session, the
  same one publishing and sandbox symbol downloads use; and **a tool in this session that can issue
  OData requests against the sandbox with a bearer token**. **The AL MCP Server is not one** — it
  builds, publishes, and reads symbols, and has no tool that calls a published endpoint.
- ***No — I'll publish and test by hand (the realistic default).*** Don't ask again for this project.
  Nothing is lost: Step 7's human pass is authoritative either way. **Recommend this one unless the
  human says they have an API-capable connection.**

**Check for the route first and say what you found.** With no HTTP-capable tool in this session,
say so plainly, publish, and suggest Postman, Power Automate, or Copilot Studio instead. Endpoint
URL shapes, including the company segment most endpoints need, are **Standards Appendix A**. It's an early filter over the API pages only —
never the BC client — and Step 7's human pass still decides.

**Outputs:** All files compiling and packaging with **0 errors, 0 warnings**; at least one package
published and manually tested on a sandbox; `docs/ChangeLog.md` current; `docs/DesignDoc.md` updated for
every rule change.

**Exit gate:** Full extension compiles clean, with the analyzers and nothing suppressed (Ops § Analyzers); human confirms sandbox testing is clean; no known
systemic issue outstanding; no unit in a language required at first release is
`needs-translation` or `needs-adaptation`, and translation checks are clean.

---

# PHASE: PROVE

Goal: confirm the built code matches the Design Doc, is clean, is documented, and has passed a
human-run release test.

## STEP 6 — Review, Gap-Check & Finalize Docs

**Inputs:** The built extension, `docs/DesignDoc.md`, `docs/ChangeLog.md`.

**Actions:**
- **Gap-check** — compare `docs/DesignDoc.md` against the as-built code. For each divergence: object
  planned but not built (intentional or oversight?), object built but not planned (scope creep or
  gap-fill?), a rule implemented differently (is there a ChangeLog entry?). Classify each as
  **Intentional**, **Oversight** (fix now via the Step 5 cycle), or **Spec stale** (code's right —
  update `docs/DesignDoc.md`).
- **Code review** — one pass across every object: consistent structure/naming/formatting
  throughout (small projects still drift between the first file written and the last); no dead
  code (**Standards §1.5**); no reference to anything with `ObsoleteState = Pending`/`Removed`,
  unconditionally and with no version check (**Standards §3.2–§3.3**); both permission sets named
  with the App Code (**§5.4**). `Rec.`-prefix everywhere and every table's `tabledata` coverage are
  already proven by the last 0/0 compile — confirm it ran with the analyzers this framework
  requires (ALL ALONG → Analyzers) and nothing is suppressed, rather than re-deriving either check
  by hand. Correct `DelayedInsert`/`Editable` per data mutability (**§2.2**) still needs a human
  read; a compiler can't judge it. **Then run the full
  Anti-Patterns table — Standards Part 7 — against the codebase.** It's one table and it reads in
  a couple of minutes; it's the single highest-value thing the Standards Guide gives a Lite
  project, because most of what it catches is invisible until publish or until a consumer hits
  it. `TranslationFile` is on for every project (**§8.2**), so a 0/0 compile already proves the
  compiled codebase is free of `CaptionML`, `ToolTipML`, and the rest via `AL0424` — search anyway
  for anything added since that last compile, human-pasted included, so nothing new slips past
  before the next one. Read the code against
  AL Guidelines' *Best Practices* and *Vibe Coding Rules* for anything the Standards Guide doesn't
  already cover (the Standards Guide wins on any conflict — surface it rather than picking a side
  silently). **Translations:** run every technical translation check with all rules enabled, then
  review against **Standards Part 8** — no hard-coded user-facing strings, `Comment`s on
  placeholders, glossary terms used consistently, likely truncation in longer languages, and API
  caption locking re-verified against the Step 2 records. Then invoke the BCQuality snapshot's `skills/entry.md` dispatch flow (fetched at Step 3) as
  an additional, independent pass, and fold its findings in the same way as your own — never
  applied blind. If the fetch didn't happen or the snapshot is missing, say so rather than
  silently skipping this pass.
- **Update `docs/DesignDoc.md` in place** to reflect the as-built reality — final object inventory, any
  naming or exception that emerged during BUILD, a short deviation summary pointing at the
  relevant `docs/ChangeLog.md` entries. There's no separate as-built document in Lite; one file, kept
  current, is the point.
- Present this step's fixes together for one approval, as in Step 5. Any fix this step produces
  follows the Step 5 cycle (recompile, repackage, redeploy, retest) before this step closes; a
  comment/formatting-only fix doesn't need a fresh package.
- **Write `docs/Docs.md`** — one combined reference covering everything the full framework splits
  across four documents:
  - *API/dev reference*, generated from the actual code, not memory: one section per object, one
    row per field (identifier, source name, description, R/W status); a quick-start (auth, one
    request, one response); `$filter`/`$select` examples; create/update/delete examples; known
    limitations.
  - A Mermaid `erDiagram` of the schema, generated from the actual objects — every table the
    extension owns *and* every standard table it touches via `TableRelation`/`tableextension`.
    **Render it before shipping it** (e.g. `npx @mermaid-js/mermaid-cli`) — a syntactically
    invalid diagram looks fine in the source and only fails wherever it's finally viewed.
  - A short **user guide** section: what the feature is for, how to do each task, what to do when
    something is refused — written for the person clicking around in BC, not a developer.
  - A short **deployment** section: version requirements, install procedure, which permission sets
    map to which roles, uninstall, and which users to reassign if a release renames a permission set.
- **Write `docs/TestScript.md`** — the green-team/red-team checklist from Step 5, made concrete against
  this extension's actual endpoints, for a human tester to run end to end at Step 7. With more
  than one required language, add a **language pass**: key pages, messages, and customer-facing
  documents walked once per required language, checking for untranslated text, truncation,
  regional terms, and formats. Each case names the glossary terms the tester should see, so a
  tester who reads English can run it without a translated copy.
- **If the project has AL test codeunits, run them — don't leave it to the human.** The AL MCP
  Server's `al_run_tests` runs them against the sandbox, one codeunit per call (**Ops § Automated
  Tests**), never against production. A failing test fails this step like a compiler error. If the
  server isn't connected, say so and list the codeunit IDs rather than reporting untested code as
  tested.
- **Translated documents aren't produced here.** Step 7 produces them once its functional test
  pass is green, so a fix found in testing doesn't make every translated copy stale too.

**Outputs:** `docs/DesignDoc.md` (updated in place, glossary included), `docs/Docs.md`, and `docs/TestScript.md`.
Together with `docs/ChangeLog.md` from Step 1 onward, that's Lite's four maintained documents; translated
documents follow at Step 7. Step 1's `docs/ProblemStatement.md` and
`docs/ProjectParameters.md` are also tracked, but written once at kickoff rather than kept current.

**Exit gate:** Every gap classified and resolved or explicitly deferred (logged in
`docs/ChangeLog.md`); dead-code scan clean; no obsolete references; `docs/Docs.md`'s diagram renders;
`docs/TestScript.md` is executable by a non-developer; translation checks clean; any AL test codeunits
have been run and pass, or it's recorded why they couldn't be.

## STEP 7 — Release for Testing

> **The hand-off moment — mark it, don't slide into it.** The instant Step 6's outputs are done
> and this step is about to begin, the agent's own work in this routine is effectively finished:
> everything from here is a human running tests and deciding whether to ship. Send a formal
> message for this specific transition — this **replaces**, it does not add to, the ordinary Rule
> 6c step-completion check-in at the Step 6 → Step 7 boundary — through the interactive mechanism
> (Rule 6a), with exactly two named options plus the mechanism's own free-text/Other entry:
> **"Perfect, I understand!"** and **"I have some questions."** The message itself must: (a)
> congratulate the human on reaching this point; (b) state plainly that this is the logical end of
> the Lite framework's own work — Step 7 runs by human hands from here; (c) say concretely what
> they need to do next (run `docs/TestScript.md` end to end, record every finding in `docs/ChangeLog.md`);
> and (d) say how to bring the agent back in — when testing surfaces something to fix, when the
> functional pass is green and translated documents are due (if Step 1 asked for any), or once
> everything passes and it's time to mark the release candidate.
>
> Everything below this note is what happens *after* that hand-off — the human's test run, and
> the agent's part in recording and fixing what it turns up.

**Inputs:** The most recently built package; `docs/TestScript.md`; `docs/Docs.md`.

**Actions:**
- Confirm the latest package is published to a BC sandbox tenant — republish if anything changed.
- **If this isn't the first release, test the upgrade path first** (**Standards §9.6**): install the
  previous version on a clean sandbox with data in the fields this version changes, publish and
  install this one, verify the migrated data, install it again to confirm the upgrade tag makes the
  second run a no-op, and check that a fresh install doesn't run upgrade code at all. A failed
  upgrade path fails this step — by the time anyone notices, the tenant's data is already wrong.
- Real users/testers — not the agent, not a simulated pass — run `docs/TestScript.md` end to end: every
  green-team and red-team case, by hand.
- Verify permission sets as part of the same pass: read-only grants read everywhere; read/write
  includes it plus write on editable pages.
- **Translated documents, once the functional pass is green** (if Step 1 asked for them): the
  agent produces `docs/Docs.<culture>.md` (user-guide section) and, if chosen, `docs/TestScript.<culture>.md`.
  It uses the glossary for every BC term and names the English source version in each file's
  header. Each is reviewed by that language's reviewer before the language pass that uses it.
- **Language passes:** for each language required at first release, a tester fluent in it runs
  the language pass, with the right Microsoft or partner language app installed in the sandbox.
- **Translation approval — the release gate** (Ops § Translations; skip if *US wording, no translation files*):
  - Each language's named reviewer approves its translations — directly in their tooling, or by
    telling the agent exactly which units they approve. The agent sets `signed-off` only on those
    units.
  - Log each approval in `docs/ChangeLog.md`: reviewer by name, language, count, and date.
  - Then **scan every target file** for a language required at first release: every unit must be
    `signed-off` or `final` (**Standards §8.7**).
  - A fix that changes source text sends affected units back through Step 5 and review.
- Record every finding directly in `docs/ChangeLog.md` — verbatim first, then triaged: **implement now**
  (its own entry, fixed via the Step 5 cycle), **defer** (its own entry, marked deferred, with
  reasoning — Lite doesn't keep a separate `Roadmap.md`), or **reject** (record why).
- **If a fix here changes any object, field, or behavior, treat Step 6's outputs as stale, not
  already covered** — re-run the affected parts of the review and regenerate `docs/Docs.md`'s reference
  and diagram from the now-changed code, plus any translated document already produced from what
  changed. Say explicitly which parts a given fix actually requires re-running.
- Repeat until every green-team test passes and every red-team test fails gracefully.

**Outputs:** `docs/ChangeLog.md` updated with every test finding and its resolution.

**Exit gate:** All green-team tests pass; all red-team tests fail gracefully; the upgrade path
passes, or this is the first release (**Standards §9.6**); permission sets
verified; every translated document Step 1 asked for exists and has been reviewed; every required
language has passed its language pass and its state scan shows every unit `signed-off` or `final`
(Ops § Translations).
**If everything passes, the package that was actually tested is the one deployed to Production** —
bump its Build segment (e.g. `0.0.5.0` → `0.0.5.1`) or copy it to an immutable
filename first, so the shipped artifact stays permanently identifiable. This is marking the
release candidate, not building a new one — no recompile, no new testing required to do it.
**Before that deploy, restate the Schema Sync Mode assessment** (ALL ALONG → Packaging &
Versioning) — **Add** if this release is additive-only, **Force Sync** with an explicit data-loss
warning if anything was removed, shrunk, retyped, or re-keyed since the last production release.

---

# ALL ALONG — Continuous Discipline

Run these throughout, not as a final step.

**Each section below carries its non-negotiables and points at the Operations Guide for the
procedure.** Read the named **Ops §** section at the step that needs it.

## ChangeLog.md — the single running log

Lite merges what the full framework splits across a ChangeLog, a Testing Feedback Log, and a
Roadmap into **one file**. Every deviation from `docs/DesignDoc.md`, every diagnosed root cause, and
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
references its `docs/ChangeLog.md` entries.

## Packaging & Versioning

**Full procedure: Ops § Packaging.** Read it at Step 5's first package and before Step 7's release
bump. The non-negotiables:

- **Fixed name and location:** `<ExtensionName, spaces → underscores>_<version>.app` in
  **`outputAppPackage/`**, read from `app.json` at build time. Say the exact path every time a build
  completes.
- **Built packages are tracked, never gitignored** — no blanket `*.app` entry.
- **The agent never publishes to a production environment.** Before every publish, state the target
  environment and type; if it isn't a sandbox, stop and ask. Never force a destructive schema change
  (`ForceSync`, `Recreate`, `forceUpgrade`) without a separate approval naming what can be lost. The
  production deploy at Step 7 is the human's, through Extension Management (Ops § Packaging).
- **Never delete or overwrite a package from a different version.** Repeated builds at the same
  in-progress version legitimately overwrite that file; the protection is across versions.
- **The package that passes Step 7 ships** — bump its Build segment or copy it to an immutable name,
  and say which one passed.
- **Version bumps are proposed and approved**, never a silent `app.json` edit.
- **Flag Schema Sync Mode on every completed build:** **Add** for additive-only, **Force Sync** with
  a data-loss warning otherwise.

## OCPF AL Development Standards Guide

Two companions are fetched at Step 1 and kept for the life of the project: the **Standards Guide**
(`standardsGuide/ocpfALDevStandardsGuide.md`, v1.9.0.0), cited as **Standards §**, and the
**Operations Guide** (`opsGuide/ocpfOperationsGuide.md`, v1.3.0.0), cited as **Ops §** and shared
unchanged with the full framework.

**Full procedure: Ops § Fetched Companions** — fetching, refreshing, the plugin's offline copies,
and what to do when GitHub is unreachable.

- Both live inside the project root and are **always gitignored** — not covered by Step 1's
  framework-files question.
- **Neither is optional:** a missing copy is a real gap. Say so and ask the human for a copy rather
  than working from memory of a rule.
- **Version skew is named, not papered over.**

## Repository Hygiene

**Full procedure: Ops § Repository Hygiene.** Read it at Step 1 and Step 3.

**Always gitignored, not a per-project choice:** `.claude/settings.local.json`,
`.ocpf/notifications.json`, `standardsGuide/`, `opsGuide/`, `patterns/`, `scripts/`, `.alpackages/`,
`*.g.xlf`, and Microsoft's translation files. BCQuality lives outside the project root entirely.

**Always tracked:** `docs/DesignDoc.md`, `docs/ChangeLog.md`, `docs/Docs.md`, `docs/TestScript.md`, the Step 1 kickoff
artifacts, the AL source, `Translations/*.xlf`, and every package in `outputAppPackage/`.

**Gitignored by default, with Step 1's question — by exact filename, every one:** this runbook
under whatever name it was placed (`CLAUDE.md`, `.github/copilot-instructions.md`,
`.github/instructions/ocpf-framework.instructions.md`, `LITE_BC_App_Build_Routine_Agent.md`), its
changelog in either spelling (`LITE_[Rr]unbook[Cc]hange[Ll]og.md`), `LITE_RunbookSchematics.md`, and
the plugin's `.ocpf/` folder — except `.ocpf/notifications.json`, always ignored. Step 1's table has
the list; Ops § Repository Hygiene has the block to paste. **Verify with `git check-ignore -v`** on
each file that exists — that command, not a re-read of `.gitignore`, is what proves an entry works.
**Never the project's own `docs/ChangeLog.md`**, one of Lite's four maintained documents.

**`docs/` is where every document lives** — see the header note. At every exit gate, list the root:
a document sitting there is moved with `git mv`, and the move is noted in `docs/ChangeLog.md`.

**If a project built on an earlier Lite version has `docs/ChangeLog.md` in `.gitignore`,** remove that
entry and commit the file — earlier wording said "this runbook and `docs/ChangeLog.md`" when it meant the
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
- Outside Copilot Chat, run `scripts/al-analyze.*`. The AL MCP Server's `al_build` never applies
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
- **Record it in `.ocpf/notifications.json`** (per developer, always gitignored) and read it at the
  start of every session; ask again when it's missing.
- **Apply it** through each tool's own notifications and hooks — never a script-raised banner on
  macOS — and test it once.

## Reference Sources — Microsoft Learn and AL Guidelines

**The list: Ops § Reference Sources** — Microsoft Learn's Base Application and System Application
references, the translation-files and country/language pages, Microsoft's terminology collection and
style guides, and AL Guidelines. Consulted online; nothing is fetched.

- **Precedence:** downloaded symbols beat Microsoft Learn on anything symbol-verifiable; the
  Standards Guide beats AL Guidelines on any AL rule. Surface a conflict rather than picking a side
  silently.
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

- The human's own cross-project BC AL patterns, fetched once into `patterns/`, always gitignored,
  refreshed only on request, and merged rather than overwritten.
- **Using it:** before diagnosing a bug from scratch at Step 5 or 7, check whether `patterns/`
  already documents this class of problem.
- A fix likely to recur on future projects is a candidate for a new pattern — flag it, don't add it
  unilaterally.

## Translations & Terminology

**Full procedure: Ops § Translations** — the glossary, the cycle inside Step 5, review and approval,
and the release gate. Read it at Step 1, at Step 5's first full build, and at Step 7's gate. Skip
everything here if Step 1 chose *US wording, no translation files*.

- **The glossary lives in `docs/DesignDoc.md`** and is filled only by **Standards Appendix D**, never from
  model memory.
- **The agent drafts, a named person approves.** Every approval is logged in `docs/ChangeLog.md` by name
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

**Applies only when `.ocpf/framework.json` exists** — the plugin's `start` skill creates it. Without
that file, skip this section.

- **Once per session,** compare the project's runbook version against the latest published Lite
  runbook and offer **Update now / Not now / Skip this version**. Never replace the runbook without
  an explicit yes.
- **What the plugin adds:** offline copies of the runbooks and both companions, one-step AL tool
  setup, notification setup, and the `status`, `al-standards`, `notifications`, and `roles` skills
  (`roles` asks Lite's two model questions). (The `ocpf-light` and `ocpf-reasoning` sub-agents
  belong to the full framework's role split, which Lite doesn't use.)

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
editions fetch the same v1.9.0.0 file and apply the same AL rules — Lite differs only in process.

**Document count:** 4 maintained documents (`docs/DesignDoc.md`, `docs/ChangeLog.md`, `docs/Docs.md`,
`docs/TestScript.md`), plus Step 1's two kickoff artifacts (`docs/ProblemStatement.md`,
`docs/ProjectParameters.md`), versus the full framework's 20 (`ProblemStatement`, `ProjectParameters`, `FRD`, `TDD`,
`SanityCheck`, `ChangeLog`, `ProjectMemory`, `ProjectProgress`, `GapAnalysis`, `CodeReview`,
`PostDevTDD`, `Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`,
`AutomatedTestScripts`, `ReleaseTestResults`, `TestingFeedback`, `Roadmap`,
`TranslationGlossary`). Lite keeps its translation glossary inside `docs/DesignDoc.md`; translated copies
of `docs/Docs.md` and `docs/TestScript.md` don't count as separate documents.

---

*Lite Edition derived from the OCPF BC Agentic Development Framework, created by AJ Ansari,
Microsoft MVP, OnlyCopilotFans. Update this runbook when the full framework changes in a way that
should flow down to Lite.*
