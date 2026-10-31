#!/usr/bin/env python3
"""OCPF BC Agentic Development Framework — Custom Skills: inspect, unpack, and check (Ops § Custom Skills).

The agent's helper for the skill-load, skill-create, and skill-update commands. It reads and prints; it never writes
the register (ocpfFramework/customSkills.json), the harness folders, or any project file — the agent is the single
writer of every record. Standard library only, nothing to install. The pwsh twin ocpf-skills.ps1 prints the same
JSON (keys sorted, compact) for the same input.

    python3 ocpf-skills.py --inspect <skill folder> [--framework-version <x.y.z.w>] [--edition full|lite|feature]
                           [--extension-points <extensionPoints.json>] [--register <customSkills.json>]
        Read ocpf-skill.json and the folder and print ONE JSON line:
        {"ok": bool, "slug", "displayName", "version", "renamedFrom": [], "contentHash": "sha256:<hex>",
         "files": [relative paths], "manifest": {...}, "errors": [{"rule", "detail"}], "warnings": [{"rule", "detail"}]}
        Rules (every one named in Ops § Custom Skills → Validation): the manifest exists and says ocpfCustomSkill 1
        for this framework; the slug matches ^[a-z][a-z0-9_]{2,39}$ with no "__" and no trailing "_" and no reserved
        prefix (ocpf_, bcskills_, onlycopilotfans_, obcf_); renamedFrom entries are slugs; the version is
        four-part; SKILL.md exists and its frontmatter name is the slug with "_" → "-"; every file is an allowed kind
        (.md .txt .json .png .jpg .jpeg; LICENSE, README, CHANGELOG, .gitignore, .gitattributes bare) — scripts/,
        agents/, hooks, .mcp.json, settings*.json, .ps1, .py, .sh, .svg and anything else are REFUSED, never ignored;
        every extends / overrides key is an active extension point of this framework version (a reserved or unknown
        point is an error); journeys ⊆ {full, lite, feature}; with --framework-version: minVersion ≤ it ≤ maxVersion;
        with --edition: the edition is in journeys; with --register: a slug collision (same slug, different author)
        or a rename match (renamedFrom) is reported as "collision" or "rename".
    python3 ocpf-skills.py --unpack <file.zip> --into <folder>
        Inspect the archive's entries before extracting: refuse an absolute path, "..", a backslash, a symlink entry,
        a nested archive, more than 200 entries, or any entry over 2 MB; then extract into <folder>/<zip stem>/ and
        print {"ok", "folder", "entries", "errors"}. Nothing is extracted when any entry fails inspection; when the
        extraction itself fails part-way, the partial folder is removed so a retry is not blocked by it.
    python3 ocpf-skills.py --check --project <root>
        Read ocpfFramework/customSkills.json, framework.json, and ocpfFramework/extensionPoints.json; re-inspect every
        enabled skill's folder; run the skill ↔ framework and skill ↔ skill checks; print
        {"ok", "frameworkVersion", "edition", "skills": {slug: {"version", "enabled", "status": "compatible|blocked|disabled|missing", "issues": [...]}},
         "issues": [{"slug", "rule", "detail", "recommended"}]}. ok is false when any enabled skill has an issue:
        the agent records the block in the register and the framework refuses to run until it is resolved.
    python3 ocpf-skills.py --hash <folder>
        {"contentHash": "sha256:<hex>", "files": n} — SHA-256 over every file but .git/ and the desktop droppings
        .DS_Store, Thumbs.db, desktop.ini (left out of the walk, the file list, and the hash), sorted by relative path:
        "<path>\\0<size>\\0" then the bytes, per file.

--quiet makes every failure silent with exit 0 and no output; without it an unreadable input is an error on stderr, exit 1.
"""
import argparse, hashlib, json, os, re, shutil, sys, zipfile

SLUG_RE = re.compile(r"^[a-z][a-z0-9_]{2,39}$")
RESERVED = ("ocpf_", "bcskills_", "onlycopilotfans_", "obcf_")
FRAMEWORK_NAME = "OCPF BC Agentic Development Framework"
ALLOWED_EXT = {".md", ".txt", ".json", ".png", ".jpg", ".jpeg"}
ALLOWED_BARE = {"LICENSE", "LICENCE", "README", "CHANGELOG", "NOTICE", ".gitignore", ".gitattributes"}
REFUSED_DIRS = {"scripts", "agents", "hooks", ".claude", ".github", ".vscode", "node_modules"}
REFUSED_NAMES = {"hooks.json", ".mcp.json", "mcp.json"}
JOURNEYS = ("full", "lite", "feature")
HARNESSES = ("claude-code", "copilot")
ZIP_MAX_ENTRIES = 200
ZIP_MAX_ENTRY = 2 * 1024 * 1024
ARCHIVE_EXT = {".zip", ".7z", ".rar", ".tar", ".gz", ".tgz", ".bz2", ".xz", ".jar", ".app"}
DROPPINGS = {".ds_store", "thumbs.db", "desktop.ini"}  # left by Finder and Explorer; never part of a skill, never hashed, never refused
# The points this framework consults when no extensionPoints.json is given (the file wins when present).
DEFAULT_POINTS = {"extends": {"referenceSources": "active", "preReviewChecks": "active", "codeReviewChecks": "active",
                              "documents": "reserved", "steps": "reserved", "intakeQuestions": "reserved", "analyzeOutputs": "reserved"},
                  "overrides": {"documentTemplates": "active", "modelRecommendations": "active", "companionOffers": "active"}}

def out(obj): print(json.dumps(obj, ensure_ascii=False, sort_keys=True, separators=(",", ":")))

def load_json(p, default=None):
    try:
        with open(p, encoding="utf-8-sig") as f: return json.load(f)
    except (OSError, ValueError): return default

def vparts(v):
    """Four-part version → tuple, or None."""
    if not isinstance(v, str) or not re.match(r"^\d+\.\d+\.\d+\.\d+$", v): return None
    return tuple(int(x) for x in v.split("."))

def slug_ok(s):
    return isinstance(s, str) and bool(SLUG_RE.match(s)) and "__" not in s and not s.endswith("_") and not s.startswith(RESERVED)

def slug_problem(s):
    if not isinstance(s, str) or not s: return "missing"
    if not SLUG_RE.match(s): return "must match ^[a-z][a-z0-9_]{2,39}$ (lowercase letters, digits, underscore; starts with a letter; 3–40 characters)"
    if "__" in s: return "must not contain \"__\""
    if s.endswith("_"): return "must not end with \"_\""
    if s.startswith(RESERVED): return "starts with a reserved prefix (" + ", ".join(RESERVED) + ") — first-party names belong to the plugin"
    return ""

def walk_files(folder):
    """Relative paths (forward slashes), sorted ordinally, .git/ and the desktop droppings (.DS_Store, Thumbs.db, desktop.ini) excluded."""
    out_ = []
    for dp, dns, fns in os.walk(folder):
        dns[:] = sorted(d for d in dns if d != ".git")
        for fn in fns:
            if fn.lower() in DROPPINGS: continue
            rel = os.path.relpath(os.path.join(dp, fn), folder).replace(os.sep, "/")
            out_.append(rel)
    return sorted(out_)

def content_hash(folder, files=None):
    h = hashlib.sha256()
    for rel in (files if files is not None else walk_files(folder)):
        p = os.path.join(folder, rel.replace("/", os.sep))
        try:
            with open(p, "rb") as f: data = f.read()
        except OSError: data = b""
        h.update(rel.encode("utf-8") + b"\0" + str(len(data)).encode("ascii") + b"\0"); h.update(data)
    return "sha256:" + h.hexdigest()

def points_from(path):
    pts = load_json(path) if path else None
    if not isinstance(pts, dict) or not isinstance(pts.get("extends"), dict): return DEFAULT_POINTS, False
    def norm(d): return {k: (v.get("status") if isinstance(v, dict) else str(v)) for k, v in d.items()}
    return {"extends": norm(pts.get("extends") or {}), "overrides": norm(pts.get("overrides") or {})}, True

def file_problem(rel):
    parts = rel.split("/")
    for d in parts[:-1]:
        if d in REFUSED_DIRS: return f"folder '{d}/' is not allowed in a skill (no code, no hooks, no servers, no sub-agents)"
    name = parts[-1]; low = name.lower(); ext = os.path.splitext(low)[1]
    if low in REFUSED_NAMES or (low.startswith("settings") and ext == ".json"): return f"'{name}' is not allowed in a skill (no hooks, no MCP servers, no settings)"
    if ext in ALLOWED_EXT: return ""
    if ext == "" and (name in ALLOWED_BARE or name.upper() in ALLOWED_BARE): return ""
    if ext in (".ps1", ".py", ".sh", ".svg", ".cmd", ".bat", ".js", ".ts", ".exe", ".dll"): return f"'{name}' is not allowed in a skill ({ext} is code or a script carrier)"
    return f"'{name}' is not an allowed file kind (.md .txt .json .png .jpg .jpeg, LICENSE, README, CHANGELOG)"

def frontmatter_name(skill_md):
    try:
        with open(skill_md, encoding="utf-8-sig") as f: text = f.read()
    except OSError: return None
    if not text.startswith("---"): return None
    end = text.find("\n---", 3)
    if end < 0: return None
    for line in text[3:end].splitlines():
        m = re.match(r"^\s*name\s*:\s*(.+?)\s*$", line)
        if m: return m.group(1).strip().strip('"').strip("'")
    return None

def inspect(folder, fw_version=None, edition=None, points_path=None, register_path=None):
    res = {"ok": False, "slug": None, "displayName": None, "version": None, "renamedFrom": [], "contentHash": None,
           "files": [], "manifest": None, "errors": [], "warnings": []}
    E = lambda rule, detail: res["errors"].append({"rule": rule, "detail": detail})
    W = lambda rule, detail: res["warnings"].append({"rule": rule, "detail": detail})
    if not os.path.isdir(folder):
        E("folder", f"{folder} is not a folder"); return res
    files = walk_files(folder); res["files"] = files; res["contentHash"] = content_hash(folder, files)
    mp = os.path.join(folder, "ocpf-skill.json")
    if not os.path.isfile(mp):
        E("manifest", "ocpf-skill.json is missing — only skills made for this framework load (skill-create writes one)"); return res
    m = load_json(mp)
    if not isinstance(m, dict):
        E("manifest", "ocpf-skill.json is not a JSON object"); return res
    res["manifest"] = m
    if m.get("ocpfCustomSkill") != 1: E("manifest", "ocpfCustomSkill must be 1")
    fw = m.get("framework") if isinstance(m.get("framework"), dict) else {}
    if fw.get("name") != FRAMEWORK_NAME: E("framework", f"framework.name must be \"{FRAMEWORK_NAME}\"")
    slug = m.get("slug"); res["slug"] = slug if isinstance(slug, str) else None
    sp = slug_problem(slug)
    if sp: E("slug", f"slug {sp}")
    rf = m.get("renamedFrom", [])
    if rf is None: rf = []
    if not isinstance(rf, list) or any(not slug_ok(x) for x in rf): E("renamedFrom", "renamedFrom must be a list of valid slugs")
    else: res["renamedFrom"] = rf
    if slug and isinstance(rf, list) and slug in rf: E("renamedFrom", "renamedFrom must not contain the slug itself")
    res["displayName"] = m.get("displayName") if isinstance(m.get("displayName"), str) else None
    if not res["displayName"]: E("displayName", "displayName is required")
    if not isinstance(m.get("description"), str) or not m.get("description"): E("description", "description is required")
    res["version"] = m.get("version") if isinstance(m.get("version"), str) else None
    if vparts(m.get("version")) is None: E("version", "version must be four-part, e.g. 1.0.0.0")
    au = m.get("author") if isinstance(m.get("author"), dict) else None
    if not au or not isinstance(au.get("name"), str) or not au.get("name"): E("author", "author.name is required (typed by the human, never inferred)")
    for k in ("minVersion",):
        if vparts(fw.get(k)) is None: E("framework", f"framework.{k} must be a four-part version")
    if fw.get("maxVersion") not in (None, "") and vparts(fw.get("maxVersion")) is None: E("framework", "framework.maxVersion must be null or a four-part version")
    js = m.get("journeys")
    if not isinstance(js, list) or not js or any(j not in JOURNEYS for j in js): E("journeys", "journeys must be a non-empty list from full, lite, feature")
    hs = m.get("harnesses", list(HARNESSES))
    if not isinstance(hs, list) or any(h not in HARNESSES for h in hs): E("harnesses", "harnesses must be a list from claude-code, copilot")
    pts, from_file = points_from(points_path)
    ext = m.get("extends") if isinstance(m.get("extends"), dict) else {}
    ovr = m.get("overrides") if isinstance(m.get("overrides"), dict) else {}
    if not isinstance(m.get("extends", {}), dict): E("extends", "extends must be an object")
    if not isinstance(m.get("overrides", {}), dict): E("overrides", "overrides must be an object")
    for k, v in ext.items():
        st = pts["extends"].get(k)
        if not v: continue
        if st is None: E("extensionPoint", f"extends.{k} is not an extension point of this framework version")
        elif st != "active": E("extensionPoint", f"extends.{k} is {st} in this framework version — declared, not yet consulted; a skill that names it would silently not apply, so it is refused")
        elif isinstance(v, list):
            for f_ in v:
                if not isinstance(f_, str) or not os.path.isfile(os.path.join(folder, f_.replace("/", os.sep))): E("extensionPoint", f"extends.{k} names {f_!s}, which is not a file in the skill")
    for k, v in ovr.items():
        st = pts["overrides"].get(k)
        if not v: continue
        if st is None: E("extensionPoint", f"overrides.{k} is not on the override allowlist")
        elif st != "active": E("extensionPoint", f"overrides.{k} is {st} in this framework version")
    for key in ("conflictsWith", "requires"):   # each under its own rule name, so a requires error reads as one
        v = m.get(key)
        if v is None: continue
        if not isinstance(v, list): E(key, f"{key} must be a list of slugs"); continue
        for x in v:
            name = x.get("slug") if isinstance(x, dict) else x
            if not slug_ok(name): E(key, f"{key} entries must name slugs ({name!s})")
    for k, v in ovr.items():   # every override is an object (Ops § Custom Skills → 2); a documentTemplates value is a file in the skill
        if v is None or not pts["overrides"].get(k): continue
        if not isinstance(v, dict): E("extensionPoint", f"overrides.{k} must be an object"); continue
        if k == "documentTemplates":
            for name, f_ in v.items():
                if not isinstance(f_, str) or not os.path.isfile(os.path.join(folder, f_.replace("/", os.sep))): E("extensionPoint", f"overrides.documentTemplates.{name} names {f_!s}, which is not a file in the skill")
    if "SKILL.md" not in files: E("skill", "SKILL.md is missing")
    else:
        fm = frontmatter_name(os.path.join(folder, "SKILL.md"))
        if slug and slug_ok(slug) and fm != slug.replace("_", "-"): E("skill", f"SKILL.md frontmatter name must be \"{slug.replace('_', '-')}\" (the slug with _ → -), found {fm!r}")
    if "README.md" not in files: W("readme", "README.md is missing — how to load the skill goes there")
    for rel in files:
        fp = file_problem(rel)
        if fp: E("files", fp)
    if fw_version:
        fv = vparts(fw_version)
        mn = vparts(fw.get("minVersion")); mx = vparts(fw.get("maxVersion")) if fw.get("maxVersion") else None
        if fv and mn and fv < mn: E("frameworkVersion", f"needs framework ≥ {fw.get('minVersion')}; this project is on {fw_version}")
        if fv and mx and fv > mx: E("frameworkVersion", f"framework.maxVersion is {fw.get('maxVersion')}; this project is on {fw_version} — the skill's author must raise or remove maxVersion")
    if edition and isinstance(js, list) and edition not in js: E("journey", f"made for {', '.join(js)}; this project's journey is {edition}")
    if register_path and slug:
        reg = load_json(register_path) or {}
        skills = reg.get("skills") if isinstance(reg.get("skills"), dict) else {}
        cur = skills.get(slug)
        if isinstance(cur, dict):
            ca = (cur.get("author") or {}).get("name") if isinstance(cur.get("author"), dict) else None
            if cur.get("contentHash") == res["contentHash"]: W("dedupe", f"already loaded as {cur.get('displayName')} {cur.get('version')} (same content)")
            elif ca and au and ca == au.get("name"):
                nv = vparts(res["version"] or "") or (); cv = vparts(cur.get("version") or "") or ()
                if nv > cv: W("dedupe", f"same slug and author as the loaded {cur.get('version')}: a higher version — offer the upgrade (Ops § Custom Skills → 4)")
                elif nv < cv: W("dedupe", f"same slug and author as the loaded {cur.get('version')}: a lower version — keep the loaded one, append the source (Ops § Custom Skills → 4)")
                else: E("dedupe", f"same slug, author, and version as the loaded {cur.get('version')} but different content — a modified copy of a released version; bump it with skill-update or remove the loaded one first (Ops § Custom Skills → 4)")
            else: E("collision", f"slug collision: {slug} is already loaded from another author ({ca or 'unknown'}, {((cur.get('sources') or [{}])[0] or {}).get('ref', '')}); remove one")
        for old in res["renamedFrom"]:
            if isinstance(skills.get(old), dict): W("rename", f"{old} is loaded and this skill names it in renamedFrom — an upgrade offer to {slug}, not a collision")
    if not from_file and points_path: W("extensionPoints", f"{points_path} not readable — the built-in list for this release was used")
    res["ok"] = not res["errors"]
    return res

def unpack(zip_path, into):
    res = {"ok": False, "folder": None, "entries": 0, "errors": []}
    E = lambda rule, detail: res["errors"].append({"rule": rule, "detail": detail})
    if not os.path.isfile(zip_path) or not zipfile.is_zipfile(zip_path): E("zip", f"{zip_path} is not a zip archive"); return res
    stem = re.sub(r"[^A-Za-z0-9._-]", "-", os.path.splitext(os.path.basename(zip_path))[0]) or "skill"
    dest = os.path.join(into, stem); made = False
    try:
        with zipfile.ZipFile(zip_path) as z:
            infos = z.infolist(); res["entries"] = len(infos)
            if len(infos) > ZIP_MAX_ENTRIES: E("zip", f"{len(infos)} entries — more than {ZIP_MAX_ENTRIES}")
            for i in infos:
                n = i.filename
                if n.startswith("/") or n.startswith("\\") or re.match(r"^[A-Za-z]:", n): E("zip", f"absolute path in the archive: {n}")
                if "\\" in n: E("zip", f"backslash in an entry name: {n}")
                if ".." in n.split("/"): E("zip", f"'..' in an entry name: {n}")
                if (i.external_attr >> 16) & 0o170000 == 0o120000: E("zip", f"symlink entry: {n}")
                if i.file_size > ZIP_MAX_ENTRY: E("zip", f"{n} is {i.file_size} bytes — over {ZIP_MAX_ENTRY}")
                if not n.endswith("/") and os.path.splitext(n.lower())[1] in ARCHIVE_EXT: E("zip", f"nested archive: {n}")
            if res["errors"]: return res
            if os.path.exists(dest): E("zip", f"{dest} already exists — remove it or choose another --into"); return res
            os.makedirs(dest); made = True
            for i in infos:
                if i.filename.endswith("/"): os.makedirs(os.path.join(dest, *i.filename.strip("/").split("/")), exist_ok=True); continue
                target = os.path.join(dest, *i.filename.split("/"))
                os.makedirs(os.path.dirname(target), exist_ok=True)
                with z.open(i) as src, open(target, "wb") as dst: dst.write(src.read())
    except (OSError, zipfile.BadZipFile, RuntimeError) as e:
        if made: shutil.rmtree(dest, ignore_errors=True)  # a partial folder would block the retry (and could pass a later inspection)
        E("zip", f"could not extract the archive: {e}" if made else f"could not read the archive: {e}"); return res
    # a zip of one top-level folder unpacks to dest/<that folder>/ — point at the folder that holds the manifest
    inner = [d for d in os.listdir(dest) if os.path.isdir(os.path.join(dest, d))]
    if not os.path.isfile(os.path.join(dest, "ocpf-skill.json")) and len(inner) == 1 and os.path.isfile(os.path.join(dest, inner[0], "ocpf-skill.json")): dest = os.path.join(dest, inner[0])
    res["folder"] = dest; res["ok"] = True
    return res

def check(root):
    res = {"ok": False, "frameworkVersion": None, "edition": None, "skills": {}, "issues": []}
    marker = load_json(os.path.join(root, "ocpfFramework", "framework.json")) or {}
    res["frameworkVersion"] = marker.get("runbookVersion"); res["edition"] = marker.get("edition")
    reg_path = os.path.join(root, "ocpfFramework", "customSkills.json")
    if not os.path.isfile(reg_path): res["ok"] = True; return res  # no register, no skills, nothing to check
    reg = load_json(reg_path)
    if not isinstance(reg, dict):   # a register that exists but does not parse must not open the gate
        res["issues"].append({"slug": None, "rule": "register", "detail": "ocpfFramework/customSkills.json exists but is not valid JSON", "recommended": "fix or restore the register (git shows its last good version); the framework does not run until it reads"})
        return res
    skills = reg.get("skills") if isinstance(reg.get("skills"), dict) else {}
    pts_path = os.path.join(root, "ocpfFramework", "extensionPoints.json")
    inspected = {}
    def issue(slug, rule, detail, recommended):
        res["issues"].append({"slug": slug, "rule": rule, "detail": detail, "recommended": recommended})
        res["skills"][slug]["issues"].append({"rule": rule, "detail": detail})
    for slug, s in sorted(skills.items()):
        s = s if isinstance(s, dict) else {}
        entry = {"version": s.get("version"), "enabled": bool(s.get("enabled", True)), "status": "disabled", "issues": []}
        res["skills"][slug] = entry
        if not entry["enabled"]: continue
        folder = os.path.expanduser(str(s.get("folder") or ""))
        if not folder or not os.path.isdir(folder):
            entry["status"] = "missing"; issue(slug, "folder", f"the skill folder {folder or '(none)'} is not on this machine", f"run skill-load on {slug}'s source again, or disable it"); continue
        r = inspect(folder, res["frameworkVersion"], res["edition"], pts_path if os.path.isfile(pts_path) else None, None)
        inspected[slug] = r
        for e in r["errors"]: issue(slug, e["rule"], e["detail"], f"disable or remove {slug}, or load a version that passes")
        if r["slug"] and r["slug"] != slug: issue(slug, "slug", f"the folder's manifest says slug {r['slug']}, the register says {slug}", f"reload {slug} from its source")
        if r["contentHash"] and s.get("contentHash") and r["contentHash"] != s.get("contentHash"): issue(slug, "content", "the folder's content differs from what was loaded (the register's contentHash)", f"run skill-update on {slug}, or reload it, so the record matches the files")
        entry["status"] = "compatible" if not entry["issues"] else "blocked"
    # skill ↔ skill
    enabled = [s for s in sorted(skills) if res["skills"][s]["enabled"] and s in inspected]
    def man(s): return inspected[s]["manifest"] or {}
    owners = {}
    for s in enabled:
        for item, v in (man(s).get("overrides") or {}).items():
            if not isinstance(v, dict): continue
            for name in v: owners.setdefault((item, name), []).append(s)
    for (item, name), ss in sorted(owners.items()):
        if len(ss) > 1:
            for s in ss: issue(s, "override", f"{', '.join(ss)} all override {item}.{name}", f"keep one of them, or create one skill that merges them (skill-create)"); res["skills"][s]["status"] = "blocked"
    for s in enabled:
        cl = man(s).get("conflictsWith"); cl = cl if isinstance(cl, list) else []
        rl = man(s).get("requires"); rl = rl if isinstance(rl, list) else []
        for c in cl:
            name = c.get("slug") if isinstance(c, dict) else c
            if name in enabled: issue(s, "conflictsWith", f"{s} declares a conflict with {name}, which is loaded", f"remove or disable one of them"); res["skills"][s]["status"] = "blocked"
        for rq in rl:
            name = rq.get("slug") if isinstance(rq, dict) else rq
            if name not in enabled: issue(s, "requires", f"{s} requires {name}, which is not loaded (or not enabled)", f"load {name} first, or disable {s}"); res["skills"][s]["status"] = "blocked"
        for old in inspected[s].get("renamedFrom") or []:
            if old in enabled: issue(s, "rename", f"{s} is the renamed {old}, and both are loaded", f"remove {old}; {s} replaces it"); res["skills"][s]["status"] = "blocked"
    res["ok"] = not res["issues"]
    return res

def main():
    ap = argparse.ArgumentParser(description="OCPF Custom Skills: inspect a skill folder, unpack a skill zip safely, or check a project's loaded set.")
    ap.add_argument("--inspect", metavar="FOLDER"); ap.add_argument("--unpack", metavar="ZIP"); ap.add_argument("--into", metavar="FOLDER")
    ap.add_argument("--check", action="store_true"); ap.add_argument("--project", default="."); ap.add_argument("--hash", metavar="FOLDER")
    ap.add_argument("--framework-version"); ap.add_argument("--edition"); ap.add_argument("--extension-points"); ap.add_argument("--register")
    ap.add_argument("--quiet", action="store_true")
    a = ap.parse_args()
    if a.inspect: out(inspect(os.path.abspath(os.path.expanduser(a.inspect)), a.framework_version, a.edition, a.extension_points, a.register)); return
    if a.unpack:
        if not a.into:
            if a.quiet: return
            sys.exit("error: --unpack needs --into <folder>")
        out(unpack(os.path.abspath(os.path.expanduser(a.unpack)), os.path.abspath(os.path.expanduser(a.into)))); return
    if a.check: out(check(os.path.abspath(os.path.expanduser(a.project)))); return
    if a.hash:
        f = os.path.abspath(os.path.expanduser(a.hash)); files = walk_files(f); out({"contentHash": content_hash(f, files), "files": len(files)}); return
    ap.print_help()

if __name__ == "__main__":
    try: main()
    except SystemExit: raise
    except Exception as e:
        if "--quiet" in sys.argv: sys.exit(0)
        print(f"error: {e}", file=sys.stderr); sys.exit(1)
