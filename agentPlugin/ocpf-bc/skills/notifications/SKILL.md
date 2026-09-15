---
name: notifications
description: Turn on notifications for a Business Central project following the OCPF BC Agentic Development Framework, so the developer knows whenever the agent finishes a turn, asks a question, or waits for an approval. Uses each AI tool's own notifications: VS Code's for GitHub Copilot Chat, GitHub Copilot CLI's built-in ones, and Claude app push plus a sound for Claude Code. Nothing to install. Use when the user asks to "turn on notifications", "notify me when you're done", "alert me when it's my turn", or runs /ocpf-bc:notifications on a project set up before notifications existed.
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
- **GitHub Copilot Chat in VS Code:** `"chat.notifyWindowOnResponseReceived": "always"` and
  `"chat.notifyWindowOnConfirmation": "always"` in `.vscode/settings.json`.
- **GitHub Copilot CLI:** nothing to set up; its own desktop notifications are on by default.
- **Claude Code:** ask whether the human wants Claude app push notifications. Copy
  `ocpf-notify.sh` (macOS/Linux) or `ocpf-notify.ps1` (Windows, untested on Windows) from this
  skill's `scripts/` folder into the project's `scripts/` folder, exactly — it plays a short sound
  and shows nothing to click. Write the sound hooks, and with push the two push settings, into
  `.claude/settings.local.json` (merge, and add it to `.gitignore`). With push, add
  `"remoteControlAtStartup": true` to `~/.claude/settings.json`, and end every turn that hands the
  ball back with a short push.
- **Test once** and ask, through the options mechanism, whether it worked.

Never raise an operating-system banner from a script: on macOS, clicking one opens Script Editor
instead of the session. Say what you're doing in one sentence rather than asking whether to do it,
apart from the push question. Never ask the human to edit settings files by hand.
