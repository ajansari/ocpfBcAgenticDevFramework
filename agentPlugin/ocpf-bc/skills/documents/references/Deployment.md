> **Template** for `docs/4-prove/Deployment.md (and each translated copy)` — OCPF BC Agentic Development Framework, written at Full Step 11. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# Deployment — <Extension Name>

**Version:** <app.json version> · **Package:** `outputAppPackage/<ExtensionName>_<version>.app` · **Date:** <date>
**Rule:** the agent never publishes to production. The production deploy is the human's, from this document, after the Step 12 release test passes.

## 1. What ships
| Item | Value |
|---|---|
| Package (exact file, the one that passed Step 12) | |
| Dependencies | |
| Schema Sync Mode | Add / **Force Sync** (data-loss warning: <…>) |
| Target environments | sandbox <name> → production <name> |

## 2. Before deploying
- [ ] Release test passed (`docs/4-prove/ReleaseTestResults.md`).
- [ ] Every required translation `signed-off` or `final`.
- [ ] Version bump approved and recorded.
- [ ] Backup / restore point per the customer's policy.

## 3. Deploy — per-tenant (Extension Management)
1. <step, with the exact page and action names in BC>
2. <…>

## 3a. Deploy — AppSource (if Deployment Target = AppSource)
<Partner Center submission checklist from Standards Appendix E.>

## 4. After deploying
- [ ] Permission sets assigned (`<PREFIX> <APPCODE>, VIEW` / `, EDIT`).
- [ ] Setup completed (assisted setup or setup page).
- [ ] Smoke test: <three checks from the test script>.

## 5. Rollback
<How to uninstall or revert, what data is affected, who decides.>

## 6. Upgrade notes
<From TDD §8: upgrade codeunits that run on install, obsolete fields, data expectations.>

## Before calling this done
- [ ] The package named in §1 is the one that passed Step 12.
- [ ] Every step is runnable by an administrator who is not a developer.
