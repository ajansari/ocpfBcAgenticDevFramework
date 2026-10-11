# Report extension

**Read before writing:** Standards §1.1–§1.8, Appendix B (the base report's exact name, its
dataitem names, and the column names come from the symbols — report extensions reference them
by name and a wrong one fails only at compile).

## Ask / confirm

Needed: the base report (*Customer - List*, *Sales - Invoice*, …; resolved in the symbols — most
standard documents are now Word/RDLC reports whose datasets are extendable); the columns to add
(usually the fields of a table extension just built) and the dataitem they belong to; whether a
request-page field is wanted; whether a **layout** is to be added (an extension can add its own
layout: Excel or RDLC, same choices as `report.md`) or the human will adjust the layout in BC.
Say plainly that a dataset extension alone changes nothing visible until a layout uses the new
columns.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Reports;   // report 101 "Customer - List" lives here, not in Microsoft.Sales.Customer — read the namespace from the symbol

reportextension <ID> "<PFX> Customer List" extends "Customer - List"
{
    dataset
    {
        add(Customer)
        {
            column(PFXRegionCode; "<PFX> Region Code") { IncludeCaption = true; }
        }
    }

    // only when a layout was chosen:
    rendering
    {
        layout("<PFX> Customer List (Excel)")
        {
            Type = Excel;
            LayoutFile = './src/Reports/PFXCustomerList.xlsx';
            Caption = 'Customer List with Region (Excel)';
        }
    }
}
```

- `add(<dataitem>)` names the base report's dataitem exactly as the symbol shows it.
- Column names carry the prefix; `IncludeCaption = true` when the caption should be available.
- `requestpage { layout { addlast(Options) { field(...) } } }` only when asked.

## Pre-flight

Base report, dataitem, and every field verified in the symbols; column identifiers valid; a
layout file present if one was declared; the file is `<Name>.ReportExt.al`.

## Offer at close

*Done* (a layout change in BC's Report Layouts is the human's next step; say so in one line when
no layout was generated).
