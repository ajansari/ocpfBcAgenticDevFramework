# BC App Build Routine — STEP 6 — Review, Gap-Check & Finalize Docs

**Runbook version:** 5.1.0.0 · Lite edition · Phase: PROVE

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** The built extension, `docs/2-design/DesignDoc.md`, `docs/0-project/ChangeLog.md`, `ocpfFramework/documentTemplates/Docs.md`, `ocpfFramework/documentTemplates/TestScript.md`, `ocpfFramework/documentTemplates/Acknowledgements.md` (each document is written from its template, Ops § Documents).

**Actions:**
- **Gap-check** — compare `docs/2-design/DesignDoc.md` against the as-built code. For each divergence: object
  planned but not built (intentional or oversight?), object built but not planned (scope creep or
  gap-fill?), a rule implemented differently (is there a ChangeLog entry?). Classify each as
  **Intentional**, **Oversight** (fix now via the Step 5 cycle), or **Spec stale** (code's right —
  update `docs/2-design/DesignDoc.md`).
- **Code review** — one pass across every object: consistent structure/naming/formatting
  throughout (small projects still drift between the first file written and the last); no dead
  code (**Standards §1.5**); no reference to anything with `ObsoleteState = Pending`/`Removed`,
  unconditionally and with no version check (**Standards §3.2–§3.3**); both permission sets named
  with the App Code (**§5.4**). `Rec.`-prefix everywhere and every table's `tabledata` coverage are
  already proven by the last 0/0 compile — confirm it ran with the analyzers this framework
  requires (ALL ALONG → Analyzers) and nothing is suppressed, rather than re-deriving either check
  by hand. Correct `DelayedInsert`/`Editable` per data mutability (**§2.2**) still needs a human
  read; a compiler can't judge it. **Then run the full
  Anti-Patterns table — Standards Part 7 — against the codebase.** Then check every child list or
  list part against all six parts of **§11.1** and every number-series field and numbered table
  against **§11.2** — read each `OnNewRecord`, each child table's `OnInsert`, and each wizard's
  field bindings, not just the page properties. The Part 7 table is one table and it reads in
  a couple of minutes; it's the single highest-value thing the Standards Guide gives a Lite
  project, because most of what it catches is invisible until publish or until a consumer hits
  it. `TranslationFile` is on for every project (**§8.2**), so a 0/0 compile already proves the
  compiled codebase is free of `CaptionML`, `ToolTipML`, and the rest via `AL0424` — search anyway
  for anything added since that last compile, human-pasted included, so nothing new slips past
  before the next one. Read the code against
  AL Guidelines' *Best Practices* and *Vibe Coding Rules* for anything the Standards Guide doesn't
  already cover (the Standards Guide wins on any conflict — surface it rather than picking a side
  silently). **Translations:** run every technical translation check with all rules enabled, then
  review against **Standards Part 8** — no hard-coded user-facing strings, `Comment`s on
  placeholders, glossary terms used consistently, likely truncation in longer languages, and API
  caption locking re-verified against the Step 2 records. Then invoke the BCQuality snapshot's `skills/entry.md` dispatch flow (fetched at Step 3) as
  an additional, independent pass, and fold its findings in the same way as your own — never
  applied blind. If the fetch didn't happen or the snapshot is missing, say so rather than
  silently skipping this pass.
  **Then grade the scorecard** — the same eight dimensions as the full framework's Code Review §0,
  each **A–F** with one line of evidence, and an overall grade that is the lowest of the eight,
  stated as such: *Standards compliance* (Standards Guide adherence, Part 7 anti-patterns);
  *Correctness and robustness* (validation, `TestField` and error handling, edge cases, Part 11
  client-page rules); *Readability and maintainability* (naming, structure, consistency across
  batches, dead code); *Performance* (`SetLoadFields`, keys and SIFT, record loops, FlowFields,
  repeated lookups); *Security and permissions* (permission set coverage, `Access`, API data
  exposure, secrets); *Upgrade safety* (obsolete references, upgrade codeunits and tags, schema
  changes needing Force Sync); *Translation readiness* (labels with comments, no hard-coded text,
  glossary consistency, truncation risk); *Test coverage* (AL test codeunits present and
  meaningful, test script coverage). Rubric: **A** no findings; **B** minor findings only; **C** at
  least one major, fixed in this step; **D** several majors, or one critical, fixed in this step;
  **F** a critical left unresolved or accepted. Lite has no `CodeReview.md`: **write the table
  into this step's `docs/0-project/ChangeLog.md` entry.**
- **Update `docs/2-design/DesignDoc.md` in place** to reflect the as-built reality — final object inventory, any
  naming or exception that emerged during BUILD, a short deviation summary pointing at the
  relevant `docs/0-project/ChangeLog.md` entries. There's no separate as-built document in Lite; one file, kept
  current, is the point.
- Present this step's fixes together for one approval, as in Step 5. Any fix this step produces
  follows the Step 5 cycle (recompile, repackage, redeploy, retest) before this step closes; a
  comment/formatting-only fix doesn't need a fresh package.
- **Write `docs/4-prove/Docs.md`** — one combined reference covering everything the full framework splits
  across four documents:
  - *API/dev reference*, generated from the actual code, not memory: one section per object, one
    row per field (identifier, source name, description, R/W status); a quick-start (auth, one
    request, one response); `$filter`/`$select` examples; create/update/delete examples; known
    limitations.
  - A Mermaid `erDiagram` of the schema, generated from the actual objects — every table the
    extension owns *and* every standard table it touches via `TableRelation`/`tableextension`.
    **Render it before shipping it** — the check is **Ops § Tooling Checks**: `node --version`,
    then `npx --yes @mermaid-js/mermaid-cli --version`, never `which mmdc` (an npx-cached package
    is never on `PATH`); if Node is missing, offer the per-OS install under Rule 6b and record the
    outcome in `ocpfFramework/framework.json`. A syntactically invalid diagram looks fine in the
    source and only fails wherever it's finally viewed.
  - A short **user guide** section: what the feature is for, how to do each task, what to do when
    something is refused — written for the person clicking around in BC, not a developer.
  - A short **deployment** section: version requirements, install procedure, which permission sets
    map to which roles, uninstall, and which users to reassign if a release renames a permission set.
- **Write `docs/4-prove/TestScript.md`** — the green-team/red-team checklist from Step 5, made concrete against
  this extension's actual endpoints, plus one green-team case per parent→child entry point and one
  per number-series field from **Standards §11.3**, for a human tester to run end to end at Step 7. With more
  than one required language, add a **language pass**: key pages, messages, and customer-facing
  documents walked once per required language, checking for untranslated text, truncation,
  regional terms, and formats. Each case names the glossary terms the tester should see, so a
  tester who reads English can run it without a translated copy.
- **If the project has AL test codeunits, run them — don't leave it to the human.** The AL MCP
  Server's `al_run_tests` runs them against the sandbox, one codeunit per call (**Ops § Automated
  Tests**), never against production. A failing test fails this step like a compiler error. If the
  server isn't connected, say so and list the codeunit IDs rather than reporting untested code as
  tested.
- **Write `docs/0-project/Acknowledgements.md`** from its template — one row per resource actually
  used on this project, with author, license, and how it was used (the framework, BCQuality, the
  patterns library, the AL Language extension and AL MCP Server, XLIFF Sync or NAB AL Tools if
  used, mermaid-cli, and the AI tool with the models used), closing with the template's note that
  none of these credits is legally required and nothing from them is bundled in the shipped
  `.app`. Always committed.
- **Translated documents aren't produced here.** Step 7 produces them once its functional test
  pass is green, so a fix found in testing doesn't make every translated copy stale too.
- **Last, before the hand-off message** (Step 7's note), ask (Rule 6a): **Build the release
  candidate v1.0.0.0 now? (recommended)** / **Keep testing on 0.x builds**. Yes: set `1.0.0.0`
  in `app.json`, compile and package (the fixed *Package built* message, Step 5), and log a
  ChangeLog entry. For an existing app the RC is the next Minor (or Major) from the starting
  version, proposed. Fixes during release testing continue `1.0.0.1`, `1.0.0.2` …, and the package
  that passes ships as it is (ALL ALONG → Packaging & Versioning).

**Outputs:** `docs/2-design/DesignDoc.md` (updated in place, glossary included), `docs/4-prove/Docs.md`, and `docs/4-prove/TestScript.md`.
Together with `docs/0-project/ChangeLog.md` from Step 1 onward, that's Lite's four maintained documents; translated
documents follow at Step 7. Also: the code-review scorecard in this step's ChangeLog entry,
`docs/0-project/Acknowledgements.md`, and — if the human said yes — the release candidate
`outputAppPackage/<Name>_1.0.0.0.app`. Step 1's `docs/1-define/ProblemStatement.md` and
`docs/1-define/ProjectParameters.md` are also tracked, but written once at kickoff rather than kept current.

**Exit gate:** Every gap classified and resolved or explicitly deferred (logged in
`docs/0-project/ChangeLog.md`); dead-code scan clean; no obsolete references; `docs/4-prove/Docs.md`'s diagram renders;
`docs/4-prove/TestScript.md` is executable by a non-developer; translation checks clean; any AL test codeunits
have been run and pass, or it's recorded why they couldn't be; the eight-dimension scorecard is in
the ChangeLog entry; `docs/0-project/Acknowledgements.md` exists with one row per resource used;
the release-candidate question is answered and, on yes, `1.0.0.0` is built. This step's usage rows, one per model, are written before this message (Operating Rule 9).

**Step close (Rule 6c) — mandatory, never a prose prompt:** once the exit gate is met and the usage rows are pasted, this boundary closes with **Step 7's hand-off box** (the note at the top of `STEP-7.md`: "Perfect, I understand!" / "I have some questions."), which replaces the generic Proceed / Stop box here. Send that box, not both, and nothing of Step 7 starts until the human answers it.
