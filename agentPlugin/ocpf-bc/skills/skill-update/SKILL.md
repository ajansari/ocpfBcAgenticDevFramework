---
name: skill-update
description: Update a Custom Skill of the OCPF BC Agentic Development Framework that is loaded in the current Business Central project - show the difference between the project's copy, where the change was worked and proven, and the skill's home folder (or clone), ask what kind of change it is (patch, minor, major - four-part versions with the patch in the third part, as the framework's own), the changelog line, and whether compatibility changed (journeys, minimum framework version, overrides, conflicts, a rename), write the new version back to the home folder, commit and offer to push when it is a repository, refresh both harness folders and the register, re-check the project's loaded set, and record it in the ChangeLog. Use when the user says "update the skill", "bump our patterns skill", "publish the change to the skill", "rename the skill", or runs /ocpf-bc:skill-update.
---

# Update a Custom Skill that is loaded here

**Follow `Ops § Custom Skills` in the Operations Guide** (`ocpfFramework/opsGuide/ocpfOperationsGuide.md`)
— sections 1, 4, 5, 9, and 11. The skill must be **loaded in the current project**: the change has to
have worked somewhere, exactly as the framework's own skills are fixed in a real run before they are
released. The helper is the `skill-load` skill's `ocpf-skills.py` / `.ps1` (in
`ocpfFramework/scripts/`). Every question goes through the harness's options mechanism (Ops § Asking
and Approvals); the changelog line is the one free-text answer.

## Step 1: Which skill, and is it loaded?

Read `ocpfFramework/customSkills.json`. No register, or the named skill absent → *`<slug>` is not
loaded in this project — load it first with `/ocpf-bc:skill-load`, work the change in
`.claude/skills/<slug>/`, then come back*; stop. Several skills loaded and none named → one box
listing them. Read the entry's `folder` (the home folder, `~/.ocpf/skills/<slug>/`, or the clone) —
when it is not on this machine, say so and stop: the home folder is where the new version is written.

## Step 2: The diff — the project's copy against the home folder

The human worked the change in the project's copy, `.claude/skills/<slug>/` (or
`.github/skills/<slug>/` — take whichever is newer and say so when they differ). Compare it with the
home folder: files changed, added, removed, with a short diff of each Markdown file; run the helper's
`--hash` on both and say whether they differ. **Nothing changed** → say so and stop. A changed
`ocpf-skill.json` is shown field by field — the manifest is edited **here**, by this command, never
by hand in the copy: a hand-edited `version` or `slug` is undone and asked below.

## Step 3: What kind of change? — one box, three questions

1. **Kind** — *Patch — a fix; `<x.y.z+1.0>`* / *Minor — a new capability or a new file; `<x.y+1.0.0>`*
   / *Major — a changed extension point, override, or rename; `<x+1.0.0.0>`* — four parts, the fourth
   always `0`, as the framework's own versions go (`5.9.3.0` → `5.9.4.0` was a patch). Recommend the smallest
   kind the diff supports: a changed reference file is a patch, a new file or a new extension point
   a minor, a removed file, a changed override, or a rename a major.
2. **Changelog line** — free text (*I'll type it*), with a suggestion drafted from the diff first.
3. **Compatibility** — *Unchanged (recommended when only reference text changed)* / *Changed — I'll
   say which*: journeys, `minVersion` (raise it when the skill now relies on a point this version
   introduced), a new override, a new `conflictsWith` or `requires`, or **a rename** — a new slug,
   validated exactly as `skill-create` Step 2 does (format, reserved prefixes, the register,
   bcskills.ai, the private topic on request), the old slug appended to `renamedFrom`, and
   `SKILL.md`'s frontmatter `name` rewritten to match.

## Step 4: Write the home folder

In `~/.ocpf/skills/<slug>/` (or the clone): the changed, added, and removed files from the project's
copy; the manifest's `version` and `updated` (today), and the compatibility fields from Step 3; the
CHANGELOG entry (`## <version> — <date>`, the line, newest first). Then **inspect** —
`ocpf-skills --inspect <home folder> --framework-version <runbookVersion> --extension-points
ocpfFramework/extensionPoints.json` — and fix what it reports; `ok: true` is the gate. On a rename
the folder is renamed to the new slug too (the register's `folder` follows).

**When the home folder is a repository** (`.git/` present): `git add -A`, `git commit -m "<version>:
<changelog line>"`, and one box — *Push to <remote> now (recommended)* / *Not now* — pushed through `gh`
(rung 2 of Ops § Custom Skills → 9) when it answers, else through the human's own Git credentials
only after rung 5's box — *Use the GitHub credential your Git already stores, this once, to push
<remote>?* **Yes — this once** / *No* — asked every time, with `GIT_TERMINAL_PROMPT=0`; never
through a token the framework asked for. A tag `v<version>` is offered in the same box's text as something the human may
want (`git tag v<version>`), not done unasked.

## Step 5: Refresh the project, re-check, record

1. Copy the home folder to `.claude/skills/<slug>/` and `.github/skills/<slug>/` (both; on a rename,
   the old folders are removed and the new ones written).
2. The register entry: `version`, `contentHash` (the helper's `--hash` on the home folder),
   `compatibility`, `renamedFrom`, `folder`, `displayName`; a new `sources[]` entry is **not** added —
   the source is unchanged; on a rename the entry moves to the new slug.
3. The sheet's **Custom skills** row (Full `ProjectParameters.md` §1.11 / Lite's row /
   `FeatureRegister.md` §1) rewritten from the register.
4. **The project check** — `ocpf-skills --check --project "<root>"` — and the refuse-to-run rule of
   the `skill-load` skill's Step 5 when it fails (a major that removed a point another loaded skill
   requires is the usual cause).
5. One ChangeLog line: *Custom skill updated*: slug, old → new version, the changelog line, pushed or
   not.

## What this skill never does

Never updates a skill that is not loaded here; never edits the home folder without showing the diff
first; never chooses the version kind for the human; never writes a token; never pushes without the
box; never leaves the register's `contentHash` behind the folder (that is what makes the next
`--check` report `content`).
