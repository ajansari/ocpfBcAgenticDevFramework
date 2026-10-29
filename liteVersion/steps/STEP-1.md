# BC App Build Routine — STEP 1 — Define the Problem & Lock Parameters

**Runbook version:** 5.10.0.0 · Lite edition · Phase: DEFINE

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**

Since 5.10.0.0 this step runs in five movements (Ops § Asking and Approvals → *The kickoff*; Ops §
Intake → *The kickoff boxes* — **read both before the first box**): the clock, the kickoff (every
setup question back to back), the setup batch (all the work, once), the setup-done box, and only
then the requirements, the problem statement, and the few sheet questions that need them. Nothing
the human waits for happens between two kickoff boxes.

**0. Open the clock — the very first act of the routine** (Operating Rule 9; Ops § Usage & Cost →
1 and 8): create `ocpfFramework/state/usage.json` (`aiTool`, `transcriptDir`, empty `steps`) and
append `{ "step": "STEP-1", "startedAt": "<now>" }`. A window opened after the setup questions left
the session's first decisions and tokens outside every window on real projects.

**1. Before the first box — one read, one batch, one line said.** In a single batch: the
companions when the project has none yet — `ocpfFramework/` with its six-line `README.md` (Ops §
Project Setup gives the text), the Standards Guide into `ocpfFramework/standardsGuide/`, the
Operations Guide into `ocpfFramework/opsGuide/`, this runbook's step files (`liteVersion/steps/*.md`)
into `ocpfFramework/runbookSteps/`, and the document templates into
`ocpfFramework/documentTemplates/`, each from its raw URL
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/<folder>/<file>` (Ops §
Fetched Companions; in a plugin project the `start` skill already fetched them — check, don't
refetch; the always-ignored `.gitignore` group goes in now — see ALL ALONG → OCPF AL Development
Standards Guide); Microsoft's live *Country/Regional Availability and Supported Languages* page and
the *Choose runtime version* table (Ops § Reference Sources — every country, language, and BC
version offered comes from them, never from memory); what is on disk — `app.json`, `src/`,
`images/`, whether `requirements/` holds anything (its content is read in movement 4); and the Ops
sections the boxes cite: § Intake, § Notifications 1, § Roles → *Asking*, § Asking and Approvals.
Then one line: *"Reading the guides and two Microsoft pages, then I'll ask everything I need in one
go — about N boxes."* Tell the human what was fetched.

**2. The kickoff — the boxes, back to back** (Rule 6a, Rule 6f; the options for every question are
Ops § Intake's sheet, the order Ops § Intake → *The kickoff boxes*). Between boxes, **write each
answer as it arrives into `docs/1-define/ProjectParameters.md`** — the Project Parameters block
below, created from the first box on with placeholders for the rows not yet answered, the
publisher's and the ID range's source noted in their rows (*publisherSource*, *idRangesSource*:
the box and the date — Ops § Intake → *Forbidden sources*) — and nothing else. That file is the
record the `roles` and `notifications` skills read in their apply-only mode, and what a resumed
intake (Rule 6e) resumes from: an answer not in it is not an answer. Already-answered questions
are skipped, never re-asked.
- **K1 — Working language**, alone, in English, English first, free text for any other language
  (Operating Rule 8). Every later box is in the language chosen.
- **K2 — Notifications** (Ops § Notifications → 1): the channels — Claude app, sound, desktop
  notification, any combination, or none; in Claude Code the *Claude app* option is offered unless
  a disqualifier is positively found, never dropped for a sign-in that can't be checked, a fresh
  install, an unpaired phone, or Windows — and, in the same box, **Remote Control** (*Only when I
  turn it on* / *Every Claude Code session on this machine*), explained in the question's text and
  worded so it only matters when *Claude app* was chosen. Applied and tested in the batch.
- **K3 — Identity and target** (Ops § Intake → *Box 0*): **Extension name?** (suggestions from the
  human's own wording + *I'll type it*); **Publisher?** (only a name they already wrote, with its
  source, else *I'll type it*; never inferred from an email domain, git config, a folder name, or
  another project — Ops § Intake → *Forbidden sources*; the source is recorded with the answer);
  **App icon?** (when `images/` holds an image, *Use `images/<file>`* first; then *Yes — I'll
  provide an image* / *Create one for me* / *No icon*, *Later* via the free-text entry);
  **Deployment Target?** (*SaaS PTE* / *OnPrem PTE* / *AppSource* — what AppSource changes said in
  the box's text). **K3a, as the next box when needed:** the icon's path as free text with Ops §
  Intake → *The app icon*'s guidance (placed and resized in the batch); on *Create one for me*, the
  `app-icon` skill's one box — style, colors, content, description — drawn in the batch, accepted
  in the setup-done box.
- **K4 — Countries and app:** which countries the users work in (multi-select, from the page read
  in movement 1; asked only here); **new or existing app** (4b) when `app.json` already existed —
  an existing app's version is the one installed in the target environment, confirmed on its
  Extension Management page; and **a Business Central Copilot feature?** (*No* / *Yes*, specifics
  as free text).
- **K5 — Model** (Ops § Roles — the warning *"A High thinking effort makes every task slower: the
  model thinks longer before each answer, and a step can take noticeably more time. The framework
  recommends High only where judgment matters most."* and the model this session is running on,
  both in the box's own text): **Main model** and **Main thinking effort** — in Claude Code
  *Sonnet, Medium — recommended*; in GitHub Copilot *Claude Sonnet 5.5, Medium — recommended* and
  *GPT-6.1 Sol, Medium — recommended*, the Claude model first (the picker's names; if a name isn't
  in the picker on the day, offer the nearest and say so) — then *High* and *Low*. **When GitHub
  Copilot is one of the AI tools**, the same box carries the two Copilot session-settings questions
  (Ops § Asking and Approvals → *GitHub Copilot session settings*): the agent-mode request limit
  (*150 — recommended* / *100* / *leave the default*) and tool approvals (*Ask each time* / *Allow
  the framework's own commands* / *Allow everything*, with its warning). A Main model or effort
  other than the session's is switched by the human (`/model`, `/effort`; the picker in Copilot)
  and confirmed in the setup-done box — never record a model that isn't the one doing the work.
- **K7 — Naming** (Box 2): AL object prefix; namespace; Localization; Business Central version
  (the current major and the one before, from the page read in movement 1).
- **K8 — Permission sets and IDs** (Box 3): Permission Set App Code; other extensions using this
  prefix; object ID range (*50100–50149* only as the AL template's default, never first — Ops §
  Intake → *Forbidden sources*; for AppSource the registered bands); another range? — each *Yes*
  and each collision opens the follow-up as the next box.
- **K9 — AppSource** (only when K3 said AppSource; Boxes 3a and 3b): `url`, `privacyStatement`,
  `EULA`, `contextSensitiveHelpUrl`, then `applicationInsightsConnectionString`.
- **K10 to K12 — Languages** (Ops § Intake → *The language questions*): per country, the languages
  BC supports there (multi-select, up to four countries per box); then the source language and the
  source wording; then, only when a target language other than the source exists, whether
  `docs/4-prove/Docs.md`'s user-guide section is translated and whether testers need a translated
  test script, and, per such language, required at first release and who reviews it, two languages
  per box, a partner-translated language's app question beside them.
- **K13 — Working setup:** framework files in `.gitignore`? (the question's text explains
  `.gitignore`); customer-language documents? translatable data?
- **K14 — Requirements and existing app, always the last box:** when `requirements/` is empty and
  the human pasted or attached nothing, **Where are the requirements?** — *I'll put them in
  `requirements/` now (recommended — `.md` preferred; Word, PDF, and images are read too)* / *I'll
  paste them in chat* / *They're in a file or folder elsewhere — I'll type the path* / *I'll
  describe the need when you ask*; and, when `src/` already holds real objects beyond the AL
  template's `HelloWorld.al` and `requirements/existing/` is empty, **Run the in-depth analysis
  and documentation first (recommended when the app has no design doc or docs — 10 to 30 minutes)**
  / *Skip — the light read is enough* (Ops § Existing Apps). On *I'll paste them in chat*, end the
  turn asking for the paste; the batch starts when it arrives (or, when the human says to go on,
  runs now and captures the paste when it comes).

**3. The setup batch — one message, no question** (Ops § Intake → *The kickoff boxes* → *After the
last kickoff box*; Ops § Project Setup). In this order: the repository (`git rev-parse
--is-inside-work-tree`, else `git init -b main`, said in one line — Ops § Repository Hygiene);
`src/` and **`app.json` written complete** — `name`, `publisher`, `logo` when an icon was given, a
new or kept `id`, `version` `0.0.0.1` or the installed version from 4b, every ID range, `platform`,
`application`, `runtime` from the table read in movement 1, the `features`, `target`, and the
AppSource block when K9 was asked (`brief`, `description`, and `help` come later, from Box 4D); the
icon placed and resized, or drawn by the `app-icon` skill (Ops § Intake → *The app icon*); the
notifications recorded in `ocpfFramework/state/notifications.json`, applied, and each hook's exact
command run once (Ops § Notifications 2, 3, 5; the plugin's `notifications` skill in apply-only
mode); the Copilot answers written to `.vscode/settings.json` and `ocpfFramework/state/copilot.json`;
the **generator and reviewer sub-agent definitions** on the Main model and effort (Ops § Roles →
*Enforcement*; the plugin's `roles` skill in apply-only mode); `docs/` with its phase folders
`0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/` — the same five as Full; Lite writes
nothing into `3-build/` — and **`ProjectProgress.md` in the project root**, never `docs/`, from
`ocpfFramework/documentTemplates/ProjectProgress.md`: the *Lite* step table (STEP-1 … STEP-7)
kept, the *Full* one deleted, every row blank except this one, `In Progress`, the usage table
beneath it empty (ALL ALONG → Project Progress Tracker); the `.gitignore` blocks from K13's answer,
proven with `git check-ignore` (ALL ALONG → Repository Hygiene — `ProjectDashboard.html`,
`requirements/`, and `docs/` must not be ignored); **the live dashboard** — the renderer and
template into `ocpfFramework/scripts/`, `ProjectDashboard.html` rendered at the project root,
opened once (`--open`), the refresh hooks installed with the interpreter the runner ladder found
and proven — the Stop hook's exact command run once, the sidecar newer and carrying the app's name
and the edition (Ops § Dashboard → 3; the plugin's `dashboard` skill); the AL tools connected (ALL
ALONG → AL MCP Server; the plugin's `al-mcp-setup` skill); the symbols downloaded and the Symbol
Source recorded (ALL ALONG → Symbols — a failure is diagnosed and its options box held for the
setup-done box, never switched unasked); the editor synced; and **any raw requirements captured
verbatim** — text pasted in chat as its own Markdown file in `requirements/` (a descriptive name,
a header naming who provided it and when, the text untouched; a same-named capture gets a date
suffix, never overwritten), an uploaded or pointed-at file copied unmodified under its own name;
`requirements/` is a tracked project folder, never ignored, and the same capture applies the
moment any later requirements or change-request input arrives. The batch's closing message says,
once, that packages land in `outputAppPackage/`, one file per build, each with its own version.

**4. The setup-done box** — one box: the dashboard explanation, **I understand** / *Other*, with
Ops § Dashboard's text (what, why, how, the file and where it is, and reopening with right-click →
**Open Externally** or *Reveal* + double-click); whether each chosen notification kind arrived and
clicking one opened the session; **Accept this icon** / *Make another* when one was drawn; the Main
model switch confirmed when it differs from the session's; and *Are the requirements in
`requirements/` now?* when K14 said so. Act on a free-text answer before continuing. A failed
symbol download's options box follows (Ops § Symbols).

**5. Now the requirements.** On *Run the in-depth analysis*, run the plugin's `analyze` skill
(`/ocpf-bc:analyze`; without the plugin, the Ops § Existing Apps procedure), then read
`requirements/existing/` with the rest of `requirements/` as *what the app already is*. Read
`requirements/` in full (`.md` recommended; Word, PDF, and images read too). Questions from here on
may follow work — that is expected; the kickoff is over.
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

**Most of the block was asked in the kickoff above** (Ops § Intake → *The kickoff boxes*): the
identity, Deployment Target, countries, model, naming, permission set code, ID ranges, AppSource
URLs, languages, and `.gitignore` answers are **recorded, never asked again**, and `app.json` was
written complete in the setup batch. **What is still asked, now that the problem statement
exists** (Rule 6a; Ops § Intake): Box 4 — the onboarding extras; question 16 — permission sets
required, only when the entity list has no new table; and Box 4D — the short description, the long
description, and the Help URL, one box each with the agent's own suggestion ready first (Ops §
Intake → *The description and help questions*). Then the whole sheet is shown and confirmed once.
A suggestion is a candidate the human picks, never an answer recorded for them.

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
| **Short description** | `<Brief>` | Box 4D, question D1 → `app.json "brief"`. **Every Deployment Target.** One line, about 100 characters at most: what the app does, for whom. The agent writes its own candidate from the problem statement **before the box opens** and offers it as the first option, quoted in full; a change is typed in the free-text entry (Ops § Intake → *The description and help questions*). `AppSource`: mandatory, must match the Partner Center offer word for word. PTE: *Left out* is a valid record — then `app.json` has no `brief`. Recorded with its source. |
| **Long description** | `<Description>` | Box 4D, question D2 → `app.json "description"`. One short paragraph, three to five sentences — outcome, users, the main objects it adds, integrations — written before the box opens, offered first. Same rules. |
| **Help URL** | `<HelpUrl>` | Box 4D, question D3 → `app.json "help"` — the **Help** link on Extension Management. Only a URL from the human's own material, labelled with its source, or typed; never inferred. *Set it when the help site is built (recommended)* defers it to Step 6, which builds `docs/index.html` and offers `help` then (Ops § Help Site); for `AppSource` that deferral is a release blocker until Step 6 sets it. |
| **AppSource manifest set** *(only if Deployment Target = `AppSource`)* | — | `brief`, `description`, and `help` from the three rows above (not asked again); `url`, `logo`, `privacyStatement`, `EULA`, `contextSensitiveHelpUrl`, and `applicationInsightsConnectionString` where given. Each is **mandatory for submission** — a missing one is a rejected submission, not a warning. `name`, `publisher`, and `version` must match the Partner Center offer exactly. Anything deferred is recorded as a release blocker. |
| **Version** | `<Version>` | → `app.json "version"`. New app: **`0.0.0.1`** (default, offered first). Existing app: the version installed in the target environment — asked here, confirmed by the human on the Extension Management page — and continued from. A new app's first build goes out at `0.0.0.1` as written, an existing app's first build increments from the installed version, and every build after the first increments the Revision mechanically; Major, Minor, and Build bumps are proposed and approved; the release candidate `1.0.0.0` is asked at the end of Step 6 (ALL ALONG → Packaging & Versioning). |
| **Use Namespace (y/n)** | `<UseNamespace>` | Default `Yes`. If `No`, no generated file gets a `namespace` line. |
| **Namespace** | `<Publisher>.<ExtensionShort>` | N/A if Use Namespace = `No`. PascalCase, no spaces. |
| **Localization** | `<Localization>` | E.g. `W1`, `NA`, `EU`, `US`. Drives field/table inclusion. |
| **AL Object Prefix** | `<prefix>` | Short, lowercase. Used in page names/identifiers. |
| **APIPublisher / APIGroup Prefix / APIVersion** | — | Derived: the Publisher in camelCase (`'contoso'`), the prefix followed by a PascalCase group name (`'acmeCoreFinancial'`, no underscore), and `'v1.0'` — same values everywhere (**Standards §2.7**). |
| **Permission Set App Code** | `<APPCODE>` | Uppercase letters or digits, no spaces, unique among every extension that uses this prefix, at most `13 − (prefix length)` characters (**Standards §5.4**). |
| **Permission Set Names** | `<PREFIX> <APPCODE>, VIEW` / `<PREFIX> <APPCODE>, EDIT` | Derived: `<PREFIX>` is the AL Object Prefix in uppercase. Each ≤ 20 characters, e.g. `OCPF NAICS, VIEW`. |
| **Object ID range(s)** | — | Primary + any Additional, from Box 3. **The range belongs to the Deployment Target** (**Standards §5.5**): PTE work uses 50,000–99,999; `AppSource` uses only a range Microsoft registered to this publisher (70,000,000–74,999,999 for a new publisher), never 50,000–99,999. |
| **Permission Sets required?** | `Yes`/`No` | `No` only if the extension owns **zero new tables** (**Standards §5.3**); otherwise `Yes`, not asked. If `Yes`, the two permission sets take the primary range's first two *permission set* IDs — their own ID space; they cost no table, page, or codeunit number (Ops § Object IDs). |
| **AL Runtime / BC Application Minimum / Symbol Source** | — | BC version from Box 2; runtime from Microsoft Learn. Symbol Source is filled in by the agent after downloading: version, W1 or localized, where from, and — after a fallback — the route that failed and why (Ops § Symbols). |
| **Onboarding extras** | `Yes`/`No` each | Assisted Setup Wizard? Role Center Activity Cues? Departments/"My Business Central" placement? Box 4; `No` to any is a final answer, not a placeholder — most small extensions answer `No` to all three, but ask anyway. |
| **App icon** | `Use images/<file>` / `Yes — I'll provide an image` / `Create one for me` / `No icon` (`Later` typed) | K3 — Box 0 (Ops § Intake); re-asked as the next box when *No icon* or *Later* met an AppSource target; *Create one for me* is the plugin's `app-icon` skill (Ops § Intake → *The app icon → Creating one*). *Later* is a release blocker for AppSource — the old AppSource icon question is folded in here. On *Yes*, ask for the path as free text with the guidance *"PNG, square, 300 × 300 px is ideal — Microsoft accepts 216 to 350 px for the marketplace listing. Larger is fine; I'll resize it, keeping the proportions, never stretching."* The agent copies it to `src/logo/AppLogo.png`, resizing when larger with what the machine has — macOS `sips -Z 300 <in> --out src/logo/AppLogo.png`; Windows a PowerShell `System.Drawing` snippet (Ops § Intake gives it); Linux `convert <in> -resize 300x300 src/logo/AppLogo.png` if ImageMagick is present, else Python Pillow, else ask the human to resize. A non-square image gets its longer side resized to 300 and is padded to square with transparency, never cropped silently — say what was done. `app.json` gets `"logo": "src/logo/AppLogo.png"`; the file is committed. |
| **Business Central Copilot feature** | `Yes` / `No` | A feature in Business Central's own Copilot UI (a `Copilot Capability`, a `PromptDialog` page, a *Suggest with Copilot* action, Azure OpenAI through System.AI). **`Yes` is valid for a PTE**; Microsoft-billed needs no Azure subscription. If `Yes`: the host page(s), what the AI suggests, and the billing path — *Microsoft-billed* (default) / *Partner-billed* / *both*. Triggers the OnlyBCFans BC Copilot Blueprint fetch at Step 3 (ALL ALONG → *Business Central Copilot Features*). |
| **Framework files in `.gitignore`?** | `Yes` (default) | Box 5, asked as: *"`.gitignore` lists files Git leaves out of commits and pushes — they stay on disk and work normally. Should this framework's own files be left out of this project's repository?"* With `Yes`, the second block of Ops § Repository Hygiene goes into `.gitignore` — by name, every one, not "the framework files" in the agent's head: `ocpfFramework/` as a whole (it holds `LITE_RunbookChangeLog.md`, `LITE_RunbookSchematics.md`, `framework.json`, and the runbook itself when `CLAUDE.md` already existed), the runbook under whatever name it was given (`CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/ocpf-framework.instructions.md` — only the ones that exist), and the project-local sub-agent definitions (`.claude/agents/ocpf-light.md`, `ocpf-reasoning.md`, `ocpf-generator.md`, `ocpf-reviewer.md`, `ocpf-analyst.md`; `.github/agents/ocpf-light.agent.md`, `ocpf-reasoning.agent.md`, `ocpf-generator.agent.md`). The first block — `.claude/settings.local.json`, `ocpfFramework/state/`, `ocpfFramework/standardsGuide/`, `opsGuide/`, `runbookSteps/`, `documentTemplates/`, `patterns/`, `scripts/`, `.alpackages/`, `*.g.xlf` — is written whatever the answer. **Then prove it:** `git check-ignore -v <file>` on each file that exists, and `git status --porcelain` on the root; a framework file still showing means the entry is wrong. On a real project the changelog was left out and shipped to the client's remote. **Never `docs/`, `requirements/`, `src/`, `ProjectProgress.md`, `outputAppPackage/`, `*.app`, or `Translations/*.xlf`** — `docs/0-project/ChangeLog.md` is always committed. The full block is Ops § Repository Hygiene. |
| **Notifications** | `<channels>` / `<remoteControl>` | K2: any of Claude app, sound, desktop notification, or none, and Remote Control (*only when I turn it on* / *every session*) — recorded here as the answer arrives; the `notifications` skill's apply-only mode applies it in the batch and writes `ocpfFramework/state/notifications.json` from it. |
| **Countries** | `<Countries>` | K4, multi-select, from Microsoft's live page; the language rows reuse it — never asked again. |
| **Copilot session settings** | `<RequestLimit>` / `<ToolApprovals>` | K5, only when GitHub Copilot is in use → `.vscode/settings.json` and `ocpfFramework/state/copilot.json` in the batch. |
| **Requirements location** | — | K14, only when `requirements/` was empty: *put in `requirements/` now* / *pasted* / *path typed* / *described when asked*; the setup-done box asks whether they are in. |
| **Working language** | — | From the first question of this step. |
| **Main model & thinking effort** | `<MainModel>` / `<MainEffort>` | Asked in the kickoff's model box, K5 (Ops § Roles): the model this one agent runs on and its thinking effort — recommended **Sonnet, Medium** in Claude Code, **Claude Sonnet 5.5 or GPT-6.1 Sol, Medium** in GitHub Copilot; High only where judgment matters most. Recorded as the human named them, plus the harness's own identifier (e.g. `sonnet`). Must match what the session is actually running — the human switches the session, not the agent. The generator sub-agent Step 4 may use inherits this pair. Lite has no Light or Reasoning rows. |
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

**The AL project was set up in the setup batch** — the agent's job, never the human's (Rule 6d;
Ops § Project Setup). Once the human confirms the sheet, **verify** it against the sheet and redo
only what differs or is missing:
1. **`app.json` matches the sheet** — add Box 4D's `brief`, `description`, and `help` now (a value
   as given; a deferral or *left out* writes nothing); `id`, `name`, `publisher`, and `logo` as the
   batch wrote them; `version` from the Version row.
2. **`src/` exists** — every AL file goes there (subfolders per module are fine), never in the
   project root; the app icon, if any, at `src/logo/AppLogo.png`.
3. **The AL tools are connected** (ALL ALONG → AL MCP Server) — connect them now only if the batch couldn't.
4. **Symbols are in `.alpackages/`**, the Symbol Source recorded, `.alpackages/` ignored (ALL ALONG →
   Symbols). A download the batch could not complete is done now: global sources first unless the
   project depends on a non-AppSource app or is localized outside Copilot Chat — then the
   environment in `launch.json`. **If the download fails, diagnose and then offer the other route in
   an options box** (Ops § Symbols → *When a download fails*); never switch routes unasked, never
   send the human to the Command Palette.
5. **Keep the editor in sync** (ALL ALONG → Keeping the Editor in Sync).

**Outputs:** `ocpfFramework/` with its six-line `README.md`; `ocpfFramework/standardsGuide/`, `ocpfFramework/opsGuide/`, `ocpfFramework/runbookSteps/`, and `ocpfFramework/documentTemplates/` (all fetched, gitignored); `app.json` written complete in the setup batch (name, publisher, logo, version, id, ID ranges, platform, application, runtime, features, target) and `src/`, the descriptions added at the sheet's confirmation; `ProjectDashboard.html` (project root, tracked) rendered, opened, explained, with its hooks proven and `ocpfFramework/state/dashboard.json`; the generator and reviewer sub-agent definitions on the Main model; the AL tools connected; `ocpfFramework/state/usage.json` (Step 1's start timestamp) and `ProjectProgress.md` (seeded, project root, Lite step table only, Step 1 `In Progress`); `ocpfFramework/state/copilot.json` and the Copilot keys in `.vscode/settings.json` (when Copilot is in use); `requirements/` (if any raw input was
captured); `docs/` with `0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/` (created before the first document); `docs/1-define/ProblemStatement.md` (purpose, scope, out-of-scope, entity list, open questions);
`docs/1-define/ProjectParameters.md` (the completed Project Parameters block, all placeholders
replaced, the Main model and effort, version, and app icon answer included);
`.gitignore` populated per the table above and verified with `git check-ignore`; `app.json`; `src/`
(with `src/logo/AppLogo.png` when an icon was given); and `.alpackages/`.

**Exit gate:** Every question was asked through the options mechanism; every kickoff box was asked back to back with no work between them (Rule 6f) and before any requirement was read; `app.json` was written complete in the setup batch from those answers; the dashboard was rendered from it, opened, its hooks installed and proven, and the explanation question answered in the setup-done box (ALL ALONG → Dashboard). The AL tools are connected. When `requirements/` was empty, the requirements question was asked and its answer acted on; on an existing app the analysis offer was made and answered. `app.json` matches the
sheet (version `0.0.0.1` for a new app, the installed version for an existing one; `logo` set when an icon was given), `src/` exists, and the target version's symbols are in `.alpackages/` (Ops § Project Setup). Both companion guides are present, in `ocpfFramework/standardsGuide/` and
`ocpfFramework/opsGuide/`, and gitignored. The notification choice is recorded in
`ocpfFramework/state/notifications.json`, applied, and tested, the arrival confirmed in the setup-done box. `docs/1-define/ProjectParameters.md` exists, in `docs/`, with no placeholder remaining, and the Main model and effort recorded there match what this session is running on. Every `.gitignore` entry from the framework-files row is present and `git check-ignore` confirms each existing framework file — `ocpfFramework/LITE_RunbookChangeLog.md` included — is ignored. Nothing from the `docs/` list is in the project root; `ProjectProgress.md` is, with only the Lite step table and the Step 1 row `In Progress`. Deployment Target
is one allowed value. Namespace is consistent or correctly N/A. If
Permission Sets required = `Yes`, ≥ 2 IDs are reserved. Onboarding questions are each answered.
The short description, long description, and help URL were each asked in a box of its own with the
agent's own suggestion as the first option, and recorded with their sources — *left out* counts
for a PTE, never for AppSource.
Every target language is classified against Microsoft's live page and, unless source wording is
*US wording, no translation files*, has a required-at-release answer and a named reviewer; source
language and wording are recorded. Human confirms the sheet.

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, end the closing message with the options box: **Proceed into Step 2 now — closes DEFINE, opens DESIGN (recommended)** / **Stop here** (say what there is to review and how to resume). Nothing of Step 2 starts until the human answers.
