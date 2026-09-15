---
name: notifications
description: Turn on desktop notifications for a Business Central project following the OCPF BC Agentic Development Framework, so the developer is alerted whenever the agent finishes a turn, asks a question, or waits for an approval. Sets up the AI tool's own hooks (Claude Code, GitHub Copilot CLI) or settings (GitHub Copilot Chat in VS Code) with nothing to install. Use when the user asks to "turn on notifications", "notify me when you're done", "alert me when it's my turn", or runs /ocpf-bc:notifications on a project set up before notifications existed.
---

# OCPF turn notifications

The runbook turns notifications on at its first step (full framework: PRE-01; Lite: Step 1). Use
this skill to do the same on a project that started earlier, or to repair it.

**Follow the project runbook's ALL ALONG → Notifications section.** It has the exact hook
configuration for each AI tool, and it's the version this project follows. If the runbook predates
that section, fetch the latest runbook's section from
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/BC_App_Build_Routine_Agent.md`
and follow it; the configuration is the same for both editions.

In short:
1. **Copy the script** from this skill's `scripts/` folder into the project's `scripts/` folder,
   exactly: `ocpf-notify.sh` (macOS/Linux) or `ocpf-notify.ps1` (Windows, untested on Windows).
2. **Write the hooks for the tools in use, per developer and never committed:**
   - **Claude Code:** `.claude/settings.local.json` — `Stop`, `PreToolUse` on `AskUserQuestion`,
     and `Notification` on `permission_prompt`. Merge into any existing file, and add it to
     `.gitignore`.
   - **GitHub Copilot CLI:** `~/.copilot/hooks/ocpf-notify.json` — `agentStop` and `notification`.
     It's outside the project, so say so; the AI tool asks before writing it.
   - **GitHub Copilot Chat in VS Code:** `"chat.notifyWindowOnResponseReceived": "always"` and
     `"chat.notifyWindowOnConfirmation": "always"` in `.vscode/settings.json`.
3. **Test once:** run the script with a test message and ask, through the options mechanism,
   whether a notification appeared. On macOS, if it didn't, the human needs to allow **Script
   Editor** in **System Settings → Notifications**.

Say what you're doing in one sentence rather than asking whether to do it: telling the human when
it's their turn is part of the framework, and nothing is installed. Never ask the human to edit
settings files by hand.
