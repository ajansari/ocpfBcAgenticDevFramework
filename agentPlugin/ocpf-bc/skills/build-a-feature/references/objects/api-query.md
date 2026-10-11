# API query

**Read before writing:** Standards Part 2 (§2.5–§2.7 apply to queries), §4.1, §4.4, §8.6;
Appendix B for every table and field; Appendix A for the URL.

## Ask / confirm

Needed: the tables (one, or a parent with a joined child), the columns with camelCase
identifiers, any filter columns, `APIPublisher` / `APIGroup` / `APIVersion` / `EntityName` /
`EntitySetName` (inferred as for an API page), caption locking (§8.6). An API query is read-only
by nature; say so when the human asked for "an API" without saying which — a query is the right
answer for aggregations and joins, a page for CRUD.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Customer;

query <ID> "<PFX> Rental Units by Customer"
{
    QueryType = API;
    APIPublisher = 'contoso';
    APIGroup = 'pfxRentals';
    APIVersion = 'v1.0';
    EntityName = 'rentalUnitByCustomer';
    EntitySetName = 'rentalUnitsByCustomer';
    EntityCaption = 'Rental Unit by Customer';
    EntitySetCaption = 'Rental Units by Customer';
    Caption = 'Rental units joined to their customer, for reporting.';

    elements
    {
        dataitem(RentalUnit; "<PFX> Rental Unit")
        {
            column(systemId; SystemId) { Caption = 'System ID'; }
            column(no; "No.") { Caption = 'No.'; }
            column(description; Description) { Caption = 'Description'; }
            column(amount; Amount) { Caption = 'Amount'; }
            column(status; Status) { Caption = 'Status'; }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = RentalUnit."Customer No.";
                SqlJoinType = LeftOuterJoin;
                column(customerNo; "No.") { Caption = 'Customer No.'; }
                column(customerName; Name) { Caption = 'Customer Name'; }
            }
        }
    }
}
```

- Aggregations: `column(totalAmount; Amount) { Method = Sum; }` with the non-aggregated columns
  acting as the group; say which columns group.
- `ToolTip` is not a query-column property; the `Caption` carries the meaning (§2.5).

## Pre-flight

Identifiers camelCase ≤ 30; every table, field, and link field verified; `EntityName` /
`EntitySetName` within §4.4's limits; the file is `<Name>.Query.al`.

## Offer at close

*Permission set grants for the query* / *Done*.
