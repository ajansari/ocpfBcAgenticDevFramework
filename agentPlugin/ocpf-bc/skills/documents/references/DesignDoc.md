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
## B2. ID allocation (per object type from the range's first ID — Ops § Object IDs; buffer left at the top, per type — Standards §5.2)
| Type | First ID | Count | Highest used | Left in range |
|---|---|---|---|---|
## B3. Per-object specification
### B3.<n> <Type> <ID> "<Name>"
| Property | Value |
|---|---|
| Source table (name / verified number) | |
| PageType / APIGroup / EntityName / EntitySetName / ODataKeyFields | |
| `DelayedInsert = true` on every API page; read-only adds `Editable = false` + the three `*Allowed = false` (Standards §2.2) | |
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
Sorted by type, then ID; an ID is unique within its type only, so the same number appears once per type that uses it (Ops § Object IDs).
| Type | ID | Name | Source table | R / RW | Enum: Extensible (true / false — why) |
|---|---|---|---|---|---|

## Self-check
- [ ] Every Step 1 entity maps to at least one object, or is explicitly deferred.
- [ ] Every ID is inside the allocated range; buffer left.
- [ ] Per-type ID check (Ops § Object IDs): every object type starts at the range's first ID with no gaps; no number skipped because another type holds it.
- [ ] Every source table number and `using` namespace comes from the symbol file.
- [ ] Every field complies with Localization; obsolete fields excluded.
- [ ] All names ≤ 30 characters; R / RW matches mutability.
- [ ] Permission sets enumerated and named with this extension's App Code.
- [ ] Every deletion behaviour decided; every API object has a caption-locking decision.
- [ ] No new `Option`; every enum has its `Extensible = true` / `false` decided with the human, recorded here with the reason, and written explicitly in the object (Standards §1.9).
- [ ] Every target language has a reviewer; every regional term is in the glossary.
