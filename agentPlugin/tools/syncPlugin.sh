#!/usr/bin/env bash
# Copies the framework's canonical documents into the ocpf-bc plugin's bundled references.
#
# The runbooks and Standards Guide at the repository root are the single source of truth. The
# plugin carries copies only as an offline fallback: the start skill fetches the latest from
# GitHub first. Run this before every push that changes a runbook, a changelog, or the
# Standards Guide.
#
#   agentPlugin/tools/syncPlugin.sh           copy the canonical files into the plugin
#   agentPlugin/tools/syncPlugin.sh --check   report drift and exit 1 if any copy is stale (CI)

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
plugin="$repo_root/agentPlugin/ocpf-bc"

# canonical source (relative to repo root) -> bundled copy (relative to plugin root)
pairs=(
  "fullVersion/BC_App_Build_Routine_Agent.md|skills/start/references/BC_App_Build_Routine_Agent.md"
  "fullVersion/RunbookChangelog.md|skills/start/references/RunbookChangelog.md"
  "liteVersion/LITE_BC_App_Build_Routine_Agent.md|skills/start/references/LITE_BC_App_Build_Routine_Agent.md"
  "liteVersion/LITE_RunbookChangeLog.md|skills/start/references/LITE_RunbookChangeLog.md"
  "standardsGuide/ocpfALDevStandardsGuide.md|skills/al-standards/references/ocpfALDevStandardsGuide.md"
  "opsGuide/ocpfOperationsGuide.md|skills/start/references/ocpfOperationsGuide.md"
)

mode="sync"
if [[ "${1:-}" == "--check" ]]; then
  mode="check"
fi

stale=0
for pair in "${pairs[@]}"; do
  src="$repo_root/${pair%%|*}"
  dst="$plugin/${pair##*|}"
  if [[ ! -f "$src" ]]; then
    echo "missing canonical file: ${pair%%|*}" >&2
    exit 2
  fi
  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    echo "up to date: ${pair##*|}"
    continue
  fi
  if [[ "$mode" == "check" ]]; then
    echo "STALE: ${pair##*|} differs from ${pair%%|*}" >&2
    stale=1
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "copied: ${pair%%|*} -> ${pair##*|}"
  fi
done

version="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$plugin/.claude-plugin/plugin.json" | head -1)"
echo "plugin version: $version"

# The plugin ships two manifests: .claude-plugin/plugin.json (Claude Code, Claude apps, VS Code) and
# .github/plugin/plugin.json (GitHub Copilot tooling and the awesome-copilot marketplace). Their
# shared metadata must match.
manifest_drift="$(python3 - "$plugin" <<'PY'
import json, sys
root = sys.argv[1]
claude = json.load(open(f"{root}/.claude-plugin/plugin.json"))
copilot = json.load(open(f"{root}/.github/plugin/plugin.json"))
for key in ["name", "description", "version", "author", "homepage", "repository", "license", "keywords"]:
    if claude.get(key) != copilot.get(key):
        print(f"{key}: .claude-plugin={claude.get(key)!r} .github/plugin={copilot.get(key)!r}")
PY
)"
if [[ -n "$manifest_drift" ]]; then
  echo "Manifest mismatch between .claude-plugin/plugin.json and .github/plugin/plugin.json:" >&2
  echo "$manifest_drift" >&2
  exit 1
fi
echo "manifests agree"

if [[ "$mode" == "check" && "$stale" -ne 0 ]]; then
  echo "Bundled copies are stale. Run agentPlugin/tools/syncPlugin.sh, bump the plugin version, and commit." >&2
  exit 1
fi
