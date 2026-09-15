# Multilanguage Support in the OCPF BC Agentic Development Framework

**How the framework handles captions, XLIFF translations, regional terminology, and
language-aware UAT — in both the full framework and the Lite edition.**

*by AJ Ansari · September 14, 2026*

| | |
|---|---|
| **Multilanguage support** | Runbook v2.7.0.0 · Lite v1.4.0.0 · Standards Guide v1.2.0.0 — everything in this document |
| **Translation cadence** | Runbook v2.12.0.0 · Lite v1.9.0.0 · Standards Guide v1.5.0.0 — drafting waits for stable source text; translated documents follow release testing's functional pass (§7, §10) |
| **Shipped first** | Runbook v2.6.0.0 · Lite v1.3.0.0 · Standards Guide v1.1.0.0 — the ban on multilanguage (ML) syntax (§3) |

---

## 1. Why this exists

Shortly after the framework launched, several MVPs (names in Credits section at the end) sent the same message, in different words: **multilanguage support isn't a nice-to-have. It's a must-have.** They were right, and this document describes what changed because of it.

Their feedback came down to four requirements:

1. **UAT happens with translations in place**, not in English with translations bolted on later.
2. **Captions use `Caption` plus XLIFF (`.xlf`) files** — never `CaptionML`, which is deprecated.
3. **AppSource requires XLIFF translation files** — Microsoft's
   [technical validation checklist](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-checklist-submission)
   says so plainly — so an app built any other way isn't on the path to AppSource.
4. **Regional variants of a language are different languages in practice.** Australia speaks
   English, but Business Central in Australia says **GST**, not VAT, and uses its own term for a
   credit memo. An app that says "VAT" to an Australian user isn't just unpolished — it's wrong.
   (The feedback called that term "Credit Note". Microsoft's own Australian translation actually
   says **"CR/Adj Note"** — §12 shows the evidence. That's precisely why the framework checks terms
   against Microsoft's files instead of trusting anyone's memory, ours included.)

Thank you to everyone who raised this. The design below is better for it.

---

## 2. At a glance

- **No multilanguage (ML) syntax, ever.** The agent never writes `CaptionML` or any ML property,
  and Code Review flags it wherever it appears — including in code a human wrote.
- **Country first, then language.** Intake asks where the app will be used, then offers only the
  languages Business Central actually supports in each of those countries.
- **Source text in `en-US`, using Microsoft's own wording** — recommended and the default, with the
  developer free to choose otherwise.
- **Every target language gets its own `.xlf`, including `en-US`** — the same approach Microsoft
  takes in its own apps.
- **Terminology comes from Microsoft's translations**, not from the AI model's memory.
- **The agent drafts translations; a named human approves them.** Nothing ships unapproved.
- **API pages and queries are classified** as business or technical, and the developer decides
  whether their captions are translatable, guided by what Microsoft does in its own APIs.
- **Every required language is tested in UAT** by someone who speaks it.

---

## 3. No multilanguage (ML) syntax

This part didn't wait for the full multilanguage release — it shipped first, in v2.6.0.0.

**The rule** (Standards Guide §1.7): all user-facing text — captions, tooltips, option captions,
instructional text, and every message, error, and confirmation — is written once, in the source
language, using single-language properties or `Label`. Translations live only in `.xlf` files.

| Never use | Use instead |
|---|---|
| `CaptionML` | `Caption` |
| `ToolTipML` | `ToolTip` |
| `OptionCaptionML` | `OptionCaption` |
| `InstructionalTextML` | `InstructionalText` |
| `PromotedActionCategoriesML` | `PromotedActionCategories` |
| `RequestFilterHeadingML` | `RequestFilterHeading` |
| `AboutTitleML` | `AboutTitle` |
| `AboutTextML` | `AboutText` |
| `TextConst` | `Label` |

**Why it's unconditional:**

- The ML syntax is deprecated — compiler warning **AL0424**.
- ML properties and `TextConst` are **not included in the generated `.xlf` file**, so no XLIFF
  workflow can ever translate them.
- **The compiler won't reliably catch it.** AL0424 only fires when `app.json` includes the
  `TranslationFile` feature. Without that flag, `CaptionML` compiles with no warning at all — so a
  "zero warnings" build proves nothing here.

**How it's enforced:**

- **At generation:** any ML property or `TextConst` fails the agent's post-generation pre-flight
  check.
- **At Code Review:** every AL file is searched for all nine constructs — **whoever wrote it**,
  agent or human. Each hit is a finding, refactored to the single-language property with any
  other-language text moved into the right `.xlf` rather than discarded.
- **In the Anti-Patterns table** (Standards Part 7), which both editions run in full at Code Review.

**A note on AL Guidelines.** The framework consults [AL Guidelines](https://alguidelines.dev) for
patterns beyond its own Standards Guide. Its legacy C/AL section still hosts two pages recommending
ML properties (*"CaptionML on System Pages"* and *"Using OptionCaptionML"*). They predate AL and
XLIFF, and the framework explicitly tells the agent not to follow them. AL Guidelines' current
agent-oriented *Vibe Coding Rules* already agree with the framework's approach.

---

## 4. Choosing countries and languages

### How intake works

Languages are part of the project's intake, alongside the extension name, publisher, and ID
ranges. The agent asks:

1. **Which countries will this app be used in?** Asked as a loop, since there's often more than
   one.
2. **For each country, which languages?** The agent offers only languages Business Central
   supports there.
3. **Confirm the list.**

The agent shows the three-letter language IDs BC people already recognise, and records the XLIFF
culture codes the files actually use:

| Country (examples) | Languages | Shown as → recorded as |
|---|---|---|
| Germany | German | DEU → `de-DE` |
| Austria | German | DEA → `de-AT` |
| Switzerland | German, French, Italian | DES → `de-CH`, FRS → `fr-CH`, ITS → `it-CH` |
| Belgium | Dutch, French | NLB → `nl-BE`, FRB → `fr-BE` |
| United Kingdom | English | ENG → `en-GB` |
| Canada | English, French | ENC → `en-CA`, FRC → `fr-CA` |
| Australia | English | ENA → `en-AU` |

That table is only a sample. The agent works from Microsoft's own
[Country/Regional Availability and Supported Languages](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations)
page, read live at intake rather than copied into the framework, because Microsoft updates it
regularly. It covers roughly 250 countries and regions.

If the project's localization and its chosen languages don't line up — an Australian localization
with no `en-AU`, say — the agent points out the mismatch instead of accepting it.

### Three kinds of language support

Microsoft's page distinguishes who localizes each country and who translates each language. The
framework handles each combination differently:

| Case | Examples | How the framework handles it |
|---|---|---|
| **Microsoft translates the application** | Germany (`de-DE`), Austria (`de-AT`), Belgium (`nl-BE`, `fr-BE`), Australia (`en-AU`), Canada (`en-CA`, `fr-CA`) | **Full support.** Microsoft's own translations are the authority for terminology (§6). |
| **The language is supported, but a partner translates the application** | Türkiye (`tr-TR`), Poland (`pl-PL`), Japan (`ja-JP`) | **Supported.** There's no Microsoft application translation to align with, so the agent asks which partner localization or language app the customer uses and follows its terminology. If that isn't available, it falls back to Microsoft's terminology collection and style guides — and says plainly that the human reviewer carries more weight for that language. |
| **Business Central doesn't support the language** | Arabic (Saudi Arabia), Urdu (Pakistan) | **Not offered by default.** The agent explains that BC's own interface won't appear in that language, and offers the country's English instead. If the developer still wants it, the agent records it as outside platform support and asks them to confirm with the partner localization first. |

**Right-to-left languages.** Business Central doesn't support right-to-left interfaces. Microsoft's
availability page lists Israel as "no RTL; English only", and no right-to-left language appears in
its supported-languages table. BC's Region setting changes number formats and text alignment, not
the direction of the interface. Whether Arabic or Hebrew *data* — item names, addresses — stores
and prints correctly is a separate question; test it in a sandbox before promising it to a
customer.

**Countries where English is the only supported language** get English. Where there's no regional
English variant, that's `en-US`, which is built in.

**Partner localizations can change standard terms too.** A partner's localization may adapt
standard captions for local tax or legal terms. When the customer's localization is known, the
agent checks its translations the same way it checks Microsoft's.

---

## 5. Source language: `en-US`, in Microsoft's wording

### The developer chooses; `en-US` is recommended and the default

The developer decides what language the AL source text is written in. If they don't answer or
aren't sure, it's `en-US`. The agent labels `en-US` as recommended and explains why, because it's
a technical recommendation rather than a preference:

1. **The generated `.g.xlf` declares `source-language="en-US"`.** Writing source text in another
   language doesn't change that label — it produces an `en-US` file full of non-English text.
2. **Microsoft's own apps use `en-US` as their source.** Aligning an extension's wording with
   Microsoft's official translations works by matching source text, which only works if the
   source languages match.
3. **Users in a language with no translation file see the source text.** English is the safest
   fallback.
4. **Reviewers, translators, and tooling across the BC ecosystem assume it.**

If a developer chooses another source language anyway, the agent spells out the cost: an
`en-US.xlf` translating *into* English, no alignment with Microsoft's translations, and non-English
text for anyone whose language isn't covered.

### Microsoft's "en-US" source is really international English

Look inside the translation files of the **US** Base Application (Business Central 27.5) and
you'll find something that shapes this whole design: an **`en-US` to `en-US`** translation file.
**5,468 of its 145,199 strings are different** from their source. The source text is W1
(international) English, and the US file adapts it:

| Source text (W1 English) | US English translation |
|---|---|
| `Set up VAT` | `Set up Tax` |
| `%1% VAT` | `%1% Tax` |
| `The VAT Date is not within the range of allowed VAT dates.` | `The Tax Date is not within the range of allowed tax dates.` |
| `County` | `State` |

In other words, **Microsoft doesn't put regional wording in its source text.** Each market's
wording comes from its translation file — even American English.

### What the framework does with that

It mirrors Microsoft:

- **Source text uses Microsoft's W1 wording** whenever it names a standard BC concept — `VAT`,
  `Credit Memo`, `County` — exactly as Microsoft's source strings do.
- **Every target language gets a translation file, including `en-US`** when the US is a target.
  US users see "Tax"; Australian users see "GST"; British users see "VAT". Each comes from its own
  `.xlf`.
- **Adding a market later is a translation task, not a code change.** An app built for the UK can
  reach Australia without touching AL source.

The one cost, stated upfront at intake: a developer building a US-only app will find "VAT" in
their own source code and may find that odd. So when `en-US` is the *only* target language — and
the app isn't headed to AppSource, which requires translation files — the agent offers a choice:

- **W1 wording plus an `en-US` translation file** (recommended) — any market later is a
  translation task.
- **US wording directly in source, with no translation files** — simpler today, but a second
  market later means revising source strings.

Every other project uses W1 wording.

---

## 6. Getting regional terminology right

A translation that's grammatically correct but doesn't use the term BC users see everywhere else
on screen — "Credit Memo" for an Australian user, whose BC says "CR/Adj Note" — fails users just as badly as no
translation.
So the framework never lets the AI model decide Business Central terminology from memory. It
applies the same discipline it already uses for table numbers and field IDs: **verify against
Microsoft's ground truth.**

### Where terminology comes from, in order of authority

| | Source | What it's authoritative for |
|---|---|---|
| 1 | **Microsoft's own BC translation files** | The exact words BC users in that market already see. Symbol packages downloaded from a sandbox already contain many of them (symbols from Microsoft's public symbol feed carry none) — the System Application package alone ships translation files for 26 languages, including `en-AU`, `en-CA`, `en-GB`, `en-NZ`, `fr-CA`, `de-AT`, `de-CH`, and `nl-BE`. |
| 2 | [Working with translation files](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files) (Microsoft Learn) | How XLIFF works in AL. |
| 3 | Business Central [Base Application](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application) and [System Application](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application) reference (Microsoft Learn) | Which standard objects and modules exist. |
| 4 | [Microsoft Terminology Collection](https://learn.microsoft.com/en-us/globalization/reference/microsoft-terminology) | General Microsoft product terminology in about 100 languages, when BC's own files have no match. |
| 5 | [Microsoft Localization Style Guides](https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides) | Tone, formality (*tu*/*vous*, *du*/*Sie*), punctuation, and formats per language. |
| 6 | [Microsoft Writing Style Guide](https://learn.microsoft.com/en-us/style-guide/welcome/) | Writing the English source text well. |

**Localization matters for rank 1.** Microsoft's Base Application translations are specific to a
localization: symbols downloaded from a US environment contain the US English file, not the
Australian one. The Australian Base Application carries the Australian file; every other
Microsoft-translated language comes in a Microsoft **language app** (§12 has the evidence). So for
each target language, the agent reads the localized Base Application if it carries that language,
and otherwise Microsoft's language app for it — fetched from Microsoft's public Business Central
artifacts, with the developer's agreement. It records which file and version each term came from.
**If it can't obtain Microsoft's file for a language, it stops and asks**, rather than filling the
gap from memory.

### Terminology verification

For every string in the extension that names a standard BC concept, in every target language, the
agent:

1. Finds Microsoft's matching source string, by exact text first, then by the object or field it
   refers to. It searches first with the AL MCP Server's `al_searchtranslations`, which reads the
   translation files inside the project's symbol packages without unpacking them.
2. Uses Microsoft's translation for that language.
3. Records the pair in the project's **translation glossary**, with the Microsoft file and version
   it came from.
4. If Microsoft has no match, falls back to the terminology collection and style guides, and marks
   the term for the human reviewer's attention.

The glossary works in both directions. It also helps the agent understand users who describe
their requirements in their own language — someone who writes *Gutschrift* is mapped to BC's
credit memo objects, not left to the model's interpretation.

**Microsoft's translation files are Microsoft's content, not open source.** The framework reads
them locally, as a terminology reference, the way BC translation tools always have. It never
copies them into a repository or ships them inside an extension.

---

## 7. How translations are produced and approved

### Tooling

The framework builds on **XLIFF Sync** by **Rob van Bekkum**, which BC developers have relied on
for years:

- **[XLIFF Sync PowerShell module](https://github.com/rvanbekkum/ps-xliff-sync)** (`XliffSync`, MIT)
  — the agent's engine. It keeps every translation file in sync with the generated `.g.xlf` after
  each build, and runs technical checks with no judgment involved: missing translations,
  placeholder mismatches, option member counts, spacing, and target text still identical to the
  source.
- **[XLIFF Sync for VS Code](https://github.com/rvanbekkum/vsc-xliff-sync)** (MIT) — the human
  reviewer's tool, for jumping between units that need attention and editing them in place.

Developers who already work with **[NAB AL Tools](https://github.com/jwikman/nab-al-tools)** by
**Johannes Wikman** (MIT) can choose it instead. The agent asks which tooling to use, recommends
XLIFF Sync, and never installs PowerShell, a module, or an extension without asking first. The
release gate below doesn't depend on which tool is chosen.

The generated `.g.xlf` is treated as a build output and gitignored. The per-language files in
`Translations/` are deliverables and always committed.

### The lifecycle of a translation

Each translation unit moves through states the XLIFF 1.2 standard already defines:

| State | Meaning | Written by |
|---|---|---|
| `needs-translation` | New source text, not yet translated | Translation tooling, on sync |
| `needs-adaptation` | A technical check failed, or the source text changed | Translation tooling |
| `needs-review-translation` | Drafted, awaiting review | The agent |
| `translated` | Text present, **not approved** | Translation tooling, e.g. when importing or copying |
| **`signed-off`** | **Approved** | **The named reviewer for that language** |

**Why approval is `signed-off`, not `translated`.** XLIFF Sync writes `translated` itself when it
imports or copies text, so that state can't prove a person read the translation. Reading XLIFF
Sync's source code also showed that it leaves `needs-review-translation` alone and doesn't report it
as missing. So the framework's gate is its own simple scan of the files, rather than a tool's
opinion.

- **Every target language has a named reviewer**, recorded at intake — a person, not a role. The
  agent never approves its own drafts.
- **Reviewers approve in their own tooling**, or by telling the agent exactly which units they
  approve. Every approval is logged by name. For an `en-US` → `en-US` file, where most units are
  unchanged copies, a reviewer can approve the unchanged units containing no glossary term in one
  decision.
- **Release gate:** a package can't be marked as the release candidate until every unit in every
  language required at first release is `signed-off` (or `final`).
- **Changing source text resets its translations.** On the next sync, the unit drops to
  `needs-adaptation` and goes back through drafting and review. A translation approved for old
  wording can never quietly ship against new wording.

### Built into the compile-and-test cycle

Translation isn't a phase tacked on at the end. From the first full build onward, every build
runs the cheap, mechanical part: **build → sync translation files → technical checks.** Once the
source text is stable — the first build the tester confirms clean on the sandbox, again before the
compile-and-test step closes, and again after any later fix that changes source text — the agent
**drafts, packages, and tests in the sandbox with the user's language switched.**

- **Source text is finished before translation starts.** The agent doesn't translate batch by
  batch while code is still being generated — `.g.xlf` only exists after a build, and translating
  text that's about to change multiplies the work.
- **A full build, not Incremental Build or RAD publishing**, for any test involving languages.
  Microsoft documents that both ignore translations entirely — an easy way to lose an afternoon.
- **An optional pseudo-translation pass** — a fake, deliberately longer, accented "language" —
  surfaces hard-coded strings and truncation before real translations exist.

### Checked again at Code Review

Code Review runs XLIFF Sync's full set of technical checks, confirms the glossary was followed,
looks for text likely to truncate (German typically runs around 30% longer than English), confirms
`Locked` is used correctly, and repeats the ML-syntax scan.

**Also enforced from generation onward:**

- No hard-coded text in `Error`, `Message`, `Confirm`, `StrMenu`, or notifications — `Label` only.
- Every label with a placeholder carries a `Comment` explaining it.
- `OptionCaption` has the same number of members as the option it describes.

---

## 8. API pages and queries: translatable or locked?

`Locked = true` on a caption means *never translate this*. For an API page or query, whose captions
mostly feed `$metadata`, the right answer depends on who ends up reading those captions. Rather
than guess, the framework looked at what Microsoft does.

### What Microsoft does

| Microsoft API objects | Captions | Locked |
|---|---|---|
| **API v2.0 business pages and queries** — customers, vendors, items, sales and purchase documents, G/L entries | 1,526 | **0** |
| **API v2.0 admin pages** (`automation` group) — users, permission sets, extension deployment, scheduled jobs | 157 | **1** |
| **Power Automate and Dataverse pages** in the Base Application | 98 | **0** |
| **Internal runtime pages** in the Base Application — webhook logs, API routes | 21 | **21** |

*Counted from Microsoft's API v2.0 source in
[microsoft/ALAppExtensions](https://github.com/microsoft/ALAppExtensions/tree/main/Apps/W1/APIV2)
and the Business Central 27.5 Base Application.*

The pattern is clear. **Anything people work with or manage is translatable.** **Pure internal
plumbing is locked.** And on Microsoft's locked pages, **tooltips stay translatable** — locking
applies only to captions.

### What the framework recommends

| Group | Recommendation |
|---|---|
| **Business** — master data, documents, ledger entries, business setup, business reporting | **Translatable** |
| **Technical: admin** — something a person manages or configures through the API | **Translatable** |
| **Technical: internal plumbing** — logs, sync state, webhooks, diagnostics | **Locked** |

### How it's decided

Once the design has a full object list, and before any code is generated:

1. The agent **classifies every API page and API query** as Business, Technical admin, or Technical
   plumbing, with a one-line reason for each.
2. Anything that could reasonably go more than one way — the extension's own setup table, an
   integration mapping table, a dashboard query — is listed as **Unsure**, and the developer
   classifies each one.
3. The developer then **chooses for each group**, with the recommendation above offered first and
   the Microsoft evidence shown alongside it. For technical objects, the choices are: admin
   translatable and plumbing locked (recommended), all translatable, or all locked.
4. The decision is **recorded per object** in the design document, checked when the code is
   generated, and checked again at Code Review. New API objects added later go through the same
   questions.

**Translatable API pages also get `EntityCaption` and `EntitySetCaption`** — the names Power
Automate and similar tools show to people — matching Microsoft's API v2.0 pages.

---

## 9. Beyond captions

Translating captions and messages is most of the work, not all of it. The framework also asks and
designs for:

- **Customer language vs. user language.** A sales invoice should reach a French-speaking customer
  in French, even when the person posting it works in English. Intake asks whether printed
  documents and emails follow the customer's language.
- **Translatable data.** If the extension stores user-entered text that needs per-language
  versions, it follows BC's established translation-table pattern (as Item Translations does),
  documented in AL Guidelines as *Multilanguage Application Data*.
- **Regional formats.** Dates, numbers, and currency follow the user's Region setting, not the
  translation, so testing covers both.
- **Report layouts.** Only report labels are translated; text typed directly into a Word or RDLC
  layout isn't.
- **Telemetry** stays `Locked`, so support can read it regardless of the user's language.
- **Teaching tips** — `AboutTitle` and `AboutText` — are translated like any other caption.

---

## 10. Documents, and the language you work in

### Project documents

The developer chooses which documents are produced in which languages. The recommendation:

- **Translate the documents people outside the development team use:** the user guide and
  deployment instructions. Files are named by language, e.g. `UserGuide.fr-CA.md`. The UAT test
  script is translated only if testers need it; it names the terms each language should show, so
  a tester who reads English can run the language pass from the English script.
- **Keep engineering documents in one language** — the design documents, change log, and code
  review — so two versions can never drift apart.
- **Translate once release testing's functional pass is green**, so fixes found in testing don't
  make every translated copy stale, and keep the source version as the canonical one.

### Working with the agent in your own language

The first question the agent asks, before anything else, is **which language you want to work in.**
Every question, option, and explanation after that comes in your language.

Some things stay in English regardless: the framework's own instructions, AL code and object
names, commit messages, and the engineering documents above. Raw requirements and tester feedback
are kept word for word in whatever language they were written.

---

## 11. Where it fits in the routine

### Full framework

| Phase | Step | What multilanguage adds |
|---|---|---|
| DEFINE | PRE-01 — State the Problem | **First question:** the language you want to work in. The problem statement names the countries and languages users work in |
| | PRE-02 — Gap Analysis | Regional terminology: every BC concept the app names whose wording differs between markets |
| | 01 — Project Parameters | Countries, languages, source language and wording, reviewers, document languages, data and customer-language needs; the translation glossary is created |
| DESIGN | 02 — FRD | Languages as a requirement; customer-language documents; translatable data |
| | 03 — TDD | Label conventions, source wording, file naming; API caption classification (§8) |
| | 04 — Sanity Check | Every language supported in its market; glossary complete; every API object classified; every reviewer named |
| BUILD | 05 — Plan the Code | `TranslationFile` enabled; `Translations/` folder; tooling agreed; translation pre-flight checks |
| | 06 — Code Generation | Source text only |
| | 07 — Compile, Package, Test | Every build: sync → check. Once source text is stable: draft → package → test in each language |
| PROVE | 08 — Gap-Fit Test | Every required language complete |
| | 09 — Code Review | Full translation checks; ML-syntax scan |
| | 10 — Update Design Docs | Glossary and language settings reflect what was built |
| | 11 — Document the Code | A language pass in the test script |
| | 12 — Release to Users for Testing | Translated user-facing documents once the functional pass is green; UAT by a speaker of each language; every translation approved before release |

### Lite edition

Lite applies the same rules with less ceremony. The glossary and language decisions live inside
its single design document rather than a separate file.

| Step | What multilanguage adds |
|---|---|
| 1 — Define & Lock Parameters | **First question:** the language you want to work in. Then countries, languages, source language and wording, reviewers |
| 2 — Design Doc & Self-Check | Languages, glossary, and API caption classification, inside `DesignDoc.md` |
| 3 — Plan & Scaffold | `TranslationFile`, `Translations/`, tooling, pre-flight checks |
| 4 — Generate the Code | Source text only |
| 5 — Compile, Package, Test | Every build: sync → check. Once source text is stable: draft → test in each language |
| 6 — Review & Finalize Docs | Full translation checks; a language pass in the test script |
| 7 — Release for Testing | Translated user-facing docs if requested, once the functional pass is green; UAT in each language; every translation approved before release |

---

## 12. The evidence behind the design

Two questions came up while building this. Both have objective answers, checked against Microsoft's
own packages and documentation on September 14, 2026.

### Where do Microsoft's Business Central translations actually live?

**In Microsoft's language apps, and in each localized Base Application for its own market's
languages.** Evidence from Microsoft's public Business Central artifact for Australia (sandbox
28.5.54151.54677, the same artifacts BcContainerHelper downloads):

- It contains **a separate Microsoft language app for each Microsoft-translated language** —
  `English language (Australia)`, `English language (United Kingdom)`, `German language (Germany)`,
  `French language (Canada)`, and 20 more. Each app's manifest says it "adds the \<language\> to
  Dynamics 365 Business Central". Each contains `Base Application.<culture>.xlf`.
- **The Australian Base Application itself** ("Base Application (AU)") contains
  `Base Application.en-AU.xlf` — byte-for-byte the same size as the one in the English (Australia)
  language app. Symbols downloaded from an Australian environment therefore already include the
  Australian wording.
- **The System Application** ships translation files for 26 languages inside its own package.

So the framework's agent looks in three places, in order:
1. The localized Base Application symbols for that market.
2. The System Application and Business Foundation symbols.
3. Microsoft's language app for any language the local Base Application doesn't carry — fetched from
   Microsoft's public artifacts only with the developer's agreement.

**What Microsoft's Australian and British files actually say:**

| | Australia (`en-AU`) | United Kingdom (`en-GB`) |
|---|---|---|
| Strings differing from source | 9,273 of 132,917 | 4,838 of 128,333 |
| "VAT" | → **GST** in 3,071 strings — but **178 stay "VAT"** (e.g. *Work with VAT*) | stays **VAT** (3,109 of 3,116) |
| "Credit Memo" | → **"CR/Adj Note"** in 450 strings (*Sales CR/Adj Note*, *Purchase CR/Adj Note*) | stays **Credit Memo** (409 of 413) |
| "County" | → **State** | unchanged |
| Other | — | British spelling: *Customize* → *Customise*, *licenses* → *licences* |

Two lessons for anyone translating a BC extension:
- **Regional English is more than a few swapped words.** It's thousands of strings, including
  spelling.
- **Microsoft's adaptations aren't blanket search-and-replace.** Some "VAT" strings stay "VAT" even
  in Australia, and the Australian credit memo term isn't the one most people would guess. Only
  Microsoft's own files can tell you — which is why the framework reads them, per term, instead of
  relying on memory.

### Does AppSource require specific languages for specific markets?

**No — for a standard AppSource app, Microsoft requires translation files and an accurate
declaration, not particular languages.**

- **Technical validation:** "The extension submitted must use translation files."
  ([Technical validation checklist](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-checklist-submission))
- **Marketing validation:** "Your app can be in any language; if not in English, a document with
  English translation is required."
  ([Language, Branding, and Images](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-a-languange-branding))
- **The offer description must end with Supported Countries/Regions and Supported Languages
  paragraphs**, and those must be written in English. The markets selected in Partner Center must
  match the countries paragraph. Microsoft adds: "Remember to test your app on every country you
  intend to support, as each country's base code is slightly different."
  ([Offer Description](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-c-offer-description),
  [Marketing Validation Checklist](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-marketing))
- **The exception is Microsoft's Validated Localization app program.** There, translation into the
  local languages is mandatory — for the localization app, its documentation, and the base app if
  the language isn't already supported.
  ([Development of validated localization apps](https://learn.microsoft.com/en-us/dynamics365/business-central/about-validated-localization-apps))

**What the framework does with that:** for an AppSource project, it always produces translation
files (the US-only "no translation files" option isn't offered). It drafts the Supported
Countries/Regions and Supported Languages paragraphs in English from the project's actual language
decisions — only languages whose translations are approved and shipping — and reminds the developer
that the Partner Center markets must match and that each listed country needs its own test.

---

## Credits and references

**The feedback.** This work exists because Business Central Microsoft MVPs, specifically Kamil Sacek, Luc van Vugt, KB, and Tom Kapitan took the time to say, clearly and early, what the framework was missing. Thank you.

**Tools and projects the design builds on:**

- [BcContainerHelper](https://github.com/microsoft/navcontainerhelper) — Microsoft Corporation, MIT
  License; its `Get-BCArtifactUrl` locates the public Business Central artifacts examined in §12
  (artifact contents are Microsoft's proprietary content, read for analysis only)
- [XLIFF Sync for VS Code](https://github.com/rvanbekkum/vsc-xliff-sync) and
  [XLIFF Sync PowerShell module](https://github.com/rvanbekkum/ps-xliff-sync) — Rob van Bekkum, MIT
  License
- [NAB AL Tools](https://github.com/jwikman/nab-al-tools) — Johannes Wikman, MIT License (supported
  alternative)
- [AL Guidelines](https://alguidelines.dev) ([source](https://github.com/microsoft/alguidelines)) —
  Microsoft and the BC community, MIT License
- [Microsoft API v2.0 source](https://github.com/microsoft/ALAppExtensions/tree/main/Apps/W1/APIV2)
  in microsoft/ALAppExtensions — Microsoft Corporation, MIT License; used to count caption locking
  in §8

**Microsoft documentation:**

- [Working with translation files](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files)
- [Compiler Warning AL0424](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al424)
- [Technical validation checklist](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-checklist-submission),
  [Marketing Validation Checklist](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-marketing),
  [Language, Branding, and Images](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-a-languange-branding),
  and [Offer Description](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-c-offer-description) (AppSource)
- [Development of validated localization apps](https://learn.microsoft.com/en-us/dynamics365/business-central/about-validated-localization-apps)
- [Translations Overview](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-translations-overview)
- [Country/Regional Availability and Supported Languages](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/compliance/apptest-countries-and-translations)
- [Multilanguage and localization](https://learn.microsoft.com/en-us/dynamics365/business-central/about-locale-language)
- [Base Application reference](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application)
  and [System Application reference](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/module/system-application)
- [Microsoft Terminology](https://learn.microsoft.com/en-us/globalization/reference/microsoft-terminology)
  and [Microsoft Localization Style Guides](https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides)

*Microsoft Learn content is © Microsoft Corporation and licensed under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); facts and short excerpts above are
summarized from the pages linked. Microsoft, Dynamics 365, Business Central, and AppSource are
trademarks of the Microsoft group of companies.*

*The OCPF BC Agentic Development Framework is © 2026 AJ Ansari, OnlyCopilotFans, MIT License —
<https://github.com/ajansari/ocpfBcAgenticDevFramework>.*
