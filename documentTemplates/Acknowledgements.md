> **Template** for `docs/0-project/Acknowledgements.md` — OCPF BC Agentic Development Framework, written at Full Step 11 / Lite Step 6 — both editions; always committed. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Acknowledgements — <Extension Name>

**Date:** <date> · **Version:** <app.json version>

## 1. Resources used on this project
One row per resource actually used. The rows below are pre-filled with everything the framework can bring to a project: **keep only what was used** — XLIFF Sync *or* NAB AL Tools (or neither, when there was no translation); Claude Code *or* GitHub Copilot, naming the models that ran; drop mermaid-cli when no diagram was rendered. Delete the *if used* markers from the rows that stay.
| Resource | Author | License | How it was used on this project |
|---|---|---|---|
| OCPF BC Agentic Development Framework <edition, version> | AJ Ansari, OnlyCopilotFans | MIT | The runbook, Standards Guide, Operations Guide, and document templates that drove every step |
| BCQuality | Microsoft | MIT | Knowledge base and review checks applied at code generation and code review |
| OCPF BC AL Patterns Library | AJ Ansari | MIT | Patterns applied: <which> |
| AL Language extension and AL MCP Server | Microsoft | Microsoft license terms | Compile, package, symbols, diagnostics, and tests through the AL tools |
| XLIFF Sync (module and extension) — if used | Rob van Bekkum | MIT | Translation file sync for <languages> |
| NAB AL Tools — if used | Johannes Wikman | MIT | Translation file sync for <languages> |
| mermaid-cli | Tyler Long and contributors | MIT | Rendered the diagrams in `docs/4-prove/Documentation.md` / `docs/4-prove/Docs.md` |
| Claude Code — if used | Anthropic | Anthropic's own terms (not open source) | The AI tool; models: <Main / Light / Reasoning models and efforts> |
| GitHub Copilot — if used | GitHub | GitHub's own terms (not open source) | The AI tool; models: <Main / Light / Reasoning models and efforts> |

## 2. Note
None of these credits is legally required. Nothing from any of these tools or libraries is bundled in the shipped `.app`: they were used to design, generate, check, and document the code, and the code is the publisher's own. The credits are here because the work was faster and better for them.

## Before calling this done
- [ ] Every tool used on this project appears in §1, with the models named for the AI tool; nothing that wasn't used remains.
- [ ] Every license matches `THIRD_PARTY_NOTICES.md` of the framework repository (the AI tool is named there only as a trademark; its row says "own terms").
- [ ] The §2 note is present, unchanged.
