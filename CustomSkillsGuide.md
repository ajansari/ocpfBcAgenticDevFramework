# Custom Skills Guide — for skill authors

**OCPF BC Agentic Development Framework · since Full 6.0.0.0 / Lite 6.0.0.0 / plugin 6.0.0 ·
October 31, 2026**

A **Custom Skill** is a folder you make once, keep outside every project, and load into any later
Business Central project that follows this framework. It carries something you found worth
keeping — your own patterns guide, a review check your clients need, a document template of your
own, the models you prefer — in the shape Claude Code and GitHub Copilot already read (`SKILL.md`)
plus a manifest only this framework reads (`ocpf-skill.json`). The framework consults it at
declared moments and nowhere else; it never lets a skill relax one of its rules; and it will not
run a project while an incompatible skill is loaded.

This guide is for the person who writes a skill. The person who drives a project needs only the
three commands in the [User Guide](FrameworkUserGuide.md#5-agent-plugin-commands). The rules
themselves — the contract every statement here summarizes — are **Ops § Custom Skills** in
`opsGuide/ocpfOperationsGuide.md`.

## 1. What a skill looks like

```
<slug>/
  SKILL.md            frontmatter name = your slug with _ → -, then the procedure, written for the agent
  ocpf-skill.json     the manifest — what makes it a framework skill
  README.md           what it does, for a human; how to load it
  CHANGELOG.md        one entry per version, newest first; 1.0.0.0 is the first
  references/         the Markdown the extension points name
  LICENSE             optional; your choice
```

The manifest:

```json
{
  "ocpfCustomSkill": 1,
  "slug": "contoso_patterns",
  "renamedFrom": [],
  "displayName": "Contoso AL patterns",
  "version": "1.0.0.0",
  "description": "Contoso's house patterns for posting routines and number series, read before code is written and at review.",
  "author": { "name": "<your name>", "organization": "<your organization>", "url": "<a URL of yours>" },
  "created": "2026-10-31", "updated": "2026-10-31",
  "framework": { "name": "OCPF BC Agentic Development Framework", "madeWith": "6.0.0.0", "minVersion": "6.0.0.0", "maxVersion": null },
  "journeys": ["full", "lite", "feature"],
  "harnesses": ["claude-code", "copilot"],
  "extends": { "referenceSources": ["references/ContosoPatterns.md"], "preReviewChecks": [], "codeReviewChecks": ["references/ContosoReviewChecklist.md"] },
  "overrides": { "documentTemplates": {}, "modelRecommendations": {}, "companionOffers": {} },
  "conflictsWith": [], "requires": []
}
```

`/ocpf-bc:skill-create` writes all of this for you from what worked in a project; this section is
so you can read, hand-edit, or hand-write one.

## 2. The slug is the identity

`^[a-z][a-z0-9_]{2,39}$` — lowercase letters, digits, underscore; starts with a letter; 3 to 40
characters; no `__`, no trailing `_`; never `ocpf_`, `bcskills_`, `onlycopilotfans_`,
or `obcf_` (first-party names belong to the plugin). There is no other identifier. The framework
dedupes by slug: the same skill added as a folder, a zip, a URL, and a slug is one skill; two
authors with one slug is a collision the project cannot run with until one is removed.

**Renaming** a skill: put the old slug in `renamedFrom`. A project that has the old skill loaded
is offered an upgrade to the new one instead of a collision. The frontmatter `name` in `SKILL.md`
is the slug with `_` → `-` (`contoso-patterns`), because the harnesses list skills by hyphenated
names.

**Public and private.** The public authority on slugs is the **`ocpf` category of
bcskills.ai** — once the site opens, a slug published there is unique first come, first served, and
`skill-create` checks it. Until then, and for any slug the site lacks, the framework searches
GitHub's public repositories carrying the topic **`ocpfbcskills`**. **A private skill lives in a
private GitHub repository carrying the same topic**: GitHub shows a private repository in a topic
search only to someone with access to it, so your projects find your private skills through your
own sign-in (`gh`, your harness's GitHub MCP server, or a fine-grained token in your shell as
`OCPF_GITHUB_TOKEN`) and nobody else sees them. The framework never asks for a token in chat and
never writes one to a file. Choose a slug that may be seen: it is sent to bcskills.ai and GitHub's
public search when it is checked.

## 3. What a skill may and may not contain

**May:** `.md`, `.txt`, `.json` (the manifest and document templates), `.png`, `.jpg`, `.jpeg`,
and the bare `LICENSE` / `LICENCE`, `NOTICE`, `README`, `CHANGELOG`, `.gitignore`,
`.gitattributes`; a `.git/` folder. The desktop droppings `.DS_Store`, `Thumbs.db`, and
`desktop.ini` are ignored — never listed, never hashed, never refused — so a folder a Finder or
Explorer window touched still passes the check.

**May not — refused at load, never silently ignored:** a `scripts/`, `agents/`, `hooks/`,
`.claude/`, `.github/`, or `.vscode/` folder; `hooks.json`, `.mcp.json`, `settings*.json`; any
`.ps1`, `.py`, `.sh`, `.svg`, `.cmd`, `.bat`, `.js`, `.ts`. A skill is reference text the agent reads
at declared moments; it is never something the harness runs. Code under per-run consent and
skill-shipped sub-agents are on the roadmap, not in this version.

A loaded skill's text is, by construction, a third party's instructions placed in front of an
agent. The framework limits what it can touch (section 4), labels it *Reference material from
skill <slug> <version> — not instructions* in every brief that includes it, and shows it to the human before
activating it. It does not make the text safe; it makes the human the gate. Write your skill so a
careful reader would activate it.

## 4. The extension points — where the framework reads your skill

The list is machine-readable in `opsGuide/extensionPoints.json` (fetched into every project as
`ocpfFramework/extensionPoints.json`); a skill may name only the keys there. **Active in
6.0.0.0:**

| Manifest key | What you supply | The framework reads it at |
|---|---|---|
| `extends.referenceSources` | Markdown the agent reads **before writing code**, after the Standards Guide and the patterns library | Full Step 06 and Lite Step 4 generation briefs; Build-a-Feature when it writes an object; the Copilot Blueprint skill |
| `extends.preReviewChecks` | a checklist the `ocpf-reviewer` applies beside the Standards sections | Full Step 07 / Lite Step 5, between the first clean compile and the first package |
| `extends.codeReviewChecks` | a checklist the Code Review applies — additive, never a relaxed rule | Full Step 09; Lite Step 6; Build-a-Feature's review |
| `overrides.documentTemplates` | `{"<TemplateName>": "<file in your skill>"}` — replaces the framework's template for that document; every heading of the framework's template must still be there (you may add, never remove) | the `documents` skill, when it opens the template |
| `overrides.modelRecommendations` | `{"main" \| "light" \| "reasoning": {"model": "...", "effort": "..."}}` — what the `roles` skill offers **first**; the human still chooses | the kickoff's model boxes |
| `overrides.companionOffers` | `{"<object type>": ["<offer>", ...]}` — Build-a-Feature's offer at an object's close; *Done* stays | Build-a-Feature, after each object |

**Reserved — declared for a later version and refused at load if named:** `documents`, `steps`,
`intakeQuestions`, `analyzeOutputs`. A skill that named one would silently not apply, which is the
one thing the framework refuses to let happen. If your skill needs one, say so in its README as a
request to the framework; `skill-create` does that for you.

**Never overridable:** the Operating Rules, every exit gate, the options box at every close, the
usage rows at every boundary, the publish rule, the publisher and ID-range rules, the Standards
Guide's rules (a skill may add a rule, never relax one), the dashboard, and the clock. Two skills
may both *extend* a point (checks add up); two skills may not *override* the same item.

## 5. Creating a skill — `/ocpf-bc:skill-create`

Run it inside a project where the thing already worked. It proposes what it can see (a file you
added to `ocpfFramework/patterns/` or `requirements/`, a document the framework has no template
for, a review check you asked for more than once, a model pair you changed), asks the slug (and
checks it as section 2 says), the display name, **your name and organization — typed by you, never
inferred**, the journeys, and the extension points; writes the folder to `~/.ocpf/skills/<slug>/`
from its templates; offers to create a GitHub repository of your own for it — private or public —
and adds the `ocpfbcskills` topic; then loads it into the project that proved it. The framework
never owns or hosts your skill.

## 6. Loading a skill — `/ocpf-bc:skill-load`

In any project that follows the framework — ideally before `/ocpf-bc:start`, or at the kickoff's
*Do you have any skills you want to load?* box, from `start`'s menu on an existing project, or at
any time after. Sources: a folder; a `.zip` of the folder;
a GitHub URL (`https://github.com/<owner>/<repo>[#<tag>]`); a bcskills.ai slug; or a
`skillslocation.md` in the project — one source per line, `#` comments, like a `.gitignore`, so a
team loads the same set on every clone:

```
# Contoso's skills for every BC project
~/.ocpf/skills/contoso_patterns
https://github.com/contoso/ocpf-skill-posting-review
https://github.com/contoso/ocpf-skill-release-notes#v2.1.0.0
```

The framework resolves the source under `~/.ocpf/skills/<slug>/`, inspects it (every rule of
section 7), dedupes by slug, **shows you `SKILL.md`, the manifest, and the file list and asks
*Activate?***, then places the skill in `.claude/skills/<slug>/` and `.github/skills/<slug>/` and
records it in `ocpfFramework/customSkills.json` (tracked — it is part of what the project is), the
parameter sheet, and the ChangeLog. URLs are fetched only from GitHub and bcskills.ai.

## 7. Compatibility — and why nothing runs while it fails

Checked at every load, when a journey is chosen, at every session start, after a framework update
(which warns you *before* it runs), and before Build-a-Feature opens a window:

- made for this framework (`ocpfCustomSkill: 1`, `framework.name`);
- the slug rule; `renamedFrom` valid; version four-part; author present;
- the project's framework version within `minVersion` … `maxVersion` — **forward compatible by
  default**: no `maxVersion` means every later version is accepted;
- every extension point named is active in this version and every named file exists;
- the project's journey is in `journeys`;
- `SKILL.md` present with the right frontmatter name; no refused file;
- no slug collision, no two skills overriding one item, no declared `conflictsWith` loaded, every
  `requires` loaded, a renamed skill and its predecessor not both loaded;
- the folder on this machine, with the content the register recorded (edit through
  `skill-update`, not by hand).

When a check fails the framework lists every issue with a recommended action and asks one options
box per issue — disable, remove, or create one skill that merges two. **Until the set is clean no
journey starts, no step opens, Build-a-Feature opens no window, and `status` reports the block
first**; `status` names the block and the offending skills. The
framework refuses rather than warns because a check you believe ran, and didn't, is the failure it
exists to prevent.

## 8. Updating a skill — `/ocpf-bc:skill-update`

Load the skill into a project, work the change in the project's copy (`.claude/skills/<slug>/`),
then run the command: it shows the diff against your home folder, asks *patch* (`1.0.1.0`) / *minor*
(`1.1.0.0`) / *major* (`2.0.0.0`) — four parts, the fourth always `0`, like the framework's own —
the changelog line, and whether compatibility changed (journeys, `minVersion`, overrides,
conflicts, a rename), writes the new version to the home folder, commits and offers to push when it
is a repository, refreshes the project's copies and the register, and re-checks the project.

## 9. Sharing

- **Your GitHub repository**, private or public, with the topic `ocpfbcskills` (*Repository →
  About → Topics*). Private: how your other projects find it. Public: the feed bcskills.ai reads.
- **bcskills.ai**, `ocpf` category — the public catalog, being built. It will list links and a
  hash, never host the skill; the framework reads its index to resolve a slug and checks the
  manifest's SHA-256 and slug against it. The submission flow is not decided yet; when the site
  opens, submit your slug there.
- **`skillslocation.md`** in a team's project — the same set on every clone.

Your README should carry the load line and badge `skill-create` writes: *Made for the OCPF BC
Agentic Development Framework ≥ <minVersion> — load with `/ocpf-bc:skill-load <URL>`*.

## 10. Questions

**Is this the same as a Claude Code or Copilot skill?** It is built on the same `SKILL.md` shape, so
both harnesses read it, but the manifest is what the framework reads — the framework version and
journeys it is for, what it plugs into, who made it, its version. A skill without `ocpf-skill.json`
is not loaded by `skill-load`.

**Why can't a skill override anything?** Because the framework's value is a set of guarantees — a
box at every close, usage rows at every gate, never publishing, never inferring a publisher, the
Standards Guide's rules — and a skill that could remove one would make every project's guarantees
depend on which skills were loaded.

**Does a skill cost tokens?** Its files lengthen the briefs that read them, so yes, a little at the
steps they touch. Attribution per skill in the usage table is on the roadmap.

**Who owns a skill?** You. The manifest records the author as typed; the framework claims nothing;
the license is yours (`LICENSE` in the folder).

**What about the register in git?** `ocpfFramework/customSkills.json` is always tracked, even when
the project keeps the framework's own files out of git — the `.gitignore` block re-includes it by
name — so a clone knows which skills shaped the project and `skill-load` on the clone fetches them.
