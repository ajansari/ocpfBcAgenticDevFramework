# Table

**Read before writing:** Standards §1.1–§1.9, §5.3 (every table needs `tabledata` grants), §5.5
(ID in the project's range), Part 6 (is there a standard table that already does this?),
`references/field-types.md`; for a line table under a parent, Standards §11.1 and
`ocpfFramework/patterns/Pattern-SubPageLink-FilterGroup4.md`; for a numbered master table,
§11.2 and `ocpfFramework/patterns/Pattern-NoSeries-Setup-Field-And-Numbering.md`.

## Ask / confirm (one box)

Needed: the entity name; its fields with types (inferred per `field-types.md`); the primary key;
whether it is a **master** record (its own `No.`, list + card), a **line** under a parent
(parent key + `Line No.`, shown in a list part), a **setup** record (singleton, one card), or a
**lookup/reference** list (code + description, one list page). Infer the kind from the name and
the fields; say it in the confirmation table's first line. Standards Part 6 check in one
sentence: if a standard table already covers the need (a `Comment Line`, `Document Attachment`,
an `Extended Text`, a dimension), say so and offer the extension of it instead.

Enum-looking fields (`Status`, `Type`) become an enum object built first (`enum.md`), in the
same loop.

## Write

Numbered master table skeleton (drop what the kind does not need):

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Customer;   // one using per standard table referenced, from the symbols

table <ID> "<PFX> Rental Unit"
{
    Caption = 'Rental Unit';
    DataClassification = CustomerContent;
    LookupPageId = "<PFX> Rental Units";
    DrillDownPageId = "<PFX> Rental Units";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the number of the rental unit.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the rental unit.';
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer who rents the unit.';
            TableRelation = Customer;
        }
        field(20; "Start Date"; Date)
        {
            Caption = 'Start Date';
            ToolTip = 'Specifies the first day of the rental.';
        }
        field(30; Amount; Decimal)
        {
            Caption = 'Amount';
            ToolTip = 'Specifies the rental amount.';
            AutoFormatType = 1;
        }
        field(40; Status; Enum "<PFX> Rental Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the rental unit.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Customer; "Customer No.") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description) { }
        fieldgroup(Brick; "No.", Description, Status) { }
    }
}
```

- Field numbers: `1`, `2` for the key and description, then tens, so fields can be inserted later.
- `ToolTip` on a table field needs runtime 11.0 or later (BC 22); drop it on an older target. The
  page fields repeat the same caption and tooltip text either way (Standards §1.4, `page.md`).
- A line table: key `("Document No.", "Line No.")`, `"Line No."` `Integer`, the parent-link
  `TestField` in `OnInsert` per §11.1, no `Init()` after seeding.
- A setup table: key `("Primary Key")` `Code[10]`, one record, the card page uses
  `InsertAllowed = false; DeleteAllowed = false;` and `OnOpenPage` `Rec.Reset(); if not Rec.Get()
  then begin Rec.Init(); Rec.Insert(); end;`.
- A number series: `"No. Series"` `Code[20]` on the table, the setup table's `"Rental Unit Nos."`
  with `TableRelation = "No. Series"`, and `OnInsert` numbering through codeunit `"No. Series"`
  (§11.2) — never codeunit 396.
- Never `Option`; never `CaptionML`; a `Label` for every message; no empty triggers.
- Delete-safety: if other tables will reference this one, `OnDelete` checks are a design choice —
  say it in one line, do not add logic that was not asked for.

## Pre-flight (before compiling)

Identifier length ≤ 30; the ID inside a range of `app.json`; no reserved word (§4.3); `Caption` on
the table and every field; a `TableRelation` for every relation named; the key fields exist; the
enum object exists first; the file is `<Name>.Table.al` (§1.8); every `using` comes from the
symbols; **a `tabledata` grant will be needed** — PTE0004 fails the compile without one, so a
table built on a project with no permission set gets the permission-set offer below marked
*required*.

## Offer at close

Four options at most (Ops § Asking and Approvals): *Both list and card pages (recommended)* /
*List page only* / *An API page for it* / *Done with this table*. The permission-set grants are
offered when the pages close (`page.md`) — and when the project has no permission set at all,
say in the closing message that one is **required** before the compile can pass (PTE0004) and put
it at the front of the plan instead of offering it. A setup table offers *Setup card page* /
*Done*; a line table offers *List part on the parent's card* / *Done* (Part 11 applies).
