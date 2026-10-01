> **Template** for `docs/4-prove/CodeReview.md` — OCPF BC Agentic Development Framework, written at Full Step 09. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Code Review — <Extension Name>

**Date:** <date> · **Reviewer:** <reasoning role, model / github.com reviewer agent> · **Fixes applied by:** <main role / person>
**Reviewed:** every AL file at commit <sha> against `docs/2-design/TDD.md` v<n>, Standards Parts 1, 2, 4, 7, 11, AL Guidelines *Best Practices* and *Vibe Coding Rules*, and the BCQuality snapshot <sha>.

## 0. Scorecard
The reasoning role grades, the main role records. One grade per dimension with one line of evidence; **Overall** is the lowest grade of the eight, stated as such.
| Dimension | Grade | Evidence |
|---|---|---|
| Standards compliance — Standards Guide adherence, Part 7 anti-patterns | | |
| Correctness and robustness — validation, TestField and error handling, edge cases, Part 11 client-page rules | | |
| Readability and maintainability — naming, structure, consistency across batches, dead code | | |
| Performance — SetLoadFields, keys and SIFT, record loops, FlowFields, repeated lookups | | |
| Security and permissions — permission set coverage, Access, API data exposure, secrets | | |
| Upgrade safety — obsolete references, upgrade codeunits and tags, schema changes needing Force Sync | | |
| Translation readiness — labels with comments, no hard-coded text, glossary consistency, truncation risk | | |
| Test coverage — AL test codeunits present and meaningful, human test script coverage | | |
| **Overall** (the lowest grade above) | | |

Rubric:
| Grade | Meaning |
|---|---|
| **A** | no findings |
| **B** | minor findings only |
| **C** | at least one major, fixed in this step |
| **D** | several majors, or one critical, fixed in this step |
| **F** | a critical left unresolved or accepted |

## 1. Findings by dimension
Dimensions from `ocpfFramework/runbookSteps/09.md`. One row per finding; severity **Critical / Major / Minor / Note**.
| # | Dimension | File / object | Finding | Rule (Standards § / guideline) | Severity | Resolution | ChangeLog ref |
|---|---|---|---|---|---|---|---|

## 2. Dead-code and obsolete-reference scan
Standards §1.5 — 100 % of files.
| File | Result | Notes |
|---|---|---|

## 3. Fix batch presented for approval
All code-touching findings together, one decision (design-rule changes asked separately).
| Findings | Approved by | Date | Recompiled / repackaged / retested |
|---|---|---|---|

## 4. Pattern candidates
Findings that repeat across batches and look generalizable — flagged to the human for the OCPF BC AL Patterns Library, never added unilaterally.
| Pattern | Where it recurred | Flagged to |
|---|---|---|

## 5. Conflicts surfaced
Where the Standards Guide and AL Guidelines or BCQuality disagree — surfaced, not silently resolved.
| Conflict | Sources | Decision | Decided by |
|---|---|---|---|

## Before calling this done
- [ ] Every dimension in §0 is graded with evidence, and Overall is the lowest of the eight.
- [ ] Every Critical and Major finding is resolved or explicitly accepted by name.
- [ ] §2 shows every file clean.
- [ ] Every code fix went through the Step 07 cycle; still 0 errors / 0 warnings.
