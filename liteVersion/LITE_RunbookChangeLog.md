# Lite Edition — Changelog

Tracks changes to the **Lite Edition** of the Agentic Development Framework
(`LITE_BC_App_Build_Routine_Agent.md`) — independent of any single project built with it. This is
a separate changelog from the full framework's own `fullVersion/RunbookChangelog.md` (a sibling
folder), even though a change to one often has to be reflected in the other — Lite is a derived
edition, not a fork, and the two are expected to stay in sync on anything that isn't specifically a
process-reduction. The Lite Edition is versioned independently of the full framework; check the
header of `LITE_BC_App_Build_Routine_Agent.md` for which full-framework version it's currently
derived from.

Entries are grouped by version, newest first, and describe the **cumulative** result of a
version's changes — not the drafting history behind them; only the final, current form of a
change is recorded, matching the convention `fullVersion/RunbookChangelog.md` uses for the full
framework.

---

## v1.8.0.0 — September 15, 2026

**The mandatory compile now runs with Microsoft's own code analyzers engaged, and a round of
narrative cleanup shrinks what's loaded every session.** Derived from full framework v2.11.0.0;
applies Standards Guide v1.4.0.0's corrected §1.7 and §5.3. See `fullVersion/RunbookChangelog.md`
v2.11.0.0 for what was verified and the full reasoning.

### Changed

- **Step 3, 4, and Permission Sets:** corrected — the mandatory Step 5 compile catches a missing
  permission-set grant via `PTE0004` when the analyzer runs, not only at publish. The pre-flight
  checks stay: they catch a gap before compile, cheaper than waiting for it.
- **Step 3 and Step 6:** corrected — `AL0424` already proves the codebase is free of ML syntax,
  since `TranslationFile` is always on. The manual search stays as a backstop for anything added
  since the last compile.
- **Step 5:** the mandatory compile now explicitly runs with CodeCop, PerTenantExtensionCop, and
  UICop.
- **Step 6:** the `Rec.`-qualification and permission-set-coverage re-checks replaced with one
  check — the last compile was 0/0, with the required analyzers, and nothing suppressed.
- **Operating Rules and ALL ALONG:** dated attributions and incident narrative moved to this
  changelog; the rules themselves are unchanged.

### Added

- **ALL ALONG → Analyzers:** what the analyzers catch, how to run them, and why the AL MCP
  Server's own tools don't reliably apply them (verified — see the full changelog).

### Not changed

- **An analysis compile after every object** is not adopted here — see the full changelog's
  "Not changed" for the reasoning.

---

## v1.7.0.0 — September 15, 2026

**Permission set names now include something unique to the extension.** Derived from full
framework v2.10.0.0; applies Standards Guide v1.3.0.0's new §5.4. See
`fullVersion/RunbookChangelog.md` v2.10.0.0 for what went wrong and the facts verified.

### Changed

- **Step 1 parameters:** **Permission Set Prefix** is replaced by **Permission Set App Code**
  (asked) and **Permission Set Names** (derived): `<PREFIX> <APPCODE>, VIEW` and
  `<PREFIX> <APPCODE>, EDIT`, each 20 characters or fewer.
- **Step 1 intake:** question 6 asks for the App Code, and 6a asks whether other extensions already
  use this prefix.
- **Steps 2, 3, 6 and ALL ALONG → Permission Sets:** names are planned, pre-flighted, and reviewed
  against §5.4. With namespaces, the compiler doesn't catch a name another extension also uses.
- **Step 6 `Docs.md` deployment section:** lists users to reassign when a release renames a
  permission set.

---

## v1.6.0.0 — September 15, 2026

**The human answers questions and approves prompts; the agent does the setup.** Derived from full
framework v2.9.0.0; Standards Guide v1.2.0.0 unchanged. Four fixes from a real Lite 1.5.0.0
project. See `fullVersion/RunbookChangelog.md` v2.9.0.0 for what went wrong and the facts verified.

### Changed

- **Rule 6a:** every intake question counts as a decision, including values only the human knows
  (names, publisher, prefix, namespace, localization, ID ranges, versions). Ask them through the
  options mechanism, never open-ended in chat.
- **Rule 6d:** never hand the human a setup task the agent can do. No Command Palette for AL MCP
  setup (the AL extension has no such command), and no third-party bridge extensions.
- **Rule 2:** the agent downloads symbols; the human never does.
- **Step 1:**
  - A table of what to offer for each identity question.
  - Interactive Deployment Target, ID range loop, and BC version; `runtime` read from Microsoft
    Learn.
  - Once the sheet is confirmed, the agent writes `app.json` once, complete, connects the AL
    tools, downloads symbols, and checks the editor, all before Step 2.
- **Step 3:** confirms `app.json`, the AL tools, and symbols instead of setting them up.
- **Step 5:** after every clean compile, check the editor for stale red marks.
- **ALL ALONG → AL MCP Server:** no longer optional. It covers:
  - the human only approving,
  - fetching the launcher and the one-shot helper from the framework repository,
  - registering with a relative path,
  - working in the same session through the helper, with no restart.

### Added

- **ALL ALONG → Symbols:**
  - The order to try: VS Code's tool, the AL MCP Server, then the sandbox.
  - The MCP server's global download is W1 only.
  - Confirm symbols by using them.
- **ALL ALONG → Keeping the Editor in Sync:**
  - Why compiled code can still show red.
  - Prevention and automatic detection.
  - The fix: automatic in Copilot Chat; otherwise one short message asking for **Developer: Reload
    Window**.

---

## v1.5.0.0 — September 14, 2026

**Works with the OCPF agent plugin.** Derived from full framework v2.8.0.0; Standards Guide
v1.2.0.0 unchanged. See `fullVersion/RunbookChangelog.md` v2.8.0.0 for the verified facts and
reasoning. The manual setup is unchanged, and every change below applies only when the plugin set
the project up (`.ocpf/framework.json` exists).

### Added

- **Setup:** mentions the plugin as an optional alternative to the manual copy.
- **ALL ALONG → OCPF Plugin:**
  - the marker file,
  - a once-per-session framework update check against GitHub, replacing the project's copy only on
    an explicit "Update now" (backed up, logged in `ChangeLog.md`).
- **Standards Guide fallback:** the plugin's bundled copy is used when GitHub is unreachable at
  Step 1, recorded and named to the human.
- **Operating Rule 6d — zero-install first.** Use what the editor already provides, then what's
  installed, and only then an install. Never ask the human to edit `PATH` or shell profiles. Added
  after agents tripped on this twice; see `fullVersion/RunbookChangelog.md` v2.8.0.0.
- **AL MCP Server:**
  - **Copilot Chat in VS Code:** uses the AL extension's built-in tools, with nothing to bootstrap.
  - **Other MCP hosts:** bootstrap with the extension's bundled `altool` and VS Code's runtime; no
    duplicate registrations.
  - **With the plugin:** its `al-mcp-setup` skill does it in one step.
- **Step 1 framework-files question and Repository Hygiene:** include `.ocpf/`.

### Not added

- **The plugin's sub-agents.** They serve the full framework's role split. Lite still runs on one
  model.

---

## v1.4.0.0 — September 14, 2026

**Multilanguage support.** Derived from full framework v2.7.0.0; applies Standards Guide v1.2.0.0's
new Part 8 and Appendix D. See `fullVersion/RunbookChangelog.md` v2.7.0.0 for the verified facts
and full reasoning, and `translationAndMultiLanguage/MultilanguageSupportOverview.md` for a
user-facing explanation.

### Added

- **Operating Rule 8 — working language.** Step 1 asks it first. `DesignDoc.md`, `ChangeLog.md`,
  AL code, and commit messages stay English; raw requirements and tester feedback stay verbatim.
- **Step 1:**
  - the problem statement names countries, languages, and regional terms;
  - new Parameters rows — working language, target languages (country first, read live from
    Microsoft's availability page, classified into three support cases, each with a
    required-at-release answer and a named reviewer), source language (`en-US` recommended and
    default), source wording (W1, or US wording with no translation files when `en-US` is the sole
    target), document languages, customer-language documents, and translatable data;
  - the exit gate checks them.
- **Step 2:**
  - languages as a requirement;
  - translatable-text conventions;
  - a **translation glossary table inside `DesignDoc.md`**, filled by Standards Appendix D;
  - the **interactive API caption classification** (Business / Technical admin / Technical
    plumbing, Unsure resolved first, recommendations citing Microsoft);
  - two self-check rows.
- **Step 3:**
  - `TranslationFile`, `Translations/`, and `*.g.xlf` gitignored;
  - translation tooling agreed (XLIFF Sync recommended, NAB AL Tools alternative, ask before
    installing);
  - pre-flight checks for translatable text and API caption locking.
- **Step 4:** source text only.
- **Step 5:** the translation cycle — full build, sync, verify terms, draft to
  `needs-review-translation`, technical checks, test in each language. The exit gate adds no
  untranslated or needs-adaptation units in required languages.
- **Step 6:**
  - a translation review;
  - a language pass in `TestScript.md`;
  - translated `Docs.<culture>.md` and `TestScript.<culture>.md` where requested.
- **Step 7:**
  - language passes by fluent testers;
  - the **release gate** — the reviewer approves (logged by name in `ChangeLog.md`), then a state
    scan requires every unit in every required language to be `signed-off` or `final`.
- **ALL ALONG:**
  - a new Translations & Terminology section;
  - Repository Hygiene — `*.g.xlf` ignored, target files tracked, Microsoft's translation files
    never committed;
  - Reference Sources — the country/language availability page, Microsoft Terminology, and style
    guides.
- **Step Map:** the full framework's document count is updated to 20; Lite stays at four.
- **AppSource:** the US-only no-translation-files option isn't offered when Deployment Target is
  `AppSource` (Standards §8.10).

### Fixed — the `.gitignore` question named the wrong `ChangeLog.md`

Step 1's `.gitignore` question, ALL ALONG → Repository Hygiene, and the Standards Guide section all
said "this runbook and `ChangeLog.md`" are gitignored by default. That contradicted Lite's own Step
Map and outline, which list `ChangeLog.md` among the **four tracked documents**, and the full
framework's equivalent question, which covers only the framework's own files.

- They now name the framework files explicitly: this runbook, `LITE_RunbookChangeLog.md`, and
  `LITE_RunbookSchematics.md`.
- They state that the project's `ChangeLog.md` is **always tracked** — it now also records
  translation approvals.
- Projects on an earlier Lite version are told to remove any `ChangeLog.md` ignore entry and commit
  the file.
- `LITE_Outline_OCPFBCAgenticDevFW.md` and the ALL ALONG diagram in `LITE_RunbookSchematics.md`
  updated; all 7 Lite diagrams re-rendered clean.

---

## v1.3.0.0 — September 14, 2026

**Deprecated multilanguage (ML) syntax banned in generation and flagged in review; System App docs
and AL Guidelines added as reference sources; third-party resources credited under their
licenses.**

Derived from full framework v2.6.0.0; applies Standards Guide v1.1.0.0's new §1.7 and Part 7 row.
See `fullVersion/RunbookChangelog.md` v2.6.0.0 for the full reasoning.

### Added — Reference Sources

- **Operating Rule 2** fallback now names the BC System Application docs on Microsoft Learn
  alongside the Base App docs.
- **New ALL ALONG section — Reference Sources:** Base App docs, System App docs, *Working with
  translation files*, and AL Guidelines. Consulted online, not fetched. Precedence: symbol files
  beat Microsoft Learn, the Standards Guide beats AL Guidelines. AL Guidelines' legacy C/AL pages
  recommending `CaptionML` / `OptionCaptionML` are excluded by name.
- **Step 2** consults AL Guidelines for design patterns the Standards Guide doesn't cover;
  **Step 6** adds an AL Guidelines best-practice pass.
- **Snapshots keep `LICENSE`:** the BCQuality and Patterns Library fetches strip `.git` but keep
  the upstream `LICENSE` file, as MIT requires. Every resource is credited in the framework's new
  `THIRD_PARTY_NOTICES.md`.
- `LITE_Outline_OCPFBCAgenticDevFW.md` and the ALL ALONG diagram in `LITE_RunbookSchematics.md`
  updated; all 7 Lite diagrams re-rendered clean.

### Changed — ML anti-pattern

- **Step 3** — the post-generation pre-flight checklist now fails any `CaptionML`, `ToolTipML`,
  `OptionCaptionML`, other ML property, or `TextConst`.
- **Step 4** — generation instruction names single-language label syntax explicitly.
- **Step 6** — code review searches every AL file, including human-written or pasted code, for the
  deprecated constructs; every hit is a finding. Called out explicitly because AL0424 only fires
  when `TranslationFile` is enabled, so a clean compile doesn't prove the code is free of it.
- Standards Guide version references updated to v1.1.0.0.

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
