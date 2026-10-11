# Page extension

**Read before writing:** Standards §1.1–§1.8, §1.4; Appendix B (the base page's exact name and
the anchor control's name come from the symbols, never from memory).

## Ask / confirm

Needed: the base page (*Customer Card*, *Customer List*, *Sales Order* — resolved in the
symbols); the fields to add (usually the table extension just built; otherwise standard fields
the human wants surfaced); where (the anchor: `addlast(General)` on a card, `addlast(Control1)`
or the repeater's name on a list, `addafter("<Field>")` when the human named a neighbour — read
the repeater and group names from the page's symbol, do not guess `General`); whether a field is
editable on the list. One confirmation box with the anchor named.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Customer;

pageextension <ID> "<PFX> Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("<PFX> Region Code"; Rec."<PFX> Region Code")
            {
                Caption = 'Region Code';
                ToolTip = 'Specifies the region the customer belongs to.';
                ApplicationArea = All;
            }
            field("<PFX> Credit Reviewed"; Rec."<PFX> Credit Reviewed")
            {
                Caption = 'Credit Reviewed';
                ToolTip = 'Specifies whether the customer''s credit has been reviewed.';
                ApplicationArea = All;
            }
        }
    }
}
```

- The page-field **name** carries the prefix too (`field("<PFX> Region Code"; …)`), so it cannot
  collide with another extension's control on the same page.
- An action: only when asked — `actions { addlast(Processing) { action("<PFX> Review Credit")
  { ApplicationArea = All; Caption = 'Review Credit'; ToolTip = '…'; Image = Approve; trigger
  OnAction() … } } }` with the logic in a codeunit (`codeunit.md`), never in the trigger.
- Never change a standard field's properties (`modify(...)`) unless the human explicitly asked
  and understands it affects every user of that page.

## Pre-flight

The base page, the anchor control, and every `Rec.` field exist in the symbols (the table
extension compiles first); `Caption`, `ToolTip`, and `ApplicationArea` on every field (§1.4); the file is
`<Name>.PageExt.al`.

## Offer at close

*The same fields on the <other page: list or card>* (when the base table has both and only one
was extended) / *Done*.
