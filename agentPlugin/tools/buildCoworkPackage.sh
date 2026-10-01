#!/usr/bin/env bash
# Builds the Microsoft Copilot Cowork package (a Microsoft 365 app package) from the ocpf-bc plugin.
#
# The plugin folder is the single source. This script converts it with Microsoft's Agents Toolkit
# CLI (`atk import openplugin`), adjusts the generated manifest for Cowork, and packages the .zip.
#
# Requires: Node.js, and `npm install -g @microsoft/m365agentstoolkit-cli` (1.1.12 or later).
#
#   agentPlugin/tools/buildCoworkPackage.sh
#
# Output: agentPlugin/dist/ocpf-bc-cowork-<version>.zip (gitignored; attach it to a GitHub release
# or upload it in Cowork: + > Customize > Plugins > Upload plugin).

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
plugin="$repo_root/agentPlugin/ocpf-bc"
dist="$repo_root/agentPlugin/dist"
privacy_url="https://onlycopilotfans.com/privacy-policy"
terms_url="https://onlycopilotfans.com/terms-of-service"

command -v atk >/dev/null || { echo "atk not found: npm install -g @microsoft/m365agentstoolkit-cli" >&2; exit 2; }
command -v node >/dev/null || { echo "node not found" >&2; exit 2; }

"$repo_root/agentPlugin/tools/syncPlugin.sh" --check

version="$(node -p "require('$plugin/.claude-plugin/plugin.json').version")"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

atk import openplugin --path "$plugin" --output "$work/project" \
  --privacy-url "$privacy_url" --terms-url "$terms_url" \
  --website-url "https://github.com/ajansari/ocpfBcAgenticDevFramework"

manifest="$work/project/appPackage/manifest.json"

# Cowork runs in the cloud and supports only remote (HTTPS) MCP connectors, so the AL MCP Server
# setup skill doesn't apply there, it has no hooks or local notifications, so neither does the
# notifications skill, and it has no sub-agents, so neither does the roles skill. Remove all three,
# and give the package a proper display name.
rm -rf "$work/project/appPackage/skills/al-mcp-setup" "$work/project/appPackage/skills/notifications" "$work/project/appPackage/skills/roles"
node - "$manifest" <<'EOF'
const fs = require('fs');
const file = process.argv[2];
const m = JSON.parse(fs.readFileSync(file, 'utf8'));
m.name = { short: 'OCPF BC Agentic Dev', full: 'OCPF BC Agentic Development Framework' };
m.description = {
  short: 'Guided routine for building Business Central AL extensions',
  full: 'The OnlyCopilotFans Business Central Agentic Development Framework. In Copilot Cowork it guides the DEFINE and DESIGN phases (problem statement, gap analysis, parameters, functional and technical design) with the latest Full or Lite runbook, and applies the OCPF AL Development Standards Guide and the shared Operations Guide. Building, compiling, and testing the extension continue in Visual Studio Code.'
};
m.agentSkills = (m.agentSkills || []).filter(s => !s.folder.endsWith('/al-mcp-setup') && !s.folder.endsWith('/notifications') && !s.folder.endsWith('/roles'));
fs.writeFileSync(file, JSON.stringify(m, null, 4) + '\n');
EOF

(cd "$work/project" && atk package --manifest-file ./appPackage/manifest.json \
  --output-package-file ./appPackage/build/appPackage.zip \
  --output-folder ./appPackage/build)

mkdir -p "$dist"
cp "$work/project/appPackage/build/appPackage.zip" "$dist/ocpf-bc-cowork-$version.zip"
echo "built: agentPlugin/dist/ocpf-bc-cowork-$version.zip"
echo "note: icons are atk placeholders unless agentPlugin/ocpf-bc/color.png and outline.png exist."
