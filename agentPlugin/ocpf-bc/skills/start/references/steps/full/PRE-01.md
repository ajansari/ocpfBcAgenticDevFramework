# BC App Build Routine — PRE-01 — State the Problem

**Runbook version:** 6.0.0.0 · Full edition · Phase: DEFINE

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** Stakeholder conversation notes; the business need in plain language.

**Actions:**

Since 5.10.0.0 this step runs in five movements (Ops § Asking and Approvals → *The kickoff*; Ops §
Intake → *The kickoff boxes* — **read both before the first box**): the clock, the kickoff
(every setup question back to back), the setup batch (all the work, once), the setup-done box,
and only then the requirements and the problem statement. Nothing the human waits for happens
between two kickoff boxes.

**0. Open the clock — the very first act of the routine, before anything else** (Operating Rule 11;
Ops § Usage & Cost → 1 and 8): create `ocpfFramework/state/` and `ocpfFramework/state/usage.json`
(`aiTool`, `transcriptDir`, empty `steps`) and append `{ "step": "PRE-01", "startedAt": "<now>" }`.
Why first: a window opened after the setup questions left the session's first decisions and tokens
outside every window on real projects.

**1. Before the first box — one read, one batch, one line said.** In a single batch, before any
question: the companions when the project has none yet — `ocpfFramework/` with its six-line
`README.md` (Ops § Project Setup gives the text), the Standards Guide into
`ocpfFramework/standardsGuide/`, the Operations Guide into `ocpfFramework/opsGuide/`, this
runbook's step files (`fullVersion/steps/*.md`) into `ocpfFramework/runbookSteps/`, the document
templates (`documentTemplates/*.md`) into `ocpfFramework/documentTemplates/`, and this runbook's
changelog as `ocpfFramework/RunbookChangelog.md`, and `opsGuide/extensionPoints.json` as
`ocpfFramework/extensionPoints.json` (6.0.0.0), each from its raw URL
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/<folder>/<file>` (Ops §
Fetched Companions has the list; `main` is the environment variable `OCPF_FRAMEWORK_REF`'s value
when it is set — Ops § Plugin's pre-release channel; in a plugin project the `start` skill already fetched them —
check, don't refetch; the always-ignored `.gitignore` group goes in now, Ops § Repository Hygiene;
check each step file's `**Runbook version:**` line against this runbook's version); Microsoft's
live *Country/Regional Availability and Supported Languages* page and the *Choose runtime version*
table (Ops § Reference Sources — every country, language, and BC version offered in the kickoff
comes from them, never from memory); what is on disk — `app.json`, `src/`, `images/`, and whether
`requirements/` holds anything (its content is read in movement 4, not now); and the Ops sections
the boxes cite: § Intake, § Notifications 1, § Roles → *Asking*, § Asking and Approvals. Then one
line: *"Reading the guides and two Microsoft pages, then I'll ask everything I need in one go —
about N boxes."* Say plainly what was fetched rather than fetching silently. **Full procedure,
including the plugin's offline copies and what to do when GitHub is unreachable: ALL ALONG → OCPF
AL Development Standards Guide.**

**2. The kickoff — the boxes, back to back** (Rule 6a, Rule 6f; the options for every question are
Ops § Intake's sheet, the order is Ops § Intake → *The kickoff boxes*). Between boxes, write each
answer to `docs/0-project/ProjectMemory.md` (create `docs/0-project/` for it) and nothing else.
Already-answered questions (a resumed intake, Rule 6e) are skipped, never re-asked.
- **K1 — Working language**, alone, in English, English first, free text for any other language
  (Operating Rule 8). Every later box is in the language chosen.
- **K2 — Notifications** (Ops § Notifications → 1): the channels — Claude app, sound, desktop
  notification, any combination, or none; in Claude Code the *Claude app* option is offered unless
  a disqualifier is positively found, never dropped for a sign-in that can't be checked, a fresh
  install, an unpaired phone, or Windows — and, in the same box, **Remote Control** (*Only when I
  turn it on* / *Every Claude Code session on this machine*), its explanation in the question's
  text, worded so it only matters when *Claude app* was chosen. Applied and tested in the batch.
- **K3 — Identity and target** (Ops § Intake → *Box 0*): **Extension name?** (up to three
  suggestions built from the human's own wording, each labelled a suggestion, plus *I'll type
  it*); **Publisher?** (only a name the human has already written, quoted with its source, else
  *I'll type it* — never inferred from an email domain, git config, a folder name, or another
  project: Ops § Intake → *Forbidden sources*; record the source with the answer); **App icon?**
  (when `images/` holds an image, *Use `images/<file>`* first; then *Yes — I'll provide an image* /
  *Create one for me* / *No icon*, *Later* via the free-text entry); **Deployment Target?** (*SaaS
  PTE* / *OnPrem PTE* / *AppSource* — say in the box's text what AppSource changes: the ID range
  bands, mandatory translation files, the marketplace questions). **K3a, as the next box when
  needed:** the icon's path as free text with Ops § Intake → *The app icon*'s guidance (placed and
  resized in the batch); on *Create one for me*, the `app-icon` skill's one box — style, colors,
  content, description — the icon drawn in the batch and accepted in the setup-done box.
- **K4 — Countries and app:** which countries the users work in (multi-select, from the page read
  in movement 1 — **countries are asked only here**; Step 01 reuses the answer); **new or existing
  app** (4b) when `app.json` already existed; **who approves** — *Who signs off on the design
  documents?* **One person for every role** / **Separate people for different roles** (with one
  approver, PRE-01's sign-off joins PRE-02's and Step 03's joins Step 04's; the FRD sign-off stays
  separate); and **a Business Central Copilot feature?** (*No* / *Yes* — the host pages, what the
  AI suggests, and the billing path as free text; Standards and ALL ALONG → *Business Central
  Copilot Features*).
- **K5 and K6 — Models** (Ops § Roles — the effort warning *"A High thinking effort makes every
  task slower: the model thinks longer before each answer, and a step can take noticeably more
  time. The framework recommends High only where judgment matters most."* and the model this
  session is running on, both in K5's own text): **Main model**, **Main thinking effort**, **Light
  model**, **Light thinking effort** in K5; **Reasoning model**, **Reasoning thinking effort** in
  K6, with the recommended pair first — **Claude Code:** Main *Sonnet, Medium*; Light *Haiku,
  Medium*; Reasoning *Opus, High*; **GitHub Copilot:** Main *Claude Sonnet 5.5 or GPT-6.1 Sol,
  Medium*; Light *Claude Haiku 5.5 or GPT-6 Luna, Medium (Balanced)*; Reasoning *Claude Opus 5.5 or
  GPT-6.1 Sol, High* — two options per role, the Claude model first; the picker's names on the
  day. **When GitHub Copilot is one of the AI tools**, K6 also carries the two Copilot
  session-settings questions (Ops § Asking and Approvals → *GitHub Copilot session settings*): the
  agent-mode request limit (*150 — recommended* / *100* / *leave the default*) and tool approvals
  (*Ask each time* / *Allow the framework's own commands* / *Allow everything*, with its warning).
  A Main model or effort other than the session's is switched by the human (`/model`, `/effort`;
  the picker in Copilot) and confirmed in the setup-done box.
- **K7 — Naming** (Box 2): AL object prefix; namespace; Localization; Business Central version
  (the current major and the one before, from the page read in movement 1).
- **K8 — Permission sets and IDs** (Box 3): Permission Set App Code; other extensions using this
  prefix; object ID range (*50100–50149* only as the AL template's default, never first — Ops §
  Intake → *Forbidden sources*; for AppSource the registered bands, *The AppSource questions*);
  another range? — each *Yes* and each collision opens the follow-up as the next box.
- **K9 — AppSource** (only when K3 said AppSource; Boxes 3a and 3b): `url`, `privacyStatement`,
  `EULA`, `contextSensitiveHelpUrl`, then `applicationInsightsConnectionString`.
- **K10 to K12 — Languages** (Ops § Intake → *The language questions*): per country, the languages
  BC supports there (multi-select, up to four countries per box); then the source language and
  the source wording; then, only when a target language other than the source exists, which
  documents are translated and whether testers need a translated test script, and, per such
  language, required at first release and who reviews it, two languages per box, a
  partner-translated language's app question beside them.
- **K13 — Working setup:** framework files in `.gitignore`? (question 18, `.gitignore` explained in
  the question); customer-language documents? translatable data? (question 5 of the language
  questions).
- **K13a — Custom skills** (6.0.0.0; Ops § Custom Skills): **Do you have any skills you want to
  load?** — multi-select: *Upload — a folder or a `.zip` on this machine (I'll type its path in
  chat)* / *GitHub repository — I'll type the URL* / *Skills site —
  a bcskills.ai slug, I'll type it* / *No*; when `~/.ocpf/skills/` holds skills or the project has a
  `skillslocation.md` (read in movement 1), the first option is *Load these: <slugs> (recommended)*;
  on the Copilot CLI yes / no lines in that order, *Load these?* first when it applies. Each yes gets its typed follow-up as the very next box. The
  fetch, inspection, and dedupe run in the batch; each skill's *Activate* box is asked in the
  setup-done box.
- **K14 — Requirements and existing app, always the last box:** when `requirements/` is empty and
  the human pasted or attached nothing, **Where are the requirements?** — *I'll put them in
  `requirements/` now (recommended — `.md` preferred; Word, PDF, and images are read too)* / *I'll
  paste them in chat* / *They're in a file or folder elsewhere — I'll type the path* / *I'll
  describe the need when you ask*; and, when `src/` already holds real objects (anything beyond the
  AL template's `HelloWorld.al`) and `requirements/existing/` is empty, **Run the in-depth analysis
  and documentation first (recommended when the app has no FRD, TDD, or docs — 10 to 30 minutes)**
  / *Skip — the light read is enough* (Ops § Existing Apps). On *I'll paste them in chat*, end the
  turn asking for the paste; the batch starts when it arrives (or, when the human says to go on,
  runs now and captures the paste when it comes).

**3. The setup batch — one message, no question** (Ops § Intake → *The kickoff boxes* → *After the
last kickoff box*). In this order, each from its own section: the repository (`git rev-parse
--is-inside-work-tree`, else `git init -b main`, said in one line — Ops § Repository Hygiene);
`src/` and **`app.json` written complete** — `name`, `publisher`, `logo` when an icon was given, a
new `id` GUID or the existing file's, `version` `0.0.0.1` or the installed version from 4b, every
ID range, `platform`, `application`, `runtime` from the table read in movement 1, the `features`,
`target`, and the AppSource block when K9 was asked (Ops § Project Setup step 1 — `brief`,
`description`, and `help` come later, from Box 4D); the icon placed and resized, or drawn by the
`app-icon` skill (Ops § Intake → *The app icon*); the notifications recorded in
`ocpfFramework/state/notifications.json`, applied, and each hook's exact command run once (Ops §
Notifications 2, 3, 5; the plugin's `notifications` skill in apply-only mode); the Copilot answers
written to `.vscode/settings.json` and `ocpfFramework/state/copilot.json`; **the four project-local
sub-agent definitions** — Light and Reasoning with their chosen model and effort, the generator and
the reviewer on Main (Ops § Roles → *Enforcement*; the plugin's `roles` skill in apply-only mode) —
and all six answers with their harness identifiers recorded in `docs/0-project/ProjectMemory.md`;
`docs/` with its five phase subfolders — `0-project/`, `1-define/`, `2-design/`, `3-build/`,
`4-prove/` (Operating Rule 9) — and `ProjectProgress.md` from
`ocpfFramework/documentTemplates/ProjectProgress.md` **in the project root**, the *Full* step table
kept and the *Lite* one deleted, every row blank except this one, `In Progress`, the empty usage
table beneath it (ALL ALONG → Project Progress Tracker); the `.gitignore` blocks from K13's answer,
proven with `git check-ignore` (Ops § Repository Hygiene — `ProjectDashboard.html`,
`requirements/`, `docs/`, and `ocpfFramework/customSkills.json` must not be ignored); **the Custom
Skills K13a named fetched, inspected, and deduped** (Ops § Custom Skills → 3 — placed and registered
after their *Activate* boxes in the setup-done box, where any issue's options box is asked too); **the live dashboard** — the renderer and
template into `ocpfFramework/scripts/`, `ProjectDashboard.html` rendered at the project root,
opened once (`--open`), the refresh hooks installed with the interpreter the runner ladder found
and proven — the Stop hook's exact command run once, the sidecar newer and carrying the app's name
and the edition (Ops § Dashboard → 3; the plugin's `dashboard` skill); the AL tools connected
(ALL ALONG → AL MCP Server; the plugin's `al-mcp-setup` skill; `alMcp` recorded); the symbols
downloaded and the Symbol Source recorded (ALL ALONG → Symbols; Ops § Symbols — a failure is
diagnosed and its options box held for the setup-done box, never switched unasked); the editor
synced (ALL ALONG → Keeping the Editor in Sync); and **any raw requirements captured verbatim** —
text pasted in chat as its own Markdown file in `requirements/` (a descriptive name, a header
naming who provided it and when, the text untouched; a same-named capture gets a date suffix,
never overwritten), an uploaded or pointed-at file copied unmodified under its own name;
`requirements/` is a tracked project folder, never ignored, and the same capture applies the
moment any later requirements or change-request input arrives. The batch's closing message says,
once, that packages land in `outputAppPackage/`, one file per build, each with its own version.

**4. The setup-done box** — one box: the dashboard explanation, **I understand** / *Other*, with
the text Ops § Dashboard fixes; **Activate <display name> <version>?** per Custom Skill K13a fetched
(its `SKILL.md`, manifest, and files shown first; a fifth skill opens the next box) and any issue's
options box (Ops § Custom Skills → 5); whether each chosen notification kind arrived and clicking one
opened the session; **Accept this icon** / *Make another* when one was drawn; the Main model switch
confirmed when it differs from the session's; and *Are the requirements in `requirements/` now?*
when K14 said so. Record the answers in `docs/0-project/ProjectMemory.md`; act on a free-text
answer before continuing. A failed symbol download's options box follows (Ops § Symbols).

**5. Now the requirements.** On *Run the in-depth analysis*, run the plugin's `analyze` skill
(`/ocpf-bc:analyze`; without the plugin, the Ops § Existing Apps procedure) — it asks what the
human knows and which model does the analysis, and writes the presumed FRD and TDD, the Object
Register, the Documentation with the schema, and the Project Parameters into
`requirements/existing/` — then read that folder with the rest of `requirements/` as *what the app
already is*; the light read (name, publisher, ranges, objects by type) is said in either case.
Read `requirements/` in full (`.md` recommended; Word, PDF, and images read too). Questions from
here on may follow work — that is expected; the kickoff is over.
- Write a problem statement: what business outcome is required, who the consumers are (users, other systems, AI tools, BI/reporting), which **countries and languages** the users work in (answered in the kickoff — carried, not asked again), and what is explicitly out of scope.
- Capture the domain vocabulary the design will anchor to (entity names, categories, known pain points).
- Produce an initial entity/object list from stakeholder domain knowledge.
- As the agent: identify duplicates, ambiguous terms, and outdated/legacy terminology in the initial list; ask clarifying questions about scope and consumer use cases. Do not resolve ambiguities silently.

**Outputs:** `ocpfFramework/` with its six-line `README.md`, `standardsGuide/`, `opsGuide/`, `runbookSteps/`, `documentTemplates/`, and `RunbookChangelog.md` (all fetched, the folder gitignored per Ops § Repository Hygiene), every kickoff answer recorded in `docs/0-project/ProjectMemory.md` with its source, `app.json` written complete in the setup batch (name, publisher, logo, version, id, ID ranges, platform, application, runtime, features, target, the AppSource block when asked) and `src/` with `src/logo/AppLogo.png` when an icon was given or drawn, `ProjectDashboard.html` (project root, tracked; rendered, opened, explained — hooks installed and proven, `ocpfFramework/state/dashboard.json`), `ocpfFramework/state/usage.json` (PRE-01's `startedAt`, and its rows at the close), `ocpfFramework/state/notifications.json` (applied and tested), `ocpfFramework/state/copilot.json` and the Copilot keys in `.vscode/settings.json` (when Copilot is in use), the model and effort assignment materialized as four project-local sub-agent definitions — light, reasoning, generator, reviewer (Ops § Roles), `.gitignore` written and proven, the AL tools connected and `.alpackages/` holding the target version's symbols (Symbol Source recorded), `requirements/` (seeded, if any raw input was provided), `ProjectProgress.md` (seeded from its template, Full step table, project root), `docs/` with `0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/` (created), `requirements/existing/` (when the analysis ran), `docs/1-define/ProblemStatement.md` — purpose, scope, out-of-scope, target consumers, initial entity list, open questions.

**Exit gate:** Every kickoff box was asked back to back with no work between them (Rule 6f) and before any requirement was read; every answer is in `docs/0-project/ProjectMemory.md` with its source. `app.json` exists, written complete in the setup batch with the human's extension name and publisher (and `logo` when an icon was given — the file at `src/logo/AppLogo.png`), the publisher's source naming a box the human answered (Ops § Intake → *Forbidden sources*), and the ID range(s) chosen or typed in K8; the dashboard `ProjectDashboard.html` was rendered from it at the project root (not ignored: `git check-ignore ProjectDashboard.html` prints nothing), opened in the browser, its hooks installed and proven for this AI tool, and the explanation question answered in the setup-done box (ALL ALONG → Dashboard). Both companion guides are present, in `ocpfFramework/standardsGuide/` and `ocpfFramework/opsGuide/`, the step files in `ocpfFramework/runbookSteps/`, the templates in `ocpfFramework/documentTemplates/`, the changelog at `ocpfFramework/RunbookChangelog.md`, the `README.md` written, all gitignored. The Copilot session settings are written and recorded when Copilot is in use. `ocpfFramework/state/usage.json` holds PRE-01's `startedAt` and, at the close, its `completedAt`, and PRE-01's usage rows — one per model in Claude Code, one per step in Copilot — are in `ProjectProgress.md` and pasted into the closing message (Operating Rule 11). The notification choice is recorded in `ocpfFramework/state/notifications.json`, applied, and tested, the arrival confirmed in the setup-done box (ALL ALONG → Notifications). The effort warning was in the first model box's text, all six model and effort answers are recorded, the Main model and effort match what this session is actually running on, and the Light, Reasoning, Generator, and Reviewer sub-agent definitions exist in the project with the chosen model and effort set (Operating Rule 10). The AL tools are connected and the target version's symbols are in `.alpackages/` with the Symbol Source recorded. On an existing app the analysis offer was made and answered; when `requirements/` was empty, the requirements question was asked and its answer acted on. `docs/1-define/ProblemStatement.md` is in `docs/1-define/`, not the root or a flat `docs/` (Operating Rule 9). Functional Consultant signs off on the problem statement and initial entity list (Stage↔Step Map, Stage 1) — or, when **Approvers** is one person, this sign-off moves to the end of PRE-02 and is given together with that step's, on the problem statement and expanded list at once.

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, end the closing message with the options box: **Proceed into PRE-02 now (recommended)** / **Stop here** (say what there is to review and how to resume). Nothing of PRE-02 starts until the human answers.
