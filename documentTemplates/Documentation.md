> **Template** for `docs/4-prove/Documentation.md` — OCPF BC Agentic Development Framework, written at Full Step 11. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# <Extension Name> — Technical Documentation

**Version:** <app.json version> · **Date:** <date> · **Generated from:** the AL source at commit <sha> and `docs/4-prove/PostDevTDD.md`

## 1. Overview
<What the extension does, for whom, in two paragraphs.>

## 2. Architecture
### 2.1 Schema diagram
Mermaid, rendered and checked before it is committed — never ship a diagram you haven't seen render. The renderer check (Node, then `npx --yes @mermaid-js/mermaid-cli`, never `which mmdc`) is in **Ops § Tooling Checks**; its outcome is recorded in `ocpfFramework/framework.json` → `tooling.mermaid`.
```mermaid
erDiagram
```
### 2.2 Modules and objects
| Module | Objects (ID — type — name) | Purpose |
|---|---|---|

## 3. API reference
One section per API page or query.
### 3.<n> <EntitySetName>
| Item | Value |
|---|---|
| Route | `/api/<publisher>/<group>/<version>/companies({id})/<entitySetName>` |
| Source table | <name (number)> |
| Read / read-write | <…> |
| Key | SystemId |
| Filters supported | <…> |

| Field | Type | Source field | Notes |
|---|---|---|---|

Example request and response (from an actual call where one was made at Step 07; otherwise marked *illustrative*):
```http
GET …
```

## 4. Events
| Published / subscribed | Event | Object | Purpose |
|---|---|---|---|

## 5. Permission sets
| Set | Grants | Intended for |
|---|---|---|

## 6. Setup and configuration
<Assisted setup, setup tables, feature flags, and where they live.>

## 7. Upgrade behaviour
<Upgrade codeunits, tags, obsolete cycle.>

## 8. Known limitations
- <limitation>

## Before calling this done
- [ ] Every object in the Object Register is documented in §2 or §3.
- [ ] Every diagram was rendered and checked.
- [ ] Every example marked *illustrative* is marked so.
