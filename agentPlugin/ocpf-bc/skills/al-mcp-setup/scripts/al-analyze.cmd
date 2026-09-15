@echo off
rem OCPF analyzer-enabled compile for Windows (from the ocpf-bc plugin's al-mcp-setup skill).
rem
rem Compiles the project with Microsoft's bundled code analyzers actually engaged, using tools
rem already on this machine. Nothing is installed. Paths are resolved by al-analyze-resolve.ps1
rem beside this file. See al-analyze.sh for why this exists instead of the AL MCP Server's
rem al_build/al_compile tools.
rem
rem Usage: al-analyze.cmd <project folder> <output .app path> [pte|appsource] [extra alc args...]
rem   scripts\al-analyze.cmd . outputAppPackage\MyApp_1.0.0.0.app
rem   scripts\al-analyze.cmd . outputAppPackage\MyApp_1.0.0.0.app appsource
rem
rem Profile picks the analyzer set - pass whichever matches Deployment Target:
rem   pte       (default) CodeCop, PerTenantExtensionCop, UICop - SaaS PTE or OnPrem PTE.
rem   appsource CodeCop, AppSourceCop, UICop - Deployment Target = AppSource.
rem Never both PerTenantExtensionCop and AppSourceCop in the same compile - Microsoft's own docs
rem say several of their rules are incompatible and only one should be enabled at a time; loading
rem both on a plain PTE-shaped project buried it in AppSource-only errors unrelated to the code.
rem
rem The appsource profile also needs an AppSourceCop.json in the project root (mandatoryAffixes at
rem minimum) or the compile fails outright with AS0054 - this script doesn't create one; the
rem runbook does that separately when Deployment Target is AppSource.
rem
rem Exit codes: 0 = no errors and no warnings (Operating Rule 5); 1 = compile failed or tools not
rem found; 3 = compiled with warnings. The compiler itself exits 0 on warnings, so this script
rem counts them. Untested on Windows.

setlocal enabledelayedexpansion

if "%~2"=="" (
  echo OCPF AL analyze: usage: al-analyze.cmd ^<project folder^> ^<output .app path^> [pte^|appsource] [extra alc args...] 1>&2
  exit /b 2
)
set "OCPF_PROJECT=%~1"
set "OCPF_OUT=%~2"
shift
shift

set "OCPF_PROFILE=pte"
if /i "%~1"=="pte" (set "OCPF_PROFILE=pte" & shift)
if /i "%~1"=="appsource" (set "OCPF_PROFILE=appsource" & shift)

set "OCPF_DOTNET="
set "OCPF_ALTOOL="
set "OCPF_BINDIR="
for /f "usebackq tokens=1,* delims==" %%a in (`powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0al-analyze-resolve.ps1"`) do (
  if "%%a"=="DOTNET" set "OCPF_DOTNET=%%b"
  if "%%a"=="ALTOOL" set "OCPF_ALTOOL=%%b"
  if "%%a"=="BINDIR" set "OCPF_BINDIR=%%b"
)

if not defined OCPF_ALTOOL (
  echo OCPF AL analyze: no AL Language extension or .NET runtime found. See the messages above. 1>&2
  exit /b 1
)

if /i "%OCPF_PROFILE%"=="appsource" (
  set "OCPF_ANALYZER2=%OCPF_BINDIR%\Microsoft.Dynamics.Nav.AppSourceCop.dll"
) else (
  set "OCPF_ANALYZER2=%OCPF_BINDIR%\Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll"
)
if not exist "!OCPF_ANALYZER2!" (
  echo OCPF AL analyze: expected analyzer not found next to altool: !OCPF_ANALYZER2! 1>&2
  exit /b 1
)

set "OCPF_LOG=%TEMP%\ocpf-al-analyze-%RANDOM%%RANDOM%.log"
for %%d in ("%OCPF_DOTNET%") do set "DOTNET_ROOT=%%~dpd"
"%OCPF_DOTNET%" "%OCPF_ALTOOL%" compile -- ^
  /project:"%OCPF_PROJECT%" /packagecachepath:"%OCPF_PROJECT%\.alpackages" /out:"%OCPF_OUT%" ^
  /analyzer:"%OCPF_BINDIR%\Microsoft.Dynamics.Nav.CodeCop.dll" ^
  /analyzer:"!OCPF_ANALYZER2!" ^
  /analyzer:"%OCPF_BINDIR%\Microsoft.Dynamics.Nav.UICop.dll" ^
  %1 %2 %3 %4 %5 %6 %7 %8 %9 > "%OCPF_LOG%" 2>&1
set "OCPF_STATUS=!errorlevel!"
type "%OCPF_LOG%"

if not "!OCPF_STATUS!"=="0" (
  del "%OCPF_LOG%" >nul 2>&1
  echo OCPF AL analyze: compile failed ^(compiler exit code !OCPF_STATUS!^). 1>&2
  exit /b 1
)
findstr /r /c:": warning [A-Z][A-Z]*[0-9][0-9]*:" "%OCPF_LOG%" >nul
if not errorlevel 1 (
  del "%OCPF_LOG%" >nul 2>&1
  echo OCPF AL analyze: compiled with warnings. Operating Rule 5 requires zero; fix them before treating this build as clean. 1>&2
  exit /b 3
)
del "%OCPF_LOG%" >nul 2>&1
echo OCPF AL analyze: clean - 0 errors, 0 warnings ^(%OCPF_PROFILE% profile^).
exit /b 0
