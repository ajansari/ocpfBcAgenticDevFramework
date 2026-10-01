> **Template** for `docs/2-design/FRD.md` — OCPF BC Agentic Development Framework, written at Full Step 02. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Functional Requirements Document — <Extension Name>

**Version:** <FRD version> · **Date:** <date> · **Author:** <drafting role / person> · **Sign-off:** Dev Manager — <name>, <date or pending>
**Sources:** `docs/1-define/ProblemStatement.md`, the PRE-02 expanded entity list and gap log, `docs/1-define/ProjectParameters.md`.

## 1. Purpose and scope
<What the extension does and why, in business language. One paragraph on the outcome.>

### 1.1 Out of scope
- <Explicit exclusion, with the reason it is excluded.>

## 2. Business objectives and value
| # | Objective | Value delivered | Measured by |
|---|---|---|---|
| O1 | <objective> | <value> | <measure> |

## 3. Target consumers
| Consumer | Kind (user / system / AI tool / report) | What they need from the extension |
|---|---|---|
| <consumer> | <kind> | <need> |

## 4. Platform requirements
From Parameters §1.1 and §1.4 — BC version, deployment target, compatibility, localization.
- <requirement>

## 5. Design rules
The non-negotiable constraints every object must obey (cite Standards § where a rule comes from).
- <rule — Standards §x.y>

## 6. Entity and object inventory
Every entity from PRE-02, or listed under 6.1 with a reason. Read vs. read/write per Standards §2.2.
| Entity | Source table (name) | Object type(s) | R / RW | Global or localized | Notes |
|---|---|---|---|---|---|
| <entity> | <table> | <API page / table / …> | <R or RW> | <global> | <notes> |

### 6.1 Deferred entities
| Entity | Reason deferred | Revisit at |
|---|---|---|

## 7. Non-functional requirements
- **Compilation:** 0 errors, 0 warnings with the analyzers (Operating Rule 5).
- **Performance:** <requirement>
- **Compliance / security:** <requirement>
- **Deployment:** <requirement>

## 8. Languages and markets
From Parameters §1.9, written as requirements, not tooling.
| Language | Country | Required at first release | Reviewer | Customer-language documents | Translatable data |
|---|---|---|---|---|---|

## 9. Open questions
| # | Question | Owner | Raised | Resolved |
|---|---|---|---|---|

## Validation against DEFINE
- [ ] Every PRE-02 entity appears in §6 or §6.1.
- [ ] Every PRE-01 consumer use case is addressed in §3.
- [ ] Every platform capability assumed here was verified BC can do it (no assumed behaviour).
- [ ] §8 covers every target language in Parameters §1.9.
- [ ] Nothing here says *how* — that is the TDD's job.
