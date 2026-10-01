> **Template** for `docs/4-prove/Docs.md — Lite edition (and translated copies of the user-guide section)` — OCPF BC Agentic Development Framework, written at Lite Step 6. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# <Extension Name> — Documentation

**Version:** <app.json version> · **Date:** <date>

## 1. Technical reference
### 1.1 Objects
| ID | Type | Name | Purpose |
|---|---|---|---|
### 1.2 API reference (one per API page/query: route, source table, R / RW, fields)
### 1.3 Permission sets
### 1.4 Events, setup, upgrade notes

## 2. User guide
<For the users named in Part A of the Design Doc — plain language, BC terminology of the target language.>
### 2.1 Before you start
### 2.2 Getting there
### 2.3 Tasks (one section per task, numbered steps)
### 2.4 Messages you may see

## 3. Deployment
| Item | Value |
|---|---|
| Package (the one that passed Step 7) | |
| Schema Sync Mode | |
| Steps (Extension Management) | |
| After deploying (permission sets, setup, smoke test) | |
| Rollback | |

## Before calling this done
- [ ] Every object in the register is in §1.
- [ ] Every user task is in §2 with numbered steps.
- [ ] §3 names the exact package that passed.
