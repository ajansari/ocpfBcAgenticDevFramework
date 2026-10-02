# ocpf-bc plugin: Changelog

The plugin is versioned with three-part semantic versions, independently of the runbooks. Each
entry names the framework versions bundled as the offline fallback. The `start` skill always
fetches the latest runbook from GitHub first, so a project isn't limited to the bundled versions.

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
