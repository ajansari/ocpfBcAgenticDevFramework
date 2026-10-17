# Role center — the page, its activities cues, and a profile

**Read before writing:** Standards §1.1–§1.8, §1.4 (Caption, ToolTip, ApplicationArea on every
field), §1.7 (labels); Appendix B — symbol-verify every standard page the role center links to
(Customer List, Sales Orders, …) and every standard table a cue counts.

A role center is a **group of three or four objects**, built in this order and offered as one
plan: a **Cue table** (one record, `FlowField` counters), an **Activities page** (`PageType =
CardPart`, cue groups), the **Role Center page** itself, and a **Profile** so a user can pick it.
The intake answer *"a role center for the rental manager"* is this whole group; confirm it as one
plan in one box, then each object through the loop.

## Ask / confirm

Needed: **who it is for** (the role name — becomes the profile's caption); **the cues** (default:
one per owned list the extension has — *Open Rental Units*, *Rental Units — Overdue* — proposed
from the tables built in this session or found in `src/`; each cue is a count over a table with a
filter, so confirm the table and the filter in words); **the navigation** (which lists and cards
open from the role center's actions — the extension's own pages first, then the standard pages the
human names: Customers, Sales Orders); **the headline** (*none (recommended for a quick mod)* / *a
single fixed headline*); **the profile** (*Yes — a profile "<Role>" so users can choose it
(recommended)* / *No profile — reached from Settings only*). No charts, no embedded Power BI, no
report tiles unless asked.

## Write

Cue table (one record, flow fields only, no user data):

```al
namespace <Publisher>.<ExtensionShort>;

table <ID> "<PFX> Rental Cue"
{
    Caption = 'Rental Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Open Rental Units"; Integer)
        {
            Caption = 'Open Rental Units';
            FieldClass = FlowField;
            CalcFormula = count("<PFX> Rental Unit" where(Status = const(Open)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
```

Activities part (the cues), one group per theme, every cue a field with `DrillDownPageId`:

```al
page <ID> "<PFX> Rental Activities"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "<PFX> Rental Cue";
    Caption = 'Activities';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup(Rentals)
            {
                Caption = 'Rentals';
                field("Open Rental Units"; Rec."Open Rental Units")
                {
                    Caption = 'Open Rental Units';
                    ToolTip = 'Specifies the number of rental units that are open.';
                    ApplicationArea = All;
                    DrillDownPageId = "<PFX> Rental Units";
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
```

Role center page — parts and navigation, nothing else:

```al
page <ID> "<PFX> Rental Role Center"
{
    PageType = RoleCenter;
    Caption = 'Rental Manager';

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "<PFX> Rental Activities")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Rentals)
            {
                Caption = 'Rentals';
                action(RentalUnits)
                {
                    Caption = 'Rental Units';
                    ToolTip = 'Open the list of rental units.';
                    ApplicationArea = All;
                    RunObject = page "<PFX> Rental Units";
                }
            }
        }
        area(Embedding)
        {
            action(Customers)
            {
                Caption = 'Customers';
                ToolTip = 'Open the list of customers.';
                ApplicationArea = All;
                RunObject = page "Customer List";
            }
        }
    }
}
```

Profile, so the role center is selectable:

```al
profile "<PFX> RENTAL MANAGER"
{
    Caption = 'Rental Manager';
    ProfileDescription = 'Rental units and their customers.';
    RoleCenter = "<PFX> Rental Role Center";
    Enabled = true;
    Promoted = false;
}
```

- The **cue table holds no user data** — `DataClassification = SystemMetadata`, one record the
  part inserts on first open, every counter a `FlowField` with `Editable = false`. Never a normal
  field a user could type into.
- **Every cue field and every action carries `Caption`, `ToolTip`, `ApplicationArea = All`**
  (§1.4); every cue has a `DrillDownPageId` so the number opens the list behind it.
- The role center page has **no `SourceTable`**; the part does. Keep the headline out unless
  asked: a headline needs a second `HeadlinePart` page and a text table, which is a second plan.
- `RunObject = page "Customer List"` and every other standard page: **symbol-verify the page
  name** (Appendix B); a mistyped standard page name compiles only when it happens to exist.
- A **permission set** built in the same session grants the cue table (`R`) and executes the three
  pages; a role center without read on its cue table opens empty for a non-SUPER user.

## Pre-flight

Cue table: one key, `SystemMetadata`, every counter a `FlowField` with `Editable = false` and a
`CalcFormula` over a table and filter the human confirmed. Part: `RefreshOnActivate = true`,
`OnOpenPage` get-or-insert, every cue a `DrillDownPageId` to a page that exists. Role center: no
`SourceTable`, `PageType = RoleCenter`, every action a `RunObject` to a page that exists in the
symbols or in `src/`. Profile: `RoleCenter` names the page; the profile name is uppercase with the
prefix (§1.8 file name `<Name>.Profile.al`). Files: `<Name>.Table.al`, `<Name>.Page.al` ×2,
`<Name>.Profile.al`.

## Offer at close

After the group: *A permission set that grants the cue table and these pages (recommended if none
exists)* / *A headline part with one fixed message* / *Done*.
