---
name: notifications
description: Turn on notifications for a Business Central project following the OCPF BC Agentic Development Framework, so the developer knows whenever the agent finishes a turn, asks a question, or waits for an approval. Asks which kinds the developer wants — Claude app push, sound, desktop notification, or none — records the answer in .ocpf/notifications.json, and applies it through each AI tool's own notifications and hooks. Nothing to install. Use when the user asks to "turn on notifications", "notify me when you're done", "alert me when it's my turn", or runs /ocpf-bc:notifications on a project set up before notifications existed.
---

# OCPF turn notifications

The runbook turns notifications on at its first step (full framework: PRE-01; Lite: Step 1). Use
this skill to do the same on a project that started earlier, or to repair it.

**Follow the project runbook's ALL ALONG → Notifications section.** It has the exact settings for
each AI tool, and it's the version this project follows. If the runbook predates that section,
fetch the latest runbook's section from
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/BC_App_Build_Routine_Agent.md`
and follow it; the settings are the same for both editions.

In short:
1. **Ask one multi-select question** through the options mechanism: *"Would you like to be notified
   at the end of every turn and whenever a question or approval is waiting? Choose any."* Offer
   *Claude app* (Claude Code only), *Sound*, *Desktop notification* (GitHub Copilot Chat or
   Copilot CLI on any OS; Claude Code only on Windows or Linux), and *No notifications*.
2. **Record the answer in `.ocpf/notifications.json`** — per developer, always gitignored. The
   runbook reads it at the start of every session.
3. **Apply it** per the runbook's table: Claude Code push settings and sound/desktop hooks in
   `.claude/settings.local.json` (plus `remoteControlAtStartup` in `~/.claude/settings.json` for
   push); VS Code user settings for Copilot Chat's own sounds and notifications; user-level
   `~/.copilot/hooks/` for Copilot CLI sound. Copy `ocpf-notify.sh` or `ocpf-notify.ps1` (untested
   on Windows) from this skill's `scripts/` folder into the project's `scripts/` folder, exactly,
   when a hook needs it.
4. **Test once** and ask whether each chosen kind arrived.

Never raise an operating-system banner from a script on macOS: clicking one opens Script Editor
instead of the session. Never ask the human to edit settings files or shell profiles by hand.
