---
name: html-docs
description: Build a polished HTML documentation and support site for a Business Central extension built with the OCPF BC Agentic Development Framework - one page, docs/index.html, with tabs for the User Guide, the Documentation, an FAQ, the Deployment guide, and any other guide the project has, the app icon, an optional banner and publisher logo, a download button for the package, a support link, the schema diagram rendered in the browser, screenshots the human provides (asked for, renamed, placed), and the steps to publish it on GitHub Pages and link it from app.json as the extension's Help. Full Step 11 and Lite Step 6 offer it once the Markdown documents exist; Build-a-Feature never offers it, but it runs on request on any project. Use when the step reaches the offer, when the user says "build the help site", "make HTML documentation", "I want a documentation site", "publish the docs on GitHub Pages", "add an FAQ", "rebuild the help page", or runs /ocpf-bc:html-docs.
---

# Help site — polished HTML documentation and support

**Follow `Ops § Help Site`** in the project's Operations Guide for the files, where they live, and
the rules; this skill carries the page template, the build script, the FAQ shape, the screenshot
procedure, and the GitHub Pages steps. The Markdown documents stay the record (Full Step 11 and
Lite Step 6 write them, always; Ops § Documents); the site is **built from them** and rebuilt
whenever they change, never written by hand and never a second copy to keep current.

**What it produces** — one page, `docs/index.html`, that looks like a product's help site: the app
icon and name, a tagline and the version, a download button for the package, *Get support* and
*View on GitHub* links, an optional banner, and a sticky tab bar — **User Guide**, **Documentation**,
**FAQ** (collapsible questions), **Deployment**, and any other guide — each tab a Markdown document
rendered with its headings, tables, code, Mermaid diagrams (drawn in the browser), and screenshots.
Deep links work (`#documentation-3-api-reference`), it prints, and it needs no server: GitHub Pages
serves the `docs/` folder as it is. The reference build is the OnlyBCFans Google Address
Validator's help site, from which the template comes.

**Where it lives** — all of it under `docs/`, because GitHub Pages' *Deploy from a branch* can
publish only the root or `/docs` (`references/github-pages.md`; the reference project tried `docs/help/`
and a root `help/` first and settled on `docs/`): `docs/index.html` (built),
`docs/site.json` (the project's configuration), `docs/template.html` (the page shell, copied from
this skill, restyled per project if wanted), `docs/build.py` (copied from this skill, never
edited per project), `docs/.nojekyll` (written by the build), `docs/assets/` (icon, banner,
publisher logo), `docs/screenshots/`. **This is the one exception to "nothing loose in `docs/`"
(Full Rule 9, Ops § Documents) and it is tracked like every other project document.** Nothing of
it goes under `ocpfFramework/`, `images/`, or the project root.

**When it runs** — Full Step 11 and Lite Step 6 offer it in a box once the step's documents exist
and before the release-candidate question: **Build the help site now (recommended)** / *Not now —
ask me again at the hand-off* / *No help site for this project*. Build-a-Feature **never offers
it** (a quick mod's close is two minutes; Ops § Build-a-Feature). On request —
`/ocpf-bc:html-docs`, "build the help site", "HTML documentation" — it runs on any project with an
`app.json` and a `docs/` folder, a feature project included, and asks everything below itself.

The **Main model** does everything here; no sub-agent. Every question goes through the options
mechanism (Ops § Asking and Approvals): `AskUserQuestion` in Claude Code, `askQuestions` in
GitHub Copilot Chat, `ask_user` in the Copilot CLI. Never a prose question.

## Step 1: Know the project — read, don't ask

- `app.json`: name, publisher, version, `help`, `url`, `logo`. `git remote -v`: the repository URL,
  and whether it is on GitHub. `outputAppPackage/`: the latest package, for the download button.
- `docs/`: which documents exist — Full: `4-prove/UserGuide.md`, `Documentation.md`,
  `Deployment.md`, `FAQ.md`, other guides in `4-prove/` (a setup guide for an external service,
  for example); Lite: `4-prove/Docs.md` (its user-guide and deployment sections are tabs of their
  own, cut at their `##` headings by `site.json`'s `section`) and `FAQ.md`; feature project:
  `docs/Documentation.md` and `docs/FAQ.md`. An existing `docs/site.json` means a **rebuild**: keep
  its answers, ask only what's new (a new document, new screenshots), and go to Step 5.
- The icon brief (Ops § Intake → *The app icon*): the colors the human named there are the site's
  accent colors; otherwise the template's defaults stay. **Never pull a color, a logo, or a banner
  from a website or an e-mail signature** (Ops § Intake → *Forbidden sources*).
- `ocpfFramework/framework.json` → `tooling.mermaid`: `npx-cached` or `installed` means Node is
  there and the build's Markdown converter (`npx marked`) will run with nothing installed.

## Step 2: Ask what goes on the site — one box, several answers

**Which tabs?** (multi-select; every existing document pre-recommended): **User Guide** /
**Documentation** / **FAQ** / **Deployment** / *<each other guide found in `docs/4-prove/`, by
name>*. Say in the question which of them exist already and which would be **written now**:
- **FAQ** is written now, from `ocpfFramework/documentTemplates/FAQ.md` through the `documents`
  skill, into `docs/4-prove/FAQ.md` (`docs/FAQ.md` on a feature project) — from the User Guide, the
  Documentation, the Deployment guide, the test script's red-team cases (every refused action is a
  question), and the ChangeLog's testing findings. Nothing invented; the template's note says so.
  A second box right after, free text welcome: **Any questions users have actually asked?** —
  *None I know of — write it from the documents* / *I'll list some* (typed). Fifteen to thirty
  questions is the target; fewer than eight and the tab waits for a later rebuild.
- A **User Guide** on a project that has none (a feature project; a Lite project whose Docs.md
  user-guide section is thin) is written now from `UserGuide.md`'s template, the same way.
- On a Lite project the **User Guide** and **Deployment** tabs are `Docs.md`'s own sections
  (`"section": "User guide"` and `"section": "Deployment"` in `site.json` — the regex is matched
  anywhere in the `##` line, case-insensitively) and **Documentation** is the whole file minus
  those two (`dropSections`). Say so; the human may prefer one *Docs* tab.

The **default tab** is the User Guide when there is one, else the Documentation. **The User Guide
template already has a "Frequently asked questions" section:** when the FAQ tab is chosen, its
questions move into `FAQ.md` and that section is listed in `site.json` → `dropSections`
(`"Frequently asked questions"`), so the site never carries two FAQs. Tab keys are the deep-link
prefixes: no key may be another key plus `-…` (the build refuses `user` beside `user-guide`).

## Step 3: Screenshots — ask early, say where, rename, place

`references/screenshots.md` is the procedure; its rule in one line: the human takes them, the
agent names them. One box: **Yes — I'll add screenshots (recommended)** / *No screenshots* /
*Later — build without them now* (a rebuild adds them). On yes, in the same message:

1. **Where:** `docs/screenshots/` — create it; any file name; PNG preferred.
2. **What:** a list from the User Guide's task sections — one picture per thing the guide tells
   the reader to open, click, or look at (setup page or wizard with test data, the card with the
   action, each dialog, the result, the log), standard light theme, browser maximised, page title
   and action bar in the frame. Never a real key, a real customer, or a real address.
3. **Then:** *Tell me when they're in* — the next box is **They're in — rename and place them** /
   *Build without them*.

When they're in: **look at every file** (the file read tool shows images), say in one line what
each shows, propose its name in the shape `<page-or-object>-<what-is-happening>.png` (lowercase,
hyphens, ASCII; `setup-page.png`, `wizard-2-api-key.png`, `error-not-set-up.png`), and show the
whole old → new list in one box: **Rename all as proposed (recommended)** / *I'll adjust some*
(typed). Rename only after that answer (`git mv` when tracked). Then reference each from the
Markdown source where the guide talks about it — `![<what it shows>](../screenshots/<name>.png)`
from `docs/4-prove/`, `screenshots/<name>.png` from a flat `docs/` — right after the sentence
that tells the reader to open that thing, one per step at most, with an alt text that stands in
for the picture. A screenshot the agent can't make sense of is asked about, by file name.

## Step 4: Identity and links — one box

Propose, from Step 1, and ask once (free text where the proposal is wrong):
- **Repository link and download button:** **Link the GitHub repository and offer the package for
  download (recommended)** — the button points at
  `<repo>/raw/<branch>/outputAppPackage/<Name>_<version>.app` (`"downloadUrl": "auto"`, `"branch"`
  from `git symbolic-ref refs/remotes/origin/HEAD`, else `main`; the package must be committed and
  the repository public for the link to work — say so) / *Repository link, no download* / *Neither*.
- **Support link:** **The repository's Issues page (recommended)** / *An e-mail address* (typed) /
  *A URL* (typed) / *None*.
- **Banner and publisher logo:** *I have a banner — it's in `images/`* / *I have a publisher logo
  in `images/`* / **Neither — icon and name only (recommended when there is none)**. A file the
  human names is copied to `docs/assets/`; nothing is drawn or fetched here.
- **Tagline** — propose one line from the problem statement (what the app does, for whom);
  **Footer credit** — propose *Created by <publisher>*; the human edits either by typing.

Copy the app icon: `src/logo/AppLogo.png` (or `images/AppIcon.png`) → `docs/assets/app-icon.png`.
No icon: the template shows the name alone (`"icon": ""`).

## Step 5: Build it — and look at it

1. Copy `templates/build.py` and `templates/template.html` from this skill into `docs/` (on a
   rebuild, `build.py` is replaced — it is the skill's, never edited per project; `template.html`
   is replaced only when the human didn't restyle it — ask when a diff shows they did). Write
   `docs/site.json` from `templates/site.json` with the answers: `tabs` in the order chosen,
   `defaultTab`, `branch`, `helpUrl` left blank until Step 7's URL is known, `substitutions` empty,
   `dropSections` with the User Guide's FAQ section when the FAQ tab exists. `colors` may be left
   out: the build fills the template's defaults for any token not given.
2. Run `python3 docs/build.py` from the project root. The converter ladder is in the script: `npx
   --yes marked@12.0.2` (Node — the mermaid check already found it), else the Python `markdown`
   package if importable; neither, the script stops and names both — offer the Node install the
   way Ops § Tooling Checks does, with approval, never silently.
3. **Read the build's `review [...]` and `UNBALANCED HTML [...]` lines and act on every one.** The
   site is for the extension's users; the Markdown was written for the project. A line names a
   repository path (`docs/4-prove/Deployment.md`), an internal code (`OQ-12`, `GA-3`, `CR-2.1-4`,
   `FR-7`), a design-document reference (`TDD §14`), or a build-status remark (*not yet tested*):
   - **Fix the Markdown source when the sentence is wrong for any reader** — a path to a document
     that is now a tab becomes a plain reference to *the Deployment tab* in the page and reads
     fine in the repository too; a review code adds nothing for a user and is dropped.
   - **Add a `substitutions` pair in `site.json`** (`[regex, replacement]`, applied before
     conversion) only when the Markdown must keep the text for the repository's readers and the
     page must not show it. `dropSections` removes whole `##` sections by heading regex (a
     *Not verified* section, an internal *Status* section).
   - An **UNBALANCED HTML** line names a panel whose `<td>` or `<em>` never closes — a stray
     `<placeholder>` or a literal tag in the Markdown; fix the source. A panel left unbalanced
     bleeds into every panel after it, which is how a blank FAQ tab happened on the reference build.
   - A **missing image** line names a screenshot a document references that isn't in
     `docs/screenshots/`; fix the reference or ask for the file.
   Rebuild until the only lines left are ones the human has seen and accepted.
4. **Look at every tab before the human does.** Open `docs/index.html` with the OS opener (`open` /
   `start` / `xdg-open`). Where a browser can run headless (the `app-icon` skill's ladder — Chrome
   or Edge on every OS), screenshot the page per tab — `--screenshot=<file> --window-size=1280,2000
   "file://<abs>/docs/index.html#<tab>"` — and read the images: the hero complete, every tab
   present, no `{{PLACEHOLDER}}` left, tables inside their frames, the diagram drawn (use
   `--virtual-time-budget=10000` so mermaid finishes), screenshots shown. A tab that renders blank
   or in italics is an unbalanced panel (point 3).

## Step 6: Accept, or change

One box: **Looks good — give me the publishing steps** / *Change something* (typed: a tab's
order, the tagline, a color, a screenshot's place, a sentence on the page) / *Restyle it* (typed:
the agent edits `docs/template.html`'s CSS tokens only — `--accent` and friends, fonts — never
`build.py`). Every change is a rebuild and another look.

## Step 7: Publish — GitHub Pages, the Help link, the record

`references/github-pages.md` has the steps and the plan caveats. In the closing message, as a
numbered list with the real owner, repository, and URL filled in: push; *Settings → Pages* →
*Deploy from a branch* → the default branch, folder **`/docs`** → Save; wait a minute or two; the
site is at `https://<owner>.github.io/<repo>/`; open it and click every tab. Say plainly that a
private repository needs GitHub Pro, Team, or Enterprise Cloud for Pages, and that the site is
public either way unless the organisation has access-controlled Pages. Then:

- Write the URL into `docs/site.json` → `helpUrl` and rebuild once more (the page's canonical link).
- **Offer the Help link:** **Set `app.json` → `help` to the site's URL now (recommended)** / *Not
  now*. Business Central shows it as the extension's **Help** in Extension Management; AppSource
  requires it. It is a change to the package (ALL ALONG → Packaging & Versioning): the next build
  increments the Revision and its ChangeLog entry names the help link; a package already uploaded
  is never rebuilt at the same version. `"url"` is set to the repository when blank. Nothing else
  in `app.json` is touched.
- Put a link under the README's title — *Full documentation: setup, configuration and use* — when
  the project has a README.
- **ChangeLog entry** (`docs/0-project/ChangeLog.md`; `docs/ChangeLog.md` on a feature project):
  the site built, its tabs, the FAQ written, the screenshots renamed (old → new), the
  `.nojekyll`, the Pages setting the human must make and the URL, the `help` decision.
- Stage everything with `git add` — never commit, never push, never change a repository setting.
- **From now on the site is rebuilt whenever a source document changes** — a Step 12 / Step 7
  fix that touches the User Guide, a new FAQ question, a new screenshot: `python3 docs/build.py`,
  then stage. The step files say so; `status` lists a `docs/index.html` older than its sources.

## What this skill never does

Never installs anything (the converter ladder stops and asks); never changes GitHub settings,
pushes, or publishes; never puts the site anywhere but `docs/`; never writes the site by hand or
edits `docs/index.html` (the build owns it); never edits `docs/build.py` per project; never invents
an FAQ answer or a screenshot; never fetches a logo, banner, or color from the web; never sets
`app.json` → `help` before the human said yes; never offers itself on Build-a-Feature; never asks
in prose.
