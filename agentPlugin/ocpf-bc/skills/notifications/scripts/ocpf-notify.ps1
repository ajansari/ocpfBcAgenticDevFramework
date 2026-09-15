# OCPF "your turn" sound for Windows (from the ocpf-bc plugin's notifications skill).
#
# Plays a short system sound so the developer hears that the ball is in their court. An AI tool's
# hook runs it when the agent finishes a turn, asks a question, or waits for an approval. It shows
# no notification, so there's nothing to click. Nothing is installed. Untested on Windows.
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\ocpf-notify.ps1
#
# Always exits 0: a sound that can't play must never interrupt the agent.

try {
    if ([Console]::IsInputRedirected) { [Console]::In.ReadToEnd() | Out-Null }
    [System.Media.SystemSounds]::Asterisk.Play()
    Start-Sleep -Milliseconds 800
} catch {
    try { [Console]::Beep() } catch { }
}
exit 0
