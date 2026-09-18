---
name: status
description: Report where a Business Central project following the OCPF BC Agentic Development Framework stands - current phase and step, its exit gate, what's waiting on the human, framework edition and version, and AL MCP Server status. Use when the user asks "where are we", "project status", "what's next", "what step are we on", or resumes an OCPF project in a new session or from another device.
---

# OCPF project status

Give a short, accurate status report from the project's own files. Read them fresh; don't rely on
conversation memory.

## What to read

1. **`ProjectProgress.md`** (project root): the step-by-step tracker. Find the step marked
   `In Progress`, or the first one not complete.
2. **The runbook**, as `CLAUDE.md`, `.github/copilot-instructions.md`, or the file named in
   `.ocpf/framework.json`: that step's **Exit gate** and outputs. Read it from the runbook; don't
   paraphrase from memory.
3. **`.ocpf/framework.json`**, if present: edition, runbook version, and `alMcp`. Also
   **`.ocpf/notifications.json`**, if present: the notification kinds this developer chose.
4. **Recent context:** the latest entries in `docs/ChangeLog.md`. For Full, also
   `docs/ProjectMemory.md`. (A project started on a runbook older than Full v3.4.0.0 / Lite v2.3.0.0
   may still keep these in the root — look there second, and say so.)
5. **Parameters:** `docs/ProjectParameters.md` (both editions), for the extension name and the
   model assignment (Full §1.7: three roles; Lite: the Main model row).

If `ProjectProgress.md` doesn't exist (Full) — or, for Lite, which keeps no tracker, neither
`docs/ProjectParameters.md` nor `docs/DesignDoc.md` exists — the routine hasn't started. Say so, and offer the `start`
skill.

## What to report

Keep it to a compact block:

- **Project:** extension name, framework edition, and runbook version.
- **Now:** phase and step (for example "DESIGN, Step 03: Craft the TDD"), and what's done within it.
- **Exit gate:** what must be true to close this step, and which parts are met.
- **Waiting on you:** approvals, sign-offs, answers, or tests the human owes. If nothing, say so.
- **Next:** the next step once the gate is met.
- **AL MCP Server:** connected, not connected, or deferred, from `alMcp` and whether the session
  has the `al` server's tools. If it isn't connected and BUILD has started or is next, suggest the
  `al-mcp-setup` skill.
- **Models:** the recorded model and effort per role, and — Full only — whether the project-local
  `.claude/agents/ocpf-*.md` or `.github/agents/ocpf-*.agent.md` definitions exist with a `model:`
  line that matches. If they don't, say so: delegated steps would be running on the session's model.
- **Notifications:** the kinds recorded in `.ocpf/notifications.json` (Claude app, sound, desktop
  notification, or none). If the file is missing, say "not set" and offer the `notifications` skill.

Then stop. Don't start the next step unless the human asks.
