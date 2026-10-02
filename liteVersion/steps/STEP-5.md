# BC App Build Routine — STEP 5 — Compile, Package, Test & Iterate

**Runbook version:** 5.1.0.0 · Lite edition · Phase: BUILD

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** Every generated file (lint-clean, not yet compiled); accumulated lint findings;
`docs/2-design/DesignDoc.md`; `docs/0-project/ChangeLog.md`.

**Actions:** First, **compile the whole extension once, with the analyzers this framework
requires, then package it** (ALL ALONG → Analyzers; check for an already-provisioned runtime
before installing anything — Rule 6b). This is Rule 4's mandatory compile-and-package. Package
naming, location (`outputAppPackage/`), and the never-delete rule apply from this very first package
on (**read Ops § Packaging now**, its *Version numbers* subsection included).

**The first build of a new app goes out at `0.0.0.1`, the version Step 1 wrote — no increment.
Before every build after it, increment the version first**, mechanically, with no approval. An
existing app's first build increments from the installed version, and every build after it
increments again. The test: if `outputAppPackage/` holds no package yet and `app.json` says
`0.0.0.1`, build as is; otherwise read `version` from `app.json`, increment the fourth segment
(Revision), write it back, then build. Never build twice at one version; if
`outputAppPackage/<Name>_<version>.app` already exists, increment again
(`ocpfFramework/scripts/al-analyze.*` refuses to overwrite an existing output file — exit code 4,
the message names the file). Major, Minor, and Build bumps are still proposed and approved (Rule
6a). **After every build, say this, on its own lines:**

```
Package built: outputAppPackage/<Name>_<version>.app (previous build <version-1>)
Schema: additive only → upload with Schema Sync Mode = Add
   or: <what was removed / shrunk / retyped / re-keyed> → upload with Schema Sync Mode = Force Sync
       (Microsoft: test a forced sync in a sandbox first; it can lose data in <where>)
Upload: Extension Management → Manage → Upload Extension, choose the file, set Schema Sync Mode, Deploy.
```

The schema line compares the objects against the last package installed in a tenant; record
"last installed version" in `docs/0-project/ChangeLog.md` each time the human confirms an upload.

**After every compile with 0 errors, check what the human's editor shows** (ALL ALONG → Keeping
the Editor in Sync). Red marks the compiler didn't report, like an object ID outside the allowed
ranges, mean the editor's view is stale, not the code. Refresh the view; never change code that
compiles clean to clear them.

**From here it's a cycle, not a single event:**
1. Publish the current package to a BC sandbox tenant.
2. Test it — manually, by the human, unless the human took the agent-run API pass below, in which
   case the agent publishes and runs the checklist first and reports what it found. **Every round
   includes the two Standards §11.3 client checks**: create a child from *every* parent entry point
   (each part and each action) and confirm it stays visible with the link field filled and the
   unfiltered child list has no blank-link rows; open the wizard and the setup card and confirm the
   number-series field opens the *No. Series* dropdown, the pick survives Finish, and the first two
   records number consecutively. *"The view is filtered, and the entry is outside the filter"* and
   a series field with no dropdown are defects to diagnose (**§11.1**, **§11.2**), never warnings
   to click past — ask the human to report them explicitly.
3. For every error or problem, **first check `ocpfFramework/patterns/`** (ALL ALONG → OCPF BC AL Patterns
   Library) for a matching, already-documented pattern. If nothing matches, ask: is this a one-off
   or a pattern (search every generated file for the same class of issue)? Where did it come from
   — the generation rule, the Design Doc, or the source data? What rule should have caught it?
4. **Approve the round's fixes together, then apply them.** Once every problem from this test
   round has a diagnosis, present them all in one message — each listed separately with its root
   cause and proposed fix — and ask once (Rule 6a): **Apply all** / **Apply selected** / **Discuss
   first**. Nothing is applied before that answer. A diagnosis that would change a design rule in
   `docs/2-design/DesignDoc.md` gets its own separate box. Then fix each approved **root cause**, regenerate the
   affected files, and log the issue + resolution in `docs/0-project/ChangeLog.md` before moving on. Update
   `docs/2-design/DesignDoc.md` whenever a rule changes.
5. **Increment the Revision, compile and package again** (the message block above), redeploy,
   retest. Repeat until 0 errors / 0 warnings and the human confirms sandbox testing is clean.

**Translations run inside this cycle** (skip if *US wording, no translation files*). **The cycle is
Ops § Translations — read it at the first full build.** In short: every build syncs the target
files, verifies any new BC term, and runs the problem checks; drafting, the full checks, and
per-language testing wait until the source text is stable — the first build the human confirms clean
on the sandbox, again before this step closes, and again after any later fix that changes source
text.

**API test checklist** (used here, and again at Step 7 — endpoint URL shapes are in **Standards
Appendix A**):
- **Green-team (happy path):** `$metadata` returns the expected schema; read a collection; read a
  single record by `SystemId`; create a record on an editable endpoint; update a field; confirm a
  read-only endpoint rejects writes.
- **Red-team (boundary):** write to a read-only endpoint; send a non-existent field; send an
  invalid key; delete a record with dependencies; call with missing permissions — each should
  fail *gracefully with a clean, actionable error*.

**Ask once, at the first round: should the agent run the API checks before the human tests?**
(Rule 6a; record the answer in `docs/0-project/ChangeLog.md` and honor it for every later round.)
- ***Yes — publish and run the checks each round.*** The agent publishes and works the checklist
  above against the sandbox. **It needs two things**: one Microsoft browser sign-in per session, the
  same one publishing and sandbox symbol downloads use; and **a tool in this session that can issue
  OData requests against the sandbox with a bearer token**. **The AL MCP Server is not one** — it
  builds, publishes, and reads symbols, and has no tool that calls a published endpoint.
- ***No — I'll publish and test by hand (the realistic default).*** Don't ask again for this project.
  Nothing is lost: Step 7's human pass is authoritative either way. **Recommend this one unless the
  human says they have an API-capable connection.**

**Check for the route first and say what you found.** With no HTTP-capable tool in this session,
say so plainly, publish, and suggest Postman, Power Automate, or Copilot Studio instead. Endpoint
URL shapes, including the company segment most endpoints need, are **Standards Appendix A**. It's an early filter over the API pages only —
never the BC client — and Step 7's human pass still decides.

**Outputs:** All files compiling and packaging with **0 errors, 0 warnings**; every build's package
in `outputAppPackage/`, one file per version, none overwritten; at least one package
published and manually tested on a sandbox; `docs/0-project/ChangeLog.md` current (last installed
version included); `docs/2-design/DesignDoc.md` updated for every rule change.

**Exit gate:** Full extension compiles clean, with the analyzers and nothing suppressed (Ops § Analyzers); human confirms sandbox testing is clean; no known
systemic issue outstanding; no unit in a language required at first release is
`needs-translation` or `needs-adaptation`, and translation checks are clean. This step's usage rows, one per model, are written before this message (Operating Rule 9).

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, end the closing message with the options box: **Proceed into Step 6 now — closes BUILD, opens PROVE (recommended)** / **Stop here** (say what there is to review and how to resume). Nothing of Step 6 starts until the human answers.
