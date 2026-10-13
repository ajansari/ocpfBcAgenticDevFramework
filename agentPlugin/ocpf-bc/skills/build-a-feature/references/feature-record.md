# The feature record — `ProjectProgress.md`, `usage.json`, the ChangeLog line

Build-a-Feature keeps one written record, `ProjectProgress.md` at the project root (never
`docs/`), and the per-developer timestamps in `ocpfFramework/state/usage.json`. The dashboard and
the `status` skill read both. Nothing here is typed from memory: the usage rows come from the
`usage` script, the stage from the loop in the skill.

## The feature table

The template (`ocpfFramework/documentTemplates/ProjectProgress.md`) carries it as the third step
table, *Build-a-Feature*. Keep this shape exactly; the renderer parses it by the first column (`Row`), and the usage script counts objects by the `Type` and `ID` columns.

```
## Build-a-Feature
| Row | Object | Type | ID | Stage | Status | Shipped in |
|---|---|---|---|---|---|---|
| F00 | Intake | — | — | — | Completed | — |
| F01 | Rental Unit | Table | 50100 | Compiled | Completed | 0.0.0.1 |
| F02 | Rental Units | Page (List) | 50101 | Compiled | Completed | 0.0.0.1 |
| F03 | Rental Unit Card | Page (Card) | 50102 | Built | In Progress | |
| FPK | Package | — | — | Packaged 0.0.0.1 | Completed | 0.0.0.1 |
| FRV | Review | — | — | Reviewed | Completed | — |
```

- **Row:** `F00` is the intake; `F01`, `F02`, … one per object, in the order they were started,
  continuing across sessions from the highest existing number; `FPK` the package (one row, its
  stage shows the latest version); `FRV` the review (one row).
- **Object:** the object's name without the prefix. **Type:** `Table`, `Table Extension`,
  `Page (List)`, `Page (Card)`, `Page Extension`, `Report`, `Report Extension`, `API Page`,
  `API Query`, `Query`, `Enum`, `Enum Extension`, `Codeunit`, `Permission Set`,
  `Permission Set Extension`. **ID:** the object ID.
- **Stage:** `Asked` → `Confirmed` → `Built` → `Compiled` → (`Packaged`) → (`Reviewed`), moved by
  the loop as each thing happens. `Reviewed` and then `Packaged` are written on the object rows
  when the review and the package cover them — the review is offered first, the package after.
- **Status:** `In Progress` while the row's window is open; `Completed` once its usage rows are
  written; blank for a planned object not started yet.
- **Shipped in:** the first package version that contained the object; blank until packaged, and
  never overwritten by a later package (a later package fills only the blank rows).

**On a Full or Lite project** the table is appended under its own `## Build-a-Feature` heading
between the step table and the usage table. The step table is never edited by this journey.

## The usage windows

`ocpfFramework/state/usage.json` (Ops § Usage & Cost → 1) takes one entry per window. The `step`
is the row's id; `title` is extra and ignored by the usage script, kept so the dashboard can name
the row before the table has it:

```json
{ "step": "F01", "title": "Table Rental Unit", "startedAt": "2026-10-11T15:02:11Z", "completedAt": "2026-10-11T15:19:40Z" }
```

An open window ends where the next one starts, so a row left open never absorbs the rows after
it. A package built twice gives `FPK` two windows; the usage script sums them. The usage rows
go into the usage table under the feature table — one row per model that ran (Claude Code) or
one row per window (Copilot) — written by `/ocpf-bc:usage --step <id>` at every close and
pasted into the closing message. Never hand-written.

## The four quick documents (Part 7)

`docs/1-define/ProblemStatement.md`, `docs/1-define/FeatureRegister.md` (template
`FeatureRegister.md`: parameters, object table, schema diagram), `docs/4-prove/Documentation.md`
(template `FeatureDocumentation.md`), and `ProjectProgress.md`. Written at the close from what
the session knows, appended on later sessions, one to two minutes in all. On a Full or Lite
project they sit beside the project's documents and append, never replace.

## The ChangeLog line (framework projects only)

A Full or Lite project keeps `docs/0-project/ChangeLog.md`. Each object built by this journey
adds one line to it, under a dated heading if the day has none yet:

```
- 2026-10-11 — Build-a-Feature: table 50100 "PFX Rental Unit" (src/RentalUnit/PFXRentalUnit.Table.al), shipped in 0.3.0.4.
```

Beyond that line and the four quick documents (appended), no project document changes. A feature
project (edition `feature`) has no ChangeLog; its feature table and the four documents are the
record.

## Versioning, in one paragraph

Ops § Packaging → *Version numbers*, unchanged: a new extension starts at `0.0.0.1` and its first
package is built at that version as is; every later package increments the fourth segment first,
mechanically, with no approval; an existing extension's first package increments from the
installed version; never two packages at one version (`al-analyze.*` refuses to overwrite, exit
code 4). The release candidate — `1.0.0.0` for a new extension, the next Minor or Major for an
existing one — is proposed and approved, only once the human says the `0.x` package was tested
and approved.
