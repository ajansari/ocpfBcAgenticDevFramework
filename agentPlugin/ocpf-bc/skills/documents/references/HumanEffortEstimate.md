> **Template** for `docs/2-design/HumanEffortEstimate.md` — OCPF BC Agentic Development Framework, written at Full Step 03 / Lite Step 2, in the same pass as the design. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Human Effort Estimate — <Extension Name>

**Date:** <date> · **Estimated by:** <drafting role, model> · **Basis:** `docs/2-design/TDD.md` v<n> (Full) or `docs/2-design/DesignDoc.md` v<n> (Lite) · **Reviewed by:** <name>

> **What this is.** The billable hours an **experienced senior AL developer** (5+ years of Business
> Central extension work, fluent in AL, the AL tools, and the standards this project applies) would
> need to deliver the same scope by hand, working from the same requirements. It is an **estimate**
> for reading next to the measured AI cost in the usage table (`ProjectProgress.md`) and the AI
> estimate (`docs/2-design/AiEffortEstimate.md`), not a quote, not a timesheet, and not a claim
> about any particular developer. Every assumption is in §1 so the reader can change it.

## 1. Assumptions
| Assumption | Value used | Change it if |
|---|---|---|
| Developer profile | Senior AL developer, works alone, no ramp-up on BC | a team, or a developer new to BC |
| Working day | 8 billable hours | |
| Requirements | As complete as `docs/2-design/FRD.md` / `docs/2-design/DesignDoc.md`; no re-discovery | the human would also gather requirements |
| Testing | Manual sandbox testing by the developer, plus the unit tests named below | a separate QA function |
| Meetings, reviews, sign-offs | Included as *Review and sign-off* | |
| Baselines | §2's baselines (mid-point unless complexity says otherwise) | a rate card or history not yet in the calibration file |

## 2. Baselines used
**Baselines:** <framework default, `documentTemplates/HumanEffortBaselines.md` v<n> · or · partner calibration `~/.ocpf/HumanEffortBaselines.md` dated <d>>. When the calibration file exists it replaces the default table entirely, and this line says so.
The full table lives in the baselines file; reproduce here **only the rows this estimate actually used**, copied unchanged. Pick the low end for simple and the high end for complex; write the reason in §3.
| Task | Unit | Baseline (h) |
|---|---|---|
| <row used, copied from the baselines file> | | |

## 3. Estimate by task
One row per task; objects grouped by type where the same reasoning applies.
| # | Task | Object(s) / scope | Complexity and why | Hours | Framework step |
|---|---|---|---|---|---|
| 1 | Requirements | | | | 02 / Lite 2 |
| 2 | Technical design | | | | 03 / Lite 2 |
| 3 | <object type> — <IDs> | | | | 06 / Lite 4 |
| … | | | | | |
| n | Documentation set | | | | 11 / Lite 6 |

## 4. Totals
| Phase | Hours | Days (8 h) |
|---|---|---|
| DEFINE + DESIGN | | |
| BUILD | | |
| PROVE | | |
| **Total** | | |

**Sanity anchor:** the baselines file's anchor scaled to this project's object count is <n> – <m> h; this estimate is <inside / outside> 0.5× – 2× of it <— reason, when outside>.

## 5. What would move this estimate
- <e.g., the ID range Microsoft assigns for AppSource, an unresolved open question, a localization change>

## Before calling this done
- [ ] Every object in the Object Register appears in §3, alone or in a group.
- [ ] Every row's hours can be traced to a §2 baseline and a stated complexity reason.
- [ ] §2 names which baselines were used (framework default with its version, or the partner calibration file with its date) and reproduces only the rows used.
- [ ] The total is within 0.5× – 2× of the sanity anchor scaled by object count, or §4 states why not.
- [ ] §1 lists every assumption a reader would need to change to reuse this estimate.
- [ ] The step column lets the usage table sum these hours per framework step.
