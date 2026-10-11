# Field types — infer first, confirm once

The human says what the fields are called and, sometimes, what they hold. The agent proposes the
AL type for every field in **one table in one question**, and comes back only on what the human
changes or on a given type that is wrong. Standards §1.9 (enums, never options), §4.1 (camelCase
API identifiers), §4.2 (BC abbreviations), §4.3 (reserved words), §11.2 (number-series fields).

## Inference from the name

Match the field name (case-insensitive, after the prefix) in this order; the first match wins.
Say the inferred type and length in the confirmation table; the human corrects it there.

| Name looks like | Type | Why |
|---|---|---|
| `No.`, `Code`, `<Something> No.`, `<Something> Code` | `Code[20]` | BC's key convention; `Code[10]` for short codes the human says are short |
| `Name`, `Description`, `Title` | `Text[100]` | BC's `Name`/`Description` length |
| `Description 2`, `Comment`, `Notes`, `Remarks` | `Text[250]` (`Notes` with many lines: `Blob` with a `Text` accessor is a design question — ask) | |
| `Address`, `Address 2` | `Text[100]` | BC's `Address` |
| `City` | `Text[30]`; `Post Code` `Code[20]`; `Country/Region Code` `Code[10]` with `TableRelation = "Country/Region"`; `County` `Text[30]` | BC's address block |
| `Phone No.`, `Fax No.` | `Text[30]`, `ExtendedDatatype = PhoneNo` | |
| `E-Mail` | `Text[80]`, `ExtendedDatatype = EMail` | |
| `Home Page`, `URL`, `Link` | `Text[80]`, `ExtendedDatatype = URL` | |
| `Amount`, `Price`, `Cost`, `Total`, `Unit Price`, `Line Amount` | `Decimal`, `AutoFormatType = 1` (amount) | money; `AutoFormatType = 2` with an `AutoFormatExpression` for a currency code field when there is one |
| `Quantity`, `Qty.`, `Units`, `Count` | `Decimal`, `DecimalPlaces = 0 : 5` | BC quantities are decimals |
| `Percent`, `Pct`, `%`, `Rate`, `Discount %` | `Decimal`, `DecimalPlaces = 0 : 5`, `MinValue = 0`, `MaxValue = 100` for a percentage | the `%` character is not an identifier — `Pct` (§4.1) |
| `Weight`, `Volume`, `Length`, `Height`, `Width` | `Decimal` | |
| `Date`, `<Something> Date`, `Start Date`, `End Date`, `Due Date`, `Posting Date` | `Date` | never `DateTime` unless the time of day matters — ask only when the name says *Time* |
| `Time`, `<Something> Time` | `Time` | |
| `Date Time`, `Timestamp`, `Created At`, `<Something> At` | `DateTime` | |
| `Blocked`, `Active`, `Enabled`, `Closed`, `Is <Something>`, `Has <Something>`, `Allow <Something>` | `Boolean` | name it without *Is*/*Has* unless BC does (`Blocked`, not `Is Blocked`) |
| `Status`, `Type`, `Category`, `Kind`, `Method`, `Reason`, `Priority`, `Level` | **`Enum`** — a new enum object with the values the human names, `Extensible = true` unless they say the list is closed (§1.9) | never `Option` |
| `<Entity> No.` or `<Entity> Code` where `<Entity>` is a BC master (`Customer`, `Vendor`, `Item`, `Location`, `Salesperson`, `Resource`, `Employee`, `G/L Account`, `Dimension`, `Unit of Measure`, `Currency`, `Payment Terms`, `Job`/`Project`) | `Code[20]` (`Code[10]` for `Location`, `Currency`, `Payment Terms`, `Salesperson`, `Unit of Measure`) with `TableRelation` to that table — the exact table and key from the symbols, never from memory (Standards Part 6: modern table names, `Project` not `Job`) | lookup |
| `No. Series` | `Code[20]`, `TableRelation = "No. Series"` on a setup table; numbering per §11.2 | |
| `Id`, `GUID`, `<Something> Id` | `Guid` | or ask whether `SystemId` already serves |
| `Image`, `Picture`, `Photo` | `Media` (one) / `MediaSet` (several) | |
| `Document`, `Attachment`, `File` | not a field — `Document Attachment` is BC's way; offer it as a page action instead | |
| `Sequence`, `Line No.`, `Entry No.`, `Sort Order` | `Integer` | `Entry No.` with `AutoIncrement = true` only on a ledger-style table |
| `Last Modified`, `Created By`, `Modified By` | not a field — `SystemCreatedAt`, `SystemModifiedAt`, `SystemCreatedBy`, `SystemModifiedBy` exist on every table; say so and drop it | |

Anything that matches nothing: ask, as one question with the three likeliest types as options.

## Validating a type the human gave

Accept it unless one of these holds, then propose the fix as the first option:

- `Option` → `Enum` (§1.9), always.
- `Text` with no length → `Text[100]` (or `[250]` for a description-like name); `Code` with no
  length → `Code[20]`; a `Text` longer than 2048 → a `Blob`, and ask.
- `Text` for something that is a key, a code, or a relation → `Code`.
- `Integer` for money or quantity → `Decimal`.
- `DateTime` for a date with no time of day in the name → `Date`, offered, not forced.
- `Boolean` named with a *Not* → the positive name (`Blocked`, not `Not Allowed`).
- A `Decimal` percentage → `DecimalPlaces` and bounds as above.
- A length above BC's for the same concept (`Name` `Text[150]`) → BC's length, said with the
  reason: a page or an API consumer that copies into a standard field would truncate.
- A relation named but no table → the table, from the symbols.

## The confirmation table

One box, one question, the whole table in the question text, options *Looks right — build it*
(recommended) / *Change something*. On *Change something*, ask only for the field or fields that
change, as free text in that one follow-up, then show the table once more.

```
| # | Field | Type | Notes |
|---|---|---|---|
| 1 | No. | Code[20] | primary key; No. Series? → setup table + §11.2 |
| 2 | Description | Text[100] | |
| 3 | Customer No. | Code[20] | TableRelation Customer |
| 4 | Start Date | Date | |
| 5 | Amount | Decimal | AutoFormatType 1 |
| 6 | Status | Enum "PFX Rental Status" | values: Open, Active, Closed — extensible |
```

The primary key is always in the table and always confirmed: `No.` (`Code[20]`) when the entity is
a master record; a parent key plus `Line No.` for a line; the human's own choice when they said
one.

## Identifiers

Field names follow BC's naming (`No.`, `Posting Date`, `Unit Price`); API identifiers are the
camelCase of the name with BC's abbreviations expanded or kept per §4.1–§4.2 (`no`,
`postingDate`, `unitPrice`), 30 characters or fewer, never a reserved word (§4.3). Every field on
a page or API page gets `Caption`, `ToolTip`, `ApplicationArea = All` (§1.4); the `ToolTip` is a
sentence that says what the field holds, starting *Specifies* (§2.6).
