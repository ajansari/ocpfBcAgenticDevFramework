> **Reference** — OCPF BC Agentic Development Framework. This file is read, never written into `docs/`: the Human Effort Estimate
> (`docs/2-design/HumanEffortEstimate.md`, Full Step 03 / Lite Step 2) reads its baselines from here — or from the partner's
> calibration file when one exists (§3) — names which one it used, and reproduces only the rows it needed. Do not copy this
> file into a project and do not edit it there; changes to the default table are framework releases.

# Human Effort Baselines

**Baselines v1, September 27, 2026** · Profile: a fast US senior AL developer (5+ years of Business Central extension work, fluent in AL, the AL tools, and the standards this framework applies), working alone, no ramp-up, from requirements as complete as the FRD or Design Doc.

## 1. Default table
Hours per unit. Pick the low end for simple and the high end for complex; the estimate states the reason per row.

| Task | Unit | Baseline |
|---|---|---|
| Requirements write-up (FRD-equivalent) | per 10 entities | 1.5 – 3 |
| Technical design (TDD-equivalent, incl. ID allocation) | per 10 objects | 2 – 4 |
| New table | each | 0.5 – 1.5 |
| Table extension | each | 0.25 – 0.75 |
| List or card page | each | 0.5 – 1.5 |
| Page extension | each | 0.25 – 0.75 |
| API page or API query | each | 0.5 – 1 |
| Codeunit — helpers, subscribers, simple validation | each | 0.5 – 2 |
| Codeunit — business logic (posting, no. series, complex validation) | each | 3 – 10 |
| Report with layout | each | 2 – 6 |
| Enum or enum extension | each | 0.15 |
| Permission set (VIEW + EDIT pair) | per pair | 0.25 – 0.5 |
| Upgrade codeunit | each | 1 – 3 |
| Event publisher or subscriber wiring | each | 0.25 – 0.75 |
| Assisted setup wizard, role-center cues, Departments placement | each feature | 2 – 4 |
| Translation drafting | per language, per 20 labels | 0.25 |
| Compile, package, deploy troubleshooting | share of build hours | 5 – 10 % |
| Automated tests (only when in scope) | share of build hours | 20 – 30 % |
| Code review and fixes | share of build hours | 5 – 10 % |
| Documentation set | per project | 2 – 6 |
| Release testing support and fixes | per project | 1 – 4 |

## 2. Sanity anchor
A typical 10-object PTE (3 tables, 3 pages, 2 codeunits, 1 API page, permission sets) lands at **15 – 30 hours** end to end. Scale the anchor by the project's object count (a 20-object project anchors at 30 – 60 hours) and compare the estimate's total against it. An estimate outside 0.5× – 2× of the scaled anchor must state why in §4 of the estimate; being outside is allowed, being silent about it is not.

## 3. Calibration
If `~/.ocpf/HumanEffortBaselines.md` exists — the partner's own table, kept outside every project so it applies to all of them — it **replaces** the default table above: the estimate reads its rows from that file instead, and §2 of the estimate says *partner calibration `~/.ocpf/HumanEffortBaselines.md` dated <d>* rather than *framework default v<n>*. The calibration file has the **same shape** as §1: the same three columns, the same task rows (a row may be left out, in which case the default row for that task still applies, and the estimate says so), hours per unit, and a date on its first line. It may also restate the sanity anchor for the partner's own typical project; when it does, that anchor is the one the estimate checks against.

To build the calibration file, the partner supplies one of:
- **Hours billed and object counts from three to five past projects** — per project: total billed hours, the split by phase if known (define and design, build, prove), and the number of objects by type as the table above names them. The agent derives per-unit hours from these, writes the file, and shows the derivation before it is used.
- **The partner's rate card** — the hours the partner already quotes per object type or per feature, in whatever shape the partner keeps it. The agent maps it onto the table's rows and marks the rows it could not fill.

Either way the file is the partner's, is never committed to a project repository, and is revised whenever a finished project's actual hours are known.
