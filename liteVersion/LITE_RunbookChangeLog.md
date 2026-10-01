# Lite Edition — Changelog

Tracks changes to the **Lite Edition** of the Agentic Development Framework
(`LITE_BC_App_Build_Routine_Agent.md`) — independent of any single project built with it. This is
a separate changelog from the full framework's own `fullVersion/RunbookChangelog.md` (a sibling
folder), even though a change to one often has to be reflected in the other — Lite is a derived
edition, not a fork, and the two are expected to stay in sync on anything that isn't specifically a
process-reduction. The Lite Edition is versioned independently of the full framework; check the
header of `LITE_BC_App_Build_Routine_Agent.md` for which full-framework version it's currently
derived from.

Entries are grouped by version, newest first, and describe the **cumulative** result of a
version's changes — not the drafting history behind them; only the final, current form of a
change is recorded, matching the convention `fullVersion/RunbookChangelog.md` uses for the full
framework.

---

## v5.0.0.0 — September 27, 2026

Derived from full framework **v5.0.0.0**; Standards Guide **v1.11.0.0** (Appendix B only);
Operations Guide **v5.0.0.0**; plugin **v5.0.0**. The September 27 improvements round, applied to
Lite. A major version because the project layout changes and a project in progress needs a
migration (below). **Lite jumps from 3.1.0.0 to 5.0.0.0:** from this release the Full runbook,
Lite, the Operations Guide, and the plugin carry one version number, so "which version" has one
answer across the framework. No Lite 4.x was ever released.

### Changed

- **One folder for everything the framework fetches or keeps: `ocpfFramework/`.** The guides,
  step files, templates, patterns, and scripts move from the project root into
  `ocpfFramework/<same>`; `.ocpf/framework.json` becomes `ocpfFramework/framework.json` and the
  rest of `.ocpf/` becomes `ocpfFramework/state/` (`usage.json`, `pricing.json`,
  `notifications.json`, `copilot.json`, `previous/`); `LITE_RunbookChangeLog.md` and
  `LITE_RunbookSchematics.md` live in `ocpfFramework/` too. When a `CLAUDE.md` already existed,
  the runbook itself goes to `ocpfFramework/LITE_BC_App_Build_Routine_Agent.md` and `CLAUDE.md`
  holds the one line `@ocpfFramework/LITE_BC_App_Build_Routine_Agent.md`. Step 1 writes the
  six-line `ocpfFramework/README.md`. Hooks and `.mcp.json` point at
  `ocpfFramework/scripts/`.
- **`docs/` is laid out by phase, numbered.** `docs/0-project/` (`ChangeLog.md`,
  `Acknowledgements.md`), `docs/1-define/` (`ProblemStatement.md`, `ProjectParameters.md`),
  `docs/2-design/` (`DesignDoc.md`, `HumanEffortEstimate.md`, `AiEffortEstimate.md`),
  `docs/4-prove/` (`Docs.md`, `TestScript.md`, translated copies beside their source); Lite
  leaves `3-build/` unused. The header note lists the layout; every step names the full path.
- **All AL source lives under `src/`**, subfolders per module allowed, the app icon in
  `src/logo/`; nothing but `app.json`, `.gitignore`, `CLAUDE.md`, the tool folders,
  `Translations/`, `src/`, `docs/`, `requirements/`, `outputAppPackage/`, `ProjectProgress.md`,
  and `ocpfFramework/` in the root.
- **The `.gitignore` block has two groups** (Ops § Repository Hygiene): always ignored
  (`.claude/settings.local.json`, `ocpfFramework/state/`, the fetched guides, steps, templates,
  patterns, and scripts, `.alpackages/`, `*.g.xlf`), and — with Step 1's *Yes* — `ocpfFramework/`
  as a whole, the runbook under its names, and the project-local sub-agent definitions. Never
  `docs/`, `requirements/`, `src/`, `ProjectProgress.md`, `outputAppPackage/`, `*.app`, or
  `Translations/*.xlf`.
- **Operating Rule 2** — the downloaded symbols are the only routine lookup. Microsoft Learn's
  Base Application and System Application reference is consulted only when symbols couldn't be
  downloaded, when the object, field, method, or event isn't in them, or when a code pattern,
  snippet, or event signature is needed — never as a second check, never "to be safe", and the
  agent says why each time. ALL ALONG → Reference Sources says the same.
- **Step 1's model question** opens with the warning that a High thinking effort makes every task
  slower, and recommends **Sonnet, Medium** in Claude Code and **Gemini 3.8 Flash, Medium** in
  GitHub Copilot, offered first; the parameter row matches. The generator sub-agent inherits the
  pair.
- **Version numbers** (ALL ALONG → Packaging & Versioning; Ops § Packaging → *Version numbers*):
  a new app starts at **`0.0.0.1`** (new Version parameter row; an existing app starts from the
  installed version); the first build of a new app goes out at `0.0.0.1` as written, an existing
  app's first build increments from the installed version, and every build after the first
  increments the Revision mechanically with no approval *(clarified October 1)*; never two builds at one version (`al-analyze.*` refuses to overwrite, exit
  code 4); Major, Minor, and Build bumps stay proposed and approved. Step 6 ends by asking
  **Build the release candidate v1.0.0.0 now? (recommended)** / **Keep testing on 0.x builds**;
  fixes during release testing continue `1.0.0.1`, `1.0.0.2` …; **the package that passes Step 7
  ships as it is.** The old "bump its Build segment or copy to an immutable name" rule is gone
  from Step 7 and the Packaging section.
- **A fixed message after every build**, Steps 5–7: `Package built: …` with the previous build,
  the Schema Sync Mode line (Add, or Force Sync with what changed and where data can be lost),
  and the upload path through Extension Management. The main agent records "last installed
  version" in the ChangeLog each time the human confirms an upload.
- **Step 3 with two batches asks three ways** (Rule 6a): **parallel — one generator per batch,
  all at once (recommended)** / **one batch at a time** / **ask me before each batch**; every ID
  and file name is fixed in the batch plan before anything is generated. The translation-tooling
  bullet points at Ops § Tooling Checks for PowerShell 7.
- **Step 4 can generate both batches in parallel**: one background `ocpf-generator` sub-agent per
  batch, on the Main model and effort, each briefed with the generation rules, its batch's Design
  Doc sections, the parameters, Standards §1.1–§1.8 and §2 (Part 11 and the patterns files where
  needed), and the symbol source; it writes only its batch's files under `src/`. Lite has no
  light role, so the main agent runs the post-generation pre-flight on each batch as its generator
  returns, then integrates the Object Register, ChangeLog, and open questions. Sequential fallback
  where the harness can't run parallel sub-agents. Six speed rules apply in every mode: recorded
  effort (Medium by default), one complete file per write, no narration between files, the exact
  template text in the brief, symbols verified once per batch, and fast mode offered once with
  Opus in Claude Code.
- **Step 6** grades the eight-dimension code-review scorecard (A–F with the rubric, overall the
  lowest) and writes the table into its ChangeLog entry, since Lite has no `CodeReview.md`; the
  mermaid render check points at Ops § Tooling Checks (never `which mmdc`); it writes
  `docs/0-project/Acknowledgements.md` from its template; and it ends with the release-candidate
  question before the hand-off.
- **Step 7's hand-off notes** no longer say "Lite keeps no `ProjectProgress.md`": the closing
  reminder is the Full wording — set the Step 7 row to `Completed`, the final usage refresh, the
  calibration export. The exit gate restates Schema Sync Mode in the fixed message block. The
  translated-copy paths read `docs/4-prove/Docs.<culture>.md` and
  `docs/4-prove/TestScript.<culture>.md`.
- **Rules 6a, 6b, 6d** name the parallel-batches and release-candidate questions as 6a decisions
  and point tooling installs (Node, mermaid-cli, PowerShell 7) at Ops § Tooling Checks; Rule 4
  notes the per-batch post-generation pass in parallel mode.
- **ALL ALONG → OCPF Plugin**: the marker is `ocpfFramework/framework.json` (with `layout` and
  `tooling`); the plugin's `ocpf-generator` sub-agent is used by Lite for parallel batches; the
  `status` skill reads `ProjectProgress.md`; the `usage` skill takes `--step <id>`.
- **Step Map** — Lite's document set now counts `ProjectProgress.md`, two estimates, and
  `Acknowledgements.md`; the Standards Guide is v1.11.0.0.

### Added

- **`ProjectProgress.md` in the project root — Lite has it now.** Created at Step 1 from
  `documentTemplates/ProjectProgress.md` (the agent keeps the *Lite* step table, STEP-1 … STEP-7,
  and deletes the *Full* one); every step sets its row to `In Progress` at start and `Completed`
  at close; new ALL ALONG section **Project Progress Tracker**. **`docs/UsageReport.md` is
  retired**: the usage table is `ProjectProgress.md`'s second table, and the ALL ALONG heading is
  now *Usage & Cost Tracking — `ProjectProgress.md`, second table*.
- **Operating Rule 9 — usage at every step boundary** (Ops § Usage & Cost → 5): start timestamp
  and `In Progress` row in one message; at close, `completedAt`, the measurement
  (`/ocpf-bc:usage --step <id>` or the Ops procedure), and **one row per model that ran in the
  step**, pasted into the closing message. The exit gate is not met until the rows exist; a Claude
  Code row is never hand-written.
- **Step 2 also writes `docs/2-design/AiEffortEstimate.md`** — tokens per step × model × token
  type, cost at the fetched prices, wall-clock from Step 3 on with approvals at 30 minutes each
  (and the sentence that says so), the margin (±30 % until three measured projects sit in
  `~/.ocpf/calibration/`). The Human Effort Estimate takes its hours from
  `documentTemplates/HumanEffortBaselines.md`, replaced by `~/.ocpf/HumanEffortBaselines.md` when
  the partner has one, and names which applied. Step 2's exit gate checks both estimates.
- **Step 1 asks about the app icon** (Box 1a, question 4a: *Yes — I'll provide an image* / *No
  icon* / *Later*). On yes, the image is copied to `src/logo/AppLogo.png`, resized to 300 px
  keeping proportions (padded to square, never cropped silently), `app.json` gets the `logo`
  entry, and the file is committed. The old AppSource icon question folds into this one.
- **Tooling Checks** — a short ALL ALONG entry pointing at Ops § Tooling Checks for Node,
  mermaid-cli, and PowerShell 7, read at Step 3 and Step 6; outcomes recorded in
  `ocpfFramework/framework.json` → `"tooling"`.
- **Templates**: `AiEffortEstimate.md`, `HumanEffortBaselines.md`, and `Acknowledgements.md`
  arrive; `UsageReport.md` goes away. `ProjectProgress.md` carries both editions' step tables.

### License — PolyForm Shield 1.0.0 (October 1, 2026)

- The framework — runbooks, guides, templates, plugin, scripts, and this changelog — is released
  under the **PolyForm Shield License 1.0.0** (`LICENSE`;
  <https://polyformproject.org/licenses/shield/1.0.0>), copyright AnsariCo, Inc. dba
  OnlyCopilotFans and OnlyBCFans. Source-available and free to use: build free or commercial
  Business Central extensions with it, PTE or AppSource; the one reservation is providing a
  product that competes with the framework. README → License.

### Changed — GitHub Copilot usage is measured in AI credits (added September 29, 2026)

- **Copilot rows are measured, in their own table.** Since GitHub's June 1, 2026 billing change
  Copilot bills in **AI credits**, not premium requests, and VS Code records them per turn and per
  model, sub-agents included, in its chat session files. The usage script reads those
  (`/ocpf-bc:usage --step <id>`, the same command as in Claude Code) and writes the **GitHub
  Copilot — AI credits** table of `ProjectProgress.md` — ten columns, no token columns; a project
  keeps the table for its tool. Operating Rule 9 and ALL ALONG → Usage & Cost Tracking carry the
  Full wording: never a hand-written row in either tool, and in Copilot the step close is also
  the **checkpoint** that separates one step's credits from the next.
- **Fallback:** when the session files can't be read, the human reads *Session Cost* in the chat's
  Session Info popover and the script records that one number, without a model breakdown.
- **Step 2's AI Effort Estimate** shows a Copilot project's estimate in AI credits as well.
  `pricing.json` gains `aiCredit`, fetched and dated. Ops § Usage & Cost.

### Migration — projects on Lite < 5.0.0.0

The plugin's `update-framework` skill does it on *Update now*: creates `ocpfFramework/`, moves
`.ocpf/*` into `ocpfFramework/state/` (`framework.json` to `ocpfFramework/`), moves the guides,
step files, templates, patterns, scripts, changelog, and schematics, `git mv`s every `docs/*.md`
into its phase folder, rewrites the `.gitignore` block, `.mcp.json`, and the hook paths, creates
`ProjectProgress.md` from the template **carrying the usage table over from `docs/UsageReport.md`**
and then removes that file, writes the six-line `ocpfFramework/README.md`, and logs every move in
a ChangeLog entry. Without the plugin, the same list by hand. AL source already in the root moves
to `src/` at the same time.

### Schematics

- `LITE_RunbookSchematics.md`: Step 1 shows `ProjectProgress.md`, the phase folders, `src/`, and
  the app icon; Step 2 the two estimates; Step 3 the generation-mode question; Step 4 the parallel
  branch; Step 5 the Revision increment and the fixed build message; Step 6 the scorecard,
  Acknowledgements, and the release-candidate question; Step 7's gate ships the tested package
  as it is; ALL ALONG gains the Project Progress Tracker and Tooling Checks.

---

## v3.1.0.0 — September 21, 2026

Derived from full framework **v4.1.0.0**; Standards Guide **v1.10.0.0**; Operations Guide
**v2.0.1.0**. Same change as Full v4.1.0.0 — see `fullVersion/RunbookChangelog.md` for the two
real-run failures behind it (a number-series field with no lookup; a child created from its
parent's page that lands "outside the filter").

### Changed

- **Step 2** — the per-object spec names each child table's link field, pages, and opening
  mechanism (Standards §11.1) and each numbered table's setup field and pages (§11.2); "no.
  series" and "events" leave the list of patterns the Standards Guide doesn't cover, and the
  list now reads as Full's does ("error handling, facades, and similar").
- **Step 3** — the batch plan marks child lists and list parts, setup pages, and wizards; Step 4
  reads Standards Part 11 and the matching `patterns/` files before generating them.
- **Step 4** — Action 4 applies Part 11 while writing client pages; Action 5's pre-flight checks
  §11.1 and §11.2.
- **Step 5** — every sandbox round includes the two §11.3 client checks; the "view is filtered"
  banner and a series field with no dropdown are defects, never warnings.
- **Step 6** — the code-review bullet checks every child list or list part against §11.1 and every
  number-series field against §11.2, as Full Step 09 does; `docs/TestScript.md` carries one
  green-team case per parent→child entry point and one per number-series field.
- **ALL ALONG → OCPF BC AL Patterns Library** — "Using it" now says *before writing, and before
  diagnosing*.
- Templates `DesignDoc.md` and `TestScript.md` updated as in Full.

## v3.0.0.0 — September 19, 2026

Derived from full framework **v4.0.0.0**; Standards Guide **v1.9.0.0** (unchanged); Operations
Guide **v2.0.0.0**. The September 2026 *Major Improvements List*, applied to Lite. A major version
for the same reason as Full v4.0.0.0: the core is incomplete without `runbookSteps/` and
`documentTemplates/`, so updating from 2.x is a refetch of the set, not a swap of one file.

### Changed

- **The runbook is a core plus one file per step.** `LITE_BC_App_Build_Routine_Agent.md` (~37 KB,
  down from ~73 KB) keeps the header, Operating Rules, a stub per step (its step file's Outputs and
  Exit gate paragraphs verbatim, kept in sync by `agentPlugin/tools/buildStubs.py`), and ALL ALONG; the full text
  of Steps 1–7 lives in `liteVersion/steps/STEP-1.md` … `STEP-7.md`, fetched into the project's
  `runbookSteps/` at Step 1 with the guides, always gitignored, each carrying a `**Runbook version:**`
  line. Read the step file in full when the step starts; never work from the stub.
- **Every document is written from its template** in `documentTemplates/` (fetched with the step
  files; Lite uses `DesignDoc.md`, `HumanEffortEstimate.md`, `ChangeLog.md`, `Docs.md`,
  `TestScript.md`, `UsageReport.md`). Ops § Documents; the plugin's `documents` skill.

### Added

- **Step 2 also produces `docs/HumanEffortEstimate.md`** — the billable hours an experienced senior
  AL developer would need for the same scope, by task, with baselines and stated assumptions, in
  the same pass as the Design Doc. Step 2's exit gate checks it.
- **Usage & Cost Tracking** (ALL ALONG; Ops § Usage & Cost): step timestamps in `.ocpf/usage.json`;
  tokens per model from Claude Code's transcripts, premium requests for Copilot, priced from fetched
  and dated published rates. Lite has no `ProjectProgress.md`, so the table is
  **`docs/UsageReport.md`**, created at Step 1 and refreshed at every exit gate. The plugin's
  `usage` skill measures it.
- **Copilot session settings at Step 1** (when Copilot is in use): the agent-mode request limit
  (150 recommended / 100 / default) and tool approvals (ask each time / allow the framework's own
  commands / allow everything), written to `.vscode/settings.json` and `.ocpf/copilot.json`
  (Ops § Asking and Approvals → *GitHub Copilot session settings*).
- **Always-ignored list** gains `runbookSteps/`, `documentTemplates/`, `.ocpf/copilot.json`,
  `.ocpf/usage.json`, `.ocpf/pricing.json`.
- **Step 7's hand-off ends with a reminder**, sent as an ordinary message after the hand-off box is
  answered: the closing `docs/ChangeLog.md` entry and the final `docs/UsageReport.md` refresh are
  still owed once the release test is done, so the next developer or AI tool doesn't find the
  project looking mid-release.

---

## v2.3.0.0 — September 18, 2026

Derived from full framework **v3.4.0.0**; Standards Guide **v1.9.0.0** (unchanged); Operations
Guide **v1.3.0.0**. Three fixes from one real run of the full framework, applied to Lite so they
can't recur here either.

### Added

- **Step 1 asks which model does the work, right after notifications.** Two questions in one box:
  the Main model (*Sonnet* recommended, free entry) and its thinking effort (*High* recommended /
  Medium / Low). The agent states the model the session is running on first — in Lite the one model
  *is* the session, and only the human can change it (`/model` and `/effort` in Claude Code, the
  model picker in Copilot) — and a different choice means the human switches and confirms before
  anything continues. Recorded in a new **Main model & thinking effort** parameter row, with the
  harness's own identifier. Lite has no Light or Reasoning roles, so none of the full framework's
  enforcement machinery applies; the one check is that the recorded model matches the session.
  The asking, and why it's the first step rather than the parameter sheet, is **Ops § Roles**.

### Changed

- **Every project document lives in `docs/`.** `docs/ProblemStatement.md`,
  `docs/ProjectParameters.md`, `docs/DesignDoc.md`, `docs/ChangeLog.md`, `docs/Docs.md`,
  `docs/TestScript.md`, and every translated copy. Previously the runbook named every file bare and
  said `ProjectParameters.md` went in the project root; on a real full-framework run that pattern
  put the design documents in the root. The folder is created at Step 1, every step now writes the
  full path, the root exceptions are listed once (`requirements/`, `app.json`, the AL source,
  `Translations/`, `outputAppPackage/`), and each exit gate checks the root — a document found
  there is moved with `git mv` and the move noted in `docs/ChangeLog.md`. A project on an earlier
  Lite version keeps its layout until it updates; the plugin's `update-framework` skill offers the
  move.
- **The framework-files `.gitignore` answer is applied by exact filename and verified.** The
  parameter row now lists every entry: the runbook under each name it may have, the changelog in
  both spellings as one pattern (`LITE_[Rr]unbook[Cc]hange[Ll]og.md`), `LITE_RunbookSchematics.md`,
  and `.ocpf/`, then `git check-ignore -v` on each existing file and `git status --porcelain` on
  the root before the step closes. The full block is **Ops § Repository Hygiene**. On the real run
  the changelog was left out and reached the client's remote.

### Schematics

- The Step 1 diagram in `LITE_RunbookSchematics.md` shows the Main model question and `docs/`;
  all 7 diagrams re-rendered clean with `@mermaid-js/mermaid-cli` 11.17.0.

---

## v2.2.0.0 — September 15, 2026

Derived from full framework **v3.3.0.0**; Standards Guide **v1.9.0.0**; Operations Guide
**v1.2.0.0**. Lite carries the same AL rules and the same corrections — it differs only in process.

### Corrected

- **The analyzer claim.** Lite said the AL MCP Server's compile tools "don't apply analyzers." In
  fact `al_build` never does, while `al_compile` does — but only with `enableCodeAnalysis: true`
  and a `codeAnalyzers` token list passed at the top level of `options`. Every other shape returns
  a clean pass on failing code, which is the more dangerous failure. `scripts/al-analyze.*` remains
  the mandatory compile (`al_compile` writes no `.app`). Full detail in **Ops § Analyzers**.

### Added

- **AppSource changes the intake.** The Deployment Target row now says so, and a new parameter row
  carries the manifest set (`brief`, `description`, `url`, `logo`, `privacyStatement`, `EULA`,
  `help`, `contextSensitiveHelpUrl`, and `applicationInsightsConnectionString` where given) — each
  mandatory for submission, with anything deferred recorded as a release blocker. The questions
  themselves are **Ops § Intake → *The AppSource questions***; the rules are **Standards
  Appendix E**.
- **The object ID range belongs to the deployment target** (**Standards §5.5**): PTE work uses
  50,000–99,999; AppSource uses only a publisher-registered range, never the customization range.
- **Upgrade and events are Design Doc content.** Part B now requires the upgrade plan — codeunits,
  triggers, upgrade tags, and the two-version obsolete cycle (**Standards Part 9**) — and the event
  inventory, published and subscribed (**Standards Part 10**). "No upgrade code needed" is written
  down with its reason rather than left silent.
- **Step 7 tests the upgrade path** before the human tests anything else, whenever this isn't the
  first release (**Standards §9.6**) — and a failed upgrade path fails the step.
- **Step 6 runs the AL tests.** If the project has test codeunits, the agent runs them with
  `al_run_tests` against the sandbox, one codeunit per call (**Ops § Automated Tests**), never
  against production. A failing test fails the step; an unconnected server is said plainly instead
  of reported as a pass. Added to the step and its exit gate.

### Changed

- **The Step 5 schematic's test node** now says what it actually means: testing is by hand by
  default, and agent-run only if round 1's offer was accepted *and* an HTTP-capable route exists —
  the AL MCP Server is not one. Re-rendered.

---

## v2.1.0.0 — September 15, 2026

**The agent can run the API checks from the first build of the fix cycle, if the human wants it.**
Derived from full framework v3.2.0.0. See `fullVersion/RunbookChangelog.md` v3.2.0.0.

### Changed

- **Step 5 asks once, at the first round**, whether the agent should publish and run the API
  checklist before the human tests, with the browser sign-in named in the offer. The answer is
  recorded in `ChangeLog.md` and honored for every later round; *No — I'll test by hand* isn't asked
  again, and Step 7's human pass is authoritative either way.

---

## v2.0.1.0 — September 15, 2026

**Reference update only.** Derived from full framework v3.1.0.0 and pointing at Operations Guide
v1.1.0.0, whose update check now fetches only the first kilobyte to read a version line and raises
updates at a step boundary. Lite's own steps, gates, and documents are unchanged. See
`fullVersion/RunbookChangelog.md` v3.1.0.0.

---

## v2.0.0.0 — September 15, 2026

**The procedures Lite shares with the full framework now live in the fetched OCPF Operations Guide,
cited as Ops §.** Lite drops from 14,439 to about 9,700 words and keeps its own sequence, checks,
and document set. Derived from full framework v3.0.0.0; Standards Guide v1.8.0.0; Operations Guide
v1.0.0.0. See `fullVersion/RunbookChangelog.md` v3.0.0.0 for the full reasoning.

### Changed

- **Step 1 fetches both companions** — `standardsGuide/` and `opsGuide/` — and both are always
  gitignored.
- **Each ALL ALONG section keeps its non-negotiables** and points at its **Ops §** section: AL
  tools, analyzers, symbols, editor sync, notifications, packaging, repository hygiene,
  translations, the fetched companions, and the plugin.
- **Step 1's intake questions, the project setup, and Step 5's translation cycle** point at
  Ops § Intake, Ops § Project Setup, and Ops § Translations. Lite's own boxes, gates, and four
  maintained documents are unchanged.
- **Steps name what to read**, in their Actions, and the gates that turn on one repeat it (Steps 3
  and 5 for Analyzers, Step 7 for Translations).

---

## v1.12.0.0 — September 15, 2026

**The human chooses at Step 1 how to be notified every time the agent finishes a turn, asks a
question, or waits for an approval — Claude app, sound, desktop notification, any combination, or
none — and the choice persists.** Derived from full framework v2.15.0.0; Standards Guide unchanged
at v1.7.0.0. See `fullVersion/RunbookChangelog.md` v2.15.0.0 for what was verified.

### Added

- **ALL ALONG → Notifications:** the multi-select question (offering only options that can work),
  Remote Control explained before *Claude app* with a per-session or every-session choice, the
  per-developer record in `.ocpf/notifications.json` read every session, how each choice is applied
  and removed in Claude Code, GitHub Copilot Chat, and Copilot CLI, and a one-time test.
- **Step 1:** the question right after the working language; the exit gate checks it.
  `.claude/settings.local.json` and `.ocpf/notifications.json` are always gitignored.

---

## v1.11.0.0 — September 15, 2026

**Fixes from an independent review: the analyzer compile fails on warnings, the analyzer files are
part of the scaffold, and files are named the way CodeCop expects.** Derived from full framework
v2.14.0.0; uses Standards Guide v1.7.0.0. See `fullVersion/RunbookChangelog.md` v2.14.0.0 for
what was verified.

### Changed

- **ALL ALONG → Analyzers** rewritten: read warnings, not only the result (`al-analyze` exits `3`
  on warnings); `AA0215` and `AL0424` listed; no ruleset.
- **Step 3 scaffold and exit gate:** analyzer settings, `AppSourceCop.json` for AppSource, and a
  check that `scripts/al-analyze.*` is present. The post-generation checklist checks file names
  (**Standards §1.8**).
- **Operating Rules 4 and 5** compressed.
- **API naming is camelCase** (**Standards §2.7**, CodeCop `AA0101`): `APIGroup` becomes
  `'<prefix><GroupName>'` (e.g. `acmeCoreFinancial`, no underscore) and `APIPublisher` the
  publisher in camelCase. Published extensions keep their URLs unless their owner plans a
  versioned API change.
- **Step 1:** source wording is asked before the per-language questions it can skip; a note covers
  questions with one or more than four candidates.
- **Smaller fixes:** BCQuality described as outside the project rather than gitignored; the AL MCP
  launcher list includes `al-analyze.*`; Rule 6d's pointer to incidents that now live only in the
  changelog removed; Step 5's `al_searchtranslations` applies where the AL MCP Server is connected;
  the per-language questions and exit gate skip the reviewer for *US wording, no translation
  files*; the schematic's Hygiene node no longer lists BCQuality as gitignored.
- **Corrected in earlier entries:** v1.9.0.0 now says the Step 6 → Step 7 hand-off gained the
  translated-documents return point.

---

## v1.10.0.0 — September 15, 2026

**Step 1 asks the same questions in far fewer boxes, and the runbook stops restating the Standards
Guide.** Derived from full framework v2.13.0.0; uses Standards Guide v1.6.0.0. See
`fullVersion/RunbookChangelog.md` v2.13.0.0 for what was verified.

### Changed

- **Step 1 intake is grouped into boxes** of up to four independent questions: Identity (with
  countries, asked only once), Naming (prefix, namespace, Localization, BC version), Permission
  sets & IDs (an Object ID range is one question with its size shown), Onboarding, Setup &
  languages (`.gitignore`, source language, languages per country), the per-language and
  translation questions, and one confirmation of the whole sheet. Nothing is inferred.
- **Operating Rule 6a** names the mechanism for Claude Code (`AskUserQuestion`), GitHub Copilot Chat
  in VS Code (`askQuestions`), and GitHub Copilot CLI (`ask_user`, with an explicit *I'll type it*
  choice), and the closest equivalent elsewhere.
- **One line and a citation per AL rule:** Rule 2's fallback, Step 2's computed-field and
  permission-set bullets, Step 3's post-generation checklist, Step 4's permission check, Step 5's
  full-build note, the AL Guidelines conflict note, and the translation gate now cite **Standards
  §** instead of restating it. The Permission Sets section is three bullets.

---

## v1.9.0.0 — September 15, 2026

**Fewer one-at-a-time approvals, translation drafting that waits for stable source text, and the
drift the independent review found, resolved.** Derived from full framework v2.12.0.0; uses
Standards Guide v1.5.0.0. See `fullVersion/RunbookChangelog.md` v2.12.0.0 for what was verified.

### Changed

- **`.alpackages/` is always gitignored** (Repository Hygiene, Step 1, Step 3 scaffold, Packaging &
  Versioning). Symbols downloaded from a sandbox contain Microsoft's source and translation files.
- **Operating Rule 6 — approvals come in batches.** The Step 3 batch plan is the one approval to
  generate code; with two batches, the human chooses to run through both or be asked before the
  second. Step 4 no longer pauses per object, but stops on any pre-flight failure or Design Doc
  deviation.
- **Step 5 — one decision per test round.** Every diagnosis from a round is listed and approved
  together (*Apply all* / *Apply selected* / *Discuss first*); a design-rule change gets its own
  box. Step 6's fixes follow the same pattern.
- **Rule 6c:** check in only after a step that hands the human something to act on (Step 5's tested
  package); otherwise one line and continue. The Step 6 → Step 7 hand-off stays, and its return
  points now include translated documents.
- **Step 5 translation cadence:** sync, terminology for new terms, and problem checks on every
  build; drafting, full checks, and per-language testing once the source text is stable.
- **Translated documents move from Step 6 to Step 7**, once the functional test pass is green. Step
  1 asks whether testers need a translated `TestScript.md`, or can run the language pass from the
  English script.
- **Permission Sets:** coverage is verified at Steps 3 and 4; Step 6 relies on the analyzer-enabled
  compile, matching Step 6's own text.
- **Document set:** Step 6 and the Step Map name `ProblemStatement.md` and `ProjectParameters.md` as
  tracked kickoff artifacts alongside the four maintained documents.
- **Outline and schematics:** the AL MCP Server is needed from Step 1, not optional; ALL ALONG lists
  Analyzers, Symbols, and Keeping the Editor in Sync; schematics gates updated and all 7 diagrams
  re-rendered clean.

---

## v1.8.0.0 — September 15, 2026

**The mandatory compile now runs with Microsoft's own code analyzers engaged, and a round of
narrative cleanup shrinks what's loaded every session.** Derived from full framework v2.11.0.0;
applies Standards Guide v1.4.0.0's corrected §1.7 and §5.3. See `fullVersion/RunbookChangelog.md`
v2.11.0.0 for what was verified and the full reasoning.

### Changed

- **Step 3, 4, and Permission Sets:** corrected — the mandatory Step 5 compile catches a missing
  permission-set grant via `PTE0004` when the analyzer runs, not only at publish. The pre-flight
  checks stay: they catch a gap before compile, cheaper than waiting for it.
- **Step 3 and Step 6:** corrected — `AL0424` already proves the codebase is free of ML syntax,
  since `TranslationFile` is always on. The manual search stays as a backstop for anything added
  since the last compile.
- **Step 5:** the mandatory compile now explicitly runs with CodeCop and UICop, plus exactly one
  of PerTenantExtensionCop (SaaS/OnPrem PTE) or AppSourceCop (AppSource) by Deployment Target —
  never both; Microsoft documents them as incompatible. An `AppSourceCop.json` is scaffolded at
  Step 3 when the target is AppSource.
- **Step 6:** the `Rec.`-qualification and permission-set-coverage re-checks replaced with one
  check — the last compile was 0/0, with the required analyzers, and nothing suppressed.
- **Operating Rules and ALL ALONG:** dated attributions and incident narrative moved to this
  changelog; the rules themselves are unchanged.

### Added

- **ALL ALONG → Analyzers:** what the analyzers catch, how to run them, and why the AL MCP
  Server's own tools don't reliably apply them (verified — see the full changelog).

### Not changed

- **An analysis compile after every object** is not adopted here — see the full changelog's
  "Not changed" for the reasoning.

---

## v1.7.0.0 — September 15, 2026

**Permission set names now include something unique to the extension.** Derived from full
framework v2.10.0.0; applies Standards Guide v1.3.0.0's new §5.4. See
`fullVersion/RunbookChangelog.md` v2.10.0.0 for what went wrong and the facts verified.

### Changed

- **Step 1 parameters:** **Permission Set Prefix** is replaced by **Permission Set App Code**
  (asked) and **Permission Set Names** (derived): `<PREFIX> <APPCODE>, VIEW` and
  `<PREFIX> <APPCODE>, EDIT`, each 20 characters or fewer.
- **Step 1 intake:** question 6 asks for the App Code, and 6a asks whether other extensions already
  use this prefix.
- **Steps 2, 3, 6 and ALL ALONG → Permission Sets:** names are planned, pre-flighted, and reviewed
  against §5.4. With namespaces, the compiler doesn't catch a name another extension also uses.
- **Step 6 `Docs.md` deployment section:** lists users to reassign when a release renames a
  permission set.

---

## v1.6.0.0 — September 15, 2026

**The human answers questions and approves prompts; the agent does the setup.** Derived from full
framework v2.9.0.0; Standards Guide v1.2.0.0 unchanged. Four fixes from a real Lite 1.5.0.0
project. See `fullVersion/RunbookChangelog.md` v2.9.0.0 for what went wrong and the facts verified.

### Changed

- **Rule 6a:** every intake question counts as a decision, including values only the human knows
  (names, publisher, prefix, namespace, localization, ID ranges, versions). Ask them through the
  options mechanism, never open-ended in chat.
- **Rule 6d:** never hand the human a setup task the agent can do. No Command Palette for AL MCP
  setup (the AL extension has no such command), and no third-party bridge extensions.
- **Rule 2:** the agent downloads symbols; the human never does.
- **Step 1:**
  - A table of what to offer for each identity question.
  - Interactive Deployment Target, ID range loop, and BC version; `runtime` read from Microsoft
    Learn.
  - Once the sheet is confirmed, the agent writes `app.json` once, complete, connects the AL
    tools, downloads symbols, and checks the editor, all before Step 2.
- **Step 3:** confirms `app.json`, the AL tools, and symbols instead of setting them up.
- **Step 5:** after every clean compile, check the editor for stale red marks.
- **ALL ALONG → AL MCP Server:** no longer optional. It covers:
  - the human only approving,
  - fetching the launcher and the one-shot helper from the framework repository,
  - registering with a relative path,
  - working in the same session through the helper, with no restart.

### Added

- **ALL ALONG → Symbols:**
  - The order to try: VS Code's tool, the AL MCP Server, then the sandbox.
  - The MCP server's global download is W1 only.
  - Confirm symbols by using them.
- **ALL ALONG → Keeping the Editor in Sync:**
  - Why compiled code can still show red.
  - Prevention and automatic detection.
  - The fix: automatic in Copilot Chat; otherwise one short message asking for **Developer: Reload
    Window**.

---

## v1.5.0.0 — September 14, 2026

**Works with the OCPF agent plugin.** Derived from full framework v2.8.0.0; Standards Guide
v1.2.0.0 unchanged. See `fullVersion/RunbookChangelog.md` v2.8.0.0 for the verified facts and
reasoning. The manual setup is unchanged, and every change below applies only when the plugin set
the project up (`.ocpf/framework.json` exists).

### Added

- **Setup:** mentions the plugin as an optional alternative to the manual copy.
- **ALL ALONG → OCPF Plugin:**
  - the marker file,
  - a once-per-session framework update check against GitHub, replacing the project's copy only on
    an explicit "Update now" (backed up, logged in `ChangeLog.md`).
- **Standards Guide fallback:** the plugin's bundled copy is used when GitHub is unreachable at
  Step 1, recorded and named to the human.
- **Operating Rule 6d — zero-install first.** Use what the editor already provides, then what's
  installed, and only then an install. Never ask the human to edit `PATH` or shell profiles. Added
  after agents tripped on this twice; see `fullVersion/RunbookChangelog.md` v2.8.0.0.
- **AL MCP Server:**
  - **Copilot Chat in VS Code:** uses the AL extension's built-in tools, with nothing to bootstrap.
  - **Other MCP hosts:** bootstrap with the extension's bundled `altool` and VS Code's runtime; no
    duplicate registrations.
  - **With the plugin:** its `al-mcp-setup` skill does it in one step.
- **Step 1 framework-files question and Repository Hygiene:** include `.ocpf/`.

### Not added

- **The plugin's sub-agents.** They serve the full framework's role split. Lite still runs on one
  model.

---

## v1.4.0.0 — September 14, 2026

**Multilanguage support.** Derived from full framework v2.7.0.0; applies Standards Guide v1.2.0.0's
new Part 8 and Appendix D. See `fullVersion/RunbookChangelog.md` v2.7.0.0 for the verified facts
and full reasoning, and `translationAndMultiLanguage/MultilanguageSupportOverview.md` for a
user-facing explanation.

### Added

- **Operating Rule 8 — working language.** Step 1 asks it first. `DesignDoc.md`, `ChangeLog.md`,
  AL code, and commit messages stay English; raw requirements and tester feedback stay verbatim.
- **Step 1:**
  - the problem statement names countries, languages, and regional terms;
  - new Parameters rows — working language, target languages (country first, read live from
    Microsoft's availability page, classified into three support cases, each with a
    required-at-release answer and a named reviewer), source language (`en-US` recommended and
    default), source wording (W1, or US wording with no translation files when `en-US` is the sole
    target), document languages, customer-language documents, and translatable data;
  - the exit gate checks them.
- **Step 2:**
  - languages as a requirement;
  - translatable-text conventions;
  - a **translation glossary table inside `DesignDoc.md`**, filled by Standards Appendix D;
  - the **interactive API caption classification** (Business / Technical admin / Technical
    plumbing, Unsure resolved first, recommendations citing Microsoft);
  - two self-check rows.
- **Step 3:**
  - `TranslationFile`, `Translations/`, and `*.g.xlf` gitignored;
  - translation tooling agreed (XLIFF Sync recommended, NAB AL Tools alternative, ask before
    installing);
  - pre-flight checks for translatable text and API caption locking.
- **Step 4:** source text only.
- **Step 5:** the translation cycle — full build, sync, verify terms, draft to
  `needs-review-translation`, technical checks, test in each language. The exit gate adds no
  untranslated or needs-adaptation units in required languages.
- **Step 6:**
  - a translation review;
  - a language pass in `TestScript.md`;
  - translated `Docs.<culture>.md` and `TestScript.<culture>.md` where requested.
- **Step 7:**
  - language passes by fluent testers;
  - the **release gate** — the reviewer approves (logged by name in `ChangeLog.md`), then a state
    scan requires every unit in every required language to be `signed-off` or `final`.
- **ALL ALONG:**
  - a new Translations & Terminology section;
  - Repository Hygiene — `*.g.xlf` ignored, target files tracked, Microsoft's translation files
    never committed;
  - Reference Sources — the country/language availability page, Microsoft Terminology, and style
    guides.
- **Step Map:** the full framework's document count is updated to 20; Lite stays at four.
- **AppSource:** the US-only no-translation-files option isn't offered when Deployment Target is
  `AppSource` (Standards §8.10).

### Fixed — the `.gitignore` question named the wrong `ChangeLog.md`

Step 1's `.gitignore` question, ALL ALONG → Repository Hygiene, and the Standards Guide section all
said "this runbook and `ChangeLog.md`" are gitignored by default. That contradicted Lite's own Step
Map and outline, which list `ChangeLog.md` among the **four tracked documents**, and the full
framework's equivalent question, which covers only the framework's own files.

- They now name the framework files explicitly: this runbook, `LITE_RunbookChangeLog.md`, and
  `LITE_RunbookSchematics.md`.
- They state that the project's `ChangeLog.md` is **always tracked** — it now also records
  translation approvals.
- Projects on an earlier Lite version are told to remove any `ChangeLog.md` ignore entry and commit
  the file.
- `LITE_Outline_OCPFBCAgenticDevFW.md` and the ALL ALONG diagram in `LITE_RunbookSchematics.md`
  updated; all 7 Lite diagrams re-rendered clean.

---

## v1.3.0.0 — September 14, 2026

**Deprecated multilanguage (ML) syntax banned in generation and flagged in review; System App docs
and AL Guidelines added as reference sources; third-party resources credited under their
licenses.**

Derived from full framework v2.6.0.0; applies Standards Guide v1.1.0.0's new §1.7 and Part 7 row.
See `fullVersion/RunbookChangelog.md` v2.6.0.0 for the full reasoning.

### Added — Reference Sources

- **Operating Rule 2** fallback now names the BC System Application docs on Microsoft Learn
  alongside the Base App docs.
- **New ALL ALONG section — Reference Sources:** Base App docs, System App docs, *Working with
  translation files*, and AL Guidelines. Consulted online, not fetched. Precedence: symbol files
  beat Microsoft Learn, the Standards Guide beats AL Guidelines. AL Guidelines' legacy C/AL pages
  recommending `CaptionML` / `OptionCaptionML` are excluded by name.
- **Step 2** consults AL Guidelines for design patterns the Standards Guide doesn't cover;
  **Step 6** adds an AL Guidelines best-practice pass.
- **Snapshots keep `LICENSE`:** the BCQuality and Patterns Library fetches strip `.git` but keep
  the upstream `LICENSE` file, as MIT requires. Every resource is credited in the framework's new
  `THIRD_PARTY_NOTICES.md`.
- `LITE_Outline_OCPFBCAgenticDevFW.md` and the ALL ALONG diagram in `LITE_RunbookSchematics.md`
  updated; all 7 Lite diagrams re-rendered clean.

### Changed — ML anti-pattern

- **Step 3** — the post-generation pre-flight checklist now fails any `CaptionML`, `ToolTipML`,
  `OptionCaptionML`, other ML property, or `TextConst`.
- **Step 4** — generation instruction names single-language label syntax explicitly.
- **Step 6** — code review searches every AL file, including human-written or pasted code, for the
  deprecated constructs; every hit is a finding. Called out explicitly because AL0424 only fires
  when `TranslationFile` is enabled, so a clean compile doesn't prove the code is free of it.
- Standards Guide version references updated to v1.1.0.0.

---

## v1.2.0.0 — September 13, 2026

**Lite gets its own `ProjectParameters.md` — closing the same storage gap the full framework had,
in Lite's own equivalent place.**

Derived from full framework v2.5.0.0.

### Fixed — the Project Parameters block had no named file to live in

The full framework's own review (this same day) found that its Project Parameters block was
referenced constantly as an Input or Output, and called the project's single source of truth —
but no step ever named a file for it. Lite had the identical gap: Step 1's own actions, and Step
2's and Step 3's Inputs lines, all referenced "Project Parameters" as a concept with nowhere named
to actually find it.

- **`ProjectParameters.md`**, in the **project root** — not `docs/`, since Lite never uses a
  `docs/` folder anywhere; every Lite artifact lives flat at the root, matching where
  `ProblemStatement.md` already lived.
- **Step 1's own action bullet, Outputs, and Exit gate** all updated to name the file explicitly —
  the intake sheet is now persisted, not just discussed, the moment it's filled in.
- **Steps 2 and 3's Inputs lines** now cite `ProjectParameters.md` by name instead of the bare
  phrase "Project Parameters."
- **`LITE_Outline_OCPFBCAgenticDevFW.md`'s Document Set** section now lists `ProblemStatement.md`
  and `ProjectParameters.md` as the two Step 1 setup artifacts, distinct from the four documents
  tracked throughout the routine (`DesignDoc.md`, `ChangeLog.md`, `Docs.md`, `TestScript.md`) —
  that "four tracked files" framing was never meant as a literal count of every file Lite produces
  (it already excluded `ProblemStatement.md`), so it stays as-is; the new line just makes what it
  does and doesn't cover explicit.

---

## v1.1.0.0 — September 13, 2026

**Wired up to the OCPF AL Development Standards Guide, and three defects found in an independent
review fixed.**

Derived from full framework v2.4.0.0.

### Added — the Standards Guide, fetched and cited throughout

Lite previously carried **zero** references to any companion rules document — every AL rule it
needed was either restated in short form or simply assumed correct. Fixed on the governing
principle stated in the runbook's own header: **Lite reduces process, not AL rules.** The same
rules that apply to a 50-file extension apply to a 5-file one.

- **Step 1 gained a first action**: fetch `standardsGuide/ocpfALDevStandardsGuide.md` from the
  framework repository into `standardsGuide/`, and add it to `.gitignore` — ahead of Step 3, where
  the other fetched libraries wait, because Step 1's own gap check already leans on Standards
  Part 6.
- **New ALL ALONG section** — OCPF AL Development Standards Guide — with the same
  fetch/refresh/version-skew policy as the full framework's equivalent section, and the same
  stricter-than-patterns failure mode: an unreachable guide means stop and ask, not proceed from
  memory.
- **Citations added throughout** — Step 1 (naming, abbreviations), Step 2 (mutability, field
  exclusion, `const()` quoting, naming, permission sets, growth-buffer IDs), Steps 3–4 (page
  template, mandatory properties, indentation, symbol verification), Step 5 (endpoint patterns),
  and Step 6 (dead code, obsolescence, and — the highest-value one — the full Anti-Patterns table,
  Standards Part 7, called out explicitly as worth the couple of minutes it takes to read).
- The Parameters block now states it is authoritative and that the guide defers to it, matching
  the full framework's own Step 01.

### Fixed — three defects found in an independent review, present since the v1.0.0.0 baseline

- **The hand-off moment was misplaced.** It sat at the *end* of Step 7, after the exit gate — by
  which point the package had already shipped to Production, so "what's left is a human running
  tests" was describing something already finished. Moved to the **top of Step 7**, before its
  actions, matching the full framework's Step 11 → 12 placement.
- **The hand-off collided with Rule 6c.** It was plain prose, while Rule 6c separately required a
  selectable-options check-in at the same Step 6 → Step 7 boundary, with no stated precedence
  between the two. Now runs through the Rule 6a interactive mechanism with the same two named
  options as the full framework (*"Perfect, I understand!"* / *"I have some questions"*), and both
  sides state explicitly that the hand-off **replaces** the generic check-in rather than adding to
  it.
- **The Step Map's document count was wrong** — it said "~15" while listing 18 documents in the
  same sentence. Corrected to the full framework's actual canonical count at the time.

Also tightened: Step 6's code review hedged with "if a live BCQuality snapshot exists," even
though Step 3 bootstraps it unconditionally — it now invokes the snapshot directly and requires
the agent to say so if it's genuinely missing, rather than silently skipping the pass.

### Changed — dates written in long form

Every date in the Lite runbook converted from `YYYY-MM-DD` to long form (e.g. `September 13,
2026`). No date value changed — only its formatting.

---

## v1.0.0.0 — baseline

Initial release of the Lite Edition, derived from the full framework v2.3.0.0: a 7-step
condensation of the full framework's 14 (DEFINE → DESIGN → BUILD → PROVE, one merged document set
instead of eighteen — `DesignDoc.md`, `ChangeLog.md`, `Docs.md`, `TestScript.md` — and no
Main/Light/Reasoning role split, one model doing everything), for Business Central AL PTEs of 10
files or fewer.

---

*Lite Edition created by AJ Ansari, Microsoft MVP, OnlyCopilotFans, derived from the OCPF BC
Agentic Development Framework. Update this changelog whenever `LITE_BC_App_Build_Routine_Agent.md`
changes, whether that change originated in Lite itself or flowed down from the full framework.*
