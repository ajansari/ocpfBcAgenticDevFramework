> **Template** for `docs/FeatureRegister.md` — OCPF BC Agentic Development Framework, Build-a-Feature journey (Ops § Build-a-Feature → *The record*). On a Full or Lite project the same file is written beside the project's own as `docs/1-define/FeatureRegister.md`. **Written incrementally, not at the close:** §1 at the intake close, a §2 row the moment an object's design is proposed (marked *proposed* until the human confirms it), §4 whenever a decision is taken. It holds what Full keeps in `ProjectParameters.md` and `ObjectRegister.md`; the schema lives in `docs/DataModel.md`, the narrative in `docs/Documentation.md`. Keep every heading; replace every `<placeholder>`; a section that doesn't apply keeps its heading with *N/A — reason* beneath it; delete this note. A later session appends rows.

# Feature Register — <Extension Name>

**Updated:** <date> · **Journey:** Build-a-Feature · **Sessions:** <n> · **Working language:** <language>

## 1. Parameters
Written at the intake close; every value is one the human chose or typed in a box, with its source. Nothing here was inferred from a file, an email domain, a folder name, or another project.
| Parameter | Value | Source (the box or message the human answered) |
|---|---|---|
| Extension name | <name> | <e.g. Box 0, session 1, typed> |
| Publisher | <publisher> | <typed by the human on <date>; never inferred> |
| App id | <GUID> | <kept from app.json / generated> |
| Deployment Target | <SaaS PTE / OnPrem PTE> | <box> |
| AL object prefix | <prefix> | <box> |
| Namespace | <namespace or none> | <box> |
| Object ID range(s) | <start–end (n IDs)> | <chosen or typed by the human on <date>; the AL template's 50100–50149 only if they chose it knowing it is the template's default> |
| Permission Set App Code | <code or not yet> | <box or N/A> |
| BC version / runtime | <application> / <runtime> | <Microsoft Learn runtime table, read <date>> |
| Main model / effort | <model> / <effort> | <roles question> |
| Version now / packages | <app.json version> / <versions in outputAppPackage/, or none> | — |
| New or existing app | <New app — started at 0.0.0.1 / Existing app — installed version <v>> | <intake 4b> |

## 2. Objects
One row per object this journey built, in build order; `Row` is the feature table's id in `ProjectProgress.md`. A row is written when the object's design is **proposed** (status *proposed*), updated to *confirmed* when the human accepts the design, and completed with the file when it compiles. **Base object:** for an extension, the standard object it extends. **Relates to:** the tables, pages, APIs, and permission sets this object links to or is used by.
| Row | Type | ID | Name | File | Base object | Relates to | Status | Session |
|---|---|---|---|---|---|---|---|---|
| F01 | Table | 50100 | <PFX Rental Unit> | src/<…>.Table.al | — | Customer (Customer No.); pages F02, F03; API F04 | confirmed · compiled | <date> |

## 3. Where to look
| Question | Document |
|---|---|
| Which tables and fields exist and how they connect | `docs/DataModel.md` |
| What each object does and how a user works with it | `docs/Documentation.md` |
| What was asked for, what was built, what was left out | `docs/ProblemStatement.md` |
| What changed, when, and in which package | `docs/ChangeLog.md` |
| How to install a package in a sandbox | `docs/SandboxInstall.md` |
| Stage, status, time, and cost per object | `ProjectProgress.md` and `ProjectDashboard.html` |

## 4. Decisions worth keeping
One line per decision, dated: a field type the human changed, a relation chosen, an enum's `Extensible` answer, a review finding declined, a companion offer refused, a range or publisher the human typed.
- <date> — <decision>
