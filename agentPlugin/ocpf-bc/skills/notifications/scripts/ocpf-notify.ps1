# OCPF turn notification for Windows (from the ocpf-bc plugin's notifications skill).
#
# Shows a Windows notification so the developer knows the ball is in their court. An AI tool's hook
# runs it when the agent finishes a turn, asks a question, or needs an approval. Nothing is
# installed. Untested on Windows.
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\ocpf-notify.ps1 [message]
#
# Returns at once: the notification is shown by a hidden child process, so the calling tool isn't
# held up. Always exits 0: a notification that can't be shown must never interrupt the agent.

param([string]$Message = 'Your turn: the agent is waiting for you', [switch]$Show)

try {
    if (-not $Show) {
        if ([Console]::IsInputRedirected) { [Console]::In.ReadToEnd() | Out-Null }
        $project = Split-Path -Leaf (Get-Location)
        Start-Process -WindowStyle Hidden -FilePath 'powershell.exe' -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"",
            '-Show', '-Message', "`"$Message ($project)`"")
        exit 0
    }
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    $icon = New-Object System.Windows.Forms.NotifyIcon
    $icon.Icon = [System.Drawing.SystemIcons]::Information
    $icon.Visible = $true
    $icon.ShowBalloonTip(5000, 'OCPF BC agent', $Message, [System.Windows.Forms.ToolTipIcon]::Info)
    Start-Sleep -Seconds 6
    $icon.Dispose()
} catch {
    try { [Console]::Beep() } catch { }
}
exit 0
