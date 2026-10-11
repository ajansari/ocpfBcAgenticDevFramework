# Page — list, card, list part, setup card

**Read before writing:** Standards §1.1–§1.8, §1.4 (Caption, ToolTip, ApplicationArea on every
field), §11.1 and `ocpfFramework/patterns/Pattern-SubPageLink-FilterGroup4.md` for a list part
or any child list, §11.2 for a setup card with a number-series field.

## Ask / confirm

Needed: the source table (just built, or named); which pages (*List*, *Card*, both, *List part*
for a line table, *Setup card* for a setup table); which fields show where (default: every field
in the table's order on the card; the key, description, and the three or four most useful
fields on the list — show the proposal in the confirmation box); whether the list opens the card
(`CardPageId`) — yes by default when both exist; menu placement: `UsageCategory = Lists` for a
list, `Administration` for a setup card, none for a card or a part. No actions unless the human
asked for one.

## Write

List:

```al
namespace <Publisher>.<ExtensionShort>;

page <ID> "<PFX> Rental Units"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "<PFX> Rental Unit";
    CardPageId = "<PFX> Rental Unit Card";
    Caption = 'Rental Units';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the rental unit.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies a description of the rental unit.';
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the rental unit.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
```

Card:

```al
page <ID> "<PFX> Rental Unit Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "<PFX> Rental Unit";
    Caption = 'Rental Unit Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the rental unit.';
                    ApplicationArea = All;
                }
                // every other field, in table order; a second group when the human named one
            }
        }
    }
}
```

- **Every page field carries all three — `Caption`, `ToolTip`, `ApplicationArea = All`
  (Standards §1.4)**, even though the platform would inherit the first two from the table: the
  review reads §1.4 literally, and the analyzers warn on a missing tooltip. The text repeats the
  table field's caption and tooltip word for word, so there is one wording, not two.
- A list that opens a card: `Editable = false` on the list (`CardPageId` set); a list edited in
  place (lookup tables): `Editable` left default, no card.
- **List part** (line table on a parent card): `PageType = ListPart`, the parent card gets
  `part(Lines; "<PFX> Rental Lines") { ApplicationArea = All; SubPageLink = "Document No." =
  field("No."); }`, and the part implements **all six §11.1 elements** (the pattern file has
  the code): the hidden link field, the two-group `OnNewRecord` read, `TestField` in the table's
  `OnInsert`, `DelayedInsert = true`, no `Init()`.
- **Setup card:** `PageType = Card`, `UsageCategory = Administration`, `InsertAllowed = false`,
  `DeleteAllowed = false`, the `OnOpenPage` get-or-insert, and a number-series field as a plain
  table field with `TableRelation = "No. Series"` (§11.2) — never a page variable.
- A `"No."` field on a card whose table numbers from a series: `OnAssistEdit` calling the
  table's `AssistEdit` is a nicety; add it only if the table has the number series.

## Pre-flight

Every field has `ApplicationArea = All` and a `ToolTip`; no field is exposed twice; `CardPageId`
names a page that exists (build the card first when both are in the plan); the file is
`<Name>.Page.al`; a list part has every §11.1 element; `Rec.` on every field reference.

## Offer at close

After a list: *Card page (recommended)* / *Done*. After a card: *List page (recommended if none)*
/ *Done*. After both: *An API page for this table* / *Permission set grants* / *Done*. After a
setup card: *Done*. After a list part: *Done*.
