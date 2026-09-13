# Agentic Development Framework — Changelog

Tracks changes to the **Agentic Development Framework** itself (the agent runbook that drives
DEFINE → DESIGN → BUILD → PROVE) — independent of any single project built with it. The framework
is distributed as a standalone repository; a project built from an earlier copy won't otherwise
know if or how the framework it's using has since changed. Check here for what changed and why.

Entries are grouped by version, newest first, and describe the **cumulative** result of a
version's changes — not the drafting history behind them. If a change was revised multiple times
before the version that introduced it ever shipped, only the final, current form is recorded
here as one entry; incremental churn within a single unreleased version isn't itself
change-worthy. (This is a different convention from a project's own ChangeLog, which exists
specifically to keep a superseded decision on record — see the runbook's ALL ALONG guidance.)

---

## v2.1.0.0 — 2026-09-13

**The single biggest structural change since v2.0.0.0** — a whole step dropped, four others
renumbered, a new step added — released as its own minor version rather than folded into
v2.0.1.0, which had already shipped to the pilot project the day before under the old structure.

### Step 09 dropped; compile-and-package made a continuous cycle; new Step 12 added

AJ Ansari: "Step 9 keeps tripping me up" — the old sequence talked about a single mandatory
*compile*, then a separate, later *Package and Test the App* step (old Step 09) that ran
green-team/red-team API tests against a `HumanUnitTestScript.md` that, at that point in the
sequence, hadn't even been written yet (that script was old Step 12's output). Packaging and
live-sandbox testing were also already happening in practice throughout Step 07's troubleshooting
loop on the pilot project, well before old Step 09 was ever reached — the runbook's own words
didn't match how the framework was actually being used.

- **Changed — Operating Rule 4 and Step 07's own title/actions: "compile" → "compile and
  package," and the mandatory event became a continuous cycle.** Step 07 is renamed **"Compile
  and Package, Troubleshoot, Iterate."** The one mandatory compile at the top of Step 07 is now a
  mandatory **compile-and-package**; from there, Step 07, Step 08's gap-fix loop, and Step 09's
  Code Review fixes (whenever any of them needs a code change) share one explicit cycle: publish
  to a sandbox → test → diagnose → fix → **compile and package again** → redeploy → retest →
  repeat. Packaging is no longer a milestone reserved for a later step; it is the default rhythm
  of BUILD/PROVE from the moment Step 07 opens. `outputAppPackage/` naming, never-delete, and
  Schema Sync Mode/Force Sync guidance all apply from the very first package onward.
- **Removed — Step 09 ("Package and Test the App") entirely.** Its concerns split two ways: the
  actual green-team/red-team API checklist is now defined once, in Step 07 (as its own named
  block, not buried inside the optional pass that uses it), reused three times — optionally by
  the agent at the end of Step 07, as the source Step 11 writes `HumanUnitTestScript.md` from,
  and authoritatively by humans at the new Step 12.
- **Added — an optional, agent-run API test pass at the end of Step 07, gated on a live MCP
  connection.** Once the extension is compiling and packaging cleanly, the agent offers to run
  the checklist directly against the published sandbox — but only if, and because, the human can
  supply a working connection (the AL MCP Server, or another authenticated MCP endpoint reaching
  the sandbox's API). This is optional and conditional, never assumed available. If no working
  connection exists, the agent says so plainly and suggests manual alternatives instead of
  leaving API testing undone — **Postman**, or a low-code caller like **Power Automate**,
  **Power Apps**, or **Copilot Studio**.
- **Renumbered — Code Review (09, was 10), Update Design Documents (10, was 11), Document the
  Code (11, was 12).** Every internal cross-reference in `CLAUDE.md` updated to match (§1.7's
  role table, Step 04's rationale, the BCQuality section, the Stage↔Step Map, the ALL ALONG
  sections) — see the follow-up review below for the ones a first pass missed, including in
  `RunbookSchematics.md`.
- **Changed — Step 11 (Document the Code) gains a genuine question: does the human also want
  Automated Test Scripts?** Alongside — never instead of — the Human Unit Test Script. Framed
  explicitly as a real decision, not a default: automated scripts (a Postman/Newman collection, a
  Playwright suite, etc.) imply an ongoing maintenance commitment a one-time manual script
  doesn't. If yes, the agent also asks what tooling to standardize on (recommending a Postman
  collection as the lowest-friction default if the human has no preference), what should trigger
  a re-run, and where the scripts should live — then writes a companion `AutomatedTestScripts.md`
  (separate from `HumanUnitTestScript.md`) explaining how to run and maintain them.
- **Added — Step 12, "Release to Users for Testing," a new, fully-structured step** (its own
  Role/Inputs/Actions/Outputs/Exit gate, the same rigor as every other step) covering what old
  Step 09 tried to cover too early: real users run `HumanUnitTestScript.md` (and
  `AutomatedTestScripts.md` if it exists) end to end against the latest package, on a sandbox,
  *after* Code Review and documentation are done. Outputs `docs/ReleaseTestResults.md`. **Its
  exit gate is also the production go-live gate:** if everything passes, the package that was
  actually tested is the one deployed to the Production company (see the never-delete correction
  below for exactly how that package is marked before it ships) — no new package is built solely
  to "finalize" a release.
- **Net step count: still 12** (numbered 01–12), just reshuffled — dropping old Step 09 and
  adding new Step 12 cancel out. AJ's own initial estimate ("11 instead of 12") assumed the new
  release-testing step wouldn't need its own formal slot; resolved by asking directly (AJ chose
  the fully-structured Step 12 over a lighter closing-section alternative) rather than guessing
  either way.
- **Updated:** Stage↔Step Map (Stage 7 now notes Step 07 also carries the first compile-and-package
  cycle; Stage 8 = 08+09; Stage 9 = 10+11; Stage 10 = 12 → production); ALL ALONG → Document
  (added `ReleaseTestResults`, conditional `AutomatedTestScripts`); Testing Feedback Log (now
  starts "from Step 07 onward," not "throughout PROVE" — sandbox testing is mandatory in BUILD
  now, not a PROVE-only concern; test-run record cites Step 12, not old Step 09); Packaging &
  Versioning (intro and the "offer to repackage" bullet reworded from an occasional ask to the
  default rhythm of Step 07/08/09; folded in a note to confirm `app.json` identity before every
  build, moved here from old Step 09; "push back on a premature ask" rescoped to requests
  *outside* the cycle, since packaging with known open issues is now the cycle's own point, not
  a violation of it).

### Independent review of the restructure, and its fixes (2026-09-13)

Per §1.7, a reasoning-role subagent ran a full self-consistency review of the restructure above —
the same kind of pass recorded under v2.0.0.0's "Full self-consistency review" entry, this time
targeted at a much larger, more recent edit. Main role independently re-verified its four
highest-priority findings against the actual files before trusting them (confirmed all four).
Findings and resolutions:

- **Corrected — package overwrite now legitimately collides with "never delete a previous
  package."** Filenames derive only from `<ExtensionName>_<version>`, so the new "repackage every
  fix" default means same-version cycle builds now routinely write the identical filename — the
  never-delete rule as originally worded forbade this. **AJ Ansari's decision:** the protection is
  per-version, not per-file — interim cycle builds at one version may overwrite each other freely;
  the specific package that passes Step 12 gets its **Build** segment bumped (e.g. `0.0.5.0` →
  `0.0.5.1`) or is copied to an immutable filename before shipping, so the release candidate stays
  permanently identifiable and is never itself silently overwritten. Step 12's exit gate and the
  Packaging & Versioning "never delete" rule both updated to say this explicitly.
- **Fixed — a stale step number survived in `RunbookSchematics.md` §4.2** ("Code Review (10)"),
  even though `CLAUDE.md`'s own copy of the same fact was correctly updated to (09). Exactly the
  kind of drift a same-agent re-read is least likely to catch.
- **Fixed — three residual contradictions of the new model, all in `CLAUDE.md`:** Step 12's
  Inputs triggered a repackage on "Step 09/10/11 touched code or docs," even though Steps 10–11
  are documentation-only and the rule elsewhere is explicit that doc-only changes never need a
  repackage; the AL MCP Server section still said "compiling the actual extension is not
  automatic anywhere in BUILD," directly contradicted by Step 07's now-mandatory, now-automatic
  compile-and-package; Operating Rule 4's "continuous rhythm" sentence named Step 07/08 but not
  Step 09, though three other places (Packaging & Versioning, Step 09 itself, this very changelog
  entry) already say the cycle covers Step 09 too.
- **Fixed — the PROVE diagram in `RunbookSchematics.md` §3.4 showed a gate being satisfied by a
  fix loop drawn *after* it.** Gate 1's label claimed "code fixes recompiled/repackaged" while the
  gap-fix decision/loop was drawn downstream of that gate, not upstream — the diagram taught the
  opposite of what `CLAUDE.md` says. Reordered so the fix loop precedes its gate; the same
  fix-loop pattern was also missing after Step 09 and Step 12 in the diagram (present in prose,
  absent in the picture) — added both, plus a Step 12 "no → loop back" edge that was implied by
  the text ("repeat until…") but never drawn.
- **Tightened, same pass (lower priority, all applied):** the green/red-team checklist promoted
  out of the "optional MCP pass" paragraph into its own named block, since Step 11 and Step 12
  both depend on it unconditionally, not just when the optional pass runs; Step 12 gained a
  reminder to re-run whichever of Step 09/10/11 a late fix actually invalidates (documentation
  generated from code is stale the instant the code changes, and old Step 09 never had to worry
  about this because it ran *before* documentation existed); Step 12 gained an explicit
  restate-Schema-Sync-Mode action before the production deploy, since its exit gate is now the
  one moment that decision matters most; Step 12 gained a one-line Role block and an explanation
  of why `UserGuide.md`/`Deployment.md` are listed as its inputs; the BUILD diagram's `Compile`
  node was missing from its own color class, and its API-connection check read as mandatory
  rather than optional — both fixed; the Testing Feedback Log's "throughout PROVE (and sometimes
  earlier, on a demo)" framing corrected to "from Step 07 onward" since sandbox testing is now
  mandatory in BUILD; two "old Step 12"/"old Step 09" mentions that read ambiguously against the
  *new* meaning of those numbers were qualified as "old"; the front-matter description's
  "deployable app" softened to "app deployed to production," matching the routine's new actual
  end point; `AutomatedTestScripts` added to the ALL ALONG document-inventory list itself, not
  just its trailing prose.
- **Version bump, not a fold-in:** this review, and its fixes, are why the restructure above
  shipped as **v2.1.0.0** rather than folding into v2.0.1.0 — a change this size, found to still
  have five real defects on independent re-read, earns its own version number rather than hiding
  inside a point revision that had already shipped the day before under a different structure.
- **Not fixed, deliberately: the rendering gap.** No Mermaid renderer is available in this
  environment, and Operating Rule 6b blocks installing one unprompted. The reviewing subagent
  confirmed all 8 diagram blocks (including the ones this pass re-edited) pass structural checks
  — balanced delimiters, every `class`-referenced node ID actually defined — but structural
  parsing is not a render, and `RunbookSchematics.md`'s own header promises every diagram *was*
  rendered before being committed. That promise is not currently true for the diagrams touched in
  this version. Flagged here rather than silently claimed otherwise; re-render before fully
  trusting §2, §3.3, and §3.4's Mermaid blocks.

### OCPF BC AL Patterns Library — a new ALL ALONG section (2026-09-13)

**OCPF = OnlyCopilotFans**, the abbreviation used throughout. AJ Ansari had a standalone AL
pattern library created the same day (`patterns/Pattern-SubPageLink-FilterGroup4.md`,
`patterns/Pattern-Init-Does-Not-Clear-Primary-Key.md`, plus a `README.md` — see that folder's own
README for what it is: "OnlyCopilotFans Business Central AL Patterns," a portable library meant
to travel across engagements, not tied to the pilot project it was first extracted from) and
wanted the runbook to bootstrap it into every future project automatically, the same way it
already bootstraps the AL MCP Server and BCQuality.

- **Added — a new ALL ALONG section, "OCPF BC AL Patterns Library."** Modeled closely on the
  BCQuality Knowledge Snapshot section (same one-time-fetch-refreshed-on-request cadence, same
  "tell the human, don't fetch silently" principle, same `SNAPSHOT.json` metadata convention), with
  three deliberate differences:
  1. **Location — inside the project root**, in `patterns/`, not outside it. BCQuality has to
     live outside because its illustrative `.good.al`/`.bad.al` snippets aren't real compilable
     objects and `alc` would try to swallow them; every file in this library is Markdown with
     embedded AL code, so that failure mode doesn't exist here and nothing forces it out.
  2. **Merge behavior, not a plain overwrite — a human-specified exception for the README
     specifically.** If `patterns/` doesn't exist, create it and copy the fetch in. If it already
     exists and already has a `README.md`, **append** the fetched repo's `README.md` to the
     existing one under a fixed delimiter (`## Upstream README — ajansari/ocpfBCALPatterns @
     <sha>`), rather than overwriting it, so any project-specific content already documented there
     survives — and so a later *refresh* can find and replace that exact block instead of
     appending a second copy underneath the first. Pattern-file name collisions (a case AJ didn't
     specify) default to *flag and ask, per Operating Rule 6a*, not silent overwrite — filled in
     explicitly as a gap-fill and marked as such in `CLAUDE.md` itself, not invented silently or
     left looking as authoritative as AJ's own README rule.
  3. **Gitignored — same *policy* as BCQuality and `scripts/`, though the *mechanism* differs
     from BCQuality's.** BCQuality lives outside the project root entirely, so it isn't even a
     candidate for git tracking; `patterns/` lives inside the root, so it genuinely needs its own
     `.gitignore` entry to reach the same result. Either way: this is the human's own portable
     methodology, not part of what a client is paying to receive, and it's refetchable at will.
- **Wired into Step 05** (bootstrap, alongside AL MCP Server + BCQuality), **Step 07** (Compile and
  Package, Troubleshoot, Iterate) — check `patterns/` for a matching, already-documented pattern
  *before* running the three-questions diagnosis from scratch — and the **Testing Feedback Log**'s
  own reasoning-role diagnosis bullet, which now states the same check explicitly rather than
  relying on its existing "same as Step 07" cross-reference to carry it silently. A library nobody
  consults during troubleshooting is fetched for nothing; this is the actual payoff the fetch
  exists to enable.
- **Contribution direction also wired, at Step 09 (Code Review), not just consumption.**
  Recognizing "this looks like it'll recur" is the agent's job everywhere a fix happens; deciding
  to add it to a library the human carries across every other engagement is his call, never the
  agent's to make unilaterally — but Step 09's own cross-batch read is one of the best moments in
  the whole routine to actually notice a repeated shape, so it now says so explicitly, alongside
  the same flag-don't-add rule already stated in the Patterns section itself.
- **Applied to the pilot project the same day:** its own `patterns/` folder (created earlier that
  day, before this runbook section existed) is treated as already satisfying this bootstrap step
  — the two pattern files and their `README.md` already exist locally, so no fetch from
  `ajansari/ocpfBCALPatterns` was actually run against this project. `.gitignore` already had a
  `/patterns/` entry from that earlier same-day work; **this change moved it** into the "always
  gitignored, not a per-project choice" block alongside `scripts/`, and rewrote its comment, which
  had said the library was "not yet wired into the runbook" — true that morning, false the moment
  this section existed.
- **Corrected on independent review, same day (Opus, limited-scope pass on this section only):**
  a stale reference to Step 07's pre-restructure title ("Troubleshoot, Iterate," missing "Compile
  and Package"); the pattern-file-collision rule not citing Operating Rule 6a and reading as if it
  carried the same authority as AJ's own README rule; the Testing Feedback Log claim above having
  nothing on the other end before this pass; a flat "public" repo claim in `CLAUDE.md` that
  `ProjectMemory.md` hedged as "meant to be" — resolved by dropping the unverifiable adjective and
  adding an explicit "if unreachable, say so and continue" fallback, since neither this session nor
  the reviewing subagent could confirm the repo has actually been created; and this entry's own
  now-corrected claim that no `.gitignore` change was needed, when the same commit had in fact
  moved and rewritten that entry. `RunbookSchematics.md`'s Step 07 diagnosis node (§3.3) updated to
  show the patterns-check ahead of the three questions, matching the text.
- **Resolved, same day:** whether `ajansari/ocpfBCALPatterns` actually exists. AJ Ansari confirmed
  it directly; independently verified rather than taken on his word alone — `git ls-remote` against
  the bare URL returned a `main` branch with no authentication required (confirming public), and
  its rendered README on GitHub matches this project's own local `patterns/README.md` ("OnlyCopilotFans
  Business Central AL Patterns," same opening paragraph) plus both pattern files. `CLAUDE.md`'s
  "public" claim, softened to an unverified adjective earlier the same day pending this check, is
  restored with the verification method and date attached, so the next reader doesn't have to
  re-litigate it. The "if unreachable" fallback stays in place regardless — a repo confirmed
  reachable today isn't guaranteed reachable on some future project's Step 05.
- **Also fixed, found by the same review but pre-existing and unrelated to this section:** this
  file's own version sections weren't in the newest-first order its header promises (§8–13) — the
  prior round's v2.1.0.0 entry had been appended after v2.0.1.0 rather than before it. Reordered
  to v2.1.0.0 → v2.0.1.0 → v2.0.0.0 → v1.0.0.0; no content changed, only position.

---

## v2.0.1.0 — 2026-09-12

A packaging/deployment-communication gap found the same day, while wrapping up a bug-fix
round on the pilot project — released as its own point revision rather than folded into
v2.0.0.0, since v2.0.0.0 had already been established as the framework's first versioned
baseline.

### Output folder naming & Schema Sync Mode / Force Sync guidance (2026-09-12)

- **Added — a fixed output-folder name.** "Packaging & Versioning" now names the folder every
  built `.app` package is written to: **`outputAppPackage/`**, in the project root, the same way
  package *naming* was already fixed (`<ExtensionName>_<version>.app`) — not `out/`, `output/`,
  or whatever a given project happened to improvise. Step 01 intake now tells the human this
  folder name once, plainly, before any package exists; Step 07's compile-and-package cycle (and
  any later ad hoc repackage) restates the exact path plainly every time a build actually
  completes — e.g. "Package built:
  `outputAppPackage/IP_Tracking_1.0.0.0.app`" — as its own clear line, not folded into a longer
  status paragraph.
- **Why:** the pilot project had been calling this folder `out/` by unexamined precedent, with no
  runbook rule actually requiring that name or requiring the agent to say where it is. AJ Ansari
  asked for both the fixed name and the two required call-outs (intake, and every completed
  build) so a human is never left to go hunting for a package that already exists.
- **Added — Schema Sync Mode / Force Sync flagging, on every completed build.** A new Packaging &
  Versioning bullet requires checking, for every completed build, whether its schema changes are
  additive-only (new tables/fields, code-only changes — safe under Business Central's default
  **Add** Schema Sync Mode when uploading via the Extension Management page or admin center) or
  destructive (anything removed, resized down, retyped incompatibly, or with an altered primary
  key — needs **Force Sync**, which can cause data loss), and saying so plainly rather than
  assuming the human already knows. Distinguishes this from the similarly-named but different
  `schemaUpdateMode` setting in `launch.json` (`Synchronize`/`Recreate`/`ForceSync`), which governs
  local F5 dev-publish only and is explicitly never meant for production — the runbook now says
  not to conflate the two when explaining this to a human.
- **Verified before writing in, not assumed from memory** (Operating Rule 2's own discipline,
  applied to the runbook's own authoring): the exact terminology — **Schema Sync Mode**, **Add**,
  **Force Sync**, and the data-loss caution — was confirmed against current Microsoft Learn and
  the original BC19 (2021 wave 2) release-plan documentation before being written into the
  runbook, rather than reconstructed from a half-remembered UI label.
- **Applied to the pilot project the same day:** its own `out/` folder was renamed to
  `outputAppPackage/` (all existing packages preserved, none deleted, per the existing
  never-delete policy) and its `.gitignore` updated to match — see that project's own ChangeLog
  (Issue BUILD-18) for the full record, including a retroactive Force Sync assessment of its most
  recent build.

### Schematics — Model & Effort Assignment diagram clarified (2026-09-12)

- **Changed — `RunbookSchematics.md` §4.2.** The diagram named what each of the three §1.7 roles
  *does* but not *how it executes*: it now labels the Main role box "runs in the primary agent
  session" and the Light and Reasoning role boxes "runs in a subagent" — matching §1.7's own text
  ("the agent *can* delegate a specific, self-contained task to a subagent running a different
  model, get a result back, and act on it"), which the diagram had never actually shown.
- **Added — an example recommended model to each role box**, matching how the pilot project
  actually configured §1.7 (`ProjectParameters.md`): **Sonnet** for Main, **Haiku** for Light,
  **Opus** for Reasoning. Illustrative only — §1.7 itself stays deliberately model-agnostic, and a
  different project can assign different physical models to the same three roles.
- **Why:** AJ Ansari noticed the diagram was silent on both points while it's otherwise the
  clearest single picture of how the three-role split actually runs.

---

## v2.0.0.0 — 2026-09-12

First versioned revision. Everything below was learned during the framework's first real
project (a Business Central bootcamp-registration tracking PTE) and folded back into the
framework itself, dated to when each change actually happened during that project.

### Compile cadence (2026-09-11 → 2026-09-12)

- **Changed — Operating Rule 4.** Original rule: compile after every batch, never generate all
  batches first. Final form: **no per-batch compile at all.** Every batch is pre-flighted as it's
  written — including a new **symbol verification** check (every reference to a standard/base
  object, field, method, property, or enum value confirmed against the downloaded symbol source,
  falling back to the MS Learn BaseApp docs per Operating Rule 2 when the downloaded symbols don't
  answer). The whole extension compiles exactly **once**, automatically, the moment every planned
  batch (including gap-fill work) is written — this is now Step 07's opening action, not an
  open-ended "whenever the human asks." A human may also request an earlier spot-check compile
  mid-BUILD; that's additional, not a substitute for the one at the end of BUILD.
- **Fixed — every other place that assumed a different compile timing.** A self-consistency
  review the same day found six places still contradicting the tightened rule: Step 05's exit
  gate required a compile before any code existed; Step 07's own outputs/exit gate reinstated the
  "compile clean before BUILD closes" version the rule had just removed; Step 09 listed a
  clean-compiling extension as an *input* to the step that might produce it; the Packaging
  section's repackage trigger ("a batch finishes compiling") could never fire once batches stopped
  compiling; the AL MCP Server bootstrap told the agent to "invoke a build tool" during Step 05
  scaffold setup; and Rule 5 ("zero errors before PROVE") allowed the first compile to happen
  as late as inside Step 09, two steps into PROVE. Resolved by making the single mandatory compile
  a well-defined, always-runs point (Step 07 Action 0) rather than an arbitrarily deferred one —
  Rule 5 is now true by construction instead of contradicted.
- **Why symbol verification, specifically:** a lint pass without it is pattern-matching from the
  same kind of intuition that produces a hallucinated reference in the first place — checking
  against the actual symbols is the one thing that verifies against ground truth instead of a
  plausible-looking guess. This is what closes the gap left by deferring the compiler further.
- **Trade-off, accepted deliberately (AJ Ansari):** even symbol-verified lint cannot catch
  everything a real compile does — cross-file type mismatches, full semantic validation, and rule
  interactions the compiler's own engine resolves are still invisible until an actual compile
  runs. A systemic issue found only at that eventual compile can therefore touch more
  already-written files than catching it earlier would have. Accepted because generation speed
  matters more, and because symbol verification specifically targets the failure mode this
  decision was actually worried about.
- **Changed — Step 05, 06, 07 wording** updated to match throughout: Step 05's pre-flight list
  gains the symbol-verification check; Step 06 no longer compiles at all as part of its own exit
  gate (lint-clean, including symbol verification, is what closes it); Step 07's Inputs now read
  from "whenever compiling is actually triggered" rather than assuming it happens right after
  Step 06; the BUILD phase's own Goal statement was reworded to match.

### Tooling installation (2026-09-11)

- **Added — Operating Rule 6b.** Before concluding a required compiler/runtime is missing and
  reaching for an install, check whether the human's own IDE already provisions one privately for
  the tool in question — e.g. VS Code's AL extension gets its .NET runtime from a companion
  ".NET Install Tool" extension, not a system-wide install, at a path under
  `~/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/`
  on macOS (or the equivalent per-user path elsewhere) — *before* assuming none exists. Installing
  anything is a human-in-the-loop decision (rule 6) regardless of what a fallback option
  elsewhere in the runbook lists as available.
- **Why:** on the pilot project, the agent skipped this search, concluded no .NET runtime existed
  on the machine, and installed a fresh one into `~/.dotnet` without asking — when VS Code had
  already been running the same compiler the whole time via its own private copy. The agent had
  to remove what it installed once this came to light.

### Intake — Step 01 (2026-09-11)

- **Added — §1.6 Onboarding & Discoverability.** Three new intake questions, asked at Step 01
  (not left to emerge mid-DESIGN): should the extension include an **Assisted Setup Wizard**
  (and if so, what it configures); should the Role Center get **Activity Cues** (and if so,
  which ones, their filters, and drill-through targets); should the extension be findable via
  **Departments / "My Business Central"** (and if so, under which department, with which pages).
  A `No` to any is a valid, final answer — not a placeholder to revisit.
- **Why:** discovered mid-project when the human asked "does our app have any activity cue
  tiles?" and the honest answer was no — not because it was rejected, but because nothing in the
  framework had ever asked at intake.

### Permission-set coverage (2026-09-11)

- **Changed — Step 03 (TDD) permission-set guidance.** Added: the batch plan must ship each
  table's `tabledata` grant in the *same batch* that introduces the table — never deferred to a
  later batch.
- **Changed — Step 04 (Sanity Check) checklist.** "Permission sets are planned if enabled"
  strengthened to require every table's `tabledata` grant explicitly enumerated per set, not
  just "permission sets exist."
- **Changed — Step 05 pre-flight checklist.** Added permission-set `tabledata` coverage for
  every table a batch introduces, as its own named check.
- **Added — Step 06 Action 7.** An explicit, non-compiler verification pass before leaving the
  step: every table built across every batch must have a matching `tabledata` grant in both the
  read-only and read/write permission sets. Needed specifically *because* of the compile-cadence
  change above — the platform's own check for this (`PTE0004`) fires only at publish, which now
  happens after Step 06 rather than after each batch.
- **Changed — Step 10 (Code Review) Best Practices bullet.** Added independent re-verification of
  permission-set coverage — don't just trust Step 06's check.
- **Why:** the pilot project's batch plan deferred both permission sets to the final batch (valid
  for a pure compile, but not for a publish-based workflow); publish failed with `PTE0004`
  (missing permission set) on the very first batch, forcing a batch-plan rewrite after code
  already existed. All five of the above exist so the next project catches this at design time
  instead.

### Model & effort assignment — Step 01 §1.7 (2026-09-12)

- **Added — §1.7 Model & Effort Assignment.** New intake question, asked once before DESIGN
  begins: whether to split work across a **fixed three-role division of labor**, kept
  deliberately model-agnostic (no vendor/model names, so the guidance travels to any harness). If
  configured:
  - **Main role** — all BUILD code generation, all actual code edits (including applying what the
    other two roles report), and end-to-end ownership of the project's continuity documents:
    ChangeLog, Object Register, ProjectMemory, and `TestingFeedback.md` itself (recording sessions
    verbatim, then logging the triage decision once the reasoning role's diagnosis confirms it).
  - **Light role** — fast, cheap, checklist-driven verification only: the Step 05
    post-generation pre-flight pass, **explicitly including symbol verification** (a lookup
    against ground truth, not a judgment call, so it fits the cheap/fast role rather than the
    reasoning role). Reports findings; never edits code.
  - **Reasoning role** — heavier-reasoning, fresh-eyes work: Sanity Check (Step 04), Gap-Fit Test
    (Step 08), Code Review (Step 10), FRD authorship (Step 02), TDD authorship (Step 03), and
    root-cause troubleshooting/diagnosis (Step 07, and diagnosing *why* a PROVE-phase
    testing-feedback report is real). Reports findings/drafts/diagnoses; never edits code or the
    continuity documents itself.
  - The division is fixed regardless of which physical models are assigned to each role: the
    light and reasoning roles investigate, draft, or diagnose; the main role is the only one that
    edits code or owns the continuity documents. This preserves one consistent author/style
    across the codebase (the same concern Step 10 already names: "early and late batches often
    drift — normalize") and keeps root-cause tracing in one continuous thread instead of
    fragmenting across cold hand-offs.
  - **Wired into:** Step 02 (FRD drafted by reasoning role, sign-off unchanged), Step 03 (TDD,
    same pattern), Step 04 and Step 08 (both formal reviews, same pattern as Step 10), Step 05/06
    (the pre-generation pre-flight pass is main-role TDD housekeeping; the post-generation pass is
    light-role), Step 07 (root-cause diagnosis by reasoning role, fix applied by main role),
    Step 10 (review by reasoning role, fixes applied by main role), and the Testing Feedback Log
    (diagnosis is reasoning-role; the main role applies the fix and separately owns the triage
    recording itself — a wrong diagnosis is marked superseded in the project's own ChangeLog, not
    deleted).

### AL MCP Server & BCQuality Knowledge Snapshot (2026-09-12)

- **Added — AL MCP Server, as a new ALL ALONG section.** The AL Language extension's standalone
  MCP server (`altool launchmcpserver`) exposes build/publish/symbol/diagnostic tools over MCP,
  so a capable harness can drive them directly instead of shelling out to the compiler by hand.
  Documented as a one-time-per-project bootstrap (locate `altool`, confirm `app.json`/`launch.json`,
  register with the harness's MCP config preferring project scope, verify the connection) plus a
  standing preference thereafter for the MCP tools over an ad hoc terminal wrapper where both are
  available. Wired into Step 05 (bootstrap at scaffold time, alongside the rest of the one-time
  project setup). **Kept harness-agnostic throughout** — no product-specific config format or CLI
  named as a requirement, only "whatever MCP host the agent's harness provides." **Cross-platform
  picture, explicit rather than assumed:** `altool.exe` is a native binary on Windows (invoke it
  directly, no wrapper needed — simpler than macOS/Linux, not harder); on macOS or Linux the
  shipped `.exe` won't run and `altool.dll` must be invoked against a .NET runtime instead — and
  the IDE-provisioned-runtime fallback path itself differs by OS (verified working on macOS this
  project; the Linux path is written from that OS's documented convention, not from an actual
  test on it).
- **Added — BCQuality Knowledge Snapshot, as a new ALL ALONG section.** `microsoft/BCQuality` is
  a curated knowledge base and skill library for BC AL code quality (non-obvious platform rules,
  security/performance/privacy footguns) — content, not a service. Documented as a one-time
  snapshot per project (shallow `git clone` into a project-local folder, `.git` stripped, a
  `SNAPSHOT.json` recording the commit SHA and fetch time), used locally for the rest of the
  project with no further network access, and refreshed only on explicit request (report old vs.
  new commit SHA when it happens). Documents the actual consumption protocol — read `skills/entry.md`
  with an explicit task-context, get back a dispatch record, invoke the named action skill(s),
  read the `read.md`/`do.md` meta-skill contracts on demand, integrate structured findings
  (outcome, per-finding domain/references/confidence, a suppressed list) the same way as any
  other review finding, never applied blind. Wired into Step 05 (bootstrap at scaffold time) and
  Step 10 (an independent review pass alongside the Standards Anti-Patterns check).
- **Why the verification pass mattered:** both sections were checked against the actual installed
  tooling and the upstream repo's own current documentation before being written in, rather than
  transcribed from the brief that proposed them. That check found real drift from the brief: no
  `al_debug` tool exists (several others do that the brief never named); BCQuality's
  agent-consumption reference lives at `docs/agent-consumption.md`, not the repo root; and its
  `custom/` layer exists upstream (with a template `README.md`) rather than only in forks — it's
  simply empty of actual knowledge content. Both sections tell a future reader to re-verify
  against the live source rather than trust a paraphrase, including this one — the upstream repo
  is explicitly under active development.

### Full self-consistency review (2026-09-12)

A dedicated reasoning-role pass (§1.7) read the entire runbook end to end looking for places
where it contradicted itself — separate from, and in addition to, the compile-cadence and
model-role fixes recorded above. Beyond those two (the highest-impact findings), it also found
and fixed:

- **Permission sets: an optional parameter enforced unconditionally.** Parameter 1.2 let a human
  answer `Permission Sets required? No`, but Steps 05/06/10 checked `tabledata` coverage
  unconditionally, and Step 03's own text says `PTE0004` requires it for every table anyway.
  **Resolved (AJ Ansari):** `No` is now stated as valid *only* when the extension introduces zero
  new tables of its own (e.g., a pure page/report extension on standard objects) — the one case
  PTE0004 genuinely doesn't reach. The later unconditional checks are correct as written: they're
  vacuously satisfied when there are no tables, so no wording change was needed there beyond
  noting it explicitly.
- **Cross-reference integrity.** The header's companion-doc scope said "Parts 2–11" while Steps 09
  and 12 cite Part 12 seven times — widened to "Parts 2–12". Rule 6b cited "Rule 6" for
  installing-tooling approval, but Rule 6's own list was a closed enumeration that didn't include
  it — added a fifth item to Rule 6 rather than leave a pointer to something not actually there.
  Two unrelated citations ("AZ AL Dev Tools rules" and "commit each batch separately") both named
  "Appendix C" — flagged as unverified rather than guessed at, since the companion Standards doc
  isn't in this repo to check.
- **Harness/OS residue.** §1.7 states a no-vendor-names policy that Rules 6a/6b then broke without
  marking the product names as adaptable examples — both now explicitly say "substitute whatever
  your own harness/OS provides." Rule 6b's tooling-discovery path was macOS-only despite the AL
  MCP Server section (written later in the same session) already handling Windows/macOS/Linux
  separately — 6b now lists all three. Step 12's `npx @mermaid-js/mermaid-cli` instruction now
  notes it may install on first run and that Rule 6b applies to it.
- **Document inventory.** The ALL ALONG "keep every document current" list named `Documentation`
  but omitted three of Step 12's four mandatory outputs — `UserGuide`, `HumanUnitTestScript`, and
  `Deployment` — added. Also clarified the previously-unstated boundary between `Documentation.md`
  (a developer's quick-start) and `Deployment.md` (an administrator's full install/upgrade/
  uninstall procedure), the same way the runbook already distinguishes `UserGuide` from
  `Documentation`.
- **BCQuality kickoff timing.** Its own section said "fetch at project kickoff"; Step 05 (five
  steps later, in BUILD) said to bootstrap it there. Aligned both on Step 05, since that's where
  the rest of the one-time project scaffold already lives and where this project actually did it.

**Verification pass, same day.** A second, independent reasoning-role instance re-read the whole
document fresh to confirm the fixes above actually held together — not just that each fix existed,
but that the fix pass hadn't introduced anything new. It found two more real issues, both fixed:

- **Self-contradiction in the Step 05 permission-set check.** The parenthetical said a missing
  `tabledata` grant "fails at publish, not at compile, so pre-flight is the only thing that
  catches it **before the mandatory Step 07 compile does**" — which asserts in the same breath
  that the compile both doesn't and does catch it. `PTE0004` is a publish-time check; no compile
  ever catches it. Reworded to say plainly that nothing automated catches it besides pre-flight.
- **"Including gap-fill work" made the mandatory compile's trigger undefined.** Rule 4 said the
  one compile happens once every batch "including gap-fill work" is written — but gap-fill items
  are a **Step 08** (PROVE) output, which runs *after* Step 07's compile. Taken literally, the
  compile would either wait forever for work that can't exist yet at that point, or gap-fill code
  would never get compiled at all. Fixed by scoping the mandatory Step 07 compile to the
  TDD's originally-planned batches only, and stating explicitly that gap-fill — whether ad hoc
  mid-project (as actually happened on the pilot project) or a formal Step 08 output — gets its
  own pre-flight-then-compile pass through the same Step 05/06/07 discipline, when it's actually
  written. Also smoothed two smaller items the same pass flagged: Step 07's Inputs no longer
  overclaim "none yet compiled" (an earlier human-requested spot-check may have already run), and
  its action numbering ("0." followed by "1/2/3") was reworded as plain "first… then…" prose to
  remove the false impression that the compile was a peer of the three troubleshooting questions
  rather than what precedes them.

### Repository hygiene — what never syncs to a project's remote (2026-09-12)

- **Added — a new ALL ALONG section, "Repository Hygiene."** Consolidates, in one place, what
  stays out of a project's own git remote (GitHub, Azure DevOps, or otherwise) even though it
  lives in the working directory like any other file:
  - **Always gitignored, no per-project choice:** `.bcquality/` (a refetchable third-party review
    aid with no reproducibility requirement, unlike `.alpackages/`) and any local tooling helper
    script this framework's bootstrap creates for its own convenience (e.g., an AL MCP Server
    launcher wrapper, typically under `scripts/`) — this framework's own plumbing, not the
    client's deliverable.
  - **Gitignored by default, human can opt out:** this runbook itself, its changelog, and its
    schematics if generated. New **Step 01 §1.8** asks this explicitly at intake, with the
    `.gitignore` mechanism explained in plain terms for a human who may not already know it —
    recommended default keeps the framework's own methodology out of every client/shared repo it
    is ever pointed at, since it's distributed from its own dedicated repository and isn't itself
    part of what a client is paying to receive.
- **Superseded — BCQuality's "track it like `.alpackages/`" guidance.** Reversed: `.bcquality/` is
  now unconditionally gitignored, not a project-convention call.
- **Added — a documented consequence, not papered over.** If the MCP host config that references
  a gitignored local wrapper script (e.g., `.vscode/mcp.json`) *is* itself committed, a fresh
  clone gets a config pointing at a script that doesn't exist yet. Rather than silently accept
  that footgun, the AL MCP Server section now says to note this in the project's own setup
  instructions and to re-run the bootstrap to regenerate the script, instead of assuming it's
  already there.
- **Retroactive handling.** For a project where these paths were already tracked before this
  policy existed — as the pilot project's own were — adding the `.gitignore` entries alone does
  nothing; the files must also be untracked (`git rm --cached`, which leaves them on disk). Check
  for a configured remote first: untracking after a push rewrites what collaborators see as
  "deleted" files even though nothing was deleted locally, so that has to be named plainly before
  proceeding, not assumed safe.
- **Fixed — "remote" used bare, without an example, in several places.** A person being asked the
  §1.8 question may not know what "a remote" means at all. Every mention across §1.8 and the
  Repository Hygiene section now names concrete examples (GitHub, Azure DevOps) rather than
  assuming the term is self-explanatory, except one same-sentence reference back to a mention
  already clarified moments earlier, left alone since repeating the example there would be noise.
- **Corrected — the BCQuality snapshot must live outside the AL project's own root folder,
  not just outside git tracking.** Discovered when a routine compile on the pilot project
  suddenly produced 470+ syntax errors, none in the project's own code: `alc` recursively compiles
  every `.al` file under the project root with no built-in exclusion mechanism, and BCQuality
  ships illustrative `.good.al`/`.bad.al` knowledge snippets that are deliberately incomplete
  fragments, not real compilable objects. Gitignoring the snapshot (the fix two entries above)
  only ever addressed git tracking — it does nothing about the compiler, which doesn't consult
  `.gitignore` at all. Fixed by moving the snapshot physically outside the project root (e.g. a
  sibling directory) rather than merely excluding it from version control; this also matches
  BCQuality's own documented integration pattern, which already keeps its checkout and the
  reviewed app in two separate directories, never one nested inside the other. Updated the
  BCQuality Knowledge Snapshot section, the Repository Hygiene section, and §1.8's cross-reference
  to reflect that the snapshot isn't a git-tracking question for this path at all anymore.

---

## v1.0.0.0 — baseline

The version the framework was at when the pilot project (Bootcamp Registration Tracking) began.
Assigned this number retroactively — the framework wasn't itself versioned before v2.0.0.0 — as
the starting point every change above is measured against. No changelog entries exist prior to
this point.
