> **Template** for `docs/4-prove/HumanUnitTestScript.md` — OCPF BC Agentic Development Framework, written at Full Step 11; executed by humans at Step 12. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Human Unit Test Script — <Extension Name>

**Version under test:** <app.json version> · **Package:** `outputAppPackage/<file>.app` · **Environment:** <sandbox name> · **Date:** <date>
**Written for:** a tester who is not a developer. Every step says what to click and what must appear.

## 1. Setup
| # | Precondition | How to check |
|---|---|---|

## 2. Test cases — green team (it works)
### TC-<n> <Title>
**Covers:** FRD §<x> · **Language:** <en-US / each required language>
| Step | Action | Expected result | Pass / Fail | Notes |
|---|---|---|---|---|
| 1 | | | | |

## 3. Test cases — red team (it fails safely)
### TC-<n> <Title>
**Covers:** <validation, permission, deletion behaviour, error message>
| Step | Action | Expected result | Pass / Fail | Notes |
|---|---|---|---|---|

## 4. Language pass
For each required language: the terms the tester should see on each page (from the glossary). Testers who read English run this from here; a translated copy of this script exists only if Parameters §1.9 asked for one.
| Page | Term (W1) | Expected in <language> |
|---|---|---|

## 5. Results
Recorded in `docs/4-prove/ReleaseTestResults.md` at Step 12, not here.

## Before calling this done
- [ ] Every FRD requirement is covered by at least one TC.
- [ ] Every permission set, every deletion rule, and every error message has a red-team TC.
- [ ] Every parent→child entry point (each part and each action) has a green-team TC that creates a child and confirms it stays visible with the link filled (Standards §11.3).
- [ ] Every number-series field has a green-team TC that opens its dropdown, picks a series, and numbers the first two records (Standards §11.3).
- [ ] A non-developer can run every step without asking a developer.
