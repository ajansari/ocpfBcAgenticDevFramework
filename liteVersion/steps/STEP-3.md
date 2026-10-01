# BC App Build Routine — STEP 3 — Plan & Scaffold

**Runbook version:** 5.0.0.0 · Lite edition · Phase: BUILD

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** `docs/2-design/DesignDoc.md`, Object Register.

**Actions:**
- Confirm the batch plan from Operating Rule 3 (one batch, or two on a natural split) and object
  order within it (lookups before the things that reference them). **Every object's ID and file
  name is fixed in the plan (the Object Register) before anything is generated** — that's what
  makes two batches disjoint. **This is the one approval to generate code** (Rule 6). With two
  batches, ask once (Rule 6a; Ops § Roles → *Parallel batches*): **Generate both batches in
  parallel — one generator per batch, all at once (recommended when the tool runs sub-agents)** /
  **One batch at a time** / **Ask me before each batch**. Either run-through still stops by itself
  on any pre-flight failure or Design Doc deviation. Record the answer in
  `docs/0-project/ChangeLog.md`.
- Prepare the scaffold: confirm `app.json` (written at the end of Step 1) still matches
  `docs/1-define/ProjectParameters.md` — name, publisher, ID ranges, runtime, BC dependency,
  `"features": ["NoImplicitWith", "TranslationFile"]` (**Standards §8.2**) — then `launch.json`,
  the `src/` folder structure (subfolders per module if useful; nothing in the root), a
  `Translations/` folder, `.gitignore` per Step 1 and Ops § Repository Hygiene (both blocks
  present and proven), and the analyzer files: `.vscode/settings.json` with the analyzers for the
  Deployment Target, plus `AppSourceCop.json` for AppSource (ALL ALONG → Analyzers). Outside GitHub
  Copilot Chat, confirm `ocpfFramework/scripts/al-analyze.*` is present, and copy or fetch it if not. If
  `app.json` has to change, follow ALL ALONG → Keeping the Editor in Sync.
- **Agree the translation tooling** (skip if *US wording, no translation files*). Recommend the
  XLIFF Sync PowerShell module (`XliffSync`) for the agent, plus the XLIFF Sync VS Code extension
  for reviewers. Offer NAB AL Tools as the alternative. The module needs PowerShell 7 (`pwsh`):
  check it and, if missing, offer the per-OS install exactly as **Ops § Tooling Checks** says
  (Rule 6b), and record the outcome in `ocpfFramework/framework.json` → `"tooling"`. Look for
  existing installations first, and ask before installing anything.
- Bootstrap the BCQuality knowledge snapshot and the OCPF BC AL Patterns library (both ALL
  ALONG) — one-time-per-project setup, cheapest done now alongside the rest of the scaffold. (The
  Standards Guide, the AL tools, and symbols are **not** in this group: Step 1 already set them
  up, since DEFINE and DESIGN need them. Confirm `ocpfFramework/standardsGuide/` is present and gitignored, the
  AL tools respond, and `.alpackages/` holds the target version's symbols, rather than redoing
  any of it.)
- **Read the patterns library before writing, not only after breaking.** For every child list or
  list part, setup page, or wizard in the plan, Step 4 reads **Standards Part 11** and the matching
  `ocpfFramework/patterns/` files (child lists and list parts: `Pattern-SubPageLink-FilterGroup4.md`; setup
  pages and wizards: `Pattern-NoSeries-Setup-Field-And-Numbering.md`; several inserts from one
  variable: `Pattern-Init-Does-Not-Clear-Primary-Key.md`) before generating that object; mark
  those objects in the batch plan.
- Write the pre-flight checklist for each object — one list, run twice per object since one model
  is doing both passes:
  - **Pre-generation** (on the planned name/fields): identifier length ≤ 30, API names camelCase
    (**Standards §2.7**), reserved-keyword scan, localization field-range filter, `ObsoleteState`
    filter.
  - **Post-generation** (on the actual file): `Caption`, `ToolTip`, and `ApplicationArea = All`
    on every field (**Standards §1.4**); the file named after its object (**§1.8**); no ML
    properties and no `TextConst` (**§1.7**); translatable text — no string literal in a user-facing message, AA0074 suffixes, a `Comment`
    on every placeholder label (**§8.3–§8.4**); API caption locking matches the Step 2 decision
    (**§8.6**); `Rec.`-qualification (**§1.2**); no empty triggers, `// TODO`, or commented-out
    fields (**§1.5**); 4-space indentation, no tabs (**§1.6**); `tabledata` coverage for any table
    the object introduces (**§5.3**); permission set names from the App Code, ≤ 20 characters
    (**§5.4**); and **symbol verification** for every standard reference (**Appendix B**). The
    analyzer-enabled compile at Step 5 proves several of these again (ALL ALONG → Analyzers).

**Outputs:** Batch plan, project scaffold, the pre-flight checklist.

**Exit gate:** Batch plan approved with every ID and file name fixed (and, with two batches, the
generation mode recorded);
scaffold structurally complete, analyzer settings and (for AppSource) `AppSourceCop.json` in place per Ops § Analyzers
(not compiled — Operating Rule 4); pre-flight checklist ready. This step's usage rows, one per model, are written before this message (Operating Rule 9).
