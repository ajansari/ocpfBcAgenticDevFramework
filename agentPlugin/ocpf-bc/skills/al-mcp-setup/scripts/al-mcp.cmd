@echo off
rem OCPF AL MCP Server launcher for Windows (from the ocpf-bc plugin's al-mcp-setup skill).
rem
rem Starts Microsoft's AL MCP Server using tools already on this machine. Nothing is installed.
rem Tools are looked up fresh on every launch, so AL Language extension updates never break it.
rem   1. The `al` .NET tool (Microsoft.Dynamics.BusinessCentral.Development.Tools), if on PATH.
rem   2. The AL Language extension's own altool, run on the .NET runtime that VS Code already
rem      provisions for it (or a system .NET with the runtime altool needs).
rem Paths are resolved by al-mcp-resolve.ps1 beside this file. stdout carries only the MCP protocol.

setlocal

where al >nul 2>nul
if not errorlevel 1 (
  al --version >nul 2>nul
  if not errorlevel 1 (
    al launchmcpserver --transport stdio %*
    exit /b %errorlevel%
  )
)

set "OCPF_DOTNET="
set "OCPF_ALTOOL="
for /f "usebackq tokens=1,* delims==" %%a in (`powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0al-mcp-resolve.ps1"`) do (
  if "%%a"=="DOTNET" set "OCPF_DOTNET=%%b"
  if "%%a"=="ALTOOL" set "OCPF_ALTOOL=%%b"
)

if not defined OCPF_ALTOOL (
  echo OCPF AL MCP launcher: no AL Language extension or .NET runtime found. See the messages above. 1>&2
  exit /b 1
)

for %%d in ("%OCPF_DOTNET%") do set "DOTNET_ROOT=%%~dpd"
"%OCPF_DOTNET%" "%OCPF_ALTOOL%" launchmcpserver --transport stdio %*
exit /b %errorlevel%
