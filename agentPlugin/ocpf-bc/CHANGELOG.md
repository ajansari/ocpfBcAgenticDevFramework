# ocpf-bc plugin: Changelog

The plugin is versioned with three-part semantic versions, independently of the runbooks. Each
entry names the framework versions bundled as the offline fallback. The `start` skill always
fetches the latest runbook from GitHub first, so a project isn't limited to the bundled versions.

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
  `.claude-plugin/plugin.json`. The awesome-copilot intake pipeline only recognizes `plugin.json`,
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
