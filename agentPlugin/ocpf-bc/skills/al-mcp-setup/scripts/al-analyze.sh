#!/bin/sh
# OCPF analyzer-enabled compile for macOS and Linux (from the ocpf-bc plugin's al-mcp-setup skill).
#
# Compiles the project with Microsoft's bundled code analyzers actually engaged, using tools
# already on this machine. Nothing is installed.
#
# Why not the AL MCP Server's al_build/al_compile (AL Language extension 18.0.2732683; see the
# runbook's ALL ALONG → Analyzers and Ops § Analyzers). Re-verify against newer releases.
#   al_build   never applies analyzers, whatever is passed, and reports succeeded:true while
#              packaging code that has analyzer errors.
#   al_compile applies them only when enableCodeAnalysis:true AND a codeAnalyzers list of the
#              ${CodeCop} / ${PerTenantExtensionCop} / ${UICop} / ${AppSourceCop} tokens are both
#              passed at the top level of "options" — not under a "parameters" key (that wrapper is
#              al_symbolsearch's alone) and not as literal DLL paths (those return AD0001). Every
#              other shape returns a clean pass on failing code. It also writes no .app, so it can
#              be a fast pre-check but never the compile-and-package.
#
# Usage: sh al-analyze.sh <project folder> <output .app path> [pte|appsource] [extra alc args...]
#   sh scripts/al-analyze.sh . outputAppPackage/MyApp_1.0.0.0.app
#   sh scripts/al-analyze.sh . outputAppPackage/MyApp_1.0.0.0.app appsource
#
# Profile picks the analyzer set — pass whichever matches Deployment Target:
#   pte       (default) CodeCop, PerTenantExtensionCop, UICop — SaaS PTE or OnPrem PTE.
#   appsource CodeCop, AppSourceCop, UICop — Deployment Target = AppSource.
# Never both PerTenantExtensionCop and AppSourceCop in the same compile: Microsoft documents their
# rules as incompatible ("enable only one of these at a time").
#
# The appsource profile also needs an AppSourceCop.json in the project root (mandatoryAffixes at
# minimum) or the compile fails outright with AS0054 — this script doesn't create one; the runbook
# does that separately when Deployment Target is AppSource.
#
# Prints the compiler's own diagnostics, then a one-line summary. Exit codes:
#   0  compiled with no errors and no warnings under every analyzer passed (Operating Rule 5);
#   1  the compile failed, or the tools couldn't be found;
#   3  compiled, but with warnings. The compiler itself exits 0 on warnings, so this script counts
#      them: a warning still fails the framework's zero-warnings gate.
# Run it in place of a plain al_build/al_compile call for Operating Rule 4's mandatory
# compile-and-package.

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

# Find a .NET runtime (full path to dotnet) that has the ASP.NET Core runtime for a .NET major
# version: a system dotnet first, then the private runtime VS Code's .NET Install Tool provisioned.
find_dotnet() {
  if command -v dotnet >/dev/null 2>&1 && dotnet --list-runtimes 2>/dev/null | grep -q "^Microsoft.AspNetCore.App $1\."; then
    command -v dotnet
    return 0
  fi
  for rtstore in \
    "$HOME/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet" \
    "$HOME/Library/Application Support/Code - Insiders/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet" \
    "$HOME/.config/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet" \
    "$HOME/.config/Code - Insiders/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet"; do
    [ -d "$rtstore" ] || continue
    candidate="$(ls -d "$rtstore"/"$1".*aspnetcore 2>/dev/null | sort -V | tail -n 1)"
    if [ -n "$candidate" ] && [ -x "$candidate/dotnet" ]; then
      echo "$candidate/dotnet"
      return 0
    fi
  done
  return 1
}

# Candidate altool.dll files, best first. The analyzer DLLs ship in the same folder as each one.
#   1. The global `al` .NET tool, if it works (matching al-mcp.sh's precedence). Its tool store is
#      <version>/<package id>/<version>/tools/<net TFM>/any/ — newest version, newest TFM first.
#   2. The newest AL Language extension's bin/ folder, across VS Code editions.
candidates=""
if command -v al >/dev/null 2>&1 && al --version >/dev/null 2>&1; then
  toolstore="$HOME/.dotnet/tools/.store/microsoft.dynamics.businesscentral.development.tools"
  candidates="$(ls -d "$toolstore"/*/*/*/tools/net*/any/altool.dll 2>/dev/null | sort -V -r)"
fi
for extdir in "$HOME/.vscode/extensions" "$HOME/.vscode-insiders/extensions" "$HOME/.vscode-server/extensions"; do
  [ -d "$extdir" ] || continue
  newest="$(ls -d "$extdir"/ms-dynamics-smb.al-* 2>/dev/null | sort -V | tail -n 1)"
  if [ -n "$newest" ] && [ -f "$newest/bin/altool.dll" ]; then
    candidates="$candidates
$newest/bin/altool.dll"
    break
  fi
done
[ -n "$(echo "$candidates" | tr -d '[:space:]')" ] || fail "no AL Language extension found. Install 'AL Language extension for Microsoft Dynamics 365 Business Central' in VS Code, or the 'al' .NET tool."

# Use the first candidate that has its analyzers and a runtime it can run on.
altool=""; dotnet=""; missing=""
while IFS= read -r cand; do
  [ -n "$cand" ] || continue
  cbin="$(dirname "$cand")"
  [ -f "$cbin/Microsoft.Dynamics.Nav.CodeCop.dll" ] && [ -f "$cbin/Microsoft.Dynamics.Nav.UICop.dll" ] || { missing="analyzers not found beside $cand"; continue; }
  cmajor="$(sed -n 's/.*"version": *"\([0-9][0-9]*\)\..*/\1/p' "${cand%.dll}.runtimeconfig.json" 2>/dev/null | head -n 1)"
  [ -n "$cmajor" ] || { missing="couldn't read the .NET version for $cand"; continue; }
  if cdotnet="$(find_dotnet "$cmajor")"; then
    altool="$cand"; dotnet="$cdotnet"
    break
  fi
  missing="no .NET $cmajor runtime found for $cand. Open an AL project in VS Code once so the AL extension can provision it."
done <<EOF
$candidates
EOF
[ -n "$altool" ] || fail "$missing"

bindir="$(dirname "$altool")"
codecop="$bindir/Microsoft.Dynamics.Nav.CodeCop.dll"
uicop="$bindir/Microsoft.Dynamics.Nav.UICop.dll"
ptecop="$bindir/Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll"
appsourcecop="$bindir/Microsoft.Dynamics.Nav.AppSourceCop.dll"

DOTNET_ROOT="$(dirname "$dotnet")"
export DOTNET_ROOT
if [ "$profile" = "appsource" ]; then
  profilecop="$appsourcecop"
else
  profilecop="$ptecop"
fi
[ -f "$profilecop" ] || fail "expected analyzer not found next to altool: $profilecop"

log="$(mktemp "${TMPDIR:-/tmp}/ocpf-al-analyze.XXXXXX")" || fail "couldn't create a temporary log file"
trap 'rm -f "$log"' EXIT
"$dotnet" "$altool" compile -- \
  /project:"$project" /packagecachepath:"$project/.alpackages" /out:"$outfile" \
  /analyzer:"$codecop" /analyzer:"$profilecop" /analyzer:"$uicop" "$@" > "$log" 2>&1
status=$?
cat "$log"

errors="$(grep -Ec '(^|: )error [A-Z]+[0-9]+:' "$log")"
warnings="$(grep -Ec '(^|: )warning [A-Z]+[0-9]+:' "$log")"
if [ "$status" -ne 0 ]; then
  echo "OCPF AL analyze: compile failed ($errors error(s), $warnings warning(s); compiler exit code $status)." >&2
  exit 1
fi
if [ "$warnings" -gt 0 ]; then
  echo "OCPF AL analyze: compiled with $warnings warning(s). Operating Rule 5 requires zero; fix them before treating this build as clean." >&2
  exit 3
fi
echo "OCPF AL analyze: clean — 0 errors, 0 warnings ($profile profile)."
exit 0
