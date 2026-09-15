# agentPlugin: maintainer notes

This folder holds the **optional** agent plugin for the framework. Users don't need anything here
to use the framework manually. Install steps for users are in the repository's
[README](../README.md).

| Path | What it is |
|---|---|
| `ocpf-bc/` | The plugin: Claude Code plugin format, also read by GitHub Copilot and Copilot CLI. Listed in `../.claude-plugin/marketplace.json`. |
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
2. **Bump the plugin version** in `ocpf-bc/.claude-plugin/plugin.json` if anything under
   `ocpf-bc/` changed, including the synced copies.
   - Use three-part semver: patch for synced documents or wording, minor for new skills or
     behavior, major for breaking changes.
   - Claude Code and VS Code only deliver an update when this number changes.
   - Set the version only there. Don't add `version` to the marketplace entry.
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
- **What to submit:**
  - the GitHub link to the repository,
  - the plugin `ocpf-bc` at `agentPlugin/ocpf-bc`,
  - the marketplace file `.claude-plugin/marketplace.json`.
- **After approval,** the catalog pins a commit SHA, and its CI bumps the pin on each push. The
  public catalog syncs nightly. Check it at
  <https://github.com/anthropics/claude-plugins-community/blob/main/.claude-plugin/marketplace.json>.

### GitHub awesome-copilot

Submit through the **external plugin issue form** in <https://github.com/github/awesome-copilot>.
Don't open a PR that edits `plugins/external.json` directly.

| Field | Value |
|---|---|
| Plugin name | `ocpf-bc` |
| Short description | Guided DEFINE, DESIGN, BUILD, PROVE routine for Business Central AL extensions: Full or Lite runbook, zero-install AL tools, reasoning and light sub-agents. |
| GitHub repository | `ajansari/ocpfBcAgenticDevFramework` |
| Plugin path | `agentPlugin/ocpf-bc` |
| Ref | `ocpf-bc-v1.0.0` (the tag) |
| Commit SHA | the full 40-character SHA the tag points at |
| Plugin version | `1.0.0` |
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
