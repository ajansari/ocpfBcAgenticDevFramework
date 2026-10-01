# Resolves altool, a matching .NET runtime, and the analyzer DLL folder for al-analyze.cmd.
# Prints DOTNET=<path>, ALTOOL=<path>, and BINDIR=<path> on success; writes diagnostics to
# stderr otherwise. Part of the ocpf-bc plugin's al-mcp-setup skill. Nothing is installed.

$ErrorActionPreference = 'Stop'

function Get-VersionKey([string]$name) {
    # Turns "ms-dynamics-smb.al-18.0.2732683", "net10.0", or "10.0.12~x64~aspnetcore" into a sortable version.
    $m = [regex]::Match($name, '(\d+(\.\d+)+)')
    if ($m.Success) { try { return [version]$m.Groups[1].Value } catch { } }
    return [version]'0.0'
}

function Find-Dotnet([int]$major) {
    # A system dotnet with the ASP.NET Core runtime altool needs, then VS Code's private runtime.
    $systemDotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($systemDotnet) {
        $runtimes = & $systemDotnet.Source --list-runtimes 2>$null
        if ($runtimes | Where-Object { $_ -match "^Microsoft\.AspNetCore\.App $major\." }) { return $systemDotnet.Source }
    }
    foreach ($store in @("$env:APPDATA\Code\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\.dotnet",
                         "$env:APPDATA\Code - Insiders\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\.dotnet")) {
        if (-not (Test-Path $store)) { continue }
        $candidate = Get-ChildItem -Path $store -Directory -Filter "$major.*aspnetcore" |
            Sort-Object { Get-VersionKey $_.Name } | Select-Object -Last 1
        if ($candidate -and (Test-Path (Join-Path $candidate.FullName 'dotnet.exe'))) {
            return (Join-Path $candidate.FullName 'dotnet.exe')
        }
    }
    return $null
}

# Candidate altool.dll files, best first. The analyzer DLLs ship in the same folder as each one.
#   1. The global `al` .NET tool, if it works (matching al-mcp.cmd's precedence). Its tool store is
#      <version>\<package id>\<version>\tools\<net TFM>\any\ - newest version, newest TFM first.
#   2. The newest AL Language extension's bin\ folder.
$candidates = @()
$systemAl = Get-Command al -ErrorAction SilentlyContinue
if ($systemAl) {
    try { & $systemAl.Source --version 2>$null | Out-Null; $alWorks = ($LASTEXITCODE -eq 0) } catch { $alWorks = $false }
    if ($alWorks) {
        $store = "$env:USERPROFILE\.dotnet\tools\.store\microsoft.dynamics.businesscentral.development.tools"
        if (Test-Path $store) {
            $candidates += Get-ChildItem -Path $store -Recurse -Filter 'altool.dll' -ErrorAction SilentlyContinue |
                Sort-Object @{ Expression = { Get-VersionKey $_.Directory.Parent.Parent.Parent.Name }; Descending = $true },
                            @{ Expression = { Get-VersionKey $_.Directory.Parent.Name }; Descending = $true } |
                ForEach-Object { $_.FullName }
        }
    }
}
foreach ($extDir in @("$env:USERPROFILE\.vscode\extensions", "$env:USERPROFILE\.vscode-insiders\extensions")) {
    if (-not (Test-Path $extDir)) { continue }
    $newest = Get-ChildItem -Path $extDir -Directory -Filter 'ms-dynamics-smb.al-*' |
        Sort-Object { Get-VersionKey $_.Name } | Select-Object -Last 1
    if ($newest -and (Test-Path (Join-Path $newest.FullName 'bin\altool.dll'))) {
        $candidates += (Join-Path $newest.FullName 'bin\altool.dll')
        break
    }
}
if ($candidates.Count -eq 0) {
    [Console]::Error.WriteLine("OCPF AL analyze: no AL Language extension found. Install 'AL Language extension for Microsoft Dynamics 365 Business Central' in VS Code, or the 'al' .NET tool.")
    exit 1
}

# Use the first candidate that has its analyzers and a runtime it can run on. The profile's own
# analyzer (PerTenantExtensionCop or AppSourceCop) is checked by al-analyze.cmd.
$missing = ''
foreach ($altool in $candidates) {
    $binDir = Split-Path $altool -Parent
    if (-not ((Test-Path (Join-Path $binDir 'Microsoft.Dynamics.Nav.CodeCop.dll')) -and
              (Test-Path (Join-Path $binDir 'Microsoft.Dynamics.Nav.UICop.dll')))) {
        $missing = "analyzers not found beside $altool"
        continue
    }
    try {
        $config = Get-Content ($altool -replace '\.dll$', '.runtimeconfig.json') -Raw | ConvertFrom-Json
        $major = ([version]($config.runtimeOptions.frameworks | Where-Object { $_.name -eq 'Microsoft.AspNetCore.App' } | Select-Object -First 1).version).Major
    } catch {
        $missing = "couldn't read the .NET version for $altool"
        continue
    }
    $dotnet = Find-Dotnet $major
    if ($dotnet) {
        "DOTNET=$dotnet"
        "ALTOOL=$altool"
        "BINDIR=$binDir"
        exit 0
    }
    $missing = "no .NET $major runtime found for $altool. Open an AL project in VS Code once so the AL extension can provision it."
}
[Console]::Error.WriteLine("OCPF AL analyze: $missing")
exit 1
