> **Template** for `docs/2-design/DesignDoc.md — Lite edition` — OCPF BC Agentic Development Framework, written at Lite Step 2; brought to as-built at Step 6. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Design Document — <Extension Name>

**Version:** <n> · **Date:** <date> · **Sign-off:** <name>, <date or pending> · **From:** `docs/1-define/ProblemStatement.md`, `docs/1-define/ProjectParameters.md`, symbol file <version>

# Part A — What and why
## A1. Purpose, scope, out of scope
## A2. Business objectives
## A3. Target consumers
## A4. Platform requirements
## A5. Entity / object inventory
| Entity | Source table | Object type(s) | R / RW (Standards §2.2) | Notes |
|---|---|---|---|---|
## A6. Non-functional requirements
## A7. Languages and markets

# Part B — How
## B1. System identity (copied from `docs/1-define/ProjectParameters.md`)
## B2. ID allocation (sequential, buffer left at the end — Standards §5.2)
## B3. Per-object specification
### B3.<n> <Type> <ID> "<Name>"
| Property | Value |
|---|---|
| Source table (name / verified number) | |
| PageType / APIGroup / EntityName / EntitySetName / ODataKeyFields | |
| DelayedInsert = true **or** Editable = false | |
| SourceTableView | |
| `using` (from the symbol file) | |
| Deletion behaviour | |
| Caption-locking group / decision / decided by | |
| Parent link (child tables — Standards §11.1): link field, pages + opening, hidden control, two-group read, `TestField`, `DelayedInsert` | |
| Number series (numbered tables — Standards §11.2): setup field, pages + binding, `"No. Series"` field / `OnInsert` / `AssistEdit` | |
#### Fields
| Source field | Identifier | Conversion | Included / excluded — reason | FlowField or stored |
|---|---|---|---|---|
## B4. Design patterns beyond the Standards Guide (cited)
## B5. Permission sets (grants enumerated)
## B6. Upgrade and data migration ("none needed" written with its reason)
## B7. Events (verified in the symbol file)
## B8. Special notes (singletons, header/line, conflicts)
## B9. Translatable text (labels, comments, locked, file names)
## B10. Translation glossary
| BC concept | W1 term | <language> | Source | Status |
|---|---|---|---|---|
## B11. Object Register
| ID | Type | Name | Source table | R / RW |
|---|---|---|---|---|

## Self-check
- [ ] Every Step 1 entity maps to at least one object, or is explicitly deferred.
- [ ] Every ID is inside the allocated range; buffer left.
- [ ] Every source table number and `using` namespace comes from the symbol file.
- [ ] Every field complies with Localization; obsolete fields excluded.
- [ ] All names ≤ 30 characters; R / RW matches mutability.
- [ ] Permission sets enumerated and named with this extension's App Code.
- [ ] Every deletion behaviour decided; every API object has a caption-locking decision.
- [ ] Every target language has a reviewer; every regional term is in the glossary.
