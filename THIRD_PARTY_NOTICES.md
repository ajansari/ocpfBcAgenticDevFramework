# Third-Party Notices and Credits

The **OCPF BC Agentic Development Framework** is © 2026 AnsariCo, Inc. dba OnlyCopilotFans
(<https://OnlyCopilotFans.com>) and OnlyBCFans (<https://OnlyBCFans.com>), and is released under
the PolyForm Shield License 1.0.0 (see `LICENSE`; <https://polyformproject.org/licenses/shield/1.0.0>).

The framework stands on the work of others. This file credits every third-party resource it
references, fetches, invokes, or recommends, and records the license each one is used under.

**How the framework uses third-party material.** This repository **does not bundle or
redistribute** any third-party code; the one exception is three icons embedded in the
dashboard page, credited under *Embedded in the dashboard page* below. The framework's documents:

- **link** to external documentation and repositories,
- instruct the agent to **fetch** a local snapshot of certain repositories into *your* project,
  where that snapshot keeps its own `LICENSE` file,
- **invoke** tools you install yourself, or
- **name** tools it recommends.

Where this repository quotes or adapts third-party text, the attribution sits beside the quoted
text as well as here.

*Licenses and copyright holders below were checked against each project's own `LICENSE` file on
September 14, 2026 (Node.js and PowerShell 7 on September 27, 2026). The upstream project's current license always governs.*

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
- **Used for:** the reusable AL bug-pattern library, fetched into each project's `ocpfFramework/patterns/`
  folder. The snapshot keeps its `LICENSE` file.

### OnlyBCFans BC Copilot Blueprint
- **Source:** <https://github.com/ajansari/obcfBCCopilotBlueprint>
- **License:** MIT — AJ Ansari (same author as this framework)
- **Used for:** the verified reference design, templates, API reference, and false-assumptions
  table the runbooks follow when a project builds a Business Central Copilot feature. Fetched at a
  pinned tag (`v1.0.0.0` for runbook v5.3.5.0), only on projects with such a feature, into a sibling
  folder outside the project root; the snapshot keeps its `LICENSE` file. Nothing from it is
  copied into this repository or the plugin.

### OCPF AL Development Standards Guide
- **Source:** <https://github.com/ajansari/ocpfBCALStandards>
- **License:** MIT — AJ Ansari (same author as this framework)
- **Used for:** the AL rules the runbooks cite as **Standards §**. Standalone since Full/Lite
  v5.2.0.0 (it was part of this repository through its version 1.11.0.0); fetched at the pinned
  release tag (`v1.12.0.0`, named in `standardsGuide/README.md`) into each project's
  `ocpfFramework/standardsGuide/`, and bundled at that tag in the `ocpf-bc` plugin's `al-standards`
  skill as the offline copy.

---

## Embedded in the dashboard page

The live dashboard (`ProjectDashboard.html`, rendered from the plugin's
`skills/dashboard/templates/dashboard.html`) is a single self-contained file, so the icon that
names the project's AI tool is embedded as inline SVG rather than fetched. Two marks are used,
only to identify the tool the project runs in; the framework is free and sells nothing.

### Claude mark (Anthropic)
- **Drawing source:** simple-icons, `claude.svg` — <https://github.com/simple-icons/simple-icons>
- **Drawing license:** CC0 1.0 Universal (the SVG path, as published by simple-icons)
- **Trademark:** the Claude mark and name belong to Anthropic, PBC; shown in Anthropic's brand
  orange (`#D97757`) solely to identify Claude Code as the AI tool the project runs in. No
  affiliation with or endorsement by Anthropic is implied.
- **Used for:** the *Claude Code* pill in the dashboard header.

### Microsoft Dynamics 365 Business Central product icon
- **Source:** Microsoft's product icon for Dynamics 365 Business Central, as distributed by
  Microsoft (embedded as a PNG data URI)
- **Trademark:** Microsoft, Dynamics 365, and Business Central are trademarks of the Microsoft
  group of companies; the icon is shown solely to identify the platform every project built with
  this framework targets, per Microsoft's trademark and brand guidelines
  (<https://www.microsoft.com/legal/intellectualproperty/trademarks>). No affiliation with or
  endorsement by Microsoft is implied.
- **Used for:** the platform mark under the status pills in the dashboard header.

### GitHub Copilot icon (Octicons)
- **Source:** Primer Octicons, `copilot-24.svg` — <https://github.com/primer/octicons>
- **License:** MIT — Copyright (c) 2026 GitHub Inc.
- **Trademark:** GitHub and GitHub Copilot are trademarks of GitHub, Inc.; the icon is shown
  monochrome, in the page's text color, solely to identify the AI tool. No affiliation with or
  endorsement by GitHub is implied.
- **Used for:** the *Copilot Chat* / *Copilot CLI* pill in the dashboard header.
- **Obligation met:** this notice reproduces the copyright line; the full MIT text is in the
  Octicons repository's `LICENSE`.

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

### GitHub Docs and Visual Studio Code — Copilot billing and usage
- **Sources:** <https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing>
  (AI credits and per-model rates) · <https://code.visualstudio.com/docs/agents/guides/optimize-usage>
  and <https://code.visualstudio.com/docs/agents/guides/monitoring-agents> (where VS Code shows
  credits; OpenTelemetry export) · <https://github.com/microsoft/vscode> (MIT — Copyright (c)
  Microsoft Corporation), whose chat session storage the usage script reads.
- **Used for:** how GitHub Copilot usage is measured and priced (Ops § Usage & Cost). The pages are
  read and cited, prices are fetched at use and never copied into the framework; the VS Code
  source was read to confirm what the stored fields mean, and no code from it is copied. Checked
  September 29, 2026.

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
  - CodeCop Warning AA0074 —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0074>
  - Technical validation checklist —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-checklist-submission>
  - Country/Regional Availability and Supported Languages —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations>
  - Multilanguage and localization —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/about-locale-language>
  - Translations Overview —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-translations-overview>
  - Marketing Validation Checklist, Language, Branding, and Images, and Offer Description —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-marketing>
  - Development of validated localization apps —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/about-validated-localization-apps>
  - Best practices for AL code (File naming) —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-bestpracticesforalcode>
  - CodeCop Warning AA0215 —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0215>
  - CodeCop Warning AA0101 —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0101>
  - PerTenantExtensionCop Error PTE0004 —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0004>
  - AppSourceCop analyzer rules, including AS0103 and the note that AppSourceCop and
    PerTenantExtensionCop must not be enabled together —
    <https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop>
- **License:** documentation © Microsoft Corporation, licensed under
  [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/);
  code samples under MIT — per the public Business Central docs repository,
  <https://github.com/MicrosoftDocs/dynamics365smb-devitpro-pb>.
- **Used for:** linked throughout both runbooks, the Standards Guide, and the Operations Guide as fallback references.
- **Quoted or adapted material:** the Standards Guide's §1.7 (now in `ajansari/ocpfBCALStandards`) quotes the
  AL0424 warning text and adapts Microsoft Learn's list of multilanguage (ML) properties excluded
  from `.xlf` files into a table. Attribution, a link to the source, the license, and a note that
  the list was reorganized sit directly below that section, as CC BY 4.0 requires. Standards Part
  8 summarizes the AA0074 suffix list, the Incremental Build / RAD translation behavior, the
  AppSource translation-file requirement, and the country/language support facts, with the same
  attribution block at the end of Part 8. Standards §1.8 adapts the file-naming notation and type
  map from *Best practices for AL code* and *CodeCop Warning AA0215*, and §2.7 summarizes *CodeCop
  Warning AA0101*, each with the same attribution block. The Operations Guide's Ops § Analyzers
  summarizes the PerTenantExtensionCop and AppSourceCop pages.
  `translationAndMultiLanguage/MultilanguageSupportOverview.md` summarizes facts from these pages
  and carries its own attribution.

### Microsoft Learn — Globalization documentation
- **Sources:** Microsoft Terminology —
  <https://learn.microsoft.com/en-us/globalization/reference/microsoft-terminology>; Microsoft
  Localization Style Guides —
  <https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides>
- **License:** documentation © Microsoft Corporation, licensed under
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — per
  <https://github.com/MicrosoftDocs/globalization>. The downloadable Terminology Collection and the
  style guide PDFs are governed by the terms published with them.
- **Used for:** terminology fallback and per-language style guidance (Standards §8.5, Appendix D).
  Linked; the agent consults them during a project. Nothing from them is copied into this
  repository.

### Microsoft API v2.0 source (ALAppExtensions)
- **Source:** <https://github.com/microsoft/ALAppExtensions/tree/main/Apps/W1/APIV2>
- **License:** MIT — Copyright (c) Microsoft Corporation
- **Used for:** counting how Microsoft locks or translates captions on its API pages and queries.
  Standards §8.6 and the multilanguage overview cite the resulting counts. No code is copied.

### Microsoft Business Central translation files and artifacts
- **What:**
  - the XLIFF translation files inside Microsoft's Business Central `.app` packages — Base
    Application, System Application, Business Foundation, and Microsoft language apps;
  - Microsoft's public Business Central artifacts that contain those packages.
- **License:** Microsoft proprietary content — not open source.
- **Used for:** terminology verification (Standards §8.5, Appendix D). The agent reads them from the
  user's own `.alpackages/`, or fetches a single Microsoft language app from Microsoft's public
  artifacts after telling the user — under the user's own Microsoft license and Microsoft's terms
  for those artifacts. The framework never commits, copies wholesale, or redistributes them.
- **Cited in this repository:** Standards §8.1 and the multilanguage overview cite aggregate string
  counts and a few short examples from the US Base Application (`en-US`) and the English
  (Australia) and English (United Kingdom) language apps (v28.5 Australian sandbox artifact). No
  files are reproduced.

### BcContainerHelper
- **Source:** <https://github.com/microsoft/navcontainerhelper>
- **License:** MIT — Copyright (c) Microsoft Corporation
- **Used for:** Standards Appendix D names its `Get-BCArtifactUrl` command as the way to locate
  Microsoft's public Business Central artifacts. Installed by the user only if they choose to use
  it; no code is copied.

### Microsoft AL GitHub issue tracker
- **Source:** <https://github.com/microsoft/AL/issues/5789>
- **Used for:** corroborating the AL0424 compiler message text cited in Standards §1.7. Linked,
  not copied.

---

## Tools invoked or recommended (installed by you, never redistributed here)

### XLIFF Sync — VS Code extension
- **Source:** <https://github.com/rvanbekkum/vsc-xliff-sync>
- **License:** MIT — Copyright (c) 2022 Rob van Bekkum
- **Used for:** the recommended translation reviewer's tool (runbook Step 05 / Lite Step 3;
  Standards Appendix C). Installed from the VS Code Marketplace by the user, with permission.

### XLIFF Sync — PowerShell module (`XliffSync`)
- **Source:** <https://github.com/rvanbekkum/ps-xliff-sync>
- **License:** MIT — Copyright (c) 2020 Rob van Bekkum
- **Used for:** the recommended headless translation sync and technical checks the agent runs
  (runbook Step 07 / Lite Step 5). Installed from the PowerShell Gallery by the user, with
  permission. Standards §8.7 describes its translation-state behavior, based on reading its source
  code; no code is copied.

### NAB AL Tools
- **Source:** <https://github.com/jwikman/nab-al-tools>
- **License:** MIT — Copyright (c) 2019 Johannes Wikman
- **Used for:** named as the alternative translation-management tool for developers who already use
  it. No content is used.

### Node.js
- **Source:** <https://nodejs.org> (source: <https://github.com/nodejs/node>)
- **License:** MIT — Copyright Node.js contributors (the repository's `LICENSE` collects the licenses of its bundled components)
- **Used for:** running `npx @mermaid-js/mermaid-cli` to render diagrams. Ops § Tooling Checks looks for an existing installation first and offers an install only with the human's approval; nothing is redistributed.

### PowerShell 7
- **Source:** <https://github.com/PowerShell/PowerShell>
- **License:** MIT — Copyright (c) Microsoft Corporation
- **Used for:** the XLIFF Sync module, the usage script's `.ps1` port, and BCQuality's optional fast knowledge discovery. Ops § Tooling Checks looks for `pwsh` first and offers Microsoft's documented install for the human's operating system only with approval.

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
  installation, either through the extension's built-in GitHub Copilot tools or through its
  bundled AL MCP Server, which the `ocpf-bc` plugin's launcher script starts. Never redistributed.

### AL Development Tools .NET tool (Microsoft)
- **Source:** `Microsoft.Dynamics.BusinessCentral.Development.Tools` on NuGet
  (<https://www.nuget.org/packages/Microsoft.Dynamics.BusinessCentral.Development.Tools>). It
  installs the `al` command, which includes the AL MCP Server (`al launchmcpserver`).
- **License:** Microsoft Software License Terms, as linked from the package's own `LICENSE.txt` (not
  open source).
- **Used for:** optional, only for cloud sessions and machines without VS Code. There, the
  framework runs `al launchmcpserver` from this tool instead of from the AL Language extension. You
  install it yourself, in a cloud environment's setup script or with approval; this repository
  never redistributes it.

### .NET SDK
- **Source:** <https://dotnet.microsoft.com/download> (source: <https://github.com/dotnet/sdk>)
- **License:** MIT — Copyright (c) .NET Foundation and Contributors
- **Used for:** installing the AL Development Tools .NET tool above. Installed by you, if you
  choose that route.

### Microsoft 365 Agents Toolkit CLI (`atk`)
- **Source:** `@microsoft/m365agentstoolkit-cli` on npm
  (<https://github.com/OfficeDev/microsoft-365-agents-toolkit>)
- **License:** MIT
- **Used for:** maintainers only. `atk import openplugin` converts the `ocpf-bc` plugin into a
  Microsoft 365 app package for Copilot Cowork. Framework users never need it.

### Business Central symbol packages
- Microsoft's `.app` symbol packages (Base Application, System Application, and so on) are
  downloaded into *your* project's `.alpackages/` from your own Business Central environment,
  under your own Microsoft license. This repository contains none of them.

---

## Trademarks

Microsoft, Dynamics 365, Business Central, Microsoft 365, Copilot, Visual Studio Code, AppSource,
and GitHub are trademarks of the Microsoft group of companies. Claude and Claude Code are trademarks
of Anthropic. All other
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
