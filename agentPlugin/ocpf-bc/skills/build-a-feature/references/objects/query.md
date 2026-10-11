# Query (normal)

**Read before writing:** Standards §1.1–§1.8; Appendix B for every table and field.

## Ask / confirm

Needed: the tables and the join; the columns; filters the caller will set (`filter(...)`
elements); aggregation (sum, count, average, min, max) and the grouping that implies; the
intended consumer — a codeunit, a page, a report, or Excel/Power BI (`QueryType = Normal` for
code; a `QueryCategory` when it should appear in a list page's *Reports* menu). Default: a
normal query with the columns the human named.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Customer;

query <ID> "<PFX> Rental Amount by Customer"
{
    QueryType = Normal;
    Caption = 'Rental Amount by Customer';
    QueryCategory = 'Customer List';

    elements
    {
        dataitem(RentalUnit; "<PFX> Rental Unit")
        {
            column(CustomerNo; "Customer No.") { }
            column(TotalAmount; Amount) { Method = Sum; }
            column(Units; "No.") { Method = Count; }
            filter(Status; Status) { }
            filter(StartDate; "Start Date") { }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = RentalUnit."Customer No.";
                column(CustomerName; Name) { }
            }
        }
    }
}
```

- A query used from code is read with `Query.Open()` / `Query.Read()`; show the four-line usage
  in the closing message, not in a generated codeunit nobody asked for.
- `OrderBy = ascending(CustomerNo);` when an order was asked for.

## Pre-flight

Every table, field, and link verified; aggregation methods valid for the field type (no `Sum` on
a `Code`); the file is `<Name>.Query.al`.

## Offer at close

*A page that shows this query* / *A codeunit that reads it* / *Done*.
