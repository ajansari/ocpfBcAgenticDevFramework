# BC App Build Routine — Lite Agent Runbook

## OnlyCopilotFans Agentic Dev Framework — Lite Edition

**Version:** 1.11.0.0 (Lite, derived from the full framework v2.14.0.0)
**Last Updated:** September 15, 2026

> Version history for this edition lives in `LITE_RunbookChangeLog.md`, tracked independently of
> the full framework's own `fullVersion/RunbookChangelog.md` (though a change to one often has to
> be reflected in the other) and of any one project built with it. Diagrams for this routine live
> in `LITE_RunbookSchematics.md`. If either file is not found, create it.

> This is the lightweight sibling of the full **OCPF BC Agentic Development Framework**
> (`fullVersion/BC_App_Build_Routine_Agent.md`, in the same repo). Same author, same underlying
> discipline — half the steps, one model doing all the work, and no ceremony that a
> 10-files-or-fewer project doesn't need.

> **Companion document:** `standardsGuide/ocpfALDevStandardsGuide.md` — the **OCPF AL Development
> Standards Guide** (v1.7.0.0), shared unchanged with the full framework. Lite is *not* a reduced
> set of AL rules: the same AL rules apply to a 5-file extension as to a 50-file one. What Lite
> reduces is *process*. So this runbook names each rule in one line where a checklist applies it and
> cites the guide as **Standards §**; the rule's rationale, limits, tool behavior, and reference
> links live only in the guide — the abbreviation tables, the complete anti-pattern list, the
> field-exclusion rules, the endpoint patterns. Fetch it at Step 1 (see
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
     together for one decision (Step 5), with any fix that changes a design rule in `DesignDoc.md`
     asked separately;
   - **finalizing the Design Doc;**
   - **installing any tool or runtime.**

   An approved run-through still stops by itself on any pre-flight failure or deviation from
   `DesignDoc.md`, and the human can say "stop" at any time.
   6a. **Ask decisions in a selectable options box, not in prose.** When the agent needs the human
       to *decide* something — pick a design option, approve a version bump, resolve an ambiguity —
       present it through the interactive multiple-choice mechanism the agent's harness provides
       (e.g., Claude Code's `AskUserQuestion`), recommended option first with a short reason. Don't
       wrap ordinary progress (finishing a step, reporting a clean compile) in this — that's just
       noise. **Every intake question counts as a decision**, including values only the human
       knows: names, publisher, prefix, namespace, localization, ID ranges, versions. Ask them
       through the options mechanism, never as open-ended questions or a numbered list in chat;
       the mechanism's free-text entry (Claude Code: *Other*) carries a typed answer. Step 1 says
       what to offer. **The mechanism, per harness:**
       - **Claude Code — `AskUserQuestion`:** up to four questions per box, 2–4 options each, a
         free-text *Other* added automatically; multi-select where several answers apply.
       - **GitHub Copilot Chat in VS Code — the `askQuestions` tool:** several questions in one
         carousel, each single-select, multi-select, or free text.
       - **GitHub Copilot CLI — the `ask_user` tool:** a choice question there takes no typed
         answer, so add an explicit *I'll type it* choice and follow it with a free-text question.
       - **Anything else:** its closest equivalent, one question at a time if that's all it takes.
         Only when a harness has no question mechanism at all, ask one question per message with
         its options labelled, and say why.
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
       install or any manual setup step (editing `PATH`, a shell profile, or an environment
       variable), stop at the first option that works:
       1. **What the editor already provides.** The **AL Language extension** gives GitHub Copilot
          Chat in VS Code its AL tools built in (`al_build`, `al_publish`, `al_downloadsymbols`,
          `al_symbolsearch`, `al_getdiagnostics`, …). For Claude Code or Copilot CLI, its bundled
          AL MCP Server runs on the .NET runtime VS Code already provisioned (ALL ALONG → AL MCP
          Server).
       2. **What's already installed.**
       3. **Only then, an install,** asked for under Rule 6b.

       Never ask the human to edit `PATH`, a shell profile, or environment variables; put paths in
       the configuration or launcher you create. Test: would a functional consultant with only VS
       Code and the AL extension have to do anything by hand? If yes, look again.

       **Never hand the human a setup task the agent can do**.
       Connecting the AL tools, downloading symbols, and keeping the editor's view current are
       the agent's job (ALL ALONG → AL MCP Server, Symbols, Keeping the Editor in Sync). The
       human only approves the AI tool's permission prompts, and signs in when a tool reaches a
       live Business Central environment. Ask for more only when something is actually broken,
       and then name a command you've confirmed exists. **Never send the human to the Command
       Palette to set up the AL MCP Server:** the AL Language extension has no such command. Never
       route AL tooling through a third-party VS Code extension.
7. **Log every deviation immediately.** Any departure from the Design Doc — human or agent — goes
   in `ChangeLog.md` before the next batch starts.
8. **Work in the human's chosen working language.** The first question of Step 1 asks which
   language the human wants to work in. Every later question, options box, and explanation is in
   that language. **Always in English, regardless:** this runbook, the Standards Guide, AL code
   and names, commit messages, `DesignDoc.md`, and `ChangeLog.md`. **Kept verbatim in their
   original language:** raw requirements and tester feedback. When the human names a BC concept in
   their own language, map it through the glossary in `DesignDoc.md` rather than guessing.

---

# PHASE: DEFINE

Goal: turn a business need into a validated scope and a filled-in parameter sheet — before any
design work.

## STEP 1 — Define the Problem & Lock Parameters

**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**
- **Ask the working language first — before anything else** (Operating Rule 8). Ask in English,
  through the options mechanism, with English listed first and free text for any other language.
  It's asked alone, so every later box can be in the language chosen.
  Continue in the language chosen.
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
- **Populate the Project Parameters block below, and persist it as `ProjectParameters.md` in the
  project root.** Complete every field; replace every placeholder. These values override all
  defaults for the rest of the routine, and every later step reads them from that file rather than
  from conversation history.

**Ask first, don't infer — and ask interactively** (Rule 6a). Every question in this step goes
through the options mechanism Rule 6a names for this harness, never as an open-ended question or a
numbered list in chat. **Use as few boxes as the questions allow:** up to four questions per box,
sharing a box only when none depends on another's answer. Where the harness asks one question at a
time, ask the same questions in the same order.

**Before the first box,** read `ProblemStatement.md` for suggestions, and read Microsoft's live
[Country/Regional Availability and Supported Languages](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations)
page — never from memory — so every country and language offered is one BC supports. If it can't
be reached, say so and ask the human.

**Option counts:** 2–4 options per question. With one suggestion, pair it with *I'll type it*;
with more than four candidates, offer the four most likely and say others can be typed.

A suggestion is a candidate the human picks, never an answer recorded for them: nothing goes into
`ProjectParameters.md` until the human selects or types it. Never build one from an email domain
or a guess at house style. A wrong guess here means renaming the whole project later.

| Box | Questions | Options to offer (free-text entry always available) |
|---|---|---|
| **1 — Identity** | 1. Extension Name? | Up to three names built from the problem statement's wording, labelled as suggestions. |
| | 2. Publisher? | Only names the human already wrote or uploaded, quoted verbatim with their source. If none: *I'll type it* / *Decide after the other questions* (then ask it alone before Box 2). |
| | 3. Deployment Target? | *SaaS PTE* / *OnPrem PTE* / *AppSource*, best fit first. |
| | 4. Which countries will users work in? *(multi-select)* | The countries the problem statement names that BC is available in. Countries are asked only here. |
| **2 — Naming** *(built from Box 1)* | 5. AL object prefix? | Two or three short lowercase prefixes built from the name and publisher. |
| | 6. Which namespace? | `<Publisher>.<ExtensionShort>` *(recommended)* / one alternative / *No namespace*. Records both Use Namespace and Namespace. |
| | 7. Localization? | Up to three of the Box 1 countries as codes (e.g. `US`), then `W1`. |
| | 8. BC version? | The current Business Central online major version *(recommended)* and the one before it, looked up on Microsoft Learn, never from memory; a sandbox the human already has is the natural choice. Don't ask for `runtime`: read it from Microsoft Learn's [Choose runtime version in AL](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-choosing-runtime) table. |
| **3 — Permission sets & IDs** *(built from Box 2)* | 9. Permission Set App Code? | Two or three uppercase codes from the name that fit `13 − (prefix length)` characters (e.g. `NAICS`); must differ from every other extension using this prefix (**Standards §5.4**). |
| | 10. Do other extensions already use this prefix? | *No, this is the first* / *Yes — I'll type their App Codes or permission set names*. On a match, ask 9 again, alone. |
| | 11. Object ID range? | Complete ranges with their size: one from the human's material (e.g. *80300–80339 — 40 IDs*); *50100–50149 — 50 IDs* ("the AL template's default: only if no range has been assigned to you"); or type `start–end`. |
| | 12. Another Object ID range? | *No* / *Yes*. Each *Yes* opens a box with 11 and 12 again. |
| **4 — Onboarding** | 13–15. Assisted Setup Wizard? Role Center Activity Cues? Departments / "My Business Central" placement? | *No* / *Yes* each; a *Yes* gets its specifics in one follow-up box. |
| | 16. Permission Sets required? *(only if the entity list has no new table)* | *No — the extension adds no tables* / *Yes*. Not asked once the extension owns a table: then it's `Yes`. |
| **5 — Setup & languages** | 17. Leave this framework's own files out of the project's repository? | *Yes (recommended)* / *No, track them*, with the one-sentence `.gitignore` explanation from the table below. |
| | 18. Source language? | *`en-US` (recommended)*, with **Standards §8.1**'s reason in one sentence, or another language typed in. |
| | 19. Languages for each Box 1 country *(multi-select, one question per country; more countries spill into the next box)* | Only the languages BC supports in that country, as ID and culture code (*"French (Canada) — FRC → `fr-CA`"*). |
| **6 onward — Translation** | First, in one box: source wording (only when `en-US` is the sole target), customer-language documents, translatable data — source wording decides whether the rest is asked. Then, unless the answer was *US wording, no translation files*: per language, required at first release and who reviews it; then the two document questions. | As the table below describes; two questions per language, up to four per box. |
| **Last — Confirm** | 20. Is this sheet right? | Show the complete sheet first, with every ID range's size and the derived permission set names. *Confirm the sheet* / *Change something* (ask only what changes). |

The first ID range is the Primary allocation; any after it are Additional.

**Question 9 exists because permission sets named from the prefix alone** (`OCPF - READ`) collided
across every extension with that prefix (**Standards §5.4**).

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
| **APIPublisher / APIGroup Prefix / APIVersion** | — | Derived: the Publisher in camelCase (`'contoso'`), the prefix followed by a PascalCase group name (`'acmeCoreFinancial'`, no underscore), and `'v1.0'` — same values everywhere (**Standards §2.7**). |
| **Permission Set App Code** | `<APPCODE>` | Uppercase letters or digits, no spaces, unique among every extension that uses this prefix, at most `13 − (prefix length)` characters (**Standards §5.4**). |
| **Permission Set Names** | `<PREFIX> <APPCODE>, VIEW` / `<PREFIX> <APPCODE>, EDIT` | Derived: `<PREFIX>` is the AL Object Prefix in uppercase. Each ≤ 20 characters, e.g. `OCPF NAICS, VIEW`. |
| **Object ID range(s)** | — | Primary + any Additional, from Box 3. |
| **Permission Sets required?** | `Yes`/`No` | `No` only if the extension owns **zero new tables** (**Standards §5.3**); otherwise `Yes`, not asked. If `Yes`, reserve ≥ 2 IDs in the primary range. |
| **AL Runtime / BC Application Minimum / Symbol Source** | — | BC version from Box 2; runtime from Microsoft Learn. Symbol Source is filled in by the agent after downloading: version, W1 or localized, and where from. |
| **Onboarding extras** | `Yes`/`No` each | Assisted Setup Wizard? Role Center Activity Cues? Departments/"My Business Central" placement? Box 4; `No` to any is a final answer, not a placeholder — most small extensions answer `No` to all three, but ask anyway. |
| **Framework files in `.gitignore`?** | `Yes` (default) | Box 5, asked as: *"`.gitignore` lists files Git leaves out of commits and pushes — they stay on disk and work normally. Should this framework's own files be left out of this project's repository?"* Covers this runbook (under whatever name it was given: `CLAUDE.md`, `.github/copilot-instructions.md`, or `LITE_BC_App_Build_Routine_Agent.md`), `LITE_RunbookChangeLog.md`, `LITE_RunbookSchematics.md`, and the plugin's `.ocpf/` folder, if present. **Never the project's own `ChangeLog.md`**, which is always committed. |
| **Working language** | — | From the first question of this step. |
| **Target languages** | table | Box 5's question 19, for the countries from Box 1 — never asked again (rules: **Standards §8.8**). Classify each chosen language as Microsoft-translated, partner-translated (ask which partner app, in the next box — it's the terminology source), or not supported by BC (every right-to-left language included). Don't offer an unsupported language; if typed, offer the country's English instead, and only record it if the human insists. Then, unless source wording is *US wording, no translation files*, per language, two questions: *Required at first release* / *Can follow later*; and who reviews it — names the human mentioned, or *I'll type it*; a named fluent person, never the agent. Flag any mismatch with **Localization**. |
| **Source language** | `en-US` (default) | Offer `en-US` first, labelled recommended, with the one-line reasons in **Standards §8.1**. If the human chooses another, state the consequences before recording it. |
| **Source wording** | `W1` | Microsoft's W1 English wording in source, with one translation file per target language (`en-US` included). Only when `en-US` is the **sole** target **and Deployment Target isn't `AppSource`** (AppSource requires translation files — **Standards §8.10**), also offer *US wording in source, no translation files* — simpler now, but another market later means changing source strings. |
| **Documents in other languages** | per document | Only with a target language other than the source. Two questions: translate `Docs.md`'s user-guide section into each required language (*Yes (recommended)* / *No*); and does `TestScript.md` need a translated copy (*No — testers run the language pass from the English script, which names the terms they should see (recommended when testers read English)* / *Yes*)? `DesignDoc.md` and `ChangeLog.md` stay English. Translated documents are produced at Step 7, once the functional test pass is green. |
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

**Once the human confirms the sheet, set up the AL project before DESIGN** — the agent's job,
never the human's (Rule 6d). Step 2 verifies against symbols, so they must be on disk now, and
nothing here needs the human beyond the AI tool's own approval prompts.
1. **Write `app.json` once, complete,** from the sheet: name, publisher, version, every ID range,
   `platform`, `application`, `runtime`, and the `features` Step 3 lists. If one already exists
   (for example from **AL: Go!**), keep its `id` GUID and replace the rest.
2. **Connect the AL tools** if this session doesn't have them (ALL ALONG → AL MCP Server).
3. **Download symbols** (ALL ALONG → Symbols). Confirm `.alpackages/` holds Base Application and
   System Application for the target version, and record the Symbol Source. Add `.alpackages/` to
   `.gitignore` now (ALL ALONG → Repository Hygiene).
4. **Keep the editor in sync** (ALL ALONG → Keeping the Editor in Sync). If `app.json` existed
   before you changed it, VS Code's AL extension still has the old ranges. Refresh it now, before
   any `.al` file exists.

**Outputs:** `standardsGuide/` (fetched, gitignored), `requirements/` (if any raw input was
captured), `ProblemStatement.md` (purpose, scope, out-of-scope, entity list, open questions),
`ProjectParameters.md` (project root — the completed Project Parameters block, all placeholders
replaced), `.gitignore` populated per the table above, `app.json`, and `.alpackages/`.

**Exit gate:** Every question was asked through the options mechanism. `app.json` matches the
sheet, and the target version's symbols are in `.alpackages/`. The Standards Guide is present in
`standardsGuide/` and gitignored. `ProjectParameters.md` exists in the project root with no placeholder remaining. Deployment Target
is one allowed value. Namespace is consistent or correctly N/A. If
Permission Sets required = `Yes`, ≥ 2 IDs are reserved. Onboarding questions are each answered.
Every target language is classified against Microsoft's live page and, unless source wording is
*US wording, no translation files*, has a required-at-release answer and a named reviewer; source
language and wording are recorded. Human confirms the sheet.

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
  exist" — named from `ProjectParameters.md`, each ≤ 20 characters with a caption ≤ 30
  (**Standards §5.3–§5.4**).
- Special notes: singletons, header/line pairs, naming conflicts, deletion behavior for each
  entity (block-if-referenced / cascade / allow) — including any *other* table (standard BC
  included) that references this entity by `TableRelation`.
- **Translatable text** (**Standards §8.3**): every message a `Label` with an AA0074 suffix and a
  `Comment` for each placeholder; which labels are `Locked`; translation file names
  (`Translations/<ExtensionName>.<culture>.xlf`).
- **Translation glossary** — a table in `DesignDoc.md` (skip if the project chose *US wording, no
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
  order within it (lookups before the things that reference them). **This is the one approval to
  generate code** (Rule 6). With two batches, ask once (Rule 6a): **Run through both batches,
  stopping on any pre-flight failure or Design Doc deviation (recommended)** / **Ask me before
  the second batch**. Record the answer in `ChangeLog.md`.
- Prepare the scaffold: confirm `app.json` (written at the end of Step 1) still matches
  `ProjectParameters.md` — name, publisher, ID ranges, runtime, BC dependency,
  `"features": ["NoImplicitWith", "TranslationFile"]` (**Standards §8.2**) — then `launch.json`,
  folder structure, a `Translations/` folder, `.gitignore` per Step 1 (plus `*.g.xlf` and
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
  - **Pre-generation** (on the planned name/fields): identifier length ≤ 30, reserved-keyword
    scan, localization field-range filter, `ObsoleteState` filter.
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
scaffold structurally complete, analyzer settings and (for AppSource) `AppSourceCop.json` in place
(not compiled — Operating Rule 4); pre-flight checklist ready.

## STEP 4 — Generate the Code

**Inputs:** `DesignDoc.md`, `ProjectParameters.md`, symbol file, batch plan, pre-flight checklist.

**Actions — per object, in order:**
1. **Approval came at Step 3** — don't ask again per object. With two batches, pause before the
   second only if the human chose that. Stop and ask on any pre-flight failure the Design Doc
   can't resolve, or any deviation from `DesignDoc.md`.
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
deviation from `DesignDoc.md`. The extension is **not** compiled yet.

**Exit gate:** Every planned object generated and pre-flight-clean; permission-set coverage
verified. A clean compile is not required to close this gate — Step 4 hands off directly into
Step 5's mandatory compile-and-package.

## STEP 5 — Compile, Package, Test & Iterate

**Inputs:** Every generated file (lint-clean, not yet compiled); accumulated lint findings;
`DesignDoc.md`; `ChangeLog.md`.

**Actions:** First, **compile the whole extension once, with the analyzers this framework
requires, then package it** (ALL ALONG → Analyzers; check for an already-provisioned runtime
before installing anything — Rule 6b). This is Rule 4's mandatory compile-and-package. Package
naming, location (`outputAppPackage/`), and the never-delete rule (ALL ALONG → Packaging &
Versioning) apply from this very first package on.

**After every compile with 0 errors, check what the human's editor shows** (ALL ALONG → Keeping
the Editor in Sync). Red marks the compiler didn't report, like an object ID outside the allowed
ranges, mean the editor's view is stale, not the code. Refresh the view; never change code that
compiles clean to clear them.

**From here it's a cycle, not a single event:**
1. Publish the current package to a BC sandbox tenant.
2. Test it — manually, by the human, unless a live MCP connection lets the agent run the API test
   checklist below itself.
3. For every error or problem, **first check `patterns/`** (ALL ALONG → OCPF BC AL Patterns
   Library) for a matching, already-documented pattern. If nothing matches, ask: is this a one-off
   or a pattern (search every generated file for the same class of issue)? Where did it come from
   — the generation rule, the Design Doc, or the source data? What rule should have caught it?
4. **Approve the round's fixes together, then apply them.** Once every problem from this test
   round has a diagnosis, present them all in one message — each listed separately with its root
   cause and proposed fix — and ask once (Rule 6a): **Apply all** / **Apply selected** / **Discuss
   first**. Nothing is applied before that answer. A diagnosis that would change a design rule in
   `DesignDoc.md` gets its own separate box. Then fix each approved **root cause**, regenerate the
   affected files, and log the issue + resolution in `ChangeLog.md` before moving on. Update
   `DesignDoc.md` whenever a rule changes.
5. **Compile and package again**, redeploy, retest. Repeat until 0 errors / 0 warnings and the
   human confirms sandbox testing is clean.

**Translations run inside this cycle** (skip if *US wording, no translation files*). Every build
that produces a new `.g.xlf`:
1. **Full build only** — Incremental Build off, no RAD publish (**Standards §8.2**).
2. **Sync** every target file from `.g.xlf`.
3. **Verify any new BC term** per **Appendix D** (`al_searchtranslations` first where the AL MCP
   Server is connected) and update the glossary. Terms already in the glossary aren't looked up
   again.
4. **Run the problem checks** and fix findings at their root. Missing translations aren't a
   finding yet.

**Once the source text is stable** — the first build the human confirms clean on the sandbox,
again before this step closes, and again after any later fix that changes source text — draft and
test each language. Drafting earlier only means redrafting whatever a caption change sends back to
`needs-adaptation`.
1. **Draft** every `needs-translation` / `needs-adaptation` unit and set it to
   `needs-review-translation`. The agent never sets `signed-off` (**§8.7**).
2. **Run every technical translation check**, missing translations included, and fix findings at
   their root.
3. **Package and test in each language** — switch **My Settings → Language** (and **Region**) and
   look for untranslated text, truncation, and wrong regional terms.

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
systemic issue outstanding; no unit in a language required at first release is
`needs-translation` or `needs-adaptation`, and translation checks are clean.

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
- **Update `DesignDoc.md` in place** to reflect the as-built reality — final object inventory, any
  naming or exception that emerged during BUILD, a short deviation summary pointing at the
  relevant `ChangeLog.md` entries. There's no separate as-built document in Lite; one file, kept
  current, is the point.
- Present this step's fixes together for one approval, as in Step 5. Any fix this step produces
  follows the Step 5 cycle (recompile, repackage, redeploy, retest) before this step closes; a
  comment/formatting-only fix doesn't need a fresh package.
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
    map to which roles, uninstall, and which users to reassign if a release renames a permission set.
- **Write `TestScript.md`** — the green-team/red-team checklist from Step 5, made concrete against
  this extension's actual endpoints, for a human tester to run end to end at Step 7. With more
  than one required language, add a **language pass**: key pages, messages, and customer-facing
  documents walked once per required language, checking for untranslated text, truncation,
  regional terms, and formats. Each case names the glossary terms the tester should see, so a
  tester who reads English can run it without a translated copy.
- **Translated documents aren't produced here.** Step 7 produces them once its functional test
  pass is green, so a fix found in testing doesn't make every translated copy stale too.

**Outputs:** `DesignDoc.md` (updated in place, glossary included), `Docs.md`, and `TestScript.md`.
Together with `ChangeLog.md` from Step 1 onward, that's Lite's four maintained documents; translated
documents follow at Step 7. Step 1's `ProblemStatement.md` and
`ProjectParameters.md` are also tracked, but written once at kickoff rather than kept current.

**Exit gate:** Every gap classified and resolved or explicitly deferred (logged in
`ChangeLog.md`); dead-code scan clean; no obsolete references; `Docs.md`'s diagram renders;
`TestScript.md` is executable by a non-developer; translation checks clean.

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
> and (d) say how to bring the agent back in — when testing surfaces something to fix, when the
> functional pass is green and translated documents are due (if Step 1 asked for any), or once
> everything passes and it's time to mark the release candidate.
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
- **Translated documents, once the functional pass is green** (if Step 1 asked for them): the
  agent produces `Docs.<culture>.md` (user-guide section) and, if chosen, `TestScript.<culture>.md`.
  It uses the glossary for every BC term and names the English source version in each file's
  header. Each is reviewed by that language's reviewer before the language pass that uses it.
- **Language passes:** for each language required at first release, a tester fluent in it runs
  the language pass, with the right Microsoft or partner language app installed in the sandbox.
- **Translation approval — the release gate** (skip if *US wording, no translation files*):
  - Each language's named reviewer approves its translations — directly in their tooling, or by
    telling the agent exactly which units they approve. The agent sets `signed-off` only on those
    units.
  - Log each approval in `ChangeLog.md`: reviewer by name, language, count, and date.
  - Then **scan every target file** for a language required at first release: every unit must be
    `signed-off` or `final` (**Standards §8.7**).
  - A fix that changes source text sends affected units back through Step 5 and review.
- Record every finding directly in `ChangeLog.md` — verbatim first, then triaged: **implement now**
  (its own entry, fixed via the Step 5 cycle), **defer** (its own entry, marked deferred, with
  reasoning — Lite doesn't keep a separate `Roadmap.md`), or **reject** (record why).
- **If a fix here changes any object, field, or behavior, treat Step 6's outputs as stale, not
  already covered** — re-run the affected parts of the review and regenerate `Docs.md`'s reference
  and diagram from the now-changed code, plus any translated document already produced from what
  changed. Say explicitly which parts a given fix actually requires re-running.
- Repeat until every green-team test passes and every red-team test fails gracefully.

**Outputs:** `ChangeLog.md` updated with every test finding and its resolution.

**Exit gate:** All green-team tests pass; all red-team tests fail gracefully; permission sets
verified; every translated document Step 1 asked for exists and has been reviewed; every required
language has passed its language pass and its state scan shows every unit `signed-off` or `final`.
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

**`outputAppPackage/*.app` is git-tracked, never gitignored.** Track every built `.app` like any
other deliverable. Downloaded symbols in `.alpackages/` are the exception: always gitignored (ALL
ALONG → Repository Hygiene). Never add a blanket `*.app` entry, which would hide built packages too.

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

The companion rules document — `ocpfALDevStandardsGuide.md`, v1.7.0.0 — shared unchanged with the
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
  at nothing. **Exception, when the OCPF plugin is installed**:
  the plugin bundles a copy of the guide in its `al-standards` skill. Use that copy instead of
  stopping. Record `"source": "ocpf-bc plugin bundle"` and the guide's version in
  `SNAPSHOT.json`, tell the human plainly which version was used, and offer a refresh from GitHub
  once the network is back.
- **Always gitignored**, never a per-project choice — same reasoning as `patterns/` (see
  Repository Hygiene). Not covered by the Step 1 `.gitignore` question, which governs only
  this framework's own files (this runbook, `LITE_RunbookChangeLog.md`, `LITE_RunbookSchematics.md`).
- **Refresh only when asked** ("refresh the standards guide"). Report "updated from `<old sha>` to
  `<new sha>`" or "already up to date."
- The guide is versioned independently of this runbook (both tracked in the framework's
  `fullVersion/RunbookChangelog.md`). If a fetched guide's version doesn't match what this
  runbook expects, say so rather than silently reconciling a citation that doesn't resolve.

## Repository Hygiene

- The Standards Guide lives **inside** the root, in `standardsGuide/`, and is always gitignored —
  added at Step 1 when it's fetched.
- The BCQuality snapshot lives **outside** the project root entirely (see below) — not a
  candidate for this project's git tracking at all.
- The OCPF Patterns library lives **inside** the root, in `patterns/`, but is always gitignored —
  it's the human's own portable, cross-project methodology, refetchable at will, not part of what
  a client is paying to receive.
- This framework's own files — this runbook, `LITE_RunbookChangeLog.md`,
  `LITE_RunbookSchematics.md`, and the plugin's `.ocpf/` folder if present — are gitignored by
  default, per the Step 1 answer; a human who wants the project's repo to be self-contained can opt to track them instead.
- **The project's own `ChangeLog.md` is always tracked**, never gitignored. It's one of Lite's four
  documents, and it carries every deviation, root cause, test finding, and translation approval.
- **If a project built on an earlier Lite version has `ChangeLog.md` in `.gitignore`, remove that
  entry and commit the file.** Earlier Lite wording said "this runbook and `ChangeLog.md`" when it
  meant the framework's changelog. Check first whether the project has a remote — the file will
  appear as newly added to collaborators.
- `*.g.xlf` is always gitignored — it's rebuilt on every compile. The per-language files in
  `Translations/` are deliverables and always tracked.
- `.alpackages/` is always gitignored, added at the end of Step 1 when symbols are first
  downloaded. Symbols are refetched in seconds (ALL ALONG → Symbols), and a sandbox download
  carries Microsoft's own source and translation files, which are never committed. Microsoft's
  AL-Go templates ignore it too.
- Microsoft's translation files, read for terminology (**Standards Appendix D**), are Microsoft's
  proprietary content and are never committed.
- If any of the above is already tracked when this policy is adopted, add the `.gitignore`
  entries and actually untrack them (`git rm --cached`, not `git rm` — files stay on disk).
  Check first whether the project has a remote already, since untracking rewrites what a `git
  pull` shows collaborators.

## AL MCP Server

**Zero-install first (Operating Rule 6d).** Needed from the end of Step 1, when the agent
downloads symbols.
- **GitHub Copilot Chat in VS Code:** the AL Language extension's tools (`al_build`, `al_publish`,
  `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`, …) are already built in, so there's
  nothing to bootstrap.
- **Claude Code, Copilot CLI, or another MCP host:** bootstrap below with the AL extension's bundled
  `altool` and VS Code's already-provisioned .NET runtime. If the server's tools (`al_compile`,
  `al_addproject`, …) are already there, don't register a duplicate; add the project with
  `al_addproject`.
- **With the OCPF plugin:** its `al-mcp-setup` skill does the bootstrap in one step.
- **Microsoft's `al` .NET tool on NuGet** is for cloud sessions and machines without VS Code only.

**The human approves; the agent does everything else**. The AL
Language extension has **no Command Palette command** that sets up or registers this server; its
only MCP commands sign in to the separate Profiling and Snapshot servers. Don't use, install, or
depend on a third-party bridge extension (such as the *AL Language Model Tools — MCP Bridge*
VSIX): it isn't on the Marketplace, and it needs VS Code relaunched with a proposed API enabled.
The human's only part is approving the AI tool's prompts, including the one Claude Code shows once
for a new project server.

**Bootstrap once per project:**
1. **Get the launcher.** Without the plugin, download these byte for byte into `scripts/` from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/al-mcp-setup/scripts/<file>`:
   `al-mcp.sh`, `al-mcp-call.sh`, and `al-analyze.sh` (macOS/Linux), or `al-mcp.cmd`,
   `al-mcp-resolve.ps1`, `al-mcp-call.ps1`, `al-analyze.cmd`, and `al-analyze-resolve.ps1`
   (Windows). Gitignore `scripts/`. The launcher finds the newest AL extension
   and its runtime on every launch, with no `PATH`, `DOTNET_ROOT`, or absolute paths. If GitHub is
   unreachable, write the equivalent: `altool launchmcpserver --transport stdio` from the AL
   extension's `bin/` folder (`altool.dll` on the runtime VS Code provisioned, on macOS/Linux).
2. **Check it:** `sh scripts/al-mcp.sh --help` (Windows: `scripts\al-mcp.cmd --help`) prints the
   usage. An `OCPF AL MCP launcher:` message names what's missing instead. If the AL extension has
   never started on this machine, ask the human to open the project folder in VS Code once.
3. **Register it** in `.mcp.json` at the project root (Claude Code and Copilot CLI), adding the
   `al` entry without overwriting other servers: `{ "mcpServers": { "al": { "command": "sh",
   "args": ["scripts/al-mcp.sh"] } } }`, or on Windows `"command": "cmd.exe", "args": ["/c",
   "scripts\\al-mcp.cmd"]`.
4. **Keep working in this session — no restart.** A server registered mid-session only appears in
   the next session. Until then, call any tool through the one-shot helper, which starts the
   server, runs one tool, prints the response, and exits in a few seconds:
   `sh scripts/al-mcp-call.sh . al_downloadsymbols '{"globalSourcesOnly":true}'` (Windows:
   `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\al-mcp-call.ps1 . <tool> '<JSON>'`).
5. **Verify** with a non-compile call such as `al_getpackagedependencies` — not a project compile.

Prefer the server's build/publish/symbol tools over an ad hoc terminal invocation — **except for
the analysis compile itself (ALL ALONG → Analyzers): its `codeAnalyzers` argument doesn't reliably
work.**

## Analyzers

**The mandatory Step 5 compile runs with Microsoft's bundled code analyzers engaged — not a plain
compile.** They ship with the AL Language extension; nothing is installed. Every project runs
**CodeCop** and **UICop**, plus exactly one of these, by Deployment Target:

| Deployment Target | Third analyzer |
|---|---|
| `SaaS PTE` or `OnPrem PTE` | **PerTenantExtensionCop** |
| `AppSource` | **AppSourceCop** |

- **Never both PerTenantExtensionCop and AppSourceCop** — Microsoft documents them as incompatible.
- **AppSourceCop needs `AppSourceCop.json`** in the project root — at minimum
  `{ "mandatoryAffixes": ["<prefix>"] }` — or the compile fails with `AS0054`.
- **Both files are created at Step 3's scaffold:** `.vscode/settings.json` with
  `"al.enableCodeAnalysis": true` and `"al.codeAnalyzers"` set to the three analyzers, and
  `AppSourceCop.json` for AppSource. The settings also give the human live feedback in the editor.

**What the compile then proves:** `PTE0004` / `AS0103` (missing permission set, **Standards
§5.3**), `PTE0008` / `AS0062` (missing `ApplicationArea`), `AA0074` (label suffix), `AA0215` (file
name, **§1.8**), and `AL0424` (ML syntax, **§1.7**). It doesn't replace symbol verification or
App Code uniqueness across extensions (**§5.4**).

**How to run it** (verified on AL Language extension 18.0.2732683; on a newer release, compile a
table with no permission set and confirm `PTE0004` appears):
- **GitHub Copilot Chat in VS Code:** the built-in `al_build`, which reads the settings above.
- **Claude Code, Copilot CLI, or any other MCP host: not the AL MCP Server's
  `al_build`/`al_compile`** — they don't apply analyzers by argument, launch flag, or settings.
  Run `scripts/al-analyze.sh <project folder> <output .app path> [pte|appsource]` (Windows:
  `scripts\al-analyze.cmd`, same arguments; defaults to `pte`). The plugin copies it into
  `scripts/`; otherwise, or if it's missing, fetch it beside the launcher (ALL ALONG → AL MCP
  Server, step 1).
- **Read the warnings, not just the result.** The compiler and `al_build` succeed with warnings.
  `al-analyze` exits `0` only with no errors and no warnings, `3` with warnings, `1` on failure.
  Any warning fails Rule 5.

**Zero warnings means zero.** No `#pragma warning disable` and no ruleset: every analyzer rule stays
on, and a project that follows the Standards Guide compiles clean under them.

## Symbols

**The agent downloads symbols; the human never does** (Rule 6d). Stop at the first option that
works:
1. **Copilot Chat in VS Code:** the AL extension's `al_downloadsymbols` with
   `globalSourcesOnly: true`. It also reloads VS Code's AL workspace.
2. **Any other agent:** the AL MCP Server's `al_downloadsymbols` with `globalSourcesOnly: true`,
   through the one-shot helper if the server isn't in this session yet.
3. **From the sandbox** (`launch.json`, one browser sign-in by the human): when the project
   depends on a non-AppSource app, when the global download fails, or for a localized project
   outside Copilot Chat.

Global sources need no connection or sign-in (verified September 15, 2026, AL extension 18.0: a
full BC 27 set in under 10 seconds). **The AL MCP Server's global download is W1 only.** It
ignores `al.symbolsCountryRegion`, which VS Code's own download honors. For `Localization` ≠
`W1`: in Copilot Chat, set `"al.symbolsCountryRegion"` (e.g. `"us"`) in `.vscode/settings.json`
first. Elsewhere, start DESIGN on W1 and download from the sandbox before verifying any
country-specific table or field.

**Confirm symbols by using them** (`al_symbolsearch` for `Customer`, or a compile), never by
unpacking a package's `SymbolReference.json`, which can look far emptier than what the compiler
resolves. Download again after a dependency or version change, then keep the editor in sync.

## Keeping the Editor in Sync

**Symptom:** the code compiles clean, but VS Code still marks objects red, often with an object ID
"not within the allowed ranges" or a missing symbol, until the window reloads. The editor's AL
language server is working from old information:
- **`app.json` changed on disk** after the AL extension loaded it. The extension doesn't always
  re-read it ([microsoft/vscode#147111](https://github.com/microsoft/vscode/issues/147111)). The
  real case: **AL: Go!** created default ranges, then the agent wrote the project's ranges.
- **Symbols downloaded outside VS Code.** The AL MCP Server reloads only its own workspace.

**Prevent:** write `app.json` once, complete, and download symbols at the end of Step 1, before
any `.al` file exists. In Copilot Chat, download symbols with the AL extension's own tool.

**Detect** after every `app.json` or symbol change and every clean compile: read the Problems
panel with `al_getdiagnostics` (Copilot Chat) or the IDE `getDiagnostics` tool
(`mcp__ide__getDiagnostics`, Claude Code in VS Code). AL errors the latest compile didn't report
are stale. If you can't read the editor, tell the human once, at the first clean compile, what
stale marks look like and the fix. At the end of Step 1 there are no `.al` files yet, so if
`app.json` existed before you changed it, treat the editor as stale.

**Fix:**
1. **Copilot Chat:** run the AL extension's `al_downloadsymbols` once, then check again.
2. **Otherwise, or if marks remain:** no agent tool can reload VS Code's window. At the end of
   the reply, never mid-task, tell the human in one short message, in the working language: the
   code compiles clean and VS Code is showing old errors; press Ctrl+Shift+P (Cmd+Shift+P on a
   Mac) and run **Developer: Reload Window** (built into VS Code); files aren't touched, and if
   the chat panel closes, reopen it and continue from its history.

Never change code that compiles clean just to clear stale marks.

## Reference Sources — Microsoft Learn and AL Guidelines

Consulted online, never fetched into the project, so there's nothing to bootstrap, gitignore, or
refresh. If there's no web access, say so rather than answering from memory of what a reference
says.

| Reference | What it's for | Used at |
|---|---|---|
| **BC Base Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application> | Standard Base App tables, fields, datatypes/sizes | Operating Rule 2 fallback |
| **BC System Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application> | System Application modules — check before building what the platform already provides | Operating Rule 2 fallback; Step 2 |
| **Working with translation files** — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files> | XLIFF translation in AL; why ML properties are banned | Standards §1.7, Part 8 |
| **Country/Regional Availability and Supported Languages** — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations> | Which languages BC supports in each country, and who translates them — read live every time | Step 1; Standards §8.8 |
| **Microsoft Terminology** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-terminology> and **Localization Style Guides** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides> | Terminology fallback and per-language style, when BC's own translations have no match | Standards §8.5, Appendix D |
| **AL Guidelines** — <https://alguidelines.dev> (<https://github.com/microsoft/alguidelines>, MIT) | AL best practices, design patterns, agent-oriented *Vibe Coding Rules* | Step 2 (patterns); Step 6 (review) |

**Precedence:** the downloaded symbol file beats Microsoft Learn on anything symbol-verifiable; the
Standards Guide beats AL Guidelines on any AL rule. AL Guidelines' legacy *C/AL Coding
Guidelines* pages are never followed (Standards §1.7).

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
- It lives outside the project root, so there's nothing to gitignore (Repository Hygiene above).

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

## Translations & Terminology

The rules are **Standards Part 8**; Lite applies them with the same gates as the full framework,
just fewer documents. Skip everything here if Step 1 chose *US wording, no translation files*.

- **The glossary lives in `DesignDoc.md`** and is filled only by **Standards Appendix D** — never
  from model memory. Update it whenever a new BC term appears in source text.
- **The agent drafts, a named person approves.** Drafts are `needs-review-translation`. Only the
  language's reviewer approves (`signed-off`) — directly, or by naming exactly which units the
  agent should mark. Every approval is logged in `ChangeLog.md` by name.
- **Bulk approval with a named scope is fine.** For a same-language file (`en-US` → `en-US`), the
  agent may list unchanged units containing no glossary term for one approval decision.
- **The release gate is a plain state scan.** Every unit in every language required at first
  release is `signed-off` or `final` (**Standards §8.7**).
- **Changed source text invalidates approval** (**§8.7**): the unit goes back through drafting and
  review.
- Microsoft's translation files are read, never committed. XLIFF Sync and NAB AL Tools are
  credited in the framework's `THIRD_PARTY_NOTICES.md`.

## Permission Sets

- **Required the moment this project owns one table** (**Standards §5.3**).
- **Coverage is verified at the pre-flight checks in Steps 3 and 4**, so a gap doesn't wait for the
  compile. Step 6 relies on the last 0/0 compile, after confirming it ran with the analyzers and
  nothing was suppressed (ALL ALONG → Analyzers).
- **Named for this extension, not just the prefix:** `<PREFIX> <APPCODE>, VIEW` and
  `<PREFIX> <APPCODE>, EDIT`, 20 characters or fewer (**Standards §5.4**).

## OCPF Plugin (Optional)

This framework is also distributed as an agent plugin,
`ocpf-bc`, from the same repository. It works in Claude Code, the Claude apps, GitHub Copilot, and
Microsoft Copilot Cowork. It's optional: copying this runbook in by hand still works exactly as
before.

**This section applies only when `.ocpf/framework.json` exists in the project root.** The plugin's
`start` skill creates it. It records the edition, the runbook version, where the runbook copies
were placed (`placedAs`), the source commit, the plugin version, a version the human chose to
skip (`declinedUpdateVersion`), and the AL MCP Server outcome (`alMcp`). The `.ocpf/` folder
follows the Step 1 framework-files answer.

**Framework update check, once per session.** At the start of each session, before resuming work:
1. Read `runbookVersion` and `declinedUpdateVersion` from `.ocpf/framework.json`.
2. Read the `**Version:**` line of
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_BC_App_Build_Routine_Agent.md`
   (download it; don't summarize it).
3. Compare versions numerically, part by part.
   - **Latest is newer and isn't the skipped version:** tell the human in a sentence or two and
     offer **Update now / Not now / Skip this version** through the options mechanism. "Update
     now" follows the plugin's `update-framework` skill: summarize the changelog entries in
     between, back up each current copy to `.ocpf/previous/`, replace every copy in `placedAs`
     and the project's `LITE_RunbookChangeLog.md`, update the marker, log it in `ChangeLog.md`,
     and re-read the runbook.
   - **Current:** say nothing.
   - **GitHub unreachable:** mention it in one line and carry on.

Never replace the project's runbook without an explicit yes.

**What else the plugin changes:**
- **Standards Guide:** a bundled fallback copy (ALL ALONG → OCPF AL Development Standards Guide).
- **AL MCP Server:** the plugin's `al-mcp-setup` skill connects the AL tools with nothing to install
  (ALL ALONG → AL MCP Server).
- **Other skills:** `status` and `al-standards`.
- **Sub-agents:** the plugin's `ocpf-reasoning` and `ocpf-light` sub-agents are for the full
  framework's role split. Lite doesn't use them: one model still does everything.

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
editions fetch the same v1.7.0.0 file and apply the same AL rules — Lite differs only in process.

**Document count:** 4 maintained documents (`DesignDoc.md`, `ChangeLog.md`, `Docs.md`,
`TestScript.md`), plus Step 1's two kickoff artifacts (`ProblemStatement.md`,
`ProjectParameters.md`), versus the full framework's 20 (`ProblemStatement`, `ProjectParameters`, `FRD`, `TDD`,
`SanityCheck`, `ChangeLog`, `ProjectMemory`, `ProjectProgress`, `GapAnalysis`, `CodeReview`,
`PostDevTDD`, `Documentation`, `UserGuide`, `HumanUnitTestScript`, `Deployment`,
`AutomatedTestScripts`, `ReleaseTestResults`, `TestingFeedback`, `Roadmap`,
`TranslationGlossary`). Lite keeps its translation glossary inside `DesignDoc.md`; translated copies
of `Docs.md` and `TestScript.md` don't count as separate documents.

---

*Lite Edition derived from the OCPF BC Agentic Development Framework, created by AJ Ansari,
Microsoft MVP, OnlyCopilotFans. Update this runbook when the full framework changes in a way that
should flow down to Lite.*
