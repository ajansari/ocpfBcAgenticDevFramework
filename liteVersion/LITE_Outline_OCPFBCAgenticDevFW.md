# OnlyCopilotFans BC Agentic Development Framework — Lite Outline

*A one-page map of the Lite routine (10 AL files or fewer). For the full routine, see
`LITE_BC_App_Build_Routine_Agent.md`; for the AL rules it applies, see the shared
`standardsGuide/ocpfALDevStandardsGuide.md`. For larger projects, use the full framework's
`Outline_OCPFBCAgenticDevFW.md` and `BC_App_Build_Routine_Agent.md` instead.*

---

## I. DEFINE

*Turn a business need into a validated scope and a filled-in parameter sheet — before any design
work.*

| Step | Merges (full framework) |
|---|---|
| **1** — Define the Problem & Lock Parameters | PRE-01, PRE-02, Step 01 |

## II. DESIGN

*One self-sufficient Design Doc (FRD + TDD in one), self-checked, before any code.*

| Step | Merges (full framework) |
|---|---|
| **2** — Write the Design Doc & Self-Check | Step 02, Step 03, Step 04 |

## III. BUILD

*Generate AL, lint clean including symbol verification, then one mandatory compile-and-package
that becomes a continuous fix loop.*

| Step | Merges (full framework) |
|---|---|
| **3** — Plan & Scaffold | Step 05 |
| **4** — Generate the Code | Step 06 |
| **5** — Compile, Package, Test & Iterate | Step 07 |

## IV. PROVE

*Prove the built code matches the Design Doc — reviewed, documented, and passed a human-run
release test.*

| Step | Merges (full framework) |
|---|---|
| **6** — Review, Gap-Check & Finalize Docs | Step 08, Step 09, Step 10, Step 11 |
| **7** — Release for Testing | Step 12 |

---

## ALL ALONG — Continuous Discipline

*Not a phase — runs underneath all four, every step, from Step 1 to 7.*

- `ChangeLog.md` — one log for deviations, root causes, and testing feedback (no separate
  Testing Feedback Log or Roadmap in Lite)
- Packaging & Versioning
- Repository Hygiene
- **OCPF AL Development Standards Guide** — fetched at Step 1, cited as **Standards §** throughout
- AL MCP Server (optional)
- Reference Sources — Microsoft Learn (BC Base App, BC System App, translation files) and AL Guidelines
- BCQuality Knowledge Snapshot
- OCPF BC AL Patterns Library
- Permission Sets discipline

---

## Document Set

Four tracked files, start to finish: `DesignDoc.md`, `ChangeLog.md`, `Docs.md`, `TestScript.md`.

Plus two Step 1 setup artifacts, produced once at kickoff rather than maintained throughout:
`ProblemStatement.md` and `ProjectParameters.md` (project root — the persisted intake sheet every
later step reads from).

Plus one fetched, gitignored reference: `standardsGuide/ocpfALDevStandardsGuide.md` — shared
unchanged with the full framework. **Lite reduces process, not AL rules:** the same rules apply to
a 5-file extension as to a 50-file one.

## When to Graduate to the Full Framework

- Object count grows past ~10 AL files.
- The project needs separate sign-off roles (Dev Manager / Technical Lead / Functional
  Consultant as distinct people).
- You want to split work across more than one AI model (Main/Light/Reasoning).
- The extension is heading to AppSource.

Nothing is lost switching later — `DesignDoc.md` maps onto the full framework's TDD, and
`ChangeLog.md` carries straight over.

---
