# OnlyCopilotFans Business Central Agentic Development Framework Outline

*A one-page map of the routine — every phase, and the steps within it. For the full rules, see
the runbook (`BC_App_Build_Routine_Agent.md` — the core, with one file per step in `steps/` that a
project fetches into `ocpfFramework/runbookSteps/`); for the document templates,
`documentTemplates/` (a project's copy: `ocpfFramework/documentTemplates/`); for visual diagrams,
see `RunbookSchematics.md`. In a project, everything the framework fetches or keeps lives under
`ocpfFramework/`; the project's documents live in `docs/0-project/` … `docs/4-prove/`, its AL under
`src/`, and `ProjectProgress.md` alone in the root.*

---

## I. DEFINE

*Turn a business need into a validated, complete scope and a filled-in parameter sheet — before
any design work.*

| Step | Role |
|---|---|
| **PRE-01** — State the Problem | Main Agent — asks the working language, notifications, the six model-and-effort questions (Main / Light / Reasoning, the recommended pair per tool offered first) and who approves; writes the three project-local sub-agents (light, reasoning, generator); creates `ocpfFramework/`, `docs/` with its phase folders, and `ProjectProgress.md` |
| **PRE-02** — Structured Gap Analysis | Main Agent |
| **01** — Populate the Intake Sheet *(Project Parameters)* | Main Agent — including the app icon and the starting version (`0.0.0.1` for a new app); creates `src/` |

## II. DESIGN

*A complete FRD and a self-sufficient TDD, both validated for feasibility and internal
consistency — before any code.*

| Step | Role |
|---|---|
| **02** — Craft the Functional Requirements Document *(FRD)* | Reasoning Sub-Agent drafts → Main Agent integrates |
| **03** — Craft the Technical Design Document *(TDD)* + Human Effort Estimate + AI Effort Estimate | Reasoning Sub-Agent drafts the TDD and the human estimate (from the baselines file) → Main Agent integrates and writes the AI estimate |
| **04** — Sanity Check and Validation | Reasoning Sub-Agent reviews → Main Agent resolves |

## III. BUILD

*Generate AL batch by batch, lint clean — fix root causes, not symptoms. Compiling and packaging
starts as one mandatory pass at Step 07, then becomes a continuous cycle (compile, package,
deploy, test, diagnose, fix, repeat) that carries through the rest of BUILD and into PROVE.*

| Step | Role |
|---|---|
| **05** — Plan the Code | Main Agent — fixes every ID and `src/` path in the Build Plan; asks once how the batches run (all in parallel — recommended — / one at a time / ask per batch) |
| **06** — Code Generation | Generator Sub-Agents (one per batch, in the background, on the Main model) or the Main Agent generate → Light Sub-Agent runs the post-generation pre-flight/lint pass as each batch returns → Main Agent integrates |
| **07** — Compile and Package, Troubleshoot, Iterate | Reasoning Sub-Agent diagnoses → Main Agent fixes, increments the Revision, compiles, packages, and ends every build with the fixed "Package built:" block |

## IV. PROVE

*Prove the built code matches intent — tested, reviewed, documented, and released. Packaging and
sandbox testing are already underway from Step 07; PROVE adds fidelity validation, review,
documentation, and a human-run release test on top.*

| Step | Role |
|---|---|
| **08** — Gap-Fit Test, Fidelity Validation | Reasoning Sub-Agent compares → Main Agent records the classification (Step 10 applies it) |
| **09** — Code Review | Reasoning Sub-Agent reviews and grades the eight-dimension scorecard (§0 of `CodeReview.md`) → Main Agent records and applies |
| **10** — Update Design Documents | Main Agent |
| **11** — Document the Code | Main Agent — five mandatory documents (Documentation, User Guide, Human Unit Test Script, Deployment, Acknowledgements); then asks whether to build the release candidate v1.0.0.0 |
| **12** — Release to Users for Testing | Main Agent coordinates (testing itself is human-run); fixes continue 1.0.0.1, 1.0.0.2 …; the package that passes ships as it is |

---

## ALL ALONG — Continuous Discipline

*Not a phase — runs underneath all four, every step, from PRE-01 to 12.*

Each one keeps its non-negotiables in the runbook and points at the shared
**Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`, cited as **Ops §**) for the
procedure — fetched at PRE-01 alongside the Standards Guide.

- Document — every project document in its `docs/` phase folder (`0-project`, `1-define`, `2-design`, `3-build`, `4-prove`); only `ProjectProgress.md` at the root
- Track Changes — the ChangeLog
- Retain Explanations
- Testing Feedback Log
- Project Memory
- Project Progress Tracker — `ProjectProgress.md`, one status row per step, in the project root, plus the usage table — both editions
- Usage & Cost Tracking — Operating Rule 11's step boundary ritual: rows at every step start and close, one per model, never hand-written (Claude Code: tokens by type from its transcripts; GitHub Copilot: AI credits from its chat session files — two different tables), priced from published rates, next to the human and AI effort estimates; calibration export at project close
- Translations & Terminology — translation glossary, named reviewers, release gate on approved translations
- Packaging & Versioning — new apps start at `0.0.0.1`; the Revision goes up before every build, never two builds at one version, never a package overwritten; the fixed "Package built:" block after each; the release candidate `1.0.0.0` asked at Step 11; the package that passes ships as it is
- Repository Hygiene — `ocpfFramework/state/` and the fetched folders always gitignored, the rest of `ocpfFramework/` and the sub-agent definitions per intake §1.8, verified with `git check-ignore`
- AL MCP Server — set up by the agent at Step 01 §1.10; the human only approves
- Tooling Checks — Node and the mermaid renderer via `npx` (never `which mmdc`), PowerShell 7; zero-install ladder, outcomes recorded in `framework.json`
- Analyzers — CodeCop, UICop, and PerTenantExtensionCop *or* AppSourceCop, engaged on every mandatory compile
- Symbols — downloaded by the agent, never the human
- Keeping the Editor in Sync — stale red marks detected and refreshed
- Notifications — Claude app, sound, and/or desktop notification, chosen at intake and remembered, whenever the agent finishes a turn, asks a question, or waits for an approval
- OCPF AL Development Standards Guide — fetched at PRE-01, cited as **Standards §** throughout
- OCPF Operations Guide — fetched at PRE-01, cited as **Ops §**: the procedures both editions share
- Reference Sources — the downloaded symbols are the only routine lookup; Microsoft Learn's BC Base App and System App only when symbols can't answer, with a reason stated; the translation-files and country/language pages, and AL Guidelines, as before
- BCQuality Knowledge Snapshot
- OCPF BC AL Patterns Library
- OCPF Plugin (optional) — update check (with the layout migration for older projects), offline copies of both companions, the step files, and the templates; zero-install AL tool setup; notification setup; three sub-agents (light, reasoning, generator); the `documents` and `usage` skills

---

