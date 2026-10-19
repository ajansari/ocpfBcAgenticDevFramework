# Publishing the help site on GitHub Pages

The help site is static: `docs/index.html` plus `docs/assets/` and `docs/screenshots/`. GitHub
Pages serves a branch's `/docs` folder as a website, which is why the site is built **in `docs/`
and nowhere else** — "Deploy from a branch" can publish only `/ (root)` or `/docs` (the reference
project's ChangeLog records the lesson: the site started in `docs/help/`, moved to a root `help/`,
which made the whole repository root the site, and settled on `docs/`). The agent gives the human these steps in the closing message; the agent never changes
repository settings itself.

## What the human does, once

1. Push the repository to GitHub with `docs/index.html`, `docs/assets/`, `docs/screenshots/`, and
   `docs/.nojekyll` on the default branch (the build writes `.nojekyll`; it tells Pages to serve the
   files as they are instead of running them through Jekyll, which would otherwise try to turn every
   Markdown file under `docs/` into a page of its own).
2. On github.com open the repository → **Settings** → **Pages** (left column, *Code and automation*).
3. Under **Build and deployment** set **Source** to *Deploy from a branch*, **Branch** to the default
   branch (usually `main`) and the folder to **`/docs`**, then **Save**.
4. Wait a minute or two (GitHub's own figure is "up to 10 minutes" for the first publish). The page shows *Your site is live at* `https://<owner>.github.io/<repo>/`.
   Every later push to that branch republishes it within a minute or two; nothing is rebuilt on
   GitHub, so `docs/index.html` must be rebuilt locally (`python3 docs/build.py`) and pushed
   whenever a source document changes.
5. Open the URL and click every tab once.

**Private repositories:** GitHub Pages on a private repository needs GitHub Pro, Team, or
Enterprise Cloud, and the site is still public unless the organization uses access-controlled
Pages (Enterprise Cloud). On a Free plan the repository must be public for Pages to publish. Say
this plainly when the project's remote is private.

**Custom domain** (optional): *Settings → Pages → Custom domain*, a `CNAME` DNS record pointing at
`<owner>.github.io`, then *Enforce HTTPS* once the certificate is issued. The build's `helpUrl` in
`docs/site.json` becomes that domain.

## What the agent does

- Writes `docs/site.json` → `"helpUrl"` with the URL the steps above produce (the canonical link in
  the page's head), and the README's first line under its title as a link to it — *Full
  documentation: setup, configuration and use* — so the repository and the site point at each
  other.
- **Offers to set `app.json` → `"help"`** to the same URL (one box: *Set the Help link in app.json
  now (recommended)* / *Not now*). Business Central's Extension Management page shows it as the
  extension's **Help** link, and AppSource requires one. An `app.json` change is a change to the
  package: the next build increments the Revision as ALL ALONG → Packaging & Versioning says, and
  the ChangeLog entry names the help link as the reason; a package already uploaded is never
  rebuilt at the same version. Only `"help"` (and `"url"` to the repository, if blank) is touched.
- Records in the ChangeLog: the site built, its tabs, the screenshots renamed, the `.nojekyll`,
  the Pages setting the human must make (branch, `/docs`) and the URL, and whether `help` was set.
- Says in the closing message, as a numbered list, exactly the five steps above, with the real
  owner, repository, and URL filled in.
