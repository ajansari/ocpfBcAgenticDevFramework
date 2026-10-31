---
name: skill-create
description: Turn something that worked in a Business Central project built with the OCPF BC Agentic Development Framework - your own patterns guide, an extra review check, a document template of your own, a model recommendation - into a Custom Skill other projects can load - a folder outside the project with a SKILL.md, an ocpf-skill.json manifest whose slug is its identity, a README with the load line and badge, a CHANGELOG starting at 1.0.0.0, and the reference files; asks every question in options boxes (what becomes the skill, the slug and its validation against the register, bcskills.ai, and your private GitHub topic, the author typed by you, the journeys, the extension points it plugs into), writes the folder to ~/.ocpf/skills/<slug>/, offers to create a GitHub repository of your own for it with the ocpfbcskills topic, and loads it into the current project. Use when the user says "make this a skill", "turn our patterns guide into a skill", "create a custom skill", "package this check for other projects", or runs /ocpf-bc:skill-create.
---

# Create a Custom Skill from this project

**Follow `Ops § Custom Skills` in the Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`)
— sections 1 (the folder and the manifest), 2 (the extension points), 9 (the GitHub identity ladder),
10 (bcskills.ai), and 11 (creating a skill). This skill is the procedure; the `skill-load` skill's
helper (`ocpfFramework/scripts/ocpf-skills.py` / `.ps1`; the plugin's `skill-load/scripts/` copy when
it is not there yet) inspects what you write before anything is loaded. **The human types the
author; you never infer it** — Ops § Intake → *Forbidden sources* applies to a skill's author exactly
as to an app's publisher.

Every decision goes through the harness's options mechanism (Ops § Asking and Approvals), the
recommended option first, a one-line reason on each: `AskUserQuestion` in Claude Code, `askQuestions`
in Copilot Chat, `ask_user` in the Copilot CLI (add *I'll type it* where a typed answer is possible).
Free text is expected wherever a value only the human knows is asked — what becomes the skill, the
slug, the display name, the author, a document or role an override names, the repository's owner —
always through the mechanism's own typed entry, never an open question in chat.

## Step 0: Where you are

Run inside a project that follows the framework (`ocpfFramework/framework.json` exists) — the skill
is made from something that **worked here**. Read the marker's `runbookVersion` (it becomes the
skill's `framework.madeWith` and `minVersion`), `ocpfFramework/extensionPoints.json` (the points the
skill may name; fetch it as `skill-load` Step 0 says when it is missing), and
`ocpfFramework/customSkills.json` when it exists. Outside a framework project, say so and offer
`/ocpf-bc:start`; a skill is not written from nothing.

## Step 1: What becomes the skill? — one box

Propose the candidates you can see, up to three, plus *I'll describe it*:
- a file the human added to `ocpfFramework/patterns/` or `requirements/` that is not the framework's
  (compare with the fetched set — the patterns library's `SNAPSHOT.json` lists its files);
- a document under `docs/` that no template in `ocpfFramework/documentTemplates/` produced;
- a check the human asked for more than once (`docs/0-project/ChangeLog.md`, `ProjectMemory.md`:
  the same review request in two or more entries);
- a model-and-effort pair the human changed from the recommendation (`ProjectParameters.md`, the
  roles section).

Say in one line why each is a candidate. On *I'll describe it*, free text: what it does, where it
should apply. A skill may bundle several of these when they belong together (a patterns guide and
the review check that enforces it).

## Step 2: The identity — one box, five questions

1. **Slug** — free text, with the rule in the question: *lowercase letters, digits, underscore;
   starts with a letter; 3–40 characters; no `__`, no trailing `_`; not `ocpf_`,
   `bcskills_`, `onlycopilotfans_`, or `obcf_` — this is the skill's one identity, everywhere.* Offer
   one suggestion built from the human's own wording of Step 1 (never from a company name seen on the
   machine) plus *I'll type it*. Say in the question that the slug is checked against bcskills.ai and
   GitHub's public search, so a slug that must stay confidential (a client's name) should not be
   chosen.
2. **Display name** — a suggestion from the same wording plus *I'll type it*.
2a. **Description** — one sentence for the manifest and the README; a suggestion from the same
   wording plus *I'll type it*.
3. **Author** — *I'll type my name and organization* (free text, two values); the only other option
   is a name the human **typed earlier in this session**, quoted with where. Never `git config`, an
   email domain, the publisher of the app, or another project.
4. **Journeys** — *All three (recommended for reference material and checks)* / *Full and Lite* /
   *Build-a-Feature only* / *I'll say*.

**Validate the slug before the next box, and re-ask on a failure, alone:**
- the format and the reserved prefixes (the helper's rule: write a one-file manifest to a temporary
  folder and run `--inspect`, or apply the regex yourself — say which);
- the project's register: a loaded skill with that slug, or one whose `renamedFrom` names it, is a
  collision unless the human means an update (then `skill-update`);
- **bcskills.ai**: `https://bcskills.ai/api/ocpf/skills/<slug>.json` — an entry means the slug is
  taken publicly: *a public skill with this slug exists at <repository>; choose another*. The site is
  being built; a 404 or an unreachable host is expected and said in one line, and the public check
  falls back to the topic search `topic:ocpfbcskills <slug> in:name` (rung 1 of Ops § Custom
  Skills → 9; one call);
- **the human's private skills**, only when they ask (*Also check my private skills on GitHub* typed
  in the box, or a yes to the one-line offer when `gh`, the GitHub MCP server, or a token in the
  environment is present): the same search through rung 2, 3, or 4 — never rung 5 for a check.

## Step 3: How it plugs in — one box, two questions

1. **Extension points** (multi-select; Ops § Custom Skills → 2, the `active` ones only, each in one
   line): *Reference sources — read before code is written (Step 06 / Lite 4 / Build-a-Feature)* /
   *Pre-review checks — the reviewer reads them before the first package* / *Code-review checks —
   Step 09 / Lite 6 / Build-a-Feature's review*. Reserved points are not offered.
2. **Overrides** (multi-select, or *None (recommended)*): *A document template* (which document, and
   the headings may be added, never removed) / *The recommended models and efforts* (which role, which
   pair) / *Build-a-Feature's companion offers* (which object type, which offers; *Done* stays).

A need no point serves — "a step between 05 and 06", "a question in the intake" — is said back in one
sentence: *that is a reserved extension point; the skill's README will record it as a request to the
framework, and the skill will not pretend to do it.* Never invent a hook.

## Step 4: Write the folder — `~/.ocpf/skills/<slug>/`

Create `~/.ocpf/skills/` if absent (beside the calibration store, outside every project). If
`~/.ocpf/skills/<slug>/` exists, ask before overwriting — *Replace it* / *Choose another slug* /
*Stop* — and never overwrite one whose manifest names another author. Write, from this skill's
`references/` templates with every placeholder replaced:

| File | Content |
|---|---|
| `SKILL.md` | frontmatter `name: <slug with _ → ->`, a one-paragraph `description` that says what the skill supplies and when the framework reads it; then the procedure in the plugin's skill style — what the files are, which steps read them, the Standards § and Ops § it leans on; written for the agent that will read it, not for a human |
| `ocpf-skill.json` | `ocpfCustomSkill 1`, `slug`, `renamedFrom []`, `displayName`, `version "1.0.0.0"`, `description`, `author` as typed, `created` and `updated` today (ISO date), `framework {name, madeWith, minVersion}` = this project's `runbookVersion`, `maxVersion null`, `journeys`, `harnesses ["claude-code", "copilot"]`, `extends` and `overrides` from Step 3 naming the files below, `conflictsWith []`, `requires []` |
| `README.md` | what it does, for a human; the line **Made for the OCPF BC Agentic Development Framework ≥ <minVersion> — load with `/ocpf-bc:skill-load <the repository URL from Step 5, else the folder>`**; the badge `![OCPF skill](https://img.shields.io/badge/OCPF%20BC%20framework-%E2%89%A5%20<minVersion>-blue)` (static: its text is in the URL, so it depends on nothing of bcskills.ai); the ways to load (folder, the repository URL when one exists, `skillslocation.md`) — the template's *this repository* bullet is filled from Step 5 or dropped when the skill stays local; any request to the framework from Step 3 |
| `CHANGELOG.md` | `## 1.0.0.0 — <date>` and one line per thing it supplies |
| `references/<file>.md` | the reference files **copied** from the project (never rewritten — the point is that they worked); a document template as `templates/<Name>.md` |

Then **inspect it** — `ocpf-skills --inspect ~/.ocpf/skills/<slug> --framework-version <v>
--extension-points ocpfFramework/extensionPoints.json --register ocpfFramework/customSkills.json` — and
fix anything it reports before going on; `ok: true` is the gate. Show the human the file list and
`SKILL.md`.

## Step 5: A repository of the human's own — one box, asked before the README is final

> **Create a GitHub repository for it under your account? (recommended for sharing and for loading it
> into other projects)** — *Yes, private* / *Yes, public* / *Keep it local — a folder is enough*; with a
> yes, the owner (`<user>`, or an organization the human names) in the same box

The answer decides the README's load line and *this repository* bullet (Step 4), so **this box is asked
before Step 4's README is written** — Step 4 writes the folder, then this step acts. On a yes, through
rung 2 only (`gh`; Ops § Custom Skills → 9): the README lines filled with
`https://github.com/<owner>/<slug>`; `git init -b main` and a first commit in the folder when it is
not a repository yet; `gh repo create <owner>/<slug> --private|--public --source ~/.ocpf/skills/<slug>
--push`; then **`gh repo edit <owner>/<slug> --add-topic ocpfbcskills`**. On *Keep it local*, the load
line names the folder and the *this repository* bullet is dropped. Say why the topic matters, in one sentence per case:
**private** — it is how your other projects find this skill through your own sign-in; **public** —
it is the feed bcskills.ai harvests, and when the site opens you submit `<slug>` there (the
submission flow is not decided yet; nothing in the skill depends on it). Without `gh`: write the
repository steps into the closing message — create the repository on github.com, push the folder,
then *Repository → About → Topics → `ocpfbcskills`* — and record the source as a folder for now.
The framework never owns or hosts a developer's skill; the repository is theirs.

## Step 6: Load it here, and record it

Run the `skill-load` skill's Steps 3 to 6 on `~/.ocpf/skills/<slug>` (source type `folder`, or `url`
when a repository was created and pushed), so the project that proved the skill is the first to carry
it — the *Activate* box included. Add one ChangeLog line (*Custom skill created*: slug, version, home
folder, repository when one exists). The closing message: the folder, the files, the repository URL
if any, the extension points in effect, and — when the skill is public — the one line about
bcskills.ai.

## What this skill never does

Never infers the author; never writes a slug the rule or a public check refuses; never writes code,
a hook, an MCP server, a settings file, or a sub-agent into a skill; never names a reserved extension
point in a manifest; never creates a repository under an account that is not the human's; never asks
for or stores a token; never hosts the skill anywhere the framework controls.
