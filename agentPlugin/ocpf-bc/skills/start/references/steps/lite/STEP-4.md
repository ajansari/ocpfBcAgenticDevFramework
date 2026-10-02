# BC App Build Routine — STEP 4 — Generate the Code

**Runbook version:** 5.1.0.0 · Lite edition · Phase: BUILD

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** `docs/2-design/DesignDoc.md`, `docs/1-define/ProjectParameters.md`, symbol file, batch plan (IDs and
file names fixed), pre-flight checklist, the generation mode chosen at Step 3.

**Which mode** (Step 3's answer; **Ops § Roles → *Parallel batches* and *Generation speed***):
- **Parallel — two batches, and the human chose it.** Start one **background** `ocpf-generator`
  sub-agent per batch — the project-local copy the `roles` skill wrote, on the Main model and
  effort (Lite's only sub-agent; the plugin bundles it). Each brief carries: Action 4 below,
  verbatim; the batch's Design Doc sections; `docs/1-define/ProjectParameters.md`; Standards
  §1.1–§1.8 and §2 (plus Part 11 and the matching `ocpfFramework/patterns/` files when the batch
  has a child list, setup page, or wizard); and the symbol source. A generator writes its batch's
  AL files under `src/` and nothing else — never `docs/0-project/ChangeLog.md`, the Object
  Register, the Design Doc, or another batch's files — and reports deviations and open questions.
  Its report opens with the model it ran on; compare that against `docs/1-define/ProjectParameters.md`
  before using anything from it. **Lite has no light role: as each generator returns, this agent
  runs the post-generation pre-flight (Action 5) on that whole batch itself** while the other
  generator continues, then integrates — Object Register, a ChangeLog entry per deviation, the
  open questions to the human — and commits the batch. Both batches are disjoint by construction,
  so nothing conflicts. If the harness can't run parallel sub-agents (Copilot CLI, a cloud agent),
  fall back to one batch at a time and say so. Permission prompts from a background sub-agent
  still surface in the main Claude Code session.
- **One batch at a time, or ask before each** — the per-object loop below, run by this agent,
  with the pause the human chose before the second batch.

**Speed rules, in every mode:** generation runs at the Main model's recorded effort — Medium by
default, never raised for generation; one complete file per Write call, never incremental edits to
a file being created; no narration between files — one summary per batch; the brief (or this step
file) carries the exact template text, so no guide is re-read per file; symbols are verified once
per batch in the post-generation pass, not per file during generation; with Opus as Main in Claude
Code, offer fast mode (`/fast` — up to 2.5× faster at a higher per-token price, Opus only) once,
with the cost stated.

**Actions — per object, in order:**
1. **Approval came at Step 3** — don't ask again per object. With two batches, pause before the
   second only if the human chose that. Stop and ask on any pre-flight failure the Design Doc
   can't resolve, or any deviation from `docs/2-design/DesignDoc.md`.
2. Extract source-table and field data for this object from the symbol file.
3. Run the pre-generation pre-flight pass; fix the Design Doc before generating if anything fails.
4. Generate the AL file **from the standard template in Standards §1.3**, substituting only Step 1
   parameter values: one `namespace` (omitted entirely if `Use Namespace` = `No`), one `using`
   (from the symbol file), `ODataKeyFields = SystemId`, exactly one of `DelayedInsert = true` /
   `Editable = false`, `Caption` + `ToolTip` + `ApplicationArea = All` on every field. No dead
   code, no empty triggers, no commented-out fields, no `// TODO` (**Standards §1.1–§1.5**).
   Write `Caption` and `ToolTip` as self-describing schema for API consumers, not UI filler — they
   flow into OData `$metadata` and are what a developer or AI agent reads when discovering the
   endpoint (**Standards §2.5–§2.6**). Single-language label syntax only — never `CaptionML`,
   `ToolTipML`, any other ML property, or `TextConst` (**Standards §1.7**). Messages as `Label`s
   (**§8.3**), W1 source wording from the glossary, API caption locking per Step 2 (**§8.6**).
   **Source text only** — no translation file is touched until Step 5.
   **Client pages have their own rules (Standards Part 11), applied while writing:** every child
   list or list part gets the six elements of **§11.1** (property link, hidden link control,
   two-group `OnNewRecord` read, `TestField` in the table's `OnInsert`, `DelayedInsert = true`, no
   `Init()` after seeding); every number-series field gets `TableRelation = "No. Series"` on the
   setup table with the wizard bound to a temporary copy of it, and numbering uses codeunit
   `"No. Series"` (**§11.2**). Read the matching `ocpfFramework/patterns/` files first (Step 3).
5. Run the post-generation pre-flight pass immediately on this file — in parallel mode, on the
   whole batch the moment its generator returns — including the §11.1 and §11.2 checks for any
   child list, list part, setup page, or wizard. **Do not invoke the AL compiler** (Operating
   Rule 4).
6. Don't move to the next object until this one's pre-flight, including symbol verification, is
   clean (parallel mode: don't integrate a batch until its pass is clean).
- **Before moving past this step, verify permission-set coverage explicitly** across every table
  generated (**Standards §5.3**; vacuously satisfied if the extension owns no tables).

**Outputs:** Every AL file under `src/`, lint-clean including symbol verification; ChangeLog entries for any
deviation from `docs/2-design/DesignDoc.md` (a generator's reported deviations included). The extension is **not** compiled yet.

**Exit gate:** Every planned object generated and pre-flight-clean; in parallel mode, every
generator's report integrated and its model line checked; permission-set coverage
verified. A clean compile is not required to close this gate — Step 4 hands off directly into
Step 5's mandatory compile-and-package. This step's usage rows, one per model, are written before this message (Operating Rule 9).

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, end the closing message with the options box: **Proceed into Step 5 now (recommended)** / **Stop here** (say what there is to review and how to resume). Nothing of Step 5 starts until the human answers.
