---
name: al-standards
description: The OnlyCopilotFans (OCPF) AL Development Standards Guide for Microsoft Dynamics 365 Business Central - coding standards, API page design, field inclusion, naming and abbreviations, object ID allocation, gap analysis, anti-patterns, and multilanguage/XLIFF rules. Use when writing, reviewing, or planning Business Central AL code or API pages, when the user asks to "check this AL against OCPF standards", or when an OCPF runbook needs its Standards Guide and GitHub isn't reachable.
---

# OCPF AL Development Standards Guide

The full guide is in [`references/ocpfALDevStandardsGuide.md`](references/ocpfALDevStandardsGuide.md).
It's the same file the framework repository publishes at `standardsGuide/ocpfALDevStandardsGuide.md`,
bundled with this plugin. Its version is on its own `**Version:**` line.

## When a project follows the OCPF runbook

The runbook fetches the latest guide from GitHub into the project's `standardsGuide/` folder at
its first step (Full PRE-01, Lite Step 1). That fetched copy is the one to use. Use this bundled
copy only as the runbook's fallback when GitHub isn't reachable. In that case:

1. Copy `references/ocpfALDevStandardsGuide.md` into `standardsGuide/` in the project root.
2. Write `standardsGuide/SNAPSHOT.json` with `"source": "ocpf-bc plugin bundle"`, the plugin
   version, the guide's version, and the timestamp.
3. Tell the human plainly that the bundled copy was used, naming its version, and that the runbook
   will refresh it from GitHub when asked.

## When there's no runbook (a quick review or question)

Read the relevant part of the guide and apply it. Cite rules as **Standards §<number>** so the
human can look them up. The guide is organized into Parts 1–8 and Appendices A–D; start from its
table of contents rather than reading the whole file.

- Where a rule depends on project parameters (publisher, prefix, namespace, ID ranges), the guide
  defers to the project's parameters. Ask for them rather than guessing.
- For Base App facts (table numbers, fields, namespaces, `ObsoleteState`), verify against the
  project's symbol packages or Microsoft Learn, as the guide's Appendix B describes. Don't assert
  them from memory.
