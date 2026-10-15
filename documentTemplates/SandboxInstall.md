> **Template** for `docs/4-prove/SandboxInstall.md` — OCPF BC Agentic Development Framework, written at the
> first package (Full Step 07 / Lite Step 5) and kept current by the agent on every build: only §1 changes
> from build to build; the procedure below it is the same for every package. Keep every heading in this
> order; replace every `<placeholder>`; delete this note. Written for the person who uploads the package —
> a tester or administrator who may never have installed an extension before. Assume nothing.
> Microsoft's own pages, read October 15, 2026, are linked where the steps come from them.

# Installing <Extension Name> in a Business Central sandbox

**The agent does not upload packages — you do.** It builds the package; a person installs it. (A developer can explicitly ask the agent to publish a build as a DEV extension to a sandbox; that is never offered, and testers and administrators still install this way.)
This document is that person's procedure, from the file on disk to a working extension in a sandbox.
It takes about five minutes the first time and two minutes after that.

## 1. This build

| | |
|---|---|
| Package to install | `outputAppPackage/<ExtensionName>_<version>.app` |
| Version | `<version>` (the previous build was `<version-1>`; the last version installed in the sandbox was `<last installed version or "none yet">`) |
| Schema Sync Mode to choose | **Add** — this build only adds objects and fields *or* **Force** — this build removes, shrinks, retypes, or re-keys `<what>`, so Add will be refused; Force can lose data in `<where>` |
| Sandbox environment | `<environment name>` (type **Sandbox** — never a production environment) |
| Depends on | `<other extensions this one needs installed first, or "nothing beyond the Base Application">` |

The agent rewrites this table after every build. Everything below it does not change.

## 2. Before you start

- **A sandbox, not production.** Development builds go to a sandbox only. If you are not sure which
  environment is which, open the Business Central Admin Center
  (<https://businesscentral.dynamics.com/admin>): the **Environments** list shows each one's **Type**.
- **Permission to install.** You need one of:
  - access to the **Admin Center** as an internal, delegated, or application administrator (route A), or
  - in the environment itself, membership of the **D365 Extension MGT** user group, or the
    **EXTEND. MGT. - ADMIN** permission set (route B).
  If you have neither, ask your Business Central administrator to grant one before continuing.
- **The file.** Copy the package named in §1 somewhere you can browse to from the machine you will use.
  Business Central refuses a version it has already seen: every package the agent builds has its own
  version number, so always take the exact file §1 names, never an older one.
- **Pick one route and stay with it.** Microsoft's note: an installation scheduled from the Admin Center
  does not show on the environment's Extension Management page until it completes, and the other way
  round. Use the same route for this environment every time.

## 3. Route A — Business Central Admin Center (recommended by Microsoft)

Microsoft's current guidance is to upload per-tenant extensions through the Admin Center. The in-product
upload on the Extension Management page (route B) still works but is deprecated and is removed in
2027 release wave 1.

1. Open <https://businesscentral.dynamics.com/admin> and sign in with your work account.
2. In the left pane choose **Environments**, then select the sandbox named in §1.
3. On the environment's page choose the **Manage Apps** icon.
4. In the app-type dropdown choose **Per-tenant Extension**.
5. Choose **Install Extension**.
6. **Browse** to the `.app` file from §1 and select it. Business Central works out by itself whether this
   is a new extension or an update to one already installed; you do not have to say.
7. **Deployment schedule:** choose **Install immediately**. (The other choices — the next update window,
   the next minor or major update — are for production rollouts, and a brand-new extension can only be
   installed immediately or at the next update window.)
8. **Sync Mode:** choose what §1 says — **Add** or **Force**. Add is the safe default and is refused if the
   build changed the database schema in a breaking way; Force overwrites the schema and can delete data,
   which is why §1 says in advance which one this build needs.
9. Read and accept the terms, then confirm.
10. Business Central validates the file and schedules the install. Watch progress on the Admin Center's
    **Operations** page (left pane). The row for this install shows its status; a failed one shows the
    reason when you open it.
11. When the operation shows as completed, go back to **Manage Apps** and confirm the extension is listed
    at the version from §1.

To see or cancel a scheduled installation, open the extension's **App Details** page from Manage Apps.

## 4. Route B — Extension Management page inside Business Central (deprecated, still available)

1. Open the sandbox in your browser and sign in.
2. Choose the **Search for Page or Report** icon (the magnifying glass, top right), type
   **Extension Management**, and open the page.
3. Choose **Manage**, then **Upload Extension**. The **Upload and Deploy Extension** page opens.
4. Choose the browse button next to the file field and select the `.app` from §1.
5. **Deploy to:** leave **Current version** selected. (Next minor / next major are for an extension built
   specifically for a future Business Central release.)
6. **Language:** leave the default unless your administrator says otherwise.
7. **Schema Sync Mode:** choose what §1 says — **Add** or **Force**. If you choose Force, Business Central
   asks you to confirm that you understand data can be lost.
8. Turn on the **Accept** switch to accept the disclaimer.
9. Choose **Deploy**. The upload runs in the background and the page closes.
10. Back on Extension Management, choose **Manage**, then **Deployment Status**. Select the row for this
    upload and choose **Refresh** in its actions until the status is **Completed** (or **Failed** — then
    open the row's details for the reason, and see §8).
11. On Extension Management choose **Refresh** (or reopen the page) and confirm the extension is listed as
    **Installed** at the version from §1.

## 5. After it is installed

1. **Assign the permission sets.** Open **Users**, select each tester, and under **User Permission Sets**
   add `<PREFIX> <APPCODE>, VIEW` (read-only) or `<PREFIX> <APPCODE>, EDIT` (read/write). Without one of
   these a user sees nothing of the extension.
2. **Sign out and back in**, or press **Ctrl+F5** in the browser, so the client picks up the new objects.
3. **Confirm it is there:** search for **`<a page the extension adds, by its caption>`** and open it.
   `<One sentence on what a correct first screen looks like.>`
4. **Run any setup the extension needs:** `<assisted setup / setup page name, or "none">`.
5. **Tell the agent** the version you installed and the environment name. It records "last installed
   version" and judges the next build's Schema Sync Mode against it.

## 6. Installing a newer build (updating)

Repeat §3 or §4 with the new file. Business Central recognises the same extension at a higher version
and upgrades it in place; your data stays. Three things to know:

- The new version must be **higher** than the installed one. The agent increments the version on every
  build, so this is only a problem if you pick an old file by mistake.
- A build the agent marked **Force** in §1 stays Force until it has actually been installed, even if later
  builds only add things.
- If the environment ever refuses with *"An extension with same App ID and version has already been
  uploaded. Resolve and deploy again."*, the file was uploaded before (possibly a failed attempt). Ask the
  agent for a new build; it will carry the next version number.

## 7. Removing it

- **Route A:** Admin Center → **Manage Apps** → the extension's row → **Uninstall** (or **Uninstall** on its
  App Details page).
- **Route B:** Extension Management → select the extension → **Uninstall**.

Uninstalling keeps the extension's data by default, so you can install it again later. To delete the data
as well, turn on **Delete Extension Data** before confirming — that cannot be undone, and it also deletes
the data of every extension that depends on this one. If other extensions depend on this one, Business
Central lists them and uninstalls them with it.

## 8. When something goes wrong

| What you see | What it means | What to do |
|---|---|---|
| The install fails and the details mention a schema change, a field that cannot be removed, or data that would be lost | The build needs **Force** and you chose **Add** | Check §1. If it says Force, repeat with Force. If it says Add, tell the agent — its schema line was wrong. |
| *"An extension with same App ID and version has already been uploaded"* | This exact version was uploaded before | Ask the agent for a new build (next version). Never rename or re-save the file. |
| A dependency is missing or at the wrong version | Something in §1's *Depends on* row is not installed | Install that extension first, at the named version, then retry. |
| The extension installs but you cannot see any of its pages | No permission set assigned, or the client has not refreshed | §5 steps 1 and 2. |
| *"The view is filtered, and the entry is outside the filter"*, or a number-series field with no dropdown | A defect to report, not a setting to change | Report it to the agent exactly as shown; the framework treats both as bugs (Standards §11). |
| The upload is accepted but Deployment Status / Operations never completes | It can take a few minutes; the status is not live | Choose **Refresh** on the status row. After fifteen minutes, open the row's details and report the text to the agent. |

Anything else: copy the full message, note which route and which step you were on, and give both to the
agent. It will diagnose; it will not retry the upload for you.

## Sources (Microsoft Learn, read October 15, 2026)

- *Install and uninstall apps* — <https://learn.microsoft.com/en-us/dynamics365/business-central/ui-extensions-install-uninstall>
- *Deploying a tenant customization* — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-deploy-tenant-customization>
- *Managing apps* (Admin Center) — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/tenant-admin-center-manage-apps>
