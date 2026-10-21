---
name: build-a-feature
description: The Build-a-Feature journey of the OCPF BC Agentic Development Framework - quick, tactical customizations of Business Central in a new or existing per-tenant extension, built in minutes, with no steps and no design documents but a strong engineering foundation. A table and its list and card pages, a table or page or report extension, a processing report, an API page or API query, a query, an enum or enum extension, a codeunit, a permission set, a role center. Not vibe-coding - the Standards Guide, the patterns library, and the analyzers still govern every file - but lean on documentation - six short documents in a flat docs/ folder, written as the work happens. Perfect for a PoC for a demo or a prototype that a Full or Lite project can later turn into a solution. Asks what to build in one question, writes the proposed design to disk before confirming field types, compiles clean, offers the natural next object, offers to review the code and to package a .app, and keeps the live dashboard and the usage table current. Reached through /ocpf-bc:start; use it directly when the user says "just add a table", "add a field to the Customer Card", "I need an API page for", "create an enum", "a role center for", "quick mod", or runs /ocpf-bc:build-a-feature.
---

# Build-a-Feature

**Follow `Ops § Build-a-Feature` in the Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`;
fetched below if the project has none yet). That section is the journey's rules and the reasons
behind them; this skill is the procedure. Everything else in the framework still applies where
it is cited: **Standards §** is the OCPF AL Development Standards Guide, **Ops §** the Operations
Guide, and the patterns library is `ocpfFramework/patterns/`.

**What this journey is** (Ops § Journeys). Quick, tactical customizations: extend a table or a
page, a processing report, a table and its pages, an API, a role center, an enum, a permission
set — when time is of the essence. It is **not vibe-coding**: the Standards Guide and the patterns
library govern every file at writing time and the analyzers at compile time, the record is kept,
the dashboard is live, the options box closes every step. It is **lean on documentation**: no FRD,
TDD, Design Doc, Sanity Check, estimates, or test scripts — six short documents in a flat `docs/`
folder, written as the work happens, are the whole record. It builds what was asked for, not a
holistic solution, which is exactly what makes it right for a PoC app for a demo or a prototype:
the foundation is strong enough that a Full or Lite project, or a developer, can take it over
later. Minutes, usually 10–20; at published API rates most builds cost $1–5.

**Where it is reached.** The `start` skill offers it as the third journey beside Full and Lite,
recommends it first on an existing extension that never used the framework, and offers *Build a
feature in this project* on a project that already follows the framework.

**One model.** The Main model does everything here: asks, writes, compiles and fixes, documents,
reviews. No Light, Reasoning, Generator, or Reviewer sub-agent is used, even on a Full project
that has them.

Throughout, when the human must **decide**, use the harness's options mechanism with the
recommended option first and a one-line reason on each, **two to four options per question**
(Ops § Asking and Approvals): `AskUserQuestion` in Claude Code, `askQuestions` in GitHub Copilot
Chat, `ask_user` in the Copilot CLI (add *I'll type it* where a typed answer is possible). **Free
text is expected in exactly two places: the working-language question and the intake question
(Part 3).** Every later question is confirm-or-correct with preset options. Ordinary progress is
a plain message.

`start` is the documented way in. Invoked directly as `/ocpf-bc:build-a-feature`, the skill runs
the same Part 1 checks and behaves identically; it is not a different journey.

---

## Part 0: Open the clock — before anything else

**The first act of the journey, before the working-language question, before reading anything
but the folder:** make sure `ocpfFramework/state/usage.json` exists (create `ocpfFramework/state/`
and the file as the `usage` skill's Step 1 says — `aiTool`, `transcriptDir`, empty `steps`; the
folder is always gitignored) and append `{ "step": "F00", "title": "Intake", "startedAt": "<now>" }`.
Why first: on a real project the intake window was opened at the end of setup, so seven decisions
and 40 % of the session's tokens were *Unattributed* and the dashboard's clock started minutes
after the tokens did. The renderers now also stretch the first window back to the first event of
the session that opened it (v5.8.0.0), but the window is still opened here, first. **Case A** (a
Full or Lite project with a step `In Progress`): opening `F00` closes that step's window (an open
window ends where the next starts, Ops § Usage & Cost → 1); say so in one line, note the step id,
and at Part 7 **reopen it**.

## Part 1: Where you are

Decide which of these applies before asking anything. Read, don't ask.

| Case | How you know | What it means |
|---|---|---|
| **A. Framework project** | `ocpfFramework/framework.json` exists with `edition` `full` or `lite` (or a `CLAUDE.md` / `.github/copilot-instructions.md` starting `# BC App Build Routine`) | The project's parameters, prefix, namespace, ID ranges, models, notifications, dashboard, and `ProjectProgress.md` already exist. Reuse all of it. Add nothing to the project's documents except one ChangeLog line per object and the journey's documents, written beside the project's own in its phase folders (Part 7), never replacing. |
| **B. Feature project** | `ocpfFramework/framework.json` exists with `edition` `feature` | A previous Build-a-Feature session. Continue: ids continue from the highest `F` row in `ProjectProgress.md`; `ocpfFramework/state/feature.json` holds the parameters and their sources. |
| **C. Existing extension, no framework** | `app.json` exists, no `ocpfFramework/`, **and the extension has been built or installed somewhere**: `outputAppPackage/` or a `*.app` holds a package, or `src/` has real objects beyond the AL template's `HelloWorld.al` | Read `app.json` and `src/` for everything that can be read (Part 2); **confirm** what was read; ask what cannot be read. Its version is **asked**, never assumed (Part 2 step 5). **If the app has no usable documentation** (no FRD, TDD, design doc, or README that explains it) and `requirements/existing/` is empty, offer the `analyze` skill first — *Analyze and document the app first (recommended — one run, 10–30 minutes)* / *Skip — I know this app* (Ops § Existing Apps). |
| **D. Empty or new folder, or a fresh scaffold** | no `app.json`; **or** `app.json` from **AL: Go!** — version `1.0.0.0`, no package anywhere, `src/` empty or only `HelloWorld.al` | A new per-tenant extension. Keep the scaffold's `id` GUID and delete `HelloWorld.al`; Part 2 asks the identity and range questions, once, and writes **`version` `0.0.0.1`** (Ops § Packaging → *Version numbers*). AL: Go!'s `1.0.0.0` is the template's default, not a release, and is never kept. |

**New app or existing app is a question, exactly as Full and Lite ask it (intake 4b), never an
inference from `app.json`.** Whenever `app.json` exists and the project is not already a framework
project, ask it in Part 2 step 5 with the answer the evidence suggests first.

**Template placeholders are not answers.** AL: Go! writes `name` `ALProject1` (or similar),
`publisher` `Default publisher`, `version` `1.0.0.0`, `idRanges` `50100–50149`, and
`HelloWorld.al`. None of these was decided by a human. A value that matches a template default
— or that is plainly a placeholder (`Default`, `My`, `Test`, `ALProject`, `Sample`) — is treated
as **unanswered**: it is asked through the options mechanism like an empty folder's would be,
and the file is rewritten with the answer.

**Two values come only from the human, in this session, and are recorded with their source
(Ops § Intake → *Forbidden sources*).** The **publisher** is a name the human typed or chose in a
box — never `git config user.name` or `user.email`, never an email domain, never a folder or
company name seen elsewhere on the machine, never a publisher from another project, memory, or a
previous session's `app.json`, never the AL template. The **object ID range** is a range the human
chose or typed in a box — never kept silently from `app.json`, and `50100–50149` only when the
human picks it knowing it is the AL template's default. Both are written to
`ocpfFramework/state/feature.json` with `publisherSource` and `idRangesSource` naming the box and
the date (`references/feature-record.md`); Part 4 will not allocate an ID without the latter, and
`app.json` is not written without the former. Why: on real projects the agent wrote a publisher
it had seen in the human's email domain, and allocated IDs from the scaffold's default range,
and both had to be undone.

If the folder is unclear, confirm the workspace root with the human first.

## Part 2: Setup, the minimum

Nothing here needs the human beyond the questions named and the AI tool's own approval prompts.
Do it in this order; skip what the case already has.

1. **Working language** (cases B, C, D; A has it in `docs/1-define/ProjectParameters.md`): ask in
   English through the options mechanism, English first, free text for any other language.
   Continue in the language chosen.
2. **Companions** (B, C, D; A already has them): create `ocpfFramework/` with its six-line
   `README.md` (Ops § Project Setup); fetch the Standards Guide into
   `ocpfFramework/standardsGuide/` (standalone repository at the pinned tag, Ops § Fetched
   Companions), the Operations Guide into `ocpfFramework/opsGuide/`, the patterns library into
   `ocpfFramework/patterns/`, and this plugin's `usage` and `dashboard` scripts and templates into
   `ocpfFramework/scripts/`. GitHub unreachable: use the bundled copies (`al-standards` and
   `start` skills' `references/`) and say which versions. **No step files, no runbook, and no
   document templates except the ones this journey writes** — `ProjectProgress.md`,
   `FeatureRegister.md`, `FeatureDataModel.md`, `FeatureDocumentation.md`, `ChangeLog.md`,
   `SandboxInstall.md` (Part 7). BCQuality is fetched only when the human chooses a review (Part 5).
3. **Marker** (B: update; C, D: create) `ocpfFramework/framework.json`:
   ```json
   {
     "framework": "OCPF BC Agentic Development Framework",
     "edition": "feature",
     "runbookVersion": "<the Operations Guide's **Version:** line>",
     "source": "github | plugin-bundle",
     "repository": "https://github.com/ajansari/ocpfBcAgenticDevFramework",
     "ref": "main", "commitSha": "<sha or unknown>", "fetchedAt": "<ISO 8601>",
     "placedAs": [], "changelogFile": null,
     "pluginVersion": "<from ../../.claude-plugin/plugin.json>",
     "declinedUpdateVersion": null, "alMcp": "not-checked",
     "layout": "ocpfFramework-1", "tooling": {}
   }
   ```
   `placedAs` is empty because there is no runbook; `runbookVersion` is the Operations Guide's
   `**Version:**` line — the one number Full, Lite, the guide, the plugin, and this journey share
   since 5.5.0.0 — so `update-framework` can compare it. **Case A keeps its
   marker untouched** — the project stays Full or Lite; the feature table in
   `ProjectProgress.md` is what says Build-a-Feature ran on it.
4. **Notifications** (B, C, D): the `notifications` skill, right after the language. In Claude
   Code the *Claude app* option is offered unless a disqualifier is positively found — never
   dropped for a sign-in that can't be checked, a fresh install, or Windows — and each hook is
   tested with its exact command.
5. **Identity (D — an empty folder or a scaffold)**, one box, three questions (Ops § Intake →
   *Box 0*): extension name (suggestions from the human's wording + *I'll type it*; a scaffold's
   `ALProject1` is never offered), publisher (**only a name they wrote in this session, quoted
   with its source, else *I'll type it*** — never inferred from anything on the machine; `Default
   publisher` is a placeholder, not a publisher), app icon (**if `images/` holds an image, offer
   it first by file name**, then *Yes — I'll provide an image* / ***Create one for me*** — the
   `app-icon` skill: style, colors, content, and description asked in one box, the icon drawn,
   rendered, shown, and accepted before `app.json` names it (Ops § Intake → *The app icon →
   Creating one*) / *No icon*; *Later* via free text). Write
   `app.json` at once: `name`, `publisher`, `logo` when given, `version` `0.0.0.1`, the scaffold's
   `id` or a new one, platform defaults; create `src/` (delete `HelloWorld.al`). Record
   `publisher` and `publisherSource` in `ocpfFramework/state/feature.json`.
   **Identity (C — an existing extension):** keep `id`; show `name` and `publisher` as read and
   **confirm them in one box** (*That's right* / *Change the name* / *Change the publisher*) —
   a value that looks like a placeholder is asked outright, as above — and, in the same box, ask
   the **app icon** question when `app.json` has no `logo` (the `images/` file first if one exists;
   *Yes — I'll provide an image* / *Create one for me* — the `app-icon` skill / *No icon*; placed
   and resized per Ops § Intake → *The app icon*). A confirmed publisher's source is *confirmed by the human from app.json, <date>*.
   Box 0 is Box 0 on every journey: the same three questions Full's PRE-01 and Lite's Step 1 ask,
   in the same order, before the dashboard is created.
   **`app.json` already exists (C, or a scaffold under D):** then ask the intake's question 4b,
   one box, two options, the one the evidence suggests first:
   - *New app — the version starts at `0.0.0.1`* — **recommended, and first, when no package
     exists anywhere and `src/` is empty or only the template's `HelloWorld.al`** (an AL: Go!
     scaffold always says `1.0.0.0`; that is the template's default and is overwritten);
   - *Existing app — installed in a target environment; `<version from app.json>` is the
     installed version* / *I'll type the installed version* — first only when a package or real
     objects exist, and confirmed on the **Extension Management** page as Ops § Packaging says.
   Write the answer to `app.json` now. A new app is written `0.0.0.1` whatever the file said.
6. **Dashboard, the moment `app.json` exists** (B, C, D; A already has it): the `dashboard` skill
   — render, `--open`, hooks, and the one explanation question (*I understand* / *Other*) with
   Ops § Dashboard's text, adding one sentence: *On this journey the Build Map shows one row per
   object you ask for, with its stage, its time, and its cost, instead of the framework's steps.*
   Open and name `ProjectDashboard.html` (OnlyBCFans); never the F1 page unless the human asks
   for F1 by name (Ops § Dashboard → 4). The hooks name the interpreter the runner ladder found
   and are **proven before the explanation question** — the Stop hook's exact command run once,
   the sidecar newer, its `app.name` the app's and its `framework.edition` `feature` (the
   `dashboard` skill's section 2a). Why: on a real Windows project the hooks were written for
   `pwsh` on a machine without it, exited silently all build long, and the page read *Untitled
   extension* and *Full* until the closing render. Every `F` row's close ends with one render by
   the agent (section 2b), so the page is never more than one object stale.
7. **Main model and effort** (B, C, D; A has them recorded): the `roles` skill, Lite's two
   questions (Main model, Main thinking effort), after its one-sentence High-effort warning. On
   edition `feature` the `roles` skill writes **no** sub-agent copy — this journey delegates to
   none. Record the answer in `ocpfFramework/state/feature.json` (`mainModel`, `mainEffort`,
   `workingLanguage`) — there is no `ProjectParameters.md` here. Say which model the session
   is running on and have the human switch before continuing if it differs.
   **Prices:** the usage script fetches the Main model's published rate itself at the first
   measurement (Ops § Usage & Cost → 3) and the note in its output says so; read that note at the
   F00 close and record `pricingChecked` in `feature.json`. Only when the note says the fetch failed
   (offline, or a publisher the script doesn't cover) do you fetch the page yourself (the `usage`
   skill's Step 2). Why: on a real project the agent never wrote `pricing.json`, so the dashboard's
   cost tile read `$0` for the whole build for Claude Sonnet 5.5 — a model whose price was public
   all along.
8. **GitHub Copilot in use?** Ask the two Copilot session-settings questions (Ops § Asking and
   Approvals → *GitHub Copilot session settings*) and write `.vscode/settings.json` and
   `ocpfFramework/state/copilot.json`. Case A has them.
9. **Naming and range, one box** (C and D, always): **Deployment Target** (*SaaS PTE* / *OnPrem
   PTE*; AppSource is not a Build-a-Feature target — say so and offer Full), **AL object prefix**
   (C: the common prefix read from `src/`, confirmed; D: two or three short lowercase suggestions
   from the name and publisher), **namespace** (C: the first `namespace` line, confirmed; D:
   `<Publisher>.<ExtensionShort>` recommended / *No namespace*), **object ID range** — asked in
   both cases, never kept silently: *the range the human's material names*; in C, *Keep
   `<start–end>` as `app.json` has it* **unless it is `50100–50149`, which is offered as "the AL
   template's default — only if no range has been assigned to you" and never first**; *I'll type
   our range `start–end`*. Record `idRanges` and `idRangesSource` in `feature.json` from the
   answer. Then the **Permission Set App Code** (Standards §5.4, two or three uppercase
   suggestions that fit `13 − prefix length`), only when a permission set is built or a table makes
   one necessary (Part 4). A scaffold's `50100–50149` is the template default, not an allocation
   (Standards §5.5).
10. **Complete `app.json`** (C: only what is missing; D: all of it): `idRanges` from the answer,
    `platform`, `application`, `runtime` (read from Microsoft Learn's runtime table, never from
    memory), `features` `["NoImplicitWith", "TranslationFile"]` (Standards §8.2), `target`. Keep
    `id`, `name`, `publisher`, `logo`, `version` as they are.
11. **Repository, folders, and ignore list** (C, D): **the repository first** —
    `git rev-parse --is-inside-work-tree`; not a repository → `git init -b main`, said in one
    line, nothing asked; inside a larger repository → use it and say so, never a nested one (Ops §
    Repository Hygiene; on a real project no journey had ever initialized one, and every ignore
    check and `git add` ran against nothing). Then `outputAppPackage/`, `docs/` (flat — no phase folders on
    this journey, Part 7); the always-ignored block of Ops § Repository Hygiene in `.gitignore`
    (the framework-files block too, with the *Yes* default — ask only if the human objects);
    `.vscode/settings.json` with the analyzers for the Deployment Target (Ops § Analyzers);
    `ocpfFramework/scripts/al-analyze.*` outside Copilot Chat. Prove the ignore list with
    `git check-ignore` as Ops § Repository Hygiene says; the dashboard pages, `ProjectProgress.md`,
    and `docs/` must **not** be ignored.
12. **AL tools** (every case where this session lacks them): the `al-mcp-setup` skill; record
    `alMcp`. **Symbols** (C, D): download them for the target version into `.alpackages/` (Ops §
    Symbols); case A has them. Keep the editor in sync (Ops § Editor Sync).
13. **The record** — `ProjectProgress.md` at the project root:
    - **D, C, B (first time):** create it from `ocpfFramework/documentTemplates/ProjectProgress.md`
      (fetch that one template, or take it from the `documents` skill's `references/`), keep the
      **Build-a-Feature** step table, delete the other two; keep the usage table for this AI tool.
    - **A:** append the Build-a-Feature table under its own `## Build-a-Feature` heading **below
      the step table and above the usage table**, leaving the step table untouched. The usage table
      gains the `F` rows beside the step rows.
    - **B:** it exists; continue its rows.
    Write the `F00 | Intake` row `In Progress` (its window is already open from Part 0). Read
    `references/feature-record.md` for the table's exact shape, the id rules, `feature.json`, and
    the documents.

That is the whole setup. Nothing from PRE-01 / Lite Step 1 beyond this: no parameter sheet, no
problem statement beyond Part 3's short one, no estimates, no translation questions.

## Part 3: Intake — "What do you want to build today?"

1. **Look before asking.** If `requirements/` exists, or the human pointed at a file, a ticket, or
   a message, read it first (`.md`, Word, PDF, and images alike). `requirements/existing/`, when
   present, is what the app already is (the `analyze` skill's output) — read it too. If it fully
   describes the object(s), skip to the confirmation in Part 4 with everything pre-filled and say
   where each answer came from. If it is partial, pre-fill what it gives. The better formed the
   material, the faster this stage is — say so once if `requirements/` is empty.
2. **One question, the only free-text one.** Through the options mechanism:

   > **What do you want to build today?**
   > - *A new table — with its list and card pages* (the most common quick mod)
   > - *Extend a standard table or page — add fields or columns*
   > - *An API page or API query*
   > - *Something else — a report, an enum, a query, a codeunit, a permission set, a role center, an extension of one of those — I'll say which*

   *Other* / free text is where the human types what they want in their own words, for example
   *"a new table Rental Unit with No., Description, Start Date, Amount, and a card page"*. In the
   Copilot CLI, where a typed answer needs its own option, drop the third preset (an API object
   is typed, or chosen under *Something else*) and make *I'll type it* the fourth.
3. **Parse the answer** into a plan of one or more objects, in build order (lookups and enums
   before the tables that use them; tables before their pages, API pages, and permission grants;
   a table extension before the page extension that shows its fields; a cue table before its
   activities part before the role center before its profile). Recognise the usual phrasings:
   *"add a field to the Customer Card"* is a table extension **and** a page extension; *"add a
   column to the Customer List"* is a page extension, plus a table extension if the field is new;
   *"a status on the table"* is an enum plus a field; *"a role center for …"* is the four-object
   group of `references/objects/role-center.md`. Pull out names, fields, and any types the human
   gave. A follow-up with preset options settles only what the free text left genuinely open
   (which base table, which page, list or card or both).
4. **Say the plan back in one short list** — object type, name, what it will hold — and go to
   Part 4 with the first object. No approval box here: the per-object confirmation in Part 4 is
   where the human says yes.
5. **Write the first two documents now** (Part 7 has the table of all six): `docs/ProblemStatement.md`
   — a dated section: the intake answer in the human's words, the plan, what was deliberately left
   out — and `docs/FeatureRegister.md` §1 from `feature.json`, every parameter with its source.
   Case A: the problem-statement section is appended to the project's `docs/1-define/ProblemStatement.md`;
   the register goes to `docs/1-define/FeatureRegister.md`.

Close the intake window when the first object's window opens: set `F00`'s `completedAt`, run
`/ocpf-bc:usage --step F00`, paste the rows, mark the row `Completed`.

## Part 4: The object loop

For each object in the plan, in order. Each object is one row and one usage window.

1. **Open the window.** Next id (`F01`, `F02`, … continuing from the highest existing row).
   Append `{ "step": "<id>", "title": "<Type> <Name>", "startedAt": "<now>" }` to `usage.json`;
   add the row to the feature table with stage **Asked**, status `In Progress`. The dashboard
   picks it up by hook (Copilot Chat: render once, `--quiet`). **One window per object, always**
   — several objects written in one pass still get one window each, opened one after another;
   the measurement may then run once for the batch (`/ocpf-bc:usage` without `--step`) and every
   row be pasted. On a real project thirteen objects shared one window and the dashboard showed
   twelve rows with no time and no cost.
2. **Read the object's reference file** — `references/objects/<type>.md` — in full. It says what
   this object needs, how to infer and validate it, which Standards sections and patterns files
   to read before writing, the skeleton to write from, the pre-flight checks, and the companion
   offer. Read `references/field-types.md` with it for any object that has fields.
3. **Propose on disk, then ask or confirm, in one box where possible.** Infer first, confirm second
   (Ops § Build-a-Feature → *Infer, then confirm*). Types the human gave are validated, not
   re-asked; come back only on something wrong or non-standard, with the recommended fix as the
   first option. Types the human did not give are inferred from the field names. **Before the
   box, write the proposal where the human can read it:** for a table, table extension, or enum,
   its section in `docs/DataModel.md` (template `FeatureDataModel.md`) marked *proposed* — fields,
   types, lengths, key, relations, validations — and its row in `docs/FeatureRegister.md` §2 marked
   *proposed*; for a page, report, API, codeunit, permission set, or role center, the §4 / §5 line
   of `docs/DataModel.md` and the register row. **Then the box**, whose text names the file and
   section (*"The proposed design is in `docs/DataModel.md` §2.1 — open it if you want to check
   the fields before I build."*): *Looks right — build it* / *Change something* (then only what
   changes). Only a field that genuinely cannot be inferred gets a question of its own. The
   primary key is always confirmed. On the answer, update the section and the row to *confirmed*,
   and any change the human made to `docs/FeatureRegister.md` §4. Stage → **Confirmed**. Why on
   disk first: on a real project the human was asked to confirm designs they could only see in
   the chat, and the documents arrived after the package.
4. **Allocate the ID and the file name — only through the gate.** Read
   `ocpfFramework/state/feature.json` (case A: `docs/1-define/ProjectParameters.md` §1.2): the
   range must carry `idRangesSource` naming a box the human answered; if it is missing, or says
   the range was read from a file, **stop and ask the range question of Part 2 step 9 now**, then
   continue. The next free ID **of that object type** in that range (Ops § Object IDs — an ID is
   unique per type; Table 50100 and Page 50100 coexist, so a page never skips a number because a
   table holds it): the AL tools' next-object-ID tool for that type where the session has it
   (`al_getnextobjectid` in Copilot Chat), otherwise the highest ID of that type in `src/` plus
   one, or the range's first ID when the type has none — never the highest number across types —
   checked against every range. Never a number a symbol of the same type already uses. File name per
   Standards §1.8, under `src/` (a subfolder per feature is fine). Say the ID and the file name
   in the message that writes the file.
5. **Write the file, whole, once.** From the reference file's skeleton and the Standards sections
   it names: file header and `using` from the symbols (§1.1), `Rec.` qualification (§1.2),
   `Caption` + `ToolTip` + `ApplicationArea = All` on every page field (§1.4), no dead code (§1.5),
   four-space indentation (§1.6), labels never ML properties or `TextConst` (§1.7), enums never
   options (§1.9), camelCase API names (§2.7, §4.1), the Part 11 rules and the matching
   `ocpfFramework/patterns/` file for any child list, list part, setup page, or number-series
   field. Symbol-verify every standard table, field, page, and event you reference (Appendix B).
   Stage → **Built**. One file per Write; no narration between a table and its pages.
6. **Compile with the analyzers, to 0 errors / 0 warnings** (Ops § Analyzers; `al_build` or
   `ocpfFramework/scripts/al-analyze.*`), **and package nothing yet**. On a failure: check
   `ocpfFramework/patterns/` first, diagnose the root cause, fix, recompile. A fix that changes
   what the human confirmed in step 3 is said in one line, not silently applied, and
   `docs/DataModel.md` is updated. After a clean compile check what the editor shows (Ops § Editor
   Sync). Stage → **Compiled**.
7. **Document it now, not at the close** (Part 7's table): the object's §3 section in
   `docs/Documentation.md` (template `FeatureDocumentation.md` — purpose, what a user sees or does,
   rules, connections, file; written for a consultant, in full sentences), its register row
   completed with the file and *compiled*, its `docs/DataModel.md` section marked *compiled* (and
   §4 / §5 for a page, API, or permission set), and one line in `docs/ChangeLog.md` (case A:
   `docs/0-project/ChangeLog.md`) — date, object type, ID, name, file, *Build-a-Feature*. Stage →
   **Documented**. Two minutes at most; no research, no sub-agent.
8. **Close the window:** `completedAt`, `/ocpf-bc:usage --step <id>`, the rows pasted into the
   closing message, status `Completed`.
9. **The companion box (the options box at every close; Full Rule 6c / Lite Rule 6c apply here
   verbatim).** End the closing message with the offer the reference file names for this object,
   **four options at most** — for a table: *Both list and card pages (recommended)* / *List page
   only* / *An API page for it* / *Done with this table*. *Done* is always one of them. A chosen
   companion goes to the front of the plan and the loop continues at step 1. *Done* with objects
   still in the plan continues the plan; *Done* with an empty plan goes to Part 5 (the review
   offer), then Part 6 (the package offer) — in that order, each its own box.

Never generate a file that was not asked for or offered and accepted. Never publish to a tenant
in this journey; say that the package (Part 6) is what the human uploads.

## Part 5: Review, optional — offered BEFORE anything is packaged

When the plan is empty, and **before any package is built**, one box: **Review the code now
(recommended)** / *Skip the review*. Packaging (Part 6) is never started, and never offered,
until this box has been answered; a run that packages first has skipped a step.

- **Yes:** open window `FRV` (`title` `Review`). Fetch the BCQuality snapshot now, into a sibling
  folder outside the project root, exactly as Ops § Fetched Companions says (`git clone --depth 1`,
  `.git` stripped, `LICENSE` kept) — this is the one moment this journey fetches it. Review **the
  files written in this session only**, on the Main model, against three sources, in this order:
  1. the **Standards Guide** — §1.1–§1.9, Part 2 for any API object, §5.3–§5.4 for permission
     sets, Part 7's anti-patterns table in full, Part 11 for any child list or number-series field;
  2. **BCQuality** — its `skills/entry.md` dispatch flow with the explicit task context, folding
     its findings in as findings, never applied blind (Ops § Fetched Companions);
  3. the **AL Guidelines** (alguidelines.dev) *Best Practices* and *Vibe Coding Rules* for anything
     the Standards Guide does not cover; the Standards Guide wins on any conflict, said out loud.
  Present every finding in one message with its root cause and proposed fix, then one box:
  **Apply all** / *Apply selected* / *Discuss first*. Nothing is applied before the answer.
  Applied fixes go through Part 4's compile (step 6) again and update the documents (step 7); each
  finding and its decision is one line in the ChangeLog. Close the window with its rows; stage
  **Reviewed** on every row the review covered. Then Part 6.
- **Skip:** stage stays **Documented**. Say in one line what a review would have checked. Then
  Part 6.

## Part 6: Package

After the review box (Part 5) is answered — and only then — one box: **Package it as a `.app`
now (recommended)** / *Not now — I'll build it from VS Code*.

- **Yes:** open window `FPK` (`title` `Package`); apply Ops § Packaging → *Version numbers*
  mechanically — a new extension builds its first package at `0.0.0.1` as `app.json` says;
  otherwise increment the fourth segment, write it back, and build; never twice at one version —
  into `outputAppPackage/<Name>_<version>.app`; **write `docs/SandboxInstall.md`** (case A:
  `docs/4-prove/SandboxInstall.md`) from its template (Ops § Packaging → *The sandbox install
  guide*) — the first package of the project writes the whole document, every later package
  rewrites §1 only (file, version, Schema Sync Mode, sandbox, dependencies); say the fixed
  *Package built* message block from Ops § Packaging, whose *Install:* line points at that
  document (the human uploads; the agent never does unprompted); write the version into the
  **Shipped in** column of every row whose column is still blank (a row already shipped keeps its
  first version); one ChangeLog line with the version and the Schema Sync Mode; close the window
  with its usage rows. On a second package later in the same session (a fix found after
  packaging), the `FPK` row gets a second window; its stage shows the latest version.
- **No:** say how to build it (`AL: Package` in VS Code) and that the version rule still applies;
  no install guide is written for a package the agent didn't build.

Then, **only when a package was built and the extension is new (`0.x`):** one box — *The
package is tested and approved — build the release candidate 1.0.0.0 now* / *Not yet — I'll test
it first (recommended)*. On yes: set `1.0.0.0`, package again under the same rules, record it. On
*Not yet*: say in one sentence that the next time they return to this project with
*Build a feature in this project*, the first box offers the 1.0.0.0 build if they confirm the
`0.x` package was tested and approved. For an existing extension the release candidate is the
next Minor (or Major) from the starting version, proposed the same way.

## Part 7: Close

**The documents are already written** — that is the point of steps 3 and 7 of the loop. The
close finishes them, in two minutes at most, from what the session knows, no research, no
sub-agent. **Six files, in a flat `docs/` folder — no phase folders on this journey**:

| File | Template | Finished at the close with |
|---|---|---|
| `docs/ProblemStatement.md` | none — Lite Step 1's shape | the plan as built against the plan as asked; what was left out |
| `docs/FeatureRegister.md` | `FeatureRegister.md` | §1 current (version, packages), every §2 row *compiled*, §3, §4 complete |
| `docs/DataModel.md` | `FeatureDataModel.md` | the `erDiagram` redrawn from the code, every section *compiled*, §4–§6 complete |
| `docs/Documentation.md` | `FeatureDocumentation.md` | §1 what it does, §2 how to use it step by step, §4 how the objects fit, §5 API, §6 permissions and setup, §7 limitations and next steps — the parts that span objects |
| `docs/ChangeLog.md` | `ChangeLog.md` | the review and package lines |
| `docs/SandboxInstall.md` | `SandboxInstall.md` | §1 for the last package (only when one was built) |

Render the diagram **only if `ocpfFramework/framework.json` already records `tooling.mermaid` as
`npx-cached` or `installed`** (a Full or Lite project that ran Ops § Tooling Checks); otherwise
leave the source block, add one line under it — *not rendered here; GitHub and VS Code render
Mermaid* — and **never run the tooling ladder or offer an install at a quick mod's close**: a
cold `npx` pulls mermaid-cli and a browser, minutes, and the promise here is two. **Case A (a
Full or Lite project):** the same documents sit beside the project's own, in its phase folders —
`docs/1-define/FeatureRegister.md` next to `ObjectRegister.md`, `docs/2-design/DataModel.md`,
the Documentation sections under a `## Build-a-Feature` heading in the existing
`docs/4-prove/Documentation.md` (Full) or `docs/4-prove/Docs.md` (Lite), the problem-statement
section in the existing `docs/1-define/ProblemStatement.md`, the lines in
`docs/0-project/ChangeLog.md`, `docs/4-prove/SandboxInstall.md` — never replacing anything. Stage
all of it with the rest (`git add`, never committed by the agent).

The closing message, in this order: what was built (type, ID, name, file, one line each); the
documents, by path, with one sentence on what to read first (`docs/Documentation.md`); the
package path and version if one was built; the usage rows of the session (run `/ocpf-bc:usage`
without `--step` once so every `F` row is current; paste the session's rows); the dashboard path;
and the last box: **Done** / *Build another object* (back to Part 3's question) / *Open the
dashboard*. The exit condition of the journey is that every `F` row is `Completed` with its usage
rows present, every object has its section in `docs/Documentation.md` and `docs/DataModel.md`,
`ProjectProgress.md`, `docs/`, and both dashboard pages are staged, and nothing is left `In
Progress` — except, on a Full or Lite project whose step was `In Progress` when the journey
began (Part 0), that step's window reopened — append `{ "step": "<that step>", "startedAt":
"<now>" }` (a reopened step is a second window, summed) — and its row `In Progress` again.

## Resuming

A new session on a feature project (case B) or a framework project with a feature table (case A)
continues: the `start` skill's *Build a feature in this project* lands here; `status` reports the
feature rows. A row left `In Progress` is re-asked through its last box (Ops § Asking and
Approvals → *Interrupted and resumed*). New ids continue from the highest. `feature.json`'s
sources are checked before the first allocation, as always.

## What this journey never does

No FRD, TDD, Design Doc, Sanity Check, estimates, test script, user guide, or acknowledgements
file (the six documents above are the whole record); no translation files (source labels only;
`TranslationFile` stays on so the `.g.xlf` is generated for whoever adds languages later); no
publish to a sandbox or a tenant; no AppSource target; no sub-agents; no usage calibration export
unless asked; no publisher or ID range from anywhere but a box the human answered. **No help-site offer** — the polished HTML documentation site is Full Step 11's and
Lite Step 6's offer (the `html-docs` skill), never a quick mod's; a human who asks for one on a
feature project gets it on request (`/ocpf-bc:html-docs`, which asks which tabs —
`docs/Documentation.md`, a User Guide and an FAQ written then — and about screenshots). If the intake
turns into a whole process — posting, documents, a wizard, a solution with several modules — say
so in one sentence and offer Lite (an existing app without a large footprint) or Full (a complete
solution): the work so far is kept, and both read `app.json`, `src/`, and `docs/` as an existing
app at their first step.
