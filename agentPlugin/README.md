# agentPlugin: maintainer notes

This folder holds the **optional** agent plugin for the framework. Users don't need anything here
to use the framework manually. Install steps for users are in the repository's
[README](../README.md).

| Path | What it is |
|---|---|
| `ocpf-bc/` | The plugin. Two manifests with the same metadata: `.claude-plugin/plugin.json` (Claude Code, Claude apps, VS Code) and `.github/plugin/plugin.json` (GitHub Copilot tooling, which looks for `plugin.json`, `.github/plugin/plugin.json`, or `.plugin/plugin.json`). |
| `github/agents/ocpf-code-reviewer.agent.md` | Optional GitHub Copilot custom agent for github.com. Users copy it into their project's `.github/agents/`. |
| `tools/syncPlugin.sh` | Copies the canonical runbooks, their changelogs, the step files, the document templates, and the Operations Guide into the plugin's bundled references, fetches the Standards Guide at the pinned tag (`STANDARDS_TAG`), rebuilds the runbook stubs, and checks the two manifests agree. `--check` reports drift. Run it twice when the stubs change: the first run rebuilds them, the second copies the rebuilt cores. |
| `tools/buildStubs.py` | Rebuilds each core runbook's per-step stubs (Role, Outputs, Exit gate) from the step files; `--check` verifies. Called by `syncPlugin.sh`. |
| `../.github/workflows/plugin-check.yml` | CI: bundled copies in sync, manifests valid, `claude plugin validate` passes. |

## Single source of truth

The runbooks, their step files, and their changelogs live in `fullVersion/` and `liteVersion/`,
the Operations Guide in `opsGuide/`, the document templates in `documentTemplates/`, and the
Standards Guide in its own repository, `ajansari/ocpfBCALStandards`, at the tag
`standardsGuide/README.md` pins. The plugin only carries **copies**, as an offline fallback:
`start` and the once-per-session update check read the latest from GitHub first. Never edit files
under `ocpf-bc/skills/*/references/` or `ocpf-bc/skills/documents/references/` by hand.

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
3. **Record it** in `ocpf-bc/CHANGELOG.md`, with the bundled framework versions — and in
   `fullVersion/RunbookChangelog.md`, `liteVersion/LITE_RunbookChangeLog.md`, and the README's
   *What's New* when the framework changed too; Full, Lite, the Operations Guide, and the plugin
   share one version number since 5.0.0.0.
4. **Validate** with the `claude` CLI:
   ```
   claude plugin validate ./agentPlugin/ocpf-bc --strict
   claude plugin validate . --strict
   ```
5. **Push.** The marketplace (this repository) serves the new version immediately.
6. **Tag the release** as `ocpf-bc-v<version>`, e.g. `ocpf-bc-v1.0.0`.
7. **Listings:** none. The plugin is distributed only from this repository, which is its own
   marketplace for Claude Code and GitHub Copilot; there is no catalog entry to update.

## Submissions

None. The plugin is not listed in any third-party catalog or store; users add this repository as a
marketplace (README → GET STARTED: Agent Plugin).
