# ocpf-bc plugin: Changelog

The plugin is versioned with three-part semantic versions, independently of the runbooks. Each
entry names the framework versions bundled as the offline fallback. The `start` skill always
fetches the latest runbook from GitHub first, so a project isn't limited to the bundled versions.

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
