> **Template** for `docs/2-design/SanityCheck.md` — OCPF BC Agentic Development Framework, written at Full Step 04. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Sanity Check and Validation — <Extension Name>

**Date:** <date> · **Reviewer:** <reasoning role, model> · **Resolved by:** <main role / person> · **Sign-off:** Technical Lead — <name>, <date or pending>
**Reviewed:** `docs/2-design/FRD.md` v<n>, `docs/2-design/TDD.md` v<n>, symbol file <version>.

## A. Can BC do everything the FRD asks?
| # | FRD requirement | Platform capability relied on | Verified how | Finding | Resolution |
|---|---|---|---|---|---|

## B. Does the TDD fully and correctly implement the FRD?
The canonical checklist is in `ocpfFramework/runbookSteps/04.md`; every item gets a row, a finding, and a resolution.
| # | Check | Finding (pass / issue) | Evidence | Resolution | Blocking? |
|---|---|---|---|---|---|
| 1 | Every FRD entity maps to ≥ 1 TDD object | | | | |
| 2 | Every TDD object has a valid ID inside an allocated range | | | | |
| 3 | Every source table number verified against the symbol file | | | | |
| 4 | Every field complies with Localization and Standards Part 3 | | | | |
| 5 | Every obsolete / pending field excluded | | | | |
| 6 | Every `using` namespace sourced from the symbol file | | | | |
| 7 | `const()` quoting correct on every filtered page | | | | |
| 8 | Entity, field, APIPublisher, APIGroup names ≤ 30 and camelCase | | | | |
| 9 | R / RW designations match Standards §2.2 | | | | |
| 10 | Growth buffers planned per module block | | | | |
| 11 | Permission sets planned, grants enumerated, names ≤ 20 | | | | |
| 12 | Every target language supported by BC, reviewer named, terminology source named | | | | |
| 13 | Every PRE-02 regional term in the glossary, verified or flagged | | | | |
| 14 | Every API page/query has a group and caption-locking decision with a decider | | | | |
| 15 | Every message/error/confirmation is a Label with Comments on placeholders | | | | |
| 16 | Every entity's deletion behaviour explicitly decided, referencing fields re-checked | | | | |

## C. What the object structure will look like when built
<A short tree or table: modules → objects → IDs, so the reviewer can picture the result.>

## D. Findings summary
| Severity | Count | Open |
|---|---|---|
| Blocking | | |
| Should fix before BUILD | | |
| Note | | |

## Before calling this step done
- [ ] Every row in B has a finding and, where not a pass, a resolution recorded in the TDD or FRD.
- [ ] 0 blocking issues open.
- [ ] Every change made here is in `docs/0-project/ChangeLog.md` with who decided.
