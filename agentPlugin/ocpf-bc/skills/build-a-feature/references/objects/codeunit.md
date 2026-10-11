# Codeunit — event subscribers, or a small set of procedures

**Read before writing:** Standards §1.1–§1.8, §1.7 and §8.3 (every message a `Label` with a
`Comment` on placeholders), Part 10 (§10.1 subscribe, never modify; §10.2–§10.3 only if the
codeunit publishes events), Appendix B (the exact event signature from the symbols — never from
memory); `ocpfFramework/patterns/` for any pattern that matches the rule being written.

## Ask / confirm

Needed: **what should happen and when** — the human's rule in one or two sentences (*"when a
customer is blocked, clear the region code"*; *"a procedure that calculates the rental total"*);
from it, the shape: **event subscriber** (a trigger on a standard table or codeunit: find the
event in the symbols — `OnAfterValidateEvent` on the field, `OnBeforePostSalesDoc` and the like
— and show its name and signature in the confirmation box), **a procedure set** (public
procedures called from a page action or another object), or **single-instance** (state shared
in a session — rare in a quick mod; ask why). The confirmation box shows the rule restated, the
event or procedure signatures, and the error or message texts as labels. Logic beyond what the
human stated is not added.

## Write

The two skeletons are shapes with a placeholder rule; replace the body with the human's rule and
keep nothing unused (an unused label or variable is a CodeCop warning and fails the 0 / 0 gate).

Event subscriber:

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Customer;

codeunit <ID> "<PFX> Customer Events"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, Blocked, false, false)]
    local procedure ClearRegionOnBlocked(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    begin
        if Rec.Blocked = Rec.Blocked::" " then
            exit;
        Rec."<PFX> Region Code" := '';
    end;
}
```

Procedure set:

```al
codeunit <ID> "<PFX> Rental Mgt."
{
    procedure CalculateTotal(var RentalUnit: Record "<PFX> Rental Unit"): Decimal
    begin
        RentalUnit.TestField("Start Date");
        if RentalUnit.Amount = 0 then
            Error(NothingToCalculateErr, RentalUnit."No.");
        exit(RentalUnit.Amount);   // the human's rule goes here, and nothing else
    end;

    var
        NothingToCalculateErr: Label 'There is nothing to calculate for rental unit %1.', Comment = '%1 = rental unit number';
}
```

- The subscriber's parameter list is copied from the event's signature in the symbols; a
  mismatch compiles to a warning that the subscriber never fires.
- `local` on every subscriber; `procedure` without `local` only for what another object calls.
- `Rec.` qualification; no `with`; no `Commit` in a subscriber; no UI (`Message`, `Confirm`) in a
  table-event subscriber — raise an error with a label or do nothing.
- Logic that belongs to a page action lives here and the action calls it (`page-extension.md`).

## Pre-flight

The event exists with that signature; every text is a label with an AA0074 suffix (`Err`, `Msg`,
`Qst`, `Lbl`) and a placeholder comment; no empty procedure; the file is `<Name>.Codeunit.al`.

## Offer at close

*A page action that calls it* (procedure set) / *Done*.
