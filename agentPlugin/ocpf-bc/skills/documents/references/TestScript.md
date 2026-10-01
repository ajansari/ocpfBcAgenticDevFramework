> **Template** for `docs/4-prove/TestScript.md — Lite edition` — OCPF BC Agentic Development Framework, written at Lite Step 6; run by humans at Step 7. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Test Script — <Extension Name>

**Version under test:** <app.json version> · **Package:** `outputAppPackage/<file>.app` · **Environment:** <sandbox>
Written for a tester who is not a developer.

## 1. Setup
| # | Precondition | How to check |
|---|---|---|

## 2. Green team — it works
### TC-<n> <Title> (covers Design Doc §A<x>)
| Step | Action | Expected result | Pass / Fail |
|---|---|---|---|

## 3. Red team — it fails safely
### TC-<n> <Title> (validation / permission / deletion / message)
| Step | Action | Expected result | Pass / Fail |
|---|---|---|---|

## 4. Language pass
| Page | Term (W1) | Expected in <language> |
|---|---|---|

## 5. Results
| TC | Tester | Date | Result | ChangeLog entry (if failed) |
|---|---|---|---|---|

## Before calling this done
- [ ] Every parent→child entry point (each part and each action) has a green-team TC: create a child, it stays visible with the link filled (Standards §11.3).
- [ ] Every number-series field has a green-team TC: dropdown opens, pick survives Finish, first two records number consecutively (Standards §11.3).
- [ ] Every requirement in Part A has a TC; every rule in Part B that a user can hit has a red-team TC.
- [ ] A non-developer can run every step.
