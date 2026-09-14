# OCPF AL Development Standards Guide

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

**Version:** 1.1.0.0
**Last Updated:** September 14, 2026

> **Audience:** Human developers and agentic (AI) developers building Business Central AL
> Per-Tenant Extensions (PTEs).
>
> **Purpose:** The detailed, project-agnostic *rules* for writing AL in a PTE — coding standards,
> API page design, field inclusion and exclusion, identifier naming, module and ID allocation,
> gap analysis, and anti-patterns.
>
> **Relationship to the runbook:** This guide is the companion to `BC_App_Build_Routine_Agent.md`,
> the OnlyCopilotFans Agentic Dev Framework runbook. **The runbook drives the *sequence*** — what
> happens when, who signs off, which gate opens the next step. **This guide holds the *rules*
> that sequence applies.** The runbook cites it as **Standards §**. Where the two ever appear to
> disagree about *process*, the runbook wins; where they appear to disagree about an *AL rule*,
> this guide wins — but neither should happen, because neither document restates the other's
> content (see *What is deliberately not here* below).
>
> **Authoritative-source rule:** Every name, ID, version, prefix, namespace, and quoting decision
> comes from the **Project Parameters** block that the runbook fills in interactively at **Step
> 01** — that filled-in block, in the project's own repository, is the single source of truth.
> Never hardcode a publisher, prefix, namespace, version, or object ID anywhere in AL code, and
> never restate a Step 01 parameter in this guide: this guide deliberately carries no copy of the
> intake sheet, so the two can never drift apart or contradict each other.

### What is deliberately *not* here

Each of the following lives in exactly one place — the runbook — and this guide points there
rather than keeping a second, silently-diverging copy:

| Topic | Where it actually lives |
|---|---|
| The intake sheet / project parameters (extension identity, ID ranges, naming & API parameters, platform & runtime, feature flags, onboarding, model roles, `.gitignore` policy) | Runbook **Step 01**, asked interactively |
| Required project documents, and the phase/stage lifecycle | Runbook **ALL ALONG → Document**, and its DEFINE → DESIGN → BUILD → PROVE phase structure |
| What makes a TDD self-sufficient | Runbook **Step 03** |
| The sanity-check checklist | Runbook **Step 04** |
| The pre-flight validation checklist (pre- and post-generation) | Runbook **Step 05** — the canonical list |
| Batching, compile cadence, and the zero-errors/zero-warnings gate | Runbook **Operating Rules 3, 4, 5** |
| Treating a compiler error as a systemic signal | Runbook **Operating Rule 4** |
| Verifying against symbol files rather than model memory | Runbook **Operating Rule 2** (procedure in Appendix B below) |
| The ChangeLog entry format | Runbook **ALL ALONG → Track Changes** |
| The Object Register | Runbook **ALL ALONG → Document** |

---

## Part 1 — AL Coding Standards

### 1.1 File Header — Required on Every AL File

```al
namespace <Publisher>.<ExtensionShort>;

using <Microsoft.Or.System.Namespace>;
```

- One `namespace` declaration per file, always first — the value comes from the runbook's Step 01
  parameters. **If Step 01's `Use Namespace` parameter is `No`, omit the `namespace` line
  entirely** from every generated file; nothing else in this guide changes.
- One `using` directive per file; source it directly from the BC symbol file for that object's
  source table — never from documentation or memory.
- Exception: `System.Automation` for approval/workflow objects (not `Microsoft.*`).
- Never use sub-namespaces within a single extension. The namespace is flat; API groups provide
  the logical separation.

### 1.2 `Rec.` Qualification — `NoImplicitWith`

`NoImplicitWith` is enforced on every project built with this framework. It is a fixed framework
decision, not a per-project choice (runbook §1.5), and is declared in `app.json`:

```json
"features": ["NoImplicitWith"]
```

Every field source reference must therefore be prefixed with `Rec.`:

```al
// Correct
field(myField; Rec."My Field") { ... }

// Wrong — fails with NoImplicitWith
field(myField; "My Field") { ... }
```

### 1.3 AL API Page Template

Substitute every bracketed value using the runbook's Step 01 parameters. Do not add properties,
triggers, or code blocks unless specifically required.

```al
namespace <Publisher>.<ExtensionShort>;

using <Microsoft.Module.Feature>;

page <ObjectID> "<EntitySetName>"
{
    PageType = API;
    Caption = '<Complete sentence describing what this entity represents.>';
    APIPublisher = '<publisher>';
    APIGroup = '<prefix>_<groupName>';
    APIVersion = '<version>';
    EntityName = '<entityNameSingular>';
    EntitySetName = '<entitySetNamePlural>';
    SourceTable = <SourceTableName>;
    ODataKeyFields = SystemId;
    DelayedInsert = true;   // Editable pages only. Use "Editable = false;" for read-only pages.

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System ID';
                    ToolTip = 'Unique system-assigned identifier for this record. Used as the OData key.';
                    ApplicationArea = All;
                }
                field(<camelCaseIdentifier>; Rec."<Source Field Name>")
                {
                    Caption = '<Human-readable label>';
                    ToolTip = '<Specifies the ... sentence.>';
                    ApplicationArea = All;
                }
                // ... remaining fields
            }
        }
    }
}
```

> Omit the `namespace` line if Step 01's `Use Namespace` parameter is `No` (§1.1).

### 1.4 Mandatory Field Properties

Every field on every page must have all three. No exceptions.

| Property | Requirement | Notes |
|---|---|---|
| `Caption` | Required | Source from BC field metadata, or the field name in title case. Never `CaptionML` (§1.7). |
| `ToolTip` | Required | Source from BC field metadata, or `'Specifies the <FieldName>.'` Never `ToolTipML` (§1.7). |
| `ApplicationArea` | `All` | Always. Omitting it breaks visibility in both client and API contexts. |

### 1.5 No Dead Code

- No empty triggers (`OnInsert`, `OnModify`, etc. must not appear unless they contain logic)
- No commented-out fields
- No duplicate field exposures
- No placeholder `// TODO` comments in committed code

### 1.6 Indentation Standard

Use 4-space indentation per AL level. Fields inside `repeater(Group)` are 4 levels deep
(16 spaces):

```al
    layout                    // 4 spaces
    {
        area(content)         // 8 spaces
        {
            repeater(Group)   // 12 spaces
            {
                field(...)    // 16 spaces
                {
                    Caption   // 20 spaces
```

**Do not mix tabs and spaces.** Normalize every file to spaces before committing.

### 1.7 Translatable Text — Label Syntax Only, Never Multilanguage (ML) Properties

Every piece of user-facing text — captions, tooltips, option captions, instructional text, and
every message, error, confirmation, and notification string — is written **once, in the
project's default language**, using the single-language property or a `Label`. Translations
never live in AL code; they live in XLIFF (`.xlf`) translation files.

```al
// Correct — single-language label syntax; picked up in the generated .xlf file
Caption = 'Credit Memo No.';
ToolTip = 'Specifies the number of the credit memo.';
OptionCaption = 'Open,Released,Closed';

var
    PostedMsg: Label 'Document %1 was posted.', Comment = '%1 = Document No.';

// Wrong — multilanguage (ML) syntax; deprecated, and never reaches the .xlf file
CaptionML = ENU = 'Credit Memo No.', ENA = 'Credit Note No.';
ToolTipML = ENU = 'Specifies the number of the credit memo.';

var
    PostedMsg: TextConst ENU = 'Document %1 was posted.';
```

**Never use any of these**, in new code or in a modification to existing code:

| Deprecated | Use instead |
|---|---|
| `CaptionML` | `Caption` |
| `ToolTipML` | `ToolTip` |
| `OptionCaptionML` | `OptionCaption` |
| `InstructionalTextML` | `InstructionalText` |
| `PromotedActionCategoriesML` | `PromotedActionCategories` |
| `RequestFilterHeadingML` | `RequestFilterHeading` |
| `AboutTitleML` | `AboutTitle` |
| `AboutTextML` | `AboutText` |
| `TextConst` (data type) | `Label` (data type) |

**Why this is unconditional:**

- **The ML syntax is deprecated.** Compiler warning **AL0424** — *"The multilanguage syntax is
  being deprecated. Please update to the new syntax."* It may still compile today; that is not a
  reason to write it.
- **ML properties and `TextConst` are not included in the generated `.xlf` file** — Microsoft
  Learn, [*Working with translation files*](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files). A string written that way is invisible to every
  translation workflow, so the app silently shows untranslated (or wrong-regional) text to
  exactly the users it was meant to serve.
- **AppSource requires XLIFF translation files.** An extension carrying ML syntax is not on the
  path to AppSource.
- **The compiler will not reliably catch it.** AL0424 fires only when `app.json`'s `features`
  includes `TranslationFile`. On a project without that flag, `CaptionML` compiles with **no
  warning at all** — so the zero-warnings gate cannot be relied on to find it, and code review
  must (Part 7).

**Label attributes.** Use `Comment` to tell the translator what every placeholder (`%1`, `%2`, …)
stands for — required whenever a string has a placeholder. Use `Locked = true` for strings that
must never be translated (telemetry event IDs, API-facing technical values, fixed codes). Use
`MaxLength` when the string lands somewhere with a length limit.

**Found in existing code** (human-written, inherited, or pasted in): it is a Code Review finding,
not a style note. Refactor to the single-language property or `Label`, keeping the
default-language text as the value; move any other-language text out of AL and into that
language's `.xlf` file rather than discarding it.

**Conflicting older guidance.** AL Guidelines (<https://alguidelines.dev>) still hosts legacy
*C/AL Coding Guidelines* pages — *"CaptionML on System Pages"* and *"Using OptionCaptionML"* —
that recommend ML properties. They predate AL and XLIFF; this section supersedes them. AL
Guidelines' current *Vibe Coding Rules* agree with this section (labels for every message,
`Comment` for placeholders, `Locked = true` for technical text).

> *Sources and attribution:* the AL0424 message text and the list of ML properties excluded from
> `.xlf` files are quoted or adapted from Microsoft Learn — [Compiler Warning
> AL0424](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al424)
> and [Working with translation
> files](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files)
> — © Microsoft Corporation, licensed under
> [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); reorganized into the table above. The
> AL0424 message text follows the compiler's wording as reported in
> [microsoft/AL issue #5789](https://github.com/microsoft/AL/issues/5789).

---

## Part 2 — API Page Design Rules

> Entity-naming parameters (`APIPublisher`, `APIGroup`, `APIVersion`, `EntityName`,
> `EntitySetName`, and the object prefix they derive from) come from the runbook's Step 01
> parameters — never hardcoded in AL files.

### 2.1 OData Key

```al
ODataKeyFields = SystemId;
```

- **Always use `SystemId`** — a system-generated GUID present on every BC table since v15
  (2019 Wave 2).
- Never use business keys (document number, customer number, etc.) as the OData key. Business
  keys change; `SystemId` never does.
- Business key fields are still exposed as regular fields, for `$filter` use.

### 2.2 Editable vs. Read-Only Pages

**Rule:** Set based on data mutability, not developer preference.

| Data Category | Setting | Implementation |
|---|---|---|
| Master data (Customers, Vendors, Items, Bank Accounts) | Editable | `DelayedInsert = true` |
| Setup / config (Posting Groups, VAT Setup, Currencies, Dimensions, Payment Terms) | Editable | `DelayedInsert = true` |
| Open documents (Sales/Purchase Orders, Invoices, Quotes, Credit Memos, Blanket Orders) | Editable | `DelayedInsert = true` |
| Journal lines (General Journal Lines) | Editable | `DelayedInsert = true` |
| Posted ledger entries (GL Entry, Cust/Vend Ledger, Value Entries) | Read-only | `Editable = false` |
| Posted documents (Posted Invoices, Shipments, Receipts, Return docs) | Read-only | `Editable = false` |
| Audit / system tables (GL Register, Approval Entry, Workflow Instances) | Read-only | `Editable = false` |
| Registers and sub-ledgers | Read-only | `Editable = false` |

`DelayedInsert = true` is mandatory on all editable API pages — without it, OData inserts fail
silently. Do not set `DelayedInsert` on read-only pages; it is irrelevant and misleading.

### 2.3 Document-Type Filtered Pages (`SourceTableView`)

When a single BC table stores multiple document types (Sales Header, Purchase Header), create one
API page per type and apply a `SourceTableView` filter:

```al
// Single-word enum values — NO quotes inside const()
SourceTableView = where("Document Type" = const(Quote));
SourceTableView = where("Document Type" = const(Order));
SourceTableView = where("Document Type" = const(Invoice));

// Multi-word enum values — double-quotes required inside const()
SourceTableView = where("Document Type" = const("Credit Memo"));
SourceTableView = where("Document Type" = const("Blanket Order"));
SourceTableView = where("Document Type" = const("Return Order"));
```

**Rule:** Quote only when the enum value contains spaces. Never quote single-word values — that
causes a parser error.

### 2.4 Header and Line Pages

When an entity has both a header and lines (e.g., Sales Order + Sales Order Lines):

- Create two separate top-level API pages.
- Do not nest lines as a sub-page on the header.
- OData consumers join on the document number field using `$filter`.
- Example (prefix `acme`): Header `EntityName = 'acmeSalesOrder'` / `EntitySetName =
  'acmeSalesOrders'`; Lines `EntityName = 'acmeSalesOrderLine'` / `EntitySetName =
  'acmeSalesOrderLines'`.

### 2.5 Page Caption

Write the page `Caption` as a complete sentence describing the entity. It flows into OData
`$metadata` as the entity description and must be useful to a developer or AI agent discovering
the schema:

```al
// Good
Caption = 'Represents posted general ledger entries, the permanent audit trail of all financial transactions.';

// Bad
Caption = 'GL Entries';
```

### 2.6 Field ToolTips as Self-Describing Schema

ToolTips flow into OData `$metadata` as property-level descriptions. Write them for API
consumers, not just UI users:

```al
// Good
ToolTip = 'Specifies the G/L account number to which the entry is posted.';

// Acceptable fallback (no BC source tooltip exists)
ToolTip = 'Specifies the G/L Account No.';

// Bad — no information value
ToolTip = 'G/L Account No.';
```

---

## Part 3 — Field Inclusion & Exclusion Rules

> All inclusion and exclusion is governed by the **Localization** parameter set at runbook Step 01
> §1.1. Concrete ID ranges below are worked examples for `Localization = W1`; for any other
> target, apply the same logic against that localization's applicable ranges and verify each
> field in the symbol file.

### 3.1 Fields to Include

- Standard BC fields allowed by the Localization parameter.
  - For `W1`: field IDs **1–9,999** and **99,000,000+**.
  - For a specific localization (e.g., `NA`, `EU`): the W1 range **plus** the fields applicable to
    that localization.
- Fields with `ObsoleteState = Active` only
- `Media` and `MediaSet` fields (the BC API framework streams these as OData URLs)
- FlowFields with safe read operations (e.g., calculated balances)
- All applicable fields, regardless of whether they appear on any UI card or list page

### 3.2 Fields to Exclude — Mandatory

| Category | Exclusion Rule | Rationale |
|---|---|---|
| Localization-specific fields | Per the Localization parameter. For `W1`: exclude all field IDs **10,000–89,999**. For a specific localization: exclude fields outside that localization's applicable range. Verify each field's classification in the symbol file. | Prevents exposing irrelevant/region-specific data and protects deployment portability. |
| Obsolete pending | `ObsoleteState = Pending` — **all**, unconditionally | Platform has flagged it for removal; do not expose it in new builds. |
| Obsolete removed | `ObsoleteState = Removed` | Already removed from the platform. |
| BLOB fields | Type = `Blob` | Binary data; no OData serialization value. |
| FlowFilter fields | Class = `FlowFilter` | Cannot be serialized via OData. |
| Localization-specific tables | Verify each table against the Localization parameter; exclude tables that do not apply to the target (e.g., for `W1`: US Sales Tax, GST/HST, country-specific ledger tables). | Same principle as field-level localization, at table level. |

> **Obsolete Pending — Strict Rule:** Exclude all `ObsoleteState = Pending` fields regardless of
> `ObsoleteRemovalVersion` or `ObsoleteTag`. Do not evaluate timelines. A newly built extension
> must not expose fields scheduled for removal.

### 3.3 Code Functions to Exclude Because of Obsolescence

When referencing BC base-app codeunits, procedures, or events in extension logic:

- Exclude all calls to procedures where `ObsoleteState = Pending` or `Removed`.
- Do not subscribe to events marked obsolete.
- Exclude any helper/wrapper that depends on fields or symbols already obsolete in the target BC
  version.
- Check `ObsoleteReason` in the symbol file for the recommended replacement.
- Verify all codeunit and procedure references against the current symbol file — do not rely on
  documentation or AI knowledge. Preserve an obsolete construct only if the project parameters
  explicitly allow an exception.

### 3.4 Field Verification

**Always verify against BC symbol files.** Human-written TDDs contain mistakes; the two most
common:

- **Wrong table numbers** — verify every table ID against the symbol file before writing the TDD.
- **Wrong `using` directive namespaces** — source every `using` line from the symbol file, not
  from documentation or memory.

The step-by-step verification procedure is in **Appendix B**.

---

## Part 4 — Identifier Naming Rules

### 4.1 Field Identifiers — camelCase

Convert BC field names to camelCase. Apply in order:

| Rule | Example (Before → After) |
|---|---|
| Strip spaces; first word lowercase, subsequent words capitalized | `"G/L Account No."` → `gLAccountNo` |
| Remove dots, slashes, hyphens (treat as word separators) | `"Credit Memo No."` → `creditMemoNo` |
| Remove parentheses and quotation marks | `"Customer (No.)"` → `customerNo` |
| Replace `%` with a `Pct` suffix | `"Payment Discount %"` → `paymentDiscountPct` |
| Remove `$` | `"Amount ($)"` → `amount` |
| Apply BC standard abbreviations (§4.2) when the identifier exceeds 30 characters | `generalBusinessPostingGroup` (28) — OK; `generalBusinessPostingGroupCode` (30) — borderline, verify |
| Reserved AL keywords: suffix with type (§4.3) | `area` → `areaCode` |

**Hard limit: 30 characters.** AL will not compile identifiers longer than 30 characters.
Validate every identifier before committing.

### 4.2 BC Standard Abbreviations

Use these when an identifier approaches or exceeds 30 characters. Stay consistent with BC's own
conventions.

| Full Word | Abbreviation |
|---|---|
| General | Gen |
| Business | Bus |
| Product | Prod |
| Vendor | Vend |
| Customer | Cust |
| Credit Memo | CrMemo |
| Purchase | Purch |
| Detailed | Dtld |
| Ledger | Ledg |
| Entry / Entries | Entry / Entries (do not abbreviate unless necessary) |
| Posting | Posting (do not abbreviate unless necessary) |
| Application | Appl |
| Transaction | Trans |
| Description | Desc |
| Amount | Amt |
| Number | No |
| Quantity | Qty |

### 4.3 Reserved AL Keyword Conflicts

When a camelCase identifier matches an AL or layout keyword, suffix it with the field's data type
name or a clarifying noun. Never use the bare keyword.

| Conflicting Name | Use Instead | Type Suffix |
|---|---|---|
| `area` | `areaCode` | Code |
| `group` | `groupCode` | Code |
| `value` | `fieldValue` | (context-dependent) |
| `key` | `keyValue` | Value |
| `label` | `labelText` | Text |
| `trigger` | *(rename entirely)* | — |
| `type` | `typeOption` | Option |
| `name` | `nameText` *(only if a collision exists)* | Text |

### 4.4 `EntitySetName` and `EntityName` Character Limits

- Both must be ≤ 30 characters **including** the prefix.
- Apply the abbreviations in §4.2 to the name portion, not to the prefix.
- Pre-validate every name before adding it to the TDD.

| Full Name (chars) | Shortened (chars) |
|---|---|
| `<prefix>GeneralBusinessPostingGroups` (33 w/ a 4-char prefix) | `<prefix>GenBusPostingGroups` (24) |
| `<prefix>GeneralProductPostingGroups` (32) | `<prefix>GenProdPostingGroups` (25) |
| `<prefix>DetailedVendorLedgerEntries` (32) | `<prefix>DtldVendorLedgEntries` (25) |
| `<prefix>PostedPurchaseCreditMemoLines` (34) | `<prefix>PostedPurchCrMemoLines` (26) |

---

## Part 5 — Module & ID Allocation Strategy

### 5.1 Group Objects into Logical Modules Before Allocation

Before assigning any object IDs:

1. List all planned objects.
2. Group them into functional modules (e.g., CoreFinancial, MasterData, Sales, Purchasing).
3. Assign contiguous ID blocks to each module.
4. Reserve growth buffers (minimum 20% of each block unallocated).
5. Reserve a tail block at the end of the overall range for cross-module additions.

**Never scatter IDs randomly.** Grouped, sequential IDs keep the Object Register readable and
growth predictable.

### 5.2 Growth Buffer Planning

| Range size | Minimum buffer |
|---|---|
| Up to 50 objects | 10 IDs reserved |
| 50–150 objects | 25–30% buffer |
| 150+ objects | 20–25% buffer + tail block |

For each module block, leave at least 5–6 IDs unallocated at the end for additions within that
module. These reserved IDs are also what later gap-fill work draws on, so they are not decorative
— spending them early leaves nothing for the fixes that follow.

### 5.3 Permission Sets Are Deliverables, Not Afterthoughts

If Permission Sets are enabled (runbook Step 01 §1.2), every AL PTE that exposes API pages or
data must deliver:

- A **read-only** permission set granting `X` (Execute/Read) on all pages.
- A **read/write** permission set that includes the read-only set, plus write permissions on all
  editable pages.

Both must be assigned IDs from the allocated range before development begins, named using the
**Permission Set Prefix** from Step 01 §1.3 (e.g., `<PREFIX> - READ` and `<PREFIX> - READ/WRITE`).

**Every table the extension owns needs a `tabledata` grant in both sets.** BC PTE publish
validation (`PTE0004`) requires every table in a published package to be covered by an in-package
permission set — and it fires at **publish**, not at compile, so no automated step catches a
missing grant. Ship each table's grant in the same batch that introduces the table.

**Deployment note:** Extension permission sets grant access to extension objects only. Consumers
also need the underlying BC base-table permissions:

- Read-only consumers: assign `<PREFIX> - READ` + `D365 READ`.
- Read/write consumers: assign `<PREFIX> - READ/WRITE` + `D365 BUS FULL ACCESS` (or equivalent).

---

## Part 6 — Gap Analysis Checklist

Run this during the runbook's **PRE-02 (Structured Gap Analysis)** to catch missing entities
before the FRD is finalized.

### 6.1 Analytical Detail Tables

For every transactional entity, ask: *Is there a sub-ledger or detail table?*

| Entity | Ask About |
|---|---|
| Customer Ledger Entries | Detailed Customer Ledger Entries |
| Vendor Ledger Entries | Detailed Vendor Ledger Entries |
| Item Ledger Entries | Value Entries, Item Application Entries |
| General Ledger | GL Registers (audit trail) |
| Bank Account | Bank Account Ledger Entries |
| Resource | Resource Ledger Entries |

### 6.2 Posted / Archived Versions

For every open document, ask: *What is the posted equivalent?*

| Open | Posted |
|---|---|
| Sales Invoice | Posted Sales Invoice + Lines |
| Sales Credit Memo | Posted Sales Credit Memo + Lines |
| Sales Order | Posted Sales Shipment + Lines |
| Purchase Invoice | Posted Purchase Invoice + Lines |
| Purchase Credit Memo | Posted Purchase Credit Memo + Lines |
| Purchase Order | Posted Purchase Receipt + Lines |

### 6.3 Reference / Lookup Tables

Check that every lookup table referenced by an included entity is itself included:

- Payment Terms, Payment Methods
- Currencies, Countries/Regions
- Units of Measure, Item Units of Measure
- Locations, Warehouses
- Shipment Methods, Shipping Agents
- Item Categories, Product Groups
- Salesperson / Purchaser codes

### 6.4 Secondary Document Types

When including one document type, verify all related types:

- Sales Orders → also Sales Quotes, Blanket Orders, Return Orders
- Purchase Orders → also Purchase Quotes, Blanket Orders, Return Orders

### 6.5 Modern vs. Legacy Tables

| Legacy (Do Not Use) | Modern (Use This) |
|---|---|
| Sales Price (Table 7002) | Price List Header + Lines (Tables 7000, 7001) |
| Purchase Price (Table 7012) | Price List Header + Lines (Tables 7000, 7001) |
| Sales Line Discount (Table 7004) | Price List Lines |
| Job (Table 167 — UI only) | Still Table 167; use entity name `<prefix>Project` |
| Job Posting Group (Table 96) | Project Posting Group (Table 208 in BC v27+) |

### 6.6 Tax Framework Tables

Verify whether any tax tables apply to the target Localization before including or excluding
them. Do not assume.

---

## Part 7 — Anti-Patterns Reference

| Anti-Pattern | Problem | Correct Pattern |
|---|---|---|
| Using `Editable = false` on editable pages | Prevents OData write operations | `DelayedInsert = true` on all editable pages |
| Omitting `DelayedInsert` on editable pages | OData inserts fail silently | Always set `DelayedInsert = true` |
| Setting both `Editable = false` AND `DelayedInsert` | Contradictory; misleading | Set exactly one (§2.2) |
| Quoting single-word enum values in `const()` | Parser error | Quote only multi-word values (§2.3) |
| Not quoting multi-word enum values in `const()` | Parser error | Always quote values containing spaces (§2.3) |
| Using `%` in field identifiers | Invalid AL identifier character | Replace with a `Pct` suffix (§4.1) |
| Using reserved keywords as identifiers (`area`, `group`, etc.) | Compiler error | Suffix with a type noun (§4.3) |
| Identifier > 30 characters | Compiler error | Apply BC abbreviations (§4.2) |
| Using estimated / guessed table numbers | Silent wrong-table references | Verify every table ID against symbol files (Appendix B) |
| Including `ObsoleteState = Pending` fields with future removal dates | Exposes deprecated fields | Exclude all pending-obsolete fields unconditionally (§3.2) |
| Including fields outside the allowed Localization range | Exposes irrelevant data; breaks portability | Apply the field rules in Part 3 per the Localization parameter |
| Missing `ApplicationArea = All` | Fields hidden in API context | Required on every field (§1.4) |
| Missing `ODataKeyFields = SystemId` | OData key not defined | Required on every API page (§2.1) |
| Sub-namespaces within a single extension | Unnecessary complexity | One flat namespace per extension (§1.1) |
| Fixing an individual file's error without fixing the root cause | The error recurs in the next batch | Fix the template/rule, then every file it touched |
| A TDD that depends on context not in the document | Agents and new developers must guess | The TDD must be fully self-sufficient (runbook Step 03) |
| Using legacy price tables (Tables 7002, 7012) | Deprecated since BC 2020 Wave 2 | Use Price List Header + Lines (Tables 7000, 7001) (§6.5) |
| `EntityName` ≠ `EntitySetName` for singleton tables | OData metadata inconsistency | Singleton: set `EntityName = EntitySetName` |
| Generic ToolTips with no information value | Poor `$metadata` schema quality | Write descriptive, field-specific ToolTips (§2.6) |
| Hardcoding publisher, prefix, namespace, or version in AL code | Values diverge from the project parameters | Always derive from the runbook's Step 01 block — never hardcode |
| Reaching for a `FlowField` when "auto-populated but editable" is what's wanted | A `FlowField` is always read-only and always live-recalculated; a user can never override it | Use a real stored field seeded by `OnValidate`/`OnInsert` that never overwrites a value the user already entered |
| Using `CaptionML`, `ToolTipML`, `OptionCaptionML`, or any other multilanguage (ML) property, or the `TextConst` data type — whoever wrote it | Deprecated (AL0424); never included in the `.xlf` file, so the text can't be translated; blocks AppSource; compiles with **no warning** unless `TranslationFile` is enabled | Single-language `Caption` / `ToolTip` / `OptionCaption` / `Label` in the default language; translations go in `.xlf` files (§1.7) |

---

## Appendix A — OData API Endpoint Patterns

Substitute `<APIPublisher>`, `<APIGroup>`, and `<APIVersion>` with the values from the runbook's
Step 01 §1.3 parameters.

```
Base URL: https://<tenant>.api.businesscentral.dynamics.com/v2.0/<tenantId>/<environmentName>/api/

Per-group metadata:
  .../api/<APIPublisher>/<APIGroup>/<APIVersion>/$metadata

Entity collection:
  .../api/<APIPublisher>/<APIGroup>/<APIVersion>/<EntitySetName>

Single record by SystemId:
  .../api/<APIPublisher>/<APIGroup>/<APIVersion>/<EntitySetName>(<SystemId>)

Filtered query:
  .../api/<APIPublisher>/<APIGroup>/<APIVersion>/<EntitySetName>?$filter=<fieldName> eq '<value>'

Selected fields:
  .../api/<APIPublisher>/<APIGroup>/<APIVersion>/<EntitySetName>?$select=<field1>,<field2>
```

---

## Appendix B — BC Symbol File Verification Procedure

Before finalizing any TDD, using the **Symbol Source** named in the runbook's Step 01 §1.4:

1. Open the BC symbol file in VS Code using the AL Language extension.
2. For each source table: confirm the table number matches (`table <ID> "<Name>"`).
3. For each `using` directive: copy the exact namespace from the symbol file entry for that
   source table.
4. For each field: confirm `ObsoleteState`, field ID, and data type.
5. For localization compliance: confirm every included field complies with the Localization
   parameter, per the rules in Part 3.

**Do not rely on BC documentation websites, agent knowledge, or memory for table numbers or
namespaces.** Symbol files are authoritative.

**Fallback when the downloaded symbols don't answer the question** (a module isn't in
`.alpackages`, or you need to browse and discover rather than grep for something you already
know): the entire BC BaseApp for the current Business Central Online version is documented at
<https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application>
— every standard table, field, and field datatype/size — and the System Application (its
foundation modules: Language, Translation, Email, Telemetry, and the rest) at
<https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application>.
Use them to corroborate or discover; the downloaded symbol file for the target version still wins
if the two ever disagree.

---

## Appendix C — Recommended VS Code Extensions and Tools

| Tool | Purpose |
|---|---|
| AL Language (Microsoft) | AL IntelliSense, compiler, symbol files |
| AL Object ID Ninja | Manages object ID ranges across team members |
| AZ AL Dev Tools | Linting, unused variable detection, code quality — the rule set the runbook's Step 06 post-generation pass reads against |
| Git | Version control |

---

*This document was created by AJ Ansari, Microsoft MVP, from OnlyCopilotFans. Update this document
when new patterns are discovered or rules are revised. Its version history is tracked in
`RunbookChangelog.md` alongside the runbook it accompanies.*
