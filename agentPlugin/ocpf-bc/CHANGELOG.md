# ocpf-bc plugin: Changelog

The plugin is versioned with three-part semantic versions, independently of the runbooks. Each
entry names the framework versions bundled as the offline fallback. The `start` skill always
fetches the latest runbook from GitHub first, so a project isn't limited to the bundled versions.

## 5.9.1 — October 20, 2026

**Bundles:** full runbook v5.9.1.0, Lite v5.9.1.0, Standards Guide v1.13.1.0 (unchanged),
Operations Guide v5.9.1.0. The `dashboard`, `notifications`, `build-a-feature`, `usage`, `status`,
`documents`, and `roles` skill text; the pin wording in `al-standards` and `update-framework`; both
manifests' version; one header comment in each of `ocpf-notify.ps1` and `ocpf-dashboard.ps1` (no
code changes). From a Build-a-Feature run
on a new Windows machine without PowerShell 7:

- **`dashboard`: the hooks' interpreter comes from a ladder and the hooks are proven** (new
  sections 2a and 2b). Probe `python3`, `pwsh` (must answer PowerShell 7), `python`, `py -3` —
  Windows order `pwsh`, `python`, `py -3`, `python3` — record the winner as `runner` in
  `ocpfFramework/state/dashboard.json`, write the hooks with it (a direct `python` / `py` exec
  form on Windows, with `--waiting-json -` so the script reads stdin itself), then run the Stop
  hook's exact command once and require the sidecar to be newer with `app.name` and
  `framework.edition` right; record `hooksVerified`; step down the ladder on a fail; `runner:
  none` and the close render when nothing runs. Repair names the symptom: *Untitled extension*,
  or the Full map on a feature project, with `app.json` complete.
- **`usage`: the step close ends with a render on every tool**, not only Copilot Chat; an `F` row's
  close counts.
- **`notifications`: *Claude app* is offered unless a disqualifier is positively found**; the test
  runs each hook's exact command; the Windows script note no longer says "untested".
- **`build-a-feature`**: the repository is initialized at the folders-and-ignore-list step when
  there is none (never nested); the dashboard proof and the per-object close render; the
  notifications wording.
- **`status`** reports hooks written but never proven (`hooks: true`, no `hooksVerified`).
- **`documents` with no name asks a multi-select box**, never single-choice, listing this edition's
  documents whose inputs exist and ending with *The help site* — which hands off to `html-docs`
  after the chosen documents are written. On a real project the box was single-choice and the
  human could not find the site under the command they expected.
- **`roles`: the Copilot recommendations are two options per role at the same Copilot price** —
  Main Claude Sonnet 5.5 or GPT-6.1 Sol Medium, Light Claude Haiku 5.5 or GPT-6 Luna Medium,
  Reasoning Claude Opus 5.5 or GPT-6.1 Sol High — offered as two options, the Claude model first;
  Gemini 3.8 Flash and Auto withdrawn.

## 5.9.0 — October 19, 2026

**Bundles:** full runbook v5.9.0.0, Lite v5.9.0.0, Standards Guide v1.13.1.0 (unchanged),
Operations Guide v5.9.0.0. One new skill, `html-docs`; one new document template, `FAQ.md`; Full
Step 11 and Lite Step 6; the `build-a-feature` and `documents` skill text; both manifests' version
and description; the marketplace entry.

- **New `html-docs` skill (`/ocpf-bc:html-docs`) — the help site.** Builds a polished HTML
  documentation and support page, `docs/index.html`, from the project's own Markdown documents:
  tabs for the User Guide, the Documentation, an FAQ (collapsible questions), the Deployment guide,
  and any other guide; the app icon, a download button for the package, *Get support* and *View on
  GitHub* links, an optional banner and publisher logo, the Mermaid diagram drawn in the browser,
  and the human's screenshots. Asks in boxes: which tabs (a missing document — the FAQ, a User Guide
  on a feature project — is written first through `documents`), whether the human will provide
  screenshots and where to put them (`docs/screenshots/`; each file looked at, renamed to say what
  it shows after one approval of the list, placed in the Markdown where the guide talks about it),
  identity and links (repository, download, support, banner, logo, tagline — nothing fetched from
  the web). `templates/build.py` (copied into `docs/`, never edited per project) converts through
  `npx marked` or Python `markdown` with nothing installed, cleans each document for the page, and
  prints what to review — repository paths, internal codes, design references, build-status
  remarks, unbalanced HTML, missing images — which the agent acts on; `templates/template.html` is
  the page shell with CSS tokens for the accent colors; `templates/site.json` the configuration
  shape. The agent looks at every tab (headless Chrome or Edge where available) before the human
  does, then gives the GitHub Pages steps (`references/github-pages.md`: Settings → Pages → Deploy
  from a branch → `main` / `/docs`; the private-repository caveat) and offers to set `app.json` →
  `help`. Offered by Full Step 11 and Lite Step 6; never by Build-a-Feature; on request on any
  project. Procedure in the bundled Ops § Help Site.
- **`FAQ.md` template** in the `documents` skill's references; the `documents` skill lists it.
- **`build-a-feature`'s never-list** names the help-site offer; on request only.
- `THIRD_PARTY_NOTICES.md` credits marked, Mermaid, and the Google Fonts (Inter, Archivo, JetBrains
  Mono) the generated page loads from their CDNs; nothing is bundled.

## 5.8.2 — October 19, 2026

**Bundles:** full runbook v5.8.2.0, Lite v5.8.2.0, **Standards Guide v1.13.1.0** (pin moved — §5.0
corrections: no `interface` in the ID-space list, example permission set named per §5.4),
Operations Guide v5.8.2.0. Same-day review pass on 5.8.1; the `al-standards` and `update-framework`
skill text carry the new pin; both manifests' version.


**Bundles:** full runbook v5.8.1.0, Lite v5.8.1.0, **Standards Guide v1.13.0.0** (pin moved — new §5.0, object IDs per type),
Operations Guide v5.8.1.0. The `al-mcp-setup` skill text, two document templates, both manifests'
version.

- **The human runs the automated tests.** The agent does not call `al_run_tests` or publish the test
  app, even on request: on real projects in October 2026 it could not get either to work through
  the AL MCP Server. This replaces 5.7.1's "'Run the tests' works the same way". `al-mcp-setup`'s
  sign-in note, the `AutomatedTestGuide.md` opening, and the Acknowledgements AL tools row are
  worded to match. Agent-run tests are on the framework's roadmap (Ops § Automated Tests).
- **Object IDs are allocated per object type.** `build-a-feature`'s ID gate (Part 4 step 4) now
  takes the next free ID *of that object type* — `al_getnextobjectid` per type, else the highest of
  that type in `src/` plus one, or the range's first ID when the type has none — never the highest
  number across types, and "never a number a symbol already uses" became "a symbol of the same
  type". The Feature Register template says the same beside its ID column. The rule itself is the
  bundled Ops § Object IDs (new); the TDD, Design Doc, and Build Plan templates carry its check.

## 5.8.0 — October 16, 2026

**Bundles:** full runbook v5.8.0.0, Lite v5.8.0.0, Standards Guide v1.12.1.0 (unchanged),
Operations Guide v5.8.0.0. Two new skills, `analyze` and `app-icon`; two new sub-agents, `ocpf-reviewer` and
`ocpf-analyst`; three document templates (one new); both renderers, both usage scripts, both
dashboard templates; `start`, `build-a-feature`, `roles`, `status`, `documents`, `dashboard`,
`usage`, and `update-framework` skill text; both manifests' description; the marketplace entry.

- **New `analyze` skill (`/ocpf-bc:analyze`) and `ocpf-analyst` sub-agent.** Documents an existing
  extension that is not well documented before any journey extends it: asks what the human knows
  and whether they have documents for `requirements/existing/`, which model (reasoning — Claude
  Opus, recommended — or daily driver — Claude Sonnet; in Copilot the picker's GPT Sol and GPT Terra
  beside them) and which effort (Medium recommended; High 1.5×–3× longer and dearer), writes the
  analyst's project-local copy with that model, opens window `AN0`, and delivers a presumed FRD, a
  presumed TDD, an Object Register, Documentation with the schema and flows, a Project Parameters
  sheet, and a README into `requirements/existing/`. Every question through the options mechanism.
  `start` offers it on an undocumented existing extension; Build-a-Feature's case C too. October
  16, 2026 (Ops § Existing Apps).
- **New `ocpf-reviewer` sub-agent — the pre-review.** Both editions, Main model and effort, read-only:
  one read of every file between the first clean compile and the first package (Full Step 07 /
  Lite Step 5), findings with root cause and fix in two tiers, no grades. The `roles` skill now
  writes four definitions in Full and two in Lite; `update-framework` adds the missing one on an
  older project; the hygiene block lists it (Ops § Roles → *The pre-review*).
- **`start` describes the journeys by the kind of work** (Ops § Journeys): Full for a complete app
  or solution end to end on three models; Lite for updating an existing app or a new one without a
  large footprint on one model; Build-a-Feature for quick customizations in minutes — not
  vibe-coding, lean on documentation, ideal for a PoC. It says once what to put in `requirements/`
  and `images/`, and flags template placeholders in an existing `app.json` as the template's
  defaults.
- **`build-a-feature` — documents as it builds, flat `docs/`, no inferred publisher or range, a
  role center.** Part 0 opens the `F00` window before anything else; Part 2 records
  `publisherSource` and `idRangesSource` in `feature.json`, offers the `images/` icon first, asks
  the range in every case (`50100–50149` named as the template's default, never first), and fetches
  the Main model's price; Part 3 writes the problem statement and the register's parameters at the
  intake close; Part 4 writes each object's proposed design to `docs/DataModel.md` **before** the
  confirmation box, allocates an ID only through the source gate, and documents the object the
  moment it compiles (new stage *Documented*); Part 7 finishes six documents in a flat `docs/` —
  `ProblemStatement.md`, `FeatureRegister.md`, `DataModel.md`, `Documentation.md`, `ChangeLog.md`,
  `SandboxInstall.md` (phase folders on a Full or Lite project). One window per object even when
  several are written in one pass. New `references/objects/role-center.md` (cue table, activities
  part, role center page, profile); `feature-record.md` rewritten. Templates: `FeatureRegister.md`
  rewritten, `FeatureDataModel.md` new, `FeatureDocumentation.md` rewritten as documentation only.
- **New `app-icon` skill (`/ocpf-bc:app-icon`) — *Create one for me* in every identity box.** Asks
  style, colors, content, and a description in one box; the Main model writes the SVG to the
  standard (square, rounded corners, transparent background, 300 × 300), renders it with nothing
  installed (Quick Look, a headless Chrome or Edge, an installed converter, or a preview page with a
  *Save as PNG* button), checks it, shows it, offers *Accept / Make another*; the accepted icon lives
  in `images/` and is copied to `src/logo/AppLogo.png`, which `app.json` names. `references/icon-standard.md`
  carries the standard, the SVG skeleton, the preview page, and the checks. Offered by PRE-01, Lite
  Step 1, and Build-a-Feature (Ops § Intake → *The app icon → Creating one*).
- **The usage scripts fetch published prices themselves** — a Claude model with no row in
  `pricing.json` from Anthropic's pricing page (served as Markdown), a Copilot project's `aiCredit`
  from GitHub's page — written with source and date, noted in the output, retried after an hour at
  most when a fetch failed; a success clears the cooldown. On AJ's project the agent never wrote `pricing.json`, so Claude Sonnet 5.5 read *price
  unknown* and the dashboard `$0` for the whole build. The dashboard reloads `pricing.json` after
  the measurement so a freshly fetched price shows on the same render.
- **Dashboard and usage scripts (both twins).** The first window starts at the first event of the
  session that opened it (the clock and the tokens begin together; the usage script notes it);
  elapsed is the union of the windows; a window with no transcript event is the human's time; time
  with an options box open is *waiting* (it read as agent time before); agent + you + waiting
  equals elapsed exactly; a model with no rate in `pricing.json` shows *+ unpriced* with the model
  named instead of `$0`; work after the last window is noted. Feature gates gain *Documented*.
  Verified against AJ's Build-a-Feature project of October 16, 2026, in Python and PowerShell.
- **`status`** reports a `feature.json` without a publisher or range source as a blocker, the flat
  feature `docs/`, and the `AN0` row; **`documents`** maps the feature templates to the flat layout;
  **`dashboard`** gains *3c. Time and cost — what the figures mean*; **`usage`** says the first
  window is the routine's first act and the price is fetched before it closes.

## 5.7.3 — October 15, 2026

**Bundles:** full runbook v5.7.3.0, Lite v5.7.3.0, Standards Guide v1.12.1.0 (unchanged),
Operations Guide v5.7.3.0. One new skill, `copilot-blueprint`; both manifests' description.

- **New `copilot-blueprint` skill — the Blueprint rule holds in every journey.** Full and Lite fetch
  the OnlyBCFans BC Copilot Blueprint when their intake records a Copilot feature; Build-a-Feature
  has no Copilot entry and plain chat has no intake, so an ask like "add a Suggest with Copilot
  action" there was built from memory — the exact failure the Blueprint exists to prevent. The new
  skill's description triggers on a Copilot feature, a *Suggest with Copilot* action, a PromptDialog
  page, a capability registration, Azure OpenAI or System.AI, and on the agent about to call
  something impossible. It fetches the Blueprint at the framework's pinned tag into a sibling
  folder outside the project (never the root; `.git` stripped, `LICENSE` kept, `SNAPSHOT.json`;
  Claude Code also gets the project-skill copy), follows the Blueprint's fifteen-step procedure for
  the objects — in Build-a-Feature, each object a row of the session, generated from the
  Blueprint's templates renamed to the project's prefix and range — asks the billing path first,
  checks the API reference and the false-assumptions table before memory on any failure, and never
  writes a Copilot feature without the Blueprint on disk. Build-a-Feature itself is unchanged by
  AJ's decision; the skill is journey-agnostic. October 15, 2026.
- **README:** *What's New* moved below *Project Inspiration*; *License* is a collapsible section at
  the same header level as the others; the F1 dashboard image is gone (the text says the theme is
  optional).

## 5.7.2 — October 15, 2026

**Bundles:** full runbook v5.7.2.0, Lite v5.7.2.0, **Standards Guide v1.12.1.0** (pin moved),
Operations Guide v5.7.2.0. `build-a-feature`, `start`, `documents`, `al-standards`,
`update-framework`, and `al-mcp-setup` skill text; the analysis-compile script header.

- **Microsoft Copilot Cowork support is removed** — the package build script, the "not yet fully
  vetted" install section, the release-checklist step, the update-table row, the `atk` credit, and
  every mention in the `start` skill and the Operations Guide. It was never published (the
  repository has no Releases for the documented download), and AJ does not intend to pursue it.
  Claude's own Cowork surface is unaffected. October 15, 2026.
- **Standards Guide pin moved to `v1.12.1.0`** — a wording fix to §3.2's *Obsolete removed* row,
  which read as if an obsoleted field were deleted; it now says the field stays in the table and is
  merely inaccessible, pointing at §9.4.

- **Build-a-Feature writes the sandbox install guide with its package.** Part 6's *Yes* now writes
  `docs/4-prove/SandboxInstall.md` from the template with the first package and rewrites §1 with
  every later one, the same as Full Step 07 and Lite Step 5; the *Package built* block's *Install:*
  line points at it. No guide for a package the agent didn't build. AJ, October 15, 2026.
- **Release-test exit gates record which upgrade branch applied.** Full Step 12 / Lite Step 7
  passed on "the upgrade path passes, or this is the first release" without saying which; the gate
  now requires the choice recorded (`ReleaseTestResults.md` in Full, the ChangeLog in Lite), as
  Step 03 already requires for "no upgrade code needed". Lite Step 7's upgrade-path test gains the
  multi-company clause Full has (data in more than one company wherever `PerCompany` upgrade code
  exists). Both from the September 16 issues log.
- **AL MCP Server analyzer behaviour re-verified on AL Language extension 18.1.2842859** (a
  fixture table with no permission set, every argument shape, the framework's own compile as the
  control). `al_build` still ignores its analyzer arguments and workspace settings and packages
  code with analyzer errors as `succeeded: true`; `al_compile` still applies analyzers only with
  `enableCodeAnalysis: true` and a `codeAnalyzers` list under `options`. New nuance recorded: a
  server launched with `--codeanalyzers` makes both tools apply analyzers (build fails without rule
  codes; compile reports them) — the framework's launcher never passes that flag, so
  `al-analyze.*` stays the mandatory compile. Ops § Analyzers, both cores, the `al-mcp-setup`
  skill, and the script header say so, with both version stamps.
- **README:** PoC Edition and the intake sheet shelved on the roadmap with the reason; dashboard
  page-answers, a Copilot CLI live dashboard, and more themes listed as being considered; the
  stale "Coming next" line in What's New replaced.

## 5.7.1 — October 15, 2026

**Bundles:** full runbook v5.7.1.0, Lite v5.7.1.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.7.1.0. `AutomatedTestGuide` template, `al-mcp-setup` and `documents` skill
text, the dashboard template.

- **Publishing and test runs on explicit request — never offered, never the default.** A developer
  who says "publish it" is first asked, through the options box, whether they mean a DEV-extension
  publish to a named sandbox; on yes the agent does it with the AL tools (Synchronize; ForceSync /
  Recreate / forceUpgrade still need their own approval; production never), reports the result
  verbatim, and logs it as human-ordered — separate from the "last installed version", which stays
  the per-tenant install the human reports. "Run the tests" works the same way against a sandbox
  (`al_run_tests`, verified in the AL MCP Server of AL extension 18.1.2842859; it runs what is
  installed and publishes nothing). Neither becomes the routine. AJ's clarification, October 15, 2026.
- **Second-set-of-eyes review (Fable 5.1) applied.** The `AutomatedTestGuide` template no longer
  promises that the three test libraries are a marketplace search away: it opens the *Microsoft
  Marketplace Apps* page by its documented route, uses the page's own *Install* action, and tells
  the tester to stop and report if an app isn't listed (a developer can install by App ID; no
  Microsoft page confirms the libraries are offered online). Ops § Automated Tests says the same.
  "Redeploy" in both schematics' fix-cycle nodes and one Ops sentence now reads "the human installs";
  the "Package built:" block drops "(I never do)"; the user guide's document table lists the two new
  documents; Full Step 12's exit gate names the Admin Center route. Dashboard: below 900px the
  phase blocks go two per row instead of overflowing.

## 5.7.0 — October 15, 2026

**Bundles:** full runbook v5.7.0.0, Lite v5.7.0.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.7.0.0. Two new document templates (`SandboxInstall.md`,
`AutomatedTestGuide.md`) in the `documents` skill; `al-mcp-setup` and `documents` skill text; the
reasoning sub-agent's task list.

- **The agent never publishes — to a sandbox or anywhere.** Full and Lite now package only; the
  human uploads every `.app`, and the human runs every automated test. `al_publish` and
  `al_run_tests` are never called (Ops § AL Tools, § Packaging, § Automated Tests; the `al-mcp-setup`
  skill no longer lists publish or tests among what it connects). AJ's decision, October 15, 2026.
- **`SandboxInstall.md` — the human's upload guide**, written with the first package (Full Step 07 /
  Lite Step 5) and kept current: both of Microsoft's routes step by step (Admin Center → Manage Apps
  → Install Extension, the recommended one; Extension Management → Upload Extension, deprecated and
  removed in 2027 release wave 1), the permission the uploader needs, after-install steps, updating,
  uninstalling, and a table of the errors people hit — all fixed — plus §1, which the agent rewrites
  after every build with that build's file, version, Schema Sync Mode, sandbox, and dependencies.
  The "Package built:" block now ends with an *Install:* line pointing at it and a *Then:* line
  asking for the installed version. Sources: Microsoft Learn, read October 15, 2026.
- **`AutomatedTestGuide.md` — the human's test guide**, written whenever AL test codeunits are
  created (Full Step 11 / Lite Step 6): which Microsoft test apps to install once in a sandbox
  (Test Runner, Library Assert, Any, Library Variable Storage — with their app IDs), installing the
  extension and the test app, the **AL Test Tool** page with its exact captions, one row per test
  method (what it checks, expected result, setup), and running them **one at a time** with
  *Run Tests → Active Line*, reading *Result* and *Error Message*, and what to send the agent.
  Written for someone who has never opened the page. Sources: Microsoft Learn and the Test Runner's
  own source in microsoft/BCApps, read October 15, 2026.
- **Test apps depend only on what an online sandbox can install** — the extension under test plus
  Library Assert, Any, and Library Variable Storage; never Tests-TestLibraries or System Application
  Test Library, which Microsoft does not offer for online sandboxes. Built as
  `outputAppPackage/<Name>_Tests_<version>.app` (Ops § Automated Tests).
- **The agent-run API pass is gone** from Full Step 07 and Lite Step 5: it needed a publish. The
  green-team / red-team checklist stays, as the human's, and Step 12 / Lite Step 7 remain the
  authoritative pass. The schematics and the Deployment template follow.

## 5.6.2 — October 15, 2026

**Bundles:** full runbook v5.6.2.0, Lite v5.6.2.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.6.2.0. `dashboard` skill template only.

- **Dashboard (OnlyBCFans page): the bottom row shares one height.** *Who is working*, *Tokens
  by model*, the exit gate, and *Waiting on you* stretch to the tallest card in the row, as the
  first-row tiles have since 5.6.0; a collapsed card sits at the top of the row. Should have
  shipped with the tile change; AJ pointed it out.

## 5.6.1 — October 14, 2026

**Bundles:** full runbook v5.6.1.0, Lite v5.6.1.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.6.1.0. `dashboard` skill templates only.

- **Dashboard (OnlyBCFans page): text stays inside its box.** The first-row tiles can shrink below
  their content and their detail line wraps instead of clipping (`in · out · cache` no longer ends
  in `…`); the estimate tile's label wraps under its status chip and clears the collapse button;
  the time legend wraps when the tile is narrow. On the Journey, stations sit fully inside the
  panel, the rail spans the same range as the stations (the comet no longer sits to the right of
  the current node), the current station's `IN PROGRESS` label fits its column, and a sub-agent
  chip that would run off the right edge opens to the left of its spur. Found on AJ's Step 12 run.
- **Journey phase blocks keep a minimum width.** The blocks are sized by row count, so on a
  Build-a-Feature journey (one row in Intake, Review, and Package beside thirteen in Build) a
  one-row phase was a sliver with its number, name, and summary written over each other. Each
  block now has a floor of 196px and the Build block takes what is left. Found on AJ's Summit
  Support POC01 run.
- **Estimate tile shows an overrun.** The status chip and the percentage used the bar's capped
  value, so 13.25M of 10.20M read "Near estimate · 100%". Both now use the real figure
  ("Over estimate · 130%"); only the bar is capped. The F1 page's "Lap vs target" percentage is
  uncapped the same way.

## 5.6.0 — October 13, 2026

**Bundles:** full runbook v5.6.0.0, Lite v5.6.0.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.6.0.0. `build-a-feature`, `start`, `dashboard`, `usage`, `status`, and
`documents` skills; two new document templates; both renderers and both templates.

- **`build-a-feature` skill:** a fresh AL: Go! scaffold (`app.json` `1.0.0.0`, no package,
  `HelloWorld.al` only) is a **new** app — `id` kept, `HelloWorld.al` dropped, version written
  `0.0.0.1`; an existing extension is one with a package or real objects, and even then the
  new-or-existing question (intake 4b) is asked, evidence-backed answer first, never answered from
  the file. Found on AJ's first run: the skill offered the template's `1.0.0.0` as the installed
  version.
- **`start` skill:** the existing-extension detection names the package and object evidence and
  no longer reports the file's version as installed.
- **Placeholders are asked, not kept:** a scaffold's `ALProject1`, `Default publisher`, and
  `50100–50149` are treated as unanswered — Box 0 and the range question run as for an empty
  folder; an existing extension's name and publisher are confirmed in one box, and the icon is
  asked when it has none — Box 0 on every journey.
- **`build-a-feature` skill: the review is offered before the package** — Part 5 review, Part 6
  package, each its own box; the package box waits for the review answer. Renderers: phases
  *Intake · Build · Review · Package*.
- **Remediation rows:** `ocpf-dashboard.py` / `.ps1` insert `07a` / `STEP-5a` rows after their
  base step from the usage window and the `ProjectProgress.md` row (Ops § Usage & Cost → 7);
  `usage` and `status` accept the ids.
- **Build-a-Feature's four quick documents** at the close: `FeatureRegister.md` and
  `FeatureDocumentation.md` templates added to the `documents` skill's references.
- **Renderers: elapsed-time math.** Each step's agent / you / waiting split is scaled to its
  window so the three add up to Elapsed exactly.
- **`dashboard-f1.html`:** lighter grey track and pit lane; Ferrari-red *Team radio* with a
  pit-wall line (*Box box. Box box.*, bleeped `*** ***`); cars on track drive with a slow, varied
  speed cycle and overtake, state kept across repaints; header re-laid out — wordmark above the
  app icon and name, the five stickers in two rows, the status pills in two rows.
- **`dashboard` skill: OnlyBCFans opens, always.** `ocpf-dashboard.py` / `.ps1`: `--open` opens
  `ProjectDashboard.html` whatever `dashboard.json` remembers; the F1 page opens only when
  `--theme f1` is on that call, and the skill passes it only when the human asked for F1 by name.
  `dashboard.html`: the KPI tiles of the first row share one height (the Elapsed tile's).

## 5.5.0 — October 11, 2026

**Bundles:** full runbook v5.5.0.0, Lite v5.5.0.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.5.0.0 (new *Ops § Build-a-Feature*). New skill; dashboard renderers and
templates; usage scripts; `start` and five other skills.

- **New `build-a-feature` skill — the third journey.** One object or a few, in a new or existing
  per-tenant extension, no steps, no documents: one intake question (the only free-text one),
  infer-then-confirm field types (`references/field-types.md`), one reference file per object type
  under `references/objects/` (table, table extension, page, page extension, report, report
  extension, API page, API query, query, enum, enum extension, codeunit, permission set, permission
  set extension — what to ask, what to validate, the skeleton, the pre-flight, the companion
  offer), compile clean with the analyzers, the companion box at every close, one offer to package
  a `.app` and one to review on the Main model against the Standards Guide, BCQuality, and the AL
  Guidelines. Keeps `ProjectProgress.md`'s feature table (`references/feature-record.md`), the
  usage windows under `F` ids, and the dashboard. `start` is the documented way in; a direct
  `/ocpf-bc:build-a-feature` runs the same checks.
- **`start` skill:** offers **Full, Lite, or Build-a-Feature**; recommends Build-a-Feature first on
  an existing extension with no framework; on a project already on the framework asks *Status /
  Check for a framework update / Build a feature in this project* instead of stopping; accepts
  `feature` as an argument; Documents mode says the journey needs a compiler.
- **`dashboard` skill:** `ocpf-dashboard.py` / `.ps1` render `"edition": "feature"` — rows from the
  usage windows and the feature table, `phases` in the data, `stage` / `kind` / `objectId` /
  `shippedIn` per row, Main alone in the roles; both templates read `D.phases`, show the stage per
  station or lap, and show *Objects built* instead of the estimate. Full and Lite unchanged.
- **`usage` skill:** the scripts count objects from the feature table on a feature project
  (calibration); `F` ids documented as step ids.
- **`status`, `update-framework`, `roles`, `documents` skills:** edition `feature` awareness (the
  feature rows in a status report; no runbook to update, companions and scripts refreshed; Lite's
  two model questions; the template's third step table).

## 5.4.2 — October 10, 2026

**Bundles:** full runbook v5.4.2.0, Lite v5.4.2.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.4.2.0. Dashboard renderers and templates.

- **`dashboard` skill: every theme rendered on every run.** `ocpf-dashboard.py` / `.ps1` write
  `ProjectDashboard.html` and `ProjectDashboard-f1.html` from one data build; `--theme` only picks
  the page `--open` opens; the footer selector navigates instead of telling the human to ask.
- **Sub-agent counters:** `roles[].runningCount` — every running sub-agent matched to its role by
  model; shown as a green counter in both themes; brighter glowing running light.
- **All cards collapsible** on the OnlyBCFans page; a collapsed *Waiting on you* card with a
  question open pulses a ring.

## 5.4.1 — October 10, 2026

**Bundles:** full runbook v5.4.1.0, Lite v5.4.1.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.4.1.0. Dashboard templates only.

- **`dashboard` skill:** `dashboard.html` — KPI tiles and the Journey panel collapse with a
  chevron (per-browser, re-applied after each repaint); ticker pause / resume and restart
  buttons. `dashboard-f1.html` — same ticker controls; header gains the OnlyBCFans wordmark
  (day / night), app icon and name, and the BC icon. Countdown blank on first paint fixed.

## 5.4.0 — October 10, 2026

**Bundles:** full runbook v5.4.0.0, Lite v5.4.0.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.4.0.0. New dashboard theme.

- **`dashboard` skill: the `f1` theme.** New `templates/dashboard-f1.html` (trackside pit-wall
  view; same data contract, in-place refresh, Day/Night, Copilot credits). `ocpf-dashboard.py` /
  `.ps1` pick the template from `theme` in `dashboard.json` (`brand` default, `f1`) and take
  `--theme` / `-Theme` to set it; first creation copies every file in `templates/`. The footer
  selector on both pages tells the human to ask the agent to switch. Skill text covers *"use the
  F1 theme"*.
- **`update-framework` skill:** refreshes both templates.

## 5.3.5 — October 10, 2026

**Bundles:** full runbook v5.3.5.0, Lite v5.3.5.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.3.5.0. Dashboard template and renderers.

- **`dashboard` skill: in-place data refresh with a countdown.** `templates/dashboard.html` no
  longer calls `location.reload()`; its render code is one `paint(D)` function that runs on load
  and again whenever the page pulls `ocpfFramework/state/dashboard-data.js` (every
  `refreshSeconds`, via a `<script>` tag so it works from `file://`) and finds a newer
  `generatedAt`. Entrance animations play once; the Live pill reads *next in N s* and pulses on
  new data. `ocpf-dashboard.py` and `ocpf-dashboard.ps1` write the sidecar beside the page's
  embedded data and set `dataUrl`. Without the sidecar the page falls back to a reload.

## 5.3.4 — October 10, 2026

**Bundles:** full runbook v5.3.4.0, Lite v5.3.4.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.3.4.0. Template and notices only.

- **`dashboard` skill: Business Central product icon in the header.** `templates/dashboard.html`
  stacks the status pills over the Microsoft Dynamics 365 Business Central icon (PNG data URI,
  64 px), filling the empty space above the KPI tiles. Credited in `THIRD_PARTY_NOTICES.md`.

## 5.3.3 — October 10, 2026

**Bundles:** full runbook v5.3.3.0, Lite v5.3.3.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.3.3.0. Template and notices only.

- **`dashboard` skill: official tool marks in the header pill.** `templates/dashboard.html` embeds
  the Claude mark (simple-icons `claude`, CC0; Anthropic's mark, brand orange `#D97757`) for Claude
  Code and Primer Octicons `copilot-24` (MIT, © GitHub Inc.) for Copilot Chat / CLI, replacing the
  *CC* / *GH* letter badges. Inline SVG, no network. Credited in `THIRD_PARTY_NOTICES.md`.

## 5.3.2 — October 10, 2026

**Bundles:** full runbook v5.3.2.0, Lite v5.3.2.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.3.2.0. Scripts and one hook; `update-framework` migrates.

- **`usage` and `dashboard` skills: sub-agent transcripts were never read.** Claude Code journals
  each `Agent` call in `<session>/subagents/agent-*.jsonl`; `ocpf-usage.py`, `ocpf-usage.ps1`,
  `ocpf-dashboard.py`, and `ocpf-dashboard.ps1` globbed only `<tdir>/*.jsonl`. Result on a real
  project: the Reasoning role's 2.16M Opus tokens absent from every usage row and total, and the
  role shown idle while it drafted the FRD. All four now read both; a running sub-agent marks
  Main as working.
- **`dashboard` skill: the page refreshes inside a turn.** New unmatched `PostToolUse` hook
  (Claude Code) / `postToolUse` (Copilot CLI) running the renderer with `--throttle 45`
  (`-Throttle 45`): every tool call, the sub-agents' included, re-renders at most once per 45
  seconds. Before it the page froze from a turn's start to its `Stop` — a whole FRD draft.
- **`update-framework` skill:** merges the new hook into existing projects and re-runs the usage
  table so closed steps gain their sub-agent rows.
- **`status` skill:** names both symptoms and the repair.

## 5.3.1 — October 10, 2026

**Bundles:** full runbook v5.3.1.0, Lite v5.3.1.0, Standards Guide v1.12.0.0 (unchanged),
Operations Guide v5.3.1.0. Template fix only.

- **`dashboard` skill: the *Waiting on you* card's options no longer overflow.** `templates/dashboard.html`
  laid each option out as label | description on one row with the label set to `nowrap`; a long
  label (the recommended option's suffix) pushed out of the card and left the description a
  one-word column. Options now stack: label (wrapping) over description. Verified headless in both
  themes with a real question. `update-framework` refreshes the template and re-renders.

## 5.3.0 — October 10, 2026

**Bundles:** full runbook v5.3.0.0 (core + 14 step files), Lite v5.3.0.0 (core + 7 step files),
Standards Guide v1.12.0.0 (unchanged), Operations Guide v5.3.0.0. One file moves on an existing
project; `update-framework` moves it.

- **`dashboard` skill: the page is `ProjectDashboard.html` at the project root, tracked in git.**
  5.2.0 rendered it into `ocpfFramework/state/`, which every project gitignores, so the first real
  project found its dashboard missing from the repository. Both renderers (`ocpf-dashboard.py`,
  `ocpf-dashboard.ps1`) and the template's footer now name the root path; the hooks are unchanged.
  First creation proves the page is not ignored (`git check-ignore -v ProjectDashboard.html` prints
  nothing) and stages it; the explanation text tells the human it is tracked and travels with the
  project. The repair bullet moves a 5.2.0 project's page.
- **`dashboard` skill: `ocpf-dashboard.ps1` rendered nothing on PowerShell 7.** A local `$open`
  collided with the script's `[switch]$Open` parameter (names are case-insensitive): *Cannot
  convert the "1" value of type Int32 to SwitchParameter* on every run, hidden by `-Quiet` in the
  hooks. Renamed; verified with and without `usage.json`.
- **`update-framework` skill:** step 3a deletes `ocpfFramework/state/dashboard.html` after the
  first render with the new scripts, proves the new path is tracked, and stages it.
- **`status` skill:** reports a project still carrying `ocpfFramework/state/dashboard.html` as
  needing `update-framework`; gives the root path.
- **`start` skill:** names the root path.

## 5.2.0 — October 10, 2026

**Bundles:** full runbook v5.2.0.0 (core + 14 step files), Lite v5.2.0.0 (core + 7 step files),
Standards Guide v1.12.0.0 (new §1.9 *Enums, Never Options*; §2.2 API pages aligned with BCQuality —
`DelayedInsert = true` on every API page, read-only pages add the three `*Allowed = false` guards;
Part 7 rows), Operations Guide v5.2.0.0; `ProjectProgress.md`, `TDD.md`, and `DesignDoc.md` templates updated. No layout change: `update-framework` replaces the runbook, step files, and Operations
Guide, no migration.

- **`usage` skill: Copilot credits from the Copilot SDK session journal.** Both script ports
  (`ocpf-usage.py`, `ocpf-usage.ps1`) read `~/.copilot/session-state/<id>/events.jsonl`
  (`%USERPROFILE%\.copilot\session-state` on Windows): the project folder from `session.start`,
  the cumulative credits from `session.usage_checkpoint` and `session.shutdown` (`totalNanoAiu` ÷
  1e9), model requests from `assistant.message`, turns from `user.message` plus answered
  `ask_user` calls, decisions from `ask_user`, sub-agents from `subagent.started`. Per-step split
  by request share between journaled points; one row per step with every model named; open
  sessions reported *as of* their last checkpoint. The reader exists because VS Code 1.139 moved
  agent-mode sessions there, and the v5.1.0 reader, which only knew
  `workspaceStorage/<hash>/chatSessions/`, fell back to asking the human for the popover figure
  on every step of a real project.
- **New options:** `--journal <dir>` / `-Journal` (a session-state folder on another machine),
  `--reconcile` / `-Reconcile` (month-to-date AI credits from GitHub's billing API via `gh api`,
  needs `gh auth refresh -s user` once; printed as a cross-check, never a row), `--tool
  copilot-cli` accepted — the CLI is measured from the same journal, the script no longer refuses
  it. `--sessions` and `--session-credits` remain for pre-SDK chat files and the no-journal last
  resort; popover checkpoints stored by 5.1.0 are superseded by the journal and ignored with a
  note. `--json` adds `journalDirs`, `sessions` (id, client, start, last known figure, closed,
  requests, models), and `githubMonthToDate`. `usage.json` gains `copilot.journalDirs`.
- **SKILL.md** rewritten for the journal: never ask the human for a number; re-run without
  `--step` at the next boundary so a mid-chat row settles; `--journal` before `--session-credits`;
  and, in a GitHub Copilot in VS Code project on the Full edition, the main role delegates the
  script run to the `ocpf-reasoning` sub-agent and writes what it returns.
- **New `dashboard` skill** (`/ocpf-bc:dashboard`): `scripts/ocpf-dashboard.py` and
  `scripts/ocpf-dashboard.ps1` render `templates/dashboard.html` into
  `ocpfFramework/state/dashboard.html` from the project's own state (the usage script's JSON
  included); `--open` opens it once; `--live`, `--waiting-json`, `--clear-waiting`, `--event` are
  the hook entry points; `--quiet` never fails the agent's turn. Both ports verified to embed
  identical data on a real Full project and a real Copilot project. The skill installs the Claude
  Code / Copilot CLI hooks, runs the one-time explanation question, and documents the right-click →
  **Open Externally** route. The `usage` skill's step close renders the page in Copilot Chat; the
  `ocpf-reasoning` brief includes the render; `status` reports a missing dashboard;
  `update-framework` refreshes the scripts and creates the page on older projects; `start` notes
  that PRE-01 / Step 1 owns the moment.
- **`start` skill** notes the OnlyBCFans BC Copilot Blueprint as a conditional fetched companion
  (not bundled; fetched only for projects with a Business Central Copilot feature, outside the
  project root). The runbooks and Ops carry the rule.
- **Standards Guide bundled from its own repository.** `syncPlugin.sh` now fetches
  `ajansari/ocpfBCALStandards` at the pinned tag **`v1.12.0.0`** into `skills/al-standards/references/`
  (falling back to the sibling checkout with a warning when the tag is unreachable) and warns if
  the bundled version and the pin disagree. The `al-standards`, `start`, and `update-framework`
  skills and the GitHub code-reviewer agent name the new source; a project's on-disk path is
  unchanged.
- **`agents/ocpf-reasoning.agent.md`** lists that delegation among the role's tasks, with the
  output contract (table, notes, and `--json` sessions summary, verbatim).
- Verified on the project that failed: the journal's 1,143 credits against the 1,055 the human had
  read from the popover ninety seconds earlier; both ports print identical tables.

## 5.1.0 — October 1, 2026

**Bundles:** full runbook v5.1.0.0 (core + 14 step files), Lite v5.1.0.0 (core + 7 step files),
Standards Guide v1.11.0.0 (unchanged), Operations Guide v5.1.0.0; templates unchanged. No layout
change: `update-framework` replaces the runbook, step files, and Operations Guide, no migration.

- **Every step closes through `AskUserQuestion`** (or the harness's equivalent). A real run on
  5.0.0 closed Steps 1–7 with a prose prompt because Rule 6c applied the check-in only from Step
  08 (Lite: Step 5) and Rule 6a excluded "finishing a step" from the box. Rule 6c, Rule 6a, Ops §
  Asking and Approvals, and every step file now require **Proceed into Step <next> now
  (recommended)** / **Stop here** as the last thing in every step's closing message, with the
  final hand-off keeping its own two-option box. Nothing in the skills changes; the `usage`
  skill's "before the Rule 6c check-in" ordering now applies to every step.
- **Resume re-asks the box.** New runbook Rule 6e (both editions) and Ops § *Interrupted and
  resumed*: after Escape, a stop, or a closed session, "continue" re-asks whatever is still
  unanswered through `AskUserQuestion`, from the project's files, and keeps the step-close box
  at every later step. The `status` skill now reports an unanswered box under *Waiting on you*.

## 5.0.0 — September 27, 2026

**Bundles:** full runbook v5.0.0.0 (core + 14 step files), Lite v5.0.0.0 (core + 7 step files),
Standards Guide v1.11.0.0, Operations Guide v5.0.0.0 — **one version number across the Full and
Lite runbooks, the Operations Guide, and this plugin from this release on** (the plugin goes from
3.1.0 to 5.0.0; no 4.x was released) — 20 document templates (`UsageReport.md`
retired; `AiEffortEstimate.md`, `HumanEffortBaselines.md`, and `Acknowledgements.md` added). A
major version with the runbooks: **a project on an older plugin needs `update-framework`'s
migration** — it moves the framework's files under `ocpfFramework/`, the documents into their
`docs/` phase folders, rewrites `.gitignore`, `.mcp.json`, and the hook paths, and (Lite) creates
`ProjectProgress.md` from `docs/UsageReport.md`.

- **New project layout.** Everything the framework fetches or keeps lives under `ocpfFramework/`:
  `framework.json` (was `.ocpf/framework.json`, now with `"layout": "ocpfFramework-1"` and
  `"tooling": {}`), the runbook changelog and schematics, `state/` (usage, prices, notifications,
  Copilot settings, backups — always gitignored), `standardsGuide/`, `opsGuide/`, `runbookSteps/`,
  `documentTemplates/`, `patterns/`, `scripts/`, and a six-line `README.md`. A pre-existing
  `CLAUDE.md` imports `@ocpfFramework/BC_App_Build_Routine_Agent.md`. `docs/` is laid out by phase
  (`0-project/`, `1-define/`, `2-design/`, `3-build/`, `4-prove/`). `.mcp.json` and the notification
  hooks point at `ocpfFramework/scripts/`. The `start`, `status`, `update-framework`, `al-mcp-setup`,
  `notifications`, `al-standards`, `documents`, `usage`, and `roles` skills, the sub-agents, and the
  usage scripts all use the new paths.
- **New `ocpf-generator` sub-agent** (both editions): writes the AL files of exactly one batch from
  a narrow brief — one complete file per Write, no narration, symbols verified only for what the
  brief left open, Microsoft Learn only when the symbols can't answer — and never edits the
  ChangeLog, Object Register, TDD, or another batch's files. Opens with the `Model:` line like the
  other two and ends with a fixed report (files written, deviations, open questions). Runs on the
  Main model; the `roles` skill materializes `.claude/agents/ocpf-generator.md` /
  `.github/agents/ocpf-generator.agent.md` in both editions, so batches can be generated in parallel.
- **`roles`:** the one-sentence warning that a High effort slows every task; the recommendation
  table per edition and tool (Full · Claude Code: Sonnet Medium / Haiku Medium / Opus High; Full ·
  Copilot: Gemini 3.8 Flash Medium / Auto Balanced / Claude Opus 5.5 High; Lite: Sonnet Medium or
  Gemini 3.8 Flash Medium), offered first; Copilot agent files carry `reasoningEffort:`; every
  delegation runs in the background; the first-session fallback covers the generator; repair adds
  the generator to older projects without a new question.
- **`ocpf-light` and `ocpf-reasoning`:** the Learn rule — symbols are the only routine lookup, Learn
  only when they can't answer, and say why; the `ocpfFramework/BC_App_Build_Routine_Agent.md`
  runbook location; both note they run in the background and that only their report reaches the
  main role.
- **`usage`:** the step boundary ritual — `/ocpf-bc:usage --step <id>` at every start and close,
  one row per model that ran, rows pasted into the closing message, the exit gate not met without
  them, never a hand-written Claude Code row; the table is `ProjectProgress.md`'s second table in
  **both** editions; `ocpf-usage.py` and `.ps1` default to `ocpfFramework/state/usage.json` and
  `pricing.json`, and gain `--calibrate` / `-Calibrate`, which writes
  `~/.ocpf/calibration/<project>-<date>.json` at project close (per step and per model tokens by
  type, elapsed, turns, decisions, sub-agent calls, throughput, and the object counts by type from
  the Object Register or the Design Doc). The `.ps1` port's `-Usage`, `-Pricing`, and `-Step`
  parameters now work (they had silently collided with internal variables of the same name).
- **`usage`, GitHub Copilot (added September 29, 2026):** Copilot projects are **measured in AI
  credits**, the unit GitHub has billed in since June 1, 2026, instead of asking the human for
  premium requests. `ocpf-usage.py` and `.ps1` read `aiTool` from `usage.json`; for
  `copilot-chat` they find the project's `chatSessions` folder in VS Code's workspace storage,
  rebuild each session from its operation log, split every turn's credits between the Main model
  and its sub-agent calls, store a **checkpoint** per step close in `usage.json` (a turn runs
  across steps, so a step's row is the difference between checkpoints), price the credits from
  `pricing.json`'s new `aiCredit` entry, and print the ten-column **credits table** — no token
  columns. New options: `--tool`, `--sessions <dir>`, and `--session-credits <n>` (PowerShell
  `-Tool`, `-Sessions`, `-SessionCredits`) — the last records the *Session Cost* the human reads
  in the Session Info popover when the session files can't be read. Verified on a real Copilot
  project: the table's total equals the popover's Session Cost, and the two ports print identical
  tables. Also: `--calibrate` now refuses `--step`; the `.ps1` port floors minutes (it printed
  "0h 60m" for 3,599 seconds), formats cost without culture-specific separators, and reads
  timestamps that PowerShell had already parsed as dates in UTC.
- **`documents`:** a folder map (document → `docs/` subfolder); the Human Effort Estimate reads
  the Human Effort Baselines (or `~/.ocpf/HumanEffortBaselines.md`); the new AI Effort Estimate
  (Full Step 03 / Lite Step 2, reads the calibration store); Acknowledgements (Full Step 11 / Lite
  Step 6); `ProjectProgress` for both editions; no Usage Report.
- **`status`:** reads `ProjectProgress.md` in both editions, reports a closed step with no usage
  row as a blocker, and reports `tooling` (mermaid, pwsh) from `framework.json`.
- **`start`:** places files per the new layout, writes the six-line `ocpfFramework/README.md` and
  the new marker fields, and describes the three sub-agents and Lite's `ProjectProgress.md`.
- **`update-framework`:** the Migration section (Full < 5.0.0.0 / Lite < 5.0.0.0), step by step;
  refreshes patterns and scripts with the steps and templates; writes the generator definition;
  backups go to `ocpfFramework/state/previous/`.
- **`al-mcp-setup`:** `al-analyze.sh` and `al-analyze.cmd` refuse to overwrite an existing output
  `.app` — exit code 4, message names the file and says to increment the version — before the
  compile runs; the Windows `.mcp.json` example's backslashes are now valid JSON.
- **Manifests:** both describe the generator sub-agent and the estimates, and carry the license
  identifier `PolyForm-Shield-1.0.0`.
- **License (October 1, 2026):** the plugin, like the whole framework, is released under the
  PolyForm Shield License 1.0.0 (`LICENSE` at the repository root;
  <https://polyformproject.org/licenses/shield/1.0.0>) — source-available, free to use, free to
  build commercial PTE and AppSource extensions with; copyright AnsariCo, Inc. dba OnlyCopilotFans
  and OnlyBCFans.

## 3.1.0 — September 21, 2026

**Bundles:** full runbook v4.1.0.0, Lite v3.1.0.0, Standards Guide v1.10.0.0, Operations Guide
v2.0.1.0, 18 document templates.

- **Standards Guide Part 11** (parent–child pages, number-series fields, and the sandbox checks that
  prove them) is bundled, with the five new Part 7 anti-pattern rows.
- **`al-standards`** description now triggers on list parts, subforms, related-record lists, setup
  pages, assisted setup wizards, number-series fields with no lookup, and the message "The view is
  filtered, and the entry is outside the filter"; its parts count is corrected to 1–11 / A–E.
- Runbook step files, templates, and changelogs re-synced.

## 3.0.0 — September 19, 2026

**Bundles:** full runbook v4.0.0.0 (core + 14 step files), Lite v3.0.0.0 (core + 7 step files),
Standards Guide v1.9.0.0, Operations Guide v2.0.0.0, 18 document templates. A major version with
the runbooks: a project started on an earlier plugin needs the step files and templates fetched
before the new core runbook is usable, which `update-framework` now does.

- **New `documents` skill** (`/ocpf-bc:documents <name>`): writes any project document from its
  template with only the inputs its step names, briefing the reasoning sub-agent narrowly where the
  step delegates (step file + template + input paths + the cited Standards § sections, never the
  whole runbook). Templates bundled in `skills/documents/references/`, synced from the repository's
  `documentTemplates/`. Includes the new Human Effort Estimate.
- **New `usage` skill** (`/ocpf-bc:usage`): keeps `.ocpf/usage.json` step timestamps, reads Claude
  Code's session transcripts (`scripts/ocpf-usage.py`; `.ps1` port, untested on Windows) for input,
  output, cache-write, and cache-read tokens per step and model, sub-agents included, deduped by
  request; records Copilot premium requests; fetches published prices into `.ocpf/pricing.json`
  (never hardcoded); prints and writes the usage table (`ProjectProgress.md` second table, or
  `docs/UsageReport.md` in Lite).
- **`start`** explains the step-file split, sets the "first hour is interactive, then step away"
  expectation, and notes the two Copilot session-settings questions the runbook asks at its first
  step. Bundled step files live in `skills/start/references/steps/full/` and `steps/lite/`.
- **`update-framework`** refreshes `runbookSteps/` and `documentTemplates/` with the runbook and
  checks each step file's version line.
- **`status`** reads the current step's file for the exit gate (only that file), and reports the
  usage total and, with Copilot, the session settings.
- **`syncPlugin.sh`** now syncs folders (steps and templates) as well as files, removing bundled
  files that no longer have a canonical source; `--check` reports them as stale. It also runs the
  new **`buildStubs.py --check`**, which fails when a core runbook's step stubs differ from their
  step files.
- **Manifests and CI:** both plugin manifests and the marketplace entry describe the templates and
  usage tracking; `plugin-check.yml` also triggers on `documentTemplates/**`.

## 2.4.0 — September 18, 2026

**Bundles:** full runbook v3.4.0.0, Lite v2.3.0.0, Standards Guide v1.9.0.0, Operations Guide
v1.3.0.0.

- **`ocpf-reasoning` and `ocpf-light` now prove which model they ran on.** Each opens every report
  with a `Model:` line and stops on its own if it can read the project's §1.7 and is running on a
  different model. They still carry no `model:` of their own — the same file is read by Claude Code
  (which wants `opus`) and Copilot (which wants a picker name) — so the runbook now has the project
  write local copies with the chosen model and effort at PRE-01 and delegate to those, passing the
  model on every Claude Code call as well (runbook Operating Rule 10; Ops § Roles → *Enforcement*).
  On a real project every delegated task had silently inherited the session's model.
- **New `roles` skill** (`/ocpf-bc:roles`): asks the model and effort questions at the runbook's
  first step (six in Full, two in Lite) through each harness's own mechanism — two
  `AskUserQuestion` boxes in Claude Code, one `askQuestions` carousel in Copilot Chat, one at a
  time in Copilot CLI — writes the project-local `ocpf-reasoning` and `ocpf-light` copies with the
  chosen model and effort (`.claude/agents/*.md` with `model:` + `effort:`; `.github/agents/*.agent.md`
  with `model:`, read by Copilot in VS Code and the CLI — `model:` is documented for the IDEs only,
  so in the CLI the `Model:` first-line check is the guarantee), records the assignment, and handles the
  one first-session catch in Claude Code (a new `.claude/agents/` folder loads at the next start, so
  until then the bundled agents are used with the model passed per call). Also repairs a project
  whose roles ran on the wrong model. Left out of the Cowork package, which has no sub-agents.
- **`start`** tells the human the model questions come right after notifications (six in Full, two
  in Lite), points at the `roles` skill, and says that every document goes in `docs/` and that the
  `.gitignore` answer is applied by exact filename and checked.
- **`status`** reads `docs/ChangeLog.md` and `docs/ProjectParameters.md` in both editions, reports
  the recorded model per role, and says if the project-local sub-agent definitions are missing —
  meaning delegated steps would run on the session's model.
- **`update-framework`** records its ChangeLog entry at `docs/ChangeLog.md` and offers to move an
  older project's documents into `docs/`.
- **Bundled runbooks and guides:** the front-loaded model questions, the `docs/` rule, and the
  exact-name `.gitignore` block with `git check-ignore` verification.

## 2.3.0 — September 15, 2026

**Bundles:** full runbook v3.3.0.0, Lite v2.2.0.0, Standards Guide v1.9.0.0, Operations Guide
v1.2.0.0.

- **`al-mcp-setup` corrected on analyzers.** `al_build` never applies them; `al_compile` does, but
  only with `enableCodeAnalysis: true` and a `codeAnalyzers` token list at the top level of
  `options` — anything else (a `parameters` wrapper, literal DLL paths) silently returns a clean
  pass on failing code. `scripts/al-analyze.*` stays the mandatory compile, since `al_compile`
  writes no `.app`. The `al-analyze.sh` header now records all of it.
- **Bundled runbooks and guides:** AppSource intake and manifest requirements, Standards Parts 9
  (upgrade and data migration) and 10 (events and extensibility), `al_run_tests` wired into the
  testing step, and the Step 07 schematic redrawn to match the first-round API offer.

## 2.2.0 — September 15, 2026

**Bundles:** full runbook v3.2.0.0, Lite v2.1.0.0, Standards Guide v1.8.0.0, Operations Guide
v1.1.0.0.

- **Bundled runbooks:** the agent-run API pass is offered at the first build of the fix cycle, with
  its sign-in cost stated and a standing option to decline.

## 2.1.0 — September 15, 2026

**Bundles:** full runbook v3.1.0.0, Lite v2.0.1.0, Standards Guide v1.8.0.0, Operations Guide
v1.1.0.0.

- **`update-framework`** checks a version by fetching the first kilobyte of the published runbook
  rather than the whole file, and downloads it in full only after "Update now".

## 2.0.0 — September 15, 2026

**Bundles:** full runbook v3.0.0.0, Lite v2.0.0.0, Standards Guide v1.8.0.0, Operations Guide
v1.0.0.0.

- **New companion:** the Operations Guide is bundled in the `start` skill's `references/` and
  fetched into each project alongside the Standards Guide. `start` places both and falls back to the
  bundled copies when GitHub is unreachable.
- **`update-framework`** refreshes both companions to the versions the new runbook expects, and
  flags a major-version mismatch, since the runbook cites **Ops §** sections by name.
- **Sub-agents and the github.com reviewer** read the Operations Guide alongside the Standards
  Guide.
- **Major version** because a project updated to these runbooks needs the new companion on disk:
  the runbooks cite procedures that no longer live inside them.

## 1.7.0 — September 15, 2026

**Bundles:** full runbook v2.15.0.0, Lite v1.12.0.0, Standards Guide v1.7.0.0.

- **New `notifications` skill:** asks how the developer wants to be told it's their turn — Claude
  app push, sound, desktop notification, or none — explains Remote Control before a Claude app
  choice, records the answer in `.ocpf/notifications.json`, and applies it through each AI tool's
  own notifications and hooks. Includes `ocpf-notify.sh` and `ocpf-notify.ps1`. The runbooks ask at
  their first step; the skill adds it to older projects.
- **`status`:** reports the recorded notification kinds, or offers the skill when none are set.
- **`start`:** notes that the runbook asks right after the working language, and that choosing a
  notification kind counts as asking for the settings it needs.
- **Copilot Cowork package:** leaves out the `notifications` skill, which can't work there.

## 1.6.0 — September 15, 2026

**Bundles:** full runbook v2.14.0.0, Lite v1.11.0.0, Standards Guide v1.7.0.0.

- **`al-analyze.*` scripts:** exit `3` when the compile succeeds with warnings (the compiler
  itself exits 0), find the global `al` tool's analyzers (the tool-store search was one folder
  short), fall back to the VS Code extension when a runtime is missing, and count diagnostics
  printed without a file location. `al-analyze.cmd` exits 1 on a usage error, like the `.sh`.
- **`al-mcp-setup`:** copies any missing `al-analyze.*` even when the AL MCP Server is already
  connected, and in cloud sessions.
- **`ocpf-code-reviewer`:** relies on a 0/0 compile only when a build log or CI run shows it;
  otherwise checks `tabledata` coverage and ML syntax by hand, and names `AS0103` for AppSource.
- **Bundled runbooks and Standards Guide:** file naming (Standards §1.8) and camelCase API naming
  (Standards §2.7) so projects pass CodeCop with every rule on. See `RunbookChangelog.md` v2.14.0.0.

## 1.5.0 — September 15, 2026

**Bundles:** full runbook v2.13.0.0, Lite v1.10.0.0, Standards Guide v1.6.0.0.

- **`start`:** names the question mechanism for Claude Code, GitHub Copilot Chat in VS Code, and
  GitHub Copilot CLI.
- **Bundled runbooks:** intake grouped into far fewer option boxes, and AL rules cited from the
  Standards Guide instead of restated. See `RunbookChangelog.md` v2.13.0.0.

## 1.4.0 — September 15, 2026

**Bundles:** full runbook v2.12.0.0, Lite v1.9.0.0, Standards Guide v1.5.0.0.

- **`al-mcp-setup` and `start`:** connecting the AL tools is the agent's job, so the skill says what
  it's doing instead of asking. A postponed setup now points at the runbook's §1.10 (Lite: end of
  Step 1). The skill copies the analyzer scripts (`al-analyze.*`) into the project alongside the
  launchers, and notes that GitHub Copilot Chat takes its analyzers from `.vscode/settings.json`.
- **`ocpf-code-reviewer`:** framework projects gitignore `.alpackages/`, so the reviewer checks
  symbols only when present and otherwise marks the item as not verified.
- **Bundled runbooks:** batched approvals, a single approver option, translation drafting once
  source text is stable, and `.alpackages/` always gitignored. See `RunbookChangelog.md` v2.12.0.0.

## 1.3.0 — September 15, 2026

**Bundles:** full runbook v2.11.0.0, Lite v1.8.0.0, Standards Guide v1.4.0.0.

- **New scripts:** `al-analyze.sh` (macOS/Linux) and `al-analyze.cmd` + `al-analyze-resolve.ps1`
  (Windows, untested on Windows) — run the mandatory compile with Microsoft's bundled code
  analyzers actually engaged. Verified necessary: the AL MCP Server's own `al_build`/`al_compile`
  tools don't reliably apply analyzers (six attempts, all silently produced a clean result on code
  that should have failed). See `RunbookChangelog.md` v2.11.0.0.
- **Runbook cleanup:** the bundled runbooks and Standards Guide correct a repeated, false claim
  ("nothing catches a missing permission set before publish") and drop dated narrative from an
  independent review, shrinking what's loaded every session.

## 1.2.1 — September 15, 2026

**Bundles:** full runbook v2.10.0.0, Lite v1.7.0.0, Standards Guide v1.3.0.0 (unchanged).

- **Repository reorganization only — no runbook rule changed.** The full framework's four files
  (`BC_App_Build_Routine_Agent.md`, `Outline_OCPFBCAgenticDevFW.md`, `RunbookChangelog.md`,
  `RunbookSchematics.md`) moved from the repository root into `fullVersion/`, mirroring
  `liteVersion/`. Updated to match: the `start` and `update-framework` skills' fetch URLs,
  `agentPlugin/tools/syncPlugin.sh`'s canonical source paths, and cross-references in the Standards
  Guide, the Lite runbook, and the GitHub Copilot code-reviewer agent.
- **Why a patch release:** the `start` and `update-framework` skills fetch the full runbook and its
  changelog from a fixed GitHub URL; that URL now includes `fullVersion/`. Bundling the fix keeps
  every install fetching from the current path.

## 1.2.0 — September 15, 2026

**Bundles:** full runbook v2.10.0.0, Lite v1.7.0.0, Standards Guide v1.3.0.0.

- **Unique permission set names.** The bundled runbooks and the Standards Guide (`al-standards`)
  name permission sets `<PREFIX> <APPCODE>, VIEW` / `, EDIT`. The App Code is unique to each
  extension, so extensions that share a prefix no longer collide (Standards §5.4).

## 1.1.0 — September 15, 2026

**Bundles:** full runbook v2.9.0.0, Lite v1.6.0.0, Standards Guide v1.2.0.0 (unchanged).

- **New one-shot helpers:** `al-mcp-call.sh` (macOS/Linux) and `al-mcp-call.ps1` (Windows).
  - **Why:** Claude Code and Copilot CLI load MCP servers only when a session starts. The helper
    runs one AL MCP Server tool through the launcher and exits, so the agent can download symbols
    and compile in the same session it registered the server, without a restart.
  - **Tested:** the macOS helper, end to end.
  - **Not yet run:** the Windows helper.
- **`al-mcp-setup`:**
  - Copies the helpers.
  - Never sends the human to the Command Palette, and never uses a third-party bridge extension.
  - Keeps working in the same session, and downloads symbols when the project already has
    `app.json`.
  - No longer tells the human to restart or run `/mcp`.
- **Bundled runbooks** updated to full v2.9.0.0 and Lite v1.6.0.0: interactive intake, symbols
  downloaded by the agent before DESIGN, and stale editor marks detected and fixed.

## 1.0.1 — September 15, 2026

**Bundles:** full runbook v2.8.0.0, Lite v1.5.0.0, Standards Guide v1.2.0.0 (unchanged).

- **Added a GitHub Copilot manifest,** `.github/plugin/plugin.json`, alongside
  `.claude-plugin/plugin.json`. GitHub's plugin intake tooling only recognizes `plugin.json`,
  `.github/plugin/plugin.json`, or `.plugin/plugin.json`, so v1.0.0 failed its install smoke test
  and version check. Both manifests carry the same metadata, and `syncPlugin.sh --check` fails if
  they drift.
- **`start`:** if the AL tools step is postponed or skipped, the marker now records
  `"alMcp": "deferred"` instead of staying at `not-checked`.

## 1.0.0 — September 14, 2026

First release.

**Bundles:** full runbook v2.8.0.0, Lite v1.5.0.0, Standards Guide v1.2.0.0.

**Skills:**
- `start`: Full-or-Lite choice, latest runbook from GitHub (bundled fallback), never overwrites,
  zero-install AL tool connection.
- `status`
- `update-framework`: approval-gated project runbook updates.
- `al-standards`
- `al-mcp-setup`

**AL tools, zero-install:** `al-mcp-setup` uses the AL Language extension's built-in Copilot tools, or registers its bundled AL MCP Server per project with launcher scripts (`al-mcp.sh`; `al-mcp.cmd` + `al-mcp-resolve.ps1` on Windows).

**Sub-agents:** `ocpf-reasoning` and `ocpf-light`, for the full framework's §1.7 roles.
