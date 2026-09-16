# OCPF BC Agentic Development Framework — Operations Guide

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

**Version:** 1.2.0.0
**Last Updated:** September 15, 2026

> **Relationship to the runbooks.** This guide is the shared companion to
> `fullVersion/BC_App_Build_Routine_Agent.md` and `liteVersion/LITE_BC_App_Build_Routine_Agent.md`.
> **The runbook drives the sequence** — what happens when, who signs off, which gate opens the next
> step. **This guide holds the procedures that sequence uses**: how the agent asks, sets the project
> up, runs the tools, packages, notifies, and keeps the repository clean. Both editions share it
> unchanged; where an edition differs, the difference is marked **Full:** or **Lite:** in place.
>
> The runbooks cite it as **Ops §**. The third document, the **OCPF AL Development Standards Guide**
> (`standardsGuide/ocpfALDevStandardsGuide.md`), holds the AL rules, cited as **Standards §**.
>
> **Read it a section at a time.** Each step of the runbook names the sections it needs, in its
> Actions and again in its exit gate. Don't load the whole guide to answer one question, and don't
> work from memory of a section you haven't opened in this project.
>
> **Version skew is worth naming.** The runbook's header says which version of this guide it expects.
> Section names never change within a major version, so a newer minor version is safe. If the major
> versions differ, say so and offer to update the runbook rather than guessing what moved.

### What is deliberately *not* here

| Topic | Where it lives |
|---|---|
| The phase/step sequence, every step's Inputs, Actions, Outputs, and Exit gate | The runbook |
| The Project Parameters block and its tables | The runbook, Full Step 01 / Lite Step 1 |
| The pre-flight checklist, the API test checklist, the Sanity Check checklist | The runbook |
| Document formats: ChangeLog, Project Memory, Progress Tracker, Testing Feedback Log | The runbook |
| AL coding rules, API page design, naming, field inclusion, permission sets, translations rules | **Standards §** |
| Which model does what (Full's role split) | Ops § Roles, below — it's procedure, but Full only |

---

## Ops § Contents

1. [Asking and Approvals](#ops--asking-and-approvals)
2. [Intake](#ops--intake)
3. [Roles](#ops--roles-full-only) *(Full only)*
4. [Project Setup](#ops--project-setup)
5. [AL Tools](#ops--al-tools)
6. [Analyzers](#ops--analyzers)
7. [Symbols](#ops--symbols)
8. [Editor Sync](#ops--editor-sync)
9. [Notifications](#ops--notifications)
10. [Packaging](#ops--packaging)
11. [Repository Hygiene](#ops--repository-hygiene)
12. [Translations](#ops--translations)
13. [Automated Tests](#ops--automated-tests) *(the Scripts offer is Full only; running AL tests is both)*
14. [Fetched Companions](#ops--fetched-companions)
15. [Reference Sources](#ops--reference-sources)
16. [Plugin](#ops--plugin)

---

## Ops § Asking and Approvals

The runbook's Operating Rule 6 says *when* to pause and *what* needs approval. This section says
*how* to ask, and how far to look before asking the human to install or configure anything.

### The mechanism, per harness

Every decision — including every intake question, and every value only the human knows — goes
through the harness's selectable-options mechanism, with the recommended option first and a short
reason on each. Never an open-ended question or a numbered list in chat.

- **Claude Code — `AskUserQuestion`:** up to four questions per box, 2–4 options each, a free-text
  *Other* added automatically, and multi-select where several answers apply.
- **GitHub Copilot Chat in VS Code — the `askQuestions` tool:** several questions in one carousel,
  each single-select, multi-select, or free text.
- **GitHub Copilot CLI — the `ask_user` tool:** a choice question there takes no typed answer, so
  add an explicit *I'll type it* choice and follow it with a free-text question.
- **Anything else:** its closest equivalent, one question at a time if that's all it offers. Only
  when a harness has no question mechanism at all, ask one question per message with its options
  labelled, and say why.

**Option counts:** 2–4 options per question. With a single suggestion, pair it with *I'll type it*;
with more than four candidates, offer the four most likely and say the rest can be typed.

**Don't wrap ordinary progress in it.** Finishing a step, reporting a clean compile, or handing back
a result is conversation, not a decision. Over-using the box makes it noise.

### Zero-install first

Before proposing **any** install (runtime, SDK, CLI, package, extension) or **any** manual setup for
the human (editing `PATH`, a shell profile, or an environment variable), work through this order and
stop at the first option that works:

1. **What the human's editor and extensions already provide.** For AL, the AL Language extension
   provides the tools two ways with nothing to install: built into GitHub Copilot Chat in VS Code,
   and as the bundled AL MCP Server for any other MCP host, running on the .NET runtime VS Code
   already provisioned (Ops § AL Tools).
2. **What's already installed** on `PATH` or in standard install locations.
3. **Only then, an install**, asked for explicitly and using the vendor's standard installer.

**Look harder before concluding a runtime is missing.** VS Code's AL extension gets its .NET runtime
from a companion ".NET Install Tool" extension, not a system-wide install, at a path that differs by
OS:
- macOS: `~/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/`
- Linux: `~/.config/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/`
- Windows: `%APPDATA%\Code\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\`

Check the one matching the actual machine, not the first that comes to mind. If the human's own
editor can already do the thing you're about to install a tool for, that's a strong signal the tool
exists somewhere you haven't looked. On a real project the agent skipped the search, installed a
fresh runtime, and had to remove it.

**Never ask the human to edit `PATH`, a shell profile, or environment variables.** If a tool needs a
path or a variable, put it in the configuration or launcher script *you* create.

**The test before proposing any setup:** would a functional consultant with only VS Code and the AL
Language extension have to do anything by hand? If yes, look again.

**Never hand the human a setup task the agent can do.** Connecting the AL tools, downloading
symbols, keeping the editor's view current, and setting up notifications are the agent's job. The
human's part is approving the AI tool's own prompts, and a browser sign-in when a tool reaches a
live Business Central environment. Ask for more only when something is actually broken and the agent
has run out of options — then name the exact command, and confirm it exists first: for an AL command,
check the AL Language extension's `package.json` (`contributes.commands`). **Never send the human to
the Command Palette to set up the AL MCP Server** — the extension has no such command — and **never
route AL tooling through a third-party VS Code extension** the human would have to install.

**Why this is a rule, not advice:** a step a developer shrugs off can stop a functional consultant
cold, and an agent reaching for an install or a dead-end Command Palette trip in front of a client
makes the framework look careless. It has already happened four separate times
(`RunbookChangelog.md`).

---

## Ops § Intake

How the parameter sheet is filled in. **The sheet itself — every parameter, its placeholder, and
its guidance — lives in the runbook** (Full Step 01, Lite Step 1); this section is only the asking.

Every question goes through the options mechanism (Ops § Asking and Approvals). **Use as few boxes
as the questions allow:** up to four questions per box, sharing a box only when none depends on
another's answer. Where the harness asks one question at a time, ask the same questions in the same
order.

**Before the first box:** read the problem statement for suggestions, and read Microsoft's live
*Country/Regional Availability and Supported Languages* page (Ops § Reference Sources) so every
country and language offered is one Business Central supports.

**A suggestion is a candidate the human picks, never an answer recorded on their behalf.** Nothing
reaches the parameter sheet until the human selects or types it. Build suggestions only from what
the human said or confirmed — never from an email domain or a guess at house style. An inferred
publisher and prefix once forced a full-project rename.

| Box | Questions | Options to offer (free-text entry always available) |
|---|---|---|
| **1 — Identity** | 1. Extension Name? | Up to three names built from the problem statement's own wording, each labelled a suggestion. |
| | 2. Publisher? | Only names the human has already written or uploaded, quoted verbatim, each with where it came from. If there are none: *I'll type it* / *Decide after the other questions* — then ask it again, alone, before Box 2. |
| | 3. Deployment Target? | *SaaS PTE* / *OnPrem PTE* / *AppSource*, the best fit for the problem statement first. |
| | 4. Which countries will users work in? *(multi-select)* | The countries the problem statement names that BC is available in. **Countries are asked only here** — Localization and the language questions reuse the answer. |
| **2 — Naming** *(built from Box 1)* | 5. AL object prefix? | Two or three short lowercase prefixes built from the name and publisher. |
| | 6. Which namespace? | `<Publisher>.<ExtensionShort>` built from Box 1 *(recommended)* / one alternative spelling / *No namespace* (only for a deliberate reason, such as a BC version predating namespaces). One answer records both **Use Namespace** and **Namespace**. |
| | 7. Localization? | Up to three of the Box 1 countries as codes (e.g. `US`), then `W1`. |
| | 8. Business Central version? | The current BC online major version *(recommended)* and the one before it, looked up on Microsoft Learn, never from memory. A sandbox the human already has is the natural choice. Don't ask for `runtime`: read it from Microsoft Learn's [Choose runtime version in AL](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-choosing-runtime) table (for example runtime `17.0` ships with Business Central 28.0). |
| **3 — Permission sets & IDs** *(built from Box 2)* | 9. Permission Set App Code? | Two or three uppercase codes built from the name that fit `13 − (prefix length)` characters. The question says the code must differ from every other extension using this prefix (**Standards §5.4**). |
| | 10. Do other extensions already use this prefix? | *No, this is the first* / *Yes — I'll type their App Codes or permission set names*. If one matches answer 9, ask 9 again, alone. If the human isn't sure, recommend a more specific code. |
| | 11. Object ID range? | Complete ranges, each with its size: any range the human's material names (e.g. *80300–80339 — 40 IDs*); *50100–50149 — 50 IDs*, described as "the AL template's default: only if no range has been assigned to you"; or type one as `start–end`. A typed range whose start is above its end is asked again. **When Deployment Target is `AppSource`, the options change** — see *The AppSource questions* below. |
| | 12. Another Object ID range? | *No* / *Yes*. Each *Yes* opens a box with questions 11 and 12 again. |
| **4 — Onboarding** | 13–15. Assisted Setup Wizard? Role Center Activity Cues? Departments / "My Business Central" placement? | *No* / *Yes* each, with the runbook's one-line description of what each is. A follow-up box then asks the specifics of every *Yes*, offering choices drawn from the problem statement. |
| | 16. Permission Sets required? *(only if the entity list has no new table)* | *No — the extension adds no tables* / *Yes*. Not asked once the extension owns a table: then it's `Yes` (**Standards §5.3**). |
| **5 — Working setup** | 17. Split work across models? **Full only** | *One model for everything (recommended)* / *Recommended split* / *Customize each role* (Ops § Roles). |
| | 18. Leave the framework's own files out of the project's repository? | *Yes (recommended)* — the framework is distributed from its own repository, and its methodology isn't part of what the client receives / *No, track them* — a teammate cloning the project sees exactly how it was built. Explain `.gitignore` in the question itself: *"`.gitignore` lists files Git leaves out of commits and pushes — they stay on disk and work normally."* |
| | 19. Which language is the AL source text written in? | *`en-US` (recommended)*, with **Standards §8.1**'s reason in one sentence, or another language typed in. |
| **6 onward — Languages** | The per-country, per-language, and document questions below. | As below. |
| **Last — Confirm** | 20. Is this sheet right? | Show the complete sheet first — every ID range with its size, and the derived permission set names. *Confirm the sheet* / *Change something* (then ask only what changes). |

**Option counts** are in Ops § Asking and Approvals: 2–4 per question, a single suggestion paired
with *I'll type it*, more than four candidates trimmed to the four most likely.

**Lite differs only by what it doesn't have:** no question 17 (no role split), and its Box 5 carries
the `.gitignore` question, the source language, and the per-country language questions together.

### The AppSource questions

**Asked only when the answer to question 3 is `AppSource`**, and asked during intake — not
discovered at release, when a missing manifest property means the submission is rejected outright
(**Standards Appendix E**). For `SaaS PTE` and `OnPrem PTE`, skip this whole section; none of it
applies.

**Question 11 changes.** An AppSource app's ID range is **registered to the publisher by
Microsoft**, not chosen (**Standards §5.5**). Offer:
- any range the human's material names, if it falls in 1,000,000–69,999,999 or
  70,000,000–74,999,999;
- *I'll type the range Microsoft assigned us* — validated against those two bands, and asked again
  with the reason if it isn't in one;
- *We don't have one yet* — accepted, recorded as a release blocker in the parameter sheet, and
  said plainly in the question: the app can be built and tested, but can't be submitted until a
  range is requested.

**Never offer `50100–50149` here**, or any other part of 50,000–99,999: that's the customization
range, and an app submitted from it fails validation.

**Two extra boxes, after Box 3.** Every answer is written into `app.json` at project setup, and
each one is mandatory for submission:

| Box | Questions | Options to offer |
|---|---|---|
| **3a — Marketplace listing** | A1. Short description (`brief`)? | One line drawn from the problem statement, labelled a suggestion, plus *I'll type it*. It must match the offer listing in Partner Center. |
| | A2. Long description (`description`)? | A paragraph drawn from the problem statement, labelled a suggestion, plus *I'll type it*. |
| | A3. Product or support website (`url`)? | The publisher's domain if the human has given one, plus *I'll type it*. Say what it's for: it shows as **Website** on the **Extension Management** page. |
| | A4. Logo file? | *I'll give you the path* / *I'll add it later* — if later, record it as a release blocker. The file is committed in the project and referenced by a relative path. |
| **3b — Legal and support URLs** | A5. Privacy statement URL (`privacyStatement`)? | *I'll type it*, or the publisher's domain with a suggested path. |
| | A6. License terms URL (`EULA`)? | Same. |
| | A7. Help and troubleshooting URL (`help`)? | Same, plus *Same as the context-sensitive help URL*. |
| | A8. Context-sensitive help URL (`contextSensitiveHelpUrl`)? | Same, plus *Same as the help URL*. If the app won't cover every BC locale, say so and record `/{0}/` in the URL with the locales in `supportedLocales`. |
| | A9. Application Insights connection string? | *I'll paste it* / *Not yet*. Microsoft calls it recommended rather than mandatory, so *Not yet* is accepted — but say what it costs: Microsoft writes the detailed validation-failure telemetry there, so without it a rejected submission can't be diagnosed. |

**One more thing to say out loud, once, in Box 3a:** for AppSource, `name`, `publisher`, and
`version` must match the Partner Center offer exactly, so changing any of them later means changing
the offer too.

**Two answers elsewhere in the intake are already settled by `AppSource` and shouldn't be asked as
if they were open:** the analyzer set becomes CodeCop + AppSourceCop + UICop (**Ops § Analyzers**),
and translation files are mandatory regardless of language count (**Standards §8.10**) — so the
`en-US`-only shortcut isn't offered. State both as consequences when the human picks `AppSource`.

### The language questions

Microsoft's live *Country/Regional Availability and Supported Languages* page is the only source for
countries and languages: read it before Box 1, never from memory or a copy, and if it can't be
reached, say so and ask the human rather than guessing.

1. **Languages, per country.** One multi-select question per country from Box 1, up to four per box,
   offering **only the languages Business Central supports in that country**, each shown with the
   three-letter ID BC people recognize and the culture code that gets recorded (*"French (Canada) —
   FRC → `fr-CA`"*). Countries aren't asked again.
   - **Classify each chosen language** per **Standards §8.8** — Microsoft-translated,
     partner-translated, or not supported by BC — and say what that means in one sentence.
     Partner-translated: ask, in the next box, which partner localization or language app the
     customer uses, since it becomes that language's terminology source. Not supported (including
     every right-to-left language): don't offer it; if the human types it, say plainly that BC's own
     interface won't appear in that language and offer the country's English instead, recording it
     as outside platform support only if they insist.
   - **Cross-check against Localization.** If they don't line up — `AU` with no `en-AU`, or the
     reverse — raise the mismatch rather than accepting it.
2. **Source wording**, asked before the per-language questions, because its answer decides whether
   they're asked at all:
   - **Any target other than `en-US` alone:** source wording is Microsoft's W1 English
     (**Standards §8.1**). Say so, with the one-line reason: every market's wording then comes from
     its own translation file.
   - **`en-US` is the only target and the Deployment Target isn't AppSource** (AppSource requires
     translation files, **§8.10**): ask, recommended first — *W1 wording in source, plus an `en-US`
     translation file (recommended)*, so another market later needs no source changes, or *US
     wording directly in source, no translation files*, simpler now but a source rewrite later.
3. **Per target language, two questions** (so two languages to a box): is it **required at first
   release** or can it follow later, and **who reviews it** — offer names the human has already
   mentioned, or *I'll type it*. A named person who reads the language fluently, never a role, never
   the agent (**§8.7**). A partner-translated language's app question joins the same box. Skipped
   entirely for *US wording, no translation files*.
4. **Documents**, only when there's a target language other than the source:
   - *Which user-facing documents are translated into each required language?* (multi-select).
     **Full:** the user guide *(recommended)*, the deployment instructions *(recommended)*, or none.
     **Lite:** `Docs.md`'s user-guide section *(recommended)* or none — Lite has no separate
     deployment document. Engineering documents stay in English only.
   - *Do testers need a translated test script?* *No — they run the language pass from the English
     script, which names the terms each language should show (recommended when testers read
     English)* / *Yes, one per required language*.

   Translated documents are produced at release testing, once the functional pass is green, so a fix
   found in testing doesn't make every translated copy stale.
5. **Beyond the interface**, *No* / *Yes* each, with the specifics of a *Yes* as free text: do
   customer-facing documents (invoices, emails) follow the **customer's** language rather than the
   user's, and does the extension store user-entered text needing **per-language versions**
   (**Standards §8.9**)?

API caption locking isn't asked at intake — no objects exist yet. It's decided at the design step,
once the object inventory does.

---

## Ops § Roles (Full only)

The Full edition can split work across three roles, each potentially a different model. It's
optional: with no answer, everything runs through one model, as if this section didn't exist. The
Lite edition has no role split at all.

The executing agent can't switch its own model mid-session, but it can delegate a self-contained
task to a sub-agent running a different model, get a result back, and act on it. That's the whole
mechanism, and it isn't tied to one harness.

**Asking, once at intake**, as one question with three options:
- ***One model for everything (recommended)*** — no role assignment.
- ***Recommended split*** — name the models this harness actually offers: a capable general model
  for Main, a fast lower-cost model for Light, the strongest reasoning model for Reasoning, High
  thinking effort for all three. Record exactly what was named.
- ***Customize each role*** — then ask each role's **model** and **thinking effort** as two separate
  questions, never merged: one box with the three model questions, then one box with the effort
  question for each role whose chosen model has an effort setting. A role whose model has no such
  setting isn't asked; record `N/A` rather than leaving it blank.

If the harness can't run sub-agents at all — Claude Chat, Microsoft Copilot Cowork, the github.com
cloud agent — don't ask: say everything runs through one model and record `No`.

**What each role is for:**
1. **Main role** — the bulk of the work: all code generation, all actual code edits (including
   applying what the other roles report), and end-to-end ownership of the continuity documents:
   ChangeLog, Object Register, project memory, and the Testing Feedback Log. A capable
   general-purpose model.
2. **Light role** — fast, cheap, checklist-driven verification only: the post-generation pre-flight
   pass in full, including **symbol verification**, which is deliberately not the reasoning role's —
   it's a lookup against ground truth, not a judgment call. Reports findings; never edits code.
3. **Reasoning role** — heavier-reasoning, fresh-eyes work: the Sanity Check, Gap-Fit Test, Code
   Review, FRD and TDD authorship, root-cause diagnosis during the compile-and-package cycle, and
   diagnosing whether a testing-feedback report is real. Reports findings, drafts, or diagnoses;
   never edits code or the continuity documents.

**High is the recommended default thinking effort for all three roles, whichever model holds them.**
This is a quality-first framework: the zero-errors-zero-warnings rule already demands care, and
every role's job benefits from more thinking, not less. Offer High first, with that reasoning. A
human may still choose Medium — most plausibly for the Light role, whose checklist matching gains
least from extra effort — and that's a legitimate, explicit override, not a mistake to argue them
out of. What matters is that the default offered is High; a lower setting is opted into, never
assumed.

**The division of labor is fixed, whichever models are assigned.** The light and reasoning roles
investigate, draft, or diagnose; the main role is the only one that edits code and the only one that
owns the continuity documents. That keeps one consistent author across the codebase and keeps
root-cause tracing in one thread instead of fragmenting across cold hand-offs. A role holder's
output is always relayed back and integrated by the main role, never applied blind.

**Delegating in practice:** hand the role holder the specific inputs its task needs — the relevant
documents, the code or finding in question, the standing checklist — plus a pointer to the runbook
itself, since every rule applies to whichever role is acting. Set that role's configured thinking
effort when the mechanism allows it.

**With the OCPF plugin**, the Light and Reasoning roles ship as ready-made sub-agents, `ocpf-light`
and `ocpf-reasoning` (in Claude Code, `ocpf-bc:ocpf-light` and `ocpf-bc:ocpf-reasoning`). They carry
this division of labor already and are denied file-editing tools. Pass the configured model and
effort where the harness allows a per-delegation override; where it doesn't, tell the human which
model the sub-agent will actually run on.

---

## Ops § Project Setup

Once the human confirms the parameter sheet, and before design begins, the agent sets the project
up. Symbols have to be on disk before any design decision is verified against them, so this happens
at the end of intake, not at the start of BUILD. Nothing here needs the human beyond the AI tool's
own approval prompts.

1. **Write `app.json` once, complete, from the confirmed sheet:** name, publisher, version, every ID
   range, `platform`, `application`, `runtime`, and the `features` the scaffold step lists —
   including `"NoImplicitWith"` and `"TranslationFile"` (**Standards §8.2**). If `app.json` already
   exists (for example the human ran **AL: Go!**), keep its `id` GUID and replace the rest. Don't
   change `idRanges`, `platform`, `application`, `runtime`, or `dependencies` again without
   re-running step 4.
   - **Deployment Target `AppSource` adds mandatory properties:** `brief`, `description`, `url`,
     `privacyStatement`, `EULA`, `help`, `contextSensitiveHelpUrl`, `logo`, `application`, and
     `applicationInsightsConnectionString` where the human gave one — all from the intake's
     AppSource boxes (**Ops § Intake**), written now rather than at release, because a missing one
     is a rejected submission, not a warning (**Standards Appendix E**). Any the human deferred
     stay recorded as release blockers.
2. **Connect the AL tools** if this session doesn't have them (Ops § AL Tools).
3. **Download symbols** (Ops § Symbols). Confirm `.alpackages/` holds the Base Application and
   System Application for the target version, and record where they came from as the sheet's Symbol
   Source. Add `.alpackages/` to `.gitignore` now (Ops § Repository Hygiene).
4. **Keep the editor in sync** (Ops § Editor Sync). If VS Code's AL extension loaded this project
   before the agent changed `app.json`, it still shows the old ID ranges and missing symbols as red
   errors. Refresh now, while no `.al` file exists yet.

---

## Ops § AL Tools

The AL Language extension ships a standalone MCP server (`altool launchmcpserver`) exposing AL
build, publish, symbol, and diagnostic tools over the Model Context Protocol, so any MCP-capable
agent can drive them directly instead of shelling out to the compiler. Nothing runs until an MCP
host spawns it, and it exits when the host tears it down.

**When they're needed:** from the end of intake (Full §1.10 / Lite Step 1), which downloads symbols
before DESIGN — not at the start of BUILD.

**Zero-install first** (runbook Operating Rule 6d). Everything here is already on the machine of
anyone developing AL in VS Code.
- **GitHub Copilot Chat in VS Code:** the extension's tools are built in (`al_build`, `al_publish`,
  `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`, `al_getnextobjectid`,
  `al_symbolrelations`, debugging tools). Bootstrap the server below only for a tool that set lacks,
  such as `al_compile`, `al_run_tests`, or the translation tools.
- **Claude Code, Copilot CLI, or any other MCP host:** bootstrap below, using the extension's
  bundled `altool` and the .NET runtime VS Code already provisioned. If this session already has
  the server's tools, don't register a duplicate; add this project with `al_addproject`.
- **With the OCPF plugin:** its `al-mcp-setup` skill does the bootstrap in one step, copies the
  scripts, adds `al` to `.mcp.json`, and records the outcome as `alMcp` in `.ocpf/framework.json`.
- **Microsoft's `al` .NET tool on NuGet** (`Microsoft.Dynamics.BusinessCentral.Development.Tools`,
  same `launchmcpserver`) is for cloud sessions and machines without VS Code only. Install it in
  the cloud environment's setup script, never by asking the human mid-session.

**The human approves; the agent does everything else.**
- **No Command Palette.** The AL Language extension has no command that sets up or registers this
  server. Its only MCP commands sign in to two other servers, Profiling and Snapshot debugging
  (verified in AL Language extension 18.0's `package.json`).
- **No third-party bridge extensions**, such as the community *AL Language Model Tools — MCP Bridge*
  VSIX: it isn't on the Marketplace and needs VS Code relaunched with a proposed API enabled. Don't
  install, configure, or depend on one. A consultant won't have it.
- **The human's only part** is approving the AI tool's own prompts, including the one Claude Code
  shows once for a new project MCP server.

**Bootstrap once per project** (idempotent — check for an existing registration first):

1. **Get the scripts.** With the plugin, `al-mcp-setup` copies them. Otherwise download them byte
   for byte into the project's `scripts/` folder from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/al-mcp-setup/scripts/<file>`:
   - **macOS or Linux:** `al-mcp.sh`, `al-mcp-call.sh`, `al-analyze.sh`
   - **Windows:** `al-mcp.cmd`, `al-mcp-resolve.ps1`, `al-mcp-call.ps1`, `al-analyze.cmd`,
     `al-analyze-resolve.ps1`

   Add `scripts/` to `.gitignore` (Ops § Repository Hygiene). The launcher finds the newest AL
   extension and its runtime at every launch, so extension updates never break it, and it needs no
   `PATH` edit, no `DOTNET_ROOT`, and no absolute path in any config. **If GitHub isn't reachable,**
   write the equivalent: locate `altool` in the extension's `bin/` folder and run
   `launchmcpserver --transport stdio` — `altool.exe` directly on Windows, `altool.dll` on the
   runtime VS Code provisioned on macOS and Linux.
2. **Check it:** `sh scripts/al-mcp.sh --help` (Windows: `scripts\al-mcp.cmd --help`) prints the
   `launchmcpserver` usage. An `OCPF AL MCP launcher:` message names what's missing instead. If the
   AL extension has never started on this machine, its .NET runtime isn't provisioned yet — the one
   case where the human helps: ask them to open the project folder in VS Code once, where the
   extension starts because `app.json` exists, then check again.
3. **Register it** with a relative path, adding the `al` entry without overwriting other servers.
   Claude Code and Copilot CLI read `.mcp.json` in the project root:
   - **macOS or Linux:** `{ "mcpServers": { "al": { "command": "sh", "args": ["scripts/al-mcp.sh"] } } }`
   - **Windows:** `{ "mcpServers": { "al": { "command": "cmd.exe", "args": ["/c", "scripts\\al-mcp.cmd"] } } }`
   - **Other MCP hosts:** the same command in that host's configuration format.

   **A consequence to document, not paper over:** if that config is committed while `scripts/` is
   gitignored, a fresh clone points at a script that isn't there. Say so in the project's setup
   notes, and re-run this bootstrap on the new machine.
4. **Keep working in this session — no restart.** Claude Code and Copilot CLI load MCP servers when
   a session starts, so a server registered mid-session appears only in the next one. Don't stop,
   and don't ask the human to restart. Until the tools appear, call any of them through the one-shot
   helper, which starts the same server with this project loaded, runs one tool, prints the JSON-RPC
   response, and exits:
   ```
   sh scripts/al-mcp-call.sh . al_downloadsymbols '{"globalSourcesOnly":true}'
   sh scripts/al-mcp-call.sh . al_compile '{"options":{"onlyErrors":true}}'
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\al-mcp-call.ps1 . al_getpackagedependencies
   ```
   Each call reloads the project, so it takes a few seconds. Measured on macOS: symbol download
   under 10 seconds, compile about 5.
5. **Verify** with a call that isn't a compile, such as `al_getpackagedependencies`, or by listing
   the tools once they appear. The first compile belongs to the runbook's compile step, not here.
6. **Signing in:** tools that reach a live BC cloud environment (publish, downloading non-global
   symbols) trigger an interactive sign-in the first time they're used, cached for the session. Log
   out when the task that reached the cloud is done.

**Standing use.** Once registered, prefer the MCP build/publish/symbol tools over an ad hoc
terminal compiler invocation: they're the first-party path and stay current with the extension.
**The one exception is the analysis compile** (Ops § Analyzers). `launchmcpserver` also accepts AL
project paths and flags for package cache path, ruleset, and output folder; check `--help` against
the installed version rather than assuming a fixed flag set, and re-verify tool names and arguments
against the installed version rather than trusting a prior project's notes.

---

## Ops § Analyzers

**The runbook's mandatory compile (Full Step 07 / Lite Step 5) runs with Microsoft's bundled code
analyzers engaged — not a plain compile.** They ship with the AL Language extension; nothing is
installed. Every project runs **CodeCop** and **UICop**, plus exactly one of these, chosen by the
Deployment Target parameter:

| Deployment Target | Third analyzer |
|---|---|
| `SaaS PTE` or `OnPrem PTE` | **PerTenantExtensionCop** |
| `AppSource` | **AppSourceCop** |

- **Never both PerTenantExtensionCop and AppSourceCop.** Microsoft documents their rules as
  incompatible: *"Make sure to enable only one of these at a time."*
- **AppSourceCop needs `AppSourceCop.json`** in the project root — at minimum
  `{ "mandatoryAffixes": ["<prefix>"] }` with the project's AL Object Prefix — or the compile fails
  with `AS0054`, whatever the code looks like.
- **Both files are created at the scaffold step** (Full Step 05 / Lite Step 3):
  `.vscode/settings.json` with `"al.enableCodeAnalysis": true` and `"al.codeAnalyzers"` set to the
  three analyzers above, plus `AppSourceCop.json` when the target is AppSource. The settings also
  give the human live analyzer feedback in the editor.

**What the compile then proves:** `PTE0004` / `AS0103` (a table missing a matching permission set,
**Standards §5.3**), `PTE0008` / `AS0062` ("Page controls and actions must use the ApplicationArea property" — observed
on a page field missing it; API pages don't carry the property, so this lands on UI pages the
project adds),
`AA0074` (a `Label` missing its suffix, **§8.4**), `AA0101` (API names not camelCase, **§2.7**),
`AA0215` (a file not named after its object, **§1.8**), and `AL0424` (deprecated multilanguage
syntax, **§1.7**). It doesn't replace symbol verification (Operating Rule 2), permission set App
Code uniqueness across extensions (**§5.4**), or judgment a compiler can't make, such as caption
quality or the API caption-locking decisions.

**How to run it** — verified on AL Language extension 18.0.2732683. On a newer release, re-verify by
compiling a table with no permission set and confirming `PTE0004` appears:
- **GitHub Copilot Chat in VS Code:** the built-in `al_build`, which reads the
  `.vscode/settings.json` analyzers when its `codeAnalyzers` argument is omitted.
- **Claude Code, Copilot CLI, or any other MCP host: `scripts/al-analyze.*` is the mandatory
  compile, not the AL MCP Server's own tools.** `al_build` never applies analyzers (observed on AL Language
  extension 18.0.2732683; re-verify on a newer release) — whatever is passed as `codeAnalyzers`, as
  the `--codeanalyzers` launch flag, or in workspace settings, even though its schema advertises
  `enableCodeAnalysis` and `codeAnalyzers` — and
  reports `succeeded: true` while packaging code that has analyzer *errors*. `al_compile` does
  apply them, but only when `enableCodeAnalysis: true` **and** a `codeAnalyzers` list of the
  well-known tokens (`${CodeCop}`, `${PerTenantExtensionCop}`, `${UICop}`, `${AppSourceCop}`) are
  both passed **at the top level of `options`** — not wrapped in a `parameters` key, which only
  `al_symbolsearch` takes
  ([AL MCP Server](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/al-agent-tools/al-mcp-server)),
  and not as literal analyzer DLL paths, which return `AD0001` instead of rule results. **Get any
  of that wrong and it returns a clean pass on failing code**, so never read an `al_compile` result
  as a clean build unless the request had exactly that shape. It also produces no `.app`, so it's a
  fast pre-check, never Operating Rule 4's compile-and-package. Run
  `scripts/al-analyze.sh <project folder> <output .app path> [pte|appsource]` instead (Windows:
  `scripts\al-analyze.cmd`, same arguments; the profile defaults to `pte`). The plugin's
  `al-mcp-setup` skill copies it into `scripts/`; otherwise fetch it beside the launcher
  (Ops § AL Tools, step 1).
- **Read the warnings, not just the result.** The compiler succeeds with warnings, and so does
  `al_build`. `al-analyze` exits `0` only with no errors and no warnings, `3` when it compiled with
  warnings, and `1` when the compile failed.

**Zero warnings means zero, honestly.** No `#pragma warning disable` around a real defect, and no
ruleset: the framework ships none, every analyzer rule stays on, and a project that follows the
Standards Guide compiles clean under them. A suppressed or downgraded warning counts as an
unresolved one under the runbook's zero-warnings rule.

---

## Ops § Symbols

**The agent downloads symbols; the human never does.** Stop at the first option that works:

1. **Copilot Chat in VS Code:** the AL extension's `al_downloadsymbols` with
   `globalSourcesOnly: true`. It also reloads VS Code's AL workspace.
2. **Any other agent:** the AL MCP Server's `al_downloadsymbols` with `globalSourcesOnly: true`,
   through the one-shot helper if the server isn't in this session yet (Ops § AL Tools, step 4).
3. **From the sandbox** (`launch.json`, one browser sign-in by the human): when the project depends
   on a non-AppSource app, when the global download fails, or for a localized project outside
   Copilot Chat.

Global sources need no connection or sign-in — verified September 15, 2026 on AL extension 18.0: a
full BC 27 set (System, Application, System Application, Business Foundation, Base Application) in
under 10 seconds. The download takes the newest build of `app.json`'s major version (`27.0.0.0` →
27.5) unless `enforceMinorVersion: true` is set.

**The AL MCP Server's global download is W1 only.** It ignores `al.symbolsCountryRegion`, which VS
Code's own download honors. When Localization isn't `W1`: in Copilot Chat, set
`"al.symbolsCountryRegion"` (for example `"us"`) in `.vscode/settings.json` first. Elsewhere, start
DESIGN on W1 and download from the sandbox before verifying any country-specific table or field.

**What a sandbox download contains.** Full Microsoft packages, not just symbols: on BC 28.4, the
Base Application carried 8,579 Microsoft source files and the System Application carried translation
files for 26 languages. That's Microsoft's proprietary content — read it where it is, never commit
it (**Standards §8.5**, Ops § Repository Hygiene). Symbols from Microsoft's public feed carry no
translation files.

**Confirm symbols by using them** — `al_symbolsearch` for `Customer`, or a compile — never by
unpacking a package's `SymbolReference.json`, which can look far emptier than what the compiler
resolves. Download again after a dependency or version change, then keep the editor in sync
(Ops § Editor Sync).

---

## Ops § Editor Sync

**Symptom:** the extension compiles clean, but VS Code still marks objects red — often an object ID
"not within the allowed ranges" or a missing symbol — until the window reloads. The code is fine;
VS Code's AL language server is working from old information:
- **`app.json` changed on disk** after the AL extension loaded it. The extension doesn't always
  re-read it ([microsoft/vscode#147111](https://github.com/microsoft/vscode/issues/147111)). The
  real case: **AL: Go!** created default ID ranges, then the agent wrote the project's own.
- **Symbols downloaded outside VS Code.** The AL MCP Server reloads only its own workspace; VS
  Code's language server is a separate process and isn't told.

**Prevent:** write `app.json` once, complete, and download symbols at the end of intake, before any
`.al` file exists.

**Detect** after every `app.json` or symbol change and after every clean compile: read the Problems
panel with `al_getdiagnostics` (Copilot Chat, severity `error`) or the IDE diagnostics tool
(`mcp__ide__getDiagnostics`, Claude Code in VS Code). AL errors the latest compile didn't report are
stale. If you can't read the editor, tell the human once, at the first clean compile, what stale
marks look like and how to clear them. At the end of intake there are no `.al` files yet, so if
`app.json` existed before the agent changed it, treat the editor as stale.

**Fix:**
1. **Copilot Chat:** run the AL extension's `al_downloadsymbols` once, then check again.
2. **Otherwise, or if marks remain:** no agent tool can reload VS Code's window. At the end of the
   reply, never mid-task, tell the human in one short message, in the working language: the code
   compiles clean and VS Code is showing old errors; press Ctrl+Shift+P (Cmd+Shift+P on a Mac) and
   run **Developer: Reload Window**, which is built into VS Code. Files aren't touched, and if the
   chat panel closes, reopening it restores the history.

**Never change code that compiles clean just to clear stale marks.**

---

## Ops § Notifications

**The human chooses at intake how to be notified every time the agent finishes a turn, asks a
question, or waits for an approval, and the choice persists** — so no time is lost because nobody
noticed the ball was in their court. Each AI tool's own notifications and hooks do the work. The
agent sets it up; nothing is installed. In documents mode, where no files can be written, say
notifications aren't available and skip this.

### 1. Ask, right after the working language

One multi-select question: *"Would you like to be notified at the end of every turn and whenever a
question or approval is waiting? Choose any."* Offer only what can work here — check the environment
first:

| Option | Offer it when |
|---|---|
| *Claude app* — a push to your phone | Claude Code signed in through a claude.ai Pro, Max, Team, or Enterprise account, with none of `ANTHROPIC_BASE_URL` (pointing anywhere but `api.anthropic.com`), `DISABLE_TELEMETRY`, `DO_NOT_TRACK`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, or `DISABLE_GROWTHBOOK` set. Not with an API key, Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, or a Claude apps gateway. If the sign-in can't be checked, say in the option that it needs a claude.ai subscription, and that on Team or Enterprise an Owner must have enabled Remote Control. |
| *Sound* — a short sound on this computer | Always. On Linux it needs `paplay` or `canberra-gtk-play`; without them it falls back to the terminal bell, which Claude Code's VS Code extension can't ring. |
| *Desktop notification* | GitHub Copilot Chat in VS Code or GitHub Copilot CLI (their own notifications). Claude Code on Windows or Linux, or in iTerm2, WezTerm, Ghostty, Warp, or Kitty on any OS — the terminal's own notification, found from `TERM_PROGRAM`, `KITTY_WINDOW_ID`, or `TERM`, and only when `CLAUDE_CODE_ENTRYPOINT` is `cli`, since the VS Code extension can inherit `TERM_PROGRAM` from the terminal that opened VS Code. Inside tmux the terminal isn't detected. **Not for Claude Code's VS Code extension or VS Code's terminal on macOS:** there's no suitable notification there, and a banner raised from a script opens Script Editor when clicked. |
| *No notifications* | Always. If it's chosen alongside anything else, ask again. |

**With *Claude app*, explain Remote Control before going further:** pushes arrive only while Remote
Control is connected; while it's connected, the session's transcript — messages, responses, and tool
activity — is stored on Anthropic's servers; and organizations with requirements such as Zero Data
Retention can't use it. Then ask: **Only when I turn it on** (run `/remote-control`, or the VS Code
extension's Remote Control command, before stepping away) / **Every Claude Code session on this
machine** (all projects, until turned off in `/config` or the extension's settings: **Enable Remote
Control for all sessions**).

### 2. Record the answer

In `.ocpf/notifications.json` in the project root — per developer, always gitignored
(Ops § Repository Hygiene), whatever the intake said about the framework's other files:

```json
{
  "notifyWhen": "every turn end, question, and approval",
  "channels": ["claudeApp", "sound", "desktop"],
  "remoteControl": "perSession",
  "userSettingsWritten": [],
  "aiTools": ["claude-code"],
  "os": "macos",
  "decidedOn": "2026-09-15"
}
```

`channels` holds any of `claudeApp`, `sound`, and `desktop`, or nothing for *No notifications*;
`remoteControl` is `perSession` or `allSessions`, present only with `claudeApp`;
`userSettingsWritten` lists each user-level setting the agent wrote and its earlier value (step 3);
`aiTools` holds any of `claude-code`, `copilot-chat`, and `copilot-cli`; `os` is `macos`, `windows`,
or `linux`.

**At the start of every session, read it.**
- **Missing** — a developer new to the project, a fresh clone, or a project started before this
  section existed: ask the question before the next step.
- **The current AI tool isn't in `aiTools`:** apply the recorded kinds for this tool, ask only about
  a kind this tool adds, and add the tool to `aiTools`.
- **The human asks to change it:** ask again, undo what the dropped kinds set up, apply the new
  ones, and rewrite the file.

### 3. Apply it, per AI tool in use

| Choice | Claude Code (VS Code extension or terminal) | GitHub Copilot Chat in VS Code | GitHub Copilot CLI |
|---|---|---|---|
| **Claude app** | `"inputNeededNotifEnabled": true` and `"agentPushNotifEnabled": true` in `.claude/settings.local.json`; with *Every session*, also `"remoteControlAtStartup": true` in `~/.claude/settings.json`; and a push from the agent at every turn end (step 4) | — | — |
| **Sound** | Hooks in `.claude/settings.local.json` running `ocpf-notify` with `sound` | VS Code user settings: `"accessibility.signals.chatResponseReceived": { "sound": "on" }` and `"accessibility.signals.chatUserActionRequired": { "sound": "on", "announcement": "auto" }` | Hooks in `~/.copilot/hooks/ocpf-notify.json` running `ocpf-notify` with `sound` |
| **Desktop notification** | The same hooks, with `desktop` added | VS Code user settings: `"chat.notifyWindowOnResponseReceived": "always"` and `"chat.notifyWindowOnConfirmation": "always"`; clicking one opens the chat session | Built in and on by default; nothing to set up |

- **Where each file lives, and what to say.** `.claude/settings.local.json` is this developer's, for
  this project only: merge into it and add it to `.gitignore`. `~/.claude/settings.json`,
  `~/.copilot/hooks/`, and VS Code's user `settings.json` (macOS
  `~/Library/Application Support/Code/User/`, Windows `%APPDATA%\Code\User\`, Linux
  `~/.config/Code/User/`) are outside the project: before writing, say plainly that the setting
  applies to every project on this machine, and that `agentPushNotifEnabled` also syncs to the
  human's Claude account. Then let the AI tool ask. Merge, keeping every existing setting and
  comment. Claude Code honors `remoteControlAtStartup` only from user settings, never from a
  project.
- **The script.** Add `scripts/` to `.gitignore` if it isn't there, then copy `ocpf-notify.sh`
  (macOS/Linux) or `ocpf-notify.ps1` (Windows, untested on Windows) into it — from the plugin's
  `notifications` skill, or byte for byte from
  `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/notifications/scripts/<file>`.
  It takes `sound`, `desktop`, or both (`-Sound`, `-Desktop` on Windows), returns the terminal's own
  notification or bell as Claude Code hook output, runs sounds and Windows notifications in the
  background, and always exits 0.
- **Remember what was written outside the project.** When writing a user-level setting, add
  `{ "key": "<setting>", "previous": <its earlier value, or null if it wasn't set> }` to
  `userSettingsWritten`. If the human already had a different value, ask before replacing it; if
  they had the same value, leave it theirs and don't record it.
- **Removing a kind.** *Claude app*: remove the two push settings, and if `remoteControlAtStartup`
  is in `userSettingsWritten`, put back its `previous` value or remove the key when that's `null`
  (never write `false`, so an organization's default still applies). *Sound* or *Desktop
  notification*: rewrite the Claude Code hooks with only the kinds left, removing them when none
  are, and put back each VS Code user setting the same way. The Copilot CLI hooks read the record
  every time, so they need no change.
- **Not chosen:** leave each tool's defaults alone, and say what still happens: Claude Code notifies
  in iTerm2, Ghostty, and Kitty when it looks like the human is away; Copilot Chat notifies while VS
  Code isn't focused; Copilot CLI notifies while its terminal isn't focused and can be silenced only
  with `COPILOT_DISABLE_DESKTOP_NOTIFICATIONS` — never ask the human to edit a shell profile for it.

Claude Code hooks, macOS or Linux — exec form (`command` plus `args`), so no shell quotes the path.
Keep only the kinds the record chose, one array element each:

```json
{
  "hooks": {
    "Stop": [ { "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.sh", "sound", "desktop", "Your turn: the agent finished"] } ] } ],
    "PreToolUse": [ { "matcher": "AskUserQuestion", "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.sh", "sound", "desktop", "A question is waiting for your answer"] } ] } ],
    "Notification": [ { "matcher": "permission_prompt", "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.sh", "sound", "desktop", "An approval is waiting for you"] } ] } ]
  }
}
```

On Windows, each hook runs PowerShell the same way, with only the chosen switches and each hook's
own message. `-ExecutionPolicy Bypass` lets it run the local script on a default Windows PowerShell
5.1 machine:

```json
{ "type": "command", "command": "powershell.exe", "args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/scripts/ocpf-notify.ps1", "-Sound", "-Desktop", "-Message", "Your turn: the agent finished"] }
```

GitHub Copilot CLI sound hooks (user-level, so each command runs only in a project whose record
chose `sound`; they read `.ocpf/notifications.json` relative to where the CLI starts, so start it
from the project root):

```json
{
  "version": 1,
  "hooks": {
    "agentStop": [
      { "type": "command", "timeoutSec": 15,
        "bash": "grep -qs '\"sound\"' .ocpf/notifications.json && sh scripts/ocpf-notify.sh sound </dev/null >/dev/null; exit 0",
        "powershell": "if ((Test-Path .ocpf/notifications.json) -and (Get-Content .ocpf/notifications.json -Raw) -match '\"sound\"') { & powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ocpf-notify.ps1 -Sound }" }
    ],
    "notification": [
      { "type": "command", "timeoutSec": 15,
        "bash": "grep -Eq '\"notification_type\" *: *\"(permission_prompt|elicitation_dialog)\"' && grep -qs '\"sound\"' .ocpf/notifications.json && sh scripts/ocpf-notify.sh sound </dev/null >/dev/null; exit 0",
        "powershell": "$n = [Console]::In.ReadToEnd(); if ($n -match '\"notification_type\"\\s*:\\s*\"(permission_prompt|elicitation_dialog)\"' -and (Test-Path .ocpf/notifications.json) -and (Get-Content .ocpf/notifications.json -Raw) -match '\"sound\"') { & powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ocpf-notify.ps1 -Sound }" }
    ]
  }
}
```

### 4. With *Claude app*, push at the end of every turn that hands the ball back

Name what the human needs to do — work finished, a result to review, a decision asked in prose (in
Claude Code, the push notification tool). Unlike the other kinds this depends on the agent
remembering, so suggest pairing *Claude app* with *Sound*. Questions and approvals push by
themselves, and Claude Code skips pushes while the human is focused on the session. With *Only when
I turn it on*, remind the human to connect Remote Control before stepping away. Tell them to install
the Claude app, sign in with the same account, and allow its notifications; the phone is theirs to
set up.

### 5. Test once

Trigger each chosen kind and ask: *Did each one arrive, and did clicking a notification take you to
the session?* Fix or drop whatever didn't, and update the record.

**Verified September 2026:** in Claude Code 2.1.272 the `Stop` hook and a `PreToolUse` hook on
`AskUserQuestion` both fired, and the exec-form hooks block ran the script with
`${CLAUDE_PROJECT_DIR}` substituted. From documentation, not tested here: Claude Code's hook
`terminalSequence` output, push settings, and Remote Control requirements (Anthropic); the VS Code
settings and sounds (Microsoft's documentation and VS Code's source); the Copilot CLI's notifications
and hooks (GitHub's documentation and changelog). Claude Code's VS Code extension has no
notifications of its own (anthropics/claude-code issues #57230 and #29928). Windows and Linux weren't
tested. Tools with neither notifications nor hooks (Claude Chat, Microsoft Copilot Cowork) can't
notify: say so and record `"channels": []`.

---

## Ops § Packaging

Packaging starts at the runbook's mandatory compile (Full Step 07 / Lite Step 5) and recurs with
every code change after it. Version bumps stay separately gated.

**Naming and location — fixed, not a judgment call.** Every package is named
`<ExtensionName, spaces → underscores>_<version>.app`, with `name` and `version` read from
`app.json` at build time, never hardcoded or typed by hand. Example: `IP Tracking` at `1.0.0.0` →
`IP_Tracking_1.0.0.0.app`. It goes in a fixed folder named **`outputAppPackage/`** in the project
root — every project, that exact name, never `out/`, `output/`, or anything improvised.

**The tools don't do this by themselves — name the output explicitly.** Left to its default,
`al_build` writes `<publisher>_<name>_<version>.app`, keeping the spaces (verified September 15,
2026: publisher `OCPFReview`, name `OCPF Analyzer Repro` → `OCPFReview_OCPF Analyzer Repro_1.0.0.0.app`).
So pass the full path the framework wants — `outputPath` on `al_build`, the second argument to
`scripts/al-analyze.*` — rather than accepting the default and renaming afterwards.
**Say it twice:** once plainly at intake, before any package exists, and again with the exact path
every time a build completes ("Package built: `outputAppPackage/IP_Tracking_1.0.0.0.app`"), never
buried inside a longer status paragraph. Confirm `app.json` identity, runtime, and dependencies
still match the parameter sheet before every build; it's cheap and catches drift before it reaches
a package.

**Built packages are git-tracked, never gitignored.** Track every `.app` this project builds like
any other deliverable, and never delete its history. Downloaded dependency symbols in
`.alpackages/` are the exception and are always ignored (Ops § Repository Hygiene). Don't add an
`outputAppPackage/` or a blanket `*.app` entry to `.gitignore` at scaffolding; if one is already
there from an older project, remove it and `git add` the packages it was hiding — checking first,
per the untracking caution below, whether a remote would show collaborators a sudden batch of
"new" files.

**Never delete — or overwrite — a package from a *different* version.** A repackage at a new
version writes a new, uniquely named file beside the old ones. It doesn't replace, overwrite, or
"clean up" anything already in the output folder, however superseded it looks. This binds the build
script and the agent alike: no `rm`, no tidying, not even as a pre-build habit. A habitual `rm -f`
before a build deleted a previous version's package on a real project, recoverable only because the
source was tracked. Pruning old packages is a decision the human makes explicitly.

**The protection is per-version, not per-file.** Filenames derive from
`<ExtensionName>_<version>`, so under the "repackage every fix" default, consecutive builds *at the
same version* legitimately write the same filename. That's expected overwriting within an
in-progress version, not the destructive deletion this rule prevents. What must survive is the
package that actually passes release testing: bump its **Build** segment (`0.0.5.0` → `0.0.5.1`) or
copy it to an immutable filename, and say explicitly which package is "the one that passed" rather
than leaving it to be inferred from a timestamp.

**Package by default during the compile-and-package cycle.** Once that cycle opens, every fix that
touches code is recompiled and repackaged before redeploying for the next test round — the rhythm,
not an occasional offer. Outside the cycle, use judgment: a change significant enough for its own
ChangeLog entry and commit is significant enough to offer a fresh package for; a doc-only edit
isn't.

**Version bumps need a proposal and approval — never a silent edit to `app.json`.** Propose a
specific bump with reasoning and wait:
- **Major** — a breaking or structural change, such as renaming the extension or removing something
  a consumer could rely on. Rare, especially pre-release.
- **Minor** — new features, fields, or objects added backward-compatibly. The common case for a
  testing-feedback batch.
- **Build** — the same feature set packaged again: a re-verification build, an environment change,
  or "package this again as-is."
- **Revision** — a small correction or hotfix found while testing a specific package.

**Push back on a premature ask.** Outside the compile-and-package cycle, if asked to package while
known compile errors or an unfinished batch stand, or for a bump that doesn't match what changed (a
one-field tweak billed as Major, a breaking change as a Revision), say so and recommend the right
action instead of silently complying. If the human insists, get an explicit override — but name the
mismatch first. Inside the cycle, packaging with known open issues is the whole point: that's how
they get tested.

**The agent never publishes to a production environment.** Before every publish, read the target
from `launch.json` or the explicit arguments and state it plainly: environment name and type. If it
isn't a sandbox, stop and ask. The agent's own publish tool takes `environmentType`
(`Sandbox` / `Production`), `schemaUpdateMode` (`Synchronize` / `ForceSync` / `Recreate`), and
`forceUpgrade` — so it *can* force a destructive schema change on a production tenant. **Never pass
`ForceSync`, `Recreate`, or `forceUpgrade: true` without a separate approval that names what can be
lost**, and never at all against production. The production deploy at the release step is the
human's, through Extension Management.

**Flag Schema Sync Mode on every completed build, not only when asked.** Uploading a `.app` to a
Business Central Online tenant through **Extension Management** offers **Add** (the default: warns
and refuses an incompatible schema; no data loss) or **Force Sync** (overwrites the schema even when
the change is destructive — removals, a changed primary key, an incompatible type or length change —
and can lose data; Microsoft's guidance is to test a forced sync in a sandbox first). Check what the
build actually changed and say which mode it needs: "This build only adds fields — upload with the
default **Add** sync mode", or "This build removes `<field>` — you'll need **Force Sync**, and it
may lose data in `<what>`." Never assume the human knows, and never let a schema-breaking change go
out without the warning. (`schemaUpdateMode` — `Synchronize` / `Recreate` / `ForceSync` — is the same-named but separate
setting used by `launch.json` for F5 publishing *and* by the agent's publish tool; it isn't the
Extension Management choice, so don't conflate the two when explaining this to the human.)

---

## Ops § Repository Hygiene

Some things a project needs locally are not the client's deliverable and should never reach the
project's own git remote, even though they sit in the working directory like any other file.

**Always kept out of git tracking — not a choice, not asked about per project:**
- **`.claude/settings.local.json`** and **`.ocpf/notifications.json`** — each developer's own Claude
  Code settings and notification choice (Ops § Notifications). Added to `.gitignore` when the
  choice is made, even when the framework's own files are tracked.
- **`standardsGuide/` and `opsGuide/`** — the two fetched companions live inside the project root,
  so each needs its own entry. Added when they're fetched. They're the framework author's
  cross-project methodology, refetchable at will, not part of what the client is paying for.
- **The BCQuality snapshot** — kept outside the project root entirely (Ops § Fetched Companions
  explains why `alc` forces that), so it isn't even a candidate for tracking.
- **`patterns/`** — the fetched patterns library, inside the root but always excluded, for the same
  reason as the Standards Guide.
- **`scripts/`** — the framework's own plumbing: launchers, the one-shot helper, the analyzer
  compile script, the notification script.
- **`*.g.xlf`** — regenerated on every build (**Standards §8.2**). The per-language target files in
  `Translations/` **are** deliverables and always tracked.
- **`.alpackages/`** — downloaded dependency symbols, refetched in seconds (Ops § Symbols), so
  there's no reproducibility reason to track them. A sandbox download also carries Microsoft's own
  source and translation files, which must never be committed (**Standards §8.5**). Microsoft's
  AL-Go templates ignore it too.
- **Microsoft's translation files**, read for terminology (**Standards Appendix D**): read them
  where they are, inside the ignored `.alpackages/`, or extract them outside the tracked tree.

**Gitignored by default, with an intake question:** the runbook itself, its changelog, its
schematics, and the plugin's `.ocpf/` folder — except `.ocpf/notifications.json`, which is always
ignored. The runbook's intake asks this one; both answers are legitimate.

**Always tracked:** the project's own documents, its AL source, `Translations/*.xlf`, and every
package in `outputAppPackage/` (Ops § Packaging).

**If any of this is already tracked** when the policy is adopted: add the entries to `.gitignore`,
then untrack with `git rm --cached` (not `git rm` — the files stay on disk), since an ignore rule
alone does nothing for a file Git already tracks. Check whether the project has a remote first: if
it has, untracking shows collaborators a batch of "deleted" files on their next pull, even though
nothing was deleted locally. Say so plainly before proceeding.

---

## Ops § Translations

How the routine applies **Standards Part 8**. Skip everything here for a project whose parameters
chose *US wording, no translation files*, except the runbook's working-language rule and
**Standards §1.7**.

**The glossary — `docs/TranslationGlossary.md`**, created at intake and current at every step after.
**Lite:** it lives inside `DesignDoc.md` and is created at the design step, not at intake. One row per standard BC concept the extension names: the concept, the
W1 source term, one column per target language, where each term came from (Microsoft file and
version, partner app, or style guide), and its status (`verified` / `reviewer attention`).
- Every row is filled by **Standards Appendix D**, never from model memory.
- Update it the moment a new BC term appears in source text, and again when the as-built documents
  are written.
- It works in both directions: when the human names a concept in their own language, find the
  standard object through it.

### The translation cycle

Part of the compile-and-package cycle, from the first full build onward. The cheap, mechanical work
runs on every build; the work that goes stale whenever captions and messages change waits until the
source text settles.

**Every build that produces a new `.g.xlf`, before packaging:**
1. **Full build only** — Incremental Build off, no RAD publish (**Standards §8.2**).
2. **Sync** every target file in `Translations/` from `.g.xlf` with the agreed tooling (for example
   `Sync-XliffTranslations`). New units arrive as `needs-translation`; changed source text drops its
   unit to `needs-adaptation` (**§8.7**).
3. **Verify terminology** for any BC term new to source text since the last build, per **Standards
   Appendix D** (`al_searchtranslations` first where the AL MCP Server is connected), and update the
   glossary. Terms already in the glossary aren't looked up again.
4. **Run the problem checks** (for example `Test-XliffTranslations -checkForProblems`) and fix each
   finding at its root — often the source label, not the translation. Missing translations aren't a
   finding yet: drafting hasn't run.
5. **Optional, early:** a pseudo-translation pass — a throwaway target file with deliberately longer,
   accented text — surfaces hard-coded strings and truncation before real translations exist. Never
   package it for anyone but the developer.

**Once the source text is stable, draft and test each language.** "Stable" means three moments: the
first build the human confirms clean on the sandbox, again before the compile step closes, and again
after any later fix that changes source text. Drafting earlier only means redrafting every unit a
caption change sends back to `needs-adaptation`.
1. **Draft** every unit in `needs-translation` or `needs-adaptation`, using the glossary, and set it
   to `needs-review-translation`. The agent never sets `signed-off`.
2. **Run the full technical checks** with every rule enabled (for example
   `Test-XliffTranslations -checkForMissing -checkForProblems`) and fix findings at their root.
3. **Package, publish, and test in each language** — the tester switches **My Settings → Language**
   (and **Region** for formats) and walks the changed pages, messages, and reports, looking for
   untranslated text (usually a hard-coded string), truncation, and wrong regional terms.

**Full only — roles.** If the role split is configured, terminology verification is the light role's
(a lookup against ground truth, like symbol verification) and drafting is the main role's, since the
files are deliverables. Approving is never an AI role's.

### Review and approval

- **Each language's named reviewer** approves its translations, either in the tooling directly or by
  telling the agent exactly which units or which reviewed batch they approve. The agent sets
  `signed-off` on exactly those, never on its own judgment (**Standards §8.7**).
- **Log every approval** in the ChangeLog: reviewer by name, language, units approved, date.
- **Bulk approval is fine with a named scope.** In a same-language file (`en-US` → `en-US`) most
  units are unchanged copies: list the unchanged units that contain no glossary term and ask the
  reviewer to approve that list in one decision. Adapted units, and any unit containing a glossary
  term, are reviewed individually.
- **Reviewers work in parallel** from the first drafts through documentation. Approval is required
  only at the release gate.

**The release gate is a state scan, independent of tooling.** Before release testing closes, for
every language required at first release, count the units whose state isn't `signed-off` or `final`.
The gate passes only at zero. It's a plain scan of the XLIFF file, never a tool's own check.

**Source changes invalidate approval:** affected units go back through drafting and review before
the gate can pass again — even during release testing, even for a one-word fix.

**Languages that can follow later** are still synced on every build, so they never fall behind
structurally; drafting and review can wait. Such a language joins the gate for whichever release it
becomes required in — record that in the roadmap (Lite: the ChangeLog).

**Licensing.** XLIFF Sync and NAB AL Tools are MIT-licensed tools the human installs; nothing from
them is copied into a project. Microsoft's translation files are read, never committed. Credits are
in the framework's `THIRD_PARTY_NOTICES.md`.

---

## Ops § Automated Tests

**Scope:** the *offer* of Automated Test Scripts below is **Full only**. *Running AL test
codeunits* at the end of this section applies to **both editions** — Lite Step 6 sends the agent
here.

### Offering Automated Test Scripts (Full only)

At the documentation step, the Full edition asks whether the human also wants **Automated Test
Scripts**, alongside — not instead of — the human unit test script. This is a genuine question, not
a default: automated scripts carry an ongoing maintenance commitment as the app evolves, which a
one-time manual script doesn't.

**"Automated tests" has two genuinely different meanings. Ask which; don't assume the API one.**

- **AL Test Framework (native).** Business Central's own mechanism: a test codeunit
  (`Subtype = Test`) per feature area, with `[Test]`-attributed methods and the platform's test
  libraries (`Library Assert`, `Library - Random`, and the rest), exercising the app's actual business logic — tables, codeunits, pages — directly in AL,
  not limited to what an API happens to expose. Run from the in-client **Test Tool** page during
  development and headlessly in CI (AL-Go for GitHub's test pipeline, or `BcContainerHelper`'s
  `Run-TestsInBcContainer`). Conventionally shipped as its own **test app**: a separate `app.json`
  depending on the extension under test, in a `test/` folder beside the main source, never mixed
  into it. It needs its own object ID range, distinct from the project's, recorded in the Object
  Register like any other range.
- **API-level automation.** External HTTP tooling — a Postman/Newman collection, a Playwright
  suite — exercising the OData surface from outside BC: the same requests the documentation and the
  human test script already describe by hand.

**Ask which of the two, or both.** A project with substantial internal business logic may want AL
test codeunits whether or not it exposes an API at all — it's the only one of the two that can
exercise logic never surfaced through the API, such as a page's own validation, a report, or an
internal codeunit. A project that's mostly a thin API surface over standard tables may get more from
API-level automation.

- **Recommend the AL Test Framework** when the human has no preference and the extension has any
  nontrivial business logic: it's the platform's own idiomatic mechanism.
- **If API-level automation is chosen**, alone or alongside, recommend a **Postman collection** as
  the default: lowest friction for OData testing, with no separate runtime to maintain.
- **For whichever is chosen**, also ask what should trigger a re-run (every build, only before a
  release, or on a CI schedule) and where the artifacts live (this repository or a separate
  test-automation one).
- **If any are created**, write a companion `AutomatedTestScripts.md` — a separate document from the
  human unit test script — naming which kinds were created, what they cover, how to run them, and
  how to keep them current as the app, not just its API, changes.

### Running AL test codeunits: `al_run_tests`

When AL Test Framework codeunits exist and the AL MCP Server is connected, **the agent runs them
itself** — the human doesn't open the Test Tool page to find out whether the build is green.
Verified against the live tool schema on AL Language extension 18.0.2732683 (September 15, 2026);
re-verify on a newer release.

**The call.** Arguments go at the **top level** — no `parameters` wrapper (Ops § Analyzers explains
why that distinction bites). Only `codeunitId` is required:

```
al_run_tests  { "codeunitId": 60310,
                "projectPath": "<project folder>",
                "environmentName": "<sandbox name>",
                "environmentType": "Sandbox",
                "company": "<company>" }
```

- **Name the target explicitly, every time.** `codeunitId` is the only required argument, so
  everything about *where* the tests run comes from what else is passed — never from a default.
  `projectPath` is the tool's own documented route to the connection ("Optional project folder
  path. Used to read connection settings from `launch.json`"), and it's the least error-prone
  source because `launch.json` is the file the human already maintains. Pass `environmentName` and
  `environmentType` alongside it and state the resolved target out loud before running, rather than
  trusting whichever environment the server would otherwise pick.
- **One codeunit per call.** `codeunitId` is a single integer, so the agent iterates the test
  codeunits in the Object Register and aggregates the results itself. `testMethods` narrows a run
  to named methods while fixing one failure — never for the run that reports the build green.
- **Other arguments**, all optional: `company`, `tenant`, `authentication`
  (`AAD` | `Windows` | `UserPassword`), `useInteractiveLogin` (default `true` — it opens a browser),
  `noCache`, and for on-premises `serverUrl`, `serverInstance`, `port`. The tool also reads
  `BC_SERVER_URL`, `BC_SERVER_INSTANCE`, `BC_SERVER_PORT`, `BC_SERVER_USERNAME`, and
  `BC_SERVER_PASSWORD` from the environment.
- **It returns a pass/fail summary with detail for failures** — read the failures, don't report the
  summary line alone.

**`environmentType` is never `Production`.** Tests write data. The same rule as publishing applies
(Ops § Packaging): state the target environment before running, and if `launch.json` points at
production, stop and ask rather than passing an override.

**Where it fits.** The tests run after a clean analyzer compile and a successful publish, as part of
the runbook's testing step — not instead of the human unit test script, which covers what a person
must see in the UI. **A failing test codeunit fails the step**, exactly like a compiler error: it's
fixed, not annotated.

**When the server isn't connected**, or sign-in was skipped, say so plainly and leave the test run
to the human with the codeunit IDs listed — never report untested code as tested.

---

## Ops § Fetched Companions

Three bodies of knowledge are fetched into (or beside) each project, so the agent reads them from
disk rather than from memory: this framework's **Standards Guide**, the **BCQuality** snapshot, and
the **OCPF BC AL Patterns** library. **This Operations Guide is fetched the same way** — the runbook
says when. All four are refetchable at will, so none is ever committed (Ops § Repository Hygiene),
and each carries a small `SNAPSHOT.json` recording the source repo, ref, commit SHA, and fetch
timestamp, so a later refresh has something to diff against and report. **Tell the human before
fetching; none of these is a silent background download.**

### The Standards Guide and this guide

Fetched at the routine's first step, before anything else needs them, from
`https://github.com/ajansari/ocpfBcAgenticDevFramework/`: `standardsGuide/ocpfALDevStandardsGuide.md`
into `standardsGuide/`, and `opsGuide/ocpfOperationsGuide.md` into `opsGuide/`. Both live **inside**
the project root — they're single Markdown files with no `.al` objects, so nothing forces them
outside — and both are always gitignored, not a per-project choice.

- **Neither is optional.** The runbook cites **Standards §** and **Ops §** from its first steps on,
  so a missing copy is a real gap, not a degraded-but-workable state. If the repository isn't
  reachable, say so plainly and ask the human for a copy rather than working from memory.
  **Exception with the OCPF plugin:** it bundles copies. Use them, record
  `"source": "ocpf-bc plugin bundle"` and the bundled version in `SNAPSHOT.json`, say plainly which
  version was used, and offer a refresh once the network is back.
- **Refresh only when the human asks** ("refresh the standards guide", "get the latest ops guide").
  Re-run the fetch, overwrite, and report: "updated from `<old sha>` to `<new sha>`", or "already up
  to date."
- **Version skew is named, not papered over.** Each guide carries its own version, tracked in
  `RunbookChangelog.md` alongside the runbook. If a fetched guide's version doesn't match what the
  runbook expects, say so rather than silently reconciling a citation that doesn't resolve.

### BCQuality knowledge snapshot

BCQuality (`microsoft/BCQuality` on GitHub) is a curated knowledge base and skill library for BC AL
code quality — not an MCP server, not an endpoint: Markdown knowledge files (the non-obvious
platform rules, CodeCop specifics, security, performance, and privacy footguns) plus skills defining
how an agent should search and apply them during review. It augments review judgment; it doesn't
replace it, and the agent's own findings still count without a knowledge-file citation.

- **Fetch once per project, at the scaffold step** (Full Step 05 / Lite Step 3), as a shallow clone
  (`git clone --depth 1`) with `.git` stripped — a content snapshot, not a live checkout. **Never
  strip its `LICENSE`:** BCQuality is MIT-licensed, and MIT requires the notice to travel with every
  copy.
- **Put it OUTSIDE the AL project's root** — a sibling folder such as `../<ProjectName>.bcquality/`,
  never under the same tree as `app.json`. This isn't a style preference: `alc` recursively compiles
  every `.al` file under the project root, and BCQuality ships illustrative `.good.al`/`.bad.al`
  fragments that aren't compilable objects. A real project nested it inside and a previously working
  compile produced 470+ errors, none of them in its own files. BCQuality's own documented
  integration pattern also uses two separate directories.
- **Nothing to gitignore:** it isn't inside the tracked tree at all, which is a stronger guarantee
  than an ignore rule. There's also no reason for a client's repository to carry an 806-file
  third-party knowledge snapshot.
- **Don't install it as a plugin**, and don't share one long-lived copy across unrelated projects —
  that's how it goes stale for all of them at once.
- **Refresh only on request.** The repository is under active development, which is exactly why
  refreshes are human-triggered.

**Using it** — a documented protocol, not something to improvise. Verify against the snapshot's own
`docs/agent-consumption.md` before relying on any paraphrase, including this one:
1. Read `skills/entry.md` from the snapshot and follow it with an explicit task context (goal,
   inputs, technologies, BC version, enabled layers), resolving BCQuality's own instructions against
   the snapshot root and the review target against the project's files. Entry returns a **dispatch
   record** naming which action skills to run; on `no-match` or `failed`, return that record as-is
   rather than inventing a review.
2. Read the meta-skill contracts (`skills/read.md`, `skills/do.md`; `skills/write.md` only when
   authoring knowledge) on demand, not upfront.
3. Invoke each dispatched action skill from the snapshot's layers — for a full review, typically
   `microsoft/skills/review/al-code-review.md`, which composes per-domain leaf skills (security,
   performance, privacy, style) from the snapshot's layers (`microsoft/skills/`,
   `community/skills/`, `custom/`).
4. Each action skill runs Source → Relevance → Worklist → Action, filtering knowledge files by
   frontmatter (`bc-version`, `domain`, `technologies`, `countries`, `application-area`) across
   every enabled layer, higher-precedence layers suppressing lower ones. A
   prebuilt `knowledge-index.json` speeds discovery when present; without it, skills fall back to
   path-based discovery and review still works.
5. Findings come back in `do.md`'s shape: an outcome (`completed` / `not-applicable` /
   `no-knowledge` / `partial` / `failed`), a `domain` label, structured `references` for
   knowledge-backed findings, an empty `references: []` for the agent's own (capped at `medium`
   confidence), and a `suppressed` list of anything layer precedence overrode. Integrate them like any other Code Review finding — never
   applied blind.

No network access is needed once the snapshot exists.

### OCPF BC AL Patterns library

`ajansari/ocpfBCALPatterns` on GitHub (<https://github.com/ajansari/ocpfBCALPatterns>, public —
confirmed reachable September 13, 2026 via `git ls-remote`, not assumed) is the framework author's
own curated collection of reusable
BC AL patterns, each extracted from a real bug found and fixed on a past project and then
generalized: symptom, verified root cause, the fix, a worked example, and caveats, one self-contained
Markdown file per pattern. Where BCQuality is a third-party platform-wide knowledge base, this is
the human's own portable material, meant to grow with every new recurring bug class.

- **Fetch once per project, at the scaffold step**, the same way as BCQuality: shallow clone, `.git`
  stripped, `LICENSE` kept, `SNAPSHOT.json` written.
- **This one lives INSIDE the project root**, in `patterns/` — every file is Markdown with embedded
  AL, not a real `.al` object, so there's no compile-breaking risk — and it's always gitignored.
- **If the repository isn't reachable, say so and continue.** An absent patterns library isn't a
  blocker.
- **Merging, not overwriting.** If `patterns/` doesn't exist, create it. If it exists and already has
  its own `README.md`, append the fetched README under a fixed delimiter rather than replacing it:
  ```
  ---
  ## Upstream README — ajansari/ocpfBCALPatterns @ <commit SHA>
  ```
  That delimiter makes a refresh idempotent: replace the block from that heading to the end of the
  file instead of appending a second copy. Add any pattern files not already present; if a
  same-named file exists locally with different content, ask which to keep rather than overwriting.
- **Refresh only on request**, with the same merge behavior, and report what changed.

**Using it:** before diagnosing a bug from scratch, check whether `patterns/` already documents this
class of problem — that's the entire point, turning a previously solved bug into fast recognition
instead of fresh investigation. If a fix here looks like it will recur on future projects, flag it
to the human as a candidate for a new pattern; contributing back is their call, not the agent's.

---

## Ops § Reference Sources

Alongside the fetched companions (Ops § Fetched Companions) and the AL tools, the framework grounds
its work in these. None are fetched into the project — they're consulted online, so there's nothing
to bootstrap, gitignore, or refresh. **If the agent has no web access, say so plainly** rather than
answering from memory of what a reference says.

| Reference | What it's for | Where the routine uses it |
|---|---|---|
| **BC Base Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application> | Every standard Base App table, field, and datatype/size | Operating Rule 2 fallback; **Standards Appendix B** |
| **BC System Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application> | The System Application modules (Language, Translation, Email, Telemetry, and others) — check here before building something the platform already provides | Operating Rule 2 fallback; **Appendix B**; design |
| **Working with translation files** — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files> | How XLIFF translation works in AL; why ML properties are banned | **Standards §1.7**, Part 8 |
| **Country/Regional Availability and Supported Languages** — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations> | Where BC is available, who localizes each country, which languages Microsoft or partners translate. **Read live every time**, never from memory or a copy | Intake languages; **Standards §8.8** |
| **Microsoft Terminology Collection** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-terminology> | Microsoft product terminology in about 100 languages, when BC's own files have no match | **Standards §8.5**, Appendix D |
| **Microsoft Localization Style Guides** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides> | Tone, formality, punctuation, and formats per language | **Standards §8.5**, Appendix D |
| **AL Guidelines** — <https://alguidelines.dev> (source <https://github.com/microsoft/alguidelines>, MIT) | Community-driven, Microsoft-hosted AL best practices, design patterns, and agent-oriented *Vibe Coding Rules* | Design (patterns beyond the Standards Guide); Code Review |

**Precedence.** The downloaded symbol file beats Microsoft Learn on anything symbol-verifiable. The
Standards Guide beats AL Guidelines on any AL rule. Surface a conflict rather than silently
reconciling it. **AL Guidelines' legacy *C/AL Coding Guidelines* pages are never followed**
(**Standards §1.7**).

**Credit.** Every third-party resource this framework references, fetches, or recommends — with its
license and what that license asks — is listed in `THIRD_PARTY_NOTICES.md` in the framework
repository.

---

## Ops § Plugin

The framework is also distributed as an agent plugin, `ocpf-bc`, from the same repository
(`agentPlugin/ocpf-bc`, listed in `.claude-plugin/marketplace.json`). It works in Claude Code, the
Claude apps, GitHub Copilot (VS Code, Copilot CLI, github.com), and Microsoft Copilot Cowork. It's
**optional**: copying the runbook into a project by hand, as `CLAUDE.md` or
`.github/copilot-instructions.md`, is fully supported and behaves the same.

**This section applies only when `.ocpf/framework.json` exists in the project root.** The plugin's
`start` skill creates it, recording the edition and runbook version, where the copies were placed
(`placedAs`), the source and commit they came from, the plugin version, any version the human chose
to skip (`declinedUpdateVersion`), and the AL tools outcome (`alMcp`). Without that file, skip this
section entirely. The `.ocpf/` folder follows the intake answer about framework files, except
`.ocpf/notifications.json`, which is always gitignored.

**Framework update check, once per session,** before resuming work:
1. Read `runbookVersion` and `declinedUpdateVersion` from `.ocpf/framework.json`.
2. Read the `**Version:**` line of the latest published runbook. **Fetch only the first kilobyte** —
   the version line is inside it, and the whole runbook is tens of thousands of words:
   `curl -fsSL -r 0-1023 <url>` (verified September 15, 2026: GitHub's raw host honors the range and
   returns 1,024 bytes). If a host ignores the range and sends the whole file, read the line and
   discard the rest — never summarize it.
   - Full: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/BC_App_Build_Routine_Agent.md`
   - Lite: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_BC_App_Build_Routine_Agent.md`
3. Compare numerically, part by part.
   - **Newer, and not the skipped version:** say so in a sentence or two and offer **Update now /
     Not now / Skip this version**. **Raise it at a step boundary, not mid-step** — an update that
     lands between two Actions of one step is the one most likely to change the rules under work
     already half-done. When a session resumes mid-step, hold the offer until that step's exit gate
     is met rather than dropping it. "Update now" follows the plugin's `update-framework` skill:
     summarize the changelog entries in between, flagging any that touch a completed step; back up
     each current copy to `.ocpf/previous/`; replace every copy in `placedAs`, the project's runbook
     changelog, and the fetched companions the new version expects; update the marker; record it in
     the ChangeLog and project memory; then re-read the runbook before continuing.
   - **Current:** say nothing.
   - **GitHub unreachable:** one line, then carry on.

**Never replace the project's runbook without an explicit yes.** A project keeps the rules it
started with until the human chooses otherwise.

**What else the plugin changes:**
- **Fetched companions:** bundled copies of the runbooks, this guide, and the Standards Guide are
  used when GitHub is unreachable (Ops § Fetched Companions).
- **AL tools:** the `al-mcp-setup` skill does the bootstrap in one step (Ops § AL Tools).
- **Notifications:** the `notifications` skill sets them up, or adds them to an older project
  (Ops § Notifications).
- **Sub-agents:** `ocpf-reasoning` and `ocpf-light` carry the Full edition's Reasoning and Light
  roles (Ops § Roles).
- **Other skills:** `status` reports where the project stands; `al-standards` answers ad hoc AL
  questions from the Standards Guide.

**Optional github.com reviewer.** The repository also ships a GitHub Copilot custom agent,
`agentPlugin/github/agents/ocpf-code-reviewer.agent.md`. It reviews the extension against the Code
Review step and the Standards Guide, writes `CodeReview.md`, and never edits AL.
- **Offer it once**, at Code Review, if the project is hosted on GitHub and the team uses Copilot.
- **If the human wants it:** copy the file into the project's `.github/agents/`. That file **must be
  tracked** in git, or github.com can't see it.
- **Its report is an input like any other finding:** the main role still applies every fix through
  the compile-and-package cycle.
