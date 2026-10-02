# BC App Build Routine — STEP 7 — Release for Testing

**Runbook version:** 5.1.0.0 · Lite edition · Phase: PROVE

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


> **The hand-off moment — mark it, don't slide into it.** The instant Step 6's outputs are done
> and this step is about to begin, the agent's own work in this routine is effectively finished:
> everything from here is a human running tests and deciding whether to ship. Send a formal
> message for this specific transition — this **replaces**, it does not add to, the ordinary Rule
> 6c step-completion check-in at the Step 6 → Step 7 boundary — through the interactive mechanism
> (Rule 6a), with exactly two named options plus the mechanism's own free-text/Other entry:
> **"Perfect, I understand!"** and **"I have some questions."** The message itself must: (a)
> congratulate the human on reaching this point; (b) state plainly that this is the logical end of
> the Lite framework's own work — Step 7 runs by human hands from here; (c) say concretely what
> they need to do next (run `docs/4-prove/TestScript.md` end to end, record every finding in `docs/0-project/ChangeLog.md`);
> and (d) say how to bring the agent back in — when testing surfaces something to fix, when the
> functional pass is green and translated documents are due (if Step 1 asked for any), or once
> everything passes and it's time to ship the release candidate.
>
> **Then, once the human has answered, send one more ordinary message — not a decision box — as
> the last thing this session says:** a reminder that `ProjectProgress.md` still shows Step 7 as
> `In Progress`, and that when the release test is done and the package has shipped, the row must
> be set to `Completed`, the ChangeLog given a closing entry naming the shipped package, the usage
> table its final refresh — one row per model — and the calibration file exported to
> `~/.ocpf/calibration/` (Operating Rule 9; ALL ALONG → Usage & Cost Tracking), so that the next
> developer or AI tool that opens this project reads the true state rather than a step that looks
> unfinished. Say the agent will do it if brought back in for the release, and how to do it by
> hand if not (edit the row; ask the `usage` skill or the Ops § Usage & Cost procedure for the
> table). Ordinary conversation, not a decision — not wrapped in the options mechanism, and not
> folded into the hand-off box above, whose two options must stay the only thing that message asks.
>
> Everything below this note is what happens *after* that hand-off — the human's test run, and
> the agent's part in recording and fixing what it turns up.

**Inputs:** The most recently built package; `docs/4-prove/TestScript.md`; `docs/4-prove/Docs.md`.

**Actions:**
- Confirm the latest package — the release candidate `1.0.0.0` from Step 6, or the latest `0.x`
  build if the human chose to keep testing — is published to a BC sandbox tenant; republish if
  anything changed.
- **If this isn't the first release, test the upgrade path first** (**Standards §9.6**): install the
  previous version on a clean sandbox with data in the fields this version changes, publish and
  install this one, verify the migrated data, install it again to confirm the upgrade tag makes the
  second run a no-op, and check that a fresh install doesn't run upgrade code at all. A failed
  upgrade path fails this step — by the time anyone notices, the tenant's data is already wrong.
- Real users/testers — not the agent, not a simulated pass — run `docs/4-prove/TestScript.md` end to end: every
  green-team and red-team case, by hand.
- Verify permission sets as part of the same pass: read-only grants read everywhere; read/write
  includes it plus write on editable pages.
- **Translated documents, once the functional pass is green** (if Step 1 asked for them): the
  agent produces `docs/4-prove/Docs.<culture>.md` (user-guide section) and, if chosen, `docs/4-prove/TestScript.<culture>.md`.
  It uses the glossary for every BC term and names the English source version in each file's
  header. Each is reviewed by that language's reviewer before the language pass that uses it.
- **Language passes:** for each language required at first release, a tester fluent in it runs
  the language pass, with the right Microsoft or partner language app installed in the sandbox.
- **Translation approval — the release gate** (Ops § Translations; skip if *US wording, no translation files*):
  - Each language's named reviewer approves its translations — directly in their tooling, or by
    telling the agent exactly which units they approve. The agent sets `signed-off` only on those
    units.
  - Log each approval in `docs/0-project/ChangeLog.md`: reviewer by name, language, count, and date.
  - Then **scan every target file** for a language required at first release: every unit must be
    `signed-off` or `final` (**Standards §8.7**).
  - A fix that changes source text sends affected units back through Step 5 and review.
- Record every finding directly in `docs/0-project/ChangeLog.md` — verbatim first, then triaged: **implement now**
  (its own entry, fixed via the Step 5 cycle — each rebuild increments the Revision, `1.0.0.1`,
  `1.0.0.2` …, with the fixed *Package built* message; never a rebuild at a version already
  uploaded), **defer** (its own entry, marked deferred, with
  reasoning — Lite doesn't keep a separate `Roadmap.md`), or **reject** (record why).
- **If a fix here changes any object, field, or behavior, treat Step 6's outputs as stale, not
  already covered** — re-run the affected parts of the review and regenerate `docs/4-prove/Docs.md`'s reference
  and diagram from the now-changed code, plus any translated document already produced from what
  changed. Say explicitly which parts a given fix actually requires re-running.
- Repeat until every green-team test passes and every red-team test fails gracefully.

**Outputs:** `docs/0-project/ChangeLog.md` updated with every test finding and its resolution.

**Exit gate:** All green-team tests pass; all red-team tests fail gracefully; the upgrade path
passes, or this is the first release (**Standards §9.6**); permission sets
verified; every translated document Step 1 asked for exists and has been reviewed; every required
language has passed its language pass and its state scan shows every unit `signed-off` or `final`
(Ops § Translations).
**If everything passes, the package that was actually tested ships as it is** — the release
candidate, or the last `1.0.0.x` fix build that passed — to Production, by the human through
Extension Management, never the agent (Ops § Packaging). No rename, no copy, no rebuild: every
build already has its own version and file, so the shipped artifact is permanently identifiable.
**Before that deploy, restate the Schema Sync Mode assessment for this exact package** in the
fixed *Package built* message block (ALL ALONG → Packaging & Versioning) — **Add** if this release
is additive-only, **Force Sync** with an explicit data-loss warning if anything was removed,
shrunk, retyped, or re-keyed since the last package installed in that tenant. Then set the Step 7
row of `ProjectProgress.md` to `Completed`, refresh the usage table, and export the calibration
file (the hand-off note above).

**Step close (Rule 6c) — mandatory, never a prose prompt:** when the human reports the test outcome, end the closing message with the options box: **Close the project — released (recommended)** / **Something needs fixing** (names what, and re-enters the Step 5 cycle). The routine does not end on an open prompt.
