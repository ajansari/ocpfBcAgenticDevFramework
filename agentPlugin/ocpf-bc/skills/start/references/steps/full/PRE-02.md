# BC App Build Routine — PRE-02 — Structured Gap Analysis

**Runbook version:** 5.0.0.0 · Full edition · Phase: DEFINE

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** `docs/1-define/ProblemStatement.md` and the initial entity list.

**Actions:** Run the gap analysis checklist against standard BC modules (Standards Part 6). For every transactional entity, check each category:
- **Analytical detail tables** — sub-ledgers, detailed ledger entries, value entries, registers, audit trails (Standards §6.1).
- **Posted / archived versions** — the posted equivalent of every open document, header *and* lines (Standards §6.2).
- **Reference / lookup tables** — payment terms/methods, currencies, countries, UoM, locations, shipment methods, item categories, salesperson/purchaser codes (Standards §6.3).
- **Secondary document types** — quotes, blanket orders, return orders alongside orders (Standards §6.4).
- **Modern vs. legacy tables** — replace legacy price tables etc. with current equivalents; use modern entity names (Standards §6.5).
- **Tax framework tables** — decide per the target localization; do not assume (Standards §6.6).
- **Global vs. localized scope** — mark each entity as global or jurisdiction-specific.
- **Regional terminology** — for every standard BC concept the extension will name in captions or messages, note whether its wording differs across the countries named in `docs/1-define/ProblemStatement.md` (for example VAT / GST / Tax; Credit Memo / CR/Adj Note; County / State — Microsoft's actual US and Australian terms). Don't resolve the terms here — list them; Step 01 §1.9 creates the translation glossary and Standards Appendix D verifies each term.

**Outputs:** Expanded, de-duplicated entity list with each entity tagged (analytical / master / setup / document / posted / lookup), R/W intent noted, and global-vs-localized noted. Gap log: what was added and why.

**Exit gate:** Technical Lead reviews the expanded list; all gaps are closed or explicitly deferred with reasoning (Stage↔Step Map, Stage 2). When **Approvers** is one person, this is one sign-off covering `docs/1-define/ProblemStatement.md` and the expanded list together (PRE-01's deferred sign-off included). This step's usage rows, one per model, are written before this message (Operating Rule 11).
