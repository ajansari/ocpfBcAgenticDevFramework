> **Template** for `docs/2-design/TDD.md (and, at Step 10, docs/4-prove/PostDevTDD.md)` — OCPF BC Agentic Development Framework, written at Full Step 03. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Technical Design Document — <Extension Name>

**Version:** <TDD version> · **Date:** <date> · **Author:** <drafting role / person> · **Sign-off:** Technical Lead — <name>, <date or pending>
**Built from:** `docs/2-design/FRD.md` v<n>, `docs/1-define/ProjectParameters.md`, symbol file <version / source>.
**Self-sufficiency:** a developer or agent who has never seen this project must be able to produce every object from this document alone. Cite the FRD; do not restate it.

## 1. System identity
All from `docs/1-define/ProjectParameters.md` — copied, never retyped from memory.
| Item | Value |
|---|---|
| Publisher / Namespace / Prefix | <…> |
| APIPublisher / APIGroup prefix / APIVersion | <…> |
| AL runtime / BC minimum / Localization | <…> |
| Object ID range(s) | <…> |
| Permission Set App Code / names | <…> |

## 2. Module grouping and ID allocation
Standards §5.1–§5.2: contiguous sub-block per module, ≥ 20 % growth buffer, tail block for cross-module additions.
| Module | ID sub-block | Allocated | Buffer | Objects |
|---|---|---|---|---|

## 3. Batch / phase plan
Smallest, simplest batch first (Operating Rule 3). Step 05 turns this into `docs/3-build/BuildPlan.md`.
| Batch | Modules / objects | Depends on | Why this order |
|---|---|---|---|

## 4. Per-object specification
One block per object. Every source table **number** verified in the symbol file.
### 4.<n> <Object type> <ID> "<Name>"
| Property | Value |
|---|---|
| Source table (name / verified number) | <…> |
| PageType / APIPublisher / APIGroup / APIVersion | <…> |
| EntityName / EntitySetName (≤ 30, camelCase) | <…> |
| ODataKeyFields | SystemId |
| DelayedInsert = true **or** Editable = false (exactly one, Standards §2.2) | <…> |
| SourceTableView (const() quoting, Standards §2.3) | <…> |
| `using` namespaces (from the symbol file) | <…> |
| Deletion behaviour (block-if-referenced / cascade / allow) — incl. referencing fields on other tables | <…> |
| Caption-locking group and decision (Standards §8.6), decided by | <…> |
| Parent link — child tables only (Standards §11.1): link field; every page showing this table in a parent's context and its opening (`SubPageLink` part / `RunPageLink` action); hidden link control, two-group `OnNewRecord` read, `TestField` in `OnInsert`, `DelayedInsert = true` | <… or N/A — no parent-link field> |
| Number series — numbered tables only (Standards §11.2): setup field (`TableRelation = "No. Series"`); pages it appears on and their binding; `"No. Series"` field, `OnInsert`, `AssistEdit` on codeunit `"No. Series"` | <… or N/A — not numbered> |

#### Fields
| Source field | Identifier (camelCase, ≤ 30) | Conversion decision (Standards §4.1–§4.3) | Included / excluded — reason (Standards Part 3) | FlowField or stored (Standards Part 7) |
|---|---|---|---|---|

## 5. Standard object template
The exact AL pattern every generated object follows (Standards §1.3), shown once.
```al
<template>
```

## 6. Design patterns beyond the Standards Guide
| Need | Pattern | Source (AL Guidelines / Microsoft Learn, cited) |
|---|---|---|

## 7. Labels and translatable text
Standards §8.3: every message a `Label`, every placeholder a `Comment`, `Locked` where decided.
| Label | Text (W1 wording) | Comment | Locked |
|---|---|---|---|

## 8. Upgrade and data migration
Standards Part 9. "No upgrade code needed" is written down with its reason.
| Upgrade codeunit | Trigger (PerCompany / PerDatabase) | Upgrade tag | What it does |
|---|---|---|---|

## 9. Events
Standards Part 10; each Microsoft event verified in the symbol file.
| Direction (published / subscribed) | Event | Object | Why |
|---|---|---|---|

## 10. Permission sets
Standards §5.3–§5.4: a VIEW set and an EDIT set that includes it; every table's `tabledata` grant assigned to the batch that introduces the table.
| Set (≤ 20 chars) | ID | Grants | Batch |
|---|---|---|---|

## 11. Special design notes
Singletons, header/line pairs, high-volume tables, naming conflicts.
- <note>

## 12. Object Register
Also maintained standalone as `docs/1-define/ObjectRegister.md`.
| ID | Type | Name | Module | Source table | R / RW | Batch |
|---|---|---|---|---|---|---|

## Self-sufficiency check
- [ ] Every FRD entity maps to at least one object in §4.
- [ ] Every ID is inside an allocated range with its buffer intact.
- [ ] Every source table number and `using` namespace comes from the symbol file.
- [ ] Every field decision (include / exclude / rename / FlowField) is written, not defaulted.
- [ ] Every deletion behaviour and every caption-locking decision names who decided.
- [ ] No rule in this document needs knowledge that lives outside it.
