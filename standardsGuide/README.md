# The OCPF AL Development Standards Guide — how this framework uses it

**The guide itself no longer lives in this repository.** Since Full v5.2.0.0 / Lite v5.2.0.0 it is
published standalone at **<https://github.com/ajansari/ocpfBCALStandards>** as
`ocpfALDevStandardsGuide.md`, under its own MIT license and its own release tags, so the Business
Central AL community can use it without this framework. This framework is one consumer of it.

| | |
|---|---|
| Source repository | <https://github.com/ajansari/ocpfBCALStandards> |
| File | `ocpfALDevStandardsGuide.md` at the repository root (same filename as before) |
| **Pinned release this framework is validated against** | **`v1.12.1.0`** (Standards Guide 1.12.1.0) |
| Raw URL the fetch uses | `https://raw.githubusercontent.com/ajansari/ocpfBCALStandards/v1.12.1.0/ocpfALDevStandardsGuide.md` |
| Where a project keeps it | `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md` + `SNAPSHOT.json` (unchanged on-disk path, gitignored) |
| Offline copy | bundled in the `ocpf-bc` plugin's `al-standards` skill, refreshed from the pinned tag by `agentPlugin/tools/syncPlugin.sh` |

The runbook cites the guide by number — **Standards §8.6**, **Part 11**, **Appendix B** — and the
standalone repository commits to append-only numbering, so those citations keep resolving. When
the guide releases a new tag, this framework moves its pin in a framework release that also
updates any runbook line citing the new rule; the runbook never edits a rule, it only cites one.
A fetched guide whose version differs from the pin above is **version skew**: name it, don't
silently reconcile a citation that no longer resolves (Ops § Fetched Companions).

## Purpose

The detailed, project-agnostic *rules* for writing AL — coding standards, API page design, field
inclusion and exclusion, identifier naming, module and ID allocation, gap analysis, anti-patterns,
translation and multilanguage rules, upgrade and data migration, events and extensibility, and the
client page rules for parent–child pages and number series. Appendix E adds the manifest and
submission rules that apply only when the extension is destined for AppSource rather than a single
tenant.

## Relationship to the runbook

The guide is one of two companions to `BC_App_Build_Routine_Agent.md` (and its Lite edition), the
OnlyCopilotFans Agentic Dev Framework runbook. The other is the **OCPF Operations Guide**
(`ocpfFramework/opsGuide/ocpfOperationsGuide.md`, cited as **Ops §**), which holds the framework's
*procedures* — asking, intake, project setup, tooling, packaging, hygiene, and the translation
workflow. The guide holds the AL *rules*. **The runbook drives the *sequence*** — what happens when,
who signs off, which gate opens the next step. **The guide holds the *rules* that sequence
applies.** The runbook cites it as **Standards §**. Where the two ever appear to disagree about
*process*, the runbook wins; where they appear to disagree about an *AL rule*, the guide wins — but
neither should happen, because neither document restates the other's content. The runbook names
an AL rule in one line where a checklist applies it and cites **Standards §**; the rule's rationale,
limits, tool behavior, and reference links live only in the guide. The runbook's process lives
only in the runbook.

## Authoritative-source rule, in this framework's terms

The guide's rules defer to "your project's parameter sheet". In this framework that sheet is the
**Project Parameters** block the runbook fills in interactively at **Step 01** (Lite: Step 1) and
persists as `docs/1-define/ProjectParameters.md` — the single source of truth for every name, ID,
version, prefix, namespace, and quoting decision. Never hardcode a publisher, prefix, namespace,
version, or object ID anywhere in AL code, and never restate a Step 01 parameter in the guide.

## What is deliberately *not* in the guide

Each of the following lives in exactly one place — the runbook or the Operations Guide — and the
guide points there rather than keeping a second, silently-diverging copy:

| Topic | Where it actually lives |
|---|---|
| The intake sheet / project parameters (extension identity, ID ranges, naming & API parameters, platform & runtime, feature flags, onboarding, model roles, `.gitignore` policy), and how its questions are grouped and asked | Runbook **Step 01** and **Operating Rule 6a**, asked interactively |
| Required project documents, and the phase/stage lifecycle | Runbook **ALL ALONG → Document**, and its DEFINE → DESIGN → BUILD → PROVE phase structure |
| What makes a TDD self-sufficient | Runbook **Step 03** |
| The sanity-check checklist | Runbook **Step 04** |
| The pre-flight validation checklist (pre- and post-generation) | Runbook **Step 05** — the canonical list |
| Batching, compile cadence, and the zero-errors/zero-warnings gate | Runbook **Operating Rules 3, 4, 5** |
| Treating a compiler error as a systemic signal | Runbook **Operating Rule 4** |
| Verifying against symbol files rather than model memory | Runbook **Operating Rule 2** (procedure in the guide's Appendix B) |
| The ChangeLog entry format | Runbook **ALL ALONG → Track Changes** |
| The Object Register | Runbook **ALL ALONG → Document** |
| The language and translation intake questions (working language, countries, languages, source language, reviewers, document languages) | Runbook **PRE-01** and **Step 01** (Box 1 and §1.9), asked interactively |
| The interactive API caption-locking classification | Runbook **Step 03** (the rules it applies are Standards §8.6) |
| Every enum's `Extensible` decision, asked per enum | Runbook **Step 03** / Lite **Step 2** (the rule is Standards §1.9) |
| When translations are synced, drafted, checked, and tested; the translation release gate | **Ops § Translations**, applied at the runbook's compile and release steps |
| How the agent asks, sets the project up, runs the AL tools and analyzers, downloads symbols, packages, notifies, and keeps the repository clean | **Ops §** — the Operations Guide |

## Version history

The guide's history up to and including **1.11.0.0** (September 27, 2026) is in
`fullVersion/RunbookChangelog.md`. From **1.12.0.0** on, every change to the guide is logged in the
standalone repository's `CHANGELOG.md`; this framework's changelogs record only "pinned tag moved
from X to Y" and whatever runbook lines moved with it.
