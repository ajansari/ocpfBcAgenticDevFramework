> **Template** for `docs/4-prove/Documentation.md` on the Build-a-Feature journey — OCPF BC Agentic Development Framework, written at the close (Ops § Build-a-Feature → *The record*) from the code just written — one to two minutes, no research. A lighter sibling of Full's `Documentation.md`. Keep every heading; replace every `<placeholder>`; a section that doesn't apply keeps its heading with *N/A — reason* beneath it; delete this note. A later session appends its objects.

# <Extension Name> — Documentation

**Version:** <app.json version> · **Updated:** <date> · **Journey:** Build-a-Feature

## 1. What this extension does
<Two or three sentences, from the intake answers: what was asked for and why.>

## 2. Objects
One short section per object, in build order. Say what it holds, what it shows, or what it does — the way a consultant would explain it, not the way the compiler sees it.

### 2.<n> <Type> <ID> "<Name>"
- **Purpose:** <one sentence>
- **Fields / columns / values:** <the list, one line each: name — type — meaning; for a page, which fields and where; for an enum, the values>
- **Relates to:** <tables it links to, pages that show it, APIs that expose it>
- **File:** `src/<…>`

## 3. How the objects fit together
<Four lines at most: the table, the pages that show it, the API that exposes it, the permission sets that grant it. Point at the schema diagram in `docs/1-define/FeatureRegister.md` rather than redrawing it.>

## 4. API endpoints
*N/A — no API object* or one row per API page or query.
| Entity set | Route | Read / read-write | Source |
|---|---|---|---|
| <entitySetName> | `/api/<publisher>/<group>/<version>/companies({id})/<entitySetName>` | <…> | <table> |

## 5. Permissions
<Which permission sets grant what, and the base BC sets a user also needs (Standards §5.3), or *N/A — no permission set yet; every user needs SUPER*.>

## 6. How to use it
<For the person in BC: where the page is (search name), what to do, what a refusal means. Three to six lines.>
