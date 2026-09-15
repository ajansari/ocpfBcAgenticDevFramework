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
3. **`.ocpf/framework.json`**, if present: edition, runbook version, and `alMcp`.
4. **Recent context:** the latest entries in `ChangeLog.md`. For Full, also `docs/ProjectMemory.md`.
5. **Parameters:** `docs/ProjectParameters.md` (Full) or `ProjectParameters.md` (Lite), only for
   the extension name.

If `ProjectProgress.md` doesn't exist, the routine hasn't started. Say so, and offer the `start`
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

Then stop. Don't start the next step unless the human asks.
