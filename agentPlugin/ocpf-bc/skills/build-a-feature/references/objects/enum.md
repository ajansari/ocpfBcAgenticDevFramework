# Enum

**Read before writing:** Standards §1.9 in full (never `Option`; `Extensible` is a recorded
decision; value 0 blank; ordinals permanent; captions without commas), §8.4.

## Ask / confirm

Needed: the name; the values in order (from the human's words — *Open, Active, Closed*); whether
the list may grow (`Extensible = true`, the default recommendation: statuses, types, categories)
or is closed code (`Extensible = false`, with the reason); whether it is used as a table field
(then value 0 is blank). One box: the value list with ordinals, `Extensible` as a question with
*true (recommended)* first.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

enum <ID> "<PFX> Rental Status"
{
    Extensible = true;
    Caption = 'Rental Status';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Open)
    {
        Caption = 'Open';
    }
    value(2; Active)
    {
        Caption = 'Active';
    }
    value(3; Closed)
    {
        Caption = 'Closed';
    }
}
```

- Ordinals `0, 1, 2, …` for a new enum; value names in PascalCase without spaces where
  possible (`"On Hold"` quoted when a space is wanted in the name).
- `Extensible` written explicitly either way.
- An enum that implements an interface (`Implements`) is a design beyond a quick mod — say so
  and offer Lite if that is what the human needs.

## Pre-flight

No comma in any caption; value 0 blank when used as a table field; the file is `<Name>.Enum.al`;
every `case` over it (in any codeunit built later this session) has an `else`.

## Offer at close

*The table field that uses it* (when a table is in the plan or was just built) / *Done*.
