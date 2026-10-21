# BC App Build Routine — STEP 5 — Compile, Package, Test & Iterate

**Runbook version:** 5.9.2.0 · Lite edition · Phase: BUILD

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
6a). **Between the first clean compile and the first package: the pre-review** (Ops § Roles → *The
pre-review*). The moment the extension first compiles with the analyzers at 0 / 0, and **before**
the first package, delegate a read of every file under `src/` to the project-local
**`ocpf-reviewer`** sub-agent the `roles` skill wrote at Step 1 — the Main model and effort, in
the background, the model passed on the call; its report opens with the model it ran on, checked
against `docs/1-define/ProjectParameters.md` before anything in it is used. Brief: the project
root, `src/`, `docs/2-design/DesignDoc.md`, `docs/1-define/ProjectParameters.md`, the Standards
Guide path with §1.1–§1.9, Part 2, §5.3–§5.4, Part 7, Part 11, §8.3, `ocpfFramework/patterns/`,
the symbol source — nothing else. It returns findings in two tiers (what would break the first
sandbox test or force a rebuild; what is worth fixing before the package), observations, and what
it could not verify; it grades nothing. **Present every finding in one message** — file and line,
root cause, proposed fix — and ask once (Rule 6a): **Apply all (recommended)** / **Apply
selected** / **Discuss first**; a finding that would change the Design Doc gets its own box.
Nothing is applied before the answer. Apply the approved fixes, recompile to 0 / 0, and record
**each finding with its decision** — applied, declined and why, deferred to Step 6 — as an entry
in `docs/0-project/ChangeLog.md` (source *Pre-review*), with the model that ran. Then the first
package. Once per Step 5, not per round; Step 6's review is the full one.

**After every build, say this, on its own lines:**

```
Package built: outputAppPackage/<Name>_<version>.app (previous build <version-1>)
Schema: additive only → upload with Schema Sync Mode = Add
   or: <what was removed / shrunk / retyped / re-keyed> → upload with Schema Sync Mode = Force Sync
       (Microsoft: test a forced sync in a sandbox first; it can lose data in <where>)
Install: you upload it — docs/4-prove/SandboxInstall.md, §1 updated for this build.
Then: tell me the version and environment you installed; I record it as the last installed version.
```

The schema line compares the objects against the last package installed in a tenant; record
"last installed version" in `docs/0-project/ChangeLog.md` each time the human confirms an upload.

**After every compile with 0 errors, check what the human's editor shows** (ALL ALONG → Keeping
the Editor in Sync). Red marks the compiler didn't report, like an object ID outside the allowed
ranges, mean the editor's view is stale, not the code. Refresh the view; never change code that
compiles clean to clear them.

**From here it's a cycle, not a single event:**
1. **The human installs the current package in a BC sandbox — the agent never uploads unprompted
   and never offers to.** With the
   first package, write `docs/4-prove/SandboxInstall.md` from its template (Ops § Packaging → *The
   sandbox install guide*): Microsoft's two upload routes step by step, and §1 naming this build's
   file, version, Schema Sync Mode, sandbox, and dependencies. After every later build, rewrite §1
   only. Then wait: the round continues when the human says which version they installed and
   where; log that in `docs/0-project/ChangeLog.md` as the last installed version. Never assume the
   upload happened, and never offer to do it. If the developer explicitly asks for a publish,
   confirm first that they mean a DEV extension to the named sandbox, then do it (Ops § Packaging →
   *Publishing on explicit request*) — once, on request, never as the routine.
2. Test it — manually, by the human. **Every round includes the two Standards §11.3 client checks**: create a child from *every* parent entry point
   (each part and each action) and confirm it stays visible with the link field filled and the
   unfiltered child list has no blank-link rows; open the wizard and the setup card and confirm the
   number-series field opens the *No. Series* dropdown, the pick survives Finish, and the first two
   records number consecutively. *"The view is filtered, and the entry is outside the filter"* and
   a series field with no dropdown are defects to diagnose (**§11.1**, **§11.2**), never warnings
   to click past — ask the human to report them explicitly.
3. For every error or problem, **first check `ocpfFramework/patterns/`** (ALL ALONG → OCPF BC AL Patterns
   - **A System.AI or Copilot error** (an obsolete `RegisterCapability` overload, a GPT-4o getter, "Copilot capability has not been set", AL0223 on the dialog): check the Blueprint's `references/08-api-reference-bc27.md` and `references/09-false-assumptions.md` before memory (ALL ALONG → *Business Central Copilot Features*).
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
5. **Increment the Revision, compile and package again** (the message block above), rewrite
   `SandboxInstall.md` §1, the human installs it, retest. Repeat until 0 errors / 0 warnings and the human confirms sandbox testing is clean.

**Translations run inside this cycle** (skip if *US wording, no translation files*). **The cycle is
Ops § Translations — read it at the first full build.** In short: every build syncs the target
files, verifies any new BC term, and runs the problem checks; drafting, the full checks, and
per-language testing wait until the source text is stable — the first build the human confirms clean
on the sandbox, again before this step closes, and again after any later fix that changes source
text.

**API test checklist** (the human's, here and again at Step 7 — endpoint URL shapes are in
**Standards Appendix A**):
- **Green-team (happy path):** `$metadata` returns the expected schema; read a collection; read a
  single record by `SystemId`; create a record on an editable endpoint; update a field; confirm a
  read-only endpoint rejects writes.
- **Red-team (boundary):** write to a read-only endpoint; send a non-existent field; send an
  invalid key; delete a record with dependencies; call with missing permissions — each should
  fail *gracefully with a clean, actionable error*.

**The checklist is the human's to run, every round — the agent does not test on the sandbox.** It
never uploads a package, so it never has a build to call, and the AL MCP Server has no tool that
calls a published endpoint anyway. Say so plainly if asked rather than improvising a route, and
suggest Postman, Power Automate, Power Apps, or Copilot Studio. Endpoint URL shapes, including the
company segment most endpoints need, are **Standards Appendix A**. Step 7's human pass decides.

**Remediation — when the design has to change after this step closed (Ops § Usage & Cost →
7).** If testing at Step 7, or a late requirement change, means the Design Doc
must be redone and objects regenerated — not a fix inside this step's cycle — open a
**remediation** the moment the human agrees it is a rebuild: window `STEP-5a` (then `STEP-5b`, …) titled
*Remediation — <what changed>*, row `| BUILD | STEP-5a — Remediation | In Progress |` directly under
this step's row in `ProjectProgress.md`. Redo the Design Doc in place (ChangeLog entry naming
the remediation), regenerate, and bring the extension back to 0 / 0 under that window; close it
with its usage rows and the Rule 6c box offering the step the project came from. The dashboard
shows it as `STEP-5a · Remediation` on the journey line.

**Outputs:** All files compiling and packaging with **0 errors, 0 warnings**; every build's package
in `outputAppPackage/`, one file per version, none overwritten; `docs/4-prove/SandboxInstall.md`
written with the first package and its §1 current; at least one package installed by the human
and manually tested on a sandbox; `docs/0-project/ChangeLog.md` current (last installed version
included); `docs/2-design/DesignDoc.md` updated for every rule change.

**Exit gate:** Full extension compiles clean, with the analyzers and nothing suppressed (Ops § Analyzers); the pre-review ran on the Main model before the first package and every finding was decided in the options box and recorded in the ChangeLog; human confirms sandbox testing is clean; no known
systemic issue outstanding; no unit in a language required at first release is
`needs-translation` or `needs-adaptation`, and translation checks are clean. This step's usage rows — one per model in Claude Code, one per step in Copilot — are written before this message (Operating Rule 9).

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, end the closing message with the options box: **Proceed into Step 6 now — closes BUILD, opens PROVE (recommended)** / **Stop here** (say what there is to review and how to resume). Nothing of Step 6 starts until the human answers.
