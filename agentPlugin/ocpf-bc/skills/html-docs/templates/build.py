#!/usr/bin/env python3
"""Builds the project's help site, docs/index.html, from the Markdown documents docs/site.json names.

OCPF BC Agentic Development Framework - html-docs skill. Copied into the project as docs/build.py;
docs/site.json is the project's configuration and docs/template.html the page shell. Run from
anywhere: python3 docs/build.py  (it resolves the repository root as the parent of its own folder).

Markdown is converted by the first of these that works - nothing is installed:
  1. npx --yes marked@12.0.2 --gfm   (Node.js; the mermaid check at the documentation step found it)
  2. the Python 'markdown' package, if it happens to be importable
Neither present: the script stops and says which to get (Ops § Tooling Checks).
"""
import html
import json
import pathlib
import re
import subprocess
import sys
import tempfile

HERE = pathlib.Path(__file__).resolve().parent          # docs/
ROOT = HERE.parent                                      # the repository root
CONFIG = HERE / "site.json"
TEMPLATE = HERE / "template.html"
OUT = HERE / "index.html"

# --------------------------------------------------------------------------- Markdown conversion

def _md_marked(text):
    # Through files, never stdin/stdout: marked's piped stdout is cut at 64 KB on macOS and Linux (Node exits
    # before the pipe drains), which silently truncated a 91 KB document mid-table on the reference build.
    with tempfile.TemporaryDirectory() as d:
        src, dst = pathlib.Path(d, "in.md"), pathlib.Path(d, "out.html")
        src.write_text(text, encoding="utf-8")
        r = subprocess.run(["npx", "--yes", "marked@12.0.2", "--gfm", "-i", str(src), "-o", str(dst)],
                           capture_output=True, text=True)
        if r.returncode != 0 or not dst.exists():
            raise RuntimeError(r.stderr.strip() or "marked failed")
        return dst.read_text(encoding="utf-8")

def _md_python(text):
    import markdown  # noqa: F401  (only when installed; never installed by this script)
    return markdown.markdown(text, extensions=["tables", "fenced_code", "sane_lists"])

def pick_converter():
    for name, fn in (("marked (npx)", _md_marked), ("python-markdown", _md_python)):
        try:
            fn("# probe\n\n| a | b |\n|---|---|\n| 1 | 2 |\n")
            return name, fn
        except Exception:  # noqa: BLE001
            continue
    sys.exit("No Markdown converter found. Node.js lets npx run marked with nothing installed "
             "(Ops § Tooling Checks - the same check as mermaid); or the Python 'markdown' package. "
             "Nothing was written.")

# --------------------------------------------------------------------------- cleaning

def slug(text):
    s = re.sub(r"<[^>]+>", "", text)
    s = html.unescape(s).lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s or "section"

def take_section(text, heading):
    """Keep only the part of a document under the H2 whose text matches `heading` (a regex), up to the next H2."""
    m = re.search(r"^## .*?(?:" + heading + r").*$", text, flags=re.M | re.I)
    if not m:
        sys.exit(f"section heading matching /{heading}/ not found")
    rest = text[m.end():]
    nxt = re.search(r"^## ", rest, flags=re.M)
    body = rest[: nxt.start()] if nxt else rest
    # the section's own H3s become the panel's H2s so the page reads at one level
    body = re.sub(r"^### ", "## ", body, flags=re.M)
    body = re.sub(r"^#### ", "### ", body, flags=re.M)
    return body

REAL_TAG = re.compile(r"^/?(?:br|hr|details|summary|sub|sup|kbd|img|a|span|div|p|b|i|u|strong|em|small|mark)(?:\s+[a-z-]+=\"[^\"]*\")*\s*/?$")

def _escape_angle(m):
    inner = m.group(1)
    if inner.startswith("!--") or re.match(r"^(?:https?://|mailto:|[^\s@]+@[^\s@]+\.[a-z]+$)", inner) or REAL_TAG.match(inner):
        return m.group(0)
    return "&lt;" + inner + "&gt;"

def clean(text, cfg):
    """Strip what belongs to the repository, not the page: the document's own title and meta lines,
    the template's closing checklist, build-status notes, and anything site.json says to drop."""
    text = re.sub(r"\A\s*(?:>.*\n)+", "", text)                                          # a template note left at the top
    text = re.sub(r"\A\s*# .*\n", "", text)                                            # title: the panel has its own
    text = re.sub(r"\A(\s*\*\*(Version|Written for|Date|Language|For|Status)[^\n]*\n)+", "", text)
    text = re.sub(r"^\*\*Version:\*\*[^\n]*\n", "", text, count=1, flags=re.M)         # the meta line, wherever it sits
    text = re.sub(r"^> \*\*(Where this build stands|Template|Status of)[^\n]*\n", "", text, flags=re.M)
    text = re.sub(r"^(?:---\s*\n)?## (Before calling (?:this|it) done|Not verified|Self-check)[\s\S]*\Z", "", text, flags=re.M)
    for pat in cfg.get("dropSections", []):                                            # whole H2 sections, by heading regex
        text = re.sub(r"^## (?:\d+(?:\.\d+)*\.?\s+)?(?:" + pat + r")[^\n]*\n[\s\S]*?(?=^## |\Z)", "", text, flags=re.M)
    # <placeholder> text outside code spans must not become an HTML tag: everything in angle brackets is
    # escaped except URLs, e-mail addresses, and the few real tags a Markdown document may carry.
    parts = re.split(r"(```[\s\S]*?```|`[^`\n]*`)", text)
    text = "".join(p if p.startswith("`") else re.sub(r"<([^<>\n]{1,60})>", _escape_angle, p) for p in parts)
    for pat, rep in cfg.get("substitutions", []):
        text = re.sub(pat, rep, text, flags=re.M)
    return text.strip() + "\n"

INTERNAL = [
    (r"docs/[0-9]-[a-z]+/[A-Za-z.]+\.md", "a path into the repository's docs/ folder"),
    (r"\b(OQ|GA|CR|FR|TR|NFR|SC)-\d+", "an internal review or requirement code"),
    (r"\bTDD §|\bFRD §|\bStandards §", "a reference to a design document or the Standards Guide"),
    (r"not (?:been )?(?:run|tested|verified|installed)\b", "a build-status remark"),
]

def warn_unbalanced(key, rendered):
    """An unclosed <td> or <em> in one panel bleeds into every panel after it; say where it starts."""
    from html.parser import HTMLParser
    stack, problems = [], []
    class P(HTMLParser):
        def handle_starttag(self, t, a):
            if t not in ("img", "br", "hr", "input", "meta", "link", "source", "wbr"):
                stack.append((t, self.getpos()[0]))
        def handle_endtag(self, t):
            if stack and stack[-1][0] == t:
                stack.pop()
            else:
                problems.append(f"</{t}> at line {self.getpos()[0]} closes nothing open")
    P().feed(rendered)
    for t, line in stack[:3]:
        problems.append(f"<{t}> opened at line {line} is never closed")
    for pr in problems[:4]:
        print(f"  UNBALANCED HTML [{key}]: {pr} - fix the source Markdown (a stray <...> placeholder or an HTML tag)")

def warn_internal(key, rendered):
    plain = re.sub(r"<[^>]+>", "", rendered)
    for pat, what in INTERNAL:
        hits = sorted(set(m.group(0) for m in re.finditer(pat, plain)))
        if hits:
            print(f"  review [{key}]: {what}: {', '.join(hits[:6])}{' ...' if len(hits) > 6 else ''}")

# --------------------------------------------------------------------------- HTML shaping

def add_heading_ids(body, key):
    def rep(m):
        level, attrs, inner = m.group(1), m.group(2), m.group(3)
        attrs = re.sub(r'\s+id="[^"]*"', "", attrs)
        return f'<h{level}{attrs} id="{key}-{slug(inner)}">{inner}</h{level}>'
    return re.sub(r"<h([23])([^>]*)>(.*?)</h\1>", rep, body, flags=re.S)

def faq_details(body):
    """Each H3 (one question) and what follows it, up to the next H2/H3, becomes <details><summary>."""
    out, pos = [], 0
    for m in re.finditer(r"<h3([^>]*)>(.*?)</h3>", body, flags=re.S):
        out.append(body[pos:m.start()])
        nxt = re.search(r"<h[23][ >]", body[m.end():])
        end = m.end() + nxt.start() if nxt else len(body)
        out.append(f'<details class="faq"{m.group(1)}><summary>{m.group(2)}</summary><div class="answer">{body[m.end():end]}</div></details>')
        pos = end
    out.append(body[pos:])
    return "".join(out)

def shape(body, key, kind):
    body = body.replace("../screenshots/", "screenshots/").replace("../assets/", "assets/")
    body = re.sub(r'<pre><code class="language-mermaid">(.*?)</code></pre>',
                  lambda m: '<pre class="mermaid">' + m.group(1) + "</pre>", body, flags=re.S)
    body = re.sub(r"<table>", '<div class="table-wrap"><table>', body).replace("</table>", "</table></div>")
    body = add_heading_ids(body, key)
    if kind == "faq":
        body = faq_details(body)
    return body

# --------------------------------------------------------------------------- template

DEFAULT_COLORS = {"accent": "#0f7f80", "accent_bg": "#d6efee", "accent_2": "#1a5fd0", "accent_3": "#7a4fc0", "accent_4": "#c2187a"}

def fill(page, cfg, tabs_html, panels_html, keys):
    app = json.loads((ROOT / "app.json").read_text(encoding="utf-8")) if (ROOT / "app.json").exists() else {}
    version = cfg.get("version") or app.get("version", "")
    name = cfg.get("appName") or app.get("name", "")
    publisher = cfg.get("publisher") or app.get("publisher", "")
    repo = cfg.get("repoUrl", "")
    download = cfg.get("downloadUrl", "")
    branch = cfg.get("branch") or "main"
    if download == "auto" and repo and name and version:
        download = f"{repo.rstrip('/')}/raw/{branch}/outputAppPackage/{name.replace(' ', '_')}_{version}.app"
    values = {
        "APP_NAME": name, "VERSION": version, "PUBLISHER": publisher,
        "PUBLISHER_URL": cfg.get("publisherUrl", ""), "PUBLISHER_LOGO": cfg.get("publisherLogo", ""),
        "TAGLINE": cfg.get("tagline", ""), "DESCRIPTION": cfg.get("description", ""),
        "ICON": cfg.get("icon", "assets/app-icon.png"), "BANNER": cfg.get("banner", ""),
        "BANNER_ALT": cfg.get("bannerAlt", name), "REPO_URL": repo, "DOWNLOAD_URL": download,
        "SUPPORT_URL": cfg.get("supportUrl", ""), "SUPPORT_LABEL": cfg.get("supportLabel", "Get support"),
        "HELP_URL": cfg.get("helpUrl", ""), "FOOTER_CREDIT": cfg.get("footerCredit", ""),
        "DEFAULT_TAB": cfg.get("defaultTab") or keys[0], "TAB_KEYS": json.dumps(keys),
        "DEFAULT_TAB_JS": json.dumps(cfg.get("defaultTab") or keys[0]),
        "INSTALL_NOTE": cfg.get("installNote", ""),
        "TABS": tabs_html, "PANELS": panels_html,
    }
    colors = dict(DEFAULT_COLORS); colors.update(cfg.get("colors") or {})
    for k, v in colors.items():
        values["COLOR_" + k.upper()] = v
    # {{#KEY}} ... {{/KEY}} blocks stay only when KEY has a value; {{^KEY}} ... {{/KEY}} only when it has none.
    # Innermost blocks are resolved first, so a block may sit inside another.
    pat = re.compile(r"\{\{([#^])([A-Z0-9_]+)\}\}((?:(?!\{\{[#^][A-Z0-9_]+\}\}).)*?)\{\{/\2\}\}", re.S)
    def block(m):
        has = bool(values.get(m.group(2)))
        return m.group(3) if has == (m.group(1) == "#") else ""
    while pat.search(page):
        page = pat.sub(block, page)
    raw = {"TABS", "PANELS", "TAB_KEYS", "DEFAULT_TAB_JS"}
    def var(m):
        k = m.group(1)
        v = values.get(k)
        if v is None:
            return m.group(0)
        return v if k in raw else html.escape(str(v), quote=True)
    return re.sub(r"\{\{([A-Z0-9_]+)\}\}", var, page)

# --------------------------------------------------------------------------- main

def main():
    cfg = json.loads(CONFIG.read_text(encoding="utf-8"))
    conv_name, md = pick_converter()
    print(f"markdown converter: {conv_name}")
    sections, tabs, keys = [], [], []
    for tab in cfg["tabs"]:
        key, title, src = tab["key"], tab["title"], ROOT / tab["source"]
        if not src.exists():
            sys.exit(f"tab '{key}': source not found: {tab['source']}")
        text = src.read_text(encoding="utf-8")
        if tab.get("section"):
            text = take_section(text, tab["section"])
        body = shape(md(clean(text, cfg)), key, tab.get("kind", ""))
        warn_internal(key, body)
        warn_unbalanced(key, body)
        if any(k == key or key.startswith(k + "-") or k.startswith(key + "-") for k in keys):
            sys.exit(f"tab key '{key}' collides with another key: no key may be another key plus '-...' (deep links split on it)")
        keys.append(key)
        tabs.append(f'<button class="tab" role="tab" data-tab="{key}" aria-selected="false">{html.escape(title)}</button>')
        sections.append(f'<section class="panel" id="panel-{key}" role="tabpanel" hidden><h1>{html.escape(title)}</h1>{body}</section>')
    page = fill(TEMPLATE.read_text(encoding="utf-8"), cfg, "".join(tabs), "".join(sections), keys)
    OUT.write_text(page, encoding="utf-8")
    (HERE / ".nojekyll").touch()
    missing = sorted(set(re.findall(r'src="((?:screenshots|assets)/[^"]+)"', page)) - {str(p.relative_to(HERE)) for p in HERE.rglob("*") if p.is_file()})
    for m in missing:
        print(f"  missing image: docs/{m}")
    print(f"wrote {OUT.relative_to(ROOT)} ({len(page):,} bytes, {len(keys)} tabs: {', '.join(keys)})")

if __name__ == "__main__":
    main()
