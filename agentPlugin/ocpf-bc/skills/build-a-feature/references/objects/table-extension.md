# Table extension

**Read before writing:** Standards §1.1–§1.9, §3.2–§3.3 (never extend with a reference to an
obsolete field), `references/field-types.md`, Appendix B (symbol-verify the base table and its
namespace).

## Ask / confirm

Needed: the base table (from the human's words — *Customer*, *Sales Header*, *Item* — resolved
against the symbols: the table's exact name, number, and namespace; say them), the new fields
with types (inferred and confirmed as one table), and whether any new field should be validated
(a `TableRelation`, a `MinValue`, an `OnValidate` rule the human stated). Ask the base table only
when the free text did not name it, with the two or three likeliest tables as options.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Customer;

tableextension <ID> "<PFX> Customer" extends Customer
{
    fields
    {
        field(<ID range number>; "<PFX> Region Code"; Code[10])
        {
            Caption = 'Region Code';
            ToolTip = 'Specifies the region the customer belongs to.';
            DataClassification = CustomerContent;
            TableRelation = "<PFX> Region";
        }
        field(<next>; "<PFX> Credit Reviewed"; Boolean)
        {
            Caption = 'Credit Reviewed';
            ToolTip = 'Specifies whether the customer''s credit has been reviewed.';
            DataClassification = CustomerContent;
        }
    }
}
```

- **Field numbers come from the project's object ID range** (a field number in a table
  extension must be in the extension's own range, 50000+ for a PTE), never small numbers.
- **Field names carry the prefix** — `"<PFX> Region Code"` — because they live in Microsoft's
  table beside every other extension's fields (AppSourceCop AS0011 wording applies to PTEs as
  good practice; CodeCop will not catch a collision for you).
- `DataClassification` on every added field.
- No key unless the human asked for one and it is needed for a page filter or a report; a key on
  a large standard table is a schema change with a cost.
- An `OnValidate` only for a rule the human stated; nothing speculative.

## Pre-flight

The base table and every `TableRelation` target exist in the symbols with these exact names and
namespaces; the field numbers are inside the range; no obsolete field referenced; the file is
`<Name>.TableExt.al`.

## Offer at close

*Show the fields on the <base table>'s card page* / *…on its list page* / *Both (recommended
when the field is user-entered)* / *Done*. The page extension (`page-extension.md`) follows
immediately when chosen; it is nearly always wanted, so the recommended option says so.
