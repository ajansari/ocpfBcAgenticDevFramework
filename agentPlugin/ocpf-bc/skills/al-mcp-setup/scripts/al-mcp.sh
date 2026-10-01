#!/bin/sh
# OCPF AL MCP Server launcher for macOS and Linux (from the ocpf-bc plugin's al-mcp-setup skill).
#
# Starts Microsoft's AL MCP Server using tools already on this machine. Nothing is installed.
# Tools are looked up fresh on every launch, so AL Language extension updates never break it.
#   1. The `al` .NET tool (Microsoft.Dynamics.BusinessCentral.Development.Tools), if on PATH.
#   2. The AL Language extension's own altool, run on the .NET runtime that VS Code already
#      provisions for it (or a system .NET with the runtime altool needs).
# Diagnostics go to stderr; stdout carries only the MCP protocol.

set -u

fail() {
  echo "OCPF AL MCP launcher: $*" >&2
  exit 1
}

if command -v al >/dev/null 2>&1 && al --version >/dev/null 2>&1; then
  exec al launchmcpserver --transport stdio "$@"
fi

# Newest AL Language extension across VS Code editions.
altool=""
for extdir in "$HOME/.vscode/extensions" "$HOME/.vscode-insiders/extensions" "$HOME/.vscode-server/extensions"; do
  [ -d "$extdir" ] || continue
  newest="$(ls -d "$extdir"/ms-dynamics-smb.al-* 2>/dev/null | sort -V | tail -n 1)"
  if [ -n "$newest" ] && [ -f "$newest/bin/altool.dll" ]; then
    altool="$newest/bin/altool.dll"
    break
  fi
done
[ -n "$altool" ] || fail "no AL Language extension found. Install 'AL Language extension for Microsoft Dynamics 365 Business Central' in VS Code, or the 'al' .NET tool."

# The .NET major version altool targets, e.g. 10 from "version": "10.0.0".
major="$(sed -n 's/.*"version": *"\([0-9][0-9]*\)\..*/\1/p' "${altool%.dll}.runtimeconfig.json" | head -n 1)"
[ -n "$major" ] || fail "couldn't read the .NET version from ${altool%.dll}.runtimeconfig.json"

dotnet=""
# A system .NET that already has the ASP.NET Core runtime altool needs.
if command -v dotnet >/dev/null 2>&1 && dotnet --list-runtimes 2>/dev/null | grep -q "^Microsoft.AspNetCore.App $major\."; then
  dotnet="$(command -v dotnet)"
fi
# Otherwise the private runtime VS Code's .NET Install Tool provisioned for the AL extension.
if [ -z "$dotnet" ]; then
  for store in \
    "$HOME/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet" \
    "$HOME/Library/Application Support/Code - Insiders/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet" \
    "$HOME/.config/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet" \
    "$HOME/.config/Code - Insiders/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet"; do
    [ -d "$store" ] || continue
    candidate="$(ls -d "$store"/"$major".*aspnetcore 2>/dev/null | sort -V | tail -n 1)"
    if [ -n "$candidate" ] && [ -x "$candidate/dotnet" ]; then
      dotnet="$candidate/dotnet"
      break
    fi
  done
fi
[ -n "$dotnet" ] || fail "no .NET $major runtime found for the AL extension. Open an AL project in VS Code once so the AL extension can provision it."

DOTNET_ROOT="$(dirname "$dotnet")"
export DOTNET_ROOT
exec "$dotnet" "$altool" launchmcpserver --transport stdio "$@"
