# OCPF one-shot AL MCP Server call for Windows (from the ocpf-bc plugin's al-mcp-setup skill).
#
# Runs one AL MCP Server tool and exits. For sessions that can't see the `al` server yet: Claude
# Code and Copilot CLI load MCP servers only when a session starts, so a server registered
# mid-session isn't available until the next one. Nothing is installed; this starts the same
# server through al-mcp.cmd beside this file.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\al-mcp-call.ps1 <project folder> <tool name> ['<JSON arguments>'] [timeout seconds]
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\al-mcp-call.ps1 . al_downloadsymbols '{"globalSourcesOnly":true}'
#
# Prints the tool's JSON-RPC response on stdout. Exits 0 when the response arrives, 1 otherwise.

param(
    [Parameter(Mandatory = $true, Position = 0)][string]$ProjectPath,
    [Parameter(Mandatory = $true, Position = 1)][string]$Tool,
    [Parameter(Position = 2)][string]$Arguments = '{}',
    [Parameter(Position = 3)][int]$TimeoutSeconds = 900
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ProjectPath -PathType Container)) {
    [Console]::Error.WriteLine("OCPF AL MCP call: project folder not found: $ProjectPath")
    exit 2
}
$project = (Resolve-Path $ProjectPath).Path
if ([string]::IsNullOrWhiteSpace($Arguments)) { $Arguments = '{}' }

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = 'cmd.exe'
# stderr is discarded by cmd so the server's logging can't fill a pipe nobody reads.
$psi.Arguments = '/d /s /c ""' + (Join-Path $PSScriptRoot 'al-mcp.cmd') + '" "' + $project + '" 2>nul"'
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.CreateNoWindow = $true

$server = [System.Diagnostics.Process]::Start($psi)
$pending = $null

function Send-Message([string]$json) {
    $server.StandardInput.WriteLine($json)
    $server.StandardInput.Flush()
}

# Waits for the response with the given id; returns the line, or $null on timeout or exit.
function Wait-Response([int]$id, [int]$seconds) {
    $deadline = [DateTime]::UtcNow.AddSeconds($seconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        if ($null -eq $script:pending) { $script:pending = $server.StandardOutput.ReadLineAsync() }
        $remaining = [int][Math]::Max(1, ($deadline - [DateTime]::UtcNow).TotalMilliseconds)
        if (-not $script:pending.Wait([Math]::Min($remaining, 1000))) { continue }
        $line = $script:pending.Result
        $script:pending = $null
        if ($null -eq $line) { return $null }
        if ($line -match ('"id":' + $id + '[,}]')) { return $line }
    }
    [Console]::Error.WriteLine("OCPF AL MCP call: no response from $Tool within $seconds seconds.")
    return $null
}

function Stop-Server {
    try { $server.StandardInput.Close() } catch { }
    if (-not $server.WaitForExit(5000)) {
        # cmd.exe hosts the server as a child process, so end the whole tree.
        & taskkill.exe /PID $server.Id /T /F 2>$null | Out-Null
    }
}

$status = 1
try {
    Send-Message '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"ocpf-al-mcp-call","version":"1.0.0"}}}'
    if ($null -ne (Wait-Response 1 120)) {
        Send-Message '{"jsonrpc":"2.0","method":"notifications/initialized"}'
        Send-Message ('{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"' + $Tool + '","arguments":' + $Arguments + '}}')
        $response = Wait-Response 2 $TimeoutSeconds
        if ($null -ne $response) {
            Write-Output $response
            $status = 0
        }
    }
    elseif ($server.HasExited) {
        [Console]::Error.WriteLine('OCPF AL MCP call: the AL MCP Server exited. Run scripts\al-mcp.cmd --help to see why.')
    }
}
finally {
    Stop-Server
}
exit $status
