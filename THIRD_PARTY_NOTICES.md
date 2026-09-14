# Third-Party Notices and Credits

The **OCPF BC Agentic Development Framework** is © 2026 AJ Ansari, OnlyCopilotFans, and is
released under the MIT License (see `LICENSE`).

The framework stands on the work of others. This file credits every third-party resource it
references, fetches, invokes, or recommends, and records the license each one is used under.

**How the framework uses third-party material.** This repository **does not bundle or
redistribute** any third-party code. The framework's documents:

- **link** to external documentation and repositories,
- instruct the agent to **fetch** a local snapshot of certain repositories into *your* project,
  where that snapshot keeps its own `LICENSE` file,
- **invoke** tools you install yourself, or
- **name** tools it recommends.

Where this repository quotes or adapts third-party text, the attribution sits beside the quoted
text as well as here.

*Licenses and copyright holders below were checked against each project's own `LICENSE` file on
September 14, 2026. The upstream project's current license always governs.*

---

## Fetched into projects as local snapshots

### BCQuality
- **Source:** <https://github.com/microsoft/BCQuality>
- **License:** MIT — Copyright (c) 2026 Microsoft Corporation
- **Used for:** the code-quality knowledge base and review skills behind the runbooks' BCQuality
  review pass. Fetched by the agent, once per project, into a sibling folder outside the AL
  project root.
- **Obligation met:** the snapshot keeps BCQuality's `LICENSE` file (both runbooks say so
  explicitly), so the MIT copyright and permission notice travels with the copy. Nothing from
  BCQuality is copied into this repository.

### OCPF BC AL Patterns Library
- **Source:** <https://github.com/ajansari/ocpfBCALPatterns>
- **License:** MIT — AJ Ansari (same author as this framework)
- **Used for:** the reusable AL bug-pattern library, fetched into each project's `patterns/`
  folder. The snapshot keeps its `LICENSE` file.

---

## Consulted as references (linked, not copied)

### AL Guidelines
- **Source:** <https://github.com/microsoft/alguidelines> · published at <https://alguidelines.dev>
- **License:** MIT — Copyright (c) Microsoft Corporation
- **Authors:** a community-driven project; its `CITATION.cff` credits Eric Wauters, Arend-Jan
  Kauffmann, Henrik Helgesen, and Jeremy Vyska, plus its many contributors.
- **Used for:** AL best practices, design patterns, and agent-oriented *Vibe Coding Rules*,
  consulted during design and code review. The Standards Guide (§1.7) names, without quoting, two
  legacy C/AL pages it supersedes.

### Microsoft Learn — Business Central documentation
- **Sources:**
  - BC Base Application reference —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application>
  - BC System Application reference —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application>
  - Working with translation files —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files>
  - Compiler Warning AL0424 —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al424>
- **License:** documentation © Microsoft Corporation, licensed under
  [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/);
  code samples under MIT — per the public Business Central docs repository,
  <https://github.com/MicrosoftDocs/dynamics365smb-devitpro-pb>.
- **Used for:** linked throughout both runbooks and the Standards Guide as fallback references.
- **Quoted or adapted material:** `standardsGuide/ocpfALDevStandardsGuide.md` §1.7 quotes the
  AL0424 warning text and adapts Microsoft Learn's list of multilanguage (ML) properties excluded
  from `.xlf` files into a table. Attribution, a link to the source, the license, and a note that
  the list was reorganized sit directly below that section, as CC BY 4.0 requires.

### Microsoft AL GitHub issue tracker
- **Source:** <https://github.com/microsoft/AL/issues/5789>
- **Used for:** corroborating the AL0424 compiler message text cited in Standards §1.7. Linked,
  not copied.

---

## Tools invoked or recommended (installed by you, never redistributed here)

### mermaid-cli
- **Source:** <https://github.com/mermaid-js/mermaid-cli>
- **License:** MIT — Copyright (c) 2017-2020 Tyler Long
- **Used for:** rendering Mermaid diagrams to prove they parse (runbook Step 11 / Lite Step 6, and
  this repository's schematics), run via `npx @mermaid-js/mermaid-cli`.

### AZ AL Dev Tools / AL Code Outline
- **Source:** <https://github.com/anzwdev/al-code-outline>
- **License:** MIT — Copyright (c) 2017 Andrzej Zwierzchowski
- **Used for:** named in Standards Appendix C as a recommended VS Code extension; its rule set
  informs the Step 06 post-generation read.

### AL Object ID Ninja
- **Source:** <https://github.com/vjekob/al-objid> — by Vjekoslav Babić
- **License:** see the upstream repository (GitHub's license detection doesn't report a standard
  license for it).
- **Used for:** named only, in Standards Appendix C, as a recommended VS Code extension. No content
  is used.

### AL Language extension and AL MCP Server (Microsoft)
- **Source:** the AL Language extension for Visual Studio Code, published by Microsoft on the VS
  Code Marketplace; the AL MCP Server (`altool launchmcpserver`) ships inside it.
- **License:** Microsoft's own license terms for the extension (not open source).
- **Used for:** compiling, packaging, symbols, and diagnostics. Invoked from your own
  installation; never redistributed.

### Business Central symbol packages
- Microsoft's `.app` symbol packages (Base Application, System Application, and so on) are
  downloaded into *your* project's `.alpackages/` from your own Business Central environment,
  under your own Microsoft license. This repository contains none of them.

---

## Trademarks

Microsoft, Dynamics 365, Business Central, Visual Studio Code, AppSource, and GitHub are
trademarks of the Microsoft group of companies. Claude is a trademark of Anthropic. All other
names are the property of their respective owners. Their mention here is for identification and
credit only and implies no endorsement.

---

## Adding a new third-party resource

Before the framework adopts anything new, add it here with its license, verified against the
upstream `LICENSE` file:

- **Link or recommend only** → credit it in this file.
- **Fetch a snapshot into projects** → credit it here, and have the runbook keep the source's
  `LICENSE` file in the snapshot.
- **Copy code or text into this repository** → keep the original copyright and license notice
  beside the copied material, and credit it here. For CC BY content, also link the source and the
  license and say what was changed.
