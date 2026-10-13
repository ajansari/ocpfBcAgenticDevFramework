> **Template** for `ProjectProgress.md — in the project root, never docs/` — OCPF BC Agentic Development Framework, written at Full PRE-01 / Lite Step 1 / Build-a-Feature Part 2 — every journey; refreshed at every step start and exit gate (Build-a-Feature: at every object's start and close). Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Project Progress — <Extension Name>

## Steps
A remediation (Ops § Usage & Cost → 7) is a row added directly under its base step: `| BUILD | 07a — Remediation | In Progress |` (Lite: `STEP-5a`). Keep the table for this journey, delete the other two, and drop the `### Full` / `### Lite` / `### Build-a-Feature` heading that remains. A Full or Lite project on which Build-a-Feature later runs keeps its step table **and** appends the Build-a-Feature table under its own `## Build-a-Feature` heading, between the step table and the usage table.

### Full
| Phase | Step | Status |
|---|---|---|
| DEFINE | PRE-01 — State the Problem | In Progress |
| DEFINE | PRE-02 — Structured Gap Analysis | |
| DEFINE | 01 — Populate the Intake Sheet (Project Parameters) | |
| DESIGN | 02 — Craft the FRD | |
| DESIGN | 03 — Craft the TDD (+ Human and AI Effort Estimates) | |
| DESIGN | 04 — Sanity Check and Validation | |
| BUILD | 05 — Plan the Code | |
| BUILD | 06 — Code Generation | |
| BUILD | 07 — Compile and Package, Troubleshoot, Iterate | |
| PROVE | 08 — Gap-Fit Test, Fidelity Validation | |
| PROVE | 09 — Code Review | |
| PROVE | 10 — Update Design Documents | |
| PROVE | 11 — Document the Code | |
| PROVE | 12 — Release to Users for Testing | |

### Lite
| Phase | Step | Status |
|---|---|---|
| DEFINE | STEP-1 — Define the Problem & Lock Parameters | In Progress |
| DESIGN | STEP-2 — Write the Design Doc & Self-Check | |
| BUILD | STEP-3 — Plan & Scaffold | |
| BUILD | STEP-4 — Generate the Code | |
| BUILD | STEP-5 — Compile, Package, Test & Iterate | |
| PROVE | STEP-6 — Review, Gap-Check & Finalize Docs | |
| PROVE | STEP-7 — Release for Testing | |

### Build-a-Feature
One row per object asked for, in start order, plus the intake, the package, and the review (Ops § Build-a-Feature). `Row`: `F00` intake · `F01`, `F02`, … objects, continuing across sessions · `FPK` package · `FRV` review. `Stage`: Asked → Confirmed → Built → Compiled → Reviewed → Packaged. `Status`: `In Progress` while the row's usage window is open, `Completed` once its usage rows are written. `Shipped in`: the first package version that held the object.

| Row | Object | Type | ID | Stage | Status | Shipped in |
|---|---|---|---|---|---|---|
| F00 | Intake | — | — | — | In Progress | — |

## Usage and cost
Measured at every step boundary (ALL ALONG → Usage & Cost Tracking; Ops § Usage & Cost → *The step boundary ritual*; Build-a-Feature: at every object's close, the `F` ids as steps). **One row per model that ran in the step** — the Main model and every sub-agent model — never one row for the step. Written by the `usage` script, never by hand. Cost at published rates.

**Keep the table for the project's AI tool and delete the other** (Ops § Usage & Cost → *The table*). A project that changed tools midway keeps both, each with the steps worked in that tool.

### Claude Code — tokens by type
From Claude Code's session transcripts.
| Step | Model(s) | Input | Output | Cache write | Cache read | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| <PRE-01, STEP-1, or F00> | <model> | | | | | | | | | | | |
| **Total** | | | | | | | | | | | | |

*Prices: <source URL>, read <date>. Human estimate: `docs/2-design/HumanEffortEstimate.md`; AI estimate: `docs/2-design/AiEffortEstimate.md`.*

### GitHub Copilot — AI credits
From the Copilot session journals (`~/.copilot/session-state`, VS Code's chat and the CLI alike), sub-agents included — one row per step, every model that answered named. Copilot records no token totals by type, so this table has none; the **Total** is the sum of the sessions' journaled credits, equal to the Session Info popovers once every session has ended.
| Step | Model(s) | AI credits | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |
|---|---|---|---|---|---|---|---|---|---|
| <PRE-01, STEP-1, or F00> | <model(s)> | | | | | | | | <n request(s), session journal> |
| **Total** | | | | | | | | | |

*1 AI credit = $<value>: <source URL>, read <date>. Source: <n> Copilot session journal(s) in <folder> (<n> ended, <n> open). Human estimate: `docs/2-design/HumanEffortEstimate.md`; AI estimate: `docs/2-design/AiEffortEstimate.md`.*

## Before calling a refresh done
- [ ] The step table's `In Progress` row (Build-a-Feature: the feature table's) matches the open window in `ocpfFramework/state/usage.json`.
- [ ] Every step with a start timestamp has a usage row; a step that couldn't be measured says why.
- [ ] Claude Code: one row per model that ran in the step, never one row per step. Copilot: one row per step, every model named. No row was hand-written.
- [ ] Only the table for the project's AI tool is here (both, if the tool changed midway).
- [ ] Copilot: the journal folder is in `ocpfFramework/state/usage.json`, no human was asked for a figure, and a still-open session is noted *as of* its last checkpoint.
- [ ] The step's rows were pasted into the closing message.
- [ ] The Total row and the pricing footnote are current.

---
*Asking, in plain language, "Where are we in the process? What's next?" always gets a direct answer from this file (plus `docs/0-project/ChangeLog.md` — and, in Full, `docs/0-project/ProjectMemory.md` — for the reasoning behind it), whether or not an agent session is running at that moment.*
