# API page

**Read before writing:** Standards §1.3 (the template — write from it, substituting only
the bracketed values), Part 2 in full (§2.1 key, §2.2 editable vs read-only, §2.5 caption,
§2.6 tooltips as schema, §2.7 camelCase), Part 3 (which fields to include and exclude), §4.1,
§4.4 (`EntityName` / `EntitySetName` limits), §8.6 (caption locking), Appendix A (the URL shape
to show the human at the end).

## Ask / confirm

Needed: the source table (just built, or a standard one); **read-only or editable** (read-only
for anything the human will only report on; editable when an integration writes — the choice
drives the four guards in §2.2); the fields (default: every field of the project's own table, or
the §3.1 set of a standard one, each with its camelCase identifier shown in the confirmation
table); `APIPublisher` (the publisher in camelCase), `APIGroup` (prefix + a group word, camelCase,
no underscore), `APIVersion` (`v1.0`), `EntityName` / `EntitySetName` (singular / plural
camelCase); whether captions are **translatable** (business objects, the default) or **locked**
(internal plumbing) per §8.6. Everything but read-only-vs-editable and the field list is inferred
and shown; the human confirms once.

## Write

Exactly the §1.3 template:

```al
namespace <Publisher>.<ExtensionShort>;

page <ID> "<PFX> Rental Units API"
{
    PageType = API;
    Caption = 'Rental units available for rent, with their customer and status.';
    APIPublisher = 'contoso';
    APIGroup = 'pfxRentals';
    APIVersion = 'v1.0';
    EntityName = 'rentalUnit';
    EntitySetName = 'rentalUnits';
    EntityCaption = 'Rental Unit';
    EntitySetCaption = 'Rental Units';
    SourceTable = "<PFX> Rental Unit";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    // read-only only (§2.2):
    // Editable = false;
    // InsertAllowed = false;
    // ModifyAllowed = false;
    // DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System ID';
                    ToolTip = 'Unique system-assigned identifier for this record. Used as the OData key.';
                    ApplicationArea = All;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the rental unit.';
                    ApplicationArea = All;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies a description of the rental unit.';
                    ApplicationArea = All;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the customer who rents the unit.';
                    ApplicationArea = All;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the rental unit.';
                    ApplicationArea = All;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    ToolTip = 'Specifies when the record was last changed.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}
```

- Uncomment the four guards for a read-only page; leave the page editable otherwise and restrict
  individual fields (`Editable = false` on system fields) — Part 7's first four rows.
- Locked captions (§8.6): drop `EntityCaption`/`EntitySetCaption`, `Locked = true` on the page
  caption and every field caption; tooltips stay translatable.
- Exclude obsolete and localization-range fields (§3.2–§3.3); never expose an enum by ordinal.

## Pre-flight

`ODataKeyFields = SystemId`, `DelayedInsert = true`, the guards present or absent as chosen,
every identifier camelCase ≤ 30 and not reserved, `EntityName` ≠ `EntitySetName` unless a
singleton, every field has the three properties, the file is `<Name>.Page.al`. After the compile,
show the endpoint shape from Appendix A (`…/api/<publisher>/<group>/<version>/companies(<id>)/<entitySet>`).

## Offer at close

*Permission set grants for the page* (required for any non-SUPER consumer) / *An API query for
reporting on the same data* / *Done*.
