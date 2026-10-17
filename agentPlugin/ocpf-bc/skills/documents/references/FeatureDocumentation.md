> **Template** for `docs/Documentation.md` on the Build-a-Feature journey — OCPF BC Agentic Development Framework (Ops § Build-a-Feature → *The record*). On a Full or Lite project its sections are appended under a `## Build-a-Feature` heading in the project's existing `docs/4-prove/Documentation.md` (Full) or `docs/4-prove/Docs.md` (Lite). **Written as each object compiles, not at the close** — one section per object, then the parts that span objects when the plan is done. This is the document a consultant, a tester, or the next developer opens to learn what the extension does and how to use it: **documentation only** — no parameters, no object register, no usage figures, no decisions log (those are `docs/FeatureRegister.md`), no field-by-field schema (that is `docs/DataModel.md`; cite it). It is short because the extension is small, not because the sections are thin: every section is written in full sentences a non-developer can follow. Keep every heading; replace every `<placeholder>`; a section that doesn't apply keeps its heading with *N/A — reason* beneath it; delete this note. A later session appends its objects and updates §1, §4, and §6.

# <Extension Name> — Documentation

**Version:** <app.json version> · **Updated:** <date> · **Publisher:** <publisher> · **Journey:** Build-a-Feature · **Data model:** `docs/DataModel.md`

## 1. What this extension does
<One paragraph, in business language, from the intake: who asked for it, what problem it solves, what a user can now do in Business Central that they could not before. Then one sentence per object group (the table and its pages; the extension of the Customer Card; the report; the API) saying what each adds. Close with what is deliberately **not** here — the things the human said were out of scope or that the journey offered and they declined.>

## 2. How to use it, step by step
<Written for the person in Business Central, in the order they would do things. One numbered walk-through per thing a user does — for example:*
1. *Open **Rental Units** (search for "Rental Units" with the magnifier, or from the Role Center's <action>).*
2. *Choose **New**. A number is assigned from the series set up in **Rental Setup**; if no series is set up yet, the card says so — open **Rental Setup** first and pick one.*
3. *Fill in **Description**, **Customer No.** (pick from the list), **Start Date**, and **Amount**. **Status** starts as *Open*.*
4. *…*
*Name every page and action exactly as it appears on screen. Say what each error message means and what to do about it. Three to ten steps per walk-through; as many walk-throughs as there are things to do.>

## 3. The objects, one by one
One section per object, in build order. Say what it holds, shows, or does — the way a consultant would explain it, not the way the compiler sees it. Field lists belong in `docs/DataModel.md`; here, name only the fields a user needs to understand.

### 3.<n> <Type> <ID> "<Name>"
- **What it is for:** <two or three sentences — the business purpose and when a user meets it>
- **What a user sees or does:** <for a page: where it opens from, what is on it, which actions it has and what each does; for a report: what it lists, which filters the request page offers, what the layout looks like; for an API: who calls it and for what; for an enum: what the values mean in business terms; for a codeunit: what triggers it and what it changes; for a permission set: who should get it>
- **Rules it enforces:** <validations, defaults, what cannot be deleted and why, what happens on status change — or *none beyond the data types*>
- **Connected to:** <the tables it reads or writes, the pages that open it or that it opens, the API that exposes it, the permission sets that grant it — by name>
- **File:** `src/<…>`

## 4. How the objects fit together
<Four to eight sentences: the flow of data and of a user's work across the objects — "a rental unit is created on the card, listed on the list, exposed read-only through the API for the billing system, and protected by the two permission sets". Point at `docs/DataModel.md` §1 for the diagram rather than redrawing it.>

## 5. API endpoints
*N/A — no API object* **or** one row per API page or query, then a worked example.
| Entity set | Route | Read / read-write | Source table | Key fields |
|---|---|---|---|---|
| <entitySetName> | `/api/<publisher>/<group>/<version>/companies({id})/<entitySetName>` | <…> | <table> | <id, number> |

**Example — read one record:**
```
GET https://api.businesscentral.dynamics.com/v2.0/<tenant>/<environment>/api/<publisher>/<group>/<version>/companies(<companyId>)/<entitySetName>(<SystemId>)
```
<One sentence on authentication (the standard BC OAuth flow), one on the company segment, and — for a read-write endpoint — a minimal POST body with the required fields.>

## 6. Permissions and setup
- **Permission sets:** <which set grants what, who should receive each, and the standard BC sets a user also needs (Standards §5.3) — or *N/A — no permission set yet; every user needs SUPER*>
- **Setup before first use:** <the setup page and the fields to fill, number series to create, defaults to review — or *none*>
- **Translations:** <source language only; the `.g.xlf` is generated at build for whoever adds languages later>

## 7. Known limitations and next steps
<What this quick mod does not do that a full solution would — posting, documents, a wizard, a role center, reports — and what the natural next objects are. One line each. This is what makes the extension a foundation a later Full or Lite project can take over.>
