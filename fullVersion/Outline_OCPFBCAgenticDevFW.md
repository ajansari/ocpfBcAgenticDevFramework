# OnlyCopilotFans Business Central Agentic Development Framework Outline

*A one-page map of the routine — every phase, and the steps within it. For the full rules, see
the runbook (`BC_App_Build_Routine_Agent.md`); for visual diagrams, see `RunbookSchematics.md`.*

---

## I. DEFINE

*Turn a business need into a validated, complete scope and a filled-in parameter sheet — before
any design work.*

| Step | Role |
|---|---|
| **PRE-01** — State the Problem | Main Agent |
| **PRE-02** — Structured Gap Analysis | Main Agent |
| **01** — Populate the Intake Sheet *(Project Parameters)* | Main Agent |

## II. DESIGN

*A complete FRD and a self-sufficient TDD, both validated for feasibility and internal
consistency — before any code.*

| Step | Role |
|---|---|
| **02** — Craft the Functional Requirements Document *(FRD)* | Reasoning Sub-Agent drafts → Main Agent integrates |
| **03** — Craft the Technical Design Document *(TDD)* | Reasoning Sub-Agent drafts → Main Agent integrates |
| **04** — Sanity Check and Validation | Reasoning Sub-Agent reviews → Main Agent resolves |

## III. BUILD

*Generate AL batch by batch, lint clean — fix root causes, not symptoms. Compiling and packaging
starts as one mandatory pass at Step 07, then becomes a continuous cycle (compile, package,
deploy, test, diagnose, fix, repeat) that carries through the rest of BUILD and into PROVE.*

| Step | Role |
|---|---|
| **05** — Plan the Code | Main Agent |
| **06** — Code Generation | Main Agent generates → Light Sub-Agent runs the post-generation pre-flight/lint pass |
| **07** — Compile and Package, Troubleshoot, Iterate | Reasoning Sub-Agent diagnoses → Main Agent fixes, compiles, packages |

## IV. PROVE

*Prove the built code matches intent — tested, reviewed, documented, and released. Packaging and
sandbox testing are already underway from Step 07; PROVE adds fidelity validation, review,
documentation, and a human-run release test on top.*

| Step | Role |
|---|---|
| **08** — Gap-Fit Test, Fidelity Validation | Reasoning Sub-Agent compares → Main Agent applies |
| **09** — Code Review | Reasoning Sub-Agent reviews → Main Agent applies |
| **10** — Update Design Documents | Main Agent |
| **11** — Document the Code | Main Agent |
| **12** — Release to Users for Testing | Main Agent coordinates (testing itself is human-run) |

---

## ALL ALONG — Continuous Discipline

*Not a phase — runs underneath all four, every step, from PRE-01 to 12.*

- Document
- Track Changes — the ChangeLog
- Retain Explanations
- Testing Feedback Log
- Project Memory
- Packaging & Versioning
- Repository Hygiene
- AL MCP Server
- Translations & Terminology — translation glossary, named reviewers, release gate on approved translations
- Reference Sources — Microsoft Learn (BC Base App, BC System App, translation files, country/language availability) and AL Guidelines
- BCQuality Knowledge Snapshot
- OCPF BC AL Patterns Library
- OCPF Plugin (optional) — update check, Standards Guide fallback, zero-install AL tool setup, sub-agents

---

