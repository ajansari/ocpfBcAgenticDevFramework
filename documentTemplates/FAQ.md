# <App Name> — Frequently Asked Questions

> Template — OCPF BC Agentic Development Framework. Written at Full Step 11 / Lite Step 6 when the
> human chooses the FAQ tab of the help site (the `html-docs` skill; Ops § Help Site), or on request
> (`/ocpf-bc:documents FAQ`). Remove this note from the written document.
>
> **Who reads it:** the people who use the extension in Business Central and the administrator who
> set it up — never a developer looking for the API (that's `Documentation.md`). **Where the answers
> come from:** the User Guide, the Documentation, the Deployment guide, the ChangeLog's testing
> findings, the Human Unit Test Script's red-team cases (every refused action is a question), and
> the human's own list of questions. Nothing is invented: a question with no source in the project
> is left out, and an answer never promises behaviour the code doesn't have.
>
> **Shape:** one `##` heading per topic, one `###` per question, the answer directly under it in one
> to five short paragraphs or a short list. On the help site every `###` becomes a collapsible
> entry, so the question is the whole line and the answer stands on its own without the question.
> Aim for 15 to 30 questions; fewer than 8 means the tab isn't worth having yet. Keep every topic
> heading; a topic with no question stays with *N/A — <reason>* under it.

**Version:** <app version this FAQ describes> · **Date:** <YYYY-MM-DD> · **Language:** <language of this document>

## Getting started

### What does <App Name> do?
<Two or three sentences, in business terms, from the User Guide §1.>

### Who is it for?
<The roles the User Guide names; who sets it up and who uses it day to day.>

### What do I need before I can use it?
<Permission sets by name, the setup an administrator must do once, any external account or key.>

### Where do I find it in Business Central?
<Page names, the search words that find them, the action names and where they sit on the card.>

## Using it

### How do I <the first task the User Guide teaches>?
<The steps, in order; link to nothing — the text stands alone.>

### <One question per task the User Guide covers>
<…>

### What does the <field or status> field mean?
<Business meaning of each value, from the User Guide's field explanations.>

## Setup and administration

### How do I set it up for a new company?
<From the setup section of the User Guide or Deployment: once per company, by whom, what is entered.>

### Which permission sets do I assign, and to whom?
<Table or list: permission set name, who gets it, what it allows.>

### How do I install, update, or remove it?
<From Deployment: the install procedure in one paragraph, what happens on update, what uninstall leaves behind or removes.>

## When something is refused or goes wrong

### Why do I see "<the first error message a user can meet>"?
<The cause and what to do — from the test script's red-team cases and the troubleshooting table.>

### <One question per error or refusal a user can meet>
<…>

### Where is the log, and what do its entries mean?
<Only if the extension keeps one.>

## Data, limits and privacy

### What data leaves Business Central, and where does it go?
<Exactly what the extension sends out, to whom, and when; "nothing" when nothing does.>

### Are there limits — volume, size, rate, supported countries, languages?
<From the Documentation's limitations section.>

### How long is data kept?
<Retention policies the extension registers; what a user can delete.>

## Versions and support

### Which version am I on, and what changed?
<Where the version is shown in BC; the ChangeLog or release notes as the record.>

### Where do I get help?
<The support channel the help site's header names — an issues page, an email, a partner.>

---

## Before calling this done
- [ ] Every answer has a source in the project's own documents or the human's list; nothing is invented
- [ ] No answer names an internal code (OQ-, GA-, CR-, FR-), a design document, or a repository path
- [ ] Every error message a user can meet has its question (the test script's red-team cases walked)
- [ ] Every `###` line is a question a user would type, in their words, not the feature's name
- [ ] Reviewed by the human — the FAQ speaks for the publisher
