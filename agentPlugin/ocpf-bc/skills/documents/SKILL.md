---
name: documents
description: Write any project document of the OCPF BC Agentic Development Framework from its template - FRD, TDD, Sanity Check, Human Effort Estimate (with the Human Effort Baselines), AI Effort Estimate, Build Plan, ChangeLog, Gap Analysis, Code Review, Documentation, User Guide, Human Unit Test Script, Deployment, Release Test Results, Acknowledgements, Project Progress (both editions), and Lite's Design Doc, Docs, and Test Script. Reads the template and the step file, gathers only the named inputs, briefs the reasoning sub-agent narrowly where the step delegates, and writes the file into its docs/ phase folder. Use when a runbook step reaches a document, when the user asks to "write the FRD", "draft the TDD", "estimate the human effort", "estimate the AI cost", "create the build plan", "generate the user guide", "write the acknowledgements", or runs /ocpf-bc:documents <name>.
---

# OCPF project documents

Every document the framework produces has a template. This skill writes a document **from its
template and its step file, with only the inputs the step names** — which is what makes the
DESIGN documents fast: no structure is re-decided, no guide is read that the document doesn't
need, and nothing an upstream document already says is restated.

**Follow `Ops § Documents` in the project's Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`).
The runbook's step file (`ocpfFramework/runbookSteps/<step>.md`) says what goes in the document; the template
fixes its shape.

## Where documents live

`docs/` is laid out by phase, numbered so it sorts in routine order (Full Operating Rule 9, Lite's
header note). `ProjectProgress.md` is the one document in the project root, both editions.

| Document | Path | Written at |
|---|---|---|
| ChangeLog | `docs/0-project/ChangeLog.md` | first entry, both editions |
| ProjectMemory, Roadmap, TestingFeedback | `docs/0-project/` | Full, all along |
| Acknowledgements | `docs/0-project/Acknowledgements.md` | Full Step 11 / Lite Step 6 |
| ProblemStatement, ProjectParameters, ObjectRegister (Full), TranslationGlossary (Full) | `docs/1-define/` | Full PRE-01 – 01 / Lite Step 1 |
| FRD, TDD, SanityCheck | `docs/2-design/` | Full Steps 02, 03, 04 |
| DesignDoc | `docs/2-design/DesignDoc.md` | Lite Step 2 |
| HumanEffortEstimate, AiEffortEstimate | `docs/2-design/` | Full Step 03 / Lite Step 2, same pass as the design |
| BuildPlan | `docs/3-build/BuildPlan.md` | Full Step 05 (Lite keeps the plan in chat and the ChangeLog) |
| GapAnalysis, CodeReview, PostDevTDD | `docs/4-prove/` | Full Steps 08, 09, 10 |
| Documentation, UserGuide, HumanUnitTestScript, Deployment, AutomatedTestScripts | `docs/4-prove/` | Full Step 11 |
| ReleaseTestResults | `docs/4-prove/ReleaseTestResults.md` | Full Step 12 |
| Docs, TestScript | `docs/4-prove/` | Lite Step 6 |
| Translated copies (`UserGuide.fr-CA.md`, `Docs.fr-CA.md`, `TestScript.fr-CA.md`) | beside their source in `docs/4-prove/` | with the source |
| ProjectProgress | `ProjectProgress.md` (root) — step table and usage table | Full PRE-01 / Lite Step 1 |

`HumanEffortBaselines.md` is a template that is **read, not written into `docs/`**: it holds the
default hours for a fast US senior AL developer. There is no `UsageReport.md` any more — the usage
table is `ProjectProgress.md`'s second table in both editions (the `usage` skill writes it).

## Step 1: Which document, which step

Take the name from the invocation (`/ocpf-bc:documents TDD`) or from the step in progress
(`ProjectProgress.md`, both editions). The table above and the one in Ops § Documents map every
document to its template and its step. If the name is ambiguous, ask through the options mechanism.

## Step 2: Read only what the step names

1. **The template** — `ocpfFramework/documentTemplates/<Name>.md` in the project. If the folder is missing (a
   project started before Full v4.0.0.0 / Lite v3.0.0.0), fetch
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/documentTemplates/<Name>.md`,
   or use this skill's bundled copy in `references/`; say which.
2. **The step file** — `ocpfFramework/runbookSteps/<step>.md`, the section that describes this document.
3. **The named inputs** — the files the step's **Inputs** line lists, by path. Nothing else: not the
   core runbook, not a whole guide, not "everything in `docs/`".

Read the **Standards §** sections the template cites, by number, when the document needs them (the
TDD and Sanity Check do; the User Guide doesn't).

## Step 3: Draft

- **If the step assigns the draft to the reasoning role** (Full Steps 02, 03, 04, 08, 09): delegate
  to the project-local `ocpf-reasoning` agent on the recorded model (Operating Rule 10; Ops § Roles),
  as a background sub-agent, with the narrow brief from Ops § Documents → *Briefing a drafting
  role*: the step file, the template, the input paths, the named Standards § sections,
  `docs/1-define/ProjectParameters.md`, and the instruction to return the document text only, in the
  template's structure, plus open questions. Check the report's `Model:` line before using it.
- **Otherwise** draft it yourself, the same way.
- **Human Effort Estimate** (`HumanEffortEstimate`): produced in the same pass as the TDD (Full) or
  the Design Doc (Lite), from the object inventory just written, for a fast US senior AL developer.
  Its §2 embeds no numbers: it reads them from the baselines and says which applied —
  *framework default v<n>* from `ocpfFramework/documentTemplates/HumanEffortBaselines.md`, or
  *partner calibration file dated <d>* when `~/.ocpf/HumanEffortBaselines.md` exists (the
  partner's own table, same shape, outside every project; it replaces the default, and §1 of the
  estimate says so). Every assumption in §1, every row traceable to a baseline row. The baselines
  file's sanity anchor applies: an estimate outside 0.5× – 2× of the anchor scaled by object count
  must state why. It is read next to the measured AI cost (`usage` skill); say so in the document.
- **AI Effort Estimate** (`AiEffortEstimate`): the same pass, main role, not delegated. Inputs are
  the objects by type and complexity from the design, the batches, the languages, the recorded
  models and efforts, and the AI tool. Tokens per step × model × token type from the template's
  baselines (placeholders until calibrated); cost at the prices in `ocpfFramework/state/pricing.json`
  (fetched and dated — the `usage` skill's rules; Copilot: GitHub's per-model rates, the total
  shown in AI credits as well, and measured credits from the calibration store preferred);
  wall-clock from BUILD on, including approvals × 30 minutes, and the template's fixed sentence
  about approvals answered within 30 minutes. **Read every file in `~/.ocpf/calibration/`** (the
  `usage` skill's project-close export) and derive per-object and per-step averages and the
  throughput from them when present, saying so; the margin is ±30 % until three or more measured
  projects exist there, then ±10 % — the document names which applies.
- **Acknowledgements** (`Acknowledgements`): one row per resource actually used on this project,
  with author, license, and how it was used (the framework, BCQuality, the patterns library, the
  AL tools, XLIFF Sync or NAB AL Tools if used, mermaid-cli, the AI tool and models). Keep the
  template's closing note verbatim. Always committed.
- **Project Progress** (`ProjectProgress`): both editions, seeded at Full PRE-01 / Lite Step 1 —
  keep the step table for this edition, delete the other; the usage table follows and is the
  `usage` skill's to fill, one row per model per step.

## Step 4: Write and record

- Write to the path in the table above — always under `docs/<phase folder>/`, except
  `ProjectProgress.md` at the root. Never overwrite an existing document without saying so; a
  redraft keeps the old version's decisions unless the human changed them.
- Remove the template's own `> Template …` note. Keep every heading; mark a non-applicable section
  *N/A — reason*. No `<placeholder>` survives.
- Work the template's closing checklist and leave it ticked.
- Do the step's bookkeeping: the ChangeLog entry (naming the model that drafted a delegated
  document), `docs/0-project/ProjectMemory.md` (Full), and the sign-off request through the options
  mechanism when the step has one.

Then stop at the step's exit gate. Don't start the next step unless the human asks.
