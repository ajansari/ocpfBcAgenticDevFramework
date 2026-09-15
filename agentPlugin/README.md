# agentPlugin: maintainer notes

This folder holds the **optional** agent plugin for the framework. Users don't need anything here
to use the framework manually. Install steps for users are in the repository's
[README](../README.md).

| Path | What it is |
|---|---|
| `ocpf-bc/` | The plugin. Two manifests with the same metadata: `.claude-plugin/plugin.json` (Claude Code, Claude apps, VS Code) and `.github/plugin/plugin.json` (GitHub Copilot tooling; awesome-copilot requires one of `plugin.json`, `.github/plugin/plugin.json`, or `.plugin/plugin.json`). Listed in `../.claude-plugin/marketplace.json`. |
| `github/agents/ocpf-code-reviewer.agent.md` | Optional GitHub Copilot custom agent for github.com. Users copy it into their project's `.github/agents/`. |
| `tools/syncPlugin.sh` | Copies the canonical runbooks, changelogs, and Standards Guide into the plugin's bundled references. `--check` reports drift. |
| `tools/buildCoworkPackage.sh` | Builds the Microsoft Copilot Cowork `.zip` into `dist/` (gitignored). |
| `../.github/workflows/plugin-check.yml` | CI: bundled copies in sync, manifests valid, `claude plugin validate` passes. |

## Single source of truth

The runbooks, their changelogs, and the Standards Guide live at the repository root and in
`liteVersion/` and `standardsGuide/`, exactly as before. The plugin only carries **copies**, as an
offline fallback: `start` and the once-per-session update check read the latest from GitHub
first. Never edit files under `ocpf-bc/skills/*/references/` by hand.

## Release checklist

Do this whenever a round of framework changes is ready to push:

1. **Sync:** `agentPlugin/tools/syncPlugin.sh`
2. **Bump the plugin version** in **both** `ocpf-bc/.claude-plugin/plugin.json` and
   `ocpf-bc/.github/plugin/plugin.json` if anything under `ocpf-bc/` changed, including the synced
   copies. `syncPlugin.sh --check` (and CI) fails if the two manifests disagree.
   - Use three-part semver: patch for synced documents or wording, minor for new skills or
     behavior, major for breaking changes.
   - Claude Code and VS Code only deliver an update when this number changes.
   - Set the version only in the two manifests. Don't add `version` to the marketplace entry.
3. **Record it** in `ocpf-bc/CHANGELOG.md`, with the bundled framework versions.
4. **Validate** with the `claude` CLI:
   ```
   claude plugin validate ./agentPlugin/ocpf-bc --strict
   claude plugin validate . --strict
   ```
5. **Push.** The marketplace (this repository) serves the new version immediately.
6. **Tag the release** as `ocpf-bc-v<version>`, e.g. `ocpf-bc-v1.0.0`. awesome-copilot pins to a
   tag.
7. **Cowork package,** when the version changes:
   - Run `agentPlugin/tools/buildCoworkPackage.sh`.
   - Attach `dist/ocpf-bc-cowork-<version>.zip` to the GitHub release.
   - If it's listed in the Microsoft 365 App Store, submit the new version through Partner Center.
8. **Listings:**
   - **Anthropic community marketplace:** nothing to do; its CI picks up pushes.
   - **awesome-copilot:** open a PR bumping the entry in `plugins/external.json` to the new tag,
     SHA, and version.

## Submissions (one-time)

### Anthropic community marketplace (`claude-community`)

- **Form:** <https://platform.claude.com/plugins/submit> (Console; individual authors). The
  claude.ai form needs a Team or Enterprise organization with directory access.
- **Before submitting:** the repository must be public, and `claude plugin validate` must pass.
  Both are true for `ocpf-bc-v1.0.1`.
- **After approval,** the catalog pins a commit SHA, and its CI bumps the pin on each push. The
  public catalog syncs nightly. Check it at
  <https://github.com/anthropics/claude-plugins-community/blob/main/.claude-plugin/marketplace.json>.
  Updates never need a resubmission.

**About the fields below.** The form is behind a Console login, and Anthropic doesn't publish its
field list. These answers cover everything its docs and review guidance ask about. Match each form
field to the closest entry, and add any field that isn't covered here to this section afterwards.

#### Identity

| Field | Value |
|---|---|
| Plugin name | `ocpf-bc` |
| Display name | OCPF BC Agentic Development Framework |
| Version | `1.0.1` |
| Publisher / author | OnlyCopilotFans |
| Contact / support email | aj@onlycopilotfans.com |
| Security contact | aj@onlycopilotfans.com |
| License | MIT |
| Category | Development (or Coding / Engineering, whichever the form offers) |
| Keywords / tags | business-central, dynamics-365, al, erp, agentic-development, bcquality |

#### Links

| Field | Value |
|---|---|
| GitHub repository | `https://github.com/ajansari/ocpfBcAgenticDevFramework` |
| Plugin path in the repository | `agentPlugin/ocpf-bc` |
| Marketplace file | `.claude-plugin/marketplace.json` (marketplace `onlycopilotfans`) |
| Release tag / commit | `ocpf-bc-v1.0.1` / the SHA the tag points at |
| Homepage / documentation | `https://github.com/ajansari/ocpfBcAgenticDevFramework#setup-plugin` |
| Support / issues | `https://github.com/ajansari/ocpfBcAgenticDevFramework/issues` |
| Privacy policy | `https://onlycopilotfans.com/privacy-policy` |
| Terms of service | `https://onlycopilotfans.com/terms-of-service` |
| Overview (slides) | `https://ajansari.github.io/ocpfBcAgenticDevFramework/` |

#### Descriptions

**Short description / tagline** (100 characters):
> Build Business Central AL extensions the right way, with a guided DEFINE-DESIGN-BUILD-PROVE routine.

**Long description:**
> The OnlyCopilotFans Business Central Agentic Development Framework turns Claude into a disciplined
> Business Central AL developer. It's simple enough for functional consultants and robust enough for
> pro developers. Run `/ocpf-bc:start` in an AL project and the plugin helps you choose the Full
> (14-step) or Lite (7-step) routine, installs the latest runbook from GitHub, and connects
> Microsoft's AL tools using the AL Language extension you already have, with nothing to install.
> The routine takes a business problem through DEFINE (problem statement, gap analysis, project
> parameters), DESIGN (functional and technical design, sanity check), BUILD (batched AL generation
> with symbol-verified pre-flight checks, compile, package, test), and PROVE (gap-fit, code review,
> documentation, and release testing), with human approval at every key decision. It applies the
> OCPF AL Development Standards Guide, BCQuality, and Microsoft's AL Guidelines, and supports
> multilanguage extensions through XLIFF translations with a named human reviewer. Each session, it
> checks for a newer runbook and asks before applying it.

#### What it does and who it's for

| Question | Answer |
|---|---|
| Job the plugin completes | Guides building a Microsoft Dynamics 365 Business Central AL per-tenant extension end to end, from a business problem to a tested, documented app, following a proven routine and AL standards. |
| Intended users | Business Central functional consultants, and AL developers, building per-tenant extensions. |
| Primary workflow | Open an AL project folder, run `/ocpf-bc:start`, choose Full or Lite, approve the AL tools connection, then follow the routine step by step. Resume later with `/ocpf-bc:status`. |
| Where it works | **Full routine:** Claude Code (CLI, VS Code, Desktop). **DEFINE and DESIGN phases only:** Claude Chat and Cowork (skills). |

**Example prompts:**
- `/ocpf-bc:start`, or "Start a Business Central extension project with the OCPF framework"
- `/ocpf-bc:start lite`
- `/ocpf-bc:status`, or "Where are we on this project?"
- "Check this AL file against the OCPF standards"
- `/ocpf-bc:update-framework`, or "Is there a newer version of the framework?"

#### Components

| Component | Included |
|---|---|
| Skills (6) | `start`, `status`, `update-framework`, `al-standards`, `al-mcp-setup`, `notifications` |
| Sub-agents (2) | `ocpf-reasoning` (design drafting, reviews, diagnosis) and `ocpf-light` (checklist and symbol verification). Both are denied file-editing tools. |
| Hooks | None |
| MCP servers | None bundled |
| Commands | None (skills are invoked as `/ocpf-bc:<skill>`) |
| Scripts | `al-mcp-setup/scripts/`: `al-mcp.sh`, `al-mcp.cmd`, `al-mcp-resolve.ps1` (start Microsoft's AL MCP Server), `al-mcp-call.sh`, `al-mcp-call.ps1` (run one AL MCP Server tool), and `al-analyze.sh`, `al-analyze.cmd`, `al-analyze-resolve.ps1` (compile with Microsoft's code analyzers); `notifications/scripts/`: `ocpf-notify.sh`, `ocpf-notify.ps1` (show a desktop notification with the operating system's own tools). They're copied into the user's project, through the AI tool's own permission prompts, and use the locally installed AL Language extension. They install nothing. |

#### External services, data, and permissions

| Question | Answer |
|---|---|
| External services / MCP connections | No remote MCP servers. Locally, `al-mcp-setup` registers Microsoft's AL MCP Server from the user's own AL Language extension, in the project's `.mcp.json`, after the user approves. |
| Network access | Reads public files from GitHub (`raw.githubusercontent.com`, `api.github.com`): the runbooks, the Standards Guide, BCQuality, and the OCPF patterns library. Reads Microsoft Learn and AL Guidelines documentation. Microsoft's AL tools download Business Central symbols from Microsoft's public symbol feed (`pkgs.dev.azure.com/dynamicssmb2`) and AppSource with no sign-in, and reach the user's own Business Central environment only when the user signs in to publish or download symbols from it. |
| Data collection | None. No telemetry or analytics; nothing is sent to the publisher. |
| Files it writes | Only in the user's project, and only as the routine describes: `CLAUDE.md` and/or `.github/copilot-instructions.md`, the runbook changelog, `.ocpf/framework.json`, the project's design documents, AL code, and, after approval, `scripts/`, an `al` entry in `.mcp.json`, and notification settings (`.claude/settings.local.json`, `.vscode/settings.json`). One file outside the project, with approval: `~/.copilot/hooks/ocpf-notify.json` for GitHub Copilot CLI users. It never overwrites an existing `CLAUDE.md` or Copilot instructions file. |
| Setup and permissions | Nothing to configure at install. For BUILD and PROVE: VS Code with Microsoft's AL Language extension, which AL developers already have. Claude Code asks the user to approve file edits, commands, and the project MCP server as usual. |
| Installs software? | No. It never installs runtimes or tools, and never asks users to edit `PATH` or shell profiles. |

#### Assets

| Asset | Status |
|---|---|
| Logo / icon | **Not ready.** The repository has only a 1080×603 banner (`images/ocpfBCAgenticDevFrameworkBanner.png`). If the form asks for a square icon, create one first (for example 512×512 PNG). |
| Screenshots | None yet. If requested, capture `/ocpf-bc:start` asking Full or Lite, and the project status report. |

### GitHub awesome-copilot

Submit through the **external plugin issue form** in <https://github.com/github/awesome-copilot>.
Don't open a PR that edits `plugins/external.json` directly.

| Field | Value |
|---|---|
| Plugin name | `ocpf-bc` |
| Short description | Guided DEFINE, DESIGN, BUILD, PROVE routine for Business Central AL extensions: Full or Lite runbook, zero-install AL tools, reasoning and light sub-agents. |
| GitHub repository | `ajansari/ocpfBcAgenticDevFramework` |
| Plugin path | `agentPlugin/ocpf-bc` |
| Ref | `ocpf-bc-v1.0.1` (the tag) |
| Commit SHA | the full 40-character SHA the tag points at (`git rev-parse ocpf-bc-v1.0.1^{commit}`) |
| Plugin version | `1.0.1` |
| License | `MIT` |
| Author name / URL | OnlyCopilotFans / `https://github.com/ajansari` |
| Homepage | `https://github.com/ajansari/ocpfBcAgenticDevFramework` |
| Keywords | `business-central`, `dynamics-365`, `al`, `erp`, `agentic-development` |

Automation runs `vally lint` and a Copilot CLI install smoke test before a maintainer reviews it.

### Microsoft 365 App Store (Copilot Cowork), optional

Needs a Partner Center account. Submit `dist/ocpf-bc-cowork-<version>.zip`. Before a store
submission:
- **Icons:** replace the placeholders by adding `color.png` (192×192) and `outline.png` (32×32) to
  `ocpf-bc/`, then rebuild.
- **Legal URLs:** the package uses <https://onlycopilotfans.com/privacy-policy> and <https://onlycopilotfans.com/terms-of-service>. Both are required by the Microsoft 365 app manifest; confirm they're still live.
- **Schema:** check whether the channel needs manifest schema v1.28 instead of the `devPreview`
  schema that `atk import openplugin` generates.
