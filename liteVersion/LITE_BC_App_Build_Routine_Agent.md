# BC App Build Routine — Lite Agent Runbook

## OnlyCopilotFans Agentic Dev Framework — Lite Edition

**Version:** 1.3.0.0 (Lite, derived from the full framework v2.6.0.0)
**Last Updated:** September 14, 2026

> Version history for this edition lives in `LITE_RunbookChangeLog.md`, tracked independently of
> the full framework's own `RunbookChangelog.md` (though a change to one often has to be reflected
> in the other) and of any one project built with it. Diagrams for this routine live in
> `LITE_RunbookSchematics.md`. If either file is not found, create it.

> This is the lightweight sibling of the full **OCPF BC Agentic Development Framework**
> (`BC_App_Build_Routine_Agent.md`, in the same repo). Same author, same underlying discipline —
> half the steps, one model doing all the work, and no ceremony that a 10-files-or-fewer project
> doesn't need.

> **Companion document:** `standardsGuide/ocpfALDevStandardsGuide.md` — the **OCPF AL Development
> Standards Guide** (v1.1.0.0), shared unchanged with the full framework. Lite is *not* a reduced
> set of AL rules: the same AL rules apply to a 5-file extension as to a 50-file one. What Lite
> reduces is *process*. So this runbook states each rule in short form where you need it and cites
> the guide as **Standards §** for the full version — the abbreviation tables, the complete
> anti-pattern list, the field-exclusion rules, the endpoint patterns. Fetch it at Step 1 (see
> ALL ALONG → OCPF AL Development Standards Guide) and keep it open for the life of the project.

> **When to use Lite:** a Business Central AL Per-Tenant Extension with **10 or fewer AL files**
> — typically a handful of API pages over standard tables, maybe one or two new tables, a single
> developer or functional consultant driving it, one AI model doing the work. **Graduate to the
> full framework** the moment any of these stops being true: the object count grows past ~10, the
> project needs multiple sign-off roles (Dev Manager, Technical Lead, Functional Consultant as
> separate people), you want to split work across more than one AI model, or the extension is
> heading to AppSource (which tends to demand the fuller documentation trail). Nothing is lost by
> switching later — Lite's Design Doc and ChangeLog map directly onto the full framework's TDD and
> ChangeLog.

> **What this is:** a single, ordered routine an AI agent follows to build a small BC AL PTE from
> a business problem through to a tested, documented app ready for release — in **7 steps**
> instead of the full framework's 14.
>
> **How the agent uses it:** work the phases in order (DEFINE → DESIGN → BUILD → PROVE). Don't
> start a step until its predecessor's exit gate is met. The *Project Parameters* block in Step 1
> is the single source of truth for every name, ID, version, and quoting decision — never hardcode
> any of those values in AL; always derive them from that block. It is persisted as
> `ProjectParameters.md` in the project root, not just discussed — every later step reads it from
> that file.
>
> **One model does everything.** Lite drops the full framework's optional Main/Light/Reasoning
> role split. There's no delegation mechanism to configure — the executing agent plans, generates,
> reviews, and documents, in that order, within each step.
>
> **Prime directive:** an ambiguous input produces ambiguous code. If a step's inputs are
> incomplete or contradictory, stop and ask the human — do not invent rules to fill the gap.

### Setup

Same as the full framework: drop this file into the project root and rename it so your tool picks
it up automatically — `CLAUDE.md` for the Claude Code plugin in VS Code, or
`.github/copilot-instructions.md` for GitHub Copilot Chat. Keep this file itself as your master
copy elsewhere if you maintain more than one project.

You don't need to copy the Standards Guide by hand — Step 1 fetches it from the framework
repository into `standardsGuide/` and gitignores it there.

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
   knowledge of BC table numbers is not reliable. **Fallback** when the downloaded symbols don't
   answer the question (a module isn't in `.alpackages`, or you need to browse rather than already
   knowing what to grep for): the BC BaseApp is documented in full at
   <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application>,
   and the System Application (Language, Translation, Email, Telemetry, and its other foundation
   modules) at
   <https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application>.
   Use them to corroborate or discover; the downloaded symbol file for the target version is still
   authoritative when the two disagree. The step-by-step verification procedure is Standards
   Appendix B.
3. **Treat the whole extension as one batch — two only if there's a natural split** (e.g., "setup
   + master data" vs. "documents"). At 10 files or fewer there is rarely a reason for the full
   framework's multi-batch phasing. Order objects within the batch so lookup/reference tables
   precede the entities that reference them.
4. **Lint everything as it's written, including symbol verification. Do not compile until
   generation is finished.** Run the Step 3 pre-flight checklist on every object as it's
   generated — both passes, pre-generation (planned names/fields) and post-generation (the actual
   file). Symbol verification means: for every reference to a standard/base object, field, method,
   property, or enum value, verify it against the downloaded symbol source (falling back to the
   MS Learn BaseApp docs above when the downloaded symbols don't answer) — not just because it
   looks like plausible AL. That's the one check that verifies against ground truth instead of a
   plausible-looking guess. The one mandatory compile-and-package happens in Step 5, the moment
   Step 4 finishes — not deferred, not skipped. From that point, compiling and packaging is the
   continuous rhythm of Step 5 and Step 6's fix loop: compile, package, deploy to a sandbox, test,
   diagnose, fix, then compile and package again. Whenever a compile runs, treat any error as a
   systemic signal — fix the rule, then every file it touched, not only the one where the error
   surfaced.
5. **Zero errors, zero warnings before PROVE.** Treat warnings as errors. Satisfied by
   construction under Rule 4: the mandatory compile-and-package in Step 5 always runs, and must
   reach 0/0, before Step 6 begins.
6. **Human-in-the-loop is a feature.** Pause for human approval before: writing the first file,
   applying a root-cause fix, finalizing the Design Doc, and installing any tool or runtime.
   6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human
       to *decide* something — pick a design option, approve a version bump, resolve an ambiguity —
       present it through the interactive multiple-choice mechanism the agent's harness provides
       (e.g., Claude Code's `AskUserQuestion`), recommended option first with a short reason. Don't
       wrap ordinary progress (finishing a step, reporting a clean compile) in this — that's just
       noise.
   6b. **Don't install tooling without asking — and look harder first.** Before concluding a
       required compiler/runtime is missing, check whether the human's own IDE already provisions
       one privately (e.g., VS Code's AL extension gets its .NET runtime from a companion
       extension, not a system install). Installing anything is itself a human-in-the-loop
       decision regardless of what a fallback elsewhere in this runbook lists as available.
   6c. **From Step 5 onward, check in after every step closes — proceed now, or pause?** Once a
       step's outputs are written and its exit gate is met, put the choice itself through the
       selectable-options mechanism (Rule 6a): proceed directly into the next step, or stop here
       so the human has room to review, run, or publish what was just produced. State how to
       resume. Steps 1–4 are unaffected — ordinary conversational hand-off governs there.
       **The Step 6 → Step 7 boundary is a special case of this rule, not an addition to it** —
       see Step 7's own hand-off note, which replaces this generic check-in for that one
       transition. Don't do both.
7. **Log every deviation immediately.** Any departure from the Design Doc — human or agent — goes
   in `ChangeLog.md` before the next batch starts.

---

# PHASE: DEFINE

Goal: turn a business need into a validated scope and a filled-in parameter sheet — before any
design work.

## STEP 1 — Define the Problem & Lock Parameters

**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**
- **Fetch the OCPF AL Development Standards Guide first, before anything else needs it.** Get
  `standardsGuide/ocpfALDevStandardsGuide.md` from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/` into a `standardsGuide/` folder in this
  project's root, and **add `standardsGuide/` to `.gitignore`** — see ALL ALONG → OCPF AL
  Development Standards Guide. The gap check below already leans on Standards Part 6, so this
  can't wait for Step 3 the way the other fetched libraries do. Tell the human you're doing it.
- **Capture any raw requirements input verbatim, before interpreting it.** If the human pastes raw
  requirements in chat, or uploads a file, save it untouched in a `requirements/` folder (a
  descriptive filename, or the file's own name for an upload) before doing anything else with it.
  Never commit this folder to `.gitignore`. Re-apply this the moment any later requirements or
  change-request input arrives, not only at kickoff.
- Write a short problem statement: what business outcome is required, who the consumers are
  (users, other systems, AI tools, BI/reporting), and what's explicitly out of scope. Capture the
  domain vocabulary the design will anchor to.
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
- **Populate the Project Parameters block below, and persist it as `ProjectParameters.md` in the
  project root.** Complete every field; replace every placeholder. These values override all
  defaults for the rest of the routine, and every later step reads them from that file rather than
  from conversation history.

**Ask first, don't infer** — as five explicit questions, before writing anything, if any of these
still carry placeholder values:

1. What is the Extension Name?
2. Who is the Publisher?
3. Should this project use an AL namespace? If yes, what should it be (e.g.
   `<Publisher>.<ExtensionShort>`)?
4. What Localization applies (`W1`, `US`, …)?
5. What AL object prefix should be used?

Do not infer these from context under time pressure (an email domain, a guess at house style) —
a wrong guess here means renaming the whole project later.

**Then collect the Object ID range(s) as a loop**, since there can be more than one:
1. Ask for the starting Object ID, then the ending Object ID.
2. Show the resulting range and its size (e.g. "80300–80339 — 40 IDs") and confirm it.
3. Ask "Are there additional ranges?" If yes, repeat; if no, stop.

The first confirmed range is the Primary allocation; any after it are Additional.

**Tell the human where their built packages will land:** always `outputAppPackage/` in the
project root — never `out/`, `output/`, or anything ad hoc (see ALL ALONG → Packaging &
Versioning). Mention this once, plainly, now.

### Project Parameters

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Extension Name** | `<ExtensionName>` | No AL quotes. → `app.json "name"`. |
| **Publisher** | `<Publisher>` | No AL quotes. → `app.json "publisher"`. |
| **Deployment Target** | `<DeploymentTarget>` | One of: `AppSource`, `SaaS PTE`, `OnPrem PTE`. |
| **Use Namespace (y/n)** | `<UseNamespace>` | Default `Yes`. If `No`, no generated file gets a `namespace` line. |
| **Namespace** | `<Publisher>.<ExtensionShort>` | N/A if Use Namespace = `No`. PascalCase, no spaces. |
| **Localization** | `<Localization>` | E.g. `W1`, `NA`, `EU`, `US`. Drives field/table inclusion. |
| **AL Object Prefix** | `<prefix>` | Short, lowercase. Used in page names/identifiers. |
| **APIPublisher / APIGroup Prefix / APIVersion** | — | `'<Publisher>'`, `<prefix>_`, `'v1.0'` — same values everywhere. |
| **Permission Set Prefix** | `<PREFIX> - ` | Uppercase, no AL quotes. |
| **Object ID range(s)** | — | Primary + any Additional, from the loop above. |
| **Permission Sets required?** | `Yes`/`No` | `No` only if the extension owns **zero new tables**. The moment it owns one table, this is `Yes` — BC publish validation (`PTE0004`) requires it. If `Yes`, reserve ≥ 2 IDs in the primary range. |
| **AL Runtime / BC Application Minimum / Symbol Source** | — | From `app.json` target and the symbol file you'll build against. |
| **Onboarding extras** | `Yes`/`No` each | Assisted Setup Wizard? Role Center Activity Cues? Departments/"My Business Central" placement? Ask all three; `No` to any is a final answer, not a placeholder — most small extensions answer `No` to all three, but ask anyway. |
| **Framework files in `.gitignore`?** | `Yes` (default) | Explain briefly what `.gitignore` does, then ask: exclude this runbook/ChangeLog from *this project's* git tracking (recommended), or track them alongside the project's own code? |

**Quoting reference** (applies everywhere): `app.json`/`launch.json` use standard JSON strings;
AL string property values use single quotes (`APIPublisher = 'Contoso';`); AL object names use
double quotes (`page 90800 "acmeCustomers"`); BC field names with spaces use double quotes
(`Rec."Document No."`).

**Entity-naming patterns** (prefix `acme` as example): `APIGroup = 'acme_coreFinancial'`,
`EntityName = 'acmeGeneralLedgerEntry'`, `EntitySetName = 'acmeGeneralLedgerEntries'`,
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

**Outputs:** `standardsGuide/` (fetched, gitignored), `requirements/` (if any raw input was
captured), `ProblemStatement.md` (purpose, scope, out-of-scope, entity list, open questions),
`ProjectParameters.md` (project root — the completed Project Parameters block, all placeholders
replaced), `.gitignore` populated per the table above.

**Exit gate:** The Standards Guide is present in `standardsGuide/` and gitignored.
`ProjectParameters.md` exists in the project root with no placeholder remaining. Deployment Target
is one allowed value. Namespace is consistent or correctly N/A. If
Permission Sets required = `Yes`, ≥ 2 IDs are reserved. Onboarding questions are each answered.
Human confirms the sheet.

---

# PHASE: DESIGN

Goal: one self-sufficient Design Doc, sanity-checked, before any code.

## STEP 2 — Write the Design Doc & Self-Check

**Inputs:** `ProblemStatement.md`, `ProjectParameters.md`, BC symbol file.

**Actions:** Write **one** document — `DesignDoc.md` — that does the job the full framework splits
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
  Localization parameter — obsolete-pending fields are excluded unconditionally, with no timeline
  evaluation); abbreviations applied (**§4.2**); reserved-keyword resolutions (**§4.3** — `area` →
  `areaCode`, and the rest).
- **Computed-field pattern, decided per field:** a `FlowField` is always read-only and always
  live-recalculated — it cannot be overridden. A field that should *suggest* a value the user can
  override (a derived price or date) must be a real **stored** field, seeded by an
  `OnValidate`/`OnInsert` trigger that never overwrites a value the user already entered. State
  explicitly which pattern each calculated-looking field uses.
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
  exist." `PTE0004` fires at **publish**, not compile, and nothing automated catches a missing
  grant, so this has to be right at design time. **Standards §5.3** covers both sets, the naming
  convention, and the `D365` base permissions consumers need on top of them.
- Special notes: singletons, header/line pairs, naming conflicts, deletion behavior for each
  entity (block-if-referenced / cascade / allow) — including any *other* table (standard BC
  included) that references this entity by `TableRelation`.

**Self-check, before calling this step done** (same agent, same pass — no separate reviewer role
in Lite, but don't skip the checklist just because there's no one else to hand it to):
- [ ] Every entity from Step 1 maps to at least one object here (or is explicitly deferred).
- [ ] Every object has a valid ID inside the allocated range.
- [ ] Every source table number is verified against the symbol file — not estimated.
- [ ] Every field complies with the Localization parameter; every obsolete/pending field excluded.
- [ ] Every `using` namespace is sourced from the symbol file.
- [ ] All entity/field names ≤ 30 characters.
- [ ] Read vs. read/write designations match actual data mutability.
- [ ] Permission sets are fully enumerated if required.
- [ ] Every entity's deletion behavior is explicitly decided, not left to a template default.

**Outputs:** `DesignDoc.md`; an **Object Register** table (inside `DesignDoc.md` is fine at this
scale — every planned object with its ID, source table, and R/W status).

**Exit gate:** Human sign-off. Self-check passes with 0 blocking issues. No rule requires
knowledge outside the document.

---

# PHASE: BUILD

Goal: generate AL, lint clean — including symbol verification — then compile, package, test, and
fix in a loop until clean.

## STEP 3 — Plan & Scaffold

**Inputs:** `DesignDoc.md`, Object Register.

**Actions:**
- Confirm the batch plan from Operating Rule 3 (one batch, or two on a natural split) and object
  order within it (lookups before the things that reference them).
- Prepare the scaffold: `app.json` (name, publisher, runtime, BC dependency,
  `"features": ["NoImplicitWith"]`), `launch.json`, folder structure, `.gitignore` per Step 1.
- Bootstrap the AL MCP Server if the harness supports it (see ALL ALONG), the BCQuality knowledge
  snapshot, and the OCPF BC AL Patterns library (both ALL ALONG) — one-time-per-project setup,
  cheapest done now alongside the rest of the scaffold. (The Standards Guide is **not** in this
  group — it was fetched back at Step 1, since DEFINE and DESIGN both need it. Just confirm
  `standardsGuide/` is present and gitignored rather than re-fetching.)
- Write the pre-flight checklist for each object — one list, run twice per object since one model
  is doing both passes:
  - **Pre-generation** (on the planned name/fields): identifier length ≤ 30, reserved-keyword
    scan, localization field-range filter, `ObsoleteState` filter.
  - **Post-generation** (on the actual file): required-property presence (**Standards §1.4** —
    `Caption`, `ToolTip`, `ApplicationArea = All` on every field, no exceptions), **no
    multilanguage (ML) properties and no `TextConst`** — `CaptionML`, `ToolTipML`,
    `OptionCaptionML`, or any other ML variant fails pre-flight; single-language label syntax only
    (**§1.7** — AL0424 fires only when `TranslationFile` is enabled, so the compiler won't reliably
    catch it), `Rec.`-qualification (`NoImplicitWith`, **§1.2**), dead-code check (no empty triggers, no
    `// TODO`, no commented-out fields, **§1.5**), 4-space indentation with no tabs (**§1.6**),
    permission-set `tabledata` coverage for any table the object introduces (**§5.3**), and
    **symbol verification** for every standard/base reference (**Appendix B**).

**Outputs:** Batch plan, project scaffold, the pre-flight checklist.

**Exit gate:** Batch order agreed; scaffold structurally complete (not compiled — Operating Rule
4); pre-flight checklist ready.

## STEP 4 — Generate the Code

**Inputs:** `DesignDoc.md`, `ProjectParameters.md`, symbol file, batch plan, pre-flight checklist.

**Actions — per object, in order:**
1. Pause for human approval before writing the first file.
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
   `ToolTipML`, any other ML property, or `TextConst` (**Standards §1.7**).
5. Run the post-generation pre-flight pass immediately on this file. **Do not invoke the AL
   compiler** (Operating Rule 4).
6. Don't move to the next object until this one's pre-flight, including symbol verification, is
   clean.
- **Before moving past this step, verify permission-set coverage explicitly** across every table
  generated — don't just trust that it was planned. `PTE0004` only fires at publish; this is the
  only defense before then (vacuously satisfied if the extension owns no tables).

**Outputs:** Every AL file, lint-clean including symbol verification; ChangeLog entries for any
deviation from `DesignDoc.md`. The extension is **not** compiled yet.

**Exit gate:** Every planned object generated and pre-flight-clean; permission-set coverage
verified. A clean compile is not required to close this gate — Step 4 hands off directly into
Step 5's mandatory compile-and-package.

## STEP 5 — Compile, Package, Test & Iterate

**Inputs:** Every generated file (lint-clean, not yet compiled); accumulated lint findings;
`DesignDoc.md`; `ChangeLog.md`.

**Actions:** First, **compile the whole extension once, then package it** (check for an
already-provisioned runtime before installing anything — Rule 6b). This is the mandatory
compile-and-package; it is not optional. Package naming, location (`outputAppPackage/`), and the
never-delete rule (ALL ALONG → Packaging & Versioning) apply from this very first package on.

**From here it's a cycle, not a single event:**
1. Publish the current package to a BC sandbox tenant.
2. Test it — manually, by the human, unless a live MCP connection lets the agent run the API test
   checklist below itself.
3. For every error or problem, **first check `patterns/`** (ALL ALONG → OCPF BC AL Patterns
   Library) for a matching, already-documented pattern. If nothing matches, ask: is this a one-off
   or a pattern (search every generated file for the same class of issue)? Where did it come from
   — the generation rule, the Design Doc, or the source data? What rule should have caught it?
4. Fix the **root cause**, regenerate the affected files, and log the issue + resolution in
   `ChangeLog.md` before moving on. Update `DesignDoc.md` whenever a rule changes. Pause for human
   approval of each root-cause diagnosis before applying it.
5. **Compile and package again**, redeploy, retest. Repeat until 0 errors / 0 warnings and the
   human confirms sandbox testing is clean.

**API test checklist** (used here, and again at Step 7 — endpoint URL shapes are in **Standards
Appendix A**):
- **Green-team (happy path):** `$metadata` returns the expected schema; read a collection; read a
  single record by `SystemId`; create a record on an editable endpoint; update a field; confirm a
  read-only endpoint rejects writes.
- **Red-team (boundary):** write to a read-only endpoint; send a non-existent field; send an
  invalid key; delete a record with dependencies; call with missing permissions — each should
  fail *gracefully with a clean, actionable error*.

**Optional:** if a live MCP connection reaches the sandbox, offer to run the checklist above
automatically; otherwise say so plainly and suggest Postman, Power Automate, or Copilot Studio as
a manual alternative.

**Outputs:** All files compiling and packaging with **0 errors, 0 warnings**; at least one package
published and manually tested on a sandbox; `ChangeLog.md` current; `DesignDoc.md` updated for
every rule change.

**Exit gate:** Full extension compiles clean; human confirms sandbox testing is clean; no known
systemic issue outstanding.

---

# PHASE: PROVE

Goal: confirm the built code matches the Design Doc, is clean, is documented, and has passed a
human-run release test.

## STEP 6 — Review, Gap-Check & Finalize Docs

**Inputs:** The built extension, `DesignDoc.md`, `ChangeLog.md`.

**Actions:**
- **Gap-check** — compare `DesignDoc.md` against the as-built code. For each divergence: object
  planned but not built (intentional or oversight?), object built but not planned (scope creep or
  gap-fill?), a rule implemented differently (is there a ChangeLog entry?). Classify each as
  **Intentional**, **Oversight** (fix now via the Step 5 cycle), or **Spec stale** (code's right —
  update `DesignDoc.md`).
- **Code review** — one pass across every object: consistent structure/naming/formatting
  throughout (small projects still drift between the first file written and the last); no dead
  code (**Standards §1.5**); no reference to anything with `ObsoleteState = Pending`/`Removed`,
  unconditionally and with no version check (**Standards §3.2–§3.3**); `Rec.`-prefix everywhere;
  correct `DelayedInsert`/`Editable` per data mutability (**§2.2**); every table covered by both
  permission sets (re-verify independently — don't just trust Step 4). **Then run the full
  Anti-Patterns table — Standards Part 7 — against the codebase.** It's one table and it reads in
  a couple of minutes; it's the single highest-value thing the Standards Guide gives a Lite
  project, because most of what it catches is invisible until publish or until a consumer hits
  it. **Search every AL file — including anything a human wrote or pasted in — for deprecated
  multilanguage syntax** (`CaptionML`, `ToolTipML`, `OptionCaptionML`, any other `…ML` property,
  `TextConst`); every hit is a finding, refactored per **Standards §1.7**. A clean compile proves
  nothing here: AL0424 only fires when `app.json` enables `TranslationFile`. Read the code against
  AL Guidelines' *Best Practices* and *Vibe Coding Rules* for anything the Standards Guide doesn't
  already cover (the Standards Guide wins on any conflict — surface it rather than picking a side
  silently). Then invoke the BCQuality snapshot's `skills/entry.md` dispatch flow (fetched at Step 3) as
  an additional, independent pass, and fold its findings in the same way as your own — never
  applied blind. If the fetch didn't happen or the snapshot is missing, say so rather than
  silently skipping this pass.
- **Update `DesignDoc.md` in place** to reflect the as-built reality — final object inventory, any
  naming or exception that emerged during BUILD, a short deviation summary pointing at the
  relevant `ChangeLog.md` entries. There's no separate as-built document in Lite; one file, kept
  current, is the point.
- Any fix this step produces follows the Step 5 cycle (recompile, repackage, redeploy, retest)
  before this step closes; a comment/formatting-only fix doesn't need a fresh package.
- **Write `Docs.md`** — one combined reference covering everything the full framework splits
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
    map to which roles, uninstall.
- **Write `TestScript.md`** — the green-team/red-team checklist from Step 5, made concrete against
  this extension's actual endpoints, for a human tester to run end to end at Step 7.

**Outputs:** `DesignDoc.md` (updated in place), `Docs.md`, `TestScript.md`. Together with
`ChangeLog.md` from Step 1 onward, that's the full Lite document set — four files.

**Exit gate:** Every gap classified and resolved or explicitly deferred (logged in
`ChangeLog.md`); dead-code scan clean; no obsolete references; `Docs.md`'s diagram renders;
`TestScript.md` is executable by a non-developer.

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
> they need to do next (run `TestScript.md` end to end, record every finding in `ChangeLog.md`);
> and (d) say how to bring the agent back in — either when testing surfaces something to fix, or
> once everything passes and it's time to mark the release candidate.
>
> Everything below this note is what happens *after* that hand-off — the human's test run, and
> the agent's part in recording and fixing what it turns up.

**Inputs:** The most recently built package; `TestScript.md`; `Docs.md`.

**Actions:**
- Confirm the latest package is published to a BC sandbox tenant — republish if anything changed.
- Real users/testers — not the agent, not a simulated pass — run `TestScript.md` end to end: every
  green-team and red-team case, by hand.
- Verify permission sets as part of the same pass: read-only grants read everywhere; read/write
  includes it plus write on editable pages.
- Record every finding directly in `ChangeLog.md` — verbatim first, then triaged: **implement now**
  (its own entry, fixed via the Step 5 cycle), **defer** (its own entry, marked deferred, with
  reasoning — Lite doesn't keep a separate `Roadmap.md`), or **reject** (record why).
- **If a fix here changes any object, field, or behavior, treat Step 6's outputs as stale, not
  already covered** — re-run the affected parts of the review and regenerate `Docs.md`'s reference
  and diagram from the now-changed code. Say explicitly which parts a given fix actually requires
  re-running.
- Repeat until every green-team test passes and every red-team test fails gracefully.

**Outputs:** `ChangeLog.md` updated with every test finding and its resolution.

**Exit gate:** All green-team tests pass; all red-team tests fail gracefully; permission sets
verified. **If everything passes, the package that was actually tested is the one deployed to
Production** — bump its Build segment (e.g. `0.0.5.0` → `0.0.5.1`) or copy it to an immutable
filename first, so the shipped artifact stays permanently identifiable. This is marking the
release candidate, not building a new one — no recompile, no new testing required to do it.
**Before that deploy, restate the Schema Sync Mode assessment** (ALL ALONG → Packaging &
Versioning) — **Add** if this release is additive-only, **Force Sync** with an explicit data-loss
warning if anything was removed, shrunk, retyped, or re-keyed since the last production release.

---

# ALL ALONG — Continuous Discipline

Run these throughout, not as a final step.

## ChangeLog.md — the single running log

Lite merges what the full framework splits across a ChangeLog, a Testing Feedback Log, and a
Roadmap into **one file**. Every deviation from `DesignDoc.md`, every diagnosed root cause, and
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
references its `ChangeLog.md` entries.

## Packaging & Versioning

Packaging first happens at Step 5's mandatory compile-and-package, and recurs every time the
extension changes from there through Step 7 — every fix gets a fresh package before redeploying
to the sandbox for the next test round.

**Naming and location — fixed:** every package is named
`<ExtensionName, spaces → underscores>_<version>.app`, read from `app.json` at build time, never
hand-typed. Written to `outputAppPackage/` in the project root — always this name, never `out/` or
`output/`. Mention the folder once at Step 1, and state the full path again every time a build
completes (e.g. "Package built: `outputAppPackage/IP_Tracking_1.0.0.0.app`.").

**`outputAppPackage/*.app` is git-tracked, never gitignored.** Track every `.app` like any other
deliverable.

**Never delete or overwrite a package from a different version.** A repackage at a new version
writes a new file next to the old ones — it never replaces or "cleans up" anything already there,
even something that looks superseded. Consecutive builds *at the same version*, during the Step
5–7 cycle, legitimately overwrite each other — that's expected, not the destructive case. What
must stay permanently identifiable is the specific package that passes Step 7: bump its Build
segment or copy it to an immutable filename before it ships.

**Version bumps require a proposal and approval — never a silent `app.json` edit.** Propose a
specific bump with reasoning: **Major** (breaking/structural — rare pre-release), **Minor** (new
features/objects, backward-compatible — the common case), **Build** (repackage, no new
functionality), **Revision** (a small hotfix, no new features).

**Flag Schema Sync Mode on every completed build.** Uploading a `.app` through Extension
Management offers **Add** (default — refuses an incompatible schema change, no data loss) or
**Force Sync** (overwrites even a destructive change — table/field removals, a changed key,
incompatible retyping — can lose data). Say plainly which mode a given build needs; never let a
schema-breaking change go out without this warning.

## OCPF AL Development Standards Guide

The companion rules document — `ocpfALDevStandardsGuide.md`, v1.1.0.0 — shared unchanged with the
full framework. **Lite reduces process, not AL rules**, so this is the one fetched resource that
isn't optional: this runbook cites it as **Standards §** from Step 1 onward.

- **Fetch at Step 1**, not Step 3 with the other libraries — the Step 1 gap check already needs
  Standards Part 6. Get `standardsGuide/ocpfALDevStandardsGuide.md` from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/` into `standardsGuide/` in the project
  root. Write a `SNAPSHOT.json` beside it recording source, ref, commit SHA, and fetch timestamp.
  Tell the human you're doing it.
- Lives **inside** the project root, like `patterns/` — it's a single Markdown file with no `.al`
  objects, so there's no `alc` compile-breaking reason to push it outside the tree.
- **If the repo isn't reachable**, say so and ask the human for a copy — don't proceed from memory
  of what the standards say. This is stricter than the patterns library, which degrades
  gracefully: an absent Standards Guide means every `Standards §` citation in this runbook points
  at nothing.
- **Always gitignored**, never a per-project choice — same reasoning as `patterns/` and BCQuality
  (see Repository Hygiene). Not covered by the Step 1 `.gitignore` question, which governs only
  this runbook and `ChangeLog.md`.
- **Refresh only when asked** ("refresh the standards guide"). Report "updated from `<old sha>` to
  `<new sha>`" or "already up to date."
- The guide is versioned independently of this runbook (both tracked in the framework's
  `RunbookChangelog.md`). If a fetched guide's version doesn't match what this runbook expects,
  say so rather than silently reconciling a citation that doesn't resolve.

## Repository Hygiene

- The Standards Guide lives **inside** the root, in `standardsGuide/`, and is always gitignored —
  added at Step 1 when it's fetched.
- The BCQuality snapshot lives **outside** the project root entirely (see below) — not a
  candidate for this project's git tracking at all.
- The OCPF Patterns library lives **inside** the root, in `patterns/`, but is always gitignored —
  it's the human's own portable, cross-project methodology, refetchable at will, not part of what
  a client is paying to receive.
- This runbook and `ChangeLog.md` are gitignored by default, per the Step 1 answer; a human who
  wants the project's repo to be self-contained can opt to track them instead.
- If any of the above is already tracked when this policy is adopted, add the `.gitignore`
  entries and actually untrack them (`git rm --cached`, not `git rm` — files stay on disk).
  Check first whether the project has a remote already, since untracking rewrites what a `git
  pull` shows collaborators.

## AL MCP Server (optional, recommended)

The AL Language extension ships a standalone MCP server (`altool launchmcpserver`) exposing AL
build/publish/symbol/diagnostic tools over MCP. Bootstrap once per project if the harness supports
it: locate `altool` inside the AL extension's `bin/` folder (on macOS/Linux, run `altool.dll`
against a .NET runtime rather than the Windows-only `.exe` — check what the IDE already privately
provisions before installing anything, Rule 6b), confirm `app.json`/`launch.json` are in place,
register it with the harness's MCP host, and verify by listing tools (not a project compile).
Prefer its build/publish/symbol tools over an ad hoc terminal invocation once registered.

## Reference Sources — Microsoft Learn and AL Guidelines

Consulted online, never fetched into the project, so there's nothing to bootstrap, gitignore, or
refresh. If there's no web access, say so rather than answering from memory of what a reference
says.

| Reference | What it's for | Used at |
|---|---|---|
| **BC Base Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application> | Standard Base App tables, fields, datatypes/sizes | Operating Rule 2 fallback |
| **BC System Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application> | System Application modules — check before building what the platform already provides | Operating Rule 2 fallback; Step 2 |
| **Working with translation files** — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files> | XLIFF translation in AL; why ML properties are banned | Standards §1.7 |
| **AL Guidelines** — <https://alguidelines.dev> (<https://github.com/microsoft/alguidelines>, MIT) | AL best practices, design patterns, agent-oriented *Vibe Coding Rules* | Step 2 (patterns); Step 6 (review) |

**Precedence:** the downloaded symbol file beats Microsoft Learn on anything symbol-verifiable; the
Standards Guide beats AL Guidelines on any AL rule. **Known conflict, excluded outright:** AL
Guidelines' legacy *NAV Patterns → C/AL Coding Guidelines* pages recommending `CaptionML` and
`OptionCaptionML` predate AL and XLIFF — never follow them (Standards §1.7).

Every third-party resource the framework references, fetches, or recommends is credited, with its
license, in `THIRD_PARTY_NOTICES.md` at the root of the framework repository.

## BCQuality Knowledge Snapshot

BCQuality (`microsoft/BCQuality` on GitHub) is a curated knowledge base and skill library for BC
AL code quality — markdown knowledge files plus skills defining how to search and apply them. It
augments review judgment; it doesn't replace it.

- Fetch a full, current snapshot **once per project**, at Step 3, alongside the rest of the
  scaffold. Put it **outside** the AL project's own root — e.g. a sibling directory such as
  `../<ProjectName>.bcquality/` — never anywhere under `app.json`'s tree: `alc` recursively
  compiles every `.al` file it finds, and BCQuality's own knowledge base ships illustrative
  `.good.al`/`.bad.al` fragments that aren't real compilable objects. A shallow clone
  (`git clone --depth 1`), `.git` stripped but its `LICENSE` file kept (BCQuality is MIT-licensed,
  and MIT requires the notice to stay with every copy), mirroring the repo's own layout. Write a small
  `SNAPSHOT.json` alongside it recording the commit SHA and fetch timestamp. Tell the human you're
  doing this — it's not a silent background check.
- Refresh **only** when explicitly asked ("refresh BCQuality"). Overwrite the existing snapshot
  and report plainly: "updated from `<old sha>` to `<new sha>`" or "already up to date."
- **Using it:** read `skills/entry.md` from the snapshot with an explicit task context (goal,
  inputs, technologies, BC version); it returns a dispatch record naming which action skill(s) to
  run. Read `skills/read.md`/`skills/do.md` on demand. Invoke the dispatched skill(s) — for a full
  review, typically `microsoft/skills/review/al-code-review.md`. Findings come back with an
  outcome, a domain label, and structured references for knowledge-backed findings (an empty
  `references: []` for the agent's own, capped at medium confidence). Integrate every finding the
  same way as any other Step 6 finding — never applied blind. No network access is needed once the
  snapshot exists.
- Always gitignored — see Repository Hygiene above.

## OCPF BC AL Patterns Library

**OCPF** = **OnlyCopilotFans.** `ajansari/ocpfBCALPatterns` on GitHub is the human's own curated
collection of reusable BC AL patterns, each extracted from a real bug found and fixed on a past
project: symptom, verified root cause, the fix, a worked example, caveats — one self-contained
Markdown file per pattern. Unlike BCQuality, this is the human's own accumulated cross-project
material, not a third-party knowledge base.

- Fetch **once per project**, at Step 3, alongside the AL MCP Server and BCQuality bootstrap. If
  the repo isn't reachable, say so plainly and continue — it's not a blocker.
- Lives **inside** the project root, in `patterns/` — every file is Markdown with embedded AL, not
  a real `.al` object, so there's no compile-breaking risk the way there was with BCQuality.
- Shallow clone (`git clone --depth 1`), `.git` stripped, `LICENSE` kept. Write `SNAPSHOT.json` inside `patterns/`
  recording source, ref, commit SHA, fetch timestamp.
- **Merge behavior:** if `patterns/` doesn't exist, create it and copy the content in directly. If
  `patterns/README.md` already exists locally, don't overwrite it — append the fetched README
  under a fixed delimiter (`## Upstream README — ajansari/ocpfBCALPatterns @ <sha>`), so a later
  refresh can find-and-replace that block instead of duplicating it. Add any pattern files not
  already present; if a same-named file already exists locally with different content, ask the
  human which to keep (Rule 6a) rather than silently overwriting.
- Always gitignored — see Repository Hygiene above.
- Refresh **only** when explicitly asked. Report new pattern files added, or "already up to date."
- **Using it:** before diagnosing a bug from scratch at Step 5 or 7, check `patterns/` for an
  already-documented match first — that's the entire point of the library. If a fix produced
  during this project looks like it will recur on future projects, flag it to the human as a
  candidate for a new pattern file — contributing back is the human's call, not the agent's.

## Permission Sets — the one rule worth restating

The moment this project owns even one table, Permission Sets required = `Yes` — it stops being a
free choice. `PTE0004` (missing permission set) fires at **publish**, not compile, and nothing
automated catches a missing `tabledata` grant before then except the pre-flight checks in Steps 3,
4, and 6. Verify coverage independently at each of those points; don't just trust the previous
one.

---

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
editions fetch the same v1.1.0.0 file and apply the same AL rules — Lite differs only in process.

**Document count:** 4 tracked files (`DesignDoc.md`, `ChangeLog.md`, `Docs.md`, `TestScript.md`)
versus the full framework's 19 (`ProblemStatement`, `ProjectParameters`, `FRD`, `TDD`,
`SanityCheck`, `ChangeLog`, `ProjectMemory`, `ProjectProgress`, `GapAnalysis`, `CodeReview`,
`PostDevTDD`, `Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`,
`AutomatedTestScripts`, `ReleaseTestResults`, `TestingFeedback`, `Roadmap`).

---

*Lite Edition derived from the OCPF BC Agentic Development Framework, created by AJ Ansari,
Microsoft MVP, OnlyCopilotFans. Update this runbook when the full framework changes in a way that
should flow down to Lite.*
