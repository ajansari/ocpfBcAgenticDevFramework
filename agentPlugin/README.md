# agentPlugin: maintainer notes

This folder holds the **optional** agent plugin for the framework. Users don't need anything here
to use the framework manually. Install steps for users are in the repository's
[README](../README.md).

| Path | What it is |
|---|---|
| `ocpf-bc/` | The plugin. Two manifests with the same metadata: `.claude-plugin/plugin.json` (Claude Code, Claude apps, VS Code) and `.github/plugin/plugin.json` (GitHub Copilot tooling, which looks for `plugin.json`, `.github/plugin/plugin.json`, or `.plugin/plugin.json`). |
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
6. **Tag the release** as `ocpf-bc-v<version>`, e.g. `ocpf-bc-v1.0.0`.
7. **Cowork package,** when the version changes:
   - Run `agentPlugin/tools/buildCoworkPackage.sh`.
   - Attach `dist/ocpf-bc-cowork-<version>.zip` to the GitHub release.
   - If it's listed in the Microsoft 365 App Store, submit the new version through Partner Center.
8. **Listings:** none. The plugin is distributed only from this repository, which is its own
   marketplace for Claude Code and GitHub Copilot; there is no catalog entry to update.

## Submissions (one-time)

The plugin is not listed in any third-party catalog; users add this repository as a marketplace
(README → GET STARTED: Agent Plugin). The one optional store is below.

### Microsoft 365 App Store (Copilot Cowork), optional

Needs a Partner Center account. Submit `dist/ocpf-bc-cowork-<version>.zip`. Before a store
submission:
- **Icons:** replace the placeholders by adding `color.png` (192×192) and `outline.png` (32×32) to
  `ocpf-bc/`, then rebuild.
- **Legal URLs:** the package uses <https://onlycopilotfans.com/privacy-policy> and <https://onlycopilotfans.com/terms-of-service>. Both are required by the Microsoft 365 app manifest; confirm they're still live.
- **Schema:** check whether the channel needs manifest schema v1.28 instead of the `devPreview`
  schema that `atk import openplugin` generates.
