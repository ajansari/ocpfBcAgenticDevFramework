---
name: status
description: Report where a Business Central project following the OCPF BC Agentic Development Framework stands - current phase and step, its exit gate, what's waiting on the human, whether every closed step has its usage rows, framework edition and version (Full, Lite, or Build-a-Feature, whose rows are objects), tooling recorded, and AL MCP Server status. Use when the user asks "where are we", "project status", "what's next", "what step are we on", or resumes an OCPF project in a new session or from another device.
---

# OCPF project status

Give a short, accurate status report from the project's own files. Read them fresh; don't rely on
conversation memory.

## What to read

1. **`ProjectProgress.md`** (project root, every journey): the step-by-step tracker and, below it,
   the usage table. **On a Build-a-Feature project** (`"edition": "feature"` in the marker) the
   tracker is the **feature table** — one row per object (`F01`, `F02`, …), plus `F00` intake,
   `FRV` review, `FPK` package, each with a stage (*Asked → Confirmed → Built → Compiled →
   Documented → Reviewed → Packaged*) and a status — and a Full or Lite project may carry that table too, under
   `## Build-a-Feature`, when the journey ran on it: report those rows as well, after the steps.
   A **remediation row** (`07a — Remediation`, `STEP-5a — Remediation`; Ops § Usage & Cost → 7)
   sits under its base step: report it as its own step, with the step the project returns to. Find the step marked `In Progress`, or the first one not complete. Then check
   the usage table against the step table: **every step marked `Completed` must have at least one
   usage row** (one per model that ran); a closed step with no row is a blocker (Full Operating
   Rule 11 / Lite Rule 9 — the exit gate wasn't met).
2. **The step file** — `ocpfFramework/runbookSteps/<step>.md` (Full v4.0.0.0 / Lite v3.0.0.0 on; a
   Build-a-Feature project has none: the row's "gate" is the stage ladder in Ops § Build-a-Feature; on an older
   runbook, the step's section in `CLAUDE.md`, `.github/copilot-instructions.md`, or the file named
   in `ocpfFramework/framework.json`): that step's **Exit gate** and outputs. Read it; don't paraphrase from
   memory. Read only the current step's file.
2b. **`ocpfFramework/state/dashboard.json`** and the page at the project root: whether the dashboard exists
   and its hooks are installed (`hooks`) and proven (`runner`, `hooksVerified` — a project with
   `hooks: true` and no `hooksVerified` has hooks that were written but never run, which on a real
   Windows project meant a page frozen at *Untitled extension* all build long: say so and point to
   the `dashboard` skill's proof); report a project without a dashboard, or one whose hooks
   are missing, as something to repair with the `dashboard` skill, and give the path
   `ProjectDashboard.html` and the right-click → **Open Externally** route. A project that still
   has `ocpfFramework/state/dashboard.html` (v5.2.0.0) needs the `update-framework` skill; so does
   one whose hooks lack the unmatched `PostToolUse` entry (the page freezes for a whole turn) or
   whose usage rows name no sub-agent model (scripts before v5.3.2.0 never read
   `<session>/subagents/`).
3. **`ocpfFramework/framework.json`**, if present: edition, runbook version, `layout`, `alMcp`, and
   `tooling` (mermaid and pwsh, recorded by Ops § Tooling Checks). Also
   **`ocpfFramework/state/notifications.json`**, if present: the notification kinds this developer chose.
   (A project on the old layout has `.ocpf/framework.json` instead and no `layout` field: say so,
   and offer the `update-framework` skill, whose migration moves it.)
4. **Recent context:** the latest entries in `docs/0-project/ChangeLog.md`. For Full, also
   `docs/0-project/ProjectMemory.md`. (A project started on a runbook older than Full v5.0.0.0 /
   Lite v5.0.0.0 keeps its documents flat in `docs/`, or — older still — in the root; look there
   second, and say so.)
5. **Parameters:** `docs/1-define/ProjectParameters.md` (both editions), for the extension name and the
   model assignment (Full §1.7: Main, Light, Reasoning — the generator runs on Main; Lite: the Main
   model row).

A Build-a-Feature project keeps no `ProjectParameters.md`; its model, language, publisher, prefix,
namespace, and ID ranges are in `ocpfFramework/state/feature.json`, **each with its source** —
`publisherSource` and `idRangesSource` must name a box the human answered (Ops § Intake →
*Forbidden sources*); a file that lacks either, or whose source says the value was read from
`app.json` or a scaffold, is a blocker to report: the next object must not be built until the
question is asked. Its documents are flat in `docs/` (`ProblemStatement.md`, `FeatureRegister.md`,
`DataModel.md`, `Documentation.md`, `ChangeLog.md`, `SandboxInstall.md`); report an object row
past *Compiled* whose section is missing from `docs/Documentation.md` or `docs/DataModel.md`. An
`AN0` window or usage row is the `analyze` skill's run on this app (Ops § Existing Apps); its
output is `requirements/existing/`. If `ProjectProgress.md` doesn't exist — and, for Lite, neither `docs/1-define/ProjectParameters.md`
nor `docs/2-design/DesignDoc.md` exists either — the routine hasn't started. Say so, and offer the
`start` skill. (A Lite project from before Lite v5.0.0.0 has no tracker and keeps its usage table
in `docs/UsageReport.md`; report from the ChangeLog and offer `update-framework`.)

## What to report

Keep it to a compact block:

- **Project:** extension name, framework edition (Build-a-Feature, Full, or Lite), and runbook
  version (Build-a-Feature: the framework version the companions came from).
- **Now:** phase and step (for example "DESIGN, Step 03: Craft the TDD"), and what's done within it.
  Build-a-Feature: the row in progress — "F03 Rental Unit Card (Page), stage Built" — and the
  rows completed, packaged (with the version), and reviewed.
- **Exit gate:** what must be true to close this step, and which parts are met — including the
  step's usage rows.
- **Blockers:** a closed step with no usage row (name it: "Step 04 is Completed but has no row in
  the usage table — run `/ocpf-bc:usage --step 04` before anything else"); a `Model:` mismatch
  recorded in the ChangeLog; a missing companion. If nothing, say so.
- **Waiting on you:** approvals, sign-offs, answers, or tests the human owes. If nothing, say so.
- **Next:** the next step once the gate is met.
- **AL MCP Server:** connected, not connected, or deferred, from `alMcp` and whether the session
  has the `al` server's tools. If it isn't connected and BUILD has started or is next, suggest the
  `al-mcp-setup` skill.
- **Help site:** when `docs/site.json` exists (Ops § Help Site), whether `docs/index.html` exists and
  is newer than every source document `site.json`'s `tabs` name and every file in `docs/screenshots/`;
  older or missing is a one-line blocker — *rebuild the help site: `python3 docs/build.py`* — because
  GitHub Pages serves whatever was last pushed.
- **Tooling:** `tooling` from `ocpfFramework/framework.json` — `mermaid` (npx-cached, installed,
  unavailable) and `pwsh` (5.1, 7.x, unavailable); "not checked yet" when the object is empty or
  missing.
- **Models:** the recorded model and effort per role, and whether the project-local
  `.claude/agents/ocpf-*.md` or `.github/agents/ocpf-*.agent.md` definitions exist with a `model:`
  line that matches — Full: reasoning, light, generator; Lite: generator. If they don't, say so:
  delegated steps would be running on the session's model.
- **Notifications:** the kinds recorded in `ocpfFramework/state/notifications.json` (Claude app, sound, desktop
  notification, or none). If the file is missing, say "not set" and offer the `notifications` skill.
- **Usage and cost:** the last refreshed total from `ProjectProgress.md`'s second table (both
  editions) and the date its prices were read; if `ocpfFramework/state/usage.json` is missing, say
  so and offer the `usage` skill.
- **Copilot session settings** (only when Copilot is in use): the request limit and approval mode
  from `ocpfFramework/state/copilot.json`, or "not set".

- **Unanswered box:** when the open step's record shows a question or a step-close that was never
  answered (an intake field blank in `docs/1-define/ProjectParameters.md`, a step with `completedAt`
  whose successor never started), say so: the next thing on resume is that box again (runbook
  Rule 6e).

Then stop. Don't start the next step unless the human asks. When they do, the first message
re-asks whatever is still unanswered through the options box, then proceeds under Rules 6a and 6c.
