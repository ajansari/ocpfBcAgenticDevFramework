#!/bin/sh
# OCPF analyzer-enabled compile for macOS and Linux (from the ocpf-bc plugin's al-mcp-setup skill).
#
# Compiles the project with Microsoft's bundled code analyzers actually engaged, using tools
# already on this machine. Nothing is installed.
#
# Verified necessary (AL Language extension 18.0.2732683, September 2026): the AL MCP Server's
# own al_build/al_compile tools do not apply their codeAnalyzers argument or the server's
# --codeanalyzers launch flag — six different attempts (symbolic names, literal DLL paths, both
# as a tool-call argument and as a server launch flag) produced zero analyzer diagnostics for
# code that should fail. Invoking the compiler directly, as this script does, reliably engages
# the analyzers: confirmed catching PTE0004 (missing permission set) and PTE0008 (missing
# ApplicationArea) with PerTenantExtensionCop, and AA0074 (label suffix) with CodeCop. Re-verify
# against a newer AL extension release before assuming the MCP tool argument still doesn't work.
#
# Usage: sh al-analyze.sh <project folder> <output .app path> [pte|appsource] [extra alc args...]
#   sh scripts/al-analyze.sh . outputAppPackage/MyApp_1.0.0.0.app
#   sh scripts/al-analyze.sh . outputAppPackage/MyApp_1.0.0.0.app appsource
#
# Profile picks the analyzer set — pass whichever matches Deployment Target (Parameter 1.1):
#   pte       (default) CodeCop, PerTenantExtensionCop, UICop — SaaS PTE or OnPrem PTE.
#   appsource CodeCop, AppSourceCop, UICop — Deployment Target = AppSource.
# Never both PerTenantExtensionCop and AppSourceCop in the same compile: Microsoft's own docs say
# "several rules enforced by the AppSourceCop analyzer are incompatible with rules enforced by the
# PerTenantExtensionCop. Make sure to enable only one of these at a time." Confirmed in practice:
# loading both on a plain PTE-shaped project buried it in AppSource-only errors unrelated to the
# actual code (missing app.json fields, wrong ID range, no AppSourceCop.json).
#
# The appsource profile also needs an AppSourceCop.json in the project root (mandatoryAffixes at
# minimum) or the compile fails outright with AS0054 — this script doesn't create one; the runbook
# does that separately when Deployment Target is AppSource.
#
# Prints the compiler's own diagnostics (errors and warnings) to stdout/stderr and exits with the
# compiler's exit code: 0 only when the compile is clean under every analyzer passed. This is the
# framework's actual "compile to 0 errors, 0 warnings" step, not a side check — run it in place of
# a plain al_build/al_compile call for Operating Rule 4's mandatory compile-and-package.

set -u

fail() {
  echo "OCPF AL analyze: $*" >&2
  exit 1
}

[ $# -ge 2 ] || fail "usage: al-analyze.sh <project folder> <output .app path> [pte|appsource] [extra alc args...]"
project="$1"; shift
outfile="$1"; shift
profile="pte"
case "${1:-}" in
  pte|appsource) profile="$1"; shift ;;
esac
# Everything left in "$@" from here on is the caller's own extra alc arguments — never touched by
# the profile selection below, so paths containing spaces still pass through safely.

# Locate altool.dll (or the global al tool) and the analyzer DLLs that ship beside it — same
# directory either way, whether that's the AL extension's bin/ folder or the global tool's own
# store folder. Prefer the global `al` tool if it works, matching al-mcp.sh's own precedence.
altool=""
if command -v al >/dev/null 2>&1 && al --version >/dev/null 2>&1; then
  # The global tool is a native apphost; its DLLs live in the NuGet tool-store layout beside it.
  store="$HOME/.dotnet/tools/.store/microsoft.dynamics.businesscentral.development.tools"
  newest="$(ls -d "$store"/*/*/tools/net*/any/altool.dll 2>/dev/null | sort -V | tail -n 1)"
  [ -n "$newest" ] && altool="$newest"
fi
if [ -z "$altool" ]; then
  for extdir in "$HOME/.vscode/extensions" "$HOME/.vscode-insiders/extensions" "$HOME/.vscode-server/extensions"; do
    [ -d "$extdir" ] || continue
    newest="$(ls -d "$extdir"/ms-dynamics-smb.al-* 2>/dev/null | sort -V | tail -n 1)"
    if [ -n "$newest" ] && [ -f "$newest/bin/altool.dll" ]; then
      altool="$newest/bin/altool.dll"
      break
    fi
  done
fi
[ -n "$altool" ] || fail "no AL Language extension found. Install 'AL Language extension for Microsoft Dynamics 365 Business Central' in VS Code, or the 'al' .NET tool."

bindir="$(dirname "$altool")"
codecop="$bindir/Microsoft.Dynamics.Nav.CodeCop.dll"
uicop="$bindir/Microsoft.Dynamics.Nav.UICop.dll"
ptecop="$bindir/Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll"
appsourcecop="$bindir/Microsoft.Dynamics.Nav.AppSourceCop.dll"
for dll in "$codecop" "$uicop"; do
  [ -f "$dll" ] || fail "expected analyzer not found next to altool: $dll (AL extension layout may have changed — check bin/ for the current analyzer DLL names)"
done

# The .NET major version altool targets, e.g. 10 from "version": "10.0.0".
major="$(sed -n 's/.*"version": *"\([0-9][0-9]*\)\..*/\1/p' "${altool%.dll}.runtimeconfig.json" | head -n 1)"
[ -n "$major" ] || fail "couldn't read the .NET version from ${altool%.dll}.runtimeconfig.json"

dotnet=""
if command -v dotnet >/dev/null 2>&1 && dotnet --list-runtimes 2>/dev/null | grep -q "^Microsoft.AspNetCore.App $major\."; then
  dotnet="$(command -v dotnet)"
fi
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
if [ "$profile" = "appsource" ]; then
  [ -f "$appsourcecop" ] || fail "expected analyzer not found next to altool: $appsourcecop"
  exec "$dotnet" "$altool" compile -- \
    /project:"$project" /packagecachepath:"$project/.alpackages" /out:"$outfile" \
    /analyzer:"$codecop" /analyzer:"$appsourcecop" /analyzer:"$uicop" "$@"
else
  [ -f "$ptecop" ] || fail "expected analyzer not found next to altool: $ptecop"
  exec "$dotnet" "$altool" compile -- \
    /project:"$project" /packagecachepath:"$project/.alpackages" /out:"$outfile" \
    /analyzer:"$codecop" /analyzer:"$ptecop" /analyzer:"$uicop" "$@"
fi
