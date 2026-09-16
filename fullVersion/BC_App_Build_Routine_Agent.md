# BC App Build Routine — Agent Runbook

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

**Version:** 3.1.0.0
**Last Updated:** September 15, 2026

> Version history for this framework lives in `RunbookChangelog.md`, tracked independently of any
> one project built with it — check there for what changed between the version you have and the
> latest. If `RunbookChangelog.md` is not found, create one.

> **What this is:** A single, ordered routine an AI agent follows to build a new Business Central AL Per-Tenant Extension (PTE) from a business problem through to a tested, documented app deployed to production.
>
> **How the agent uses it:** Work the phases in order (DEFINE → DESIGN → BUILD → PROVE). Do not start a step until its predecessor's exit gate is met. Every step lists its **Inputs**, **Actions**, **Outputs**, and **Exit gate**. The *Project Parameters* block in Step 01 is the single source of truth for every name, ID, version, and quoting decision — never hardcode any of those values in AL; always derive them from that block. It is persisted as `docs/ProjectParameters.md`, not just discussed — every later step reads it from that file. At the start of every session, read `.ocpf/notifications.json` and keep notifying the human the way it says; if it's missing, ask how they want to be notified (ALL ALONG → Notifications).
>
> **Companion documents, both fetched at PRE-01 and kept for the life of the project:**
> - `standardsGuide/ocpfALDevStandardsGuide.md` — the **OCPF AL Development Standards Guide**
>   (v1.8.0.0): the AL *rules* this sequence applies (Parts 1–8, Appendices A–D), cited below as
>   **Standards §**.
> - `opsGuide/ocpfOperationsGuide.md` — the **OCPF Operations Guide** (v1.1.0.0): the *procedures*
>   this sequence uses — asking, intake, project setup, the AL tools, analyzers, symbols, editor
>   sync, notifications, packaging, repository hygiene, translations, fetched companions, and the
>   plugin — cited below as **Ops §**. Both editions of the runbook share it unchanged.
>
> **Read an Ops § section at the step that names it**, in that step's Actions or its exit gate.
> Don't load the whole guide at once, and don't work from memory of a section you haven't opened in
> this project. This runbook drives the *sequence*; neither companion repeats it, and it doesn't
> repeat them: ALL ALONG's sections keep a few lines of non-negotiables and point at the guide.
> See ALL ALONG → OCPF AL Development Standards Guide for fetching, refreshing, and version skew.
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
    **Which mechanism each harness offers, and the option-count limits, are Ops § Asking and
    Approvals.**
6b. **Don't install tooling without asking — and look harder first.** Before concluding a required
    compiler or runtime is missing, check whether the human's own IDE already provisions one
    privately: VS Code's AL extension gets its .NET runtime from a companion extension, not a system
    install (**Ops § Asking and Approvals** has the per-OS paths). Installing anything is itself a
    human-in-the-loop decision, whatever a fallback elsewhere lists as available.
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
6d. **Zero-install first — never turn setup into the human's job.** Before proposing any install,
    or any manual setup for the human (editing `PATH`, a shell profile, or an environment variable),
    work through the ladder in **Ops § Asking and Approvals** and stop at the first option that
    works: what the editor already provides, then what's already installed, then — only then — an
    install asked for under Rule 6b.

    **Never hand the human a setup task the agent can do.** Connecting the AL tools, downloading
    symbols, keeping the editor's view current, and setting up notifications are the agent's job.
    The human's part is approving the AI tool's own prompts, and a browser sign-in when a tool
    reaches a live Business Central environment. **Never send the human to the Command Palette to
    set up the AL MCP Server** — the AL Language extension has no such command — and never route AL
    tooling through a third-party VS Code extension. The test: would a functional consultant with
    only VS Code and the AL extension have to do anything by hand? If yes, look again.
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
- **Fetch both companion guides into the project, before anything else needs them** — the
  Standards Guide into `standardsGuide/` and the Operations Guide into `opsGuide/`, from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/`, and add both folders to this project's
  `.gitignore`. Every phase from PRE-02 onward cites them (PRE-02's own gap-analysis checklist is
  Standards Part 6, and this step's notification and intake procedures are Ops §), so they have to
  be on disk from the first step. Say so plainly rather than fetching silently. **Full procedure,
  including the plugin's offline copies and what to do when GitHub is unreachable: ALL ALONG → OCPF
  AL Development Standards Guide.**
- **Ask how to be notified, right after the working language** (Ops § Notifications — read it now): Claude app, sound, desktop notification, any combination, or none. Record the answer in `.ocpf/notifications.json` and apply it now, so every question from here on — the approvers question included — reaches the human even when they've stepped away.
- **Ask who approves, next** (Rule 6a), because it decides how many sign-offs follow — starting
  with this step's own. *Who signs off on the design documents?* **One person for every role**
  (the Functional Consultant, Technical Lead, and Dev Manager sign-offs are all the same
  reader) / **Separate people for different roles**. Record it in `ProjectMemory.md`; Step 01 §1.1
  carries it into `docs/ProjectParameters.md` as **Approvers**. With one approver, sign-offs that
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
- Before anything else, create `ProjectProgress.md` (ALL ALONG → Project Progress Tracker), **in
  the project root — always, not `docs/`** — one row per step of the whole
  routine, every row blank except this one, marked `In Progress`. It's the first project document of
  the engagement (only the notification settings come before it).
- Write a problem statement: what business outcome is required, who the consumers are (users, other systems, AI tools, BI/reporting), which **countries and languages** the users work in (countries confirmed once in Step 01's first box, languages in §1.9), and what is explicitly out of scope.
- Capture the domain vocabulary the design will anchor to (entity names, categories, known pain points).
- Produce an initial entity/object list from stakeholder domain knowledge.
- As the agent: identify duplicates, ambiguous terms, and outdated/legacy terminology in the initial list; ask clarifying questions about scope and consumer use cases. Do not resolve ambiguities silently.

**Outputs:** `standardsGuide/` and `opsGuide/` (both fetched, gitignored), `requirements/` (seeded, if any raw input was provided), `ProjectProgress.md` (seeded, project root), `ProblemStatement.md` — purpose, scope, out-of-scope, target consumers, initial entity list, open questions.

**Exit gate:** Both companion guides are present, in `standardsGuide/` and `opsGuide/`, and gitignored. The notification choice is recorded in `.ocpf/notifications.json`, applied, and tested (ALL ALONG → Notifications). Functional Consultant signs off on the problem statement and initial entity list (Stage↔Step Map, Stage 1) — or, when **Approvers** is one person, this sign-off moves to the end of PRE-02 and is given together with that step's, on the problem statement and expanded list at once.

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

**Ask first, don't infer — and ask interactively** (Operating Rule 6a). **How to ask — the boxes,
what to offer for each question, and the language questions — is Ops § Intake. Read it before the
first box.** In short: every question goes through the options mechanism, grouped into as few boxes
as the questions allow; countries are asked once; a suggestion is a candidate the human picks, never
an answer recorded on their behalf; and the whole sheet is confirmed once at the end.

**Why the Permission Set App Code question exists:** permission sets named from the prefix alone
(`OCPF - READ`) collided across every extension built with that prefix (Standards §5.4).

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
> entries — so they're asked at intake, not part-way through DESIGN when the object inventory is
> already being drafted around their absence. Ops § Intake has the asking; the specifics of every
> *Yes* go in the sheet.

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Assisted Setup Wizard** | `<AssistedSetupYN>` | `Yes`/`No`. A guided setup page that configures number series, default values, sample data, or permission set assignment. If `Yes`, list exactly what it configures — not a bare yes. |
| **Activity Cues** | `<ActivityCuesYN>` | `Yes`/`No`. The numeric Role Center tiles summarizing counts that need attention. If `Yes`, list each cue: what it counts, its filter, and its drill-through target. |
| **Departments / My Business Central placement** | `<DepartmentsYN>` | `Yes`/`No`. The role-based menu and Tell Me search surface — a different discovery path than the Role Center. If `Yes`, name the department/category and which pages appear there. |

A `No` to any of these is a valid, final answer, not a placeholder to revisit later. Record the
answer and its reasoning; a `Yes` feeds the FRD's object inventory and the TDD's per-object spec
directly.

### 1.7 Model & Effort Assignment (Optional)

> Ask once, at intake, before DESIGN begins — Step 02/03 authorship depends on the answer. With no
> preference, everything runs through one model, as if this section didn't exist.

**Full procedure: Ops § Roles** — the three roles and what each is for, the preset question, the
per-role model and effort questions, High as the recommended default everywhere, and how to delegate
(including the plugin's `ocpf-light` and `ocpf-reasoning` sub-agents).

**The division of labor is fixed regardless of which models are assigned:** the light and reasoning
roles investigate, draft, or diagnose; the **main role is the only one that edits code** and the only
one that owns the continuity documents. A role holder's output is always relayed back and integrated
by the main role, never applied blind.

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Model/role assignment** | `<ModelRolesYN>` | `No` (default — one model for everything) or a 3-row table: Main / Light / Reasoning → the **model and thinking effort** (High recommended / Medium / N/A) recorded for each. |

### 1.8 Framework File Tracking (`.gitignore`)

Asked at intake, with `.gitignore` explained in the question itself (Ops § Intake, question 18).

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Framework files in `.gitignore`?** | `<FrameworkGitignoreYN>` | `Yes` (**default, recommended**) excludes this runbook, its changelog, and its schematics from this project's git tracking; the framework is distributed from its own repository and isn't part of what the client receives. `No` tracks them alongside the project's code, so a teammate cloning it sees how it was built. In a plugin project the same answer covers `.ocpf/`, except `.ocpf/notifications.json`. |

This choice covers only those files. `standardsGuide/`, `opsGuide/`, `patterns/`, `scripts/`, and
`.alpackages/` are always gitignored, and BCQuality lives outside the project — none of that is
asked (ALL ALONG → Repository Hygiene).

### 1.9 Languages & Translation

> The questions, their order, and what to offer are **Ops § Intake**; the rules each answer applies
> are **Standards Part 8**; what happens to translations during BUILD and PROVE is ALL ALONG →
> Translations & Terminology. Asked in the working language (Operating Rule 8).

**Microsoft's live *Country/Regional Availability and Supported Languages* page is the only source**
for which countries BC serves and which languages it supports there. Read it every time; never
answer from memory or a copy.

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Working language** | `<WorkingLanguage>` | From PRE-01. |
| **Target languages** | table | One row per language: culture code · three-letter ID · country · support case (Microsoft / partner / not supported by BC) · required at first release (Yes/No) · reviewer (name) · terminology source (Microsoft, or the named partner app). |
| **Source language** | `<SourceLanguage>` | `en-US` unless the human chose otherwise, with the consequences noted (Standards §8.1). |
| **Source wording** | `<SourceWording>` | `W1` (with a translation file per target, `en-US` included) or `US, no translation files` (only when `en-US` is the sole target and the Deployment Target isn't AppSource). |
| **Document languages** | table | Document → languages. Produced at Step 12, once the functional test pass is green. |
| **Customer-language documents** | `<CustomerLanguageDocsYN>` | `Yes`/`No`, with which documents if `Yes` (Standards §8.9). |
| **Translatable data** | `<TranslatableDataYN>` | `Yes`/`No`, with which tables/fields if `Yes` (Standards §8.9). |
| **Translation tooling** | `<TranslationTooling>` | Decided at Step 05. |

*API page and query caption locking isn't asked here — no objects exist yet. It's decided at Step
03, once the object inventory does.*

### 1.10 AL Project File, AL Tools & Symbols (the agent's job, before DESIGN)

> Operating Rule 2 verifies every design decision against downloaded symbols, so symbols have to be
> on disk before Step 02, not first appear at Step 07. Nothing here needs the human beyond the AI
> tool's own approval prompts (Operating Rule 6d).

**Full procedure: Ops § Project Setup.** Once the human confirms the sheet, and before Step 02:

1. **Write `app.json` once, complete,** from the confirmed sheet, keeping an existing `id` GUID.
2. **Connect the AL tools** if this session doesn't have them (ALL ALONG → AL MCP Server).
3. **Download symbols** and record §1.4's **Symbol Source**; add `.alpackages/` to `.gitignore`
   (ALL ALONG → Symbols).
4. **Keep the editor in sync** (ALL ALONG → Keeping the Editor in Sync).

**Outputs:** `docs/ProjectParameters.md` — the completed Project Parameters block (above, all placeholders replaced), persisted as its own tracked document so every later step, and every role under §1.7, reads it from disk rather than depending on conversation history; an empty **Object Register** artifact seeded with the allocated ID ranges; the project's `.gitignore` populated per this section and per ALL ALONG → Repository Hygiene; **`docs/TranslationGlossary.md`**, created with the regional terms PRE-02 listed (ALL ALONG → Translations & Terminology) — unless the project chose *US wording, no translation files*; `app.json` and `.alpackages/` per §1.10.

**Exit gate:** Every question in this step was asked through the options mechanism (Ops § Intake). `app.json` matches the sheet, and symbols for the target version are in `.alpackages/` (§1.10, Ops § Project Setup). No placeholder remains. **Approvers** is recorded (asked at PRE-01). Deployment Target is one allowed value. Namespace matches between 1.1 and 1.3, or both are correctly N/A if Use Namespace = `No`. Localization is set. If Permission Sets required = `Yes`, ≥ 2 IDs are reserved in the primary range. §1.6's three questions are each answered `Yes`/`No` with specifics recorded for any `Yes`. §1.7 is answered or explicitly skipped — if configured, every one of the three roles has both a model and a thinking effort (or `N/A`) recorded, not model alone. §1.8 is answered (or defaults to `Yes`) and `.gitignore` reflects it. §1.9: every target language is classified against Microsoft's live page and — unless source wording is *US wording, no translation files* — has a required-at-release answer and a named reviewer; source language and wording are recorded; any mismatch with `Localization` is resolved. Human confirms the sheet.

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
- Prepare the scaffold: confirm `app.json` still matches `docs/ProjectParameters.md` (written at §1.10: name, publisher, ID ranges, runtime, BC dependency, `"features": ["NoImplicitWith", "TranslationFile"]` — `TranslationFile` on every project, Standards §8.2), `launch.json`, folder structure per module, a `Translations/` folder, `.gitignore` populated per §1.8 and ALL ALONG → Repository Hygiene (including `*.g.xlf` and `.alpackages/`), and the analyzer files: `.vscode/settings.json` with the analyzers for Parameter 1.1 Deployment Target, plus `AppSourceCop.json` if it's AppSource (**read Ops § Analyzers now**). Confirm the compile script (`scripts/al-analyze.*`) is present unless this is GitHub Copilot Chat in VS Code, and copy or fetch it if not. If `app.json` has to change here, follow ALL ALONG → Keeping the Editor in Sync.
- **Agree the translation tooling** (Rule 6a; skip if Parameter §1.9 chose *US wording, no translation files*). Recommend the **XLIFF Sync** PowerShell module (`XliffSync`) as the agent's headless sync and checks, with the **XLIFF Sync** VS Code extension for reviewers. Offer **NAB AL Tools** as the alternative for developers who already use it. Before installing PowerShell, the module, or any extension, look for an existing installation first and ask (Operating Rules 6, 6b). Record the choice in Parameter §1.9. Whatever the tooling, the release gate (ALL ALONG → Translations & Terminology) is the same state scan.
- Bootstrap the BCQuality knowledge snapshot and the OnlyCopilotFans (OCPF) BC AL Patterns (**Ops § Fetched Companions**)
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

**Exit gate:** Batch order and the run-through choice agreed with the human; scaffold is structurally complete (`app.json` fields populated, dependencies declared, folders created, analyzer settings and — for AppSource — `AppSourceCop.json` in place per Ops § Analyzers — not compiled, per Operating Rule 4); pre-flight checks ready.

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

**Actions:** First, **compile the whole extension once, with the analyzers this framework requires, then package it** (Operating Rule 4; Ops § Analyzers — check for an already-provisioned runtime before installing anything, Operating Rule 6b). This is Operating Rule 4's mandatory compile-and-package. Package naming, location (`outputAppPackage/`), the never-delete rule, and Schema Sync Mode/Force Sync guidance all apply from this very first package onward (**read Ops § Packaging now**) — there is no "not a real package yet" grace period.

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
chose *US wording, no translation files*). **The cycle itself is Ops § Translations — read it at the
first full build.** In short: every build syncs the target files, verifies any new BC term, and runs
the problem checks; drafting, the full checks, and per-language testing wait until the source text is
stable — the first build the human confirms clean on the sandbox, again before this step closes, and
again after any later fix that changes source text. Reviewers work in parallel; approval is required
only at Step 12.

**The API test checklist** — defined once, here, and used three times over the rest of the routine: optionally by the agent at the end of this step (below), as the source Step 11 writes `HumanUnitTestScript.md` from, and authoritatively by humans at Step 12 (Release to Users for Testing):
- **Green-team (happy path):** `$metadata` returns the expected schema; read a collection; read a single record by `SystemId`; create a record on an editable endpoint; update a field; confirm a read-only endpoint rejects writes. Endpoint URL shapes are in Standards Appendix A.
- **Red-team (boundary):** write to a read-only endpoint; send a non-existent field; send an invalid key; delete a record with dependencies; call with missing permissions — confirm each fails *gracefully with a clean, actionable error*.

**Optional, once things are stable: agent-run API testing via a live MCP connection.** Offer the human an automated pass over the app's own API pages, using the checklist above, run directly by the agent against the published sandbox — but only if, and because, the human can supply a working connection (e.g., the AL MCP Server actually connected per ALL ALONG → AL MCP Server, or another authenticated MCP endpoint that reaches the sandbox's API). This is optional and conditional, never assumed to be available:
- **If no working connection is available, say so plainly and suggest a manual alternative instead of leaving it undone** — testing the API by hand via **Postman**, or through a low-code caller like **Power Automate**, **Power Apps**, or **Copilot Studio**.
- This is a cheap, early pass, not a substitute for the authoritative one: the same checklist runs again at Step 12, by a human, after Code Review and documentation have had their say — whether or not this optional agent-run pass ever happened.

**Outputs:** All batches compiling and packaging with **0 errors, 0 warnings**; at least one package published and manually tested on a sandbox; ChangeLog current; TDD updated for every rule change; an agent-run API test result, if a live MCP connection was available and the human opted in; every target translation file synced, drafted, and passing technical checks, with the glossary current.

**Exit gate:** Full extension compiles clean, with the analyzers and nothing suppressed (Ops § Analyzers); the human confirms sandbox testing is clean; no known systemic issue outstanding; ChangeLog and TDD reconciled (Operating Rule 5); no translation unit in any language required at first release is in `needs-translation` or `needs-adaptation`, and the technical translation checks are clean.

---

# PHASE: PROVE

Goal: prove the built code matches intent, is clean, is fully documented, and has passed a human-run release test — packaging and sandbox testing are already underway by this point (Step 07) and continue throughout, not a separate milestone reserved for PROVE.

## 08 — Gap-Fit Test, Fidelity Validation

**Role:** if §1.7 role assignment is configured, this three-way comparison is done by the
**reasoning role**; the main role records the resulting classification (Intentional / Oversight /
Spec stale) in `GapAnalysis.md`.

**Inputs:** `FRD.md`, `TDD.md`, the built AL, ChangeLog.

**Actions:** Run a formal three-way comparison — FRD vs. TDD vs. as-built. Answer: does the written code follow the TDD and the FRD? What changed? Why? For each gap:
- Object in the FRD but not built — intentional or oversight?
- Object built but not in the FRD — scope creep or gap fill?
- Rule in the FRD the TDD did not implement — TDD gap.
- Rule implemented differently from the TDD — is there a ChangeLog entry?
- Implementation decision that contradicts the FRD — FRD update needed.
- **Languages** — a language the FRD requires at first release without a complete, synced translation file, or a translation file for a language no longer in scope. (API caption locking is re-verified once, at Step 09 — don't repeat it here.)

Classify every gap as **Intentional** (record the reasoning), **Oversight** (fix now or schedule), or **Spec stale** (the code is right, so the FRD/TDD needs updating). **Record every classification in `GapAnalysis.md` and edit no design document here** — Step 10 rewrites the TDD as `PostDevTDD.md` and re-baselines the FRD once, from this file, so the same edit isn't made twice.

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
- **Apply every *Spec stale* classification `GapAnalysis.md` recorded at Step 08** — this is where
  those document edits happen, once, rather than twice.
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
- **Ask the human whether they also want Automated Test Scripts created**, alongside — not instead
  of — the Human Unit Test Script. **How to ask, and the two genuinely different things "automated
  tests" can mean, is Ops § Automated Tests — read it before asking.** It's a genuine question:
  automated scripts carry an ongoing maintenance commitment a one-time manual script doesn't. If any
  are created, they go in `AutomatedTestScripts.md`, a separate document from
  `HumanUnitTestScript.md`.
- Write the **user guide** as `UserGuide.md` — **Markdown, in the repo, always** (HTML with `@media print` rules only as an *additional* branded/print deliverable, never instead of the Markdown). This is a **separate document from `Documentation.md`** and must not be folded into it: `Documentation.md` is the integration/API reference written for a developer or BI consumer, whereas the user guide is written for the person clicking around in Business Central — what the feature is for, how to do each task in order, what each field means in business terms, and what to do when something is refused. If the only "user guide" produced is an API reference, this action has not been done.
- Write one-page **deployment instructions** as `Deployment.md`, for an administrator: version requirements, install procedure, which permission sets map to which roles, verification steps, uninstall. If this release renames any permission set (for example, moving an older extension to Standards §5.4 names), list which users must be reassigned after the upgrade. Distinct from `Documentation.md`'s quick-start: this is the full admin install/upgrade/uninstall procedure, not a fast path to a first API call. If Parameter §1.9 has more than one language, include which Microsoft language apps (or partner language apps) an administrator must install for each language, and that the Allowed Languages list should include them.
- **AppSource listing text** — only if §1.1 Deployment Target = `AppSource` (Standards §8.10). Draft, in English, the offer description's closing *Supported Countries/Regions* paragraph (the countries from Parameter §1.9) and *Supported Languages* paragraph (only languages whose translation files ship with every unit approved at Step 12). Write both into `Deployment.md`, and state plainly that the markets selected in Partner Center must match the countries paragraph. Every listed country needs its own test at Step 12.
- **Languages in the test script.** When there's more than one required language, `HumanUnitTestScript.md` gains a **language pass**: the key pages, messages, errors, and customer-facing documents walked once per required language. Each pass records the tester's name and a pass/fail per case, with checks for untranslated text, truncation, regional terminology, and regional formats. Each case names the glossary terms the tester should see in their language, so a tester who reads English can run the pass from this script without a translated copy.
- **Translated documents aren't produced here.** Step 12 produces them once its functional test pass is green, so a fix found in testing doesn't make every translated copy stale along with the English one.

**Outputs:** `Documentation.md` (consumer/API reference, includes the Mermaid schema diagram), `HumanUnitTestScript.md`, **`UserGuide.md`** (end-user, Markdown), `Deployment.md`, and `AutomatedTestScripts.md` (only if the human opted in above). Four mandatory documents — check all four exist before claiming the step is complete; the fifth is conditional.

**Exit gate:** Reference is generated from actual code and current; test script executable by a non-developer; the human has been asked about Automated Test Scripts (Ops § Automated Tests; answer recorded either way); app ready to hand to Step 12 for release testing.

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

**Exit gate:** The Dev Manager has reviewed `PostDevTDD.md`, the FRD baseline, and Step 11's documents (recorded in `ReleaseTestResults.md`); all green-team tests pass; all red-team tests fail gracefully; permission sets verified; every translated document §1.9 requires exists and has been reviewed; every language required at first release has passed its language pass and its state scan shows every unit `signed-off` or `final` (Ops § Translations). **If everything passes, the package that was actually tested is the one deployed to the Production company** — bump its Build segment (e.g. `0.0.5.0` → `0.0.5.1`) or copy it to an immutable filename first (ALL ALONG → Packaging & Versioning) so the shipped artifact stays permanently identifiable and is never itself overwritten by a later cycle build; this is marking the release candidate, not building a new one — no code is recompiled and no new testing is required to do it. **Before that deploy, restate the Schema Sync Mode assessment for this exact package** (ALL ALONG → Packaging & Versioning) — **Add** if this release is additive-only, **Force Sync** with an explicit data-loss warning if anything was removed, shrunk, retyped, or re-keyed since the last production release.

---

# ALL ALONG — Continuous Discipline (every phase, every step)

Run these in parallel with the phased work — they are not a final step.

**Each section below carries its non-negotiables and points at the Operations Guide for the
procedure.** Read the named **Ops §** section at the step that needs it.

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
- **Link it one way:** each ChangeLog Issue or `Roadmap.md` item names the `TestingFeedback.md`
  entry it came from. The raw ask stays traceable to its decision without writing the same finding
  three times with back-links in both directions; a search finds the reverse.
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

- **Keep it short — an anchor, not a narrative.** Where each live document lives, any decision
  awaiting sign-off, and a one-line pointer per past milestone. **It doesn't carry the current
  step:** `ProjectProgress.md` owns that, and this file points at it, so there's no second copy to
  keep in sync. The full
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
- **This file is the only record of which step is current.** Update it when a step starts and when
  its exit gate is met. `ProjectMemory.md` points here rather than repeating it.
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

**Full procedure: Ops § Translations** — the glossary, the translation cycle inside Step 07, review
and approval, and the release gate. Read it at Step 01 §1.9, at Step 07's first full build, and at
Step 12's gate. Everything here is skipped for a project whose §1.9 chose *US wording, no
translation files*, except Operating Rule 8 and Standards §1.7.

- **The glossary is `docs/TranslationGlossary.md`**, created at Step 01 and filled only by Standards
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

**Full procedure: Ops § Packaging.** Read it at Step 07's first package, and again before the Step
12 release bump. The non-negotiables:

- **Name and location are fixed:** `<ExtensionName, spaces → underscores>_<version>.app` in
  **`outputAppPackage/`** in the project root, with `name` and `version` read from `app.json` at
  build time. Say the folder once at intake, and the exact path every time a build completes.
- **Built packages are git-tracked, never gitignored.** No `outputAppPackage/` or blanket `*.app`
  entry in `.gitignore`.
- **Never delete or overwrite a package from a different version. NEVER.** No `rm`, no tidying, not
  even before a build. Repeated builds at the same in-progress version legitimately overwrite that
  version's file; the protection is across versions.
- **The package that passes Step 12 is the one that ships** — bump its Build segment or copy it to
  an immutable name, and say explicitly which package passed.
- **Version bumps are proposed and approved, never a silent `app.json` edit.** Major / Minor / Build
  / Revision, with the reasoning stated. Push back on a bump that doesn't match what changed.
- **Flag Schema Sync Mode on every completed build:** **Add** for additive-only, **Force Sync** with
  an explicit data-loss warning when anything was removed, shrunk, retyped, or re-keyed.

## Repository Hygiene — What Stays Out of the Project's Remote

**Full procedure: Ops § Repository Hygiene.** Read it at §1.8, at §1.10, and at Step 05's scaffold.

**Always kept out of git tracking, not a per-project choice:** `.claude/settings.local.json` and
`.ocpf/notifications.json` (each developer's own), `standardsGuide/`, `opsGuide/`, `patterns/`,
`scripts/`, `.alpackages/`, `*.g.xlf`, and Microsoft's translation files. The BCQuality snapshot
lives outside the project root entirely, so there's nothing to ignore.

**Always tracked:** the project's own documents, its AL source, `Translations/*.xlf`, and every
package in `outputAppPackage/`.

**Gitignored by default, with the §1.8 intake question:** this runbook, its changelog, its
schematics, and the plugin's `.ocpf/` folder — except `.ocpf/notifications.json`, always ignored.

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
- `.vscode/settings.json` (and `AppSourceCop.json` for AppSource) is created at Step 05's scaffold.
- Outside GitHub Copilot Chat, run `scripts/al-analyze.*`: the AL MCP Server's own
  `al_build`/`al_compile` don't apply analyzers.
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
- **Record the answer in `.ocpf/notifications.json`** — per developer, always gitignored — and read
  it at the start of every session. Ask again when it's missing.
- **Apply it** through each tool's own notifications and hooks, never a script-raised banner on
  macOS. With *Claude app*, explain Remote Control and what it stores before turning it on, and end
  every turn that hands the ball back with a short push.
- **Test once**, and fix or drop whatever didn't arrive.

## OCPF AL Development Standards Guide

The companion rules document — `ocpfALDevStandardsGuide.md`, v1.8.0.0 — holds the AL rules this
runbook cites as **Standards §**, from PRE-02 onward. Its sibling, the **Operations Guide**
(`ocpfOperationsGuide.md`, v1.0.0.0), holds the procedures, cited as **Ops §**.

**Fetch both at PRE-01, before anything else needs them** — `standardsGuide/` and `opsGuide/` in
this project's root, both always gitignored. **Full procedure: Ops § Fetched Companions**, which
also covers refreshes, the plugin's offline copies, and what to do when GitHub is unreachable.

**Neither is optional.** A missing copy is a real gap, not a degraded-but-workable state: say so
and ask the human for a copy rather than working from memory of what a rule says. **Version skew is
named, not papered over** — both carry their own version, tracked in `RunbookChangelog.md`.

## Reference Sources — Microsoft Learn and AL Guidelines

**The list, with what each is for: Ops § Reference Sources.** Microsoft Learn's Base Application
and System Application references, the translation-files and country/language pages, Microsoft's
terminology collection and style guides, and AL Guidelines. None are fetched; all are consulted
online.

- **Precedence:** downloaded symbols beat Microsoft Learn on anything symbol-verifiable; the
  Standards Guide beats AL Guidelines on any AL rule. Surface a conflict rather than reconciling it
  silently.
- **If the agent has no web access, say so** rather than answering from memory of a reference.

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
  fetched once into `patterns/` inside the project root, always gitignored, refreshed only on
  request, and merged rather than overwritten.
- **Using it:** before diagnosing a bug from scratch at Step 07, or a testing-feedback report during
  PROVE, check whether `patterns/` already documents this class of problem.
- A fix that looks likely to recur on future projects is a candidate for a new pattern — flag it to
  the human rather than adding one unilaterally.

## OCPF Plugin (Optional)

**Full procedure: Ops § Plugin.** Read it at the start of a session in a plugin-installed project.

**This section applies only when `.ocpf/framework.json` exists in the project root** — the plugin's
`start` skill creates it. Without that file, skip it entirely.

- **Once per session,** compare the project's `runbookVersion` against the latest published runbook
  and offer **Update now / Not now / Skip this version**. Never replace the project's runbook
  without an explicit yes.
- **What the plugin adds:** offline copies of the runbooks and both companions, one-step AL tool
  setup, notification setup, the `ocpf-light` and `ocpf-reasoning` sub-agents for §1.7, and the
  `status`, `al-standards`, and `notifications` skills.
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
| 10 — Deployment | 12 (sandbox, human-run release test) → production deploy of that same package, per `Deployment.md` |

---

*Routine created by AJ Ansari, Microsoft MVP, OnlyCopilotFans. Update this runbook when the framework or the standards change.*

