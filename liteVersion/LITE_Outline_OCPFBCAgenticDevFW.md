# OnlyCopilotFans BC Agentic Development Framework — Lite Outline

*A one-page map of the Lite routine (10 AL files or fewer). For the full routine, see
`LITE_BC_App_Build_Routine_Agent.md` (the core, with one file per step in `steps/` that a project
fetches into `ocpfFramework/runbookSteps/`, and the shared `documentTemplates/` fetched into
`ocpfFramework/documentTemplates/`); for the AL rules it applies, see the shared
`standardsGuide/ocpfALDevStandardsGuide.md` (`ocpfFramework/standardsGuide/` in a project). For larger projects, use the full framework's
`fullVersion/Outline_OCPFBCAgenticDevFW.md` and `fullVersion/BC_App_Build_Routine_Agent.md`
instead.*

---

## I. DEFINE

*Turn a business need into a validated scope and a filled-in parameter sheet — before any design
work.*

| Step | Merges (full framework) |
|---|---|
| **1** — Define the Problem & Lock Parameters (asks the working language, notifications, the one Main model and its thinking effort, and the app icon; creates `docs/` by phase and `ProjectProgress.md`; version starts at `0.0.0.1`; AL source under `src/`) | PRE-01, PRE-02, Step 01 |

## II. DESIGN

*One self-sufficient Design Doc (FRD + TDD in one), self-checked, before any code.*

| Step | Merges (full framework) |
|---|---|
| **2** — Write the Design Doc & Self-Check (+ the Human and AI Effort Estimates) | Step 02, Step 03, Step 04 |

## III. BUILD

*Generate AL, lint clean including symbol verification, then one mandatory compile-and-package
that becomes a continuous fix loop.*

| Step | Merges (full framework) |
|---|---|
| **3** — Plan & Scaffold (IDs and file names fixed; two batches: parallel / one at a time / ask before each) | Step 05 |
| **4** — Generate the Code (one background generator per batch in parallel mode) | Step 06 |
| **5** — Compile, Package, Test & Iterate (Revision incremented before every build; the fixed *Package built* message) | Step 07 |

## IV. PROVE

*Prove the built code matches the Design Doc — reviewed, documented, and passed a human-run
release test.*

| Step | Merges (full framework) |
|---|---|
| **6** — Review, Gap-Check & Finalize Docs (scorecard into the ChangeLog, `Acknowledgements.md`, then the release-candidate question) | Step 08, Step 09, Step 10, Step 11 |
| **7** — Release for Testing (the release candidate that passes ships as it is) | Step 12 |

---

## ALL ALONG — Continuous Discipline

*Not a phase — runs underneath all four, every step, from Step 1 to 7.*

Each one keeps its non-negotiables in the runbook and points at the shared
**Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`, cited as **Ops §**) for the
procedure — fetched at Step 1 alongside the Standards Guide.

- `ChangeLog.md` — one log for deviations, root causes, and testing feedback (no separate
  Testing Feedback Log or Roadmap in Lite)
- Project Progress Tracker — `ProjectProgress.md` in the project root: the step table and, beneath
  it, the usage table (one row per model per step, written at every step boundary — Operating
  Rule 9)
- Packaging & Versioning — `0.0.0.1` start, Revision incremented before every build, never two
  builds at one version, release candidate `1.0.0.0` at Step 6, the tested package ships as it is
- **OCPF AL Development Standards Guide** — fetched at Step 1, cited as **Standards §** throughout
- **OCPF Operations Guide** — fetched at Step 1, cited as **Ops §**: the procedures both editions share
- Repository Hygiene — `ocpfFramework/state/` and every fetched folder always ignored; `ocpfFramework/` as a whole, the runbook, and the sub-agent definitions with Step 1's *Yes*, verified with `git check-ignore`
- AL MCP Server — needed from the end of Step 1; set up by the agent, the human only approves
- Analyzers — CodeCop, UICop, and PerTenantExtensionCop *or* AppSourceCop, engaged on every mandatory compile
- Symbols — downloaded by the agent, never the human
- Keeping the Editor in Sync — stale red marks detected and refreshed
- Notifications — Claude app, sound, and/or desktop notification, chosen at intake and remembered, whenever the agent finishes a turn, asks a question, or waits for an approval
- Reference Sources — the downloaded symbols are the only routine lookup; Microsoft Learn's Base App and System App only when symbols are missing, don't cover it, or a pattern or event signature is needed; translation and country/language pages; AL Guidelines
- Tooling Checks — Node, mermaid-cli, PowerShell 7 (Ops § Tooling Checks; never `which mmdc`)
- BCQuality Knowledge Snapshot
- OCPF BC AL Patterns Library
- Translations & Terminology — glossary in `DesignDoc.md`, named reviewers, release gate on approved translations
- Permission Sets discipline
- OCPF Plugin (optional) — update check, Standards Guide fallback, zero-install AL tool setup, the generator sub-agent for parallel batches, the `usage` skill at every step boundary

---

## Document Set

Four tracked files, start to finish, all in `docs/` by phase: `docs/2-design/DesignDoc.md`,
`docs/0-project/ChangeLog.md`, `docs/4-prove/Docs.md`, `docs/4-prove/TestScript.md` (translated
copies beside their source).

Plus `ProjectProgress.md` in the project root (the step table and the usage table, refreshed at
every step boundary); two Step 1 setup artifacts, produced once at kickoff rather than maintained
throughout: `docs/1-define/ProblemStatement.md` and `docs/1-define/ProjectParameters.md` (the
persisted intake sheet every later step reads from — including the Main model and thinking
effort, the version, and the app icon); two estimates from Step 2: `docs/2-design/HumanEffortEstimate.md`
(the hours a senior AL developer would bill, from the baselines file) and
`docs/2-design/AiEffortEstimate.md` (tokens, cost, and wall-clock the routine itself is expected to
take); and `docs/0-project/Acknowledgements.md` from Step 6. Only `requirements/`, `app.json`,
`src/`, `Translations/`, `outputAppPackage/`, `ProjectProgress.md`, and `ocpfFramework/` stay in
the project root.

Plus two fetched, gitignored companions, both shared unchanged with the full framework, under
`ocpfFramework/`: `standardsGuide/ocpfALDevStandardsGuide.md` (the AL rules, **Standards §**) and
`opsGuide/ocpfOperationsGuide.md` (the procedures, **Ops §**). **Lite reduces process, not AL
rules:** the same rules apply to a 5-file extension as to a 50-file one, and both editions run the
same procedures.

## When to Graduate to the Full Framework

- Object count grows past ~10 AL files.
- The project needs separate sign-off roles (Dev Manager / Technical Lead / Functional
  Consultant as distinct people).
- You want to split work across more than one AI model (Main/Light/Reasoning).
- The extension is heading to AppSource.

Nothing is lost switching later — `DesignDoc.md` maps onto the full framework's TDD, and
`ChangeLog.md` carries straight over.

---
