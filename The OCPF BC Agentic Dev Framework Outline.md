# OnlyCopilotFans Business Central Agentic Development Framework Outline

*A one-page map of the routine — every phase, and the steps within it. For the full rules, see
the runbook (`CLAUDE.md`); for visual diagrams, see `RunbookSchematics.md`.*

---

## I. DEFINE

*Turn a business need into a validated, complete scope and a filled-in parameter sheet — before
any design work.*

**PRE-01** — State the Problem   
**PRE-02** — Structured Gap Analysis   
**01** — Populate the Intake Sheet *(Project Parameters)*

## II. DESIGN

*A complete FRD and a self-sufficient TDD, both validated for feasibility and internal
consistency — before any code.*

**02** — Craft the Functional Requirements Document *(FRD)*   
**03** — Craft the Technical Design Document *(TDD)*   
**04** — Sanity Check and Validation 

## III. BUILD

*Generate AL batch by batch, lint clean — fix root causes, not symptoms. Compiling and packaging
starts as one mandatory pass at Step 07, then becomes a continuous cycle (compile, package,
deploy, test, diagnose, fix, repeat) that carries through the rest of BUILD and into PROVE.*

**05** — Plan the Code   
**06** — Code Generation   
**07** — Compile and Package, Troubleshoot, Iterate   

## IV. PROVE

*Prove the built code matches intent — tested, reviewed, documented, and released. Packaging and
sandbox testing are already underway from Step 07; PROVE adds fidelity validation, review,
documentation, and a human-run release test on top.*

**08** — Gap-Fit Test, Fidelity Validation   
**09** — Code Review   
**10** — Update Design Documents   
**11** — Document the Code   
**12** — Release to Users for Testing   

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
- BCQuality Knowledge Snapshot
- OCPF BC AL Patterns Library

---

