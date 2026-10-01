> **Template** for `docs/4-prove/GapAnalysis.md` — OCPF BC Agentic Development Framework, written at Full Step 08. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Gap-Fit Analysis — <Extension Name>

**Date:** <date> · **Compared by:** <reasoning role, model> · **Recorded by:** <main role / person>
**Compared:** `docs/2-design/FRD.md` v<n> · `docs/2-design/TDD.md` v<n> · as-built at commit <sha> · `docs/0-project/ChangeLog.md` through <last issue>

## 1. Three-way comparison
| # | Requirement / design element | FRD | TDD | As built | Gap? |
|---|---|---|---|---|---|

## 2. Gaps
Classification per `ocpfFramework/runbookSteps/08.md`: **Intentional** (the reasoning is recorded), **Oversight** (fixed now through Steps 05–07, or scheduled in `docs/0-project/Roadmap.md`), **Spec stale** (the code is right and the FRD/TDD need updating — recorded here, applied at Step 10).
| # | Gap | Classification (Intentional / Oversight / Spec stale) | Why | Resolution (fix now / scheduled / documents updated at Step 10) | ChangeLog / Roadmap ref | Decided by |
|---|---|---|---|---|---|---|

## 3. Gap-fill work items
Built with the same discipline as main batches, from the reserved growth IDs, through Steps 05–07.
| Item | Objects / IDs | Batch | Status |
|---|---|---|---|

## 4. Unexplained divergences
None allowed at the exit gate; list anything still open with its owner.
| Divergence | Owner | Due |
|---|---|---|

## Before calling this done
- [ ] Every gap has a classification and a route.
- [ ] Every code-touching resolution went through compile, package, deploy, retest.
- [ ] §4 is empty, or every row has an owner and the human agreed to carry it.
