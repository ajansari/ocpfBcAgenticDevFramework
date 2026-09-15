# Agentic Development Framework — Changelog

Tracks changes to the **Agentic Development Framework** itself (the agent runbook that drives
DEFINE → DESIGN → BUILD → PROVE) — independent of any single project built with it. The framework
is distributed as a standalone repository; a project built from an earlier copy won't otherwise
know if or how the framework it's using has since changed. Check here for what changed and why.

Since v2.4.0.0 this also tracks the two documents that ship alongside the runbook:
`standardsGuide/ocpfALDevStandardsGuide.md` (the **OCPF AL Development Standards Guide**) and
`liteVersion/` (the **Lite Edition**). All three are versioned independently — as of runbook
**v2.11.0.0**, the guide is at **v1.4.0.0** and Lite is at **v1.8.0.0** — but
recorded together here, since a change to one usually has to be reflected in the others.

Entries are grouped by version, newest first, and describe the **cumulative** result of a
version's changes — not the drafting history behind them. If a change was revised multiple times
before the version that introduced it ever shipped, only the final, current form is recorded
here as one entry; incremental churn within a single unreleased version isn't itself
change-worthy. (This is a different convention from a project's own ChangeLog, which exists
specifically to keep a superseded decision on record — see the runbook's ALL ALONG guidance.)

---

## v2.11.0.0 — September 15, 2026

**The mandatory compile now runs with Microsoft's own code analyzers engaged, catching several
things this runbook previously only checked by hand — and a round of narrative cleanup, prompted
by an independent review, shrinks what has to be read every session.** Standards Guide **v1.4.0.0**
corrects §1.7 and §5.3. Ships with Lite **v1.8.0.0**. Plugin **v1.3.0**.

### Why

An independent review (`pluginDesign/ReviewReport.md`, gitignored) found the runbook had grown
large and repetitive, and flagged that this framework's own repeated claim — "nothing automated
catches a missing permission set; `PTE0004` only fires at publish" — didn't match what Microsoft
documents. Both are addressed here: the false claim is corrected, using a mechanism verified to
actually work, and the historical narrative that made the runbook larger than it needed to be is
removed.

### Facts verified before designing — not assumed

- **`PTE0004` is a PerTenantExtensionCop rule that fires at compile, not only at publish.**
  Reproduced directly: a table with no permission set, compiled with the analyzer DLL attached,
  fails with `error PTE0004: Table 60300 'OCPF No Perm Table' is missing a matching permission
  set.` The same compile also caught `PTE0008` (a page field missing `ApplicationArea`) and, with
  CodeCop attached, `AA0074` (a `Label` missing its suffix).
- **`AL0424` (deprecated multilanguage syntax) already fires with no analyzer at all**, as a base
  compiler warning, whenever `app.json`'s `features` includes `TranslationFile` — which every
  project built with this framework has (Standards §8.2). Reproduced: a `CaptionML` property
  produced `warning AL0424` on a plain compile. The runbook's own repeated claim that "a clean
  compile proves nothing here" was simply false for every project this framework builds.
- **The AL MCP Server's `al_build`/`al_compile` tools do not reliably apply analyzers**, despite
  documenting a `codeAnalyzers` argument and the server's own `--codeanalyzers` launch flag. Six
  attempts — the tool-call argument and the server flag, each with symbolic names (`${CodeCop}`)
  and literal DLL paths, comma- and semicolon-separated — all produced a clean result on code that
  should have failed `PTE0004` and `PTE0008` (AL Language extension 18.0.2732683, September 2026).
  Invoking the compiler directly (`altool compile -- /analyzer:<dll path>`, the same pattern the
  `al-mcp-call.sh` launcher already uses to reach `altool`) reliably engages every analyzer tested.
  Re-verify against a newer AL extension release before assuming either result still holds.
- **A permission set name collision across extensions is still not caught by the compiler**, even
  with PerTenantExtensionCop enabled — confirmed again under this rule's analyzer, closing the
  question raised when §5.4 shipped (v2.10.0.0): two apps declaring the identical bare permission
  set name, one depending on the other, compiled clean with `${PerTenantExtensionCop}` attached.
  §5.4's naming rule stands as the only defense.

### Changed

- **Operating Rule 4:** the trade-off/correction narrative folded into one short reasoning clause;
  the substance (don't compile per batch; one mandatory compile-and-package at Step 07) is
  unchanged.
- **Rule 6a, 6c, 6d:** dated attributions and incident-list narrative moved to this changelog; the
  rules themselves are unchanged. Rule 6d's four incidents are now a single sentence pointing here.
- **§1.7 Model & Effort Assignment:** the "superseded" framing removed; the decision stands as
  stated.
- **Step 05 post-generation checklist, Standards §5.3, and Lite's equivalents:** corrected — a
  missing permission-set grant is caught by the mandatory compile via `PTE0004` when the analyzer
  runs, not only at publish. The per-batch pre-flight check stays: it catches a gap before the next
  batch builds on it, cheaper than waiting for Step 07.
- **Step 05 checklist, Standards §1.7, Standards Part 7, `ocpf-code-reviewer`, and Lite's
  equivalents:** corrected — `AL0424` already proves the codebase is free of ML syntax, since
  `TranslationFile` is always on. The manual search stays as a backstop for anything added since
  the last compile.
- **Step 06:** Action 7's final cross-batch permission-set re-check removed — the per-batch check
  (Step 05, kept) and Step 07's mandatory compile (now analyzer-enabled) already cover it without
  a third pass. Step 06's Outputs and Exit gate updated to match.
- **Step 07 and Lite Step 5:** the mandatory compile now explicitly runs with CodeCop,
  PerTenantExtensionCop, and UICop (AppSourceCop added for an AppSource target).
- **Step 09, `ocpf-code-reviewer`, and Lite Step 6's equivalent:** the re-verification of
  `Rec.`-qualification, ML syntax, and permission-set coverage replaced with one check — the last
  compile was 0/0, with the required analyzers, and nothing suppressed. Obsolete-reference
  checking is unchanged: compiler behavior there wasn't independently verified this round.
- **Packaging & Versioning:** the git-tracking rule and the never-delete rule kept in full; the
  incidents that motivated them moved to this changelog.
- **`.bcquality/`'s stale `.gitignore` claim removed** (it lives outside the project; there was
  nothing to gitignore). `.alpackages/`'s tracked-for-reproducibility claim is unchanged and still
  sits alongside the never-commit-translation-files rule without being reconciled — flagged, not
  resolved, this round.

### Added

- **ALL ALONG → Analyzers** (both editions): what the analyzers catch, how to run them on each
  harness, and the verified reason the AL MCP Server's own tools don't work for this.
- **`agentPlugin/ocpf-bc/skills/al-mcp-setup/scripts/al-analyze.sh`** (macOS/Linux) and
  **`al-analyze.cmd` + `al-analyze-resolve.ps1`** (Windows, untested on Windows): locate the same
  AL extension the MCP launcher does, resolve the analyzer DLLs beside it, and run
  `altool compile --` directly. Exits with the compiler's own code.

### Not changed

- **Option B — an analysis compile after every batch** (revisiting the September 12, 2026
  trade-off in Operating Rule 4) is not adopted here. The review that prompted this round
  recommended running one real project first to see the warning volume before deciding; that
  hasn't happened yet.
- **`.alpackages/` tracked vs. gitignored** — a real, still-open contradiction the review
  identified. Left for a separate decision.

---

## v2.10.0.0 — September 15, 2026

**Permission set names now include something unique to the extension.** Standards Guide
**v1.3.0.0** adds §5.4. Ships with Lite **v1.7.0.0**. Plugin **v1.2.0**.

### What went wrong

- **Every extension named its sets from the prefix alone.** Standards §5.3 said to name them from
  the Permission Set Prefix (`<PREFIX> - READ`, `<PREFIX> - READ/WRITE`), so every extension built
  with prefix `ocpf` shipped the same names and collided with the others.
- **It was fixed by hand, again and again.** Each project was fixed after the error surfaced, each
  with a different improvised pattern (`OCPF NAICS - READ`, `OCPF - IP Track Read`,
  `OCPF - Bootcamp Read`). The runbook never changed, so every new extension hit the same problem.

### Facts verified before designing — not assumed

- **Identity:** in the tenant, a permission set is identified by its **Role ID**: the object name in
  uppercase, `Code[20]`, with no namespace. `Access Control`, `Aggregate Permission Set`, and
  `Tenant Permission Set` store it next to the App ID (BC 27 System symbols).
- **Length:**
  - An assignable permission set name is limited to **20 characters**; longer fails with `AL0305`
    ([Permission set object](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-permissionset-object)).
    Reproduced with a 21-character name.
  - The platform's permission set **Name** is `Text[30]`. A 38-character caption compiles.
- **The compiler hides the clash when namespaces are on.** Compiled with AL Language extension
  18.0, app B depending on app A:
  - both declaring `"OCPF - READ"` in different namespaces compiled cleanly;
  - with no namespaces, it failed with `AL0197`.

  Namespaces are the framework default, so the clash first shows up in the tenant.
- **Microsoft's precedent:** Business Central 28's Base Application names its 86 assignable sets
  `D365 <AREA>, VIEW` / `, EDIT` / `, SETUP`, all within 20 characters. Its affix guidance, for
  several apps from one publisher, adds an app-level affix after the company affix
  ([Prefix and suffix for naming in extensions](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-prefix-suffix)).
- **Renaming a shipped set loses its assignments.** `Access Control` keys each assignment by Role
  ID and App ID, so users assigned to a renamed set lose that access when the new version is
  installed. **Permission Set by User** (page 9816) lists who holds a set.

### Changed

- **Standards §5.3:** names come from §5.4. The deployment note uses the new names.
- **Standards §5.4 (new):** `<PREFIX> <APPCODE>, VIEW` and `<PREFIX> <APPCODE>, EDIT`, and:
  - the App Code is unique across every extension using the prefix, at most `13 − prefix length`
    characters;
  - names are 20 characters or fewer, captions 30 or fewer;
  - how to rename an installed extension's sets without silently dropping users.

  Standards Part 7 gains a matching anti-pattern.
- **Step 01 §1.3:** **Permission Set Prefix** is replaced by **Permission Set App Code** (asked)
  and **Permission Set Names** (derived). The intake table adds question 6 (the App Code) and 6a
  (other extensions already using this prefix).
- **Step 03, Step 04, Step 05 post-generation pre-flight, Step 09 code review:** each checks the
  names against §5.4, since the compiler won't.
- **Step 11 `Deployment.md`:** lists users to reassign when a release renames a permission set.

### Not changed

- **Existing extensions aren't renamed automatically.** Renaming drops existing user
  assignments. Move an older extension to §5.4 names in a planned release, following §5.4's
  rename steps.

---

## v2.9.0.0 — September 15, 2026

**The human answers questions and approves prompts; the agent does the setup.** Four fixes from
a real Lite 1.5.0.0 project (NAICS Classification, September 15, 2026). Two of them had also
shown up on full-framework projects.

Ships with Standards Guide **v1.2.0.0** (unchanged) and Lite **v1.6.0.0**. Plugin **v1.1.0**.

### What went wrong

1. **Intake wasn't interactive.** The extension name, publisher, and object ID ranges were asked
   as open-ended chat questions. Rule 6a covered "decisions", and the agent didn't count a typed
   value as one.
2. **The human downloaded symbols by hand.** VS Code's AL log shows three manual downloads
   (03:12, 03:25, 03:40). The agent then misread the packages as unusable and designed from
   Microsoft Learn, recording posting events that don't exist.
3. **The human was sent to the Command Palette** for an AL MCP command that doesn't exist. The
   agent did the setup itself only after being told. The project's `.mcp.json` also ended up with
   a third-party bridge extension's server and an absolute-path NuGet `al` entry with
   `DOTNET_ROOT`.
4. **Code compiled clean but VS Code still showed red "object ID" errors** until the window was
   reloaded. **AL: Go!** had created `app.json` with its default range (03:12), the AL extension
   loaded it, and the agent rewrote the range at 03:49.

### Facts verified before designing — not assumed

Checked against AL Language extension 18.0.2732683 on macOS, Microsoft Learn, and public issues:
- **Symbols need no sign-in.** The AL MCP Server's `al_downloadsymbols` with
  `globalSourcesOnly: true` downloaded System, Application, System Application, Business
  Foundation, and Base Application for BC 27 in under 10 seconds, with no Business Central
  connection ([Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/al-agent-tools/al-tool-download-symbols)).
  VS Code's `al_downloadsymbols` tool has the same option.
- **The MCP server's global download is W1 only.** It has no country option, and it ignored
  `al.symbolsCountryRegion` in `.vscode/settings.json`, with the project loaded at launch and at
  runtime ("Using symbols country/region: w1"). VS Code's own download supports that setting.
- **There's no AL MCP command in the Command Palette.** The AL extension's `contributes.commands`
  holds only sign-in and credential-reset commands for the separate Profiling and Snapshot MCP
  servers. The bridge server in the project's `.mcp.json` comes from *AL Language Model Tools —
  MCP Bridge*, a community VSIX that isn't on the Marketplace, needs VS Code relaunched with a
  proposed API enabled, and is set up from the Command Palette.
- **A server registered mid-session isn't usable until the next session** in Claude Code and
  Copilot CLI. A one-shot stdio call works without a restart: the new `al-mcp-call.sh` helper
  downloaded symbols (8.6 seconds), compiled (4.4 seconds), and exited without leaving processes
  behind. A plain shell pipe didn't: it hung after the response, because the server never closes
  its end.
- **Stale red marks have two verified causes.**
  - **`app.json` changed outside the editor.** The AL extension doesn't always re-read it. ID
    ranges updated by `git pull` stayed stale until VS Code restarted
    ([microsoft/vscode#147111](https://github.com/microsoft/vscode/issues/147111), attributed to
    the AL extension).
  - **Symbols downloaded by the MCP server.** The server reloads its own workspace ("Reloading
    workspace after symbol download"), while VS Code's AL language server is a separate process.
    VS Code's own `al_downloadsymbols` reloads VS Code's AL workspace (Microsoft Learn).
- **No agent tool can reload the VS Code window.**
  - The AL extension has no reload command. Its `vscode://` URI routes are Business Central's
    web-client flows, and they prompt the user.
  - Claude Code's VS Code integration offers `getDiagnostics` (the Problems panel), but no way
    to run editor commands.
  - Headless AL language server tests couldn't reproduce the marks: `altool launchlspserver`
    publishes no diagnostics.

  So the agent can **detect** stale marks everywhere it can read the editor, **fix** them itself
  in Copilot Chat, and otherwise has to ask the human for **Developer: Reload Window**.
- **Runtime follows from the BC version.** Microsoft Learn's *Choose runtime version in AL*
  table maps them (runtime `17.0` ↔ Business Central 28.0), so the human isn't asked for it.

### Changed

- **Operating Rule 6a:** every intake question counts as a decision, including values only the
  human knows. They go through the options mechanism, with the free-text entry carrying a typed
  answer.
- **Operating Rule 6d:** never hand the human a setup task the agent can do. The human's part is
  approval prompts and a browser sign-in for live environments. Never send the human to the
  Command Palette for AL MCP setup, and never route AL tooling through a third-party extension.
  The "why" list now records four incidents.
- **Step 01 intake:** a table of what to offer for each identity question; interactive
  Deployment Target, ID range loop, and BC version; `runtime` read from Microsoft Learn; §1.6,
  §1.8, and §1.9 asked the same way. A suggestion is a candidate the human picks, never an answer
  recorded on their behalf, and never built from an email domain.
- **Step 01 §1.10 (new): AL Project File, AL Tools & Symbols.** Once the sheet is confirmed, the
  agent writes `app.json` once, complete, connects the AL tools, downloads symbols, and checks the
  editor, all before Step 02. §1.4 **Symbol Source** is now filled in by the agent.
- **Step 05:** confirms `app.json`, the AL tools, and symbols instead of setting them up.
  BCQuality and the Patterns library stay here.
- **Step 07:** after every compile with 0 errors, check the editor for stale marks; never change
  code that compiles clean to clear them.
- **Operating Rule 2:** the agent downloads symbols; the human never does.
- **ALL ALONG → AL MCP Server:**
  - The human only approves; no Command Palette; no bridge extensions.
  - Without the plugin, fetch the launcher and helper from this repository.
  - Register with a relative path.
  - Keep working in the same session through the one-shot helper.
  - Verify with `al_getpackagedependencies`.

### Added

- **ALL ALONG → Symbols:**
  - The order to try: VS Code's own tool, the AL MCP Server, then the sandbox with one sign-in.
  - The W1-only limit of the MCP server's global download.
  - Confirm symbols by using them, never by unpacking `SymbolReference.json`.
- **ALL ALONG → Keeping the Editor in Sync:**
  - Causes and prevention.
  - Automatic detection through `al_getdiagnostics` or Claude Code's `getDiagnostics`.
  - The fix: automatic in Copilot Chat; otherwise one short end-of-reply message asking for
    **Developer: Reload Window**.

### Not changed

- **The manual setup, and the plugin-only behavior's condition** (`.ocpf/framework.json`). The
  new launcher and helper download works with or without the plugin.
- **BCQuality and the Patterns library** are still fetched at Step 05.

### Open

- **`al-mcp-call.ps1` (Windows) hasn't been run on Windows yet.** The macOS helper is tested end
  to end. Windows testing is already an open plugin item.

---

## v2.8.0.0 — September 14, 2026

**The framework is now also an agent plugin, and the runbook knows how to work with it.**
- The plugin is `ocpf-bc`, in `agentPlugin/`. This repository is its marketplace.
- It works in Claude Code, the Claude apps, GitHub Copilot (VS Code, CLI, github.com), and
  Microsoft Copilot Cowork.
- Its `start` skill guides the Full-or-Lite choice, installs the **latest** runbook from GitHub,
  and checks the AL MCP Server tooling.
- The manual setup — copy the runbook in as `CLAUDE.md` or `.github/copilot-instructions.md` — is
  unchanged. Every runbook change below applies only when the plugin set the project up.

Ships with Standards Guide **v1.2.0.0** (unchanged) and Lite **v1.5.0.0**. Plugin **v1.0.0**.

### Why

AJ Ansari wanted people who use Claude or Copilot to reach the framework more easily, without
taking the manual route away. He also wanted every new project to start on the current runbook,
not a stale copy.

### Facts verified before designing — not assumed

- **One plugin format reaches every surface.**
  - Claude Code, the Claude apps, VS Code's Copilot Chat, and Copilot CLI all read Claude-format
    plugins (`.claude-plugin/plugin.json`).
  - The Copilot cloud agent installs them from a repository's `.github/copilot/settings.json`.
  - Copilot Cowork converts them on upload, skills only.
- **Plugins can't run code at install time** on any of these platforms. So the plugin fetches the
  latest runbook when a project starts, not when the plugin installs.
- **The AL Language extension already provides the AL tools, with nothing to install.**
  - **GitHub Copilot Chat in VS Code:** it contributes `al_build`, `al_publish`,
    `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`, `al_getnextobjectid`,
    `al_symbolrelations`, and debugging tools directly.
  - **Other MCP hosts:** its bundled AL MCP Server (`altool launchmcpserver`) runs on the .NET
    runtime VS Code's .NET Install Tool already provisioned.
  - Tested on macOS through Claude Code: 16 tools, including `al_compile`, `al_build`,
    `al_symbolsearch`, `al_publish`, and `al_addproject`.
  - Projects are added at runtime with `al_addproject`.
- **Microsoft also publishes the same tools as a NuGet .NET tool**
  (`Microsoft.Dynamics.BusinessCentral.Development.Tools`, command `al`). It needs a .NET SDK, and
  `DOTNET_ROOT` when .NET isn't in its standard location. That's too much setup for a functional
  consultant, so the framework uses it only where there's no VS Code (cloud sessions).

### Added

- **ALL ALONG → OCPF Plugin.** Applies only when `.ocpf/framework.json` exists. It holds:
  - the marker file,
  - a **once-per-session framework update check** against GitHub,
  - pointers to everything else below.

  The update check tells the human about a newer runbook and replaces the project's copy only on
  an explicit "Update now". It backs up the old copy, updates the changelog and marker, and logs
  the change in `ChangeLog.md` and `docs/ProjectMemory.md`.
- **Standards Guide fallback.** If GitHub is unreachable at PRE-01, use the plugin's bundled copy
  instead of stopping. Record it in `SNAPSHOT.json` and name the version to the human.
- **Operating Rule 6d — zero-install first.** Before proposing any install or manual setup step,
  use what the editor already provides, then what's already installed, and only then an install
  (Rule 6b). Never ask the human to edit `PATH`, a shell profile, or environment variables.
  - **Why:** added after agents tripped on this a second time. First, an agent installed a .NET
    runtime the AL extension already had. Then, while the plugin was being built, the agent
    designed AL MCP support around installing the .NET SDK and a NuGet tool, plus a `PATH` edit —
    when the AL extension already provided everything.
- **AL MCP Server.** It opens with the zero-install route.
  - **Copilot Chat in VS Code:** use the AL extension's built-in tools; there's nothing to
    bootstrap.
  - **Other MCP hosts:** bootstrap with the extension's bundled `altool` and VS Code's
    already-provisioned runtime. Don't register a duplicate if the tools are already there.
  - **With the plugin:** its `al-mcp-setup` skill does it in one step, with a launcher that follows
    AL extension updates.
  - **NuGet `al` tool:** for cloud sessions and machines without VS Code only.
- **§1.7 sub-agents.** The plugin's `ocpf-reasoning` and `ocpf-light` sub-agents carry the
  Reasoning and Light roles. Delegate to them when role assignment is configured; the default
  (one model) is unchanged.
- **§1.8 and Repository Hygiene.** The `.ocpf/` folder follows the framework-files `.gitignore`
  answer.
- **Optional github.com reviewer.** `agentPlugin/github/agents/ocpf-code-reviewer.agent.md`,
  offered once at Step 09 when the project is on GitHub. It writes `CodeReview.md` and never edits
  AL; its file must be tracked for github.com to see it.

### Lite v1.5.0.0

The same changes, including Rule 6d, minus the sub-agents: Lite still runs on one model. See
`liteVersion/LITE_RunbookChangeLog.md`.

---

## v2.7.0.0 — September 14, 2026

**Multilanguage support, end to end.**
- Work with the agent in your own language.
- Countries and languages chosen from Microsoft's live availability data.
- Regional terminology verified against Microsoft's own BC translations.
- Agent-drafted translations with a named human reviewer and a release gate.
- Caption locking on API pages and queries decided interactively.
- UAT in every required language.

Ships with Standards Guide **v1.2.0.0** and Lite **v1.4.0.0**. A user-facing explanation is in
`translationAndMultiLanguage/MultilanguageSupportOverview.md`.

### Why

After the framework launched, several European MVPs said the same thing: multilanguage support is a
must-have, not a nice-to-have.
- UAT has to happen with translations in place.
- Captions must use `Caption` plus XLIFF, never `CaptionML`.
- AppSource requires translation files.
- Regional variants matter: Business Central in Australia says **GST**, not VAT, and uses its own
  credit memo term. The feedback called it "Credit Note"; Microsoft's Australian translation file
  says **"CR/Adj Note"** (below).

v2.6.0.0 shipped the `CaptionML` ban; this version ships everything else. AJ Ansari's decisions are
recorded below where they shaped the design.

### Facts verified before designing — not assumed

- **Microsoft's `en-US` source text is W1 English.** The US Base Application (v27.5) ships an
  `en-US` → `en-US` translation file in which **5,468 of 145,199 strings differ** from source
  (`Set up VAT` → `Set up Tax`, `County` → `State`). Regional wording lives in translation files,
  even for American English — so the framework does the same.
- **Business Central supports languages per country, in three cases.** Microsoft-translated,
  partner-translated, or not supported — from Microsoft Learn's *Country/Regional Availability and
  Supported Languages* page. **No right-to-left language is supported**; Microsoft lists Israel as
  "no RTL; English only".
- **Microsoft's API caption locking follows who reads the API.**
  - API v2.0 business pages and queries: 0 of 1,526 captions locked.
  - API v2.0 admin (`automation`) pages: 1 of 157.
  - Base Application internal runtime pages: 21 of 21 locked.
  - Counted from `microsoft/ALAppExtensions` and the v27.5 Base Application.
- **XLIFF Sync's state behavior, from its source code** (`rvanbekkum/ps-xliff-sync`): it writes only
  `needs-translation`, `needs-adaptation`, and `translated`, and writes `translated` itself when it
  imports or copies text. It leaves other states such as `needs-review-translation` untouched and
  doesn't report them as missing. So `translated` can't mean "approved", and a tool's checks can't
  serve as the release gate.
- **Where Microsoft's translations live**, from Microsoft's public Business Central artifact for
  Australia (sandbox 28.5.54151.54677), read via HTTP range requests rather than a full download:
  - it ships **one Microsoft language app per Microsoft-translated language** (e.g. `English
    language (Australia)`), each containing `Base Application.<culture>.xlf`;
  - "Base Application (AU)" itself contains `Base Application.en-AU.xlf`, the same size as the one
    in the language app.
- **Microsoft's regional English, measured:**
  - `en-AU` differs from source in 9,273 of 132,917 strings. `VAT` → `GST` in 3,071 strings, but 178
    keep `VAT`. `Credit Memo` → **`CR/Adj Note`** in 450 strings.
  - `en-GB` differs in 4,838 of 128,333 strings. `VAT` and `Credit Memo` are kept; the differences
    include British spelling (`Customize` → `Customise`).
  - Adaptation is per string, not search-and-replace.
- **AppSource:**
  - Microsoft's technical validation checklist: "The extension submitted must use translation
    files."
  - Its marketing validation guidance: the app "can be in any language" (with an English document
    if not English); the offer description must end with *Supported Countries/Regions* and
    *Supported Languages* paragraphs in English; Partner Center markets must match.
  - **No language is mandated per market** — except in the Validated Localization app program,
    which requires local-language translation.
- **CodeCop AA0074** label suffixes: `Msg`, `Tok`, `Err`, `Qst`, `Lbl`, `Txt`.

### Added — Standards Guide v1.2.0.0

- **New Part 8 — Translation & Multilanguage Rules:**
  - §8.1 source language (`en-US`, recommended and default) and W1 source wording, with the US-only
    exception;
  - §8.2 translation files — `TranslationFile` on every project, `Translations/<ExtensionName>.<culture>.xlf`,
    `en-US` gets its own file, `.g.xlf` never edited and gitignored, full builds only for language
    testing;
  - §8.3 labels, AA0074 suffixes, placeholder `Comment`s, `Locked`, `MaxLength`;
  - §8.4 `OptionCaption` member parity;
  - §8.5 terminology — Microsoft's translations are the authority, with the source order and the
    never-redistribute rule;
  - §8.6 API page and query caption locking — groups, recommendations, Microsoft precedents,
    `EntityCaption` / `EntitySetCaption`, tooltips always translatable;
  - §8.7 translation states — only `signed-off` / `final` count as approved, and the agent never
    approves its own drafts;
  - §8.8 language support by market, including right-to-left;
  - §8.9 customer-language documents, report layouts, translatable data, text expansion.
- **§8.10 AppSource** — translation files mandatory (so the US-only no-translation-files option
  isn't offered); no language mandated per market; *Supported Countries/Regions* and *Supported
  Languages* paragraphs in English, listing only languages that ship with every unit approved;
  test in every listed country.
- **§8.1** cites the measured US, Australian, and British differences.
- **New Appendix D — Terminology Verification Procedure**, the translation equivalent of Appendix B.
  It looks in a fixed order: the localized Base Application symbols, then the System Application
  and Business Foundation symbols, then Microsoft's language app for the language — fetched from
  Microsoft's public artifacts (located with BcContainerHelper's `Get-BCArtifactUrl`), one app only,
  after telling the human — then the partner app. If Microsoft's file can't be obtained, the agent
  stops and asks rather than proceeding from memory.
- **§1.3 template** gains `EntityCaption` / `EntitySetCaption`, plus a note on the locked variant.
- **Part 7 gains nine anti-pattern rows:** hard-coded message text; placeholders without
  `Comment`; `OptionCaption` member mismatch; editing `.g.xlf`; BC terms chosen from memory;
  shipping unapproved units; undecided API caption locking; testing translations with Incremental
  Build or RAD; regional wording in source.
- **Appendix C** gains XLIFF Sync (both), and NAB AL Tools as an alternative.
- **"What is deliberately not here"** gains three rows pointing at the runbook's intake,
  classification, and translation-cycle steps.

### Added — full runbook

- **Operating Rule 8 — work in the human's chosen working language.**
  - The runbook, AL code and names, commit messages, and engineering documents stay English.
  - Raw requirements and tester feedback stay verbatim in their original language.
- **PRE-01** asks the working language first, before anything else, and the problem statement names
  countries and languages. **PRE-02** gains a regional-terminology gap category.
- **Step 01 §1.9 — Languages & Translation**, interactive:
  - **Countries, then languages**, as a loop, read live from Microsoft's availability page. Each
    language is classified into the three cases; unsupported languages (right-to-left included) are
    not offered by default; mismatches with `Localization` are raised.
  - **Source language:** `en-US` offered first and recommended, and the default.
  - **Source wording:** W1. When `en-US` is the sole target, the developer may choose US wording
    with no translation files — **a choice added in implementation**: without it, every US-only
    project would carry an `en-US` translation file.
  - **Per language:** required at first release? Named reviewer?
  - **Documents:** which ones get translated.
  - **Beyond the interface:** customer-language documents and translatable data.
  - **`docs/TranslationGlossary.md`** is created at this step (canonical document list: 19 → 20).
- **Step 02** adds languages and markets as requirements. **Step 04** adds four sanity-check rows.
- **Step 03 — interactive API caption classification** (AJ Ansari's decision):
  - every API page and query is classified Business / Technical admin / Technical internal
    plumbing;
  - Unsure objects are resolved first, one at a time;
  - then one Business question and one Technical question, each recommendation citing Microsoft's
    precedent;
  - recorded per object, with the decider named.
- **Step 05:**
  - `TranslationFile` and `Translations/` in the scaffold, and `*.g.xlf` gitignored.
  - Translation tooling agreed: XLIFF Sync recommended, NAB AL Tools the alternative, nothing
    installed without asking.
  - New post-generation pre-flight checks for translatable text and API caption locking.
- **Step 06** generates source text only.
- **Step 07** gains the translation cycle:
  - full build → sync → terminology verification (light role) → draft to `needs-review-translation`
    (main role) → technical checks → test in each language;
  - optional pseudo-translation.
  - Exit gate: no `needs-translation` / `needs-adaptation` units in required languages.
- **Step 08** adds language gaps. **Step 09** adds a full translation review. **Step 10** updates the
  glossary as built.
- **Step 11:**
  - language passes in `HumanUnitTestScript.md`;
  - translated documents named `<Document>.<culture>.md`, each reviewed;
  - `Deployment.md` lists the language apps each language needs.
- **AppSource projects:** §1.9 doesn't offer the US-only no-translation-files option. Step 11
  drafts the English *Supported Countries/Regions* and *Supported Languages* paragraphs into
  `Deployment.md`. Step 12 tests in every listed country.
- **Step 12:**
  - language passes by fluent testers;
  - the **release gate** — the reviewer approves, then a state scan requires every unit in every
    required language to be `signed-off` or `final`, recorded in `ReleaseTestResults.md`.
- **New ALL ALONG section — Translations & Terminology:**
  - the glossary format;
  - roles (terminology is the light role's, drafting the main role's, approval never an AI role's);
  - two approval routes, both logged by name in the ChangeLog;
  - bulk approval with a named scope;
  - the tooling-independent state scan;
  - changed source invalidating approval;
  - languages that follow later;
  - licensing.
- **Repository Hygiene:** `*.g.xlf` gitignored, target files tracked, Microsoft's translation files
  never committed. **Reference Sources** gains the country/language availability page, Microsoft
  Terminology, and the Localization Style Guides.
- **Outline and schematics:** ALL ALONG entries and a Translations & Terminology diagram node; all 15
  diagrams (8 full, 7 Lite) re-rendered clean. The step structure is unchanged.

### Changed — Lite v1.4.0.0

The same design with Lite's lighter process:
- **Operating Rule 8** and the working-language question at Step 1.
- **Language rows in Step 1's Parameters table.**
- **Step 2:** the glossary and the API caption classification live inside `DesignDoc.md`.
- **Step 3:** scaffold, tooling, and pre-flight additions. **Step 4:** source text only.
- **Step 5:** the translation cycle. **Step 6:** the translation review and translated
  `Docs.<culture>.md` / `TestScript.<culture>.md`.
- **Step 7:** language passes and the same state-scan release gate, with approvals logged in
  `ChangeLog.md`.
- **Also:** a condensed ALL ALONG → Translations & Terminology section, and Repository Hygiene and
  Reference Sources additions.
- The document count is still four; the full framework's comparison count is updated to 20.
- **Fixed — Lite's `.gitignore` question contradicted Lite's own document set.** Step 1's question,
  Repository Hygiene, and the Standards Guide section all said "this runbook and `ChangeLog.md`"
  are gitignored by default. Yet the Step Map and the Lite outline list `ChangeLog.md` as one of
  Lite's **four tracked documents**, and the full framework's equivalent question (§1.8) covers
  only the framework's *own* files. The wording meant the framework's changelog. It now names the
  framework files explicitly (this runbook, `LITE_RunbookChangeLog.md`, `LITE_RunbookSchematics.md`)
  and states that the project's `ChangeLog.md` is always tracked. That matters more now, because
  translation approvals are logged there. Projects built on earlier Lite versions are told to
  remove any `ChangeLog.md` ignore entry.

### Also

- **README:** multilanguage support in the Background section, the overview in Contents, and the
  roadmap item marked complete.
- **`THIRD_PARTY_NOTICES.md`** gains:
  - XLIFF Sync — VS Code extension and PowerShell module (MIT, Rob van Bekkum);
  - NAB AL Tools (MIT, Johannes Wikman);
  - Microsoft API v2.0 source in `microsoft/ALAppExtensions` (MIT);
  - the Microsoft Learn globalization docs (CC BY 4.0);
  - four more Microsoft Learn Business Central pages;
  - Microsoft's BC translation files (proprietary — read, never redistributed).
- **Standards Part 8** carries CC BY 4.0 attribution for the Microsoft Learn facts it summarizes.

---

## v2.6.0.0 — September 14, 2026

**Deprecated multilanguage (ML) syntax is now a named anti-pattern; two new reference sources join
the framework (Microsoft Learn's BC System App docs and Microsoft's AL Guidelines); and every
third-party resource is now credited under its license.** Ships with Standards Guide **v1.1.0.0**
and Lite **v1.3.0.0**.

### Why — the ML anti-pattern

AJ Ansari, after feedback from several European MVPs on the launched framework: multilanguage
support is a must-have, not a nice-to-have, and `CaptionML` (marked for deprecation, AL0424)
should never be written by the agent or a subagent, and should be flagged when a human writes it.
The fuller multilanguage architecture (target languages, XLIFF generation, translated documents)
is being planned separately; this version closes the one rule that shouldn't wait for it.

Two facts, verified against Microsoft Learn rather than assumed, shaped how the rule is enforced:

- **ML properties and `TextConst` are not included in the generated `.xlf` file** (*Working with
  translation files*). The problem is not just "deprecated" — text written that way can't be
  translated by any XLIFF workflow, which AppSource requires.
- **AL0424 fires only when `app.json`'s `features` includes `TranslationFile`.** Without that
  flag, `CaptionML` compiles with no warning at all, so Operating Rule 5's zero-warnings gate can't
  be relied on to catch it. That's why it is enforced in pre-flight and in Code Review explicitly,
  not left to the compiler.

### Added — Standards Guide v1.1.0.0

- **New §1.7 — Translatable Text: Label Syntax Only, Never Multilanguage (ML) Properties.** Bans
  all eight ML properties (`CaptionML`, `ToolTipML`, `OptionCaptionML`, `InstructionalTextML`,
  `PromotedActionCategoriesML`, `RequestFilterHeadingML`, `AboutTitleML`, `AboutTextML`) and the
  `TextConst` data type — scoped wider than `CaptionML` alone, since all nine share the same
  deprecation and the same absence from the `.xlf` file. Includes a correct/wrong example, a
  replacement table, `Comment` / `Locked` / `MaxLength` guidance, and what to do when it's found in
  existing code (refactor to the single-language property; move other-language text into `.xlf`,
  don't discard it).
- **§1.4** — the `Caption` and `ToolTip` rows now say "never the ML variant (§1.7)."
- **Part 7** — new anti-pattern row covering the whole ML family and `TextConst`, explicitly
  "whoever wrote it."

### Changed — full runbook

- **Step 05** — the post-generation pre-flight checklist now fails any ML property or `TextConst`.
- **Step 06 Action 4** — generation instruction names single-language label syntax explicitly.
- **Step 09** — new Code Review bullet: search every AL file, **including human-written or pasted
  code**, for the nine deprecated constructs; every hit is a finding. Kept separate from the Part 7
  pass because a clean compile proves nothing here.
- Standards Guide version references updated to v1.1.0.0.

### Added — Reference Sources: BC System App docs and AL Guidelines (both editions)

AJ Ansari asked for two references to sit alongside the AL MCP Server, BCQuality, and the Patterns
Library, in both the full framework and Lite:

- **Microsoft Learn — BC System Application docs**
  (<https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application>).
  Added next to the existing Base App docs in Operating Rule 2's fallback and Standards Appendix B.
- **AL Guidelines** (<https://github.com/microsoft/alguidelines>, published at
  <https://alguidelines.dev>). Consulted at Step 03 for design patterns the Standards Guide doesn't
  cover, and at Step 09 as a best-practice pass (Lite: Steps 2 and 6).
- **New ALL ALONG section — Reference Sources.** Lists both, plus the Base App docs and Microsoft
  Learn's *Working with translation files*, with a precedence rule: symbol files beat Microsoft
  Learn, the Standards Guide beats AL Guidelines, and a conflict is surfaced to the human rather
  than silently reconciled. All are consulted online, not fetched, so there's nothing to
  bootstrap, gitignore, or refresh.
- **One known conflict, excluded by name.** AL Guidelines' legacy *C/AL Coding Guidelines* include
  *"CaptionML on System Pages"* and *"Using OptionCaptionML"*, both of which recommend exactly what
  the new §1.7 bans. An agent consulting AL Guidelines could otherwise pick them up. Both the new
  section and Standards §1.7 say they're superseded. AL Guidelines' current *Vibe Coding Rules*
  already agree with §1.7.
- **Outlines and schematics:** both ALL ALONG lists gain the entry; both ALL ALONG diagrams gain a
  Reference Sources node. All 15 diagrams (8 full, 7 Lite) re-rendered clean with mermaid-cli.

### Added — `THIRD_PARTY_NOTICES.md`, and license-safe snapshots

AJ Ansari asked that everything the framework uses from other repositories be credited as its
open-source license requires. Every referenced repository's license was checked against its own
`LICENSE` file: BCQuality, AL Guidelines, the Patterns Library, mermaid-cli, and AZ AL Dev Tools
are MIT; Microsoft Learn documentation is CC BY 4.0.

- **New `THIRD_PARTY_NOTICES.md`** at the repo root: every resource the framework fetches,
  references, invokes, or recommends, with its license, copyright holder, how it's used, and how
  the obligation is met. Linked from the README's Contents table. It records that this repository
  bundles no third-party code.
- **Snapshots keep their `LICENSE` file.** The BCQuality and Patterns Library fetch instructions
  said to strip `.git`; both editions now also say explicitly to keep `LICENSE`, since MIT requires
  the copyright and permission notice to travel with every copy — and these snapshots are copies.
- **CC BY 4.0 attribution in Standards §1.7.** The quoted AL0424 message and the adapted list of
  ML properties now carry a source link, the license, and a note that the list was reorganized.

### Changed — Lite v1.3.0.0

- The ML anti-pattern's three touchpoints, in Lite's equivalents: Step 3's post-generation
  pre-flight, Step 4's generation instruction, and Step 6's code review.
- Operating Rule 2 fallback gains the System App docs; Step 2 consults AL Guidelines for patterns;
  Step 6 adds the AL Guidelines best-practice pass.
- New ALL ALONG → Reference Sources section, and `LICENSE` retention for the BCQuality and
  Patterns snapshots.
- Standards Guide version references updated to v1.1.0.0.

### Changed — README

Background lists the System App docs and AL Guidelines among the framework's grounding sources;
Contents gains `THIRD_PARTY_NOTICES.md`; Last Updated moved to September 14, 2026.

---

## v2.5.0.0 — September 13, 2026

**§1.7 now asks for thinking effort, not just a model, per role — as its own separate question,
recommending High by default.** Also names, for the first time, the file the whole intake sheet is
actually persisted to.

### Fixed — §1.7 has been titled "Model & Effort Assignment" since it existed, but never asked for effort

An independent review asked directly: when the runbook lets the human configure Main / Light /
Reasoning roles, does it also let them pick a thinking-effort level per role? It did not — §1.7
captured a model per role and stopped there, even though "Effort" has been in its own section
title since the three-role division was introduced in v2.1.0.0. The schematics diagram at §4.2
(itself titled "Model & Effort Assignment") had the same gap: each role's box showed "Example
model: …" with no effort anywhere.

A follow-up question sharpened the fix further: model and effort needed to be **two separate
interactive questions per role, always** — never inferred from the model choice, never bundled
into one prompt — and the recommended default across **every** role needed to be **High**, not a
mix of Medium and High by role. An earlier pass at this fix had differentiated the recommendation
(Medium for Main and Light, High only for Reasoning); that reasoning is preserved as the rationale
for when a human might *choose* to override toward Medium, but it is no longer what the framework
recommends by default anywhere.

### Added — thinking effort as its own question per role, High recommended everywhere

- **Two separate questions per role, asked in sequence, never merged:** "Which model should the
  `<Role>` role use?", then — as its own distinct interactive prompt (Rule 6a), immediately after —
  "What thinking effort should the `<Role>` role run at?" Repeated for Main, then Light, then
  Reasoning.
- **High is the recommended default for all three roles, always**, regardless of which model is
  assigned to which role — presented as the first-listed option with the reasoning: this is a
  quality-first framework, and every one of the three roles' jobs benefits from more thinking
  effort, not less. A human may still choose Medium as an explicit override — most plausibly for
  **Light**, whose checklist-matching work has the smallest marginal benefit from extra effort of
  the three roles — but the default *offered* is High everywhere.
- **`N/A` is now a valid, explicit answer** for a role whose assigned model exposes no
  thinking-effort dial at all — distinct from a blank, which still reads as "not yet asked."
- **The Parameters table row, the worked example, the delegation-mechanics paragraph, and Step
  01's exit gate** were all updated to match: the exit gate now requires every configured role to
  carry both a model and an effort (or `N/A`), not model alone. The worked example shows a
  realistic mix — Main and Reasoning accepting the recommended High, Light explicitly overridden
  to Medium for cost — rather than either all-High or the old differentiated defaults.
- **Schematics §4.2** — each role's box now reads "effort High (default accepted)" for Main and
  Reasoning and "effort Medium (High default overridden)" for Light, with an intro line stating
  model and effort are two separate questions and High is the universal recommended default.
  Re-rendered and verified (all 8 diagrams in the file still parse clean).

### Fixed — the Project Parameters block had no named file to live in

Answering a direct question about where the model/role decision (and every other Step 01 value) is
actually stored turned up a real gap: "Project Parameters" was referenced as an Input or Output by
Steps 01, 02, 03, and 06, and called the project's single source of truth in the runbook's own
opening paragraph — but no step ever named a file for it. It was the one entry implied by every
other document's existence that was never itself on the canonical document list.

- **`docs/ProjectParameters.md`** is now Step 01's named output — the completed intake sheet,
  persisted as its own tracked document so every later step and every §1.7 role reads it from disk
  rather than depending on conversation history.
- **Added to the ALL ALONG → Document canonical list**, right after `ProblemStatement` (the list is
  now 19 documents, not 18), and to the opening paragraph's description of the Project Parameters
  block.
- **Steps 02, 03, and 06's Inputs lines** now cite `docs/ProjectParameters.md` by name instead of
  the bare phrase "Project Parameters."
- **Schematics' DEFINE diagram (Step 01 node)** updated to output `docs/ProjectParameters.md`
  instead of the unnamed "Project Parameters."
- **Lite's own document-count comparison** (which cites the full framework's total) updated from
  18 to 19 and now lists `ProjectParameters` alongside `ProblemStatement`.

This section remains entirely optional and vendor-agnostic, as it always was — if the human has
no preference, §1.7 is skipped in full and every role, including effort, runs through whatever the
harness's own default is.

### Fixed — Lite gets its own `ProjectParameters.md`, closing the same gap (Lite v1.2.0.0)

Lite had the identical version of the gap above: its own Project Parameters block was referenced
throughout — Step 1's own actions, and as an Input to Steps 2 and 3 — but never persisted to a
named file. Fixed the same way, adapted to where Lite actually keeps things:

- **`ProjectParameters.md`**, in the **project root** — not `docs/`, since Lite never uses a
  `docs/` folder anywhere; everything lives flat at the root, matching `ProblemStatement.md` and
  `ProjectProgress.md`.
- Step 1's own action bullet, Outputs, and Exit gate all updated to name the file explicitly, the
  same way Step 01's did in the full framework.
- **Steps 2 and 3's Inputs lines** now cite `ProjectParameters.md` by name instead of the bare
  phrase "Project Parameters."
- **`LITE_Outline_OCPFBCAgenticDevFW.md`'s Document Set** section now lists `ProblemStatement.md`
  and `ProjectParameters.md` as the two Step 1 setup artifacts, distinct from the four documents
  tracked throughout the routine — that "four tracked files" framing was never meant to be a
  literal file count (it already excluded `ProblemStatement.md`), so it's left as-is; the new line
  just makes what it does and doesn't cover explicit.
- Lite's own header bumped to **v1.2.0.0** (derived from full framework v2.5.0.0) to reflect a real
  addition, not just documentation churn.

---

## v2.4.0.0 — September 13, 2026

**The companion Standards document is back — recovered, cleaned up, versioned, and now fetched
into every project.** Also tracks the first release of `ocpfALDevStandardsGuide.md` **v1.0.0.0**,
which is versioned independently of the runbook but recorded here alongside it.

### The problem this version fixes

Every version of this runbook since the baseline cited a companion rules document —
`AL_PTE_Development_Standards_UNIFIED.md` — as **Standards §**, roughly seventy times across
every phase. That file was never in this repository and never in its git history. The runbook had
been operating as one half of a two-document pair whose other half nobody could open.

Worse, an audit of those citations found that a large fraction of them pointed at sections that
had never existed in the companion document *even when it did exist* — every `Standards §11.2`,
`§11.3`, `§11.4`, `§11.5`, `§11.6`, and the whole `§12.x` family (nine citations in all, covering
the API test checklist, as-built TDD, gap-fit comparison, code review, user guide, and deployment
instructions). The real content for all of them was already in the runbook; the citations were
decoration pointing into a void. A separate note at ALL ALONG → Retain Explanations had already
flagged one of these as "unverified against the companion doc, which isn't in this repo."

### Fixed — the Standards Guide, recovered and rewritten as a rules-only document

AJ Ansari supplied the original file. It has been cleaned up and republished as
`standardsGuide/ocpfALDevStandardsGuide.md` (**v1.0.0.0**). The governing edit was: **anything the
runbook already handles must not also live in the Standards Guide**, because two copies of a rule
are two rules that will eventually disagree. Removed from the guide entirely:

| Removed from the guide | Why | Now lives only in |
|---|---|---|
| **Part 1 — Project Parameters** (§1.1–§1.5: identity, ID allocation, naming/API, platform/runtime, feature flags) | The runbook collects all of this interactively at Step 01, with questions, a multi-range ID loop, and four sections (§1.6–§1.8 plus the `Use Namespace` parameter) the guide never had. A static second copy could only ever be a stale copy. | Runbook **Step 01** |
| **Part 2 — Project Lifecycle & Documentation Standards** (§2.1 required documents, §2.2 development stages, §2.3 TDD self-sufficiency, §2.4 sanity-check checklist) | All four are in the runbook in fuller form. The runbook's document list carries 17 documents to the guide's 7. | Runbook **ALL ALONG → Document**, **Step 03**, **Step 04**, and the phase structure |
| **§9.1 Pre-Compilation Checklist** | Directly duplicated Step 05's pre-flight checklist, which explicitly declares itself canonical and says "if you're re-stating it elsewhere, point here rather than re-enumerating." | Runbook **Step 05** |
| **§9.3 / §9.4** (systemic compiler errors; zero errors/warnings) | Operating Rules 4 and 5 say the same thing. | Runbook **Operating Rules 4, 5** |
| **Part 10 — Agentic Development Guidance** (§10.1–§10.5) | §10.1 duplicates the prime directive; §10.2 duplicates Step 03; §10.4's ChangeLog format is byte-identical to ALL ALONG → Track Changes; §10.5 is Operating Rule 2. | Runbook **prime directive, Step 03, ALL ALONG → Track Changes, Operating Rule 2** |

### Fixed — two live contradictions between the two documents, now gone

Both were in the guide and both would have actively mis-instructed an agent that read it:

- **§10.3 "Batch Generation Strategy"** told the agent to *"Open in VS Code and compile
  immediately"* after Batch 1 and *"Never generate all batches before compiling Batch 1."* Operating
  Rule 4 says the exact opposite — do **not** compile per batch; lint with symbol verification
  instead, and compile-and-package once at Step 07. Removed.
- **The Anti-Patterns row "Generating all batches before compiling → Compile after each batch"**
  was the same contradiction in table form. Removed; every other row was kept.

### Changed — the Standards Guide renumbered, and all ~70 runbook citations repointed

With Parts 1, 2, 9 (mostly) and 10 gone, the remainder was renumbered into a contiguous rules-only
structure. Every citation in the runbook was updated to match; all of them now resolve to a
section that actually exists.

| Old | New |
|---|---|
| Part 3 — AL Coding Standards | **Part 1** (§3.1–§3.5 → §1.1–§1.5, plus old §9.2 indentation as **§1.6**) |
| Part 4 — API Page Design Rules | **Part 2** (§4.1–§4.6 → §2.1–§2.6) |
| Part 5 — Field Inclusion & Exclusion | **Part 3** (§5.1–§5.4 → §3.1–§3.4) |
| Part 6 — Identifier Naming Rules | **Part 4** (§6.1–§6.4 → §4.1–§4.4) |
| Part 7 — Module & ID Allocation | **Part 5** (§7.1–§7.3 → §5.1–§5.3) |
| Part 8 — Gap Analysis Checklist | **Part 6** (§8.1–§8.6 → §6.1–§6.6) |
| Part 11 — Anti-Patterns Reference | **Part 7** |
| Appendices A, B, C | unchanged |

The nine citations to sections that never existed (`§11.2`–`§11.6`, `§12.1`–`§12.5`) were dropped
rather than repointed — the content they claimed to cite was always the runbook's own. The six
`Standards §2.2 Stage N` exit-gate citations now read **Stage↔Step Map, Stage N**, pointing at the
runbook's own map, which gained a short explanation of why it's kept.

### Changed — the relationship between the two documents is now stated in both, in one direction

The runbook's Step 01 used to claim its parameter block was *"copied verbatim from
`AL_PTE_Development_Standards_UNIFIED.md` Part 1."* With Part 1 gone from the guide, that's
reversed and stated explicitly on both sides: **Step 01 is the authoritative source**, and the
guide defers to whatever is filled in there rather than carrying its own copy. The guide opens
with a "What is deliberately *not* here" table naming all ten topics that live only in the
runbook, so a future reader can see the split was a decision rather than an omission.

### New — the guide is fetched at PRE-01, and gitignored

- **PRE-01 gained a first action**: fetch `standardsGuide/ocpfALDevStandardsGuide.md` from
  `https://github.com/ajansari/ocpfBcAgenticDevFramework/` into a `standardsGuide/` folder in the
  project root. PRE-01, not Step 05 alongside BCQuality and the patterns library, because PRE-02's
  own gap-analysis checklist *is* Standards Part 6 — by Step 05 it would already be four steps
  too late.
- **New ALL ALONG section — OCPF AL Development Standards Guide** — covering fetch, `SNAPSHOT.json`,
  refresh-only-on-request, and version skew. It records one deliberate difference from its two
  sibling sections: an unreachable patterns library degrades gracefully, but an unreachable
  standards guide means every `Standards §` citation in the routine points at nothing, so the agent
  must stop and ask for a copy rather than proceed from memory of what the standards say.
- **`standardsGuide/` is always gitignored**, never a per-project choice — same policy as
  `patterns/`, the BCQuality snapshot, and `scripts/`. Added to Repository Hygiene's
  always-excluded list, and §1.8 now says explicitly that the intake question governs only the
  runbook, its changelog, and its schematics — not the fetched libraries.
- PRE-01's exit gate now requires the guide to be present and gitignored.

### Fixed — the "unverified Appendix C" note, resolved rather than carried forward

ALL ALONG → Retain Explanations carried a standing caveat that its Appendix C citation (per-batch
commits) was unverifiable and might conflict with Step 06's Appendix C citation (the AZ AL Dev
Tools rule set). With the guide recovered, both are settled: Appendix C is a **tools** list, so
Step 06's citation was right all along and the commit convention is the runbook's own rule, now
stated without a citation. The caveat is replaced with a note recording the resolution.

### Changed — Lite Edition wired up to the Standards Guide (Lite v1.1.0.0)

The Lite Edition (`liteVersion/`) had no Standards references at all — it inlined short-form
summaries of the AL rules and stopped there. It now fetches and cites the same guide, on the
principle stated in its own header: **Lite reduces process, not AL rules.** The same AL rules
apply to a 5-file extension as to a 50-file one, so both editions fetch the identical v1.0.0.0
file; only the surrounding ceremony differs.

- **Lite Step 1 gained the fetch** as its first action — the same PRE-01 reasoning, since Lite's
  Step 1 gap check already leans on Standards Part 6. `standardsGuide/` added to `.gitignore`,
  added to Lite's Repository Hygiene list, and named in Step 1's exit gate and outputs.
- **New Lite ALL ALONG section** — OCPF AL Development Standards Guide — with the same
  fetch/refresh/version-skew policy and the same stricter-than-patterns failure mode (stop and ask
  rather than proceed from memory).
- **Citations added where Lite states a rule in short form**, so its brevity now has depth behind
  it rather than being the end of the story: naming and abbreviations (§4.1–§4.4), the page
  template and mandatory properties (§1.1–§1.5), indentation (§1.6), editable vs. read-only
  (§2.2), `const()` quoting (§2.3), captions/tooltips as schema (§2.5–§2.6), field exclusion
  (Part 3), growth-buffer IDs (§5.2), permission sets (§5.3), the gap-analysis tables (Part 6),
  endpoint patterns (Appendix A), and symbol verification (Appendix B).
- **Step 6's code review now explicitly runs the full Anti-Patterns table (Part 7)** — called out
  as the single highest-value thing the guide gives a Lite project, since most of what it catches
  stays invisible until publish or until a consumer hits it.
- Lite's Parameters block now states that it is authoritative and that the guide defers to it —
  the same one-directional relationship the full framework's Step 01 now states.
- `LITE_Outline_OCPFBCAgenticDevFW.md` updated to list the guide under ALL ALONG and in the
  document set.

### Fixed — three defects found in an independent review of Lite (carried over from Lite v1.0.0.0)

A review of Lite against the full framework, checking whether each of the full framework's
mechanisms actually made it across, confirmed that Rule 6a (options box), Rule 6c (step-completion
check-in), the AL MCP Server, BCQuality, and the Patterns Library are all present and wired up.
It also turned up three real defects, all predating this version:

- **The hand-off moment was in the wrong place.** Lite's note sat at the *end* of Step 7, after
  the exit gate, and read "what's left is a human running tests and deciding whether to ship" —
  but Step 7's own actions *are* the human running tests, and its exit gate has already marked the
  release candidate and shipped to Production. By the time an agent reached that line, nothing it
  described was still pending. Moved to the **top of Step 7**, reframed as the Step 6 → Step 7
  boundary — the same position and purpose as the full framework's Step 11 → Step 12 note.
- **The hand-off didn't use the options box, and silently collided with Rule 6c.** It said "say so
  plainly" — prose — while Rule 6c independently requires a selectable-options check-in when Step
  6 closes, leaving two interactions at one boundary with no guidance. It now runs through the
  Rule 6a mechanism with the same two named options as the full framework, and both sides state
  the precedence explicitly: the hand-off **replaces** Rule 6c's generic check-in at that one
  boundary, and Rule 6c now points at it.
- **The document count was wrong** — the Step Map claimed the full framework has "~15" documents
  while listing 18 in the same sentence. The full framework's own canonical list in ALL ALONG →
  Document is exactly 18. Corrected.

Also tightened: Step 6's code review hedged with "if a live BCQuality snapshot exists," even
though Step 3 bootstraps it unconditionally. It now invokes the snapshot directly and requires the
agent to say so if it's missing, rather than silently skipping the pass.

### Changed — README documents both editions

The README covered only the full framework. It now carries a **Lite Edition** section: when to use
it (~5–10 AL files, one person, one model), when to graduate to the full framework, what Lite
trims (process, not rules), and per-tool deployment steps for the Claude Code plugin and GitHub
Copilot Chat — matching the existing full-framework instructions. Also adds the Standards Guide to
the Contents table with a note that it's fetched automatically rather than copied by hand, and
notes that a project follows one edition or the other, with the full runbook swapped in place of
the Lite one if a project outgrows Lite mid-flight. Two stale items fixed in passing: the
Contents table still named the pre-rename `The OCPF BC Agentic Dev Framework Outline.md`, and the
"Last Updated" line read Saturday, September 12, 2026.

### Changed — dates are written in long form throughout

Every `YYYY-MM-DD` date in the runbook, this changelog, the schematics, and the Lite runbook is now
written as `September 13, 2026`. No date was changed — only its formatting.

### Also in the guide, not just removals

- **§1.1 and §1.3** now honor the runbook's `Use Namespace (y/n)` parameter, which postdates the
  original guide: if it's `No`, the `namespace` line is omitted from every generated file. The old
  template assumed a namespace unconditionally.
- **§5.3** absorbed the `PTE0004` / `tabledata`-coverage rule that the runbook had been carrying
  alone across four separate steps.
- **§5.2** notes that reserved growth IDs are what gap-fill work draws on later — the fact the
  deleted `§11.6` citation was reaching for.
- **Appendix B** gained the MS Learn BaseApp fallback that Operating Rule 2 already described.
- **Part 7** gained one anti-pattern row from the runbook's Step 03: reaching for a `FlowField`
  when "auto-populated but editable" is what's actually wanted.

---

## v2.3.0.0 — September 13, 2026

Three changes from the same request, all corrections or additions AJ Ansari made after actually
living with `v2.2.1.0` for a few minutes on the pilot project — a location he wanted fixed, a
capture behavior that had never existed at all, and a tracking default nobody had ever actually
reviewed.

### Fixed — `ProjectProgress.md` now lives in the project root, not `docs/`

v2.2.1.0 placed the new tracker under `docs/` alongside every other document. AJ wanted it at the
project root instead — the whole point is a fast, at-a-glance check, and every other required
document already lives under `docs/`, so putting this one there too buried the one file meant to
be the fastest thing to find. PRE-01's own action and the ALL ALONG section heading both corrected
to say "project root," explicitly called out as the deliberate exception to where every other
document lives.

### New — capture raw requirements verbatim, at PRE-01 and whenever they arrive later

Nothing in the routine previously said what to do with a stakeholder's raw input — pasted
requirements text in chat, or an uploaded file — beyond it eventually feeding `ProblemStatement.md`
in already-interpreted form. AJ wanted the raw material itself preserved, unedited, as its own
artifact — exactly the role this pilot project's own `requirements/bootcamp-registration-extension-requirements.md`
had already been playing informally, now made a standing rule instead of something that happened
to be done right once.

- **New PRE-01 action:** create `requirements/` in the project root if it doesn't exist (a
  normal, git-tracked artifact, never gitignored). Pasted chat text becomes its own Markdown file
  (descriptive name, a header naming who provided it and when, then the raw text verbatim —
  no editing, cleanup, or summarizing in this copy). An uploaded file gets saved as an unmodified
  copy under its own filename. A same-named capture is never overwritten — a date suffix is added
  instead, same never-delete discipline as `outputAppPackage/`.
- **Not limited to kickoff** — the same capture applies any time later raw requirements or scope
  input arrives (a change request, a fresh drop of material), not only at PRE-01.

### Fixed — `.app` build packages are tracked in git by default, not gitignored

AJ, reviewing the pilot project's own `.gitignore`: the runbook's Packaging & Versioning section
had never actually said to gitignore built packages — an earlier project scaffolded its own
`.gitignore` that way regardless, as an unreviewed default nobody had traced back to a rule that
didn't exist. Corrected the actual gap rather than just the pilot project's file:

- **New standing rule:** `outputAppPackage/*.app`, and any `.app` file anywhere in the repo, are
  git-tracked like any other project deliverable — never gitignored, at Step 05 scaffolding or
  ever after. If a project is ever found with one anyway (e.g. built on an older framework copy),
  remove the ignore rule and track the packages it was hiding — checking first, per Repository
  Hygiene's own untracking caution, whether a remote exists that would show collaborators a sudden
  batch of "new" files.
- Applied on the pilot project itself: the `.gitignore` rule removed, all 6 `outputAppPackage/`
  versions added, plus 6 duplicate, non-standard-named `.app` files that had accumulated at the
  repo root (from a VS Code Publish action, outside the framework's own naming/location
  convention) — AJ's explicit choice to track those too rather than leave them out. A stray
  `_compile_check.app` (a spot-check compile byproduct, never actually named like a real release)
  was deleted outright, also AJ's explicit choice — the only one of the three ever actually
  removed rather than tracked or left alone.

**Files affected:** `CLAUDE.md` (PRE-01, ALL ALONG → Project Progress Tracker, Packaging &
Versioning). Project files touched on the pilot project directly (not part of this framework
repo): `.gitignore`, `ProjectProgress.md` moved to root, 12 `.app` files added, 1 deleted.

---

## v2.2.1.0 — September 13, 2026

### Fixed — Step 11's "Automated Test Scripts" question was wrongly scoped to API-only tooling

AJ Ansari, reviewing a project that had already been asked this question once: "Why is the
automated test script focused around Postman/API? This was supposed to be for automated test
scripts for the entire BC app (AL)." A real misunderstanding, not a deliberate scoping the
runbook had ever actually confirmed with AJ — the wording introduced in v2.1.0.0's Step 07/09/12
restructure framed "Automated Test Scripts" entirely in terms of external HTTP tooling (a
Postman/Newman collection, a Playwright suite), as if that were the only kind of automation
worth asking about. It caught real, if quiet, damage: the pilot project had already been asked
the mis-scoped question at its own Step 11 and declined — no wrong artifact was produced, but the
question itself never offered the option that was actually wanted.

- **Fixed — Step 11 now names two genuinely different kinds of automated testing and asks which
  (or both), rather than assuming API-level tooling is the only kind:**
  - **AL Test Framework (native)** — BC's own mechanism: test codeunits (`Subtype = Test`),
    `[Test]`-attributed methods, the platform's test libraries (`Library Assert` etc.), run via
    the in-client Test Tool or headlessly in CI (AL-Go for GitHub, `BcContainerHelper`). Tests the
    app's actual business logic directly in AL, not just what's reachable over an API. Shipped as
    its own test app with its own `app.json` and object ID range.
  - **API-level automation** — the previously-described Postman/Newman/Playwright approach,
    unchanged, now correctly presented as one of two options rather than the only one.
  - Recommends AL Test Framework as the default when the human has no preference and the
    extension has nontrivial business logic (it's the only one of the two that can exercise logic
    never surfaced through the API); recommends a Postman collection as the default specifically
    for whichever project chooses API-level automation.
  - `AutomatedTestScripts.md`'s own description updated to name which kind(s) were created and
    to track the app, not just its API, as the thing to keep current against.

**Files affected:** `CLAUDE.md` (Step 11). No project files touched.

### New — `docs/ProjectProgress.md`, a required, standing status table

AJ Ansari asked for a persistent way to see which step a project is on across the whole
routine — ideally a progress bar. No mechanism available to any agent running this framework
writes to a persistent UI element outside its own conversation, and even a harness-specific one
wouldn't travel with the repo the way a file does — so a durable, in-repo artifact is the
substitute, the same reasoning that already justifies `ProjectMemory.md` existing instead of
relying on an agent's own non-shared cross-session memory.

- **Added a new required ALL ALONG artifact:** `docs/ProjectProgress.md` — one row per step
  (PRE-01 through 12, the full routine, not only the numbered steps), a Status column
  (blank / `In Progress` / `Completed`), and a closing note that asking, in plain language,
  "Where are we in the process? What's next?" always gets a direct answer, agent running or not.
  Deliberately kept to a single table, nothing narrative — that's what `ProjectMemory.md` is
  already for.
- **Created at PRE-01, updated at every step boundary alongside `ProjectMemory.md`'s "Current
  position."** PRE-01's own Actions gained a new first bullet: create this file, seeded, before
  anything else — the very first artifact of the entire engagement.
- **Finer-grained, in-session progress (a live plan while a step is actively being worked) stays
  conversational, not filed.** `ProjectProgress.md` tracks step-level status only; narrating
  what's planned/done/left within a single step's multi-part work is ordinary text in the
  conversation, no tool or document update involved.

**Folded into this version rather than given its own** (AJ's call) — same-day addition on top of
the fix above, not yet exercised on any project when it landed.

**Files affected:** `CLAUDE.md` (PRE-01, ALL ALONG). No project files touched by this addition
itself (the pilot project's own `docs/ProjectProgress.md` was created and backfilled separately,
since the project predates this rule).

---

## v2.2.0.0 — September 13, 2026

Two standing interaction-behavior changes, both from the pilot project reaching the end of its
own PROVE phase for the first time and AJ Ansari deciding how that moment — and every PROVE-phase
step boundary before it — should actually be handled going forward, rather than left to whatever
the agent's own judgment produced in the moment (which, on the pilot project, was to just ask in
ordinary prose whether to keep going).

### New Operating Rule 6c — check in after every step from Step 08 onward

Previously, Rule 6a explicitly said *not* to wrap ordinary step-to-step hand-off in a decision
box ("finishing a step and waiting to be told to start the next one... is normal conversation,
not a decision point"). That's still the right default for Steps 01–07, where Operating Rule 6's
own approval gates already pace things tightly batch by batch. But starting at Step 08, each step
hands back a real artifact — a gap analysis, a code review, a repackaged build, a full
documentation set — that the human may need time to act on before anything else happens, which
makes "keep going or pause here" a genuine decision, not noise.

- **New Rule 6c:** from Step 08 (Gap-Fit Test) through Step 12 (Release to Users for Testing),
  close every step with a second message after its normal summary: put "proceed directly into
  the next step now" vs. "pause here" through the same interactive mechanism Rule 6a already
  uses, and say how to resume when ready. Steps 01–07 are explicitly carved out as unaffected.
- The Step 11 → Step 12 boundary is called out as a special case of this rule, not an addition to
  it — see below.

### New: a formal hand-off message at the Step 11 → Step 12 boundary

The moment Step 11's outputs are done, the agent's own work in this routine is effectively
finished — Step 12 runs entirely by human hands. AJ wanted that specific moment marked
deliberately rather than folded into the generic Rule 6c check-in or, worse, left to ordinary
conversational back-and-forth (a real risk: it's easy for this instant to slide by unremarked
when the agent is mid-flow finishing Step 11's four documents).

- Added a note at the top of Step 12 describing the required message: it must congratulate the
  human, state plainly that this is the logical end of the framework's own work, say concretely
  what to do next, and say how to bring the agent back in — sent through Rule 6a's interactive
  mechanism with exactly two named options (**"Perfect, I understand!"** / **"I have some
  questions"**) plus the mechanism's own free-text/Other entry, never as plain prose.
- A worked example from the pilot project is included directly in the runbook text, since this is
  exactly the kind of moment that's easy to under-specify and then improvise inconsistently
  project to project.
- **This replaces, not adds to, Rule 6c's generic check-in for this one boundary** — a project
  doesn't get both a generic "proceed or pause?" prompt and the formal hand-off message back to
  back at this specific transition.

**Files affected:** `CLAUDE.md` (Operating Rules, Step 12). No project files touched.

---

## v2.1.0.0 — September 13, 2026

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

### Independent review of the restructure, and its fixes (September 13, 2026)

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

### OCPF BC AL Patterns Library — a new ALL ALONG section (September 13, 2026)

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

## v2.0.1.0 — September 12, 2026

A packaging/deployment-communication gap found the same day, while wrapping up a bug-fix
round on the pilot project — released as its own point revision rather than folded into
v2.0.0.0, since v2.0.0.0 had already been established as the framework's first versioned
baseline.

### Output folder naming & Schema Sync Mode / Force Sync guidance (September 12, 2026)

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

### Schematics — Model & Effort Assignment diagram clarified (September 12, 2026)

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

## v2.0.0.0 — September 12, 2026

First versioned revision. Everything below was learned during the framework's first real
project (a Business Central bootcamp-registration tracking PTE) and folded back into the
framework itself, dated to when each change actually happened during that project.

### Compile cadence (September 11, 2026 → September 12, 2026)

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

### Tooling installation (September 11, 2026)

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

### Intake — Step 01 (September 11, 2026)

- **Added — §1.6 Onboarding & Discoverability.** Three new intake questions, asked at Step 01
  (not left to emerge mid-DESIGN): should the extension include an **Assisted Setup Wizard**
  (and if so, what it configures); should the Role Center get **Activity Cues** (and if so,
  which ones, their filters, and drill-through targets); should the extension be findable via
  **Departments / "My Business Central"** (and if so, under which department, with which pages).
  A `No` to any is a valid, final answer — not a placeholder to revisit.
- **Why:** discovered mid-project when the human asked "does our app have any activity cue
  tiles?" and the honest answer was no — not because it was rejected, but because nothing in the
  framework had ever asked at intake.

### Permission-set coverage (September 11, 2026)

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

### Model & effort assignment — Step 01 §1.7 (September 12, 2026)

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

### AL MCP Server & BCQuality Knowledge Snapshot (September 12, 2026)

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

### Full self-consistency review (September 12, 2026)

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

### Repository hygiene — what never syncs to a project's remote (September 12, 2026)

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

Prior to this, there were two separate private repos of earlier versions and directions of this agentic development framework. These were merged and rebooted as this project.