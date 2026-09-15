@echo off
rem OCPF analyzer-enabled compile for Windows (from the ocpf-bc plugin's al-mcp-setup skill).
rem
rem Compiles the project with Microsoft's bundled code analyzers actually engaged, using tools
rem already on this machine. Nothing is installed. Paths are resolved by al-analyze-resolve.ps1
rem beside this file. See al-analyze.sh for why this exists instead of the AL MCP Server's
rem al_build/al_compile tools.
rem
rem Usage: al-analyze.cmd <project folder> <output .app path> [extra alc arguments...]
rem   scripts\al-analyze.cmd . outputAppPackage\MyApp_1.0.0.0.app
rem
rem Analyzers included by default: CodeCop, PerTenantExtensionCop, UICop. Add AppSourceCop
rem yourself (an extra /analyzer:<path> argument) only when Deployment Target is AppSource.
rem
rem Exits with the compiler's own exit code: 0 only when the compile is clean under every
rem analyzer passed.

setlocal

if "%~2"=="" (
  echo OCPF AL analyze: usage: al-analyze.cmd ^<project folder^> ^<output .app path^> [extra alc arguments...] 1>&2
  exit /b 2
)
set "OCPF_PROJECT=%~1"
set "OCPF_OUT=%~2"
shift
shift

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

for %%d in ("%OCPF_DOTNET%") do set "DOTNET_ROOT=%%~dpd"
"%OCPF_DOTNET%" "%OCPF_ALTOOL%" compile -- ^
  /project:"%OCPF_PROJECT%" /packagecachepath:"%OCPF_PROJECT%\.alpackages" /out:"%OCPF_OUT%" ^
  /analyzer:"%OCPF_BINDIR%\Microsoft.Dynamics.Nav.CodeCop.dll" ^
  /analyzer:"%OCPF_BINDIR%\Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll" ^
  /analyzer:"%OCPF_BINDIR%\Microsoft.Dynamics.Nav.UICop.dll" ^
  %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b %errorlevel%
