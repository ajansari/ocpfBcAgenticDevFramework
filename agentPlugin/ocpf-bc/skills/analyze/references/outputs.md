# The analysis outputs — `requirements/existing/`

Six files, all written by the `ocpf-analyst` sub-agent, all into `requirements/existing/`, all
marked for what they are: a **reverse-engineered record**, presumed where the code only implies
it, confirmed only where the human's notes or a document in the folder says so. They are inputs to
the next journey, not framework documents: Full PRE-01 / Lite Step 1 reads them with the rest of
`requirements/`, and the FRD and TDD the journey later writes into `docs/` supersede them.

## 1. `PresumedFRD.md`

The framework's `FRD.md` template, every heading kept, with the title **Presumed Functional
Requirements — <Extension Name> (reverse-engineered <date>)** and this line under the title:
*Every requirement below is inferred from the code unless marked (confirmed by <source>). Statements
marked (presumed) need the owner's review.* Fill §1 purpose and scope and §1.1 out of scope from
what the objects do and do not do; §3 consumers from the pages, APIs, reports, and role centers
present (a user, an integration, a BI tool); the business rules from validations, `TestField`s,
status enums, posting or processing codeunits; the flows from the pages' actions and the codeunits
they call. A section the code gives no evidence for keeps its heading with *N/A — nothing in the
code implies this; ask the owner*. End with **Open questions**.

## 2. `PresumedTDD.md`

The framework's `TDD.md` template, every heading kept, title **Technical Design, as built —
<Extension Name> (reverse-engineered <date>)**. §1 system identity from `app.json` (id, name,
publisher, version, target, platform, application, runtime, features, dependencies, ID ranges);
§2 modules as the folders or the naming groups suggest; §4 one specification per object with its
fields, keys, relations, triggers, and the labels it uses; §7 labels and translations (which
languages `Translations/` holds, which units are untranslated); §8 upgrade and install code found;
§9 events published and subscribed; §10 permission sets and what they grant; §12 the Object
Register (the same table as file 3). Mark *(presumed)* on any intent you infer — "this key exists
to speed the list" — and keep facts (a field's type) unmarked.

## 3. `ObjectRegister.md`

The shape Full Step 01 seeds and Step 05 maintains:

| Type | ID | Name | File | Extends / Source | R/W | Purpose (one line) |
|---|---|---|---|---|---|---|

One row per object under `src/`, in ID order within type: tables, table extensions, enums, enum
extensions, pages, page extensions, reports, report extensions, codeunits, queries, API pages and
queries, permission sets and extensions, XMLports, control add-ins, interfaces, entitlements,
profiles. **R/W:** a page's or API's editability; a table's `DataPerCompany`; a codeunit's
`SingleInstance` or subscriber nature. Count the files and the rows and say both in the README;
they must match.

## 4. `Documentation.md`

The framework's `Documentation.md` template shape — overview, architecture with the schema
diagram, modules and objects, API reference, events, permission sets, setup and configuration,
upgrade behaviour, known limitations — with three additions this analysis needs:

- **§2.1 Schema** — a Mermaid `erDiagram` of every table the extension owns, every standard table
  it extends or relates to, and the relations between them, read from `TableRelation`s, keys, and
  `FlowField` filters; under it, one field table per owned table (field, type, meaning as the
  caption and tooltip say it, relation). Source only — *not rendered here; GitHub and VS Code
  render Mermaid*.
- **§2.3 What each object is for** — a table: object, type, role in the app, how a user or a
  system reaches it. Cover, where present: pages (list, card, document, list part, setup card,
  worksheet), processing-only reports and printed reports, API pages and queries, permission sets
  and their intended audience, assisted-setup wizards and what they set up, number series and
  which setup field holds them, role centers and their cues and actions, event subscribers and
  what they hook, install and upgrade codeunits, interfaces and their implementations, XMLports.
- **§2.4 How it flows** — the user's path through the app in numbered steps (open this page,
  create a record, run this action, which codeunit does what, what is posted or created where),
  one walk-through per distinct flow, written for a consultant, not a compiler.

Every purpose statement is *(presumed)* unless confirmed.

## 5. `ProjectParameters.md`

The Project Parameters block of Full Step 01 (`fullVersion/steps/01.md`, §1.1–§1.10; Lite Step 1
carries the same rows) — title **Project Parameters, as read — <Extension Name>** — with a third
column **Source**: *app.json*, *the code* (prefix from the object names, namespace from the first
`namespace` line, localization from captions or dependencies), or *unknown — ask*. Never fill a
publisher, a prefix, or a range from anything but the file and the code; a template default is
written as *the AL template's default — not a decision*. The model rows are *N/A — not a framework
project yet*.

## 6. `README.md`

The folder's index: what each file is and when it was written; the model and effort the analysis
ran on, with the `Model:` line the report opened with; the human's typed notes, verbatim; the
documents the human placed in the folder, by name; the counts (files read, objects by type, rows
in the register); the open questions, most important first; the risks noticed in the code; and,
after the clock closes, the usage rows under `## Usage` when the project has no
`ProjectProgress.md` to hold them.
