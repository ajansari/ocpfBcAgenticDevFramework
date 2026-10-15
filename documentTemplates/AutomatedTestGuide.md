> **Template** for `docs/4-prove/AutomatedTestGuide.md` — OCPF BC Agentic Development Framework, written
> whenever AL test codeunits are created (Full Step 11; Lite Step 6 when the project has test codeunits),
> beside `AutomatedTestScripts.md`, which says *what* the tests are. This document says *how a person
> installs and runs them, one at a time, in Business Central*, and assumes the reader has never opened the
> AL Test Tool. Keep every heading in this order; replace every `<placeholder>`; one row per test method in
> §6 — never "and so on"; delete this note. Microsoft's pages and the Test Runner's own source, read
> October 15, 2026, are linked at the end.

# Running the automated tests for <Extension Name>

**The agent does not upload or run anything in Business Central unless a developer explicitly asks it to.** It writes the tests and this guide; a
person installs the test app and runs the tests in a sandbox, then reports what the page showed. Plan on
twenty minutes the first time (installing the test framework is most of it) and five minutes after that.

## 1. What you are installing

| | |
|---|---|
| The extension under test | `outputAppPackage/<ExtensionName>_<version>.app` (install it first — `docs/4-prove/SandboxInstall.md`) |
| The test app | `outputAppPackage/<ExtensionName>_Tests_<version>.app` — a separate extension whose only job is to test the one above; it is never installed in production |
| Test codeunits in the test app | `<count>` codeunits, `<count>` test methods, listed in §6 |
| Test framework apps the test app needs | **Library Assert**, **Any**, **Library Variable Storage** — Microsoft's, installed once per sandbox (§3) |
| The page you run tests from | **AL Test Tool** (page 130451), which comes with Microsoft's **Test Runner** app (§3) |
| Sandbox | `<environment name>` — tests write data and are not allowed in a production environment |

## 2. Before you start

- **A sandbox only.** Microsoft allows automated tests in online sandboxes and forbids them in production.
  Two limits apply in a sandbox: no single test method may run longer than fifteen minutes, and Microsoft
  recommends not running tests for more than one or two hours a day.
- **The permission to install extensions** (§2 of `SandboxInstall.md`): Admin Center access, the
  **D365 Extension MGT** user group, or the **EXTEND. MGT. - ADMIN** permission set.
- **A company you can dirty.** Tests create and delete records. Use the sandbox's demonstration company
  (**CRONUS** …) or a company set aside for testing, never a copy of live data you still need.
- **The extension under test installed first**, at the version §1 names. The test app depends on it and
  will refuse to install without it.

## 3. Install the test framework (once per sandbox)

The test app depends on three small Microsoft apps, and the page that runs tests lives in a fourth. All
four are free and published by Microsoft. Install them in this order; each takes under a minute.

| Order | App | Publisher | App ID |
|---|---|---|---|
| 1 | **Test Runner** (brings the **AL Test Tool** page) | Microsoft | `23de40a6-dfe8-4f80-80db-d70f83ce8caf` |
| 2 | **Library Assert** | Microsoft | `dd0be2ea-f733-4d65-bb34-a28f4624fb14` |
| 3 | **Any** | Microsoft | `e7320ebb-08b3-4406-b1ec-b4927d3e280b` |
| 4 | **Library Variable Storage** | Microsoft | `5095f467-0a01-4b99-99d1-9ff1237d286f` |

For each one:

1. Open the sandbox, choose the **Search for Page or Report** icon (magnifying glass, top right), type
   **Microsoft Marketplace Apps**, and open the page. It lists the Business Central apps available to
   this environment.
2. Find the app by the exact name in the table. Check the publisher is **Microsoft**.
3. Select it and choose **Install**; accept the terms and wait for the confirmation.
4. Open **Extension Management** the same way, choose **Refresh**, and confirm the app shows as
   **Installed**.

**If one of them is not listed, stop and tell the agent which one.** Do not look for the file on disk or
in a Docker image. A developer can install a Microsoft app that the page doesn't show by its App ID
(the table above) through the Admin Center API — the agent knows the route — and if that isn't possible
for this sandbox, the agent will say plainly that the test app cannot be installed there and what the
alternatives are. Two Microsoft test apps — **Tests-TestLibraries** and **System Application Test
Library** — are *not* available in online sandboxes at all, which is why this project's tests use only
the three libraries above. A test app that depends on either of those two cannot be installed in a
sandbox, and the agent must not write one.

## 4. Install the extension under test, then the test app

1. Install `outputAppPackage/<ExtensionName>_<version>.app` by `docs/4-prove/SandboxInstall.md`, if it is
   not already installed at that exact version. (A test app is built against one version of the
   extension; a different version installed is the most common reason the test app refuses to install.)
2. Install `outputAppPackage/<ExtensionName>_Tests_<version>.app` the same way — same route, same steps,
   **Schema Sync Mode = Add** unless §1 says otherwise (a test app normally has no tables of its own).
3. On **Extension Management**, confirm both are **Installed**, each at the version from §1.

## 5. Open the AL Test Tool and load the tests

1. Choose the **Search for Page or Report** icon, type **AL Test Tool**, and open it. (It is page
   **130451**. If the search finds nothing, the **Test Runner** app from §3 is not installed.)
2. The page opens on a test suite called **DEFAULT** (the **Suite Name** field at the top). Leave it.
3. Choose **Manage Tests**, then **Get Test Codeunits**. A list of every test codeunit installed in the
   environment opens.
4. Select the codeunits from §6 — `<codeunit ID and name>`, `<…>` — and choose **OK**. One line per
   codeunit appears, each followed by one line per test method; the **Line Type** column says which is
   which, **Codeunit ID** and **Name** say what they are.
5. Every line has its **Run** checkbox ticked. Leave them ticked; the one-at-a-time procedure in §7
   does not depend on them.

The list stays on the page between sessions. After a new build of the test app, choose
**Manage Tests → Update Test Methods** so the lines match the new code.

## 6. What each test checks

One row per test method. Run them in this order the first time; later, run only what a fix touched.

| # | Codeunit (ID · name) | Test method | What it checks | Expected result | Setup it needs first |
|---|---|---|---|---|---|
| 1 | `<50xxx · Name>` | `<MethodName>` | `<One sentence in business terms: "a ticket cannot be closed while it has open lines">` | **Success** | `<none / "the setup page's number series filled in">` |
| 2 | | | | | |

A method whose job is to prove that something is *refused* still shows **Success** when the refusal
happens as designed; the test catches the error itself. **Failure** always means the extension did
something the design did not intend — or that §6's setup column was not done.

## 7. Run the tests one at a time

Running one method at a time is the whole point of this guide: a single failure then points at a single
line of this table, and the agent gets a precise report.

For each row of §6, in order:

1. Do what the row's **Setup it needs first** column says, if anything.
2. Click the line of that test method in the AL Test Tool so it is the active line.
3. Choose **Run Tests**, then **Active Line** in the prompt that appears (the choices are **All**,
   **Active Codeunit**, **Active Line**). Only that method runs.
4. Read the **Result** column on that line: **Success**, **Failure**, or **Skipped**. **Duration** shows how
   long it took.
5. **On Failure, open the Error Message.** Click the **Error Message** cell on that line: it holds the
   full message and the call stack. Copy the whole text — the first line names what the test expected and
   what it got (for example `Assert.AreEqual failed. Expected:<50101> (Integer). Actual:<0> (Integer).
   Codeunit does not match default.`); the stack below it names the method and line in the extension
   where it happened.
6. Record the row's result in §9 before moving to the next row. A failed test does not stop you from
   running the rest; run them all, then report once.

The totals at the bottom of the page — **Successful Tests**, **Failed Tests**, **Skipped Tests**,
**Tests not Executed** — count every line in the suite, so they only mean something once every row has
been run.

**To run everything in one go** (a second pass after fixes, for instance): choose **Run Tests → All**,
or tick **Run** only on the lines you want and choose **Run Selected Tests**. Results land in the same
columns.

## 8. Reading the result, and what to send the agent

| Result | Meaning | Send the agent |
|---|---|---|
| **Success** | The method ran and every check in it held | Nothing but the row number |
| **Failure** | A check did not hold, or the code raised an error the test did not expect | The row number, the full **Error Message** text, and anything you did differently from §6's setup column |
| **Skipped** | The method was not run | The row number and the Error Message text if there is one |
| Empty | The line has not been run yet | — |

The agent diagnoses from the message and the stack, fixes the extension (or the test, when the test was
wrong), and builds new packages — both the extension and the test app, at a higher version. You then
repeat §4 (install the new versions), **Manage Tests → Update Test Methods**, and §7 for the rows that
failed, then one full pass of everything before the step closes. **A failing test is a defect** in this
framework, the same as a compiler error: the step does not close with a Failure on the page.

## 9. Results of this pass

| Date | Tester | Sandbox | Extension version | Test app version | Rows passed | Rows failed (numbers) | Notes |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

## 10. Before copying this sandbox anywhere

Uninstall the test app (**Extension Management → select `<ExtensionName> Tests` → Uninstall**) before a
sandbox is copied to production or handed to users: test codeunits have no business in a production
environment, and Microsoft refuses to run them there anyway. The three library apps and Test Runner can
stay; they do nothing on their own.

## Sources (read October 15, 2026)

- *Testing the application overview* (sandbox rules, limits) — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-testing-application>
- *Test the advanced sample extension* (Test Tool walkthrough, error message and call stack) — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-extension-advanced-example-test>
- *Install and uninstall apps* (Extension Management, marketplace) — <https://learn.microsoft.com/en-us/dynamics365/business-central/ui-extensions-install-uninstall>
- The **AL Test Tool** page and the **Test Runner**, **Any**, **Library Assert**, and **Library Variable Storage** apps, with their IDs and the page's exact captions and actions — Microsoft's BCApps repository, `src/Tools/Test Framework/` — <https://github.com/microsoft/BCApps/tree/main/src/Tools/Test%20Framework>
- *Manage Marketplace apps* (the Microsoft Marketplace Apps page) — <https://learn.microsoft.com/en-us/dynamics365/business-central/admin-manage-appsource-apps>
- Availability of the test framework apps in online sandboxes (Test Runner from the marketplace since 17.2; Tests-TestLibraries never; the three libraries by App ID, as practitioners report — no Microsoft page confirms it) — Freddy Kristiansen, *Running tests in Business Central Online Sandbox environments* (February 2021) — <https://freddysblog.com/2021/02/15/running-tests-in-business-central-online-sandbox-environments/>
