> **Template** for `docs/4-prove/ReleaseTestResults.md` — OCPF BC Agentic Development Framework, written at Full Step 12. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Release Test Results — <Extension Name>

**Version tested:** <app.json version> · **Package:** `outputAppPackage/<file>.app` · **Environment:** <sandbox> · **Script:** `docs/4-prove/HumanUnitTestScript.md` v<n>

## 1. Review
| Reviewer (Dev Manager) | Date | Overall result | Notes |
|---|---|---|---|

## 2. Results by test case
| TC | Title | Language | Tester | Date | Result | ChangeLog issue (if failed) |
|---|---|---|---|---|---|---|

## 3. Upgrade path
Standards §9.6. Required unless this is the extension's first release; a failed upgrade path fails the step.
| Previous version installed | Data verified after upgrade | No-op re-run clean | Fresh install clean | Result | Tester | Date |
|---|---|---|---|---|---|---|

## 4. Language passes and translation state scan
| Language | Units | Approved (signed-off / final) | Reviewer (approval) | Tester (language pass) | Result | Notes |
|---|---|---|---|---|---|---|

## 5. Feedback received
Verbatim entries go to `docs/0-project/TestingFeedback.md`; this table links them.
| Feedback entry | Triage (implement / roadmap / reject) | ChangeLog / Roadmap ref |
|---|---|---|

## 6. Release decision
| Decision | By | Date | Package that ships |
|---|---|---|---|

## Before calling this done
- [ ] Every TC has a result; every failure has an issue.
- [ ] The package that passed is named exactly and is the one Step 12 releases.
- [ ] The upgrade path passed, or the document states this is the first release.
- [ ] Every language required at first release shows all units approved, with the reviewer named.
