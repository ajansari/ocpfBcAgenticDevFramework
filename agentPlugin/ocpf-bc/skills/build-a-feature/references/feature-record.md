# The feature record — `ProjectProgress.md`, `usage.json`, `feature.json`, the documents

Build-a-Feature keeps one tracker, `ProjectProgress.md` at the project root (never `docs/`), the
per-developer timestamps in `ocpfFramework/state/usage.json`, the journey's own parameters in
`ocpfFramework/state/feature.json`, and — since 5.8.0.0 — **six documents in a flat `docs/`
folder, written as the work happens, not at the close**. The dashboard and the `status` skill read
the first three. Nothing here is typed from memory: the usage rows come from the `usage` script,
the stage from the loop in the skill.

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
  `Page (List)`, `Page (Card)`, `Page (List Part)`, `Page (Role Center)`, `Page (Card Part)`,
  `Page Extension`, `Report`, `Report Extension`, `API Page`, `API Query`, `Query`, `Enum`,
  `Enum Extension`, `Codeunit`, `Permission Set`, `Permission Set Extension`, `Profile`. **ID:**
  the object ID (a profile has none: `—`).
- **Stage:** `Asked` → `Confirmed` → `Built` → `Compiled` → `Documented` → (`Reviewed`) →
  (`Packaged`), moved by the loop as each thing happens. `Reviewed` and then `Packaged` are
  written on the object rows when the review and the package cover them — the review is offered
  first, the package after.
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

**`F00` opens as the very first act of the journey**, before the working-language question — the
file is created then, if it doesn't exist — so that nothing the session does is outside a window.
The renderers also stretch the first window back to the first event of the session that opened
it (v5.8.0.0), so even a late `startedAt` no longer makes the clock start after the tokens; but
the rule stands: open it first. An open window ends where the next one starts, so a row left open
never absorbs the rows after it. **One window per object, always** — when several objects are
written in one pass, the windows are still opened one after another (a JSON line each; the usage
run may then be done once for the batch, without `--step`, and every row pasted). A package built
twice gives `FPK` two windows; the usage script sums them. The usage rows go into the usage table
under the feature table — one row per model that ran (Claude Code) or one row per window
(Copilot) — written by `/ocpf-bc:usage --step <id>` at every close and pasted into the closing
message. Never hand-written.

## `ocpfFramework/state/feature.json` — the journey's parameters, with their sources

Build-a-Feature has no `ProjectParameters.md`; this file is its sheet, per developer, gitignored.
Every value a later step depends on is here **with the box the human answered**, so no step can
run on a value nobody chose:

```json
{
  "mainModel": "sonnet", "mainEffort": "medium", "workingLanguage": "en",
  "publisher": "Contoso", "publisherSource": "typed by the human, Box 0, 2026-10-16",
  "idRanges": [{ "from": 50100, "to": 50149 }],
  "idRangesSource": "chosen by the human, naming-and-range box, 2026-10-16 — the AL template's default, kept knowingly",
  "prefix": "CRU", "namespace": "Contoso.RentalUnits",
  "pricingChecked": "2026-10-16"
}
```

**The ID gate:** Part 4 step 4 allocates an object ID **only** when `idRangesSource` is present;
a missing or template-derived source ("read from app.json") sends the loop back to the range
question first. **The publisher gate:** `app.json`'s `publisher` is written **only** from a value
whose `publisherSource` names a box or a message the human typed in — never git config, an email
domain, a folder name, memory of another project, or the AL template (Ops § Intake). The `status`
skill reports a feature project whose `feature.json` lacks either source.

## The documents — flat `docs/`, written as the work happens

| File | Template | Written | Holds |
|---|---|---|---|
| `docs/ProblemStatement.md` | none — Lite Step 1's shape: purpose, scope, out of scope | at the intake close (F00); a dated section per session | the intake answer in the human's words, the plan, what was deliberately left out |
| `docs/FeatureRegister.md` | `FeatureRegister.md` | §1 at the intake close; a §2 row when an object is **proposed**, updated when confirmed and when compiled; §4 at every decision | the parameters with their sources, the object register, where to look, decisions |
| `docs/DataModel.md` | `FeatureDataModel.md` | a table / extension / enum section **before its confirmation box**, marked *proposed*; updated on confirm and on compile; §4–§6 as pages, APIs, and permission sets are built; diagram redrawn at the close | the schema: fields, types, keys, relations, enums, where the data is shown, who may read it |
| `docs/Documentation.md` | `FeatureDocumentation.md` | a §3 section when the object **compiles**; §1, §2, §4–§7 at the close of the plan | the explanation for a consultant, tester, or next developer: what it does, how to use it, the objects, how they fit, API, permissions, limitations |
| `docs/ChangeLog.md` | `ChangeLog.md` | one line per object when it compiles; one per review and per package | the running log, the format Full and Lite use |
| `docs/SandboxInstall.md` | `SandboxInstall.md` | with the first package; §1 rewritten by every later one | the human's upload guide |

**Why written as the work happens:** on a real project the documents arrived only at the close,
so the human was asked to confirm designs they could not see on disk, and a wrong field type was
found after the package. Now the proposal for each table is in `docs/DataModel.md` **before** the
box that asks *Looks right — build it*, and the box's text names the file.

**Why flat:** a feature project writes six documents; numbered phase folders made for a 19-document
routine skipped numbers here and hid the files. `docs/` holds them all, at one level.

**On a Full or Lite project (case A)** the project's phase folders stay: `FeatureRegister.md` goes
to `docs/1-define/`, `DataModel.md` to `docs/2-design/`, the Documentation sections are appended
under a `## Build-a-Feature` heading in the existing `docs/4-prove/Documentation.md` (Full) or
`docs/4-prove/Docs.md` (Lite), the problem-statement section is appended to the existing
`docs/1-define/ProblemStatement.md`, the ChangeLog line goes to `docs/0-project/ChangeLog.md`, and
`SandboxInstall.md` to `docs/4-prove/` — never replacing anything.

## The ChangeLog line

Each object built adds one line under a dated heading (`docs/ChangeLog.md` on a feature project;
`docs/0-project/ChangeLog.md` on a Full or Lite one):

```
- 2026-10-11 — Build-a-Feature: table 50100 "PFX Rental Unit" (src/RentalUnit/PFXRentalUnit.Table.al), shipped in 0.3.0.4.
```

A review adds a line per finding applied or declined; a package adds a line with its version and
Schema Sync Mode.

## Versioning, in one paragraph

Ops § Packaging → *Version numbers*, unchanged: a new extension starts at `0.0.0.1` and its first
package is built at that version as is (and `docs/SandboxInstall.md` is written with it — §1
rewritten by every later package — for the person who uploads it); every later package increments
the fourth segment first, mechanically, with no approval; an existing extension's first package
increments from the installed version; never two packages at one version (`al-analyze.*` refuses
to overwrite, exit code 4). The release candidate — `1.0.0.0` for a new extension, the next Minor
or Major for an existing one — is proposed and approved, only once the human says the `0.x`
package was tested and approved.
