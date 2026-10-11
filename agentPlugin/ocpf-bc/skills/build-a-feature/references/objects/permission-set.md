# Permission set

**Read before writing:** Standards §5.3 (VIEW and EDIT; every owned table in both), §5.4 (the
name `<PREFIX> <APPCODE>, VIEW` / `, EDIT`, ≤ 20 characters, the App Code unique across the
prefix's extensions; caption ≤ 30), §5.5.

## Ask / confirm

Needed: the **Permission Set App Code** if the project has none recorded (two or three uppercase
suggestions from the extension name that fit `13 − prefix length`, and the question whether other
extensions already use this prefix — if one does, its App Codes must differ); which objects to
grant (default: **every object this extension owns**, read from `src/` — tables as `tabledata`
and `table`, pages, reports, queries, codeunits as `X`); whether the sets are **assignable**
(yes). The two sets are built together; the confirmation box lists the grants.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

permissionset <ID> "<PREFIX> <APPCODE>, VIEW"
{
    Assignable = true;
    Caption = '<Extension Name> - View';

    Permissions =
        tabledata "<PFX> Rental Unit" = R,
        table "<PFX> Rental Unit" = X,
        page "<PFX> Rental Units" = X,
        page "<PFX> Rental Unit Card" = X,
        page "<PFX> Rental Units API" = X,
        query "<PFX> Rental Amount by Customer" = X,
        report "<PFX> Rental Unit List" = X,
        codeunit "<PFX> Rental Mgt." = X;
}
```

```al
permissionset <ID + 1> "<PREFIX> <APPCODE>, EDIT"
{
    Assignable = true;
    Caption = '<Extension Name> - Edit';
    IncludedPermissionSets = "<PREFIX> <APPCODE>, VIEW";

    Permissions =
        tabledata "<PFX> Rental Unit" = IMD;
}
```

- `<PREFIX>` is the AL object prefix in uppercase; the App Code from the parameter sheet (Full /
  Lite project) or `ocpfFramework/state/feature.json` (record it there the first time).
- Two files: `<PREFIXAPPCODEVIEW>.PermissionSet.al` and `…EDIT.PermissionSet.al` (§1.8 strips
  the comma and the space).
- A table extension needs no grant of its own; an API page and a query need `X`.
- Say the deployment note (§5.3): consumers also need `D365 READ` or `D365 BUS FULL ACCESS`.

## Pre-flight

Name ≤ 20 characters, caption ≤ 30, both sets name every owned table (PTE0004), the EDIT set
includes the VIEW set, no object named that does not exist, two files.

## Offer at close

*Done*. (A later object built in the same session adds its grant to both sets as part of its
own loop — the table and API page references say so.)
