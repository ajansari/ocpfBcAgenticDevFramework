# Resolves the AL Language extension's altool and a matching .NET runtime for al-mcp.cmd.
# Prints DOTNET=<path> and ALTOOL=<path> on success; writes diagnostics to stderr otherwise.
# Part of the ocpf-bc plugin's al-mcp-setup skill. Nothing is installed.

$ErrorActionPreference = 'Stop'

function Get-VersionKey([string]$name) {
    # Turns "ms-dynamics-smb.al-18.0.2732683" or "10.0.12~x64~aspnetcore" into a sortable version.
    $m = [regex]::Match($name, '(\d+(\.\d+)+)')
    if ($m.Success) { try { return [version]$m.Groups[1].Value } catch { } }
    return [version]'0.0'
}

$altool = $null
foreach ($extDir in @("$env:USERPROFILE\.vscode\extensions", "$env:USERPROFILE\.vscode-insiders\extensions")) {
    if (-not (Test-Path $extDir)) { continue }
    $newest = Get-ChildItem -Path $extDir -Directory -Filter 'ms-dynamics-smb.al-*' |
        Sort-Object { Get-VersionKey $_.Name } | Select-Object -Last 1
    if ($newest -and (Test-Path (Join-Path $newest.FullName 'bin\altool.dll'))) {
        $altool = Join-Path $newest.FullName 'bin\altool.dll'
        break
    }
}
if (-not $altool) {
    [Console]::Error.WriteLine("OCPF AL MCP launcher: no AL Language extension found. Install 'AL Language extension for Microsoft Dynamics 365 Business Central' in VS Code, or the 'al' .NET tool.")
    exit 1
}

$config = Get-Content ($altool -replace '\.dll$', '.runtimeconfig.json') -Raw | ConvertFrom-Json
$major = ([version]($config.runtimeOptions.frameworks | Where-Object { $_.name -eq 'Microsoft.AspNetCore.App' } | Select-Object -First 1).version).Major

$dotnet = $null
$systemDotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if ($systemDotnet) {
    $runtimes = & $systemDotnet.Source --list-runtimes 2>$null
    if ($runtimes | Where-Object { $_ -match "^Microsoft\.AspNetCore\.App $major\." }) { $dotnet = $systemDotnet.Source }
}
if (-not $dotnet) {
    foreach ($store in @("$env:APPDATA\Code\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\.dotnet",
                         "$env:APPDATA\Code - Insiders\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\.dotnet")) {
        if (-not (Test-Path $store)) { continue }
        $candidate = Get-ChildItem -Path $store -Directory -Filter "$major.*aspnetcore" |
            Sort-Object { Get-VersionKey $_.Name } | Select-Object -Last 1
        if ($candidate -and (Test-Path (Join-Path $candidate.FullName 'dotnet.exe'))) {
            $dotnet = Join-Path $candidate.FullName 'dotnet.exe'
            break
        }
    }
}
if (-not $dotnet) {
    [Console]::Error.WriteLine("OCPF AL MCP launcher: no .NET $major runtime found for the AL extension. Open an AL project in VS Code once so the AL extension can provision it.")
    exit 1
}

"DOTNET=$dotnet"
"ALTOOL=$altool"
