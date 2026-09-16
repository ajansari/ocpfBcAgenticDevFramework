---
name: notifications
description: Turn on notifications for a Business Central project following the OCPF BC Agentic Development Framework, so the developer knows whenever the agent finishes a turn, asks a question, or waits for an approval. Asks which kinds the developer wants — Claude app push, sound, desktop notification, or none — records the answer in .ocpf/notifications.json, and applies it through each AI tool's own notifications and hooks. Nothing to install. Use when the user asks to "turn on notifications", "notify me when you're done", "alert me when it's my turn", or runs /ocpf-bc:notifications on a project set up before notifications existed.
---

# OCPF turn notifications

The runbook turns notifications on at its first step (full framework: PRE-01; Lite: Step 1). Use
this skill to do the same on a project that started earlier, or to repair it.

**Follow `Ops § Notifications` in the project's Operations Guide** (`opsGuide/ocpfOperationsGuide.md`)
— it has the exact settings, hooks, and record format, and it's the version this project follows. If
the project has no `opsGuide/` yet (a project started before the guide existed, or a runbook older
than Full v3.0.0.0 / Lite v2.0.0.0), use this plugin's bundled copy in the `start` skill's
`references/ocpfOperationsGuide.md`, or fetch
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/opsGuide/ocpfOperationsGuide.md`.
The procedure is the same for both editions.

In short:
1. **Ask one multi-select question** through the options mechanism: *"Would you like to be notified
   at the end of every turn and whenever a question or approval is waiting? Choose any."* Offer only
   what can work, per `Ops § Notifications`, step 1:
   - *Claude app* — Claude Code signed in through a claude.ai subscription, with Remote Control
     available (no API key, Bedrock, Google Cloud, Foundry, gateway, or the environment variables
     the runbook lists).
   - *Sound* — always.
   - *Desktop notification* — Copilot Chat or Copilot CLI; Claude Code on Windows or Linux, or in
     iTerm2, WezTerm, Ghostty, Warp, or Kitty. Not Claude Code's VS Code extension or VS Code's
     terminal on macOS.
   - *No notifications* — always.
2. **With *Claude app*, explain Remote Control** (transcripts are stored on Anthropic's servers
   while it's connected) and ask: only when the human turns it on, or every session on this machine.
3. **Record the answer in `.ocpf/notifications.json`** — per developer, always gitignored. The
   runbook reads it at the start of every session.
4. **Apply it** per `Ops § Notifications`, step 3: Claude Code push settings and sound/desktop hooks in
   `.claude/settings.local.json` (plus `remoteControlAtStartup` in `~/.claude/settings.json` for
   every-session Remote Control); VS Code user settings for Copilot Chat's own sounds and
   notifications; user-level `~/.copilot/hooks/` for Copilot CLI sound. Before writing a user-level
   file, say it applies to every project on this machine. Add `scripts/` to `.gitignore`, then copy
   `ocpf-notify.sh` or `ocpf-notify.ps1` (untested on Windows) from this skill's `scripts/` folder
   into the project's `scripts/` folder, exactly, when a hook needs it.
5. **Test once** and ask whether each chosen kind arrived and whether clicking a notification
   opened the session.

Never raise an operating-system banner from a script on macOS: clicking one opens Script Editor
instead of the session. Never ask the human to edit settings files or shell profiles by hand.
