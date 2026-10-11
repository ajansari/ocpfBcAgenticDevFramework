# Permission set extension

**Read before writing:** Standards §5.3–§5.4; Appendix B (the base permission set's exact name
from the symbols — `D365 BASIC`, `D365 BUS FULL ACCESS`, or one of this project's own).

## Ask / confirm

Needed: the base set (the human's words resolved in the symbols; when they say "everyone who can
use BC", `D365 BASIC` is the usual choice and the confirmation says what that means); the grants
to add (default: the objects built this session). Say plainly: extending a Microsoft set gives
the grant to **every user who holds that set**, which is often exactly the point for a lookup
table every page needs — and is wrong for anything a role should control; in that case offer the
project's own set (`permission-set.md`) instead.

## Write

```al
namespace <Publisher>.<ExtensionShort>;

using System.Security.AccessControl;

permissionsetextension <ID> "<PFX> Region Basic" extends "D365 BASIC"
{
    Permissions =
        tabledata "<PFX> Region" = R,
        table "<PFX> Region" = X,
        page "<PFX> Regions" = X;
}
```

- The `using` comes from the symbol of the base set (`System.Security.AccessControl` for the
  `D365 …` sets); verify it.
- Read grants only on a Microsoft base set unless the human said otherwise; write grants belong
  in the project's own EDIT set.

## Pre-flight

The base set exists in the symbols; every object named exists; the file is
`<Name>.PermissionSetExt.al`.

## Offer at close

*Done*.
