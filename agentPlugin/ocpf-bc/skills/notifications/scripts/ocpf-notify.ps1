# OCPF "your turn" notification for Windows (from the ocpf-bc plugin's notifications skill).
#
# An AI tool's hook runs it when the agent finishes a turn, asks a question, or waits for an
# approval, with the kinds the developer chose at intake (ALL ALONG → Notifications). Nothing is
# installed. Untested on Windows.
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\ocpf-notify.ps1 [-Sound] [-Desktop] [-Message <text>]
#   -Sound    a short Windows system sound
#   -Desktop  a Windows notification, shown by a hidden child process so the caller doesn't wait
# With neither, it plays the sound. Always exits 0: a notification that can't be shown must never
# interrupt the agent.

param([switch]$Sound, [switch]$Desktop, [string]$Message = 'Your turn: the agent is waiting for you', [switch]$ShowBalloon)

try {
    if ($ShowBalloon) {
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing
        $icon = New-Object System.Windows.Forms.NotifyIcon
        $icon.Icon = [System.Drawing.SystemIcons]::Information
        $icon.Visible = $true
        $icon.ShowBalloonTip(5000, 'OCPF BC agent', $Message, [System.Windows.Forms.ToolTipIcon]::Info)
        Start-Sleep -Seconds 6
        $icon.Dispose()
        exit 0
    }
    if ([Console]::IsInputRedirected) { [Console]::In.ReadToEnd() | Out-Null }
    if (-not $Sound -and -not $Desktop) { $Sound = $true }
    if ($Desktop) {
        $project = Split-Path -Leaf (Get-Location)
        Start-Process -WindowStyle Hidden -FilePath 'powershell.exe' -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"",
            '-ShowBalloon', '-Message', "`"$Message ($project)`"")
    }
    if ($Sound) {
        [System.Media.SystemSounds]::Asterisk.Play()
        Start-Sleep -Milliseconds 800
    }
} catch {
    try { [Console]::Beep() } catch { }
}
exit 0
