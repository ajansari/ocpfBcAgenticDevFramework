# BC App Build Routine — STEP 1 — Define the Problem & Lock Parameters

**Runbook version:** 5.1.0.0 · Lite edition · Phase: DEFINE

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**
- **Ask the working language first — before anything else** (Operating Rule 8). Ask in English,
  through the options mechanism, with English listed first and free text for any other language.
  It's asked alone, so every later box can be in the language chosen. Continue in the language
  chosen.
- **Fetch both companion guides first, before anything else needs them.** Get
  `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md` into `ocpfFramework/standardsGuide/` and
  `ocpfFramework/opsGuide/ocpfOperationsGuide.md` into `ocpfFramework/opsGuide/`, from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/`, and **add both folders to
  `.gitignore`** — see ALL ALONG → OCPF AL Development Standards Guide. **In the same fetch, get
  this runbook's step files** (`liteVersion/steps/*.md`) into `ocpfFramework/runbookSteps/` and the document
  templates (`ocpfFramework/documentTemplates/*.md`) into `ocpfFramework/documentTemplates/`, both always gitignored — each from
  its raw URL, `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/<folder>/<file>`
  (Ops § Fetched Companions has the list). Everything the framework fetches or keeps lives under
  `ocpfFramework/` — create the folder with its six-line `README.md` now (Ops § Project Setup gives
  the text). The gap check below leans on Standards Part 6, and this step's notification and
  intake procedures are Ops §, so neither can wait for Step 3 the way the other fetched libraries
  do. Tell the human you're doing it.
- **Ask how to be notified, right after the working language** (Ops § Notifications — read it now): Claude app, sound,
  desktop notification, any combination, or none. Record it in `ocpfFramework/state/notifications.json` and
  apply it, so every later question reaches the human even when they've stepped away.
- **Ask which model does the work, right after notifications** (Rule 6a; **Ops § Roles — read
  it now**). Say once, before the questions: *"A High thinking effort makes every task slower: the
  model thinks longer before each answer, and a step can take noticeably more time. The framework
  recommends High only where judgment matters most."* Two questions in one box, the recommended
  pair first and free-text entry for anything else: **Main model** and **Main thinking effort** —
  in Claude Code *Sonnet, Medium — recommended*; in GitHub Copilot *Gemini 3.8 Flash, Medium —
  recommended* (the picker's names; if a name isn't in the picker on the day, offer the nearest and
  say so) — then *High* and *Low*. Say which model this session is running on before asking: in Lite the one
  model *is* this session, and only the human can change it (`/model` and `/effort` in Claude Code;
  the model picker in Copilot). If they choose something other than what's running, ask them to
  switch now and confirm before continuing — never record a model that isn't the one doing the
  work. The answer goes in the Project Parameters below. Asked here, not in the intake boxes, so
  it's settled before the first document is drafted. In a plugin project the plugin's `roles` skill
  (`/ocpf-bc:roles`) asks and records it.
- **If GitHub Copilot is one of the AI tools on this project, ask the two Copilot session-settings
  questions now** (Rule 6a; **Ops § Asking and Approvals → *GitHub Copilot session settings***):
  the agent-mode request limit (*150 — recommended* / *100* / *leave the default*) and tool
  approvals (*Ask each time* / *Allow the framework's own commands* / *Allow everything*, with its
  warning). Write the answers to `.vscode/settings.json` and record them in `ocpfFramework/state/copilot.json`.
- **Create the `docs/` folder now, with its phase folders** `0-project/`, `1-define/`,
  `2-design/`, `3-build/`, `4-prove/` — the same five as Full; Lite writes nothing into `3-build/`, but the layout is one layout — every document from here on is written
  there (see the header note). **In the same moment create `ProjectProgress.md` in the project
  root** — never `docs/` — from `ocpfFramework/documentTemplates/ProjectProgress.md`: keep the
  *Lite* step table (STEP-1 … STEP-7), delete the *Full* one, every row blank except this one,
  marked `In Progress`; the usage table beneath it starts empty (ALL ALONG → Project Progress
  Tracker).
- **Start the usage clock:** append Step 1's `startedAt` to `ocpfFramework/state/usage.json` the
  moment `ProjectProgress.md` is created (Operating Rule 9; Ops § Usage & Cost). At this step's
  close the same rule writes Step 1's usage rows, one per model, into the second table.
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
- **Populate the Project Parameters block below, and persist it as `docs/1-define/ProjectParameters.md`.** Complete every field; replace every placeholder. These values override all
  defaults for the rest of the routine, and every later step reads them from that file rather than
  from conversation history.

**Ask first, don't infer — and ask interactively** (Rule 6a). **How to ask — the boxes, what to
offer for each question, and the language questions — is Ops § Intake. Read it before the first
box.** In short: every question goes through the options mechanism, grouped into as few boxes as the
questions allow (identity, naming, permission sets and IDs, onboarding, setup and languages, then
the translation questions); countries are asked once; a suggestion is a candidate the human picks,
never an answer recorded for them; and the whole sheet is confirmed once at the end. Box 1a carries
question **4a. App icon?** (the *App icon* row below). Lite asks only the Main model and effort —
already asked above, right after notifications — not the full framework's Light and Reasoning
questions.

**The Permission Set App Code question exists because** permission sets named from the prefix alone
(`OCPF - READ`) collided across every extension with that prefix (**Standards §5.4**).

**Tell the human where their built packages will land:** always `outputAppPackage/` in the project
root, one file per build — the first build of a new app at `0.0.0.1`, the Revision incremented before every build after it (ALL ALONG →
Packaging & Versioning). Mention it once, plainly, now.

### Project Parameters

| Parameter | Placeholder | Guidance |
|---|---|---|
| **Extension Name** | `<ExtensionName>` | No AL quotes. → `app.json "name"`. |
| **Publisher** | `<Publisher>` | No AL quotes. → `app.json "publisher"`. |
| **Deployment Target** | `<DeploymentTarget>` | One of: `AppSource`, `SaaS PTE`, `OnPrem PTE`. **`AppSource` adds a block of mandatory `app.json` parameters and narrows the ID range** — read **Ops § Intake → *The AppSource questions*** before Box 3, and **Standards Appendix E**. |
| **AppSource manifest set** *(only if Deployment Target = `AppSource`)* | — | `brief`, `description`, `url`, `logo`, `privacyStatement`, `EULA`, `help`, `contextSensitiveHelpUrl`, and `applicationInsightsConnectionString` where given. Each is **mandatory for submission** — a missing one is a rejected submission, not a warning. `name`, `publisher`, and `version` must match the Partner Center offer exactly. Anything deferred is recorded as a release blocker. |
| **Version** | `<Version>` | → `app.json "version"`. New app: **`0.0.0.1`** (default, offered first). Existing app: the version installed in the target environment — asked here, confirmed by the human on the Extension Management page — and continued from. A new app's first build goes out at `0.0.0.1` as written, an existing app's first build increments from the installed version, and every build after the first increments the Revision mechanically; Major, Minor, and Build bumps are proposed and approved; the release candidate `1.0.0.0` is asked at the end of Step 6 (ALL ALONG → Packaging & Versioning). |
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
| **App icon** | `Yes — I'll provide an image` / `No icon` / `Later` | Box 1a, question 4a (Ops § Intake). *Later* is a release blocker for AppSource — the old AppSource icon question is folded in here. On *Yes*, ask for the path as free text with the guidance *"PNG, square, 300 × 300 px is ideal — Microsoft accepts 216 to 350 px for the marketplace listing. Larger is fine; I'll resize it, keeping the proportions, never stretching."* The agent copies it to `src/logo/AppLogo.png`, resizing when larger with what the machine has — macOS `sips -Z 300 <in> --out src/logo/AppLogo.png`; Windows a PowerShell `System.Drawing` snippet (Ops § Intake gives it); Linux `convert <in> -resize 300x300 src/logo/AppLogo.png` if ImageMagick is present, else Python Pillow, else ask the human to resize. A non-square image gets its longer side resized to 300 and is padded to square with transparency, never cropped silently — say what was done. `app.json` gets `"logo": "src/logo/AppLogo.png"`; the file is committed. |
| **Framework files in `.gitignore`?** | `Yes` (default) | Box 5, asked as: *"`.gitignore` lists files Git leaves out of commits and pushes — they stay on disk and work normally. Should this framework's own files be left out of this project's repository?"* With `Yes`, the second block of Ops § Repository Hygiene goes into `.gitignore` — by name, every one, not "the framework files" in the agent's head: `ocpfFramework/` as a whole (it holds `LITE_RunbookChangeLog.md`, `LITE_RunbookSchematics.md`, `framework.json`, and the runbook itself when `CLAUDE.md` already existed), the runbook under whatever name it was given (`CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/ocpf-framework.instructions.md` — only the ones that exist), and the project-local sub-agent definitions (`.claude/agents/ocpf-light.md`, `ocpf-reasoning.md`, `ocpf-generator.md`; `.github/agents/ocpf-light.agent.md`, `ocpf-reasoning.agent.md`, `ocpf-generator.agent.md`). The first block — `.claude/settings.local.json`, `ocpfFramework/state/`, `ocpfFramework/standardsGuide/`, `opsGuide/`, `runbookSteps/`, `documentTemplates/`, `patterns/`, `scripts/`, `.alpackages/`, `*.g.xlf` — is written whatever the answer. **Then prove it:** `git check-ignore -v <file>` on each file that exists, and `git status --porcelain` on the root; a framework file still showing means the entry is wrong. On a real project the changelog was left out and shipped to the client's remote. **Never `docs/`, `requirements/`, `src/`, `ProjectProgress.md`, `outputAppPackage/`, `*.app`, or `Translations/*.xlf`** — `docs/0-project/ChangeLog.md` is always committed. The full block is Ops § Repository Hygiene. |
| **Working language** | — | From the first question of this step. |
| **Main model & thinking effort** | `<MainModel>` / `<MainEffort>` | Asked right after notifications (Ops § Roles): the model this one agent runs on and its thinking effort — recommended **Sonnet, Medium** in Claude Code, **Gemini 3.8 Flash, Medium** in GitHub Copilot; High only where judgment matters most. Recorded as the human named them, plus the harness's own identifier (e.g. `sonnet`). Must match what the session is actually running — the human switches the session, not the agent. The generator sub-agent Step 4 may use inherits this pair. Lite has no Light or Reasoning rows. |
| **Target languages** | table | Box 5, for the countries from Box 1 — Lite groups the setup and language questions together (Ops § Intake) — never asked again (rules: **Standards §8.8**). Classify each chosen language as Microsoft-translated, partner-translated (ask which partner app, in the next box — it's the terminology source), or not supported by BC (every right-to-left language included). Don't offer an unsupported language; if typed, offer the country's English instead, and only record it if the human insists. Then, unless source wording is *US wording, no translation files*, per language, two questions: *Required at first release* / *Can follow later*; and who reviews it — names the human mentioned, or *I'll type it*; a named fluent person, never the agent. Flag any mismatch with **Localization**. |
| **Source language** | `en-US` (default) | Offer `en-US` first, labelled recommended, with the one-line reasons in **Standards §8.1**. If the human chooses another, state the consequences before recording it. |
| **Source wording** | `W1` | Microsoft's W1 English wording in source, with one translation file per target language (`en-US` included). Only when `en-US` is the **sole** target **and Deployment Target isn't `AppSource`** (AppSource requires translation files — **Standards §8.10**), also offer *US wording in source, no translation files* — simpler now, but another market later means changing source strings. |
| **Documents in other languages** | per document | Only with a target language other than the source. Two questions: translate `docs/4-prove/Docs.md`'s user-guide section into each required language (*Yes (recommended)* / *No*); and does `docs/4-prove/TestScript.md` need a translated copy (*No — testers run the language pass from the English script, which names the terms they should see (recommended when testers read English)* / *Yes*)? `docs/2-design/DesignDoc.md` and `docs/0-project/ChangeLog.md` stay English. Translated documents are produced at Step 7, once the functional test pass is green. |
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
1. **Write `app.json` once, complete,** from the sheet, keeping an existing `id` GUID — `version`
   from the Version row, `"logo": "src/logo/AppLogo.png"` when an icon was given.
2. **Create `src/`** — every AL file goes there (subfolders per module are fine), never in the
   project root; the app icon, if any, at `src/logo/AppLogo.png`.
3. **Connect the AL tools** if this session doesn't have them (ALL ALONG → AL MCP Server).
4. **Download symbols**, record the Symbol Source, and gitignore `.alpackages/` (ALL ALONG →
   Symbols).
5. **Keep the editor in sync** (ALL ALONG → Keeping the Editor in Sync).

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

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, end the closing message with the options box: **Proceed into Step 2 now — closes DEFINE, opens DESIGN (recommended)** / **Stop here** (say what there is to review and how to resume). Nothing of Step 2 starts until the human answers.
