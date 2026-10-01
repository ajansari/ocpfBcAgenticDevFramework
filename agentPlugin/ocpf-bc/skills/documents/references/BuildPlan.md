> **Template** for `docs/3-build/BuildPlan.md` — OCPF BC Agentic Development Framework, written at Full Step 05. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Build Plan — <Extension Name>

**Date:** <date> · **From:** `docs/2-design/TDD.md` v<n> §3 · **Approved by:** <name>, <date> (one approval for the whole plan, Operating Rule 6)
**Approval mode:** whole plan once / ask before each batch — <which>

## 1. Scaffold
| Item | Value |
|---|---|
| `app.json` | written at Step 01 §1.10 — confirmed current |
| Analyzers (`.vscode/settings.json`) | CodeCop, UICop, + <PerTenantExtensionCop or AppSourceCop> |
| `ocpfFramework/scripts/` | `al-analyze.*`, launchers as needed |
| `.gitignore` | Ops § Repository Hygiene block present and verified |
| BCQuality snapshot / patterns library | fetched — <sha, date> |

## 2. Batches
Smallest and simplest first. A batch is independently correct; the whole extension compiles once at Step 07.
| Batch | Module(s) | Objects (ID — type — name) | Permission grants introduced | Depends on | Pre-flight owner |
|---|---|---|---|---|---|
| B1 | | | | — | Light role |

## 3. Pre-flight checklist applied to every batch
Copied from `ocpfFramework/runbookSteps/05.md`, both passes; ticked per batch in the ChangeLog entry that closes the batch.
- [ ] <check>

## 4. Deviations expected
Anything already known to differ from the TDD, with its ChangeLog issue.
| Deviation | ChangeLog issue |
|---|---|

## Before calling this done
- [ ] Every Object Register entry is in exactly one batch.
- [ ] Every table's `tabledata` grant ships in the batch that introduces the table.
- [ ] The approval is recorded by name and date.
