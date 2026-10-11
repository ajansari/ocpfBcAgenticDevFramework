# Enum extension

**Read before writing:** Standards §1.9 (ordinals from the project's own range), §8.4;
Appendix B (the base enum's exact name and whether it is extensible — an enum with
`Extensible = false` cannot be extended, and the symbol says so).

## Ask / confirm

Needed: the base enum (*Sales Document Type*, *Item Type*, *Gen. Journal Document Type* — resolved
in the symbols, extensibility confirmed); the values to add with their captions. Say in one line
what the new value will and will not do: a new enum value in a standard enum is just a value —
every `case` in the base app that handles the enum falls through to its `else` for it, so
behaviour attached to the value is a codeunit (event subscribers) the human may want next.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

using Microsoft.Sales.Document;

enumextension <ID> "<PFX> Sales Document Type" extends "Sales Document Type"
{
    value(<ID range number>; "<PFX> Rental")
    {
        Caption = 'Rental';
    }
}
```

- **Ordinals from the project's object ID range** (`50100`, …), never small numbers a later base
  value could take (§1.9).
- Value names carry the prefix.

## Pre-flight

The base enum exists and is extensible; the ordinal is inside the range and unused; no comma in
the caption; the file is `<Name>.EnumExt.al`.

## Offer at close

*A codeunit that handles the new value (event subscribers)* / *Done*.
