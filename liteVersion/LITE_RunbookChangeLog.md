# Lite Edition — Changelog

Tracks changes to the **Lite Edition** of the Agentic Development Framework
(`LITE_BC_App_Build_Routine_Agent.md`) — independent of any single project built with it. This is
a separate changelog from the full framework's own `RunbookChangelog.md` (one directory up), even
though a change to one often has to be reflected in the other — Lite is a derived edition, not a
fork, and the two are expected to stay in sync on anything that isn't specifically a
process-reduction. The Lite Edition is versioned independently of the full framework; check the
header of `LITE_BC_App_Build_Routine_Agent.md` for which full-framework version it's currently
derived from.

Entries are grouped by version, newest first, and describe the **cumulative** result of a
version's changes — not the drafting history behind them; only the final, current form of a
change is recorded, matching the convention `RunbookChangelog.md` uses for the full framework.

---

## v1.2.0.0 — September 13, 2026

**Lite gets its own `ProjectParameters.md` — closing the same storage gap the full framework had,
in Lite's own equivalent place.**

Derived from full framework v2.5.0.0.

### Fixed — the Project Parameters block had no named file to live in

The full framework's own review (this same day) found that its Project Parameters block was
referenced constantly as an Input or Output, and called the project's single source of truth —
but no step ever named a file for it. Lite had the identical gap: Step 1's own actions, and Step
2's and Step 3's Inputs lines, all referenced "Project Parameters" as a concept with nowhere named
to actually find it.

- **`ProjectParameters.md`**, in the **project root** — not `docs/`, since Lite never uses a
  `docs/` folder anywhere; every Lite artifact lives flat at the root, matching where
  `ProblemStatement.md` already lived.
- **Step 1's own action bullet, Outputs, and Exit gate** all updated to name the file explicitly —
  the intake sheet is now persisted, not just discussed, the moment it's filled in.
- **Steps 2 and 3's Inputs lines** now cite `ProjectParameters.md` by name instead of the bare
  phrase "Project Parameters."
- **`LITE_Outline_OCPFBCAgenticDevFW.md`'s Document Set** section now lists `ProblemStatement.md`
  and `ProjectParameters.md` as the two Step 1 setup artifacts, distinct from the four documents
  tracked throughout the routine (`DesignDoc.md`, `ChangeLog.md`, `Docs.md`, `TestScript.md`) —
  that "four tracked files" framing was never meant as a literal count of every file Lite produces
  (it already excluded `ProblemStatement.md`), so it stays as-is; the new line just makes what it
  does and doesn't cover explicit.

---

## v1.1.0.0 — September 13, 2026

**Wired up to the OCPF AL Development Standards Guide, and three defects found in an independent
review fixed.**

Derived from full framework v2.4.0.0.

### Added — the Standards Guide, fetched and cited throughout

Lite previously carried **zero** references to any companion rules document — every AL rule it
needed was either restated in short form or simply assumed correct. Fixed on the governing
principle stated in the runbook's own header: **Lite reduces process, not AL rules.** The same
rules that apply to a 50-file extension apply to a 5-file one.

- **Step 1 gained a first action**: fetch `standardsGuide/ocpfALDevStandardsGuide.md` from the
  framework repository into `standardsGuide/`, and add it to `.gitignore` — ahead of Step 3, where
  the other fetched libraries wait, because Step 1's own gap check already leans on Standards
  Part 6.
- **New ALL ALONG section** — OCPF AL Development Standards Guide — with the same
  fetch/refresh/version-skew policy as the full framework's equivalent section, and the same
  stricter-than-patterns failure mode: an unreachable guide means stop and ask, not proceed from
  memory.
- **Citations added throughout** — Step 1 (naming, abbreviations), Step 2 (mutability, field
  exclusion, `const()` quoting, naming, permission sets, growth-buffer IDs), Steps 3–4 (page
  template, mandatory properties, indentation, symbol verification), Step 5 (endpoint patterns),
  and Step 6 (dead code, obsolescence, and — the highest-value one — the full Anti-Patterns table,
  Standards Part 7, called out explicitly as worth the couple of minutes it takes to read).
- The Parameters block now states it is authoritative and that the guide defers to it, matching
  the full framework's own Step 01.

### Fixed — three defects found in an independent review, present since the v1.0.0.0 baseline

- **The hand-off moment was misplaced.** It sat at the *end* of Step 7, after the exit gate — by
  which point the package had already shipped to Production, so "what's left is a human running
  tests" was describing something already finished. Moved to the **top of Step 7**, before its
  actions, matching the full framework's Step 11 → 12 placement.
- **The hand-off collided with Rule 6c.** It was plain prose, while Rule 6c separately required a
  selectable-options check-in at the same Step 6 → Step 7 boundary, with no stated precedence
  between the two. Now runs through the Rule 6a interactive mechanism with the same two named
  options as the full framework (*"Perfect, I understand!"* / *"I have some questions"*), and both
  sides state explicitly that the hand-off **replaces** the generic check-in rather than adding to
  it.
- **The Step Map's document count was wrong** — it said "~15" while listing 18 documents in the
  same sentence. Corrected to the full framework's actual canonical count at the time.

Also tightened: Step 6's code review hedged with "if a live BCQuality snapshot exists," even
though Step 3 bootstraps it unconditionally — it now invokes the snapshot directly and requires
the agent to say so if it's genuinely missing, rather than silently skipping the pass.

### Changed — dates written in long form

Every date in the Lite runbook converted from `YYYY-MM-DD` to long form (e.g. `September 13,
2026`). No date value changed — only its formatting.

---

## v1.0.0.0 — baseline

Initial release of the Lite Edition, derived from the full framework v2.3.0.0: a 7-step
condensation of the full framework's 14 (DEFINE → DESIGN → BUILD → PROVE, one merged document set
instead of eighteen — `DesignDoc.md`, `ChangeLog.md`, `Docs.md`, `TestScript.md` — and no
Main/Light/Reasoning role split, one model doing everything), for Business Central AL PTEs of 10
files or fewer.

---

*Lite Edition created by AJ Ansari, Microsoft MVP, OnlyCopilotFans, derived from the OCPF BC
Agentic Development Framework. Update this changelog whenever `LITE_BC_App_Build_Routine_Agent.md`
changes, whether that change originated in Lite itself or flowed down from the full framework.*
