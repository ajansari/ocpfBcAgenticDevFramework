---
name: build-a-feature
description: The Build-a-Feature journey of the OCPF BC Agentic Development Framework - one object, or a few, in a new or existing Business Central per-tenant extension, with no documents and no steps. A table and its list and card pages, a table or page or report extension, a report, an API page or API query, a query, an enum or enum extension, a codeunit, a permission set or permission set extension. Asks what to build in one question, infers and confirms field types, writes the AL from the Standards Guide and the patterns library, compiles clean with the analyzers, offers the natural next object, offers to package a .app and to review the code, and keeps the live dashboard and the usage table current. Reached through /ocpf-bc:start (the third choice beside Full and Lite, or "Build a feature in this project" on a project that already follows the framework); use it directly when the user says "just add a table", "add a field to the Customer Card", "I need an API page for", "create an enum", "quick mod", or runs /ocpf-bc:build-a-feature.
---

# Build-a-Feature

**Follow `Ops § Build-a-Feature` in the Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`;
fetched below if the project has none yet). That section is the journey's rules and the reasons
behind them; this skill is the procedure. Everything else in the framework still applies where
it is cited: **Standards §** is the OCPF AL Development Standards Guide, **Ops §** the Operations
Guide, and the patterns library is `ocpfFramework/patterns/`.

**What this journey is.** Quick mods, not whole solutions. The human already knows what they
want: one object, or a handful. The journey jumps straight to it. There is no runbook, no step
list, no FRD or Design Doc, no test script, no translation files beyond the source labels, and no
publish step. What it keeps from the framework is the quality of the code (the Standards Guide
and the patterns library at writing time; the analyzers at compile time), the record
(`ProjectProgress.md`'s feature table and the usage rows), the live dashboard, and the options box
at every close.

**Where it is reached.** The `start` skill offers it as the third edition beside Full and Lite,
recommends it first on an existing extension that never used the framework, and offers *Build a
feature in this project* on a project that already follows the framework.

**One model.** The Main model does everything here: asks, writes, compiles and fixes, reviews.
No Light, Reasoning, or Generator sub-agent is used, even on a Full project that has them.

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

## Part 1: Where you are

Decide which of these applies before asking anything. Read, don't ask.

| Case | How you know | What it means |
|---|---|---|
| **A. Framework project** | `ocpfFramework/framework.json` exists with `edition` `full` or `lite` (or a `CLAUDE.md` / `.github/copilot-instructions.md` starting `# BC App Build Routine`) | The project's parameters, prefix, namespace, ID ranges, models, notifications, dashboard, and `ProjectProgress.md` already exist. Reuse all of it. Add nothing to the project's documents except one ChangeLog line per object. |
| **B. Feature project** | `ocpfFramework/framework.json` exists with `edition` `feature` | A previous Build-a-Feature session. Continue: ids continue from the highest `F` row in `ProjectProgress.md`. |
| **C. Existing extension, no framework** | `app.json` exists, no `ocpfFramework/` | Read `app.json` and `src/` for everything that can be read (Part 2); ask only what cannot. |
| **D. Empty or new folder** | no `app.json` | A new per-tenant extension. Part 2 asks the identity and range questions, once. |

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
   document templates except `ProjectProgress.md`'s** (step 13). BCQuality is fetched only when
   the human chooses a review (Part 6).
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
4. **Notifications** (B, C, D): the `notifications` skill, right after the language.
5. **Identity, new extension only (D)**, one box, three questions (Ops § Intake → *Box 0*):
   extension name (suggestions from the human's wording + *I'll type it*), publisher (only a
   name they already wrote, else *I'll type it*, never inferred), app icon (*Yes — I'll provide an
   image* / *No icon* / *Later*). Write `app.json` at once: `name`, `publisher`, `logo` when
   given, `version` `0.0.0.1`, a new `id`, platform defaults; create `src/`.
   **Existing extension (C):** keep `app.json` as it is. Its `version` is the installed version;
   confirm it with one question — *`<version>` is what's installed in the target environment* /
   *I'll type the installed version* — and write the answer back (Ops § Packaging → *Version
   numbers*).
6. **Dashboard, the moment `app.json` exists** (B, C, D; A already has it): the `dashboard` skill
   — render, `--open`, hooks, and the one explanation question (*I understand* / *Other*) with
   Ops § Dashboard's text, adding one sentence: *On this journey the Build Map shows one row per
   object you ask for, with its stage, its time, and its cost, instead of the framework's steps.*
7. **Main model and effort** (B, C, D; A has them recorded): the `roles` skill, Lite's two
   questions (Main model, Main thinking effort), after its one-sentence High-effort warning. On
   edition `feature` the `roles` skill writes **no** sub-agent copy — this journey delegates to
   none. Record the answer in `ocpfFramework/state/feature.json` (`{"mainModel", "mainEffort",
   "workingLanguage"}`) — there is no `ProjectParameters.md` here. Say which model the session
   is running on and have the human switch before continuing if it differs.
8. **GitHub Copilot in use?** Ask the two Copilot session-settings questions (Ops § Asking and
   Approvals → *GitHub Copilot session settings*) and write `.vscode/settings.json` and
   `ocpfFramework/state/copilot.json`. Case A has them.
9. **Naming and range, one box** (C where it cannot be read, D always): **Deployment Target**
   (*SaaS PTE* / *OnPrem PTE*; AppSource is not a Build-a-Feature target — say so and offer
   Full), **AL object prefix** (two or three short lowercase suggestions from the name and
   publisher), **namespace** (`<Publisher>.<ExtensionShort>` recommended / *No namespace*),
   **object ID range** (a range the human's material names / *50100–50149 — the AL template's
   default, only if no range has been assigned* / type `start–end`). Then the **Permission Set
   App Code** (Standards §5.4, two or three uppercase suggestions that fit `13 − prefix
   length`), only when a permission set is built or a table makes one necessary (Part 4). Case C
   reads the prefix and namespace from the existing objects (the first `namespace` line; the
   common object-name prefix) and the ranges from `app.json` `idRanges`, and asks only to confirm
   what it read — one question, *That's right* first.
10. **Complete `app.json`** (C: only what is missing; D: all of it): `idRanges`, `platform`,
    `application`, `runtime` (read from Microsoft Learn's runtime table, never from memory),
    `features` `["NoImplicitWith", "TranslationFile"]` (Standards §8.2), `target`. Keep `id`,
    `name`, `publisher`, `logo`, `version` as they are.
11. **Folders and ignore list** (C, D): `outputAppPackage/`; the always-ignored block of Ops §
    Repository Hygiene in `.gitignore` (the framework-files block too, with the *Yes* default —
    ask only if the human objects); `.vscode/settings.json` with the analyzers for the Deployment
    Target (Ops § Analyzers); `ocpfFramework/scripts/al-analyze.*` outside Copilot Chat. Prove the
    ignore list with `git check-ignore` as Ops § Repository Hygiene says; the dashboard pages and
    `ProjectProgress.md` must **not** be ignored.
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
    Then open the intake window: append `{ "step": "F00", "title": "Intake", "startedAt": "<now>" }`
    to `ocpfFramework/state/usage.json` (create the file as the `usage` skill's Step 1 says if it
    is missing; `aiTool`, `transcriptDir`) and write the `F00 | Intake` row `In Progress`. Read
    `references/feature-record.md` for the table's exact shape and the id rules.
    **Case A, a step still `In Progress`:** an open window ends where the next one starts (Ops §
    Usage & Cost → 1), so opening `F00` closes that step's window. Say so in one line, note the
    step id, and at Part 7 **reopen it** — append `{ "step": "<that step>", "startedAt": "<now>" }`
    (a reopened step is a second window, summed) — so the step's later work is attributed and the
    dashboard's clock returns to it.

That is the whole setup. Nothing from PRE-01 / Lite Step 1 beyond this: no parameter sheet, no
problem statement, no estimates, no translation questions.

## Part 3: Intake — "What do you want to build today?"

1. **Look before asking.** If `requirements/` exists, or the human pointed at a file, a ticket, or
   a message, read it first. If it fully describes the object(s), skip to the confirmation in
   Part 4 with everything pre-filled and say where each answer came from. If it is partial,
   pre-fill what it gives.
2. **One question, the only free-text one.** Through the options mechanism:

   > **What do you want to build today?**
   > - *A new table — with its list and card pages* (the most common quick mod)
   > - *Extend a standard table or page — add fields or columns*
   > - *An API page or API query*
   > - *Something else — a report, an enum, a query, a codeunit, a permission set, an extension of one of those — I'll say which*

   *Other* / free text is where the human types what they want in their own words, for example
   *"a new table Rental Unit with No., Description, Start Date, Amount, and a card page"*. In the
   Copilot CLI, where a typed answer needs its own option, drop the third preset (an API object
   is typed, or chosen under *Something else*) and make *I'll type it* the fourth.
3. **Parse the answer** into a plan of one or more objects, in build order (lookups and enums
   before the tables that use them; tables before their pages, API pages, and permission grants;
   a table extension before the page extension that shows its fields). Recognise the usual
   phrasings: *"add a field to the Customer Card"* is a table extension **and** a page extension;
   *"add a column to the Customer List"* is a page extension, plus a table extension if the field
   is new; *"a status on the table"* is an enum plus a field. Pull out names, fields, and any
   types the human gave. A follow-up with preset options settles only what the free text left
   genuinely open (which base table, which page, list or card or both).
4. **Say the plan back in one short list** — object type, name, what it will hold — and go to
   Part 4 with the first object. No approval box here: the per-object confirmation in Part 4 is
   where the human says yes.

Close the intake window when the first object's window opens: set `F00`'s `completedAt`, run
`/ocpf-bc:usage --step F00`, paste the rows, mark the row `Completed`.

## Part 4: The object loop

For each object in the plan, in order. Each object is one row and one usage window.

1. **Open the window.** Next id (`F01`, `F02`, … continuing from the highest existing row).
   Append `{ "step": "<id>", "title": "<Type> <Name>", "startedAt": "<now>" }` to `usage.json`;
   add the row to the feature table with stage **Asked**, status `In Progress`. The dashboard
   picks it up by hook (Copilot Chat: render once, `--quiet`).
2. **Read the object's reference file** — `references/objects/<type>.md` — in full. It says what
   this object needs, how to infer and validate it, which Standards sections and patterns files
   to read before writing, the skeleton to write from, the pre-flight checks, and the companion
   offer. Read `references/field-types.md` with it for any object that has fields.
3. **Ask or confirm, in one box where possible.** Infer first, confirm second (Ops §
   Build-a-Feature → *Infer, then confirm*). Types the human gave are validated, not re-asked;
   come back only on something wrong or non-standard, with the recommended fix as the first
   option. Types the human did not give are inferred from the field names and shown as one
   table in one question: *Looks right — build it* / *Change something* (then only what
   changes). Only a field that genuinely cannot be inferred gets a question of its own. The
   primary key is always confirmed. Stage → **Confirmed**.
4. **Allocate the ID and the file name.** The next free ID in `app.json`'s `idRanges` — the AL
   tools' next-object-ID tool where the session has it (`al_getnextobjectid` in Copilot Chat),
   otherwise the highest ID of that type in `src/` plus one, checked against every range. Never a
   number a symbol already uses. File name per Standards §1.8, under `src/` (a subfolder per
   feature is fine). Say the ID and the file name in the message that writes the file.
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
   what the human confirmed in step 3 is said in one line, not silently applied. After a clean
   compile check what the editor shows (Ops § Editor Sync). Stage → **Compiled**.
7. **Close the window:** `completedAt`, `/ocpf-bc:usage --step <id>`, the rows pasted into the
   closing message, status `Completed`. **Case A: one line in `docs/0-project/ChangeLog.md`**
   — date, object type, ID, name, *Build-a-Feature* — nothing more.
8. **The companion box (the options box at every close; Full Rule 6c / Lite Rule 6c apply here
   verbatim).** End the closing message with the offer the reference file names for this object,
   **four options at most** — for a table: *Both list and card pages (recommended)* / *List page
   only* / *An API page for it* / *Done with this table*. *Done* is always one of them. A chosen
   companion goes to the front of the plan and the loop continues at step 1. *Done* with objects
   still in the plan continues the plan; *Done* with an empty plan goes to Part 5.

Never generate a file that was not asked for or offered and accepted. Never publish to a tenant
in this journey; say that the package (Part 5) is what the human uploads.

## Part 5: Package

When the plan is empty, one box: **Package it as a `.app` now (recommended)** / *Not now — I'll
build it from VS Code*.

- **Yes:** open window `FPK` (`title` `Package`); apply Ops § Packaging → *Version numbers*
  mechanically — a new extension builds its first package at `0.0.0.1` as `app.json` says;
  otherwise increment the fourth segment, write it back, and build; never twice at one version —
  into `outputAppPackage/<Name>_<version>.app`; say the fixed *Package built* message block from
  Ops § Packaging; write the version into the **Shipped in** column of every row whose column is
  still blank (a row already shipped keeps its first version); close the window with its usage
  rows. On a second package later in the same session
  (a fix after a review), the `FPK` row gets a second window; its stage shows the latest version.
- **No:** say how to build it (`AL: Package` in VS Code) and that the version rule still applies.

Then, **only when a package was built and the extension is new (`0.x`):** one box — *The
package is tested and approved — build the release candidate 1.0.0.0 now* / *Not yet — I'll test
it first (recommended)*. On yes: set `1.0.0.0`, package again under the same rules, record it. On
*Not yet*: say in one sentence that the next time they return to this project with
*Build a feature in this project*, the first box offers the 1.0.0.0 build if they confirm the
`0.x` package was tested and approved. For an existing extension the release candidate is the
next Minor (or Major) from the starting version, proposed the same way.

## Part 6: Review, optional

One box: **Review the code now (recommended)** / *Skip the review*.

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
  Applied fixes go through Part 4's compile (step 6) again; a package built before the fix is
  superseded by a new one (Part 5, `FPK` reopened). Close the window with its rows; stage
  **Reviewed** on every row the review covered.
- **Skip:** stage stays **Compiled** (or **Packaged**). Say in one line what a review would have
  checked.

## Part 7: Close

The closing message, in this order: what was built (type, ID, name, file, one line each); the
package path and version if one was built; the usage rows of the session (run
`/ocpf-bc:usage` without `--step` once so every `F` row is current; paste the session's rows);
the dashboard path; and the last box: **Done** / *Build another object* (back to Part 3's
question) / *Open the dashboard*. The exit condition of the journey is that every `F` row is
`Completed` with its usage rows present, `ProjectProgress.md` and both dashboard pages are
staged (`git add`, never committed by the agent), and nothing is left `In Progress` — except,
on a Full or Lite project whose step was `In Progress` when the journey began (Part 2 step 13),
that step's window reopened and its row `In Progress` again.

## Resuming

A new session on a feature project (case B) or a framework project with a feature table (case A)
continues: the `start` skill's *Build a feature in this project* lands here; `status` reports the
feature rows. A row left `In Progress` is re-asked through its last box (Ops § Asking and
Approvals → *Interrupted and resumed*). New ids continue from the highest.

## What this journey never does

No FRD, TDD, Design Doc, Sanity Check, estimates, test script, documentation, user guide, or
acknowledgements file; no translation files (source labels only; `TranslationFile` stays on so
the `.g.xlf` is generated for whoever adds languages later); no publish to a sandbox or a
tenant; no AppSource target; no sub-agents; no usage calibration export unless asked. If the
intake turns into more than a handful of related objects, or a whole process (posting, documents,
a wizard, a role center), say so in one sentence and offer Lite — the work so far is kept, and
Lite's Step 1 reads `app.json` and `src/` as an existing app.
