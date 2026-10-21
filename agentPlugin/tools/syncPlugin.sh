#!/usr/bin/env bash
# Copies the framework's canonical documents into the ocpf-bc plugin's bundled references.
#
# The runbooks and the Operations Guide at the repository root are the single source of truth; the
# Standards Guide's is the standalone repository ajansari/ocpfBCALStandards at the pinned tag below.
# The plugin carries copies only as an offline fallback: the start skill fetches from GitHub first.
# Run this before every push that changes a runbook, a changelog, the Operations Guide, or the pin.
#
#   agentPlugin/tools/syncPlugin.sh           copy the canonical files into the plugin
#   agentPlugin/tools/syncPlugin.sh --check   report drift and exit 1 if any copy is stale (CI)

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
plugin="$repo_root/agentPlugin/ocpf-bc"

# The Standards Guide is standalone (github.com/ajansari/ocpfBCALStandards) since Full/Lite 5.2.0.0.
# The plugin bundles the release the framework pins, fetched here by tag — never from main. Keep this
# tag equal to the pin named in standardsGuide/README.md. If the tag isn't reachable (offline, or not
# pushed yet) and the sibling checkout exists, its working copy is used and a warning is printed.
STANDARDS_REPO="ajansari/ocpfBCALStandards"
STANDARDS_TAG="v1.13.1.0"
STANDARDS_FILE="ocpfALDevStandardsGuide.md"
standards_dst="$plugin/skills/al-standards/references/$STANDARDS_FILE"
standards_sibling="$repo_root/../ocpfBCALStandards/$STANDARDS_FILE"

# canonical source (relative to repo root) -> bundled copy (relative to plugin root)
pairs=(
  "fullVersion/BC_App_Build_Routine_Agent.md|skills/start/references/BC_App_Build_Routine_Agent.md"
  "fullVersion/RunbookChangelog.md|skills/start/references/RunbookChangelog.md"
  "liteVersion/LITE_BC_App_Build_Routine_Agent.md|skills/start/references/LITE_BC_App_Build_Routine_Agent.md"
  "liteVersion/LITE_RunbookChangeLog.md|skills/start/references/LITE_RunbookChangeLog.md"
  "opsGuide/ocpfOperationsGuide.md|skills/start/references/ocpfOperationsGuide.md"
)

# canonical folder -> bundled folder (every *.md inside is copied; stale extras are removed)
dirs=(
  "fullVersion/steps|skills/start/references/steps/full"
  "liteVersion/steps|skills/start/references/steps/lite"
  "documentTemplates|skills/documents/references"
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

for pair in "${dirs[@]}"; do
  srcdir="$repo_root/${pair%%|*}"
  dstdir="$plugin/${pair##*|}"
  if [[ ! -d "$srcdir" ]]; then
    echo "missing canonical folder: ${pair%%|*}" >&2
    exit 2
  fi
  mkdir -p "$dstdir"
  for src in "$srcdir"/*.md; do
    dst="$dstdir/$(basename "$src")"
    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
      continue
    fi
    if [[ "$mode" == "check" ]]; then
      echo "STALE: ${pair##*|}/$(basename "$src") differs from ${pair%%|*}" >&2
      stale=1
    else
      cp "$src" "$dst"
      echo "copied: ${pair%%|*}/$(basename "$src") -> ${pair##*|}/"
    fi
  done
  for dst in "$dstdir"/*.md; do
    [[ -f "$dst" ]] || continue
    if [[ ! -f "$srcdir/$(basename "$dst")" ]]; then
      if [[ "$mode" == "check" ]]; then
        echo "STALE: ${pair##*|}/$(basename "$dst") has no canonical file" >&2
        stale=1
      else
        rm "$dst"
        echo "removed: ${pair##*|}/$(basename "$dst")"
      fi
    fi
  done
  if [[ "$mode" == "check" && "$stale" -ne 0 ]]; then
    echo "folder checked: ${pair##*|}"
  else
    echo "folder in sync: ${pair##*|}"
  fi
done

# Bundled Standards Guide: fetch the pinned tag (or fall back to the sibling checkout).
tmp_std="$(mktemp)"
if curl -fsSL "https://raw.githubusercontent.com/$STANDARDS_REPO/$STANDARDS_TAG/$STANDARDS_FILE" -o "$tmp_std" 2>/dev/null; then
  std_src="$tmp_std"; std_from="$STANDARDS_REPO@$STANDARDS_TAG"
elif [[ -f "$standards_sibling" ]]; then
  std_src="$standards_sibling"; std_from="sibling checkout (tag $STANDARDS_TAG not reachable — push and tag it)"
  echo "WARNING: using $standards_sibling; $STANDARDS_REPO@$STANDARDS_TAG could not be fetched" >&2
else
  echo "cannot fetch $STANDARDS_REPO@$STANDARDS_TAG and no sibling checkout at $standards_sibling" >&2
  rm -f "$tmp_std"; exit 2
fi
if [[ -f "$standards_dst" ]] && cmp -s "$std_src" "$standards_dst"; then
  echo "up to date: skills/al-standards/references/$STANDARDS_FILE ($std_from)"
elif [[ "$mode" == "check" ]]; then
  echo "STALE: skills/al-standards/references/$STANDARDS_FILE differs from $std_from" >&2; stale=1
else
  mkdir -p "$(dirname "$standards_dst")"; cp "$std_src" "$standards_dst"
  echo "copied: $std_from -> skills/al-standards/references/$STANDARDS_FILE"
fi
rm -f "$tmp_std"
std_ver="$(sed -n 's/^\*\*Version:\*\* *\([0-9.]*\).*/\1/p' "$standards_dst" | head -1)"
if [[ "v$std_ver" != "$STANDARDS_TAG" ]]; then
  echo "WARNING: bundled Standards Guide says version $std_ver but STANDARDS_TAG is $STANDARDS_TAG" >&2
fi

# The step stubs in the two core runbooks must carry their step files' Role / Outputs / Exit gate
# paragraphs verbatim (agentPlugin/tools/buildStubs.py rebuilds them; --check verifies).
if ! python3 "$repo_root/agentPlugin/tools/buildStubs.py" --check; then
  if [[ "$mode" == "check" ]]; then stale=1; else python3 "$repo_root/agentPlugin/tools/buildStubs.py"; fi
fi

version="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$plugin/.claude-plugin/plugin.json" | head -1)"
echo "plugin version: $version"

# The plugin ships two manifests: .claude-plugin/plugin.json (Claude Code, Claude apps, VS Code) and
# .github/plugin/plugin.json (GitHub Copilot tooling). Their
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

# The website's hero strip (index.html) names the released plugin version. A release that leaves it
# behind ships a stale site, which happened at 5.9.2; so the strip must carry the current version.
if ! grep -q "v${version} ·" "$repo_root/index.html"; then
  echo "index.html hero strip does not name v${version}: update the site's version strip before releasing." >&2
  if [[ "$mode" == "check" ]]; then stale=1; else exit 1; fi
else
  echo "site hero strip: v${version}"
fi

if [[ "$mode" == "check" && "$stale" -ne 0 ]]; then
  echo "Bundled copies are stale. Run agentPlugin/tools/syncPlugin.sh, bump the plugin version, and commit." >&2
  exit 1
fi
