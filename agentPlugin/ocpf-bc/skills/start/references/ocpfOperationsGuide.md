# OCPF BC Agentic Development Framework — Operations Guide

## OnlyCopilotFans Agentic Dev Framework for BC Consultants

**Version:** 5.9.5.0 (since 5.0.0.0 the Full and Lite runbooks, this guide, and the plugin share one version number, and since 5.5.0.0 the Build-a-Feature journey carries it too — it has no runbook of its own, so a feature project's marker records this guide's version; the previous version of this guide was 2.0.1.0)
**Last Updated:** October 21, 2026

> **Relationship to the runbooks.** This guide is the shared companion to
> `fullVersion/BC_App_Build_Routine_Agent.md` and `liteVersion/LITE_BC_App_Build_Routine_Agent.md`.
> **The runbook drives the sequence** — what happens when, who signs off, which gate opens the next
> step. **This guide holds the procedures that sequence uses**: how the agent asks, sets the project
> up, runs the tools, packages, notifies, and keeps the repository clean. Both editions share it
> unchanged; where an edition differs, the difference is marked **Full:** or **Lite:** in place.
>
> The runbooks cite it as **Ops §**. The third document, the **OCPF AL Development Standards Guide**
> (`ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`, published standalone at
> <https://github.com/ajansari/ocpfBCALStandards> and fetched at a pinned tag — Ops § Fetched
> Companions), holds the AL rules, cited as **Standards §**. Since
> runbook v4.0.0.0 / Lite v3.0.0.0 the runbook's step text lives in per-step files (`ocpfFramework/runbookSteps/`)
> and every document has a template (`ocpfFramework/documentTemplates/`), both fetched with this guide (Ops §
> Fetched Companions). Since runbook v5.0.0.0 / Lite v5.0.0.0 (this guide's v5.0.0.0) **everything the
> framework fetches or keeps lives in one folder, `ocpfFramework/`, in the project root** — the guides, the
> step files, the templates, the patterns library, the scripts, the plugin's marker, and each developer's own
> state under `ocpfFramework/state/` — and the project documents live in numbered phase folders under
> `docs/` (Ops § Project Setup, Ops § Repository Hygiene).
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
| Which model does what — the Main model (both editions) and the Light/Reasoning split (Full) | Ops § Roles, below |

---

## Ops § Contents

1. [Asking and Approvals](#ops--asking-and-approvals)
2. [Intake](#ops--intake)
3. [Roles](#ops--roles-full-only) *(the Main model in both editions; Light and Reasoning are Full only)*
4. [Project Setup](#ops--project-setup)
5. [Object IDs](#ops--object-ids) *(unique per object type — a table, a page, and a codeunit may all be 50100; every type starts at the bottom of the block)*
6. [AL Tools](#ops--al-tools)
7. [Tooling Checks](#ops--tooling-checks) *(mermaid and PowerShell 7 — the same zero-install ladder)*
8. [Analyzers](#ops--analyzers)
9. [Symbols](#ops--symbols)
10. [Editor Sync](#ops--editor-sync)
11. [Notifications](#ops--notifications)
12. [Packaging](#ops--packaging)
13. [Repository Hygiene](#ops--repository-hygiene)
14. [Translations](#ops--translations)
15. [Automated Tests](#ops--automated-tests) *(the Scripts offer is Full only; the human runs the AL tests in both)*
16. [Fetched Companions](#ops--fetched-companions)
17. [Documents](#ops--documents)
18. [Help Site](#ops--help-site) *(the polished HTML documentation and support page built from the documents — offered at Full Step 11 / Lite Step 6, never by Build-a-Feature; GitHub Pages serves `docs/`)*
19. [Usage & Cost](#ops--usage--cost)
20. [Dashboard](#ops--dashboard)
21. [Journeys](#ops--journeys) *(Build-a-Feature, Full, or Lite — which one, and why; Full recommended; what to put in `requirements/` and `images/`)*
22. [Build-a-Feature](#ops--build-a-feature) *(the quick-mod journey: no steps, six short documents in a flat `docs/`, written as the work happens)*
23. [Existing Apps](#ops--existing-apps) *(an undocumented app is analyzed and documented into `requirements/existing/` before any journey extends it)*
24. [Reference Sources](#ops--reference-sources)
25. [Plugin](#ops--plugin)

---

## Ops § Asking and Approvals

The runbook's Operating Rule 6 says *when* to pause and *what* needs approval. This section says
*how* to ask, and how far to look before asking the human to install or configure anything.

### The mechanism, per harness

Every decision — including every intake question, and every value only the human knows — goes
through the harness's selectable-options mechanism, with the recommended option first and a short
reason on each. Never an open-ended question or a numbered list in chat.

- **Claude Code — `AskUserQuestion`:** up to four questions per box, 2–4 options each, a free-text
  *Other* added automatically, and multi-select where several answers apply. The four-question cap
  is a hard limit of the tool: a set that needs more (the six model-and-effort questions, Ops §
  Roles) is split into consecutive boxes, never trimmed.
- **GitHub Copilot Chat in VS Code — the `askQuestions` tool:** several questions in one carousel,
  each single-select, multi-select, or free text.
- **GitHub Copilot CLI — the `ask_user` tool:** a choice question there takes no typed answer, so
  add an explicit *I'll type it* choice and follow it with a free-text question.
- **Anything else:** its closest equivalent, one question at a time if that's all it offers. Only
  when a harness has no question mechanism at all, ask one question per message with its options
  labelled, and say why.

**Option counts:** 2–4 options per question. With a single suggestion, pair it with *I'll type it*;
with more than four candidates, offer the four most likely and say the rest can be typed.

**Every step close goes through it; progress inside a step does not.** The end of every step and
every phase — Full PRE-01 through Step 12, Lite Steps 1 through 7 — closes with one box, **Proceed
into Step <next> now (recommended)** / **Stop here** (runbook Rule 6c), sent after the usage rows
are pasted and before anything of the next step starts. The one exception is the final hand-off
(Full Step 11 → 12, Lite 6 → 7), which has its own two-option box in the step file. A clean
compile mid-round, a batch's pre-flight result, or a draft handed back part-way through a step is
conversation, not a decision — wrapping those makes the box noise. (Through v5.0.0.0 the rule
applied only to the PROVE steps; a real run on v5.0.0.0 closed Steps 1–7 with a prose prompt and
stalled, which is why the box is now mandatory at every step.)

### Interrupted and resumed — the box comes back (runbook Rule 6e)

Escape in Claude Code dismisses an `AskUserQuestion` box with no answer recorded; Copilot's
`askQuestions` and `ask_user` can be cancelled the same way; a session can be closed on any of
them. None of that changes how the agent asks. On "continue", "resume", a named step, or the
`status` skill followed by "go on":

1. **Find what is still unanswered, from files, not memory:** intake answers in
   `docs/1-define/ProjectParameters.md` and `app.json`; decisions in sign-offs and
   `docs/0-project/ProjectMemory.md` (Full) or the ChangeLog and `docs/2-design/DesignDoc.md`
   (Lite); the open step in `ProjectProgress.md` and
   `ocpfFramework/state/usage.json` (a step with `startedAt` and no `completedAt` is mid-step; a
   step with `completedAt` whose next step has no `startedAt` is at a boundary).
2. **Re-ask every unanswered question through the mechanism above**, in the same box form, the
   already-answered ones skipped. An interrupted intake resumes at its first unanswered question. A
   resume at a boundary **always** starts with that boundary's Rule 6c box, sent again — nothing
   records whether it was answered or dismissed, so it is never inferred. A dismissed approval is
   asked again before the gated action. The once-per-session framework update check (Ops § Plugin)
   runs first, as its own box; the re-asked box follows it.
3. **Carry on under the same rules** — the Rule 6c box at the end of this step and every later
   one, the usage ritual, the approval gates. "Continue" reopens the routine; it answers nothing.

Both editions apply this identically (Full Rule 6e, Lite Rule 6e).

### GitHub Copilot session settings

Two VS Code settings decide how often a Copilot agent-mode session stops and waits for the human.
Both are asked **once, at the routine's first step, right after the model questions**, whenever
GitHub Copilot is one of the AI tools on the project (`ocpfFramework/framework.json` → `placedAs` names
`.github/…`, or the runbook was placed there by hand). Skip both in a project that uses Claude Code
alone — its permission prompts are its own, and the `notifications` step already covers them.

**1. The agent-mode request limit.** `chat.agent.maxRequests` caps how many requests one agent turn
may make before Copilot stops with *"Copilot has been working on this problem for a while. It can
continue to iterate, or you can send a new message…"* (VS Code's reference documents the default as
25; some builds show 50). A DESIGN step or a compile-and-fix round routinely needs more. Ask:

> *How many requests may a Copilot agent turn make before it pauses to ask you?* — **150
> (recommended)** for this framework's longer steps / **100** / **Leave VS Code's default**.

This one always goes to the **workspace's** `.vscode/settings.json` (create it if absent; merge,
never overwrite other keys — the analyzer settings live in the same file from Step 05 / Lite Step 3
onward). It changes nothing about what runs without approval, so sharing it with collaborators is
harmless.

**2. Tool approvals.** VS Code asks before every terminal command, file edit outside the workspace,
and URL fetch, with *Allow in this Session / Workspace / Always* choices in its own dialog — nothing
in chat can pre-answer that dialog. What the agent can do is write the settings that back it. Ask:

> *How should Copilot handle tool approvals on this project?* — **Ask each time (recommended when
> the project is a client's)** — VS Code's default, nothing written / **Allow the framework's own
> commands** — only the commands this runbook runs are approved without asking; everything else
> still asks / **Allow everything** — `chat.tools.global.autoApprove`, which VS Code's settings
> reference describes as disabling critical security protections: say that in the option, and
> record who chose it.

**Where the approval keys go is a trust decision, so ask before writing them.** An auto-approve
rule in a tracked `.vscode/settings.json` applies to every collaborator who opens the project. So,
for *Allow the framework's own commands* and *Allow everything* only:

> *`.vscode/settings.json` may be committed with the project. Should this approval choice apply to
> everyone who opens it?* — **No — just me on this machine (recommended)** — written to VS Code's
> **user** settings (the same file Ops § Notifications step 3 writes for Copilot Chat sounds; say,
> as there, that it applies to every project on this machine) / **Yes — everyone, in the workspace
> file** — written to `.vscode/settings.json`, and the ChangeLog entry names who decided.

**The *Allow the framework's own commands* block** — the commands the runbook itself runs and
nothing that can run something else:

```json
{
  "chat.tools.terminal.autoApprove": {
    "git": true,
    "ls": true, "cat": true, "find": true, "grep": true, "head": true, "tail": true, "wc": true,
    "mkdir": true, "cp": true, "mv": true,
    "/^(sh|bash|pwsh|powershell)(\\s+-\\S+)*\\s+(\\.[\\/\\\\])?ocpfFramework[\\/\\\\]scripts[\\/\\\\][A-Za-z0-9._-]+(\\s+[^;&|`$<>]*)?$/": { "approve": true, "matchCommandLine": true },
    "/^(\\.[\\/\\\\])?ocpfFramework[\\/\\\\]scripts[\\/\\\\][A-Za-z0-9._-]+\\.(sh|cmd)(\\s+[^;&|`$<>]*)?$/": { "approve": true, "matchCommandLine": true },
    "/^curl(\\s+-[A-Za-z]+)*\\s+https:\\/\\/(raw\\.githubusercontent\\.com|api\\.github\\.com|github\\.com)\\/[^\\s;&|`$<>]*(\\s+-o\\s+[^\\s;&|`$<>]+)?$/": { "approve": true, "matchCommandLine": true }
  }
}
```

What it allows, and why it is safe to allow: `git` and the read-only inspection commands; `mkdir`,
`cp`, and `mv`, which write but only inside the workspace; the framework's own scripts in
`ocpfFramework/scripts/` — the AL MCP launchers, the one-shot helper, the analyzer compile, the notification
script — matched as whole command lines that name that folder (`ocpfFramework[\/\\]scripts[\/\\]`, either
separator, an optional `./` in front) and end at the script's arguments, so nothing can be chained
after them and no other `scripts/` folder is approved by accident; and `curl` **only** against the framework repository's raw files and GitHub's
API, with the whole command line matched so `&&`, `;`, `|`, backticks, and `$(…)` can't ride along
(VS Code denies bare `curl` by default; this re-allows just that shape). **Never** `bash -c`,
`pwsh -c`, `python3`, `node`, `dotnet`, or any interpreter given a string: each of those would let
a deny-listed command through inside the string. `rm`, `rmdir`, `kill`, `chmod`, `eval`, and
`wget` stay on VS Code's deny list.

*Ask each time* writes nothing beyond `chat.agent.maxRequests`. *Allow everything* writes
`"chat.tools.global.autoApprove": true` and nothing else.

**Record the answers in `ocpfFramework/state/copilot.json`**, per developer, always gitignored:

```json
{
  "maxRequests": 150,
  "toolApprovals": "framework-commands",
  "approvalsScope": "user",
  "settingsFiles": [".vscode/settings.json", "<user settings path>"],
  "decidedBy": "<name>",
  "decidedOn": "2026-09-19"
}
```

`toolApprovals` is `ask`, `framework-commands`, or `all`; `approvalsScope` is `user` or
`workspace` (absent for `ask`). **At the start of every Copilot session, read it**: if it's
missing, ask before the next step; if a settings file has lost the keys, rewrite them and say so.
Setting IDs verified against VS Code's *AI settings reference* on September 19, 2026; if VS Code
rejects a key, say so and fall back to asking the human to set it in the Settings UI — the only
place in this framework that ever sends the human to a settings page.

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

**Forbidden sources — two values come only from a box the human answered in this project, and are
recorded with that source.** The **publisher** is never taken from `git config user.name` or
`user.email`, an email domain, the machine's user or company name, a folder name, a publisher seen
in another project or remembered from a previous session, a previous `app.json`, or the AL
template's `Default publisher`; it is a name the human typed or chose, quoted with the box and the
date (`publisherSource` in the record — `docs/0-project/ProjectMemory.md` in Full, the parameter row
in Lite, `ocpfFramework/state/feature.json` on Build-a-Feature). The **object ID range** is never
kept silently from `app.json` and never assumed from a scaffold; it is a range the human chose or
typed in the range question, and `50100–50149` is offered only as *the AL template's default — only
if no range has been assigned to you*, never first and never pre-selected (`idRangesSource` in the
same record). **No object ID is allocated until the range's source names a box**, and `app.json`'s
`publisher` is not written until the publisher's source does. Why: on real Build-a-Feature runs the
agent wrote a publisher it had seen in the human's email domain, and allocated IDs from the
scaffold's default range — both had to be undone, and both were "obvious" to the agent.

**What the human can prepare, and where it goes** (said once, in the first message of any
journey, when the folders are empty): raw requirements belong in **`requirements/`** — `.md`
files are recommended; Word, PDF, and images are read too — and an app icon in **`images/`**. The
better formed and documented the material, the faster the first stage goes: a complete
`requirements/` folder pre-fills the intake and the problem statement, and the icon question
offers the file it finds. An existing app's reverse-engineered record lives in
`requirements/existing/` (Ops § Existing Apps).

**Box 0 — Identity first, at the routine's first step.** Since v5.2.0.0 the three questions that
name the app are asked at **PRE-01 / Lite Step 1, right after the notification question and before
the model questions** — not in the intake sheet's Box 1 — and `app.json` is written the moment they
are answered (a first write: `name`, `publisher`, `logo`, `version` `0.0.0.1`, `id`, platform
defaults; Ops § Project Setup step 1 rewrites it complete after the sheet is confirmed, keeping
those values). Why: the dashboard (Ops § Dashboard) is created right after and shows the app's name
and icon from `app.json`. One box, three questions: **Extension name?** (up to three suggestions
from the human's own wording, each labelled a suggestion, plus *I'll type it*); **Publisher?** (only
a name the human has already written or uploaded, quoted with its source; else *I'll type it* —
never inferred from anything (*Forbidden sources*, above); an inferred publisher once forced a
full-project rename); **App icon?** (four options at most, in this order: **when `images/` holds an image file, that file
by name — *Use `images/<file>`*** — then *Yes — I'll provide an image* (the path as free text with
the guidance under *The app icon* below; the agent places and resizes it), ***Create one for me*** —
the plugin's `app-icon` skill draws it to the standard below and shows it before anything is written
(*The app icon → Creating one*) — and *No icon*; *Later* is typed in the free-text entry when the
human wants it, and for AppSource *No icon* is not offered and *Later* is a release blocker). The sheet's Box 1 and Box 1a then **record** these three answers and do not ask them
again. Everything else `app.json` needs — ID ranges, BC version, features, the AppSource block —
stays where it is below, because it depends on answers the business questions produce first.

| Box | Questions | Options to offer (free-text entry always available) |
|---|---|---|
| **1 — Identity** | 1. Extension Name? | *Recorded from Box 0* — not asked again. |
| | 2. Publisher? | *Recorded from Box 0* — not asked again. |
| | 3. Deployment Target? | *SaaS PTE* / *OnPrem PTE* / *AppSource*, the best fit for the problem statement first. |
| | 4. Which countries will users work in? *(multi-select)* | The countries the problem statement names that BC is available in. **Countries are asked only here** — Localization and the language questions reuse the answer. |
| **1a — App** *(after Box 1: the options depend on the Deployment Target)* | 4a. App icon? *(both editions)* | *Recorded from Box 0* — asked here only if Box 0 recorded *Later* and the target is now `AppSource` (then it is a release blocker to resolve). Formerly: *Yes — I'll provide an image* / *No icon* / *Later*. For `AppSource`, *No icon* isn't offered and *Later* is recorded as a release blocker — the old AppSource logo question (A4) is this one. On *Yes*, the next box asks for the path as free text with this guidance, verbatim: *"PNG, square, 300 × 300 px is ideal — Microsoft accepts 216 to 350 px for the marketplace listing. Larger is fine; I'll resize it, keeping the proportions, never stretching."* What happens next is under *The app icon* below. |
| | 4b. New app or existing app? | *New app — the version starts at `0.0.0.1` (recommended)* / *Existing app — I'll type the version installed in the target environment*. An existing app's version is confirmed on its **Extension Management** page and the project continues from it (Ops § Packaging → *Version numbers*). |
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
| **4D — Description & help** *(after Box 4: by now the problem statement, the Deployment Target, and the onboarding answers are known — enough to describe the app)* | D1. Short description (`brief`)? | **The agent's own one-line suggestion, written before the box opens**, as the first option; *Propose another*; and, for a PTE only, *Leave it out for now*. A change is typed in the free-text entry. One question per box — three boxes in a row. The procedure is *The description and help questions* below. |
| | D2. Long description (`description`)? | The same shape: the agent's own paragraph, ready before the box opens, as the first option. |
| | D3. Help URL (`help`)? | *Set it when the help site is built (recommended)* — Full Step 11 / Lite Step 6 offers it (Ops § Help Site); a URL only from the human's own material, if there is one; *I'll type it*; and, for a PTE only, *Leave it out for now*. Both editions, every Deployment Target; for `AppSource` these three are the old A1, A2, and A7 and are not asked again. |
| **5 — Working setup** | 17. *(Moved.)* Which models do the work — and at what thinking effort — is asked at the routine's first step, right after notifications, not here (Ops § Roles). Box 5 only confirms the recorded answer is on the sheet. | — |
| | 18. Leave the framework's own files out of the project's repository? | *Yes (recommended)* — the framework is distributed from its own repository, and its methodology isn't part of what the client receives / *No, track them* — a teammate cloning the project sees exactly how it was built. Explain `.gitignore` in the question itself: *"`.gitignore` lists files Git leaves out of commits and pushes — they stay on disk and work normally."* |
| | 19. Which language is the AL source text written in? | *`en-US` (recommended)*, with **Standards §8.1**'s reason in one sentence, or another language typed in. |
| **6 onward — Languages** | The per-country, per-language, and document questions below. | As below. |
| **Last — Confirm** | 20. Is this sheet right? | Show the complete sheet first — every ID range with its size, and the derived permission set names. *Confirm the sheet* / *Change something* (then ask only what changes). |

**Option counts** are in Ops § Asking and Approvals: 2–4 per question, a single suggestion paired
with *I'll type it*, more than four candidates trimmed to the four most likely.

**Lite differs only by what it doesn't have:** no Light or Reasoning roles (its Step 1 asks the Main
model and effort only, Ops § Roles), and its Box 5 carries the `.gitignore` question, the source
language, and the per-country language questions together. Questions 4a and 4b, and Box 4D's three
description and help questions, are asked in both editions.

### The app icon

On *Yes* to question 4a, the agent — not the human — puts the image where `app.json` expects it:
**`src/logo/AppLogo.png`**, and writes `"logo": "src/logo/AppLogo.png"` into `app.json` at project
setup (Ops § Project Setup). The file is a deliverable and is committed. Copy the file as it is when
it's already a square PNG of 300 px or less; **resize when it's larger, keeping the proportions,
never stretching**, with whatever the machine already has — the zero-install ladder applies here too
(Ops § Asking and Approvals). Stop at the first that exists:

- **macOS** — `sips`, built in: `sips -Z 300 <in> --out src/logo/AppLogo.png` (`-Z` fits the longer
  side to 300 px and keeps the aspect ratio).
- **Windows** — Windows PowerShell 5.1 with `System.Drawing`, on every Windows machine. It scales
  proportionally and pads to a square, transparent 300 × 300 PNG:
  ```powershell
  Add-Type -AssemblyName System.Drawing
  $in = [System.Drawing.Image]::FromFile((Resolve-Path '<in>'))
  $scale = [Math]::Min(1, [Math]::Min(300 / $in.Width, 300 / $in.Height))
  $w = [int][Math]::Round($in.Width * $scale); $h = [int][Math]::Round($in.Height * $scale)
  $out = New-Object System.Drawing.Bitmap 300, 300
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($in, [int](150 - $w / 2), [int](150 - $h / 2), $w, $h)
  $g.Dispose(); $in.Dispose()
  New-Item -ItemType Directory -Force src\logo | Out-Null
  $out.Save((Join-Path (Get-Location) 'src\logo\AppLogo.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose()
  ```
- **Linux** — ImageMagick when `convert` is on `PATH`:
  `convert <in> -resize 300x300 src/logo/AppLogo.png` (add
  `-background none -gravity center -extent 300x300` to pad a non-square image).
- **Any OS, when Python with Pillow is present** (`python3 -c "import PIL"` succeeds):
  ```
  python3 -c "from PIL import Image; im=Image.open('<in>').convert('RGBA'); im.thumbnail((300,300)); c=Image.new('RGBA',(300,300),(0,0,0,0)); c.paste(im,((300-im.width)//2,(300-im.height)//2)); c.save('src/logo/AppLogo.png')"
  ```
- **Otherwise, ask the human** to resize it, with the size stated; never install a tool for this.

**Non-square input:** resize the longer side to 300 px and pad to a square with transparency — the
PowerShell, ImageMagick `-extent`, and Pillow forms above do that; after `sips -Z` the file is still
non-square, so pad it with Pillow if present or say so and ask. **Never crop silently.** Whatever was
done — copied, resized, padded — say it in one line with the final pixel size.

**Creating one — *Create one for me* (every journey; the plugin's `app-icon` skill,
`/ocpf-bc:app-icon`).** When the human has no icon, the Main model makes one, to a fixed standard:
a **square** icon with **rounded corners** (an 18 % radius), a **transparent background** outside the
rounded square, 300 × 300, legible at the 32 px Business Central uses in its lists. One box asks
four things — the **style** (*Flat 2D (recommended)* / *Isometric 3D*), the **colors** (*One color* /
*Two colors (recommended)* / *A two-color gradient*, with the colors proposed in the question's text
from what the human has written, never pulled from a website or an email signature, and free text
for their own), the **content** (*An image only (recommended)* / *A word mark and an image*, two to
four characters), and **anything it must show or avoid** (*Use your best understanding of what the app
is about*, that understanding stated, or *I'll describe it*). The model writes the icon as an SVG
(`images/AppIcon.svg`, from the skill's skeleton — everything inside a rounded clip path), renders it
to PNG with nothing installed (macOS Quick Look's `qlmanage`; a headless Chrome or Edge with a
transparent default background on any OS; ImageMagick, librsvg, Inkscape, or cairosvg only when
already present; last, a preview page with a *Save as PNG* button for the human), checks the file
is 300 × 300 with an alpha channel, opens it, and asks: **Accept this icon** / *Make another — I'll
say what to change* / *Make another — your call*, keeping every attempt until one is accepted. On
acceptance the PNG and its SVG stay in `images/`, the PNG is copied to `src/logo/AppLogo.png` as
above, and `app.json` gets `"logo": "src/logo/AppLogo.png"` — never before the human accepted. The
brief and the acceptance are recorded where the journey keeps its record.

### The description and help questions

**Box 4D (D for description — the letter avoids a clash with Box 1a's questions 4a and 4b) — asked on every project, both editions, whatever the Deployment Target** (since
v5.9.5.0; before that `brief` and `description` were asked for AppSource only, and `help` was first
raised when the help site was built). Three properties of `app.json` describe the app to the people
who install it: `brief` and `description` show on the **Extension Management** page and in the
extension's details, and `help` is the **Help** link there. They are cheap to set at intake, when
the agent has just read the requirements and written the problem statement, and tedious to chase
at release — so they are asked here, after Box 4, once the problem statement, the Deployment Target,
and the onboarding answers are known. Not earlier: a description written before the scope is
settled is rewritten.

**Have the answers ready before asking.** Before the first of the three boxes opens, the agent
writes its own candidate for each from what it knows of the project — the problem statement, the
entity list, the consumers, the countries — in the working language, in the voice of the app's
listing, not the project's. **`brief`**: one line, about 100 characters at most, what the app does
for whom (*"Approval routing for purchase orders with Teams notifications, for US and Canadian
companies"*). **`description`**: one short paragraph, three to five sentences — the business outcome,
who uses it, the main objects or pages it adds, and anything it integrates with; no marketing
superlatives, no version numbers, no object IDs. **`help`**: never written by the agent — a URL
only from the human's own material (a support page or documentation link named in
`requirements/`, or the product website answered in the AppSource boxes); the *Forbidden sources*
rule applies in full, so an email domain, a company name, or a guessed GitHub Pages address is
never offered.

**Three boxes, one question each, in this order — never one box with three questions, and never
prose.** The human reads one proposal at a time and answers it before the next appears:

1. **Short description (`brief`)?** Options: **the suggestion itself, quoted in full, labelled
   *Use this (suggested)*** / *Propose another* (the agent writes a different one and asks again) /
   *Leave it out for now* — the last offered only when the Deployment Target is a PTE. **A change
   is the free-text entry:** the question's text says *"Choose Other to type your own wording or
   to edit mine"*, so a human who wants a different sentence types it rather than describing it.
2. **Long description (`description`)?** The same shape, the paragraph quoted in full in the
   option's text (a harness that truncates long labels puts the full text in the question and a
   first line in the label).
3. **Help URL (`help`)?** Options, recommended first (Ops § Asking): **Set it when the help site
   is built (recommended)** — Full Step 11 / Lite Step 6 builds `docs/index.html`, gives the GitHub
   Pages URL, and offers `help` then (Ops § Help Site) / the URL from the human's material when
   there is one, quoted, labelled with its source (*"from requirements/Support.md"*) / *I'll type
   it* / *Leave it out for now* (PTE only). A typed URL is checked for shape only (`https://`, a
   host) — never fetched.

**AppSource.** When the Deployment Target is `AppSource`, these three are the marketplace
questions A1, A2, and A7 — asked here, once, and not again in Box 3a / 3b. The difference is said
in the question: each is **mandatory for submission** (Standards Appendix E), so *Leave it out for
now* is not offered, and `brief` and `description` **must match the Partner Center offer
listing word for word** — if the offer already exists, the human pastes its text and the
suggestion is only a draft for an offer not yet written. A `help` deferred to the help-site step
is recorded as a release blocker until that step sets it.

**What is recorded and written.** Each answer goes on the parameter sheet — Full §1.1's **Short
Description**, **Long Description**, and **Help URL** rows; Lite's rows of the same names — with
its source (*suggested, accepted*; *typed*; *from requirements/…*; *deferred to the help site*;
*left out*). Ops § Project Setup step 1 writes the three into `app.json` for every Deployment
Target: a value the human chose or typed is written as given; *Set it when the help site is built*
and *Left out* write nothing — **never an empty string**, which AppSourceCop flags and which shows
as a blank line in Extension Management. The help-site step later offers to set `help` or, when
intake recorded a URL, to replace it, naming the current value in its question. Changing any of
the three after the first package is a package change: the next build's Revision, with its
ChangeLog entry (Ops § Packaging).

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
| **3a — Marketplace listing** | A1. Short description (`brief`)? — **not asked here**: it is Box 4D's question D1, asked on every project (*The description and help questions* above). For AppSource that box says it is mandatory and must match the offer listing in Partner Center word for word. | — |
| | A2. Long description (`description`)? — **not asked here**: Box 4D's question D2, with the same AppSource conditions. | — |
| | A3. Product or support website (`url`)? | The publisher's domain if the human has given one, plus *I'll type it*. Say what it's for: it shows as **Website** on the **Extension Management** page. |
| | A4. Logo file? — **not asked here**: it is question 4a in Box 1a, already answered. For AppSource a *Later* there is a release blocker; `logo` is written from it. | — |
| **3b — Legal and support URLs** | A5. Privacy statement URL (`privacyStatement`)? | *I'll type it*, or the publisher's domain with a suggested path. |
| | A6. License terms URL (`EULA`)? | Same. |
| | A7. Help and troubleshooting URL (`help`)? — **not asked here**: Box 4D's question D3. A `help` deferred there to the help-site step is a release blocker until that step sets it. | — |
| | A8. Context-sensitive help URL (`contextSensitiveHelpUrl`)? | Same, plus *Same as the help URL* when Box 4D recorded one. If the app won't cover every BC locale, say so and record `/{0}/` in the URL with the locales in `supportedLocales`. |
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
     **Lite:** `docs/4-prove/Docs.md`'s user-guide section *(recommended)* or none — Lite has no separate
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

*(The heading keeps its name for anchor stability. Since Ops v1.3.0.0 the first part — asking
which model the Main role runs on — applies to Lite too, and since 5.0.0.0 / 5.8.0.0 so do the
generator and the reviewer (*Generation speed*, *Parallel batches*, *The pre-review*); only the
Light and Reasoning roles remain Full only.)*

The Full edition splits work across three roles, each potentially a different model. Lite has one
role, Main, and asks only that one's model and effort. **The assignment is never optional and never
"everything on one model, as if the roles didn't exist":** every role gets a model and a thinking
effort, recorded and enforced. Choosing the same model for all three is a valid answer — the Light
and Reasoning roles still run as sub-agents, because fresh eyes are the point, not just a different
model. Two more sub-agents carry the Main role's model and effort and so add no question: the
**generator**, which writes the AL files of one batch at a time (both editions; *Generation speed*
and *Parallel batches* below), and the **reviewer**, which reads the whole extension once it first
compiles clean and before it is first packaged (both editions; *The pre-review* below).

The executing agent can't switch its own model mid-session, but it can delegate a self-contained
task to a sub-agent running a different model, get a result back, and act on it. That's the whole
mechanism, and it isn't tied to one harness. **What can go wrong is the delegation inheriting the
session's model by default** — which is exactly what happened on a real project, and why the
*Enforcement* part below exists.

### Asking — at the routine's first step, right after notifications

Asked in the runbook's first step (Full PRE-01, Lite Step 1), **before any document is drafted**, so
the answer exists before the first delegated task — not at the parameter sheet, where it used to sit
behind a preset question and arrived after the sub-agent definitions had already been used with no
model set.

**Say this once, before the first model question, in both editions**, verbatim:

> *"A High thinking effort makes every task slower: the model thinks longer before each answer, and a
> step can take noticeably more time. The framework recommends High only where judgment matters
> most."*

**What to recommend, per edition and per tool.** Offer the recommended pair first in every question,
with a one-line reason. Copilot names are the names its model picker shows on the day; if a name
below isn't in the picker, offer the nearest and say so. The generator sub-agent inherits Main and
is never asked about.

| Edition · tool | Main | Light | Reasoning |
|---|---|---|---|
| Full · Claude Code | **Sonnet, Medium** | **Haiku, Medium** | **Opus, High** |
| Full · GitHub Copilot | **Claude Sonnet 5.5 or GPT-6.1 Sol, Medium** | **Claude Haiku 5.5 or GPT-6 Luna, Medium (Balanced)** | **Claude Opus 5.5 or GPT-6.1 Sol, High** |
| Lite · Claude Code | **Sonnet, Medium** | — | — |
| Lite · GitHub Copilot | **Claude Sonnet 5.5 or GPT-6.1 Sol, Medium** | — | — |

In Copilot each role names **two** recommended models, a Claude model and its OpenAI peer at the
same published price (Copilot's models-and-pricing page, read October 20, 2026: Sonnet 5.5 and
GPT-6.1 Sol at $2 / $0.10 / $10 per million input, cached, and output tokens; Haiku 5.5 and GPT-6
Luna at $0.10 / $0.01 / $0.50; Opus 5.5 at $4 / $0.20 / $20). Offer both as options, the Claude
model first, and let the human pick either; a flash-class model as Main is a legitimate budget
override, said with the warning that step discipline may slip — the Main role's work is mostly
rule-following over a long runbook, which is where small models fall short (an earlier
recommendation of Gemini 3.8 Flash as Main was withdrawn in 5.9.2.0 for that reason). The
cached-input rate matters most on this framework, since every turn re-reads the runbook and the
guides from cache — which is why a model with a higher cached rate (Grok 4.7 at $0.50) costs more
here despite its cheaper output.

Why these: Main does the volume — generation, edits, bookkeeping — where a fast, capable model at
Medium is quicker and cheaper with no loss the analyzers and the light pass wouldn't catch; Light
is checklist matching, which gains least from extra thinking; Reasoning drafts the FRD and TDD,
runs the Sanity Check, the Gap-Fit Test, and the Code Review, and diagnoses root causes — the
judgment work, and the one place High earns its time. Medium or Low elsewhere, or High everywhere, is
a legitimate, explicit override, not a mistake to argue the human out of; say what it costs in time
(High) or in judgment (Low on Reasoning) and record the choice.

**Full — six questions, on one page where the harness allows it** (Claude Code names shown; in
Copilot, the picker's names from the table above):

| # | Question | Options to offer (free-text entry always available) |
|---|---|---|
| 1 | Main model? | *Sonnet (recommended)* / *Opus* / *Haiku* — or, in a harness with other models, the names its picker uses |
| 2 | Main thinking effort? | *Medium (recommended)* / *High* / *Low* |
| 3 | Light model? | *Haiku (recommended)* / *Sonnet* / *Opus* |
| 4 | Light thinking effort? | *Medium (recommended)* / *High* / *Low* |
| 5 | Reasoning model? | *Opus (recommended)* / *Sonnet* / *Haiku* |
| 6 | Reasoning thinking effort? | *High (recommended)* / *Medium* / *Low* |

- **Claude Code:** `AskUserQuestion` takes at most four questions per box, so this is two boxes, back
  to back — questions 1–4 (Main and Light), then 5–6 (Reasoning). Don't spread them further.
- **GitHub Copilot Chat in VS Code:** `askQuestions` carries all six in one carousel. Offer the
  Claude models by the names the model picker shows (for example *Claude Sonnet 5*), since that's the
  string a `.agent.md` file's `model:` needs.
- **GitHub Copilot CLI:** `ask_user`, one question at a time in the same order, with *I'll type it*
  on each.
- **A harness that can't run sub-agents at all** (Claude Chat, the
  github.com cloud agent): ask questions 1–2 only, say that the Light and Reasoning roles can't run
  here, and record `N/A — no sub-agents in this harness` for them.

**Lite — two questions, one box:** the Main model (*Sonnet (recommended)* / *Opus* / *Haiku*; in
Copilot, *Claude Sonnet 5.5 (recommended)* and *GPT-6.1 Sol (recommended)* first) and its thinking
effort (*Medium (recommended)* / *High* / *Low*).

**Say what's running before asking.** The Main model *is* the session's model. State it — and the
session's effort, where the harness shows it — in the question's own text, and offer the current
value as the recommended one when it matches the framework's recommendation. Only the human can
change either: `/model <sonnet|opus|haiku>` and `/effort <low|medium|high>` in Claude Code (which also accepts `xhigh` and `max`; the framework offers three — the
agent has no tool that does this); the model picker in Copilot Chat. If the human picks a Main model
or effort other than what's running, ask them to switch now, then confirm the session shows the new
model before continuing. **Never record a Main model that isn't the one doing the work.**

**Record everything, in one place:** the model as the human named it, the harness identifier it maps
to (the Claude Code alias `sonnet` / `opus` / `haiku`, or the Copilot picker name), and the effort —
in `docs/0-project/ProjectMemory.md` at once, then Full §1.7 / Lite's parameter row when the sheet is written.

### What each role is for

1. **Main role** — the bulk of the work: all code generation, all actual code edits (including
   applying what the other roles report), and end-to-end ownership of the continuity documents:
   ChangeLog, Object Register, project memory, and the Testing Feedback Log. A capable
   general-purpose model.
2. **Light role** — fast, cheap, checklist-driven verification only: the post-generation pre-flight
   pass in full, including **symbol verification**, which is deliberately not the reasoning role's —
   it's a lookup against ground truth, not a judgment call. Reports findings; never edits code.
3. **Reasoning role** — heavier-reasoning, fresh-eyes work: the Sanity Check, Gap-Fit Test, Code
   Review, FRD and TDD authorship, root-cause diagnosis during the compile-and-package cycle,
   diagnosing whether a testing-feedback report is real, and — in a GitHub Copilot in VS Code
   project — the usage measurement at every step boundary (*Usage & Cost → 5*). Reports findings,
   drafts, diagnoses, or the measurement's output; never edits code or the continuity documents.
4. **Generator sub-agent** (both editions) — the main role's hands for one batch: it writes the
   AL files of exactly one batch, under `src/`, from a brief it reads and nothing else; it never
   edits the ChangeLog, the Object Register, the TDD, or another batch's files; it reports the
   files written, every deviation from the brief, and its open questions. It runs on the **Main
   model and effort** — it isn't a fourth role, it's the Main role running in parallel with itself,
   which is what makes *Parallel batches* possible.
5. **Reviewer sub-agent** (both editions) — the pre-review at Full Step 07 / Lite Step 5: the
   moment the extension first compiles with 0 / 0 and before the first package, it reads every
   file under `src/` against the design, the Standards Guide, and plain logic, and reports
   findings with a root cause and a fix; it never edits, never grades, writes no scorecard. It
   runs on the **Main model and effort**, in the background, so the human's first sandbox test
   doesn't find what a first read would have. It is not the Code Review: Full Step 09 / Lite Step
   6 still happens, with fresh eyes, on the Reasoning model (Lite: the Main model), with the
   scorecard.

**The division of labor is fixed, whichever models are assigned.** The light and reasoning roles
investigate, draft, or diagnose; the generator writes new files inside its batch and nothing else;
the main role is the only one that edits existing code and the only one that owns the continuity
documents. That keeps one consistent author across the codebase and keeps root-cause tracing in one
thread instead of fragmenting across cold hand-offs. A role holder's output is always relayed back
and integrated by the main role, never applied blind — a generator's files included: the main role
records them in the Object Register and the ChangeLog and sends them through the light pre-flight.

### Enforcement — making the recorded model the one that actually runs (Full)

A sub-agent runs on whatever its definition and the delegating call say. **If neither says
anything, it inherits the main session's model** — in Claude Code that is the documented resolution
order (per-call `model` parameter → the definition's `model:` frontmatter → the
`CLAUDE_CODE_SUBAGENT_MODEL` environment variable → the main conversation's model), and Copilot's
custom agents likewise fall back to the model picker's selection. The plugin's bundled
`ocpf-light`, `ocpf-reasoning`, and `ocpf-generator` definitions deliberately carry **no `model:`**,
because the same file is read by Claude Code (which wants an alias like `opus`) and by Copilot
(which wants a picker name like `Claude Opus 5.5`) and the human's choice isn't known until intake.
So the project has to supply it. Four steps, all the agent's, none optional:

1. **Materialize the assignment as project-local sub-agent definitions, immediately after
   the answer** — at PRE-01, before PRE-02 starts: four in Full (light, reasoning, generator,
   reviewer); two in Lite (generator and reviewer, both on the Main model and effort). Take the
   bundled definitions as the template: fetch `agentPlugin/ocpf-bc/agents/ocpf-light.agent.md`,
   `ocpf-reasoning.agent.md`, `ocpf-generator.agent.md`, and `ocpf-reviewer.agent.md` from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/`, or copy them from
   the installed plugin's `agents/` folder when GitHub is unreachable. Write, for every harness the
   project uses (the same choice the runbook placement was made for):
   - **Claude Code:** `.claude/agents/ocpf-light.md`, `.claude/agents/ocpf-reasoning.md`,
     `.claude/agents/ocpf-generator.md`, and `.claude/agents/ocpf-reviewer.md`, with the bundled body unchanged and two frontmatter lines
     added — `model: <alias>` (`haiku`, `sonnet`, `opus`, or a full model ID) and
     `effort: <low|medium|high>` (Claude Code's own effort field on a sub-agent definition, which
     also accepts `xhigh` and `max`; there is **no per-call effort override**, so the frontmatter is
     the only place a role's effort can be set). **The generator and the reviewer carry the Main
     model and the Main effort**, copied from questions 1–2, never asked separately. Keep `name:`
     as `ocpf-light` / `ocpf-reasoning` / `ocpf-generator` / `ocpf-reviewer` and keep each file's
     tool restrictions (the `disallowedTools:` line on the three reporting roles; the generator's
     write access limited to `src/`).
   - **GitHub Copilot:** `.github/agents/ocpf-light.agent.md`, `.github/agents/ocpf-reasoning.agent.md`,
     `.github/agents/ocpf-generator.agent.md`, and `.github/agents/ocpf-reviewer.agent.md`, with `model: '<picker name>'` added (a string, or
     an array of picker names in preference order) and `reasoningEffort: <low|medium|high>` where
     the surface supports it — Copilot's *Balanced* is `medium`. Copilot CLI has wanted the spelling
     `reasoning-effort`; check the installed version's documentation for the key it reads, and where
     no effort key is honored, say so and record the effort as `session` for that role.

   These files are framework files: they follow the §1.8 / Step 1 `.gitignore` answer (Ops §
   Repository Hygiene lists the entries). Tell the human they were written, and where.
2. **Delegate to the project-local definition, and pass the model anyway.** In Claude Code — the
   VS Code extension and the CLI behave the same — call the Agent tool with `subagent_type` set to
   the project-local `ocpf-reasoning`, `ocpf-light`, or `ocpf-generator` (a project agent outranks
   a plugin agent of the same name) **and** `model` set to the recorded alias on **every single
   call** — belt and braces, because the per-call parameter wins over everything and costs nothing. In Copilot Chat
   and Copilot CLI, invoke the project-local agent by name (both read `.github/agents/`). In VS
   Code its `model:` line does the rest — Copilot has no per-call override, so the file is the
   mechanism. **In Copilot CLI, `model:` is not documented** (GitHub lists it for VS Code and the
   JetBrains, Eclipse, and Xcode IDEs only), so the sub-agent may run on the CLI's session model:
   say so to the human, and rely on step 3's `Model:` check to show what actually ran.
   Hand the role holder the inputs its task needs plus a pointer to the runbook, as before.

   **The first session is the exception, in Claude Code.** It watches `.claude/agents/` for
   changes, but only a folder that existed when the session started; the session that *creates*
   the folder may not see the new definitions until the next start (nor does it watch folders added
   with `--add-dir`, or anything in a `--disable-slash-commands` session). So after writing them, check
   whether the Agent tool offers `ocpf-reasoning`; if not, for the rest of that session delegate to
   the plugin's `ocpf-bc:ocpf-reasoning` / `ocpf-bc:ocpf-light` / `ocpf-bc:ocpf-generator` **with
   the recorded alias in the `model` parameter on every call** — the model is still right — tell the human that those roles'
   effort will be the session's until the next session, and record it in `docs/0-project/ChangeLog.md`. Step
   3 catches any call that forgets.
3. **Verify from the report, every time.** Every sub-agent report opens with one line —
   `Model: <the model this sub-agent is running on>` — which the bundled definitions require. Before
   using anything from the report, the main role compares that line with the §1.7 row for the
   role. **A mismatch stops the step:** say so to the human in plain words ("the Reasoning role ran
   on Sonnet; §1.7 says Opus"), fix the definition or the call, and redo the task on the right model.
   Never accept the output and note the discrepancy later — the discrepancy *is* the defect.
4. **Record what actually ran.** The ChangeLog entry that closes a delegated step names the model
   from the report's first line, so the project's record shows what happened rather than what was
   intended. A project that finds, after the fact, that its roles never ran on the recorded models
   records that in the ChangeLog too — as a defect with a root cause, not a footnote.

**Why four steps and not one:** on a real project the human chose Sonnet / Haiku / Opus at intake
and the sheet said so, but the sub-agent definitions carried no model, no delegation passed one, and
nothing checked. Every Reasoning-role task — the FRD, the TDD, the Sanity Check — ran on Sonnet, and
it came to light only because the human asked. Any one of the steps above would have caught it.

**Run delegations in the background.** Every role delegation — light, reasoning, generator — runs
as a *background* sub-agent, not a blocking one. None of them ever asks the human (they report,
draft, diagnose, or write files from a brief), so the restricted tool set a background sub-agent
gets costs nothing; and background is what makes parallel batches and the overlapping pre-flight
possible: the main role keeps integrating while a generator writes and a light pass checks. Run one
in the foreground only when the very next action needs its result and nothing else can proceed —
an FRD draft the human is waiting to read, for instance. Tell the human once, in Claude Code, that
a permission prompt raised by a background sub-agent still surfaces in the main session, so a
prompt that appears while "nothing is happening" is that sub-agent asking.

**With the OCPF plugin**, the Light and Reasoning roles, the generator, and the reviewer ship as
ready-made sub-agents, `ocpf-light`, `ocpf-reasoning`, `ocpf-generator`, and `ocpf-reviewer` (in
Claude Code, `ocpf-bc:ocpf-light`, `ocpf-bc:ocpf-reasoning`, `ocpf-bc:ocpf-generator`,
`ocpf-bc:ocpf-reviewer`). They carry this division of labor already — the three reporting roles
are denied file-editing tools, the generator writes only under `src/` — and open every report with
the `Model:` line; but **they are templates**, used through the project-local copies above, and
delegated to directly only in the first-session fallback, always with the model passed per call.
The plugin's **`roles` skill** (`/ocpf-bc:roles`) does the asking, says the warning sentence,
writes the copies (four in Full, two in Lite), records the assignment, and runs the first-session
check in one go, in Claude Code and Copilot alike; the runbook invokes it at its first step in a
plugin project, and it repairs a project whose roles ran on the wrong model. (The `analyze`
skill's `ocpf-analyst` is the one sub-agent outside this assignment: it carries the model the
human chooses for one analysis, Ops § Existing Apps.) **On the dashboard** the reviewer has no
row of its own: it runs on Main's model, so its tokens land in Main's row and, while it runs, the
*Who is working* card's counter beside the Generator (the other Main-model sub-agent) shows it.

### Generation speed

Code generation (Full Steps 05–06, Lite Steps 3–4) is where a project spends most of its output
tokens and most of its wall-clock time, so these rules apply **in every mode**, parallel or not:

- **Run generation at the Main role's recorded effort** — Medium by default (the table above). It
  is the generator's effort too, because the generator carries Main. Don't raise it for "hard"
  objects; the light pre-flight and the analyzer compile are the quality gates, and they run
  regardless.
- **One complete file per Write call.** Write each `.al` file once, whole. Never create a file with
  a stub and grow it with incremental edits: every edit re-reads and re-sends the file, and on a
  real project that alone doubled the tokens of a batch.
- **No narration between files.** One summary per batch — the files written, the deviations, the
  open questions — not a sentence per object.
- **The brief carries the exact template text.** The generation brief includes the object
  templates and the Standards sections it needs, copied in, so no guide is re-read per file (Ops §
  Documents → *Briefing a drafting role* gives the same rule for documents).
- **Symbols are verified once per batch by the light pass**, after generation — not per file during
  it. The generator writes against the symbol source named in the brief and lists anything it wasn't
  sure of; the light role checks the batch in one pass.
- **With Opus as Main in Claude Code, offer fast mode once**, at the first generation batch:
  `/fast` runs Opus up to about 2.5× faster at a higher per-token price (Opus only; the human
  toggles it, the agent can't). State the price difference from `ocpfFramework/state/pricing.json`
  when offering it, and record the answer; never ask again in the project unless the human raises
  it.

### Parallel batches

**Ask once, at the start of Full Step 05 (Lite Step 3 only when the plan has two or more
batches)**, as a Rule 6a decision:

> *How should the batches be generated?* — **Generate all batches in parallel — one generator per
> batch, all at once (recommended with two or more batches when the tool runs sub-agents)** / **One
> batch at a time** / **Ask me before each batch**.

**Parallel mode:**
1. **Fix every ID and file name in the Build Plan before anything starts** — the Object Register
   is complete for every batch, so no two generators can claim the same ID or name. Batches are
   disjoint by construction; that's what makes conflicts impossible rather than merely unlikely.
2. **One background generator per batch**, all started together, each briefed with: the step
   file's generation rules; the batch's own TDD sections; `docs/1-define/ProjectParameters.md`;
   Standards §1.1–§1.8 and §2, plus Part 11 and the matching `ocpfFramework/patterns/` files when
   the batch has a child list, a setup page, or a wizard; and the symbol source. Nothing else
   (*Briefing a drafting role*).
3. **As each generator returns, run the light-role pre-flight on that batch in the background**
   while the other generators continue — the pre-flight of batch 1 overlaps the generation of
   batch 3.
4. **The main role integrates**, batch by batch as the reports arrive: Object Register, ChangeLog,
   the deviations and open questions, then the compile-and-package cycle once every batch is in.

**Fall back to sequential and say so** when the harness can't run parallel sub-agents (Copilot
CLI, the github.com cloud agent, or any harness without a background Agent tool): one generator per
batch in order, or the main role generating directly when there are no sub-agents at all. The
speed rules above still apply.

### The pre-review

**When:** Full Step 07 / Lite Step 5, the moment the whole extension first compiles with the
analyzers at 0 errors / 0 warnings — and **before the first package is built**. Every later round
of that step's cycle (a fix, a regenerate) does **not** repeat it; the Code Review at Full Step 09
/ Lite Step 6 is the full review, on its scorecard, with fresh eyes.

**Who:** the project-local `ocpf-reviewer` sub-agent, on the **Main model and Main effort** as
recorded at PRE-01 / Step 1, **in the background** (Operating Rule 10 in force: the project-local
definition, the model passed on the call in Claude Code, the report's `Model:` line checked
against §1.7 / the Main row before anything in it is used). The main role carries on with the
package preparation while it reads.

**The brief, and nothing else:** the project root; `src/` (every file); the design —
`docs/2-design/TDD.md` and `docs/3-build/BuildPlan.md` (Full) or `docs/2-design/DesignDoc.md`
(Lite); `docs/1-define/ProjectParameters.md`; the Standards Guide path with the sections to read
(§1.1–§1.9, Part 2 for API objects, §5.3–§5.4, Part 7, Part 11, §8.3); `ocpfFramework/patterns/`;
the symbol source; and the instruction to open with `Model:` and report in the agent's fixed shape.

**What comes back, and what the main role does with it:** findings in two tiers — what would break
the human's first sandbox test or force a rebuild, and what is worth fixing before the package —
plus observations and what could not be verified. The main role presents **every finding in one
message**, each with its file and line, root cause, and proposed fix, then asks **once**, through
the options mechanism (Rule 6a): **Apply all (recommended)** / *Apply selected* (the human names
which) / *Discuss first* — the same box Step 07 / Step 5 use for a test round's diagnoses, and a
finding that would change the FRD, the TDD, or the Design Doc gets its own separate box. Nothing is
applied before the answer. Approved fixes are applied by the main role, the extension recompiled to
0 / 0, and **each finding with its decision — applied, declined and why, deferred to Code Review —
is one entry in `docs/0-project/ChangeLog.md`** (the Issue shape, source *Pre-review*); Full also
notes the pass in `docs/0-project/ProjectMemory.md`. Then the first package. A report with no
findings is one ChangeLog line saying so, with the model that ran.

**Why:** on real projects the first package went to the human with a wrong relation, a validation
the design asked for and the code lacked, and a tooltip that said nothing — all visible on a first
read, none visible to the analyzers — and the human found them in the sandbox. One read on the
Main model costs a few minutes in the background and a fraction of the generation's tokens; a
sandbox round costs the human an upload and a test. Not a grade, not a rubric, not a document: a
pair of eyes between "it compiles" and "please install this".

---

## Ops § Project Setup

Once the human confirms the parameter sheet, and before design begins, the agent sets the project
up. Symbols have to be on disk before any design decision is verified against them, so this happens
at the end of intake, not at the start of BUILD. Nothing here needs the human beyond the AI tool's
own approval prompts.

**The root of an AL project holds only this — either edition, no exceptions:**

```
app.json  .gitignore  CLAUDE.md  .github/  .claude/  .vscode/  .alpackages/  Translations/
src/                 all AL source; subfolders per module allowed; the app icon in src/logo/
docs/                project documents (Ops § Documents gives the phase folders)
requirements/        raw input, verbatim (.md recommended; Word, PDF, images read too); requirements/existing/ holds
                     an existing app's reverse-engineered record (Ops § Existing Apps)
images/              the human's app icon source, when they have one (Ops § Intake → Box 0; optional)
outputAppPackage/    every built package (Ops § Packaging)
ProjectProgress.md   both editions
ProjectDashboard.html  both editions — the live dashboard page (Ops § Dashboard), tracked, never ignored
ProjectDashboard-f1.html  the same page in the F1 theme, rendered on every run; tracked, never ignored
ocpfFramework/       everything the framework fetches or keeps (below)
```

`CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/ocpf-framework.instructions.md`,
`.claude/agents/`, `.github/agents/`, `.vscode/`, `.alpackages/`, and `Translations/` stay where
their tools require them. The BCQuality snapshot stays a sibling folder *outside* the root (Ops §
Fetched Companions explains why `alc` forces that). Nothing else goes in the root: no loose `.al`
files, no runbook, no changelog, no scripts. Why: a client opening the repository sees their app, not
the framework's plumbing, and a fresh clone or a migration knows exactly what is theirs.

**`ocpfFramework/` — one folder for everything that isn't the client's:**

```
ocpfFramework/
  README.md                          six fixed lines (text below)
  framework.json                     the plugin's marker (Ops § Plugin)
  RunbookChangelog.md                or LITE_RunbookChangeLog.md
  RunbookSchematics.md               or LITE_RunbookSchematics.md, when placed
  BC_App_Build_Routine_Agent.md      only when CLAUDE.md already existed; CLAUDE.md then holds the
                                     single line @ocpfFramework/BC_App_Build_Routine_Agent.md
                                     (Lite: LITE_BC_App_Build_Routine_Agent.md)
  state/                             per developer, always gitignored:
    usage.json  pricing.json  notifications.json  copilot.json  previous/
  standardsGuide/ocpfALDevStandardsGuide.md + SNAPSHOT.json
  opsGuide/ocpfOperationsGuide.md + SNAPSHOT.json
  runbookSteps/
  documentTemplates/
  patterns/
  scripts/
```

**`ocpfFramework/README.md` is these six lines, written at the first step and never varied**, so
anyone who opens the folder — a teammate, a client, a later agent — knows what it is without
reading the framework:

```
# ocpfFramework
This folder belongs to the OCPF BC Agentic Development Framework, which built this project.
Everything in it is fetched or generated by the framework: guides, step files, templates, patterns, scripts, and its marker.
Never edit anything here by hand; the framework's update step refetches it, and a hand edit is lost on the next update.
Per-developer files (usage, prices, notifications, Copilot settings) live in state/ and are never committed.
Framework repository: https://github.com/ajansari/ocpfBcAgenticDevFramework
```

Then, in order:

1. **Write `app.json` complete, from the confirmed sheet** — the second and last write; the first
   happened at PRE-01 / Lite Step 1 with the identity answers (Ops § Intake → *Box 0*), so **keep
   `id`, `name`, `publisher`, and `logo` exactly as that write left them** and fill in the rest:
   version, every ID range, `platform`, `application`, `runtime`, and the `features` the scaffold step lists —
   including `"NoImplicitWith"` and `"TranslationFile"` (**Standards §8.2**). **`version` is
   `0.0.0.1` for a new app**, or the installed version the human gave at intake question 4b for an
   existing one (Ops § Packaging → *Version numbers*). **`brief`, `description`, and `help` come
   from Box 4D for every Deployment Target** (Ops § Intake → *The description and help questions*):
   a value the human chose or typed is written as given; an answer of *Set it when the help site
   is built* or *Leave it out for now* writes nothing — never an empty string. If `app.json`
   already exists (for example the
   human ran **AL: Go!**), keep its `id` GUID and replace the rest. Don't change `idRanges`,
   `platform`, `application`, `runtime`, or `dependencies` again without re-running step 5.
   - **Deployment Target `AppSource` adds mandatory properties:** `brief`, `description`, `url`,
     `privacyStatement`, `EULA`, `help`, `contextSensitiveHelpUrl`, `logo`, `application`, and
     `applicationInsightsConnectionString` where the human gave one — from the intake's
     AppSource boxes and Box 4D (**Ops § Intake**), written now rather than at release, because a missing one
     is a rejected submission, not a warning (**Standards Appendix E**). Any the human deferred
     stay recorded as release blockers.
2. **Place the app icon**, when intake question 4a was *Yes*: copy or resize the human's image to
   `src/logo/AppLogo.png` exactly as Ops § Intake → *The app icon* says (proportions kept, padded
   to a square, never stretched or silently cropped), write `"logo": "src/logo/AppLogo.png"` into
   `app.json`, and say what was done with the final size. The file is committed with the source.
   *Later* leaves `logo` out and, for AppSource, keeps the release blocker on the sheet.
3. **Create the folders**: `src/` (AL source goes here and only here, in per-module subfolders when
   the design has modules), `docs/` with its phase folders (`0-project`, `1-define`, `2-design`,
   `3-build`, `4-prove` — Ops § Documents; **Build-a-Feature keeps `docs/` flat**, Ops §
   Build-a-Feature), `requirements/` (if the human hasn't), `outputAppPackage/`, and
   `ocpfFramework/` with its README. In a plugin project, `ocpfFramework/framework.json` also
   carries `"layout": "ocpfFramework-1"` (so a later migration knows which layout it's reading)
   and `"tooling": {}` (filled by Ops § Tooling Checks as each check runs).
4. **Connect the AL tools** if this session doesn't have them (Ops § AL Tools).
5. **Download symbols** (Ops § Symbols). Confirm `.alpackages/` holds the Base Application and
   System Application for the target version, and record where they came from as the sheet's Symbol
   Source. Add `.alpackages/` to `.gitignore` now (Ops § Repository Hygiene).
6. **Keep the editor in sync** (Ops § Editor Sync). If VS Code's AL extension loaded this project
   before the agent changed `app.json`, it still shows the old ID ranges and missing symbols as red
   errors. Refresh now, while no `.al` file exists yet.
7. **Check the layout and the ignore list before design begins.** The root holds only what the
   layout above lists; `docs/` holds every document written so far, each in its phase folder
   (nothing from the runbook's document list loose in `docs/` or in the root, `ProjectProgress.md`
   and the dashboard pages `ProjectDashboard.html` / `ProjectDashboard-f1.html` excepted); the
   repository exists (`git rev-parse --is-inside-work-tree`, else `git init -b main` — Ops §
   Repository Hygiene); `.gitignore` carries the full block from Ops § Repository
   Hygiene; `git check-ignore -v` names each framework file that exists **and does not name**
   `ProjectDashboard.html`, `ProjectDashboard-f1.html`, or `ProjectProgress.md`; and `git status --porcelain` lists
   both dashboard pages as untracked or modified, never as nothing (stage it). A miss here is
   cheap now and a client-facing mistake later.

---

## Ops § Object IDs

**An object ID is unique per object type, never across the extension.** Business Central keeps a
separate ID space for every object type: a table, a page, a report, a codeunit, a query, an
XMLport, an enum, a permission set, and each kind of extension object (table
extension, page extension, report extension, enum extension, permission set extension) can all
carry the same number at once. A range of five IDs, `50001–50005`, holds five tables **and** five
pages **and** five reports **and** five codeunits — not five objects. Spending `50001` on a table
and starting the first page at `50002` throws away one ID in every other type, and on real
projects in October 2026 it emptied a range that had room for the whole app several times over.
Standards **§5.0** states this rule with the AL shape; Part 5's "contiguous, sequential" blocks are
blocks **per type**.

**The allocation rule — every type starts at the bottom of its block.** Within a block (the
primary range of Parameter §1.2, or a module's sub-block under Standards §5.1), the first object of
each type takes the block's first ID, the second object of that type the next, and so on, in design
order. Table 50100, Page 50100, Codeunit 50100, Enum 50100, and Report 50100 coexist in one app.
**A number is never skipped for any reason** — not because another type already uses it, not to
line a page up with its table, not to leave room "in case". The buffer Standards §5.2 asks for is
whatever is left at the **top** of the block, counted per type: a block of 50 that holds ten tables
and seventeen pages has forty table IDs and thirty-three page IDs in reserve.

**The check — run it before every sign-off and before every generator starts.** Sort the Object
Register by type, then by ID. For each type in each block, the IDs used must be exactly the first
*n* IDs of that block, where *n* is how many objects of that type the block holds: the lowest
equals the block's first ID, the highest equals the first ID plus *n* − 1, and there are no gaps
between them. Any type whose lowest ID sits above the block's first ID, or whose IDs have a hole,
is a misallocation: **renumber before asking for the approval, and say in the message what was
renumbered and why** — never carry it forward as "already assigned". The TDD, the Design Doc, and
the Build Plan carry this check in their closing lists; Full Step 03 / Step 05 and Lite Step 2 /
Step 3 name it in their exit gates and refuse to close on a failed one; Build-a-Feature applies it to the single ID it allocates.

**The AL tools already think this way.** `al_getnextobjectid` takes an object *type* and returns
the next free ID for that type within `app.json`'s ranges; it never answers "the next ID" for the
extension as a whole. When the session has it, ask it per type. When it does not, the next ID of a
type is the highest ID **of that type** in `src/` plus one (or the block's first ID when none
exists), checked against the ranges — never the highest number in `src/` regardless of type.
Symbols are read the same way: a number a *table* in the symbol file uses is unavailable to a new
*table* only.

**Permission sets cost nothing elsewhere.** The read-only and read/write permission sets
(Standards §5.3) are objects with their own ID space, so they take the block's first two permission
set IDs and leave every table, page, and codeunit number untouched. Nothing is "reserved" for them
in any other type.

---

## Ops § AL Tools

The AL Language extension ships a standalone MCP server (`altool launchmcpserver`) exposing AL
build, publish, symbol, and diagnostic tools over the Model Context Protocol, so any MCP-capable
agent can drive them directly instead of shelling out to the compiler. Nothing runs until an MCP
host spawns it, and it exits when the host tears it down. **Two of its tools no step of the
routine calls, and the agent never offers: `al_publish` and `al_run_tests`.** Uploading a package
is the human's, by `docs/4-prove/SandboxInstall.md`, and running tests is the human's, by
`docs/4-prove/AutomatedTestGuide.md`. A developer who explicitly asks for a publish in the session
gets it — only after confirming it means a DEV extension to a named sandbox (Ops § Packaging →
*Publishing on explicit request*); never production, never as a default, never as an offered
choice. **`al_run_tests` is not used at all, even on request, and the test app is never published
by the agent** (Ops § Automated Tests). The rest — build, compile, symbols, diagnostics, object
IDs, translations — is what the agent uses them for.

**When they're needed:** from the end of intake (Full §1.10 / Lite Step 1), which downloads symbols
before DESIGN — not at the start of BUILD.

**Zero-install first** (runbook Operating Rule 6d). Everything here is already on the machine of
anyone developing AL in VS Code.
- **GitHub Copilot Chat in VS Code:** the extension's tools are built in (`al_build`, `al_publish`,
  `al_downloadsymbols`, `al_symbolsearch`, `al_getdiagnostics`, `al_getnextobjectid`,
  `al_symbolrelations`, debugging tools). Bootstrap the server below only for a tool that set lacks,
  such as `al_compile` or the translation tools.
- **Claude Code, Copilot CLI, or any other MCP host:** bootstrap below, using the extension's
  bundled `altool` and the .NET runtime VS Code already provisioned. If this session already has
  the server's tools, don't register a duplicate; add this project with `al_addproject`.
- **With the OCPF plugin:** its `al-mcp-setup` skill does the bootstrap in one step, copies the
  scripts, adds `al` to `.mcp.json`, and records the outcome as `alMcp` in `ocpfFramework/framework.json`.
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
   for byte into the project's `ocpfFramework/scripts/` folder from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/al-mcp-setup/scripts/<file>`:
   - **macOS or Linux:** `al-mcp.sh`, `al-mcp-call.sh`, `al-analyze.sh`
   - **Windows:** `al-mcp.cmd`, `al-mcp-resolve.ps1`, `al-mcp-call.ps1`, `al-analyze.cmd`,
     `al-analyze-resolve.ps1`

   Add `ocpfFramework/scripts/` to `.gitignore` (Ops § Repository Hygiene). The launcher finds the newest AL
   extension and its runtime at every launch, so extension updates never break it, and it needs no
   `PATH` edit, no `DOTNET_ROOT`, and no absolute path in any config. **If GitHub isn't reachable,**
   write the equivalent: locate `altool` in the extension's `bin/` folder and run
   `launchmcpserver --transport stdio` — `altool.exe` directly on Windows, `altool.dll` on the
   runtime VS Code provisioned on macOS and Linux.
2. **Check it:** `sh ocpfFramework/scripts/al-mcp.sh --help` (Windows: `ocpfFramework\scripts\al-mcp.cmd --help`) prints the
   `launchmcpserver` usage. An `OCPF AL MCP launcher:` message names what's missing instead. If the
   AL extension has never started on this machine, its .NET runtime isn't provisioned yet — the one
   case where the human helps: ask them to open the project folder in VS Code once, where the
   extension starts because `app.json` exists, then check again.
3. **Register it** with a relative path, adding the `al` entry without overwriting other servers.
   Claude Code and Copilot CLI read `.mcp.json` in the project root:
   - **macOS or Linux:** `{ "mcpServers": { "al": { "command": "sh", "args": ["ocpfFramework/scripts/al-mcp.sh"] } } }`
   - **Windows:** `{ "mcpServers": { "al": { "command": "cmd.exe", "args": ["/c", "ocpfFramework\\scripts\\al-mcp.cmd"] } } }`
   - **Other MCP hosts:** the same command in that host's configuration format.

   **A consequence to document, not paper over:** if that config is committed while `ocpfFramework/scripts/` is
   gitignored, a fresh clone points at a script that isn't there. Say so in the project's setup
   notes, and re-run this bootstrap on the new machine.
4. **Keep working in this session — no restart.** Claude Code and Copilot CLI load MCP servers when
   a session starts, so a server registered mid-session appears only in the next one. Don't stop,
   and don't ask the human to restart. Until the tools appear, call any of them through the one-shot
   helper, which starts the same server with this project loaded, runs one tool, prints the JSON-RPC
   response, and exits:
   ```
   sh ocpfFramework/scripts/al-mcp-call.sh . al_downloadsymbols '{"globalSourcesOnly":true}'
   sh ocpfFramework/scripts/al-mcp-call.sh . al_compile '{"options":{"onlyErrors":true}}'
   powershell -NoProfile -ExecutionPolicy Bypass -File ocpfFramework\scripts\al-mcp-call.ps1 . al_getpackagedependencies
   ```
   Each call reloads the project, so it takes a few seconds. Measured on macOS: symbol download
   under 10 seconds, compile about 5.
5. **Verify** with a call that isn't a compile, such as `al_getpackagedependencies`, or by listing
   the tools once they appear. The first compile belongs to the runbook's compile step, not here.
6. **Signing in:** tools that reach a live BC cloud environment (downloading non-global symbols)
   trigger an interactive sign-in the first time they're used, cached for the session. Log out when
   the task that reached the cloud is done.

**Standing use.** Once registered, prefer the MCP build/symbol tools over an ad hoc terminal
compiler invocation: they're the first-party path and stay current with the extension.
**The one exception is the analysis compile** (Ops § Analyzers). `launchmcpserver` also accepts AL
project paths and flags for package cache path, ruleset, and output folder; check `--help` against
the installed version rather than assuming a fixed flag set, and re-verify tool names and arguments
against the installed version rather than trusting a prior project's notes.

---

## Ops § Tooling Checks

Two tools the routine reaches for outside AL — **mermaid** for the diagrams in the documentation
step and **PowerShell 7** for translation tooling — are checked here, once, with the same
zero-install ladder as Operating Rule 6d and Ops § Asking and Approvals: what's already there first,
an install only with the human's explicit approval, never a `PATH` edit or a shell-profile change.
The step files point here (Full Step 05 and Lite Step 3 for PowerShell, Full Step 11 and Lite Step 6
for mermaid) instead of repeating the check. **Record every outcome in `ocpfFramework/framework.json`
→ `"tooling"`**, so the next session and the `status` skill read it instead of checking again:

```json
"tooling": { "mermaid": "npx-cached | installed | unavailable", "pwsh": "5.1 | 7.x | unavailable" }
```

**Mermaid** (diagrams rendered from Markdown in the documentation step):

1. `node --version` — is Node.js present?
2. `npx --yes @mermaid-js/mermaid-cli --version` — this is the check, and the way to run it. `npx`
   runs the package from its cache, with no network once cached, and installs nothing on `PATH`.
   **Never `which mmdc`** (or `where mmdc`): an npx-cached package is never on `PATH`, so that check
   answers "not installed" on a machine where mermaid works — the false negative a real project
   hit. Record `npx-cached` when this works, `installed` when a global `mmdc` happens to exist.
3. **If Node is missing**, offer — with approval, naming the command — the vendor's standard route:
   Windows `winget install --id OpenJS.NodeJS.LTS`; macOS the LTS `.pkg` from nodejs.org opened by
   the human, or `brew install node` only if Homebrew is already present; Linux the distribution's
   package (`sudo apt install nodejs npm` on Debian and Ubuntu, `sudo dnf install nodejs` on
   Fedora and RHEL). Declined or failed: record `unavailable`, and the documentation step keeps the
   mermaid source blocks in the Markdown — GitHub and VS Code render them — and says the PNG export
   was skipped.

**PowerShell 7 (`pwsh`)**:

- **Who needs it:** the XLIFF Sync module (`Sync-XliffTranslations`, `Test-XliffTranslations` —
  Ops § Translations), the `.ps1` port of the usage script (Ops § Usage & Cost), and the `.ps1`
  twin of the dashboard renderer — which is why the dashboard's hook runner is chosen by a ladder
  and proven, never assumed to be `pwsh` on Windows (Ops § Dashboard → 3). BCQuality
  *recommends* it, not requires it: its README says PowerShell 7 is recommended for fast knowledge
  discovery and that without it the review still discovers knowledge by reading the folders
  (<https://github.com/microsoft/BCQuality>, read September 27, 2026). The framework's own `.ps1`
  helpers — the AL MCP launcher, the notification script — run on **Windows PowerShell 5.1**, which
  every Windows machine has, so a Windows project without `pwsh` loses nothing until translation,
  provided the dashboard hooks were written for Python rather than `pwsh` (the ladder).
- **Check:** `pwsh --version`. Record `7.x` with the version it prints; on Windows without it,
  `5.1` (`powershell -NoProfile -Command $PSVersionTable.PSVersion` confirms); otherwise
  `unavailable`.
- **If missing, offer with approval**, the commands from Microsoft's own install pages (read
  September 27, 2026):
  - Windows: `winget install --id Microsoft.PowerShell --source winget`
    ([Install PowerShell on Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows)).
  - macOS: the `.pkg` from the PowerShell releases page, opened by the human — Microsoft's preferred
    method ([Install PowerShell on macOS](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-macos));
    `brew install --cask powershell` only if Homebrew is already present (Microsoft lists Homebrew
    under its alternate install methods).
  - Ubuntu and Debian: register `packages.microsoft.com` (the `packages-microsoft-prod.deb` for the
    release, `sudo dpkg -i`, `sudo apt-get update`), then `sudo apt-get install -y powershell`
    ([Install PowerShell on Ubuntu](https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu)).
    RHEL and Fedora: `sudo dnf install powershell` after registering the same repository.
  - Declined or failed: record `unavailable`; translation sync then waits for the human to run the
    XLIFF tooling, or uses NAB AL Tools in VS Code, which needs no PowerShell — say which.

**Why a section and not a line in each step:** the check is cheap and the wrong check is expensive.
Two real projects lost time to "mermaid isn't installed" on a machine where `npx` had it cached, and
to a PowerShell install proposed on a Windows machine whose 5.1 already ran every framework script.

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

**How to run it** — verified on AL Language extension 18.0.2732683 and again on 18.1.2842859
(October 15, 2026). On a newer release, re-verify by compiling a table with no permission set and
confirming `PTE0004` appears:
- **GitHub Copilot Chat in VS Code:** the built-in `al_build`, which reads the
  `.vscode/settings.json` analyzers when its `codeAnalyzers` argument is omitted.
- **Claude Code, Copilot CLI, or any other MCP host: `ocpfFramework/scripts/al-analyze.*` is the mandatory
  compile, not the AL MCP Server's own tools.** `al_build` ignores its own `enableCodeAnalysis` and
  `codeAnalyzers` arguments (top level or under `options`) and the workspace `.vscode/settings.json`
  analyzers (observed on AL Language extension 18.0.2732683 and 18.1.2842859; re-verify on a newer
  release) and reports `succeeded: true` while packaging code that has analyzer *errors*. It honours
  analyzers only when the server itself was launched with `--codeanalyzers` — which the framework's
  launcher never passes — and then it fails the build without listing the rule codes, so even that
  shape can't serve as the analysis compile. `al_compile` does apply them, but only when `enableCodeAnalysis: true` **and** a `codeAnalyzers` list of the
  well-known tokens (`${CodeCop}`, `${PerTenantExtensionCop}`, `${UICop}`, `${AppSourceCop}`) are
  both passed **at the top level of `options`** — not wrapped in a `parameters` key, which only
  `al_symbolsearch` takes
  ([AL MCP Server](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/al-agent-tools/al-mcp-server)),
  and not as literal analyzer DLL paths, which return `AD0001` instead of rule results. **Get any
  of that wrong and it returns a clean pass on failing code** (the one exception: a server launched
  with `--codeanalyzers` applies them to an argument-less `al_compile`, per its schema's "uses the
  server's startup configuration" — the framework's launcher doesn't launch it that way), so never
  read an `al_compile` result as a clean build unless the request had exactly that shape. It also produces no `.app`, so it's a
  fast pre-check, never Operating Rule 4's compile-and-package. Run
  `ocpfFramework/scripts/al-analyze.sh <project folder> <output .app path> [pte|appsource]` instead (Windows:
  `ocpfFramework\scripts\al-analyze.cmd`, same arguments; the profile defaults to `pte`). The plugin's
  `al-mcp-setup` skill copies it into `ocpfFramework/scripts/`; otherwise fetch it beside the launcher
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

**Prevent:** complete `app.json` once at the end of intake (its identity values were written at PRE-01 / Step 1) and download symbols then, before any
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
| *Claude app* — a push to your phone | **In Claude Code, always — unless a disqualifier is positively found.** The disqualifiers: an API key sign-in, Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, or a Claude apps gateway; or any of `ANTHROPIC_BASE_URL` (pointing anywhere but `api.anthropic.com`), `DISABLE_TELEMETRY`, `DO_NOT_TRACK`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, or `DISABLE_GROWTHBOOK` set in the environment. A claude.ai Pro, Max, Team, or Enterprise sign-in is what it needs; when the sign-in can't be checked, **offer it anyway** and say in the option's description that it needs a claude.ai subscription, and that on Team or Enterprise an Owner must have enabled Remote Control. **Never drop the option** because the sign-in is fresh, the machine is new, the phone isn't paired yet, or the operating system is Windows or Linux: none of those is a disqualifier — the pairing happens afterwards, in the Claude app, and the push settings are what this step turns on. Not offered in GitHub Copilot. Why the inversion: on a real Windows project (October 2026, a new machine, a fresh claude.ai sign-in, nothing disqualifying) the agent could not confirm the sign-in and silently dropped the option, so the human was never asked. |
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

In `ocpfFramework/state/notifications.json` — per developer, always gitignored with the rest of
`ocpfFramework/state/` (Ops § Repository Hygiene), whatever the intake said about the framework's
other files:

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
- **The script.** Add `ocpfFramework/scripts/` to `.gitignore` if it isn't there, then copy `ocpf-notify.sh`
  (macOS/Linux) or `ocpf-notify.ps1` (Windows; it runs on Windows PowerShell 5.1, and the test
  in step 5 is what proves it on this machine) into it — from the plugin's
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
    "Stop": [ { "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-notify.sh", "sound", "desktop", "Your turn: the agent finished"] } ] } ],
    "PreToolUse": [ { "matcher": "AskUserQuestion", "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-notify.sh", "sound", "desktop", "A question is waiting for your answer"] } ] } ],
    "Notification": [ { "matcher": "permission_prompt", "hooks": [ { "type": "command", "command": "sh", "args": ["${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-notify.sh", "sound", "desktop", "An approval is waiting for you"] } ] } ]
  }
}
```

On Windows, each hook runs PowerShell the same way, with only the chosen switches and each hook's
own message. `-ExecutionPolicy Bypass` lets it run the local script on a default Windows PowerShell
5.1 machine:

```json
{ "type": "command", "command": "powershell.exe", "args": ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-notify.ps1", "-Sound", "-Desktop", "-Message", "Your turn: the agent finished"] }
```

GitHub Copilot CLI sound hooks (user-level, so each command runs only in a project whose record
chose `sound`; they read `ocpfFramework/state/notifications.json` relative to where the CLI starts, so start it
from the project root):

```json
{
  "version": 1,
  "hooks": {
    "agentStop": [
      { "type": "command", "timeoutSec": 15,
        "bash": "grep -qs '\"sound\"' ocpfFramework/state/notifications.json && sh ocpfFramework/scripts/ocpf-notify.sh sound </dev/null >/dev/null; exit 0",
        "powershell": "if ((Test-Path ocpfFramework/state/notifications.json) -and (Get-Content ocpfFramework/state/notifications.json -Raw) -match '\"sound\"') { & powershell -NoProfile -ExecutionPolicy Bypass -File ocpfFramework/scripts/ocpf-notify.ps1 -Sound }" }
    ],
    "notification": [
      { "type": "command", "timeoutSec": 15,
        "bash": "grep -Eq '\"notification_type\" *: *\"(permission_prompt|elicitation_dialog)\"' && grep -qs '\"sound\"' ocpfFramework/state/notifications.json && sh ocpfFramework/scripts/ocpf-notify.sh sound </dev/null >/dev/null; exit 0",
        "powershell": "$n = [Console]::In.ReadToEnd(); if ($n -match '\"notification_type\"\\s*:\\s*\"(permission_prompt|elicitation_dialog)\"' -and (Test-Path ocpfFramework/state/notifications.json) -and (Get-Content ocpfFramework/state/notifications.json -Raw) -match '\"sound\"') { & powershell -NoProfile -ExecutionPolicy Bypass -File ocpfFramework/scripts/ocpf-notify.ps1 -Sound }" }
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
set up. On a new machine or a fresh sign-in that is the whole pairing — nothing on this computer
needs the phone first, and nothing on the phone needs to exist before the option is chosen.

### 5. Test once, with the hook's own command

Run each installed hook's exact command once from the shell — the same interpreter, the same
arguments, the same script path the hook names — and ask the human in one box whether each chosen
kind arrived and whether clicking a notification opened the session. A kind that did not arrive is
fixed or dropped now, and the record rewritten. Never conclude a hook works because the file was
written: a hook whose interpreter is missing exits silently, which is how a real Windows project
ran a whole build without a single refresh (Ops § Dashboard → 3).

**Verified September 2026:** in Claude Code 2.1.272 the `Stop` hook and a `PreToolUse` hook on
`AskUserQuestion` both fired, and the exec-form hooks block ran the script with
`${CLAUDE_PROJECT_DIR}` substituted. From documentation, not tested here: Claude Code's hook
`terminalSequence` output, push settings, and Remote Control requirements (Anthropic); the VS Code
settings and sounds (Microsoft's documentation and VS Code's source); the Copilot CLI's notifications
and hooks (GitHub's documentation and changelog). Claude Code's VS Code extension has no
notifications of its own (anthropics/claude-code issues #57230 and #29928). Linux wasn't tested. On
Windows (October 20, 2026, a new machine) a Build-a-Feature run chose desktop notifications and the
hooks were written; whether the desktop kind arrived was not recorded, which is exactly why step 5
now runs each hook's exact command and asks. Tools with neither notifications nor hooks (Claude Chat) can't
notify: say so and record `"channels": []`.

---

## Ops § Dashboard

**Every project gets a live HTML dashboard — `ProjectDashboard.html`, the *Build Map*
page — from the first minutes of the routine on.** It shows the app's name and icon, which phase
and step the project is on, tokens (Copilot: AI credits) and cost so far, elapsed time split
between the agent's work and the human's, which models are working, the current step's exit gate,
and — when a question is open — the question and where to answer it. It is a **view**, not a
record: `ProjectProgress.md` stays the written tracker, and the page is rendered from files the
framework already keeps. In a plugin project the `dashboard` skill (`/ocpf-bc:dashboard`) does
everything below; without the plugin, the scripts are fetched byte for byte from
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/agentPlugin/ocpf-bc/skills/dashboard/`.

**The page is a project file, tracked in git.** It lives at the project root, beside
`ProjectProgress.md`, and nowhere under `ocpfFramework/`; Ops § Repository Hygiene names it among
the paths that are never ignored, and the setup check proves it with `git check-ignore`. Why: in
v5.2.0.0 the renderer wrote it to `ocpfFramework/state/`, which is always ignored, so on the first
real project the dashboard did not persist with the project — exactly what the human wanted it to
do. Since v5.3.0.0 the renderer writes `ProjectDashboard.html` to the root and nothing else; the
hooks need no change. The page changes at every refresh, so `git status` shows it modified after
every turn: that is expected — commit it with the rest of the project.

### 1. When it first appears

**The moment `app.json` exists at PRE-01 / Lite Step 1** — right after the three identity
questions (Ops § Intake → *Box 0*) are answered and written, before the model questions. That is
the first moment the page has a name and an icon to show; earlier it would be an empty shell. The
runbook renders it, **opens it once in the default browser** (`--open`: `open` on macOS, `start` on
Windows, `xdg-open` on Linux — nothing installed, nothing else ever opens it unasked), installs the
refresh hooks, and then **asks the one explanation question through the options mechanism**
(Rule 6a) before anything else — **I understand** / *Other* (free text) — with this text, in the
working language:

> **Your project now has a live dashboard.** I just opened it in your browser. It shows this
> extension's name and icon, which phase and step we're on, tokens *(Copilot: AI credits)* and cost
> so far, how the elapsed time splits between my work and yours, which models are working, the
> current step's exit gate, and — when I'm waiting on you — the open question and where to answer
> it. It exists so you can see where the build stands at a glance without asking me, which also
> costs nothing: the page re-renders itself from files the framework already keeps, by hooks, with
> no model call. `ProjectProgress.md` remains the written record.
>
> **The file:** `ProjectDashboard.html` at the root of this project, next to
> `ProjectProgress.md`, tracked in git like any other project file — it is your view, and it
> travels with the project. While open it refreshes its data in place every 30 seconds — no page
> reload — and the header shows the seconds to the next refresh.
>
> **If you close the tab or window:** in VS Code's Explorer, right-click the file → **Open
> Externally** *(when that entry isn't offered: **Reveal in Finder** / **Reveal in File Explorer**
> and double-click the file)*, or ask me to "open the dashboard" and I will.
>
> *(Copilot Chat in VS Code, or when no interpreter for the hooks was found on this machine:)* There are no working hooks here, so this page refreshes at every step
> boundary rather than every turn; the header says *Refreshed* and when.

Record the answer in `docs/0-project/ProjectMemory.md`; act on a free-text answer before continuing.

### 2. What renders it, and from what

`ocpfFramework/scripts/ocpf-dashboard.py` (PowerShell twin `ocpf-dashboard.ps1`; both print the
same page) and its template `dashboard.html`, copied from the plugin's `dashboard` skill into
`ocpfFramework/scripts/` (gitignored) at first creation and refreshed with the framework
(`update-framework`). The renderer reads, and only reads:

| Source | What the page takes from it |
|---|---|
| `app.json` | name, publisher, version, BC version, `logo` (embedded as a data URI, so the page is one file) |
| `ocpfFramework/framework.json` | edition, runbook version, AL MCP state |
| `ocpfFramework/state/usage.json` | the AI tool and every step's start / close window |
| `ProjectProgress.md` | each step's status (the step table is the source of truth for *done / in progress*) |
| `ocpfFramework/runbookSteps/<step>.md` | each step's phase and title; the current step's **Exit gate** text. A remediation row (`07a`, `STEP-5a` — Ops § Usage & Cost → 7) has no step file: it sits after its base step with the title *Remediation* and a fixed three-line gate |
| the usage script's `--json` (Ops § Usage & Cost) | tokens or credits, cost, turns, decisions per step and model |
| `ocpfFramework/state/pricing.json` | price source and date; the credit price |
| the sub-agent definitions (`.claude/agents/`, `.github/agents/`) | each role's model and effort |
| Claude Code transcripts | who is working now, running sub-agents, and the **agent / you / waiting** time split, which adds up to Elapsed exactly (Ops § Usage & Cost → *8. Agent time and human time*); the first window's start, moved back to the session's first event |
| `ocpfFramework/state/waiting.json` | the open question and its options, written by the hooks |
| `ocpfFramework/state/dashboard-events.jsonl` | the recent-events strip |
| `docs/2-design/AiEffortEstimate.md` | the current step's estimate, for the *step vs estimate* bar |

**The agent never writes the HTML, never edits the template, and never types a number into the
page.** A figure the renderer cannot find is shown as *n/a* or *No estimate yet* with the reason;
a model with no rate in `pricing.json` makes the cost tile read *+ unpriced* with the model named
(never `$0`), and the fix is the `usage` skill's price fetch, not a typed figure.

### 3. Keeping it fresh — hooks, zero tokens

| AI tool | Refresh | How |
|---|---|---|
| **Claude Code** | every turn, every sub-agent return, every question opened and answered, and at least every 45 seconds inside a long turn | `Stop`, `SubagentStop`, `PreToolUse` and `PostToolUse` (matcher `AskUserQuestion`) hooks in `.claude/settings.local.json`, merged beside the notification hooks, each running the renderer with `--quiet --live` (the PreToolUse hook adds `--waiting-json` from stdin, the PostToolUse hook `--clear-waiting`); plus one `PostToolUse` hook with no matcher — every tool call, the sub-agents' included — running the renderer with `--quiet --live --throttle 45`, which returns at once when the page is younger than 45 seconds |
| **GitHub Copilot CLI** | the same moments | the same five hooks in `.github/hooks/ocpf-dashboard.json` (project level, gitignored) with the CLI's event names and `ask_user` as the tool; the unmatched `postToolUse` hook carries `--throttle 45` |
| **GitHub Copilot Chat in VS Code** | every step boundary | no hooks exist; the usage ritual's step close (Ops § Usage & Cost → 5) ends by running the renderer, and the Reasoning role's measurement brief (Full) includes it. The header reads *Refreshed · time · at step close*. Offer a refresh whenever the human asks where things stand. |
| **Every tool, every journey** | every step close (Full, Lite) or object close (Build-a-Feature) | the close render below — the agent runs the renderer once at the end of the step-close ritual, whether or not hooks exist, so a dead hook costs at most one close of staleness |

**The runner — chosen by a ladder, never assumed.** The hooks name one interpreter, and it has to
be one that exists on this machine. Probe, in this order, and take the first whose version
command answers: `python3 --version` (macOS and Linux first choice; the `.py`), then
`pwsh -NoProfile -Command $PSVersionTable.PSVersion.Major` answering `7` (**PowerShell 7** — the
`.ps1` twin uses `??` and `ConvertFrom-Json -AsHashtable`, which Windows PowerShell 5.1 cannot
parse; the Windows first choice when it exists), then `python --version` and `py -3 --version`
(the Windows launcher), each running the `.py`. On Windows the order is `pwsh`, `python`, `py -3`,
`python3`. A probe that answers with a Microsoft Store prompt or nothing has failed. Record the winner as `runner` in `ocpfFramework/state/dashboard.json`
(`pwsh`, `python3`, `python`, `py`, or `none`) and write every hook with that interpreter. The
Python hooks keep the exec form with `sh -c` on macOS and Linux; on Windows they name the
interpreter directly (`"command": "python"`, `"args": ["<root>\\ocpfFramework\\scripts\\ocpf-dashboard.py", "--project", "<root>", "--quiet", "--live"]`,
the root written out — Claude Code expands `${CLAUDE_PROJECT_DIR}` in `args` on every OS, so that
form works too). `pwsh` is **not** on every Windows machine (Ops § Tooling Checks records whether
it is), and `python3` is usually not the name on Windows: a hook written to either without the
ladder exits silently for the whole build.

**Prove the hooks before the explanation question is asked.** After the hooks are written: read
the sidecar's modification time (`ocpfFramework/state/dashboard-data.js`), run the `Stop` hook's
**exact command** once from the shell, then read the sidecar again. It passes only when the file
is newer **and** its `app.name` equals `app.json`'s `name` **and** its `framework.edition` equals
the marker's `edition` (`full`, `lite`, or `feature`). A page that says *Untitled extension* or
shows the Full map on a feature project after that run has failed the proof. On failure: run the
same command without `--quiet` / `-Quiet` to see the error, step down the ladder, rewrite the
hooks, and prove again. When nothing on the ladder runs, record `hooks: false` and `runner: none`,
say so in one sentence, and rely on the close render (next paragraph); the explanation question
then says the page refreshes at every step close, not every turn. Record `hooksVerified` (ISO
timestamp) in `dashboard.json` when the proof passes; the `status` skill reports a project whose
hooks were never proven. Why: on a real Windows Build-a-Feature project (October 2026) the hooks
were written for `pwsh` on a machine without it; `--quiet` made every run exit 0 and silent, and
the page read *Untitled extension* and *Full* from the first render until the agent's own render
at the journey's close — the only render that ever happened.

**The close render — every tool, hooks or not.** The step-close ritual (Ops § Usage & Cost → 5)
ends by running the renderer once, on every AI tool and every journey — a step close in Full and
Lite, an object's close (`F` row) in Build-a-Feature. In Claude Code and the Copilot CLI it is
redundant while the hooks work and the only refresh when they don't; in Copilot Chat it is the
refresh. One render costs well under a second and no tokens, so the page is never more than one
close stale whatever the hooks did.

A hook run costs no tokens: the script reads files and writes one file. `--quiet` makes every
failure silent with exit 0 — a dashboard that cannot render must never interrupt the agent, which
is exactly why the proof above runs once without it. The
page pulls fresh data every 30 seconds while open and repaints in place (the header counts down to
the next pull), so a hook's render appears without a keypress and without the page flashing: the
renderer writes the same data a second time as `ocpfFramework/state/dashboard-data.js`, which
the page loads through a `<script>` tag — the one kind of local load every browser allows from
`file://`. v5.3.4.0 and earlier reloaded the whole page, which AJ found jarring.
**Why the every-tool hook:** `Stop` fires only when the turn ends. On a real v5.2.0.0 project Main
delegated the FRD to the Reasoning sub-agent and the page sat frozen for the whole turn — still
showing the previous step as current and the sub-agent idle — because nothing had fired since the
turn began; reloading the page only reloads the same file. With the throttled hook every tool call
(Main's and the sub-agents') is a chance to re-render, at most once per 45 seconds, and a render
costs well under a second of file reading and no tokens.
`ocpfFramework/state/dashboard.json` records `hooks`, `theme`, `tool`, `runner`, and
`hooksVerified`; the `status` skill reports a project whose hooks are missing or were never proven.

**On a Build-a-Feature project** (`"edition": "feature"` in the marker, Ops § Build-a-Feature) the
page has no steps to show: the renderer builds its rows from the usage windows and the feature
table in `ProjectProgress.md` instead — **one row per object asked for** (`F01`, `F02`, …), plus
the intake, the package, and the review rows — grouped under the phases *Intake · Build · Review
· Package*, each row carrying its stage (*Asked → Confirmed → Built → Compiled → Documented →
Reviewed → Packaged*), its object ID, its time, and its cost; the *Objects built* tile replaces the estimate
bar (there is no estimate on this journey), the exit-gate card shows the ladder a row climbs to
close, and the roles card shows Main alone. Everything else — tokens or credits, cost, the time
split, the open question, the hooks, both themes — is the same page. A Full or Lite project on
which Build-a-Feature runs keeps its edition and its step map; its feature rows live in the usage
table and the feature table, not on the Build Map.

### 4. Themes

Two themes ship since v5.4.0.0, both with a Day / Night switch in the header and the same data
underneath; every theme is rendered on every run; `theme` in `ocpfFramework/state/dashboard.json` records the human's stated preference:

| `theme` | Template | What it is |
|---|---|---|
| `brand` (default — the one the agent opens and names unless the human asks for F1) | `dashboard.html` | *OnlyBCFans* — the Build Map page: tiles, journey line, roles, models, exit gate |
| `f1` | `dashboard-f1.html` | *F1* — a trackside pit-wall view: the Main agent is the Ferrari, the Reasoning, Light, and Generator roles are the Mercedes, McLaren, and Red Bull; steps are laps on a timing screen; tokens are fuel, cost is budget, decisions are pit stops; an open question is **BOX BOX** with the car held in its box and the question on the team radio; sub-agents leave their garages and run on the far straight while they work |

**OnlyBCFans is the default, on every journey, always.** The agent opens and names
`ProjectDashboard.html` — at first creation, on "open the dashboard", in every message — and
**never passes `--theme f1`, opens `ProjectDashboard-f1.html`, or mentions the F1 page unless the
human asked for F1 by name in this session**. Since v5.6.0.0 the renderers enforce the first
half: `--open` opens the OnlyBCFans page whatever `dashboard.json` remembers; the F1 page opens
only when `--theme f1` is passed on that very call. Why: on a real project the agent opened the
F1 page unasked, more than once; a theme is the human's taste, not the agent's.

**Switching.** Every render writes **every theme** — `ProjectDashboard.html` (OnlyBCFans) and
`ProjectDashboard-f1.html` (F1), both at the project root, both tracked — from one data build;
the second file costs a write of ~150 KB and nothing else (no tokens, no model call). So the
human switches by opening the other page: the footer selector on each page navigates to it, and
whichever page is open keeps refreshing in place from the shared sidecar. `theme` in
`dashboard.json` (set with `--theme` / `-Theme`) records the human's stated preference for the
record; it no longer decides which page opens. Both templates are copied into `ocpfFramework/scripts/` at first creation
and refreshed by `update-framework`. The F1 theme reads the same
data as the brand page, so it works with GitHub Copilot exactly as the brand page does — AI
credits instead of tokens, the Copilot pill, and the same refresh cadence per tool (every turn in
Claude Code and the Copilot CLI, every step close in Copilot Chat).

### 5. On request, and repair

**On the page itself** (both themes, no agent involved): each KPI tile and the Journey panel
collapse and expand with the chevron in their corner — the *Who is working*, *Tokens by model*,
*Exit gate*, and *Waiting on you* cards too; a collapsed *Waiting on you* card with a question open
pulses a glowing ring — and the choice is remembered per browser; the *Who is working* card shows a
green counter beside a role with the number of its sub-agents running right now;
the bottom ticker has a pause / resume button and a restart button that starts it again from the
newest message without reloading anything.

"Open the dashboard" → render, then open; say the path. "Refresh it" → render. "Use the F1 theme" /
"switch to OnlyBCFans" → render with `--theme f1` / `--theme brand` (section 4). "Where is it?" →
the path and the right-click route. A page that stopped refreshing: check the hooks still name the
scripts and `ocpfFramework/scripts/` still holds them, then run the renderer by hand and read its
notes. **A page that reads *Untitled extension*, or shows the Full map on a feature project, while
`app.json` and the marker are complete:** the hooks never ran — their interpreter is missing
(`pwsh` on a Windows machine without PowerShell 7, `python3` on Windows) — so run the ladder and
the proof in section 3, rewrite the hooks with the runner that works, and record `runner` and
`hooksVerified`. The page uses no network; it is self-contained for its first paint and loads one local
file, `ocpfFramework/state/dashboard-data.js`, for the in-place refresh — so a blank page means
the file was not re-rendered, and a page that paints but never updates means the sidecar is
missing (a renderer older than v5.3.5.0): refresh `ocpfFramework/scripts/`.


### 6. Completed, and waiting on your test

**A finished project reads *Completed*, and nobody is lit** (v5.9.5.0). Before this, a project
that was done-done still showed Main *working* and the elapsed clock running: the last hook had
rendered the page inside the 180-second "working" window and nothing ever rendered it again, and
the Build-a-Feature *Done* answer left the last window open, so Elapsed grew on every refresh.
The renderer now carries a **project state** — `completed`, `waiting`, `testing`, `working`, or
`idle` — and both pages draw it:

| State | When | What the page shows |
|---|---|---|
| **completed** | `usage.json` carries `projectClosedAt` and no window opened after it; or, in Full and Lite, the last step's row (Step 12 / Step 7 — a remediation row opened from the release test, `07a` / `STEP-5a`, doesn't count) is `Completed`; the renderer stamps `projectClosedAt` on first sight, so the clocks stop there | A green **Completed** pill with the close time in the header; a *Project completed* card where the question card sits, with the final Elapsed and cost and the line *Nothing is waiting on you*; **Who is working** shows Main **finished** and every sub-agent idle, no breathing dot; every row of the journey closed; the F1 page's pit lane cam shows the chequered flag out, the Ferrari stopped on the finish line under confetti, and the trophy on the podium, with *Race won* on the cam tag, the pit wall, and the drivers list |
| **testing** | Full and Lite only: the last step is in progress, no question is open, and Main is not working (its last transcript event is older than 180 seconds). Both pages derive it themselves on every in-place refresh, because the last render usually happened while Main still counted as working and nothing renders again while the human tests | An amber **Waiting on you · release testing** pill; a *Waiting on you* card saying the release test is in the human's hands; Main **waiting on you**; the F1 Ferrari in the box with the pit wall screens amber and *In the box · waiting on your release test* |
| **waiting** | `waiting.json` holds an open question | Unchanged: the question card, Main *waiting on you*, BOX BOX on the F1 page |
| **working** / **idle** | From the transcript, as before | Unchanged |

**What closes a project.** Three things, each enough on its own:

- **Build-a-Feature's *Done*** (Ops § Build-a-Feature → step 5): the agent runs the renderer once
  more with **`--close-project`** (`-CloseProject`) — it stamps `projectClosedAt` in
  `ocpfFramework/state/usage.json`, sets `completedAt` on any window still open (the clocks stop
  there), logs *closed the project* in the feed, and renders. A later object reopens the project by
  itself: a window that starts after `projectClosedAt` cancels it, so *Build another object* in a
  new session needs nothing undone.
- **The usage script's `--calibrate`** (Full Step 12 / Lite Step 7, the project close — Ops § Usage
  & Cost → 6) stamps the same marker before it writes the calibration file.
- **The last step's row set to `Completed`** in `ProjectProgress.md`, for a project closed by hand —
  the renderer stamps `projectClosedAt` the first time it sees it, so the clock stops there and not
  at the next render. `--calibrate` refuses to stamp while a step is still `In Progress`, so a
  mid-project cost export never reads as the close. The intended route is the first one: the
  human comes back and says *I'm done with Step 12* (Lite: *Step 7*), and the agent closes the
  row, refreshes the usage table, exports the calibration file, and stops the clocks in one go —
  Step 12 and Lite Step 7 say so in their hand-off notes.

**A stale render can't keep the light green.** Main's row now carries `lastAt`, the time of its
last transcript event, and both pages age *working* out 180 seconds after it on every in-place
refresh, hooks or not — so a session that simply ended shows Main idle within three minutes.

**The victory scene.** The pit lane cam draws the podium and stands AJ's trophy render on its P1
block (background removed, `TROPHY_SRC` in `dashboard-f1.html`); the cam is 330 units tall, too
short for the whole figure.
So the first panel of the right column, above the telemetry and in view without scrolling, is a
victory panel with his render of the Ferrari driver holding the trophy and the chequered flag
(`VICTORY_SRC`, resized to 720 px and embedded as WebP), with *P1 · Race won*, the app's name, the
close time, and the race time. Like the cars and the crew, the render is his and only cut, resized,
and embedded — never redrawn by the agent (Ops § Dashboard → 4).

---

## Ops § Packaging

Packaging starts at the runbook's mandatory compile (Full Step 07 / Lite Step 5) and recurs with
every code change after it. The Revision segment moves by itself before every build (*Version
numbers*, below); Major, Minor, and Build bumps stay separately gated.

**Naming and location — fixed, not a judgment call.** Every package is named
`<ExtensionName, spaces → underscores>_<version>.app`, with `name` and `version` read from
`app.json` at build time, never hardcoded or typed by hand. Example: `IP Tracking` at `0.0.0.7` →
`IP_Tracking_0.0.0.7.app`. It goes in a fixed folder named **`outputAppPackage/`** in the project
root — every project, that exact name, never `out/`, `output/`, or anything improvised.

**The tools don't do this by themselves — name the output explicitly.** Left to its default,
`al_build` writes `<publisher>_<name>_<version>.app`, keeping the spaces (verified September 15,
2026: publisher `OCPFReview`, name `OCPF Analyzer Repro` → `OCPFReview_OCPF Analyzer Repro_1.0.0.0.app`).
So pass the full path the framework wants — `outputPath` on `al_build`, the second argument to
`ocpfFramework/scripts/al-analyze.*` — rather than accepting the default and renaming afterwards.
**Say it twice:** once plainly at intake, before any package exists, and again with the fixed
message block below every time a build completes, never buried inside a longer status paragraph.
Confirm `app.json` identity, runtime, and dependencies still match the parameter sheet before every
build; it's cheap and catches drift before it reaches a package.

### Version numbers

Why this subsection exists: testers upload packages as per-tenant extensions through **Extension
Management**, and Business Central will not install a version that is already installed — so a
package built twice at one version is a package a tester can't upload, and the fix arrives as
"nothing happened". Versioning is therefore mechanical and always moving, not an occasional
decision.

- **A new app starts at `0.0.0.1`** — the parameter default, written into `app.json` at project
  setup. A `0.x` version says plainly that nothing has been released.
- **An existing app starts from the version installed in the target environment**, asked at intake
  (question 4b) and confirmed by the human on the **Extension Management** page before the first
  build; the project continues from it.
- **The first build of a new app is `0.0.0.1` — the version Step 01 wrote, built as is.** Every
  build after it increments first. **An existing app's first build increments from the installed
  version** (the installed version itself is never built again), and every build after it
  increments again. So the one test before any compile-and-package: *if `outputAppPackage/` holds
  no package yet and `app.json` says `0.0.0.1`, build at `0.0.0.1`; otherwise read `version` from
  `app.json`, add one to the fourth segment, write it back, then build* — `0.0.0.7` → `0.0.0.8`.
  Mechanical, no approval: this is the one edit to `app.json` that needs no proposal, because it
  changes nothing about what the version *means*. Say it in the build message, not as a separate
  decision.
- **Never build twice at one version.** If `outputAppPackage/<Name>_<version>.app` already exists,
  increment again before building. `ocpfFramework/scripts/al-analyze.sh` and `.cmd` **refuse to
  overwrite an existing output file** — exit code `4`, with the file named in the message — so a
  build that hits that exit code means the increment was skipped: fix the version, don't delete the
  file.
- **Major, Minor, and Build bumps are still proposed and approved** (Rule 6a), as below. The
  Revision moves underneath them.
- **The release candidate.** At the end of Full Step 11 / Lite Step 6, before the hand-off message,
  ask (Rule 6a): **Build the release candidate v1.0.0.0 now? (recommended)** / **Keep testing on
  0.x builds**. On yes: set `1.0.0.0`, compile and package, and write the ChangeLog entry. Fixes
  found during release testing continue `1.0.0.1`, `1.0.0.2`, … — each a new package under the
  rule above — and **the package that passes release testing ships exactly as it is**: no rebuild,
  no rename, no copy to an "immutable" name. Its version is already unique and already the one the
  testers installed, and that is what makes it the release. For an existing app the release
  candidate is the next Minor (or Major, when the change warrants it) from the starting version,
  proposed and approved.
- **Record the last installed version.** Each time the human confirms an upload, the main role
  writes "last installed version: `<version>` in `<environment>`" into `docs/0-project/ProjectMemory.md`
  (Lite: the ChangeLog). The schema line in the build message compares against it.

**The message after every build, from Full Step 06 / Lite Step 4 on, on its own lines, fixed:**

```
Package built: outputAppPackage/<Name>_<version>.app (previous build <version-1>)
Schema: additive only → upload with Schema Sync Mode = Add
   or: <what was removed / shrunk / retyped / re-keyed> → upload with Schema Sync Mode = Force Sync
       (Microsoft: test a forced sync in a sandbox first; it can lose data in <where>)
Install: you upload it — docs/4-prove/SandboxInstall.md, §1 updated for this build.
Then: tell me the version and environment you installed; I record it as the last installed version.
```

The schema line compares this build's objects against the **last package installed in a tenant**
(the recorded last installed version), not against the previous build — three additive builds after
one destructive change still need Force Sync until the destructive one has been installed. The
upload is Microsoft's own, and the human's: the Admin Center's **Manage Apps → Install Extension**
(Microsoft's recommended route), or the environment's **Extension Management → Manage → Upload
Extension** (deprecated, removed in 2027 release wave 1); for breaking schema changes both offer
the **Force** option under **Sync Mode** / **Schema Sync Mode** (Microsoft Learn, *Deploying a
tenant customization* and *Managing apps*, read October 15, 2026 — the pages name the option
**Force**; the framework's message says *Force Sync* so it can't be mistaken for anything else).

### The sandbox install guide — `docs/4-prove/SandboxInstall.md`

**The agent never uploads a package on its own initiative, and never offers to — sandbox or
production.** It builds; a person installs. So the first package of a project (Full Step 07 / Lite Step 5) is
written together with the document that person follows: `docs/4-prove/SandboxInstall.md`, from
its template (Ops § Documents). The template is nine-tenths fixed — both of Microsoft's routes,
step by step, with the exact page and action names, the permission the uploader needs, what to do
after the install, how to update to a newer build, how to uninstall, and a table of the errors
people actually hit — and one section that is this build's: **§1 names the exact package file, its
version, the Schema Sync Mode this build needs, the sandbox, and the dependencies.** The agent
rewrites §1 after every build, with the "Package built:" block, so the person always opens a
document that names the file they are about to upload. Nothing else in it changes between builds.

The cycle then waits on the human: nothing is "on the sandbox" until the human says which version
they installed and where. The agent records that as the last installed version (above) and only
then judges the next build's schema line against it. **Never assume an upload happened** because
a package was built, and never offer to do it — not through `al_publish`, not through `launch.json`
and F5, not through the Automation API. The one way a package reaches a tenant from the agent is
the explicit request below.

### Publishing on explicit request — a DEV extension, to a sandbox, confirmed first

A developer who knows the tooling may say "publish it". That is not an offer the framework makes
and not a default it falls into; it is a request the agent honors **after confirming what is
meant**, through the options mechanism (Rule 6a), because "publish" in Business Central can mean
three different things:

> You asked me to publish. To be sure: you mean publish the current package as a **DEV extension**
> to the sandbox **`<environment name>`** (type Sandbox) through the AL tools — the way F5 does —
> not a per-tenant upload through the Admin Center or Extension Management, and not production?
> **Yes — publish `<Name>_<version>.app` as a DEV extension to `<sandbox>`** / **No — I'll upload it
> myself (`docs/4-prove/SandboxInstall.md`)** / **I meant something else** (say what).

On *Yes*: call `al_publish` (or the tooling in use) with `environmentType: Sandbox` and the named
environment — read from `launch.json` and stated out loud, never from a default — and
`schemaUpdateMode: Synchronize`; **`ForceSync`, `Recreate`, and `forceUpgrade: true` still need a
separate approval naming what can be lost**, and **production is never a target, confirmed or
not**. Report the tool's result verbatim and note in the ChangeLog that the publish was human-ordered,
with the version and sandbox. **It is not the "last installed version"**: that record, and the
schema line judged against it, follow the per-tenant install the human reports from
`SandboxInstall.md`, because the testers' sandbox may still hold an older PTE while the developer's
DEV publish sits in another — keep the two apart in `ProjectMemory.md` (Lite: the ChangeLog). **The
request covers the extension only, never the test app** (`<Name>_Tests_<version>.app`), which the
human installs from `AutomatedTestGuide.md` (Ops § Automated Tests). The next build goes back to the "Package built:" block and the guide;
the request does not become the routine, and the agent does not ask "shall I publish this one
too?". A DEV-extension publish is a developer's convenience, not a tester's install: testers and
administrators still follow `SandboxInstall.md`, and a package that passes release testing still
reaches production only by the human's deploy.

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

**The protection covers every package, because every package has its own version.** Filenames
derive from `<ExtensionName>_<version>`, and *Version numbers* above guarantees no two builds share
a version, so there is never a legitimate overwrite in `outputAppPackage/` — the script's exit
code `4` enforces it. Every build that a tester installed stays on disk under its own name, and the
one that passed release testing is named in `ReleaseTestResults.md` (Lite: the ChangeLog) by its
exact filename, never inferred from a timestamp.

**Package by default during the compile-and-package cycle.** Once that cycle opens, every fix that
touches code is recompiled and repackaged before the human installs it for the next test round — the rhythm,
not an occasional offer. Outside the cycle, use judgment: a change significant enough for its own
ChangeLog entry and commit is significant enough to offer a fresh package for; a doc-only edit
isn't.

**Major, Minor, and Build bumps need a proposal and approval — never a silent edit to
`app.json`.** Propose a specific bump with reasoning and wait:
- **Major** — a breaking or structural change, such as renaming the extension or removing something
  a consumer could rely on. Rare, especially pre-release.
- **Minor** — new features, fields, or objects added backward-compatibly. The common case for a
  testing-feedback batch after release.
- **Build** — the same feature set packaged again for a different reason: a re-verification
  build, an environment change, or "package this again as-is."
- **Revision** — moves by itself before every build (*Version numbers*); it is never proposed.

**Push back on a premature ask.** Outside the compile-and-package cycle, if asked to package while
known compile errors or an unfinished batch stand, or for a bump that doesn't match what changed (a
one-field tweak billed as Major, a breaking change as a Revision), say so and recommend the right
action instead of silently complying. If the human insists, get an explicit override — but name the
mismatch first. Inside the cycle, packaging with known open issues is the whole point: that's how
they get tested.

**The agent never publishes on its own initiative, and never offers to — sandbox or production.**
The AL tools it holds can publish (`al_publish` takes `environmentType`, `schemaUpdateMode`, and
`forceUpgrade`, so it *can* force a destructive schema change on a live tenant), and no step of the
routine calls them: every package reaches a sandbox by the human's upload, following
`docs/4-prove/SandboxInstall.md` (above), and reaches production by the human's deploy at the
release step, following `docs/4-prove/Deployment.md`. The single exception is the developer's
explicit request, confirmed as a DEV-extension publish to a named sandbox (*Publishing on explicit
request*, above); production is never a target, asked or not.

**Flag Schema Sync Mode on every completed build, not only when asked** — it is the second line of
the fixed message above. Uploading a `.app` to a Business Central Online tenant through **Extension
Management** offers **Add** (the default: warns and refuses an incompatible schema; no data loss) or
**Force Sync** (overwrites the schema even when the change is destructive — removals, a changed
primary key, an incompatible type or length change — and can lose data; Microsoft's guidance is to
test a forced sync in a sandbox first). Check what the build actually changed against the last
installed version and fill the line: additive only → Add; anything removed, shrunk, retyped, or
re-keyed → Force Sync, naming what can be lost and where. Never assume the human knows, and never
let a schema-breaking change go out without the warning. (`schemaUpdateMode` — `Synchronize` / `Recreate` / `ForceSync` — is the same-named but separate
setting `launch.json` holds for a developer's own F5 publish; it isn't the Extension Management or
Admin Center choice, so don't conflate the two when explaining this to the human.)

---

## Ops § Repository Hygiene

Some things a project needs locally are not the client's deliverable and should never reach the
project's own git remote, even though they sit in the working directory like any other file.

**The repository exists before the first ignore check — on every journey.** Everything below, and
every `git check-ignore` and `git add` the routine runs, assumes a repository. So the first time a
journey writes `.gitignore` (Full PRE-01, Lite Step 1, Build-a-Feature's folders-and-ignore-list
step), run `git rev-parse --is-inside-work-tree` first. Not a repository: run `git init -b main`
and say so in one line — it is local, reversible, and asks for nothing; the human decides later
whether and where to push. Already inside a work tree (the project is a folder of a larger
repository): use that repository, say so, and write the ignore entries relative to the project
folder. Never create a nested repository inside an existing one. Why: on a real Build-a-Feature
project (October 2026) no journey had ever said `git init`, every ignore check and `git add` ran
against nothing, and the human found an untracked folder at the end of the build.

**Always kept out of git tracking — not a choice, not asked about per project:**
- **`.claude/settings.local.json`** — each developer's own Claude Code settings, including the
  notification hooks (Ops § Notifications). Added to `.gitignore` when the choice is made, even
  when the framework's own files are tracked.
- **`ocpfFramework/state/`** — everything per developer: `notifications.json` (the notification
  choice), `copilot.json` (the Copilot session settings record — the approval keys themselves go to
  user settings unless the human chose to share them), `usage.json` (step timestamps),
  `pricing.json` (fetched prices), and `previous/` (backups the framework update keeps). One entry
  covers the folder (Ops § Notifications; Ops § Asking and Approvals; Ops § Usage & Cost; Ops §
  Plugin).
- **`ocpfFramework/standardsGuide/` and `ocpfFramework/opsGuide/`** — the two fetched guides. Added
  when they're fetched. They're the framework author's cross-project methodology, refetchable at
  will, not part of what the client is paying for.
- **`ocpfFramework/runbookSteps/` and `ocpfFramework/documentTemplates/`** — the runbook's step
  files and the document templates, fetched with the guides (Ops § Fetched Companions), the same
  methodology, refetchable at will.
- **`ocpfFramework/patterns/`** — the fetched patterns library, for the same reason as the
  Standards Guide.
- **`ocpfFramework/scripts/`** — the framework's own plumbing: launchers, the one-shot helper, the
  analyzer compile script, the notification script, the dashboard renderer and its template.
- **The BCQuality snapshot and the OnlyBCFans BC Copilot Blueprint** — kept outside the project
  root entirely (Ops § Fetched Companions explains why `alc` forces that: both ship `.al` files
  that are not this project's objects), so neither is even a candidate for tracking.
- **`*.g.xlf`** — regenerated on every build (**Standards §8.2**). The per-language target files in
  `Translations/` **are** deliverables and always tracked.
- **`.alpackages/`** — downloaded dependency symbols, refetched in seconds (Ops § Symbols), so
  there's no reproducibility reason to track them. A sandbox download also carries Microsoft's own
  source and translation files, which must never be committed (**Standards §8.5**). Microsoft's
  AL-Go templates ignore it too.
- **Microsoft's translation files**, read for terminology (**Standards Appendix D**): read them
  where they are, inside the ignored `.alpackages/`, or extract them outside the tracked tree.

**Gitignored by default, with an intake question:** the rest of `ocpfFramework/` — its README,
`framework.json`, the runbook changelog and schematics, and the runbook itself when `CLAUDE.md`
already existed — plus the runbook where the tools place it (`CLAUDE.md`,
`.github/copilot-instructions.md`, `.github/instructions/ocpf-framework.instructions.md`) and the
project-local sub-agent definitions per harness (Ops § Roles → *Enforcement*; the `analyze`
skill's `ocpf-analyst` with them, Ops § Existing Apps). The runbook's
intake asks this one (question 18); both answers are legitimate: *Yes* keeps the client's repository
about the client's app; *No* lets a teammate who clones it see exactly how it was built.

**The block to write, by name.** "The framework files" is not an entry; each path is. With the
intake answer *Yes*, the project's `.gitignore` carries this block, exactly:

```
# OCPF BC Agentic Development Framework — always ignored (Ops § Repository Hygiene)
.claude/settings.local.json
ocpfFramework/state/
ocpfFramework/standardsGuide/
ocpfFramework/opsGuide/
ocpfFramework/runbookSteps/
ocpfFramework/documentTemplates/
ocpfFramework/patterns/
ocpfFramework/scripts/
.alpackages/
*.g.xlf

# OCPF BC Agentic Development Framework — framework files (intake answer: not tracked)
ocpfFramework/
CLAUDE.md
.github/copilot-instructions.md
.github/instructions/ocpf-framework.instructions.md
.claude/agents/ocpf-light.md
.claude/agents/ocpf-reasoning.md
.claude/agents/ocpf-generator.md
.claude/agents/ocpf-reviewer.md
.claude/agents/ocpf-analyst.md
.github/agents/ocpf-light.agent.md
.github/agents/ocpf-reasoning.agent.md
.github/agents/ocpf-generator.agent.md
.github/agents/ocpf-reviewer.agent.md
.github/agents/ocpf-analyst.agent.md
```

With the answer *No, track them*, only the first group is written. The first group's
`ocpfFramework/…` entries stay even though the second group's `ocpfFramework/` would cover them:
they are what keeps the always-ignored files out when the answer is *No*, and a reader of the file
sees which rule is a choice and which isn't. Drop an agent-definition entry only for a harness the
project doesn't use. **Never** ignore `docs/`, `requirements/` (`requirements/existing/` included), `images/`,
`outputAppPackage/`, `*.app`, `Translations/*.xlf`, `ProjectProgress.md`, `ProjectDashboard.html`,
`ProjectDashboard-f1.html`, or `src/`. The dashboard page
is the one file the framework renders that **is** the project's: it lives at the root for that
reason (Ops § Dashboard), and a renderer, a hook, or a hand-written entry that puts it under
`ocpfFramework/` or adds `*.html` to `.gitignore` is a bug — v5.2.0.0 made exactly that mistake.

**Prove it, don't assume it.** After writing the file, run `git check-ignore -v <path>` for each
framework file that exists on disk and `git status --porcelain` in the root: a framework file that
`check-ignore` doesn't name, or that `status` lists as untracked or modified, means an entry is
missing or misspelled — fix it before moving on. Then run `git check-ignore -v ProjectDashboard.html
ProjectDashboard-f1.html ProjectProgress.md`: it must print **nothing** (exit 1) — a match means an entry is too broad, and
the human's dashboard would vanish from every clone. A `.gitignore` that was "written per the runbook"
but never checked is how the changelog reached a client's remote on a real project.

**Always tracked:** the project's own documents — all of them under `docs/`, in their phase folders, and the help site at `docs/`' root when one was built (`index.html`, `site.json`, `template.html`, `build.py`, `.nojekyll`, `assets/`, `screenshots/` — Ops § Help Site; GitHub Pages publishes the tracked folder, so an ignored screenshot is a broken image on the live site)
`docs/0-project`, `docs/1-define`, `docs/2-design`, `docs/3-build`, and `docs/4-prove` (the
runbook's rule: Full Operating Rule 9, Lite's header note; the map is in Ops § Documents), with
`ProjectProgress.md` the one document at the root in **both** editions, and the dashboard pages
`ProjectDashboard.html` / `ProjectDashboard-f1.html` beside it (Ops § Dashboard) — its AL source under `src/`
(the app icon included), `requirements/`, `Translations/*.xlf`, and every package in
`outputAppPackage/` (Ops § Packaging).

**Never** ignore the project's own `docs/0-project/ChangeLog.md` — see the block above.

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

**The glossary — `docs/1-define/TranslationGlossary.md`**, created at intake and current at every step after.
**Lite:** it lives inside `docs/2-design/DesignDoc.md` and is created at the design step, not at intake. One row per standard BC concept the extension names: the concept, the
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
   `Sync-XliffTranslations`, which needs PowerShell 7 — checked once in Ops § Tooling Checks). New
   units arrive as `needs-translation`; changed source text drops its unit to `needs-adaptation`
   (**§8.7**).
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
3. **Package, have the human install it (`docs/4-prove/SandboxInstall.md`), and test in each
   language** — the tester switches **My Settings → Language**
   (and **Region** for formats) and walks the changed pages, messages, and reports, looking for
   untranslated text (usually a hard-coded string), truncation, and wrong regional terms.

**Full only — roles.** Terminology verification is the light role's (Operating Rule 10)
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
  libraries (`Library Assert`, `Any`, `Library Variable Storage` — the three an online sandbox can install, below), exercising the app's actual business logic — tables, codeunits, pages — directly in AL,
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
- **If AL test codeunits are created, write `docs/4-prove/AutomatedTestGuide.md` as well**, from its
  template (Ops § Documents): the person's step-by-step for getting the test app and Microsoft's test
  framework into a sandbox and running the tests **one at a time** on the **AL Test Tool** page — a
  row per test method saying what it checks, the expected result, and the setup it needs, with the
  exact page captions, action names, and the prompt choices. It assumes the reader has never opened
  the page. Both documents are revised every time the tests change.

**What an AL test app may depend on — online sandboxes decide this.** Microsoft's **Test Runner**
(the AL Test Tool page) has been installable in an online sandbox from the marketplace since 17.2;
the three Test Framework libraries — **Library Assert**, **Any**, **Library Variable Storage** —
are Microsoft-published apps that practitioners report installing in online sandboxes by App ID
(the Admin Center API, or BcContainerHelper's `Install-BcAppFromAppSource -appId`) when the
marketplace page doesn't list them, and no Microsoft page confirms either way — so the guide tells
the tester to stop and report if one isn't offered, and the agent then says plainly what that
sandbox can and cannot run. The **Tests-TestLibraries** and **System Application Test Library**
apps (`Library - Sales`, `Library - Random`, `Library - Utility`, and the rest) are **not**
available online, and Microsoft said there were no plans to add them (Freddy Kristiansen, *Running
tests in Business Central Online Sandbox environments*, February 2021). So a test app
this framework writes depends on the extension under test and, of Microsoft's, only those three
libraries — never on Tests-TestLibraries — or the human cannot install it. Build it as its own
package, `outputAppPackage/<ExtensionName>_Tests_<version>.app`, versioned in step with the
extension, from a `test/` folder with its own `app.json` and its own object ID range in the Object
Register.

### Running AL test codeunits — the human, from the guide

**The agent does not publish the test app or run tests in Business Central — not on its own
initiative and not on request.** The AL MCP Server ships an `al_run_tests` tool (`codeunitId`,
`testMethods`, `projectPath`, `environmentName`, `environmentType`; seen in AL Language extension
18.1.2842859 on October 15, 2026, and not on Microsoft's *AL MCP Server* reference page), but on
real projects in October 2026 the agent could not get the test app published to a sandbox or its
tests run through the AL tools. So `al_run_tests` is never called, and a "publish it" request
(Ops § Packaging) never covers the test app. **A developer who asks the agent to run the tests**
is told plainly that running them is the human's, from `AutomatedTestGuide.md` §7, and that
agent-run tests are on the framework's roadmap; the agent then waits for the reported results. It
never reports a pass nobody ran. When
AL test codeunits exist, the agent writes `docs/4-prove/AutomatedTestGuide.md` (above), builds the
test app, and hands both over. The human installs the test framework apps once, installs the
extension and the test app (`docs/4-prove/SandboxInstall.md`), opens the **AL Test Tool** page, and
runs the rows of the guide's §6 one at a time — **Run Tests → Active Line** — reporting each row's
**Result** and, on a Failure, the full **Error Message** text (message and call stack).

**Tests never run in a production environment.** Tests write data; Microsoft refuses to run them in a
production environment and the guide says so. The guide also carries Microsoft's sandbox limits:
no test method over fifteen minutes, and not more than an hour or two of test runs a day.

**Where it fits.** The tests run after a clean analyzer compile, once the human has installed the
build — as part of the runbook's documentation step and again at release testing — not instead of
the human unit test script, which covers what a person must see in the UI. **A failing test fails
the step**, exactly like a compiler error: the agent diagnoses from the reported message and stack
(reasoning role), fixes the extension or the test, builds both packages at the next version, and
the human runs the failed rows again, then a full pass. The step closes on a full pass with no
Failure, or with a written record of why a test could not be run — never on a pass nobody ran.

---

## Ops § Fetched Companions

Four bodies of knowledge are fetched into (or beside) each project, so the agent reads them from
disk rather than from memory: the **Standards Guide**, the **BCQuality** snapshot, the **OCPF BC AL
Patterns** library, and — when the project builds a Business Central Copilot feature — the
**OnlyBCFans BC Copilot Blueprint**. **This Operations Guide is fetched the same way** — the runbook
says when. All five are refetchable at will, so none is ever committed (Ops § Repository Hygiene),
and each carries a small `SNAPSHOT.json` recording the source repo, ref, commit SHA, and fetch
timestamp, so a later refresh has something to diff against and report. **Tell the human before
fetching; none of these is a silent background download.**

### The Standards Guide

Fetched at the routine's first step, before anything else needs it, from **its own repository**,
`https://github.com/ajansari/ocpfBCALStandards/` — the guide has been published standalone since
Full v5.2.0.0 / Lite v5.2.0.0 so the AL community can use it without this framework — **at the
release tag the framework pins**, never from `main`:

```
https://raw.githubusercontent.com/ajansari/ocpfBCALStandards/<pinned tag>/ocpfALDevStandardsGuide.md
  → ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md   (+ SNAPSHOT.json)
```

The pinned tag is named in the framework repository's `standardsGuide/README.md` (the *prelude*:
purpose, relationship to the runbook, the authoritative-source rule in Step 01 terms, and the
"what is deliberately not in the guide" map), which is fetched beside the guide into the same
folder as `README.md`. For runbook **v5.9.5.0 the pin is `v1.13.1.0`** (Standards Guide 1.13.1.0).
The on-disk path and filename are unchanged from the days the guide lived in this repository, so
no step file, runbook, or agent definition cites anything new. `SNAPSHOT.json` records
`"repo": "ajansari/ocpfBCALStandards"`, the tag, the commit SHA, and the fetch time.

- **Pin a tag, not `main`.** The guide has its own release cadence. A newer tag may add rules the
  runbook does not yet cite; the runbook moves its pin in a framework release, never on its own.
  The standalone repository commits to append-only numbering, so **Standards §** citations keep
  resolving across its releases.
- **Not optional.** The runbook cites **Standards §** from its first steps on. If the repository
  isn't reachable, say so plainly and ask the human for a copy rather than working from memory.
  **Exception with the OCPF plugin:** it bundles the pinned release in the `al-standards` skill.
  Use it, record `"source": "ocpf-bc plugin bundle"` and the bundled version in `SNAPSHOT.json`,
  say plainly which version was used, and offer a refresh once the network is back.
- **Refresh only when the human asks** ("refresh the standards guide"). Re-fetch the pinned tag,
  overwrite, and report: "updated from `<old sha>` to `<new sha>`", or "already up to date." A
  request to move to a *newer* tag than the pin is a framework update, not a refresh — say so.
- **Version skew is named, not papered over.** If the fetched guide's `**Version:**` line doesn't
  match the pin, say so rather than silently reconciling a citation that doesn't resolve.

### This guide, the step files, and the document templates

Fetched in the same call, from the framework repository
`https://github.com/ajansari/ocpfBcAgenticDevFramework/`: `opsGuide/ocpfOperationsGuide.md` into
`ocpfFramework/opsGuide/`, `standardsGuide/README.md` into `ocpfFramework/standardsGuide/`
(repository paths in the raw URL, `ocpfFramework/…` on disk). Everything lives **inside** the
project root — single Markdown files with no `.al` objects, so nothing forces them outside — and
is always gitignored, not a per-project choice. The runbook's changelog (`RunbookChangelog.md` /
`LITE_RunbookChangeLog.md`) and, when placed, its schematics go in `ocpfFramework/` beside them,
never in the project root. This guide is not optional either, and its version is tracked in
`ocpfFramework/RunbookChangelog.md` with the runbook; a mismatch is skew, named the same way.

The step files and the document templates come from the same repository, in the same call, gitignored the same way:

| From the repository | Into the project | What it is |
|---|---|---|
| `fullVersion/steps/*.md` (Full) or `liteVersion/steps/*.md` (Lite) | `ocpfFramework/runbookSteps/` | One file per step of the runbook the project follows. **The step file is the step**: the core runbook (`CLAUDE.md` / `copilot-instructions.md`) carries only a stub per step so that every turn doesn't carry every step. |
| `documentTemplates/*.md` | `ocpfFramework/documentTemplates/` | One template per project document (Ops § Documents). |

**File lists, so the fetch needs no directory listing** (`raw.githubusercontent.com` serves files,
not folders):
- Full steps: `PRE-01.md`, `PRE-02.md`, `01.md`, `02.md`, `03.md`, `04.md`, `05.md`, `06.md`,
  `07.md`, `08.md`, `09.md`, `10.md`, `11.md`, `12.md`.
- Lite steps: `STEP-1.md` … `STEP-7.md`.
- Templates: `FRD.md`, `TDD.md`, `SanityCheck.md`, `HumanEffortEstimate.md`,
  `HumanEffortBaselines.md`, `AiEffortEstimate.md`, `BuildPlan.md`, `ChangeLog.md`,
  `GapAnalysis.md`, `CodeReview.md`, `Documentation.md`, `UserGuide.md`, `HumanUnitTestScript.md`,
  `Deployment.md`, `ReleaseTestResults.md`, `Acknowledgements.md`, `ProjectProgress.md`,
  `SandboxInstall.md`, `AutomatedTestGuide.md`, `DesignDoc.md`, `Docs.md`, `TestScript.md`,
  `FeatureRegister.md`, `FeatureDataModel.md`, `FeatureDocumentation.md`. Both editions fetch the
  whole set; Build-a-Feature fetches only the ones it writes (Ops § Build-a-Feature).

**The URL for every one of them** is the raw file, never the repository page:
`https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/<folder>/<file>` — for
example `…/main/fullVersion/steps/PRE-01.md`, `…/main/liteVersion/steps/STEP-1.md`,
`…/main/documentTemplates/FRD.md`. Download each byte for byte (`curl -fsSL <url> -o <file>`),
never through a summarizing fetch.
**Version check:** every step file's `**Runbook version:**` line must equal the core runbook's
version; a mismatch is skew — say so and refetch the set the runbook names. The plugin bundles all
of them for the offline case (the steps in the `start` skill's `references/`, the templates in the
`documents` skill's `references/`). **Refresh with the runbook**: the `update-framework` skill
replaces the step files and templates whenever it replaces the runbook.

**Read a step file when its step starts, in full, and not before.** Reading every step file at the
first step recreates exactly the context load the split removed.

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
- **This one lives INSIDE the project root**, in `ocpfFramework/patterns/` — every file is Markdown with embedded
  AL, not a real `.al` object, so there's no compile-breaking risk — and it's always gitignored.
- **If the repository isn't reachable, say so and continue.** An absent patterns library isn't a
  blocker.
- **Merging, not overwriting.** If `ocpfFramework/patterns/` doesn't exist, create it. If it exists and already has
  its own `README.md`, append the fetched README under a fixed delimiter rather than replacing it:
  ```
  ---
  ## Upstream README — ajansari/ocpfBCALPatterns @ <commit SHA>
  ```
  That delimiter makes a refresh idempotent: replace the block from that heading to the end of the
  file instead of appending a second copy. Add any pattern files not already present; if a
  same-named file exists locally with different content, ask which to keep rather than overwriting.
- **Refresh only on request**, with the same merge behavior, and report what changed.

**Using it, twice.** *Before writing:* the generation step reads the pattern files that match the
objects in the batch — child lists and list parts, setup pages, wizards — alongside Standards Part 11,
which holds the two rules those patterns became after they kept recurring on projects that had the
library fetched and never opened it. *Before diagnosing:* check whether `ocpfFramework/patterns/` already documents
this class of problem — turning a previously solved bug into fast recognition instead of fresh
investigation. If a fix here looks like it will recur on future projects, flag it
to the human as a candidate for a new pattern; contributing back is their call, not the agent's.

### OnlyBCFans BC Copilot Blueprint — when the project builds a Business Central Copilot feature

`ajansari/obcfBCCopilotBlueprint` on GitHub (<https://github.com/ajansari/obcfBCCopilotBlueprint>,
MIT, the framework author's own) is a **verified, end-to-end reference design for a Business
Central Copilot feature in AL** — the signature Copilot UI: a `Copilot Capability` enum extension
and its 4-parameter registration, a `PromptDialog` page with its system actions, the host page's
`Prompting` action, the System.AI codeunits for both the **Microsoft-billed** path (Microsoft-managed
Azure OpenAI, no Azure subscription, no key) and the **Partner-billed** path (the customer's own
Azure OpenAI endpoint), setup, wizard, telemetry, install and upgrade, a symbol-verified API
reference for BC 27.5, nine compilable AL templates, and a table of **31 false assumptions** agents
keep making about BC Copilot. It exists because the framework and most AI coding tools get this
feature wrong or declare it impossible — "a PTE cannot register a Copilot capability", "Copilot
needs an Azure subscription", "`RegisterCapability` takes three parameters", "the dialog closes
with `LookupOK`" — and a shipped per-tenant extension proved every one of those wrong.

- **When:** fetched the moment the project is known to include a Copilot feature — normally at the
  scaffold step (Full Step 05 / Lite Step 3) when the intake sheet's **Business Central Copilot
  feature** answer is *Yes*; otherwise the moment a Copilot feature is asked for later — in any
  journey, Build-a-Feature included, or in plain chat with no project: the plugin's
  `copilot-blueprint` skill fires on the ask and does this fetch. A project with no Copilot feature
  never fetches it.
- **Where:** **OUTSIDE the AL project's root**, like BCQuality — a sibling folder such as
  `../<ProjectName>.copilotBlueprint/` — because `templates/` holds nine real `.al` objects (prefix
  `PFX`, IDs 50100–50199) that `alc` would otherwise compile into the project. Shallow clone
  **at the release tag the framework pins** (`v1.0.0.0` for runbook v5.9.5.0; the Blueprint pins
  its claims to a BC version, so a tag matters), `.git` stripped, `LICENSE` kept (MIT), and a
  `SNAPSHOT.json` with repo, tag, commit SHA, and fetch time. Nothing to gitignore: it isn't in the
  tracked tree. **In Claude Code, also copy the folder to `.claude/skills/obcf-bc-copilot-blueprint/`**
  (gitignored with the other framework files) so the skill triggers on *Copilot*, *PromptDialog*,
  *Azure OpenAI*, and on an agent about to say something is not possible; in Copilot the rule in
  the runbook (ALL ALONG → *Business Central Copilot Features*) is the trigger.
- **Using it:** the Blueprint's `SKILL.md` is the entry point and its **15-step procedure is the
  build order for the feature's objects**, inside this framework's own steps: the FRD (Full Step 02
  / Lite Step 2) names the capability, the host page, the billing path(s), and what the AI
  suggests, citing the Blueprint; the TDD (Full Step 03 / Lite Step 2) specifies every object from
  `references/01-architecture.md` and the templates, billing path from `03` or `04`, the dialog
  from `05`, the engine from `06`, setup/wizard/telemetry/upgrade from `07`; generation (Full Step
  06 / Lite Step 4) starts from `templates/`, renamed and renumbered to the project's prefix and
  ranges, never from a blank file; compile fixes (Full Step 07 / Lite Step 5) check
  `references/08-api-reference-bc27.md` before memory; Code Review (Full Step 09 / Lite Step 6)
  walks `SKILL.md` section 3's done checklist and section 2's non-negotiable rules as a review
  dimension. **Before any statement that a BC Copilot thing is impossible, unsupported for PTEs,
  or needs an Azure subscription, read `references/09-false-assumptions.md` and cite the row** —
  or drop the claim.
- **Where the Blueprint and the Standards Guide seem to disagree, the Standards Guide wins** and
  the Blueprint has a bug (its own README says so); report it to the human as a candidate fix.
  Where the Blueprint's BC version differs from the project's target, say so: its claims are
  pinned to BC 27.5, and `references/08` documents how to re-extract the API from newer symbols.
- **Refresh only on request**, and report what changed. Moving to a newer Blueprint tag is a
  framework decision, recorded in the framework changelog like the Standards pin.

---

## Ops § Documents

Every document the routine produces has a template in `ocpfFramework/documentTemplates/` (fetched at the first
step, Ops § Fetched Companions). **A document is written from its template**, never from a structure
improvised in the moment: the template fixes the headings, the tables, and the "before calling it
done" checks; the step file says what goes in them. In a plugin project the `documents` skill
(`/ocpf-bc:documents <name>`) does this — it reads the template and the step file, gathers the named
inputs, drafts (delegating to the reasoning role where the step says so), and writes the file into
its folder under `docs/`.

**`docs/` is laid out by phase, numbered so it sorts in the order the work happens** — both
editions, the same five folders; a document goes in the folder of the phase that writes it and stays
there:

```
docs/
  0-project/   ChangeLog.md  ProjectMemory.md (Full)  Roadmap.md (Full)  TestingFeedback.md (Full)
               Acknowledgements.md
  1-define/    ProblemStatement.md (Full)  ProjectParameters.md  ObjectRegister.md (Full)
               TranslationGlossary.md (Full)
  2-design/    FRD.md  TDD.md  SanityCheck.md (Full)  DesignDoc.md (Lite)
               HumanEffortEstimate.md  AiEffortEstimate.md
  3-build/     BuildPlan.md (Full)
  4-prove/     GapAnalysis.md  CodeReview.md  PostDevTDD.md  Documentation.md  UserGuide.md
               HumanUnitTestScript.md  AutomatedTestScripts.md  Deployment.md  ReleaseTestResults.md
               (Full)  ·  Docs.md  TestScript.md (Lite)  ·  SandboxInstall.md (both, at the first
               package)  ·  AutomatedTestGuide.md (both, when AL test codeunits exist)  ·
               translated copies beside their source:
               UserGuide.fr-CA.md, Docs.fr-CA.md, TestScript.fr-CA.md
```

`ProjectProgress.md` is the one document outside `docs/`: in the project root, both editions.
`ProjectDashboard.html` sits beside it — not a document but the rendered view of this one (Ops §
Dashboard), tracked the same way.
Nothing is written loose in `docs/` **on Full or Lite** — with one exception, the **help site** (Ops § Help
Site): `docs/index.html`, `docs/site.json`, `docs/template.html`, `docs/build.py`, `docs/.nojekyll`,
`docs/assets/`, and `docs/screenshots/` sit at `docs/`' root because GitHub Pages serves that folder as
the site, and nothing else may.

**Build-a-Feature is the exception, by design: its `docs/` is flat.** A feature project writes six
short documents and no more, and numbered phase folders that skip numbers hid them (AJ, October
16, 2026). So, on edition `feature`:

```
docs/
  ProblemStatement.md  FeatureRegister.md  DataModel.md  Documentation.md  ChangeLog.md  SandboxInstall.md
```

written **as the work happens** — the register and the data model before each object's
confirmation box, the documentation section when the object compiles — never all at the close
(Ops § Build-a-Feature → *The record*). When Build-a-Feature runs **on** a Full or Lite project,
the project's phase folders stay and the same files go into them (`1-define/FeatureRegister.md`,
`2-design/DataModel.md`, sections appended to `4-prove/Documentation.md` or `Docs.md`, lines in
`0-project/ChangeLog.md`, `4-prove/SandboxInstall.md`).

| Template | Document | Written at |
|---|---|---|
| `FRD.md` | `docs/2-design/FRD.md` | Full Step 02 |
| `TDD.md` | `docs/2-design/TDD.md`; also the base for `docs/4-prove/PostDevTDD.md` | Full Step 03; Step 10 |
| `SanityCheck.md` | `docs/2-design/SanityCheck.md` | Full Step 04 |
| `HumanEffortEstimate.md` | `docs/2-design/HumanEffortEstimate.md` | Full Step 03 / Lite Step 2, in the same pass as the design |
| `HumanEffortBaselines.md` | **Read, not written.** The default hours-per-task table for a fast US senior AL developer that the Human Effort Estimate prices from. If `~/.ocpf/HumanEffortBaselines.md` exists — the partner's own table in the same shape, outside every project — it replaces the default, and the estimate's §1 says which was used and its date. | Read at Full Step 03 / Lite Step 2 |
| `AiEffortEstimate.md` | `docs/2-design/AiEffortEstimate.md` — tokens per step × model × token type, cost at the fetched prices, wall-clock from BUILD on with approvals at 30 minutes each, the margin in force, and what the calibration store contributed (Ops § Usage & Cost → *Calibration*) | Full Step 03 / Lite Step 2, same pass as the Human Effort Estimate, main role, not delegated |
| `BuildPlan.md` | `docs/3-build/BuildPlan.md` | Full Step 05 (Lite keeps the plan in chat and the ChangeLog) |
| `ChangeLog.md` | `docs/0-project/ChangeLog.md` | first entry, both editions |
| `GapAnalysis.md` | `docs/4-prove/GapAnalysis.md` | Full Step 08 |
| `CodeReview.md` | `docs/4-prove/CodeReview.md` — §0 Scorecard (eight dimensions, A–F, overall = the lowest) before the findings | Full Step 09 (Lite writes the same scorecard table into its Step 6 ChangeLog entry) |
| `Documentation.md`, `UserGuide.md`, `HumanUnitTestScript.md`, `Deployment.md` | the four Step 11 documents, in `docs/4-prove/` | Full Step 11 |
| `SandboxInstall.md` | `docs/4-prove/SandboxInstall.md` — the human's upload procedure; §1 rewritten with every build | Full Step 07 / Lite Step 5, with the first package; Build-a-Feature Part 6, with the package |
| `AutomatedTestGuide.md` | `docs/4-prove/AutomatedTestGuide.md` — install the test app and run each test on the AL Test Tool page | Full Step 11 / Lite Step 6, only when AL test codeunits exist |
| `Acknowledgements.md` | `docs/0-project/Acknowledgements.md` — one row per resource actually used (author, license, how it was used), always committed | Full Step 11 / Lite Step 6 |
| `ReleaseTestResults.md` | `docs/4-prove/ReleaseTestResults.md` | Full Step 12 |
| `ProjectProgress.md` | `ProjectProgress.md` (root) — the step table for the project's edition (the template carries both; delete the other) and the usage table, **both editions** | Full PRE-01 / Lite Step 1, then every step start and close |
| `FAQ.md` | `docs/4-prove/FAQ.md` (`docs/FAQ.md` on a feature project) — one `###` per question, answered from the User Guide, the Documentation, the Deployment guide, the test script's red-team cases, and the ChangeLog's findings; nothing invented; the help site's FAQ tab, each question collapsible | Full Step 11 / Lite Step 6 when the help site's FAQ tab is chosen (Ops § Help Site), or on request |
| `DesignDoc.md`, `Docs.md`, `TestScript.md` | `docs/2-design/DesignDoc.md`; `docs/4-prove/Docs.md` and `docs/4-prove/TestScript.md` | Lite Steps 2 and 6 |
| `FeatureRegister.md`, `FeatureDataModel.md`, `FeatureDocumentation.md` | `docs/FeatureRegister.md`, `docs/DataModel.md`, `docs/Documentation.md` on a feature project (phase folders on a Full or Lite project) — with `ChangeLog.md` and `SandboxInstall.md` from the templates above and a `ProblemStatement.md` in Lite Step 1's shape | Build-a-Feature, as the work happens: register §1 and the problem statement at the intake close; a register row and a data-model section before each confirmation box; a documentation section and a ChangeLog line at each compile; the parts that span objects at the close |

**Rules for writing from a template:**
- Keep every heading the template has, in its order. A section that genuinely doesn't apply stays,
  with *N/A — <reason>* under it, so a reader can tell "not applicable" from "forgotten".
- Replace every `<placeholder>`; none survives into `docs/`.
- Work the template's closing checklist before the exit gate, and leave it in the document, ticked.
- The template's own front-matter block (the `> Template …` note at the top) is removed from the
  written document.

### Briefing a drafting role

When a step delegates the draft to the reasoning role (Full Steps 02, 03, 04, 08, 09), the
delegation is a **narrow brief**, and that narrowness is what makes the step fast:

- **Pass:** the step file from `ocpfFramework/runbookSteps/`; the document's template; the named inputs (the
  files the step's **Inputs** line lists, as paths — the sub-agent reads them itself); the **exact**
  Standards § sections the template cites, by number, so the sub-agent reads those and no more; the
  Project Parameters file; and the instruction to open its report with `Model:` (Ops § Roles).
- **Never pass:** the core runbook, a whole guide, the conversation so far, the ChangeLog beyond the
  entries the step names, or "everything in `docs/`". Every one of those was, on a real project, how
  a two-minute draft became a twenty-minute one.
- **Ask for the document text only**, in the template's structure, plus a short list of open
  questions for the human. The main role integrates: saves it to its folder under `docs/`, does the
  ChangeLog and ProjectMemory bookkeeping, and takes it to the human for sign-off.

**Why the templates exist:** on real runs the FRD, TDD, and Sanity Check each took a long time, and
most of the tokens went into re-deciding structure, re-reading guides that weren't needed for the
document at hand, and re-stating what an upstream document already said. The template removes the
first, the brief removes the second, and the rule that the TDD cites the FRD rather than restating
it removes the third.

---

## Ops § Help Site

**What it is.** A polished HTML documentation and support page for the extension — one file,
`docs/index.html`, built from the project's own Markdown documents: the app icon and name, a
tagline and the version, a download button for the package, *Get support* and *View on GitHub*
links, an optional banner and publisher logo, and a sticky tab bar — **User Guide**,
**Documentation**, **FAQ** (each question collapsible), **Deployment**, and any other guide the
project wrote — with headings, tables, code, the Mermaid schema diagram drawn in the browser,
and the human's screenshots. Deep links work, it prints, it needs no server, and GitHub Pages
serves it from `docs/`. The Markdown stays the record; the page is **built from it and rebuilt
whenever it changes**, never written by hand and never a second copy to keep current. The
reference build is the OnlyBCFans Google Address Validator's help site (October 2026), whose
template and build script the plugin's `html-docs` skill carries.

**When.** Full Step 11 and Lite Step 6 offer it in a box once the step's documents exist and
before the release-candidate question — *Build the help site now (recommended)* / *Not now — ask
me again at the hand-off* / *No help site for this project* — and record the answer in the
ChangeLog either way. **Build-a-Feature never offers it**: a quick mod's close is two minutes.
On request — "build the help site", "HTML documentation", `/ocpf-bc:html-docs` — it runs on any
project with an `app.json` and a `docs/`, a feature project included, and asks everything itself:
which tabs, screenshots, identity and links. In a project without the plugin the procedure is the
same, with the template and script copied from the plugin's `skills/html-docs/templates/`.

**The files — all under `docs/`, all tracked** (Ops § Repository Hygiene), the one exception to
Ops § Documents' "nothing loose in `docs/`": GitHub Pages' *Deploy from a branch* publishes only
the root or `/docs`; the reference project's ChangeLog records trying `docs/help/` and a root
`help/` (which made the whole repository root the site) before settling on `docs/`.

| File | What | Who writes it |
|---|---|---|
| `docs/index.html` | the site, one page | the build; never edited by hand |
| `docs/site.json` | the project's configuration: name, tagline, links, colors, the tabs in order (key, title, source document, optional `section` heading regex, `kind: faq`), `dropSections`, `substitutions` | the agent, from the human's answers |
| `docs/template.html` | the page shell; CSS tokens (`--accent` …) are the only thing restyled per project | copied from the skill |
| `docs/build.py` | converts each tab's Markdown (through `npx marked`, else Python `markdown`; nothing installed), strips the document's own title, meta lines, and closing checklist, escapes `<placeholders>`, rewrites `../screenshots/`, wraps tables, gives every heading a deep-link id, turns an FAQ's `###` into collapsible entries, fills the template, writes `.nojekyll`, and **prints what to review**: repository paths, internal review codes, design-document references, build-status remarks, unbalanced HTML, missing images | copied from the skill; never edited per project |
| `docs/.nojekyll` | tells Pages to serve the files as they are | the build |
| `docs/assets/` | `app-icon.png` (copied from `src/logo/AppLogo.png`), the banner and the publisher logo when the human has them | the agent; nothing fetched or drawn here |
| `docs/screenshots/` | the human's screenshots, renamed by the agent | the human drops them in; the agent renames |
| `docs/4-prove/FAQ.md` (`docs/FAQ.md` on a feature project) | the FAQ, from its template (Ops § Documents) | the `documents` skill, when the FAQ tab is chosen |

**Tabs.** Full: `UserGuide.md`, `Documentation.md`, `FAQ.md`, `Deployment.md`, any other guide in
`docs/4-prove/`. Lite: `Docs.md`'s user-guide and deployment sections as tabs of their own
(`section` in `site.json`), the rest as *Documentation*, and `FAQ.md`. Feature project:
`docs/Documentation.md`, an FAQ, and a User Guide written then if wanted. The human chooses in one
multi-select box; a chosen document that doesn't exist is written first, from its template.

**The FAQ** is written from `FAQ.md`'s template — one `##` per topic, one `###` per question —
answered only from the User Guide, the Documentation, the Deployment guide, the test script's
red-team cases (every refused action is a question), the ChangeLog's testing findings, and the
questions the human has actually heard (asked, free text). Nothing invented; a question without a
source is left out; fifteen to thirty questions is the target.

**Screenshots** are the human's to take and the agent's to name. The agent asks early (*Yes — I'll
add screenshots* / *No* / *Later*), says where — `docs/screenshots/`, any file name, PNG
preferred — and what, as a list taken from the User Guide's task sections (one per thing the
guide tells the reader to open, click, or look at; standard light theme; test data only), then
waits. When they're in it **looks at every file**, says what each shows, proposes a name in the
shape `<page-or-object>-<what-is-happening>.png` (lowercase, hyphens, ASCII: `setup-page.png`,
`wizard-2-api-key.png`, `error-not-set-up.png`), shows the whole old → new list in one box, renames
only after that answer (`git mv` when tracked), and places each in the Markdown where the guide
talks about it — `![<what it shows>](../screenshots/<name>.png)` right after the sentence that
tells the reader to open that thing, one per step at most. A file no document references is
listed to the human; a reference without its file is a build warning fixed before the site is
called done.

**Build, review, look.** `python3 docs/build.py` from the project root. **Every `review [...]`
line the build prints is acted on**: a repository path (`docs/4-prove/Deployment.md`), a review code
(`OQ-12`, `GA-3`, `CR-2.1-4`), a design reference (`TDD §14`), or a build-status remark (*not yet
tested*) is wrong for the extension's users — fix the Markdown when the sentence is wrong for any
reader (a path to a document that is now a tab becomes *the Deployment tab*); add a
`substitutions` pair or a `dropSections` heading in `site.json` only when the repository's readers
must keep the text. An **UNBALANCED HTML** line names a panel with an unclosed tag — a stray
`<placeholder>` or a literal tag in the Markdown — and a panel left unbalanced bleeds into every
panel after it (a blank FAQ tab on the reference build); fix the source. Then the agent **looks at
every tab before the human does**: open the page with the OS opener, and where Chrome or Edge can
run headless (the `app-icon` skill's ladder) screenshot each tab and read the images — hero
complete, every tab present, no `{{PLACEHOLDER}}`, tables framed, diagram drawn, screenshots shown.
One box to accept or change; a restyle touches `template.html`'s CSS tokens only.

**Publishing — GitHub Pages, the Help link, the record.** The closing message gives the human the
steps as a numbered list with the real owner, repository, and URL: push; *Settings → Pages* →
*Build and deployment* → *Deploy from a branch* → the default branch, folder **`/docs`** → Save;
wait a minute or two; the site is at `https://<owner>.github.io/<repo>/`; open it and click every
tab. Say plainly that a private repository needs GitHub Pro, Team, or Enterprise Cloud for Pages,
and that the site is public either way unless the organisation has access-controlled Pages. The
agent never changes a repository setting, never pushes. Then it writes the URL into `site.json` →
`helpUrl` (the page's canonical link) and rebuilds once; **offers** to set `app.json` → `help` to
it — or, when intake's Box 4D recorded a URL, to replace that one, named in the question — Business
Central shows it as the extension's **Help** in Extension Management, AppSource
requires it, and it is a change to the package: the next build increments the Revision and its
ChangeLog entry names the help link (Ops § Packaging; a package already uploaded is never rebuilt
at the same version); puts a link under the README's title; writes the ChangeLog entry (tabs,
FAQ, screenshots renamed old → new, `.nojekyll`, the Pages setting and URL, the `help` decision);
and stages everything with `git add`. **From then on every change to a source document — a Step
12 / Step 7 fix, a new FAQ question, a new screenshot — reruns the build before that step
closes**, and `status` reports a `docs/index.html` older than its sources.

**Never:** an install (the converter ladder stops and asks, as Ops § Tooling Checks does for
Node); a repository setting changed, a push, a publish; the site anywhere but `docs/`; the page
edited by hand; `build.py` edited per project; an invented FAQ answer or screenshot; a logo,
banner, or color fetched from the web (Ops § Intake → *Forbidden sources*); `app.json` → `help`
set before the human said yes; the offer on Build-a-Feature; a question in prose.

---

## Ops § Usage & Cost

**Purpose:** a per-step, per-model record of what the AI work actually consumed — **tokens by type
in Claude Code, AI credits in GitHub Copilot**, each the unit its tool records and bills in —
priced from published rates, next to the hours a senior AL developer would bill for the same step.
The two tools get **two different usage tables** (*4. The table*); a project's table is the one for
its `aiTool`, and the two are never mixed in one row. It answers the client's question ("what
did this cost?") with measurements, not impressions. In a plugin project the `usage` skill
(`/ocpf-bc:usage`) does everything below; without the plugin, follow it by hand.

### 1. Timestamps — `ocpfFramework/state/usage.json`

Written at the routine's first step and appended to at every step start and every exit gate, the
same moment the step's `ProjectProgress.md` row changes (both editions — *5. The step boundary
ritual*). Per developer, always gitignored.

```json
{
  "aiTool": "claude-code",
  "transcriptDir": "~/.claude/projects/-Users-aj-Projects-contosoApp",
  "steps": [
    { "step": "PRE-01", "startedAt": "2026-09-19T14:02:11Z", "completedAt": "2026-09-19T14:41:05Z" },
    { "step": "PRE-02", "startedAt": "2026-09-19T14:41:05Z" }
  ]
}
```

At project close one more field appears, **`"projectClosedAt"`** (ISO 8601, UTC): stamped by the
usage script's `--calibrate` (Full Step 12 / Lite Step 7) or by the renderer's `--close-project`
(Build-a-Feature's *Done*), with any window still open given that `completedAt`. The dashboard reads
it as *Completed* and stops its clocks there; a window that starts later cancels it (Ops § Dashboard
→ 6).

`aiTool` is `claude-code`, `copilot-chat`, or `copilot-cli`. **`step` is the step file's name without
`.md`, and nothing else:** `PRE-01`, `PRE-02`, `01` … `12` in Full; `STEP-1` … `STEP-7` in Lite;
a remediation is the base step plus a letter — `07a`, `STEP-5a` — with a `title` (*7. Remediation*);
on Build-a-Feature, where there are no step files, the feature table's row ids — `F00`, `F01`, …,
`FPK`, `FRV` — with an optional `title` the dashboard shows (Ops § Build-a-Feature). The
usage table's first column, the `usage` skill's `--step` argument, and this file all use that
spelling. A step reopened later gets a second entry with the same `step`; windows are summed. **An
open window ends where the next window starts**, so a step left without `completedAt` never absorbs
the steps after it. **The first window is opened as the very first act of the routine** — before
the working-language question — and the usage script and the dashboard renderer also stretch it
back to the first event of the session that opened it (*8. Agent time and human time*), so nothing
the session did before the agent got round to writing `startedAt` is left outside every window. A Copilot project's file also holds `copilot.journalDirs` (and, for a
project that began on the pre-SDK chat, `copilot.sessionDirs` and `copilot.checkpoints`) — written
by the usage script, never by hand (*2. Measuring*). Without these timestamps nothing can be attributed
to a step, so a missing file is fixed the moment it's noticed: create it, and mark earlier steps
`n/a — no timestamps` in the table rather than back-filling guesses.

### 2. Measuring

**Claude Code** writes every request's usage to the session transcript on disk, per message, and
that file is the source — not `/cost`, not memory:

- **Where:** `~/.claude/projects/<project key>/*.jsonl`, where the project key is the project's
  absolute path with every `/` replaced by `-` (macOS and Linux; on Windows, `%USERPROFILE%\.claude\projects\`
  with the drive and separators encoded the same way). Record the folder in `usage.json` once.
- **What:** every line whose `type` is `assistant` carries `timestamp`, `message.model`, and
  `message.usage` with `input_tokens`, `output_tokens`, `cache_creation_input_tokens`,
  `cache_read_input_tokens`, and `cache_creation.ephemeral_5m_input_tokens` /
  `ephemeral_1h_input_tokens` (which cache-write rate applies). Sub-agent work (the `Agent` tool) is **not** in the session's own file: each session `<id>.jsonl` has a sibling folder `<id>/subagents/agent-*.jsonl`, one file per sub-agent, whose lines carry `isSidechain: true`, the sub-agent's `message.model`, and the same `message.usage` and `requestId` fields. Read both — a reader that globs only the top-level files reports the Reasoning and Light roles as never having run and leaves their tokens out of every total, which is what v5.2.0.0 did on a real project.
- **Dedupe by `requestId`.** One API response produces several `assistant` lines (text, then each
  tool call), all carrying the same `requestId` and the same usage; count each `requestId` once. A
  line with no `requestId` is skipped and counted in a note, never counted by another key.
- **Attribute by timestamp** to the step window(s) in `usage.json`; lines outside every window are
  reported as *unattributed*, not dropped.
- **Also count, per step:** turns (lines whose `type` is `user`, whose content holds no
  `tool_result` block, and that aren't sidechains), decisions asked (`AskUserQuestion` tool calls),
  sub-agent invocations (`Agent` tool calls, or `Task` in older transcripts), and web requests
  (`usage.server_tool_use`, reported in the row's *Notes*).
- **Cache writes are priced even without the TTL breakdown:** any `cache_creation_input_tokens` not
  covered by the 5-minute / 1-hour split are priced at the 5-minute rate. Nothing measured is ever
  priced at zero silently.

**GitHub Copilot — VS Code's Copilot Chat and the Copilot CLI** bill in **AI credits** — GitHub's
usage-based billing, on every plan since June 1, 2026, which replaced premium requests. Each model
call's input, cached, and output tokens are priced at that model's published rate and converted to
credits. Since VS Code 1.139 (September 2026) Copilot Chat's agent mode runs on the **Copilot SDK**,
the same engine as the CLI, and **the SDK journals every session on disk; that journal is the
source** — the agent reads it, the human reads nothing:

- **Where:** `~/.copilot/session-state/<session id>/events.jsonl` (macOS and Linux;
  `%USERPROFILE%\.copilot\session-state\` on Windows) — one folder per session, whether it ran in
  VS Code's chat or in the CLI. The journal's `session.start` event carries `context.cwd`, the
  project folder, and that is how the script finds a project's sessions; a session journaled on
  another machine (a remote, WSL, or dev-container window keeps it there) is named with
  `--journal <its session-state folder>`. The script records the folder in `usage.json` as
  `copilot.journalDirs`.
- **What:** `session.usage_checkpoint` and `session.shutdown` carry `totalNanoAiu`, the session's
  **cumulative cost in nano-AI-units — 1,000,000,000 to the AI credit** (the SDK's
  `NANO_AIU_PER_AIU`; checked against the Session Info popover on a real project: the popover said
  1,055 credits at a step close, the journal 1,143 ninety seconds and a few requests later).
  `session.shutdown` also carries `modelMetrics`, the same figure per model. Every model request is
  an `assistant.message` event with its model and timestamp; every question to the human is an
  `ask_user` tool call; every sub-agent is a `subagent.started` event. Sub-agents are folded into
  the session's figure.
- **What the journal does not hold:** per-call usage. The SDK's `assistant.usage` event is streamed
  live and never written to disk (GitHub's streaming-events reference marks it ephemeral), and a
  **checkpoint is written when the chat ends, not per turn**. So inside a session the cumulative
  figure is exact only at those points. Between two known points the script **splits the
  difference across the step windows by each window's share of model requests**, and the table's
  footnote says so. The project total is the sum of the sessions' last known figures: exact once a
  session has ended, *as of* its last checkpoint while it is open — the next measurement picks up
  the rest.
- **No token totals by type.** `session.shutdown` reports tokens per model for the whole session
  only, and the context meter is not consumption. **The Copilot table has no token columns**, and
  a token figure is never derived from credits.
- **One row per step**, its *Model(s)* cell naming every model that answered in it, *Notes* saying
  *n request(s), session journal*. A per-model split of a step would be a second estimate on top of
  the first; the session's exact per-model figures are in the `--json` output and the calibration
  export for whoever wants them.
- **Also counted, per step:** turns (the human's prompts plus every `ask_user` the human
  answered), decisions asked (`ask_user` calls), and sub-agent invocations (`subagent.started`).
- **The pre-SDK chat** (VS Code before 1.139) kept per-turn credits in
  `<VS Code user data>/User/workspaceStorage/<hash>/chatSessions/<session id>.jsonl`; the script
  still reads those files when present, with the checkpoint arithmetic they need, so a project
  that spans both formats loses nothing. The format is VS Code's own (microsoft/vscode#338007,
  closed as not planned, September 2026); the SDK journal is documented by GitHub.
- **Nobody reads a number from the screen.** `--session-credits <n>` still exists for the one case
  where no journal and no chat file exists on any reachable machine; the row then says *read from
  the popover by the human*. A run that asks the human for the popover figure while a journal
  exists is a bug — name the journal folder instead.
- **A cross-check, not a source:** `--reconcile` asks GitHub's billing API (`gh api
  /users/<login>/settings/billing/ai_credit/usage`, classic token with the `user` scope: `gh auth
  refresh -s user`) for the account's month-to-date AI credits and prints them under the table.
  It covers everything the account did that month, so it bounds a project's total; it never fills a
  row. The same figure is on github.com → *Settings → Billing and licensing → AI usage*.

**Ollama** through Claude Code or another harness: local models report token counts through the
harness the same way and cost `$0`; Ollama's cloud models are priced per million tokens on
`https://ollama.com/pricing`, read the same way as any other published rate.

### 3. Pricing — `ocpfFramework/state/pricing.json`

Prices are **fetched from the publisher's own page at first use, dated, and cited** — never typed
from memory, never hardcoded in a runbook or a skill, since they change. **Since 5.8.0.0 the usage
script does the fetch itself:** at every measurement, a Claude model with no row in `pricing.json`
is looked up on Anthropic's pricing page (served as Markdown at `…/pricing.md`, parsed by the
table's columns, matched by the model id's prefix so a dated id like `claude-sonnet-4-5-20250929`
finds *Claude Sonnet 4.5*), and a Copilot project with no `aiCredit` gets *1 AI credit = $x USD*
from GitHub's page; the rows are written with the source and the date, the attempt is recorded
(`autoFetchFailedAt`, written only by a failed fetch and cleared by a success, so a new model is
priced at once and an offline machine's hook renders don't hammer the page — retry after an hour), and the table's notes say what was fetched. Why: on a real Build-a-Feature project
the agent never wrote `pricing.json`, every row of the build said *price unknown*, and the
dashboard read `$0` for Claude Sonnet 5.5 — a model whose price had been public all along — until
the human forced the fetch after the last window closed. The agent's part is now only what the
script cannot do: a publisher the script doesn't cover (Ollama cloud, another vendor), a machine
that is offline (the note says so — fetch when online), or a model the page doesn't list.
The pages:

- Anthropic: `https://platform.claude.com/docs/en/about-claude/pricing` (input, output, cache-write
  at 5-minute and 1-hour TTL, cache-read; per million tokens).
- Ollama cloud models: `https://ollama.com/pricing`. Local models: `0`.
- GitHub Copilot: `https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing` — **the
  value of one AI credit in USD**, stored as `aiCredit`. Copilot's per-model token rates are on
  the same page; the usage table doesn't need them, because VS Code has already applied them —
  the AI Effort Estimate does (Ops § Documents).
- Any other publisher: its own pricing page, cited by URL.

```json
{
  "fetchedAt": "2026-09-19",
  "currency": "USD",
  "perMillionTokens": {
    "claude-sonnet-5": { "input": 0, "output": 0, "cacheWrite5m": 0, "cacheWrite1h": 0, "cacheRead": 0,
                         "source": "https://platform.claude.com/docs/en/about-claude/pricing" }
  }
}
```

A Copilot project's file carries the credit's value instead of, or beside, the token rates:

```json
{
  "fetchedAt": "2026-09-29",
  "currency": "USD",
  "aiCredit": { "usd": 0, "source": "https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing" }
}
```

(Zeros above are placeholders — the file is only ever written from a page just read.) **Cost of a
Copilot row = AI credits × `aiCredit.usd`**; with no `aiCredit` entry the row says *price unknown*.
Cost of a Claude Code request = input × input rate + output × output rate + 5-minute cache writes × 5m rate + 1-hour
cache writes × 1h rate + cache reads × cache-read rate, each divided by 1,000,000. A model with no
row gets *price unknown* in the table, and the human is asked once whether to fetch it. Refresh the
file when the human asks or when a model appears that it doesn't cover; say the date the prices were
read in the table's footnote. **A subscription doesn't bill per token or per credit until its allowance is used up** (Claude
Pro/Max; a Copilot plan's included monthly credits): the table still shows the published-rate
equivalent, labelled *at published rates*, because that is the number a client comparison needs.

### 4. The table

It is the **second table of `ProjectProgress.md`**, under the step table — **in both editions**;
Lite no longer keeps a separate usage report. Refreshed at every step close; the template
(`ocpfFramework/documentTemplates/ProjectProgress.md`) fixes the columns, **one set per AI tool —
keep the table for the project's `aiTool` and delete the other**:

**Claude Code — tokens by type** (thirteen columns):

| Step | Model(s) | Input | Output | Cache write | Cache read | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|

**GitHub Copilot — AI credits** (ten columns):

| Step | Model(s) | AI credits | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |
|---|---|---|---|---|---|---|---|---|---|

Everything but the consumption columns is the same in both, and means the same. A project that
changes tools midway keeps **both** tables, each with the steps worked in that tool, and a line
between them saying when the tool changed.

- **Claude Code: one row per model that ran in the step** — the Main model's row and one for every
  sub-agent model — never one row for the step with a single model in it. **Copilot: one row per
  step**, every model named in it (*2. Measuring*). Then a **Total** row, and a footnote naming the
  pricing source and the date read. *Elapsed*, *Turns*, and *Decisions* belong to the
  step, so they appear on the Main model's row and `—` on the sub-agent rows.
- The *Senior AL dev est.* column is filled from `docs/2-design/HumanEffortEstimate.md` once it
  exists (Full Step 03 / Lite Step 2) — the estimate's per-task hours summed to the step they belong
  to.
- In the Copilot table a step is **one row**, *Model(s)* naming every model that answered in it
  and *Notes* saying *n request(s), session journal* (a pre-SDK chat's rows keep *main, n turn(s)*
  / *sub-agent, n call(s)*); the footnote names the credit's price, its source, the date read, and
  the journals read, with how many sessions have ended and how many are still open. The table's
  **Total is the sum of the sessions' journaled figures** and, once every session has ended,
  equals what the Session Info popovers showed. Both editions use the same columns; Lite's
  sub-agent column counts the generator and the skills' delegations.
- A step with no timestamps, or worked in a tool that exposes nothing, says why. **Never a blank,
  never a guess.**

### 5. The step boundary ritual

Usage is recorded at **every** step boundary, in the same message as the boundary itself — not at
the end of the project, not "when there's time". Both editions, the same words (Full Operating Rule
11, Lite Rule 9 point here):

- **Step start:** append `{ "step": "<id>", "startedAt": "<now>" }` to
  `ocpfFramework/state/usage.json` and set the step's `ProjectProgress.md` row to `In Progress`.
  Same moment, same message.
- **Step close — before the closing message (summary, then the pasted rows, then the Rule 6c box as its last thing):** set `completedAt`; run the
  measurement — with the plugin `/ocpf-bc:usage --step <id>`, without it parts 1–3 above by hand —
  and write the step's rows into the usage table — **one row per model that ran in the step** in
  Claude Code, **one row per step** in Copilot. Then **paste those rows into the closing message**,
  so the human sees them without opening the file.
- **The exit gate is not met until the rows exist.** A step whose rows are missing is not closed;
  the next step does not start on a missing row, and the `status` skill reports a missing row for a
  closed step as a blocker.
- **Never hand-write a row, in either tool.** The script reads the transcripts (Claude Code) or
  the Copilot session journals and already aggregates per step, sub-agents included. A hand-written
  row is exactly how a real project ended up with one model credited for everything, when three
  had run. **The human is never asked to read a figure from the screen**: a Copilot run that asks
  for the popover's Session Cost while a journal exists is a bug, not a procedure.
- **Copilot in VS Code (Full): the Reasoning role runs the measurement.** The main role delegates
  it to the project-local `ocpf-reasoning` sub-agent, Rule 10 in force (the §1.7 model, in the
  background, the report's first line verified). The brief carries five things and nothing else:
  the project root; the step id; the exact command — `python3 <usage skill folder>/scripts/ocpf-usage.py --project "<root>" --step <id>` (PowerShell: the `.ps1` twin) — and the
  instruction to run it twice, once as printed and once with `--json`, then run the dashboard
  renderer once (`python3 ocpfFramework/scripts/ocpf-dashboard.py --project "<root>" --quiet`),
  and **return the measurement's outputs verbatim: the table, every `*Note:*` line, and the JSON's
  `sessions` summary**, adding nothing and fixing nothing. The main role writes the returned rows into the table and pastes them; a
  report without the table, or with a row the script did not print, is rejected and the delegation
  rerun. The Reasoning role never asks the human for a figure either. Why a delegation for a
  script: on a real Copilot project the Main model skipped the script and asked the human for the
  popover figure at every step close; the measurement is a procedure with no judgment in it,
  which the Reasoning role follows exactly, for a handful of requests' worth of credits. Claude
  Code projects, the Copilot CLI, and Lite (no Reasoning role) keep the main role running it.
- **The step close ends by refreshing the dashboard — on every tool, every journey.** After the
  rows are written and pasted, run the renderer once with the recorded `runner`
  (`python3 ocpfFramework/scripts/ocpf-dashboard.py --project "<root>" --quiet`, or the `.ps1`
  under `pwsh`, or `python` / `py -3` on Windows — `ocpfFramework/state/dashboard.json` says
  which). In Full on Copilot Chat the Reasoning role's brief ends with the render command, so the
  page is refreshed when the measurement returns; everywhere else the main role runs it. On
  Build-a-Feature the close of every `F` row is a step close for this purpose. In Claude Code and
  the Copilot CLI the hooks do the same between closes; when they don't (an interpreter the hooks
  name is missing — Ops § Dashboard → 3), this render is the only one, and the page is never more
  than one close stale. Why: on a real Windows project the hooks exited silently for the whole
  build and the page showed *Untitled extension* until the journey's closing render.
- **Copilot: the figure refines when the chat ends.** The journal's cumulative credits are exact at
  a checkpoint, which the SDK writes when the chat ends; a step closed mid-chat gets its share by
  request count, and the next measurement after the chat ends settles it. Say *as of* in the
  closing message when a session is still open.

Why a ritual and not a reminder: on a real project the table was "to be filled in later", and later
the windows were gone. Recording at the boundary costs one command; reconstructing costs the data.

### 6. Calibration — `~/.ocpf/calibration/`

At project close (Full Step 12 / Lite Step 7), the `usage` skill — or the agent by hand — writes
**`~/.ocpf/calibration/<project>-<date>.json`**, outside every project: per step and per model, the
tokens by type (Claude Code) or the AI credits (Copilot — `aiCredits` and `role` per model, token
fields `null`), elapsed time, turns, and decisions, plus the project's object counts by type. It is
the partner's own measured history, not the client's, which is why it lives under the home folder
and not in `docs/`. The AI Effort Estimate (Ops § Documents) reads every file there at the next
project, derives per-object and per-step averages when they exist, and says so in its margin
section — ±30 % until three or more measured projects are in the store, then the framework's ±10 %
target. A project with no store is estimated from the template's baselines and says that instead.
Tell the human once, when the first file is written, where it is and what reads it. The export
also stamps `projectClosedAt` in `usage.json` and closes any window still open (→ 1), so the
dashboard reads *Completed* (Ops § Dashboard → 6).

### 7. Remediation — `07a`, `07b`, `STEP-5a` …

**When testing or a late requirement change forces a major rebuild — the FRD and TDD (Lite: the
Design Doc) have to be redone and objects regenerated — that work is a *remediation*, and it gets
its own row on the journey, not a reopened step.** Why: a reopened Step 07 window hides that the
design changed after it was approved, makes one row carry two builds' cost, and leaves the human
reading the dashboard unable to see that the project went back. A remediation row shows it.

- **Id:** the base step's id plus a letter — Full `07a`, then `07b`, …; Lite `STEP-5a`, `STEP-5b`,
  … The base is **the compile-and-package step** (Full Step 07, Lite Step 5), because that is what
  the remediation must bring back to green, whatever step the project was on when the change
  arrived (Step 08's gap-fit, Step 09's review, Step 12's release test, Lite Step 7's testing).
- **A fix inside the Step 07 / Step 5 cycle is not a remediation.** A failed test, a wrong field,
  a missed tooltip: the cycle in the step file handles it, under the same window. A remediation
  is when the *design* changes — a new or removed object, a changed schema, a changed rule — and
  the FRD or TDD (Lite: the Design Doc) is updated in place with a ChangeLog entry that names the
  remediation.
- **The ritual is the step ritual** (*5. The step boundary ritual*): the moment the human agrees
  the change is a rebuild, append `{ "step": "07a", "title": "Remediation — <what changed>",
  "startedAt": "<now>" }` to `usage.json` and add the row `| BUILD | 07a — Remediation | In
  Progress |` to `ProjectProgress.md`'s step table, **directly under the base step's row**. Do
  the FRD / TDD update, the regeneration, and the compile-and-package under that window; close it
  with `/ocpf-bc:usage --step 07a` and the rows pasted; end with the Rule 6c box offering the step
  the project came from (*Back to Step 12's release test* / *Stop here*). **Opening `07a` closes
  the window of the step the project was on** (an open window ends where the next starts, *1.*),
  so *Back to Step 12* **reopens it**: a second entry with `"step": "12"` and a new `startedAt`
  (summed as a reopened step), its row left `In Progress` throughout; Step 12's own close later
  writes its rows from both windows. While `07a` is open two rows read `In Progress`; the
  dashboard shows the remediation, which precedes Step 12 on the journey.
- **The dashboard** (Ops § Dashboard) inserts the row on the journey line after its base step —
  `07a · Remediation` — in the base step's phase, with its own time, tokens, and cost; the
  exit-gate card shows the remediation's three conditions. Nothing else changes.
- **Which steps say so:** Full Step 07, Step 08, and Step 12, Lite Step 5 and Step 7 each carry
  one paragraph pointing here; the `usage` and `status` skills accept the ids.

---

### 8. Agent time and human time

The dashboard's time tile (Ops § Dashboard) splits the project's elapsed time three ways from the
Claude Code transcript — nothing is estimated, the gaps between the transcript's events are
classified:

| Gap, from → to | Counted as |
|---|---|
| the human's prompt → the agent's next event | **agent** |
| an agent event → the next agent event or tool result | **agent**, up to 10 minutes; anything beyond is **you** (the turn ended and nobody prompted) |
| an **options box opened** (`AskUserQuestion` / `ask_user`) → its answer, which arrives as a tool result | **waiting** — since v5.8.0.0; before it, this read as agent time, which is why the split "never added up" |
| the agent's turn ended → the human's next prompt | **you** |
| a window with no transcript event at all | **you** — nobody was in the chat |

Each step's split is scaled to that step's window, and the totals to the union of every window
(a reopened step or a remediation open beside another counts once), so **agent + you + waiting =
elapsed, exactly**, on the tile and in the JSON. **The first window begins where its session
began:** the renderer and the usage script find the session (Claude Code: the transcript file;
Copilot: the journaled session) whose span contains the first window's recorded `startedAt` and
move the start back to that session's first event — never to an earlier, separate session in the
same folder — so the clock and the tokens begin together; the rows say so in a note. Work that
still falls outside every window (after the last window closed) is an *Unattributed* row, in the
total, named in a dashboard note. Copilot has no per-turn transcript, so its tile shows elapsed
time only and says so.

---

## Ops § Journeys

**Three journeys, one standard.** Every journey fetches and applies the same Standards Guide and
patterns library, compiles with the same analyzers, keeps `ProjectProgress.md` and the dashboard,
measures usage at every boundary, and closes every step through the options box. What differs is
how much of the engineering *process* the work needs — not how many files it has. **Full is the
recommended journey.** Build-a-Feature and Lite are the offers for smaller work, taken when the
human says the work is a quick customization or a modest update — never pushed. The `start`
skill's journey question lists the three in **one fixed order — Build-a-Feature, Full
(recommended), Lite** — an explicit exception to the recommended-first rule of Ops § Asking and
Approvals, so the human sees the smallest journey first and the recommended one marked. Every
list of the journeys, in every document and on the website, keeps that order. The words:

**Build-a-Feature — quick customizations, when time is of the essence.** Extend a table or a page,
a processing report, a table and its pages, an API, a role center, an enum, a permission set: a
tactical change, not a holistic solution. **It is not vibe-coding** — the Standards Guide, the
patterns library, and the analyzers govern every file, the record is kept, the dashboard is live —
but it is lean on documentation: no design documents, no test scripts; six short documents in a
flat `docs/`, written as the work happens. That makes it right for a PoC app for a demo or a
prototype, and because the foundation is sound, an agent or a developer can later take it into a
Full or Lite project and turn it into a solution. Minutes — usually 10 to 20 — at very low token
consumption: at published API rates most builds cost $1 to $5.

**Full — a complete app or solution, end to end, or a major overhaul of a big existing app.** The
work needs a detailed review of the requirements, an FRD, a TDD and a Sanity Check, a build plan, a
gap-fit test, a graded code review, full documentation, a user guide, testing guides, and automated
test scripts. It runs on three models — Main, Reasoning, and Light — for the highest-quality
outcome, which also makes it the slowest of the three: at least three to four hours end to end for
a typical app, longer for an extensive one, plus the human's own review and approval time — still
far less than a development team needs for an app of the same size.

**Lite — updating an existing app, or a new app without a large footprint.** One Main model does
everything, in fewer steps, with leaner documents (a Design Doc, Docs, a Test Script). It still
follows a reliable agentic engineering process and produces quality outcomes — faster, cheaper,
and with less detail than Full. One to two hours depending on complexity.

**What the human can prepare.** The more well-formed and documented the idea, the faster the
first stage goes. Requirements go in `requirements/` (`.md` recommended; Word, PDF, and images are
read too), an app icon in `images/`, and an existing app's reverse-engineered record — written by
the `analyze` skill — in `requirements/existing/` (Ops § Existing Apps). Every journey reads them
at its first step.

**Switching costs nothing.** Lite's Design Doc and ChangeLog carry into Full; a Build-a-Feature
extension is an existing app to Lite's Step 1 or Full's PRE-01; Build-a-Feature can run on top of
a Full or Lite project at any time. A project follows one of Full or Lite, never both at once.

---

## Ops § Build-a-Feature

**The third journey** (Ops § Journeys). Build-a-Feature builds **quick customizations** in a new or
an existing per-tenant extension — a table and its list and card pages, a field on the Customer
Card, a processing report, an API page or API query, a query, an enum or enum extension, a codeunit
with an event subscriber, a permission set, a role center — **with no steps and no design
documents**: six short documents in a flat `docs/`, written as the work happens, are the whole
record. It exists because most day-to-day Business Central work is a quick mod, not a project, and
a quick mod done through a 14-step routine is either skipped or done without the framework's
standards. It is not vibe-coding: speed is bought by dropping *deliverables* — the FRD, the TDD,
the Design Doc, the estimates, the test script, the translation files, the publish step — never by
dropping the rules the code is written to. In the plugin the `build-a-feature` skill does
everything below; `start` is the documented way in (Ops § Plugin), and a direct
`/ocpf-bc:build-a-feature` runs the same checks — it is one journey, not a second one.

**One governing rule:** *open the clock, jump straight to what the human wants, find out what you
need as fast as possible, write the design down before asking them to confirm it, build it to the
Standards Guide, document it as it compiles, offer the natural next object, stop.*

### Where it runs

| Case | Recognised by | Setup |
|---|---|---|
| A Full or Lite project | the marker says `full` or `lite` | nothing new: the parameters, prefix, ranges, models, notifications, dashboard, and `ProjectProgress.md` are reused; the feature table is appended; one ChangeLog line per object; the journey's documents are written beside the project's own, in its phase folders, never replacing |
| A feature project | the marker says `feature` | continue: the row ids carry on from the highest; `ocpfFramework/state/feature.json` holds the parameters and their sources |
| An existing extension that never used the framework | `app.json`, no `ocpfFramework/`, and a package or real objects exist | read `app.json` and `src/` for the name, ranges, prefix, and namespace; **confirm** what was read in one box — the range is asked, never kept silently, and `50100–50149` is named as the template's default; **ask intake question 4b** (new app at `0.0.0.1` / existing app at the installed version, confirmed on Extension Management) — the version is never taken from the file unasked; **offer the `analyze` skill first when the app has no usable documentation** (Ops § Existing Apps); the companions, the marker (`"edition": "feature"`), notifications, the dashboard, the Main model and its price, the AL tools, the symbols |
| An empty folder, or an AL: Go! scaffold (`1.0.0.0`, no package, `HelloWorld.al` only) | nothing, or the template's `app.json` | the same, plus Box 0 (name, publisher, icon — the `images/` file first when there is one) and one naming-and-range box (Deployment Target — PTE only; prefix; namespace; ID range); the scaffold keeps its `id`, loses `HelloWorld.al`, and is written **`0.0.0.1`** — the template's `1.0.0.0` is never kept (Ops § Packaging → *Version numbers*); **its `ALProject1`, `Default publisher`, and `50100–50149` are placeholders, not answers** — Box 0 and the range question are asked exactly as for an empty folder, and the publisher and the range are recorded with their sources (Ops § Intake → *Forbidden sources*) |

Nothing from PRE-01 / Lite Step 1 beyond that and the working-language question (asked first, so
every later box is in the human's language): no parameter sheet, no estimates, no per-country
language questions. AppSource is not a Build-a-Feature target; the journey says so and offers Full.

### The journey

0. **The clock opens first.** `ocpfFramework/state/usage.json` is created if missing and the `F00`
   window appended **before the working-language question** — the very first act. Why: on a real
   project the window was opened at the end of setup, seven decisions and 40 % of the tokens were
   *Unattributed*, and the dashboard's clock started minutes after the tokens. The renderers also
   stretch the first window back to the session's first event (Ops § Usage & Cost → 8); the rule
   stands anyway.
1. **Intake — one question.** *What do you want to build today?* with four preset options (a new
   table and its pages; extend a standard table or page; an API page or query; something else —
   a report, an enum, a query, a codeunit, a permission set, a role center) and free text — **the
   one place free text is expected**. `requirements/` (and `requirements/existing/`), or a file the
   human points at, is read first and pre-fills the answer. The answer is parsed into a plan of
   objects in build order (enums before tables, tables before pages, a table extension before its
   page extension, a cue table before its activities part before the role center before its
   profile) and said back in one list. No approval box here; each object's confirmation is the
   approval. **The problem statement and the register's parameters are written now**, at the
   intake close.
2. **The object loop.** For each object: open its usage window and its row (stage *Asked*) —
   **one window per object, always**, even when several are written in one pass; read the
   object's reference file in the skill (what it needs, which Standards sections and patterns
   files to read first, the skeleton, the pre-flight, the companion offer); **write the proposed
   design to disk** — the table's section in `docs/DataModel.md` and its row in
   `docs/FeatureRegister.md`, marked *proposed* — **then infer-and-confirm** (below) in a box whose
   text names the file — stage *Confirmed*; **allocate the ID only through the gate** — the range
   in `feature.json` (or the Full / Lite sheet) must carry a source naming the box the human
   answered, else the range question is asked now — the next free ID **of that object type** (Ops §
   Object IDs): the AL tools' next-object-ID for that type where the session has it, else the
   highest ID of that type in `src/` plus one, or the range's first ID when the type has none;
   never the highest number across types; write the file whole, once, from the skeleton and
   the Standards Guide — stage *Built*; compile with the analyzers to 0 errors / 0 warnings,
   patterns library first on any failure — stage *Compiled*; **document it now** — its section in
   `docs/Documentation.md`, its register row and data-model section completed, its ChangeLog line
   — stage *Documented*; close the window with its usage rows pasted; end with the **companion
   box** — the options box every close has (Full Rule 6c / Lite Rule 6c), two to four options —
   offering the object's natural next object and *Done*. Never a file that was not asked for or
   offered and accepted; never a publish to a tenant.
3. **Review, offered once, before anything is packaged:** when the plan is empty, *Review the
   code now (recommended)* / *Skip*. The package offer waits for this answer. On yes the BCQuality
   snapshot is fetched now (the one moment this journey fetches it; a sibling folder, Ops §
   Fetched Companions) and **this session's files** are reviewed on the Main model against the
   Standards Guide (§1, Part 2 for API objects, §5.3–§5.4, Part 7 in full, Part 11), BCQuality's
   dispatch flow, and the AL Guidelines' *Best Practices* and *Vibe Coding Rules*; every finding
   in one message with root cause and fix; one box *Apply all / Apply selected / Discuss first*;
   applied fixes recompile and update the documents before the package offer; each finding and
   its decision is a ChangeLog line.
4. **Package, offered once**, after the review box is answered: *Package it as a `.app` now* / *Not now*.
   Ops § Packaging → *Version numbers* applies unchanged — a new extension's first package at
   `0.0.0.1` as `app.json` says, every later package after a mechanical increment of the fourth
   segment, an existing extension's first package incremented from its installed version, never
   two at one version — into `outputAppPackage/`, with `docs/SandboxInstall.md` written
   with the first package and its §1 rewritten by every later one (*The sandbox install guide*,
   above), with the fixed *Package built* message and the
   version written into every row's *Shipped in*. Then, for a new extension only and only when a
   package was built: *The package is tested and approved — build the release candidate 1.0.0.0
   now* / *Not yet — I'll test it first (recommended)*; on *Not yet* the offer returns the next
   time the human comes back to the project. An existing extension's release candidate is the
   next Minor or Major, proposed the same way.
5. **Close:** the documents finished (*The record*, below — the diagram redrawn, the parts of the
   documentation that span objects, the register current), then the list of what was built, the
   documents by path, the package, the session's usage rows, the dashboard path, and the last
   box: *Done / Build another object / Open the dashboard*. Every row `Completed` with its rows
   present; `ProjectProgress.md`, `docs/`, and the dashboard pages staged. **On *Done*, one more
   render with `--close-project`** (`-CloseProject`): on a feature project the dashboard then reads
   *Completed*, Main *finished*, and the clocks stop (Ops § Dashboard → 6); a later object reopens it
   by itself. Inside a Full or Lite project (Case A) the renderer skips the close by itself — the
   host project stays open.

### Infer, then confirm

Field types are the one place a quick mod turns into twenty questions. The rule: **types the
human gave are validated, not re-asked** — the agent comes back only on something wrong or
non-standard (`Option` → `Enum`; `Text` without a length; `Integer` for money; a relation with no
table), with the recommended fix first. **Types the human did not give are inferred from the
names** (`No.` → `Code[20]`; `Description` → `Text[100]`; `Amount` → `Decimal`; `Start Date` →
`Date`; `Blocked` → `Boolean`; `Status` → an enum; `Customer No.` → `Code[20]` with the relation)
and **written to `docs/DataModel.md` first, then shown as one table in one question** whose text
names the file — *Looks right — build it* / *Change something*. Only a field that genuinely cannot
be inferred gets its own question. The primary key is always confirmed. The full inference table
is the skill's `references/field-types.md`. Why on disk first: on a real project the human was
asked to confirm designs they could only see in the chat, and the documents arrived after the
package — too late to verify anything.

### One model, every role

The Main model asks, writes, compiles and fixes, documents, and reviews. No Light, Reasoning,
Generator, or Reviewer sub-agent runs on this journey, even on a Full project that has them: the
objects are simple, the review's value is its three checklists rather than deeper reasoning, and a
fresh context buys little when the whole session is a handful of files. If an intake turns into a
whole process — posting, documents, a wizard, several modules — the journey says so in one
sentence and offers Lite or Full; the work so far is an existing app to their first step.

### The record, the usage, the dashboard

- **`ProjectProgress.md`** (project root, tracked) keeps the **feature table** — the template's
  third step table: `Row | Object | Type | ID | Stage | Status | Shipped in`, one row per object
  (`F01`, `F02`, … continuing across sessions), plus `F00` intake, `FPK` package, `FRV` review;
  stage *Asked → Confirmed → Built → Compiled → Documented → Reviewed → Packaged*; status `In
  Progress` while the row's window is open, `Completed` once its usage rows are written. On a Full
  or Lite project the table is appended under its own heading between the step table and the
  usage table, and the step table is never touched.
- **`ocpfFramework/state/feature.json`** is the journey's parameter sheet, per developer: the
  Main model and effort, the working language, the publisher and the ID ranges **each with the box
  the human answered as its source**, the prefix and namespace, and the date the model's price was
  checked. No ID is allocated and no `app.json` publisher written without the matching source
  (Ops § Intake → *Forbidden sources*); the `status` skill reports a file that lacks one.
- **Usage** (Ops § Usage & Cost, unchanged): every row is a window in `ocpfFramework/state/usage.json`
  — `step` is the row id, `title` names it — opened at the row's start and closed at its close
  with `/ocpf-bc:usage --step <id>`, one row per model (Claude Code) or per window (Copilot),
  pasted into the closing message, never hand-written. `F00` opens with the session, first, so
  that nothing is *Unattributed*; the package and the review have their own windows because one
  package or one review covers every object of the session. **The Main model's
  price is fetched by the usage script itself** at the first measurement (Ops § Usage & Cost → 3);
  a model it cannot price makes every row *price unknown*, which the dashboard now says — with the
  reason — instead of showing `$0`.
- **The dashboard** (Ops § Dashboard) is the same page: on a feature project its rows are the
  objects, with their stage, ID, time, and cost, under *Intake · Build · Review · Package*; the
  hooks and the in-place refresh are unchanged; the explanation question gains one sentence.
- **Six documents, in a flat `docs/`, written as the work happens** — never all at the close, and
  never in numbered phase folders (a six-document journey skipping folder numbers hid the files):

  | File | Template | When |
  |---|---|---|
  | `docs/ProblemStatement.md` | Lite Step 1's shape | the intake close; a dated section per session |
  | `docs/FeatureRegister.md` | `FeatureRegister.md` — the parameters Full keeps in `ProjectParameters.md`, each with its source; the object table Full keeps in `ObjectRegister.md`; where to look; decisions | §1 at the intake close; a row when an object is proposed, updated on confirm and on compile |
  | `docs/DataModel.md` | `FeatureDataModel.md` — the schema: an `erDiagram`, every table's fields, types, keys, relations, enums, where the data is shown, who may read it, the standard objects used | a section **before each confirmation box**, marked *proposed*; updated on confirm and compile; diagram redrawn at the close |
  | `docs/Documentation.md` | `FeatureDocumentation.md` — documentation only, for a consultant, a tester, or the next developer: what it does, how to use it step by step, each object in full sentences, how they fit, API, permissions and setup, limitations and next steps; nothing else mixed in | a section when each object compiles; the parts that span objects at the close |
  | `docs/ChangeLog.md` | `ChangeLog.md` | a line per object at compile, per review finding, per package |
  | `docs/SandboxInstall.md` | `SandboxInstall.md` | with the first package; §1 rewritten by every later one |

  On a Full or Lite project the same files go into the project's phase folders beside its own
  documents, appending, never replacing (Ops § Documents). Why: AJ wants to know, after any quick
  mod, what objects exist, how they relate, and how to use them — meaningful documentation, split
  by purpose, visible while the work happens — without the journey growing a document phase.
- **The ChangeLog line** (both kinds of project): one line per object under the day's heading —
  date, object type, ID, name, file, *Build-a-Feature*, and the package version it shipped in.

### What the journey never does

No FRD, TDD, Design Doc, Sanity Check, estimates, test script, user guide, or acknowledgements
(the six documents above are the whole record); no help-site offer (Ops § Help Site — on request
only, `/ocpf-bc:html-docs`); no translation files (`TranslationFile` stays on so the `.g.xlf` exists for
whoever adds languages later; labels are the source text, Standards §1.7 and §8.3 apply in full);
no publish to a sandbox or a tenant; no AppSource target; no sub-agents; no calibration export
unless asked; no second launch command; no publisher or ID range from anywhere but a box the human
answered. It works the same in Claude Code, GitHub Copilot Chat, and the Copilot CLI
(`askQuestions` / `ask_user` for every box; AI credits in the usage table; the dashboard refreshed
by hook or at every row close in Copilot Chat).

---

## Ops § Existing Apps

**An existing app that nobody can explain is documented before it is extended.** Many extensions
arrive with no FRD, no TDD, no design document, and no README that explains them: a developer
wrote them and left, a vibe-coding session produced them, or an agent built them without
documenting. Extending such an app from guesswork is how a journey designs against a model of the
app that isn't the app. So the framework reads the app first and writes down what it finds —
**presumed where it is presumed** — into **`requirements/existing/`**, where the owner reviews it
and where every journey's first step reads it as *what the app already is*.

**The `analyze` skill (`/ocpf-bc:analyze`) is the procedure**, used **first**, before a journey
starts on the app:

1. **Looks and says what it found** — name, publisher, version, ranges, objects by type, packages,
   translations, any docs — flagging template placeholders as the template's defaults, never as
   facts (Ops § Intake → *Forbidden sources*).
2. **Asks, in two boxes, through the options mechanism:** what the human already knows about the
   app (free text expected), whether they have documents to put in `requirements/existing/` (`.md`
   recommended; Word, PDF, images read too — they create the folder and say when done); then
   **which model** — a reasoning model (*Claude Opus*, recommended for an unknown, large, or tangled
   app) or a daily driver (*Claude Sonnet*); in GitHub Copilot the picker's *GPT Sol* and *GPT
   Terra* are offered beside them, in Claude Code the two Claude options only — and **which
   effort**: *Medium (recommended)* / *High*, saying that High is more detail-oriented but can take
   1.5× to 3× longer and as many more tokens or credits.
3. **Runs the analysis on the chosen model** through the `ocpf-analyst` sub-agent — a project-local
   copy with the model and effort in its frontmatter, the model passed on the call, the report's
   `Model:` line checked (the same enforcement as Ops § Roles) — in the background, from a narrow
   brief: the paths, the human's notes verbatim, the documents found, the output shapes, the
   templates. The clock is open throughout (`usage.json` window `AN0`), the model priced.
4. **Delivers six files into `requirements/existing/`**, all written by the analyst and checked by
   the main role: `PresumedFRD.md` (the requirements the code implies, every statement *presumed*
   unless the human's material confirms it), `PresumedTDD.md` (the design as built), `ObjectRegister.md`
   (every object with its ID, file, source, and one-line purpose), `Documentation.md` (what the app
   does and how a user works through it; a Mermaid schema of its tables and fields and how they
   connect; the role of every page, processing report, API page, permission set, assisted-setup
   wizard, number series, role center, event subscriber, and setup table; how to use it in BC),
   `ProjectParameters.md` (the Full Step 01 sheet with each value's source: `app.json`, the code,
   or *unknown — ask*), and `README.md` (the index: model and effort, the human's notes, counts,
   open questions, risks, the usage rows).
5. **Hands over** with the summary, the paths, the open questions, the usage rows, and one box,
   then says: review everything, correct what is presumed wrongly, answer the open questions in
   the files; to extend the app, put the new requirements in `requirements/` and run
   `/ocpf-bc:start` — every journey reads `requirements/existing/` as what the app is and
   `requirements/` as what it should become.

**Where the journeys offer it.** The `start` skill offers it on an existing extension that never
used the framework, before the journey choice, when the app has no usable documentation. Full
PRE-01 and Lite Step 1 offer it the moment they see real objects under `src/` (anything beyond the
AL template's `HelloWorld.al`) and `requirements/existing/` is empty — before the problem
statement, so before question 4b is asked — *Run the in-depth analysis and documentation first
(recommended when the app has no FRD, TDD, or docs — 10 to 30 minutes)* / *Skip — the light read
is enough* — and, on yes, run the skill before the problem statement; the step then reads
`requirements/existing/` with the rest of `requirements/`. Build-a-Feature offers it in its case C.
The analysis never edits `src/`, `app.json`, or `docs/`; it writes under `requirements/existing/`
and nowhere else; the FRD and TDD a later journey writes into `docs/` supersede the presumed ones.

**Why a separate command, not a step:** the analysis is wanted before any journey is chosen, on
apps that may never get a journey, by people who only want to understand what they inherited.

---

## Ops § Reference Sources

Alongside the fetched companions (Ops § Fetched Companions) and the AL tools, the framework grounds
its work in these. None are fetched into the project — they're consulted online, so there's nothing
to bootstrap, gitignore, or refresh. **If the agent has no web access, say so plainly** rather than
answering from memory of what a reference says.

| Reference | What it's for | Where the routine uses it |
|---|---|---|
| **BC Base Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application> | Every standard Base App table, field, and datatype/size — only when the symbols can't answer (*Precedence*, below) | Operating Rule 2 fallback; **Standards Appendix B** |
| **BC System Application docs** — <https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application> | The System Application modules (Language, Translation, Email, Telemetry, and others) and their code patterns and event signatures — only when the symbols can't answer (*Precedence*, below) | Operating Rule 2 fallback; **Appendix B**; design |
| **Working with translation files** — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files> | How XLIFF translation works in AL; why ML properties are banned | **Standards §1.7**, Part 8 |
| **Country/Regional Availability and Supported Languages** — <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations> | Where BC is available, who localizes each country, which languages Microsoft or partners translate. **Read live every time**, never from memory or a copy | Intake languages; **Standards §8.8** |
| **Microsoft Terminology Collection** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-terminology> | Microsoft product terminology in about 100 languages, when BC's own files have no match | **Standards §8.5**, Appendix D |
| **Microsoft Localization Style Guides** — <https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides> | Tone, formality, punctuation, and formats per language | **Standards §8.5**, Appendix D |
| **AL Guidelines** — <https://alguidelines.dev> (source <https://github.com/microsoft/alguidelines>, MIT) | Community-driven, Microsoft-hosted AL best practices, design patterns, and agent-oriented *Vibe Coding Rules* | Design (patterns beyond the Standards Guide); Code Review |

**Precedence.** The downloaded symbols are the source of truth and the **only** routine lookup.
Consult Microsoft Learn's Base Application or System Application reference **only** when (a)
symbols could not be downloaded, (b) the object, field, method, or event is not in the downloaded
symbols, or (c) the task needs a code pattern, a snippet, or an event's signature to subscribe to
it. Never as a second check on something the symbols already answered, and never "to be safe".
Every Learn lookup costs time and tokens; say why it was needed when one happens. The other Learn
pages in the table — countries and languages, the runtime table, the translation pages — are read
as their rows say; this rule is about the two application references. The Standards Guide beats AL
Guidelines on any AL rule. Surface a conflict rather than silently reconciling it. **AL Guidelines'
legacy *C/AL Coding Guidelines* pages are never followed** (**Standards §1.7**).

**Credit.** Every third-party resource this framework references, fetches, or recommends — with its
license and what that license asks — is listed in `THIRD_PARTY_NOTICES.md` in the framework
repository.

---

## Ops § Plugin

The framework is also distributed as an agent plugin, `ocpf-bc`, from the same repository
(`agentPlugin/ocpf-bc`, listed in `.claude-plugin/marketplace.json`). It works in Claude Code, the
Claude apps, and GitHub Copilot (VS Code, Copilot CLI, github.com). It's
**optional**: copying the runbook into a project by hand, as `CLAUDE.md` or
`.github/copilot-instructions.md`, is fully supported and behaves the same.

**This section applies only when `ocpfFramework/framework.json` exists** — the plugin's marker,
inside the `ocpfFramework/` folder of the project root. The plugin's `start` skill creates it,
recording the edition and runbook version, where the copies were placed (`placedAs`), the source
and commit they came from, the plugin version, any version the human chose to skip
(`declinedUpdateVersion`), the AL tools outcome (`alMcp`), the layout it wrote
(`"layout": "ocpfFramework-1"`), and the tooling checks (`"tooling": {}` until Ops § Tooling Checks
fills it). Without that file, skip this section entirely. The `ocpfFramework/` folder follows the
intake answer about framework files, except `ocpfFramework/state/` and the fetched subfolders,
which are always gitignored (Ops § Repository Hygiene). A project whose marker is still at
`.ocpf/framework.json` predates this layout: the `update-framework` skill migrates it (below).

**Framework update check, once per session,** before resuming work:
1. Read `runbookVersion` and `declinedUpdateVersion` from `ocpfFramework/framework.json`.
2. Read the `**Version:**` line of the latest published runbook. **Fetch only the first kilobyte** —
   the version line is inside it, and the whole runbook is tens of thousands of words:
   `curl -fsSL -r 0-1023 <url>` (verified September 15, 2026: GitHub's raw host honors the range and
   returns 1,024 bytes). If a host ignores the range and sends the whole file, read the line and
   discard the rest — never summarize it.
   - Full: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/BC_App_Build_Routine_Agent.md`
   - Lite: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_BC_App_Build_Routine_Agent.md`
3. Compare numerically, part by part.
   - **Newer, and not the skipped version:** say so in a sentence or two and offer **Update now /
     Not now / Skip this version**. **Raise it at a step boundary, not mid-step** — as its own box,
     sent after the boundary's Rule 6c box is answered *Proceed* and before the next step's
     `startedAt`; on a session that resumes **at a boundary**, this offer comes first, then the
     re-asked Rule 6c box (reversed from a live boundary, because on resume the Rule 6c box has not
     yet been answered and an update may change the next step's rules); on a mid-step resume the
     version is still read at session start, but the offer is held until the gate (next sentence)
     and any re-asked box comes first (runbook Rule 6e) — an update that
     lands between two Actions of one step is the one most likely to change the rules under work
     already half-done. When a session resumes mid-step, hold the offer until that step's exit gate
     is met rather than dropping it. "Update now" follows the plugin's `update-framework` skill:
     summarize the changelog entries in between, flagging any that touch a completed step; back up
     each current copy to `ocpfFramework/state/previous/`; replace every copy in `placedAs`, the project's runbook
     changelog, the step files, the templates, and the fetched companions the new version expects; update the marker; record it in
     the ChangeLog and project memory; then re-read the runbook before continuing. **From Full
     < 5.0.0.0 / Lite < 5.0.0.0 the update is also a migration**, done in the same "Update now"
     after the human has seen the list: create `ocpfFramework/` with its six-line README; move
     `.ocpf/*` to `ocpfFramework/state/` (the marker to `ocpfFramework/framework.json`); move the
     guides, steps, templates, patterns, and scripts under it, and the changelog and schematics; `git mv`
     every `docs/*.md` into its phase folder (Ops § Documents); rewrite the `.gitignore` block,
     `.mcp.json`, and the hook paths; Lite: create `ProjectProgress.md` from the template, carry the
     usage table over from `docs/UsageReport.md`, then remove that file; and write a ChangeLog entry
     listing every move.
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
  roles; `ocpf-generator` writes one batch's AL files and `ocpf-reviewer` runs the pre-review at
  the first clean compile, both editions, both on Main's model (Ops § Roles); `ocpf-analyst`
  analyzes an existing app for the `analyze` skill on the model the human chooses for it (Ops §
  Existing Apps). They carry no model of their own: the project's copies, written with the recorded
  model and effort, are the ones delegated to (Ops § Roles → *Enforcement*).
- **Models:** the `roles` skill says the effort warning, asks the model and effort questions at the
  first step (six in Full, two in Lite) with the recommendations per tool, writes the project-local
  copies (four in Full, two in Lite), records the assignment, and repairs a project whose roles ran
  on the wrong model.
- **Existing apps:** the `analyze` skill (`/ocpf-bc:analyze`) documents an undocumented extension
  into `requirements/existing/` — presumed FRD and TDD, Object Register, Documentation with the
  schema and flows, Project Parameters — on a model and effort the human chooses, before any
  journey extends it (Ops § Existing Apps). `start`, PRE-01 / Step 1, and Build-a-Feature offer it.
- **Tooling:** the `al-mcp-setup` skill records `alMcp`; the mermaid and PowerShell checks record
  `tooling` (Ops § Tooling Checks); `status` reports both.
- **Documents:** the `documents` skill writes any project document from its template — reads the
  template and the step file, gathers the named inputs, briefs the reasoning role narrowly where the
  step delegates, writes into the document's phase folder under `docs/` (Ops § Documents). The
  Human Effort Estimate, the AI Effort Estimate, and the Acknowledgements are among them.
- **Usage and cost:** the `usage` skill keeps `ocpfFramework/state/usage.json`, reads Claude Code's
  transcripts, fetches published prices into `ocpfFramework/state/pricing.json`, refreshes the
  usage table in `ProjectProgress.md` for both editions at every step boundary
  (`/ocpf-bc:usage --step <id>`), and writes the calibration file at project close (Ops § Usage &
  Cost).
- **Other skills:** `status` reads `ProjectProgress.md` in both editions and reports where the
  project stands (the model per role, whether the project-local definitions exist, a missing usage
  row for a closed step as a blocker, and `tooling`); `al-standards` answers ad hoc AL questions
  from the Standards Guide; `app-icon` draws the app icon when the human has none — the *Create one
  for me* option of every identity box (Ops § Intake → *The app icon → Creating one*);
  `html-docs` builds the help site — the polished HTML documentation and support page from the
  documents, with an FAQ, the human's screenshots renamed and placed, and the GitHub Pages steps —
  offered at Full Step 11 / Lite Step 6, never by Build-a-Feature, and on request on any project
  (`/ocpf-bc:html-docs`; Ops § Help Site); `copilot-blueprint` fires on any ask for a BC Copilot feature in any
  journey or none, fetches the Blueprint (Ops § Fetched Companions), and builds from it — so the
  Blueprint rule holds in Build-a-Feature and in plain chat, where no intake asks the question.
- **Build-a-Feature:** the `start` skill is the one launching point for every journey — it offers
  **Build-a-Feature, Full, or Lite** in the words of Ops § Journeys (that fixed order, Full
  recommended, and the `analyze` skill before the choice when an existing extension is
  undocumented), and on a project that already follows the framework it offers
  *Status / Check for a framework update / Build a feature in this project*. The third choice
  invokes the `build-a-feature` skill (Ops § Build-a-Feature); a direct `/ocpf-bc:build-a-feature`
  runs the same checks and is not a different journey. On a Full or Lite project (a quick mod
  between or after steps; a step left `In Progress` has its window reopened when the journey
  closes) the journey leaves the marker, the runbook, the steps, and
  the documents alone, appends its feature table to `ProjectProgress.md`, writes its six documents
  beside the project's own, and adds one ChangeLog line per object.

**Optional github.com reviewer.** The repository also ships a GitHub Copilot custom agent,
`agentPlugin/github/agents/ocpf-code-reviewer.agent.md`. It reviews the extension against the Code
Review step and the Standards Guide, writes `docs/4-prove/CodeReview.md`, and never edits AL.
- **Offer it once**, at Code Review, if the project is hosted on GitHub and the team uses Copilot.
- **If the human wants it:** copy the file into the project's `.github/agents/`. That file **must be
  tracked** in git, or github.com can't see it.
- **Its report is an input like any other finding:** the main role still applies every fix through
  the compile-and-package cycle.
