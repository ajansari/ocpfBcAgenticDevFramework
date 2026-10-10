#!/usr/bin/env python3
"""OCPF BC Agentic Development Framework — the live dashboard renderer.

Renders ocpfFramework/state/dashboard.html for one project from state the framework already keeps:

  app.json                               name, publisher, version, BC version, logo (embedded as a data URI)
  ocpfFramework/framework.json           edition, runbook version, AL MCP state
  ocpfFramework/state/usage.json         aiTool, step windows (startedAt / completedAt)
  ProjectProgress.md                     the step table (status per step)
  ocpfFramework/runbookSteps/<step>.md   the current step's Exit gate text, each step's phase and title
  ocpfFramework/state/pricing.json       price source and date, credit price
  ocpfFramework/state/waiting.json       the open question, written by the hooks (see the dashboard skill)
  ocpfFramework/state/dashboard-events.jsonl   recent events, appended by this script and the hooks
  docs/2-design/AiEffortEstimate.md      the current step's estimate (tokens or credits)
  .claude/agents/ocpf-*.md or .github/agents/ocpf-*.agent.md   each role's model and effort
  the usage script (ocpf-usage.py, same folder) with --json   tokens / credits / cost per step and model
  Claude Code transcripts (~/.claude/projects/<key>/*.jsonl)   the agent / you / waiting time split and who is working now

Nothing here is estimated by the model: the page shows what is on disk and says what it cannot know.

    python3 ocpf-dashboard.py --project <root> [--open] [--quiet] [--refresh 30] [--toast "text"]
    python3 ocpf-dashboard.py --project <root> --waiting-json '<AskUserQuestion tool input>'   # hook: a question opened
    python3 ocpf-dashboard.py --project <root> --clear-waiting                                  # hook: it was answered
    python3 ocpf-dashboard.py --project <root> --event "who" "text"                             # append a feed event
"""
import argparse, base64, glob, json, os, re, subprocess, sys
from datetime import datetime, timezone, timedelta

STATE = os.path.join("ocpfFramework", "state")
HERE = os.path.dirname(os.path.abspath(__file__))
FULL = [("PRE-01", "DEFINE"), ("PRE-02", "DEFINE"), ("01", "DEFINE"), ("02", "DESIGN"), ("03", "DESIGN"), ("04", "DESIGN"),
        ("05", "BUILD"), ("06", "BUILD"), ("07", "BUILD"), ("08", "PROVE"), ("09", "PROVE"), ("10", "PROVE"), ("11", "PROVE"), ("12", "PROVE")]
LITE = [("STEP-1", "DEFINE"), ("STEP-2", "DESIGN"), ("STEP-3", "BUILD"), ("STEP-4", "BUILD"), ("STEP-5", "BUILD"), ("STEP-6", "PROVE"), ("STEP-7", "PROVE")]
SHORT = {"PRE-01": "State the Problem", "PRE-02": "Gap Analysis", "01": "Intake Sheet", "02": "FRD", "03": "TDD", "04": "Sanity Check",
         "05": "Plan the Code", "06": "Code Generation", "07": "Compile & Package", "08": "Gap-Fit Test", "09": "Code Review",
         "10": "Update Design Docs", "11": "Document the Code", "12": "Release for Testing",
         "STEP-1": "Define & Lock", "STEP-2": "Design Doc", "STEP-3": "Plan & Scaffold", "STEP-4": "Generate", "STEP-5": "Compile & Test",
         "STEP-6": "Review & Finalize", "STEP-7": "Release for Testing"}

def load_json(p, default):
    try:
        with open(p, encoding="utf-8") as f: return json.load(f)
    except (OSError, json.JSONDecodeError): return default

def parse_ts(s):
    if not s: return None
    try: return datetime.fromisoformat(str(s).replace("Z", "+00:00")).astimezone(timezone.utc)
    except ValueError: return None

def now_utc(): return datetime.now(timezone.utc)

def read(p):
    try:
        with open(p, encoding="utf-8", errors="replace") as f: return f.read()
    except OSError: return ""

# ---------------------------------------------------------------- project facts
def app_facts(root):
    a = load_json(os.path.join(root, "app.json"), {})
    icon = None
    logo = a.get("logo")
    if logo and os.path.isfile(os.path.join(root, logo)):
        try:
            with open(os.path.join(root, logo), "rb") as f: raw = f.read()
            if len(raw) < 400_000:
                ext = os.path.splitext(logo)[1].lower().lstrip(".") or "png"
                icon = f"data:image/{'jpeg' if ext in ('jpg','jpeg') else ext};base64," + base64.b64encode(raw).decode()
        except OSError: pass
    bc = None
    for k in ("application", "platform"):
        v = a.get(k)
        if isinstance(v, str) and v.split(".")[0].isdigit(): bc = v.split(".")[0]; break
    deps = a.get("dependencies") or []
    return {"name": a.get("name"), "publisher": a.get("publisher"), "version": a.get("version"), "bc": bc, "iconDataUri": icon,
            "target": a.get("target")}

def step_catalog(root, edition):
    base = LITE if edition == "lite" else FULL
    out = []
    for sid, ph in base:
        p = os.path.join(root, "ocpfFramework", "runbookSteps", f"{sid}.md")
        txt = read(p)
        title = None; phase = ph; gate = []
        if txt:
            m = re.search(r"^# .*? — (?:PRE-0[12]|[0-9]{2}|STEP [0-9]) — (.+)$", txt, re.M)
            if m: title = m.group(1).strip()
            m = re.search(r"Phase:\s*([A-Z]+)", txt)
            if m: phase = m.group(1)
            m = re.search(r"\*\*Exit gate:\*\*\s*(.+?)(?:\n\n|\n\*\*|$)", txt, re.S)
            if m:
                g = re.sub(r"\s+", " ", m.group(1)).strip()
                g = re.sub(r"`([^`]*)`", r"\1", g); g = re.sub(r"\*\*([^*]*)\*\*", r"\1", g)
                gate = [(s.strip()[:220] + ('…' if len(s.strip()) > 220 else '')) for s in re.split(r"(?<=[.;])\s+(?=[A-Z§`])", g) if len(s.strip()) > 3][:7]
        out.append({"id": sid, "phase": phase, "title": title or SHORT.get(sid, sid), "short": SHORT.get(sid, title or sid), "exitGate": gate})
    return out

def progress_status(root, catalog):
    txt = read(os.path.join(root, "ProjectProgress.md"))
    status = {}
    for line in txt.splitlines():
        m = re.match(r"^\|\s*(DEFINE|DESIGN|BUILD|PROVE)\s*\|\s*([A-Z0-9-]+)\s*[—-]\s*[^|]*\|\s*([^|]*)\|", line)
        if m:
            sid = m.group(2).strip(); st = m.group(3).strip().lower()
            status[sid] = "now" if "in progress" in st else ("done" if st.startswith("complete") or st.startswith("done") else ("todo" if not st or st in ("", "pending", "not started") else "done" if "complet" in st else "todo"))
    return status

def windows(usage):
    wins = []
    for s in usage.get("steps", []):
        a = parse_ts(s.get("startedAt"))
        if a and s.get("step"): wins.append([s["step"], a, parse_ts(s.get("completedAt"))])
    wins.sort(key=lambda w: w[1])
    for i, w in enumerate(wins):
        if w[2] is None and i + 1 < len(wins): w[2] = wins[i + 1][1]
    return wins

def elapsed_by_step(wins):
    out = {}
    for sid, a, b in wins:
        out[sid] = out.get(sid, 0) + max(0, ((b or now_utc()) - a).total_seconds())
    return out

# ---------------------------------------------------------------- usage (tokens / credits)
def usage_rows(root, tool):
    script = os.path.join(HERE, "ocpf-usage.py")
    if not os.path.isfile(script):
        for cand in (os.path.join(root, "ocpfFramework", "scripts", "ocpf-usage.py"), os.path.join(HERE, "..", "..", "usage", "scripts", "ocpf-usage.py")):
            if os.path.isfile(cand): script = cand; break
    if not os.path.isfile(script): return None, "usage script not found beside the dashboard script"
    try:
        r = subprocess.run([sys.executable, script, "--project", root, "--json"], capture_output=True, text=True, timeout=240)
        if r.returncode != 0: return None, (r.stderr or r.stdout).strip().splitlines()[-1] if (r.stderr or r.stdout).strip() else "usage script failed"
        return json.loads(r.stdout), None
    except (OSError, ValueError, subprocess.SubprocessError) as e:
        return None, str(e)

# ---------------------------------------------------------------- Claude Code transcript: time split and who is working
def transcript_dir(root, usage):
    d = usage.get("transcriptDir")
    if d: return os.path.expanduser(d)
    key = os.path.abspath(root).replace("\\", "-").replace("/", "-").replace(":", "-")
    return os.path.expanduser(os.path.join("~", ".claude", "projects", key))

def claude_live(root, usage, wins, steps_idx):
    """Agent / you / waiting seconds per step, and the live state of Main and the sub-agents."""
    tdir = transcript_dir(root, usage)
    files = sorted(glob.glob(os.path.join(tdir, "*.jsonl")), key=os.path.getmtime)
    if not files: return None
    ev = []  # (ts, kind, extra)
    side = {}  # agentId -> {"last": ts, "model":..., "first": ts}
    for f in files:
        try:
            with open(f, encoding="utf-8", errors="replace") as fh:
                for line in fh:
                    try: o = json.loads(line)
                    except json.JSONDecodeError: continue
                    ts = parse_ts(o.get("timestamp")); t = o.get("type")
                    if not ts or t not in ("user", "assistant"): continue
                    m = o.get("message") or {}; c = m.get("content"); blocks = c if isinstance(c, list) else []
                    if o.get("isSidechain"):
                        aid = o.get("agentId") or "sidechain"
                        s = side.setdefault(aid, {"first": ts, "last": ts, "model": None, "done": False})
                        s["last"] = max(s["last"], ts)
                        if t == "assistant" and m.get("model"): s["model"] = m.get("model")
                        continue
                    if t == "user":
                        kind = "result" if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in blocks) else "prompt"
                        ev.append((ts, kind, None))
                    else:
                        ask = any(isinstance(b, dict) and b.get("type") == "tool_use" and b.get("name") == "AskUserQuestion" for b in blocks)
                        agent = any(isinstance(b, dict) and b.get("type") == "tool_use" and b.get("name") in ("Agent", "Task") for b in blocks)
                        txt = " ".join(b.get("text", "") for b in blocks if isinstance(b, dict) and b.get("type") == "text")[:160]
                        ev.append((ts, "ask" if ask else "agent", {"model": m.get("model"), "txt": txt, "delegated": agent}))
        except OSError: continue
    ev.sort(key=lambda e: e[0])
    if not ev: return None
    def step_of(ts):
        hit = None
        for sid, a, b in wins:
            if ts >= a and (b is None or ts <= b): hit = sid
        return hit
    per = {}
    def add(sid, k, v):
        d = per.setdefault(sid, {"agent": 0.0, "human": 0.0, "waiting": 0.0}); d[k] += v
    pending = False; prev = None; GAP = 600
    for ts, k, x in ev:
        if prev:
            gap = (ts - prev[0]).total_seconds(); sid = step_of(prev[0]) or step_of(ts)
            if k == "prompt":
                add(sid, "waiting" if (pending and prev[1] != "prompt") else "human", gap)
            else:
                if prev[1] == "prompt": add(sid, "agent", gap)
                else: add(sid, "agent", min(gap, GAP)); add(sid, "human", max(0, gap - GAP))
        if k == "ask": pending = True
        if k == "prompt": pending = False
        prev = (ts, k)
    last = ev[-1]; age = (now_utc() - last[0]).total_seconds()
    main_state = "working" if (last[1] != "prompt" and age < 180) else ("waiting" if last[1] == "ask" or pending else "idle")
    last_model = next((x["model"] for ts, k, x in reversed(ev) if x and x.get("model")), None)
    last_txt = next((x["txt"] for ts, k, x in reversed(ev) if x and x.get("txt")), "")
    subs = []
    for aid, s in side.items():
        running = (now_utc() - s["last"]).total_seconds() < 120
        subs.append({"agentId": aid, "model": s["model"], "running": running, "seconds": (s["last"] - s["first"]).total_seconds(), "last": s["last"]})
    subs.sort(key=lambda s: s["last"], reverse=True)
    return {"perStep": per, "main": {"state": main_state, "model": last_model, "text": last_txt, "lastAt": last[0].isoformat()}, "subs": subs}

# ---------------------------------------------------------------- roles
def roles(root, tool):
    out = []
    pats = [(".claude/agents", "ocpf-{}.md"), (".github/agents", "ocpf-{}.agent.md")]
    for role, key in (("Main", None), ("Light", "light"), ("Reasoning", "reasoning"), ("Generator", "generator")):
        model = effort = None
        if key:
            for d, pat in pats:
                p = os.path.join(root, d, pat.format(key))
                txt = read(p)
                if txt:
                    m = re.search(r"^model:\s*(.+)$", txt, re.M); model = m.group(1).strip().strip("'\"") if m else model
                    m = re.search(r"^(?:effort|reasoningEffort):\s*(.+)$", txt, re.M); effort = m.group(1).strip().strip("'\"") if m else effort
                    if model: break
        out.append({"role": role, "model": model, "effort": effort, "status": "idle"})
    return out

# ---------------------------------------------------------------- estimate
def estimate_for(root, sid, copilot):
    txt = read(os.path.join(root, "docs", "2-design", "AiEffortEstimate.md"))
    if not txt: return None
    tot_tokens = 0.0; credits = 0.0; hit = False
    for line in txt.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 6 or cells[0].strip("*") != sid: continue
        def num(s):
            s = s.replace(",", "").strip().lower()
            m = re.match(r"^([0-9.]+)\s*([km]?)", s)
            if not m: return 0.0
            v = float(m.group(1)); return v * (1e6 if m.group(2) == "m" else 1e3 if m.group(2) == "k" else 1)
        hit = True
        tot_tokens += sum(num(c) for c in cells[2:6])
        if len(cells) >= 8: credits += num(cells[7])
    if not hit: return {"note": f"No estimate row for step {sid}"}
    return {"estimated": credits if copilot else tot_tokens, "unit": "credits" if copilot else "tokens"}

# ---------------------------------------------------------------- events
def events_path(root): return os.path.join(root, STATE, "dashboard-events.jsonl")
def append_event(root, who, text):
    os.makedirs(os.path.join(root, STATE), exist_ok=True)
    with open(events_path(root), "a", encoding="utf-8") as f:
        f.write(json.dumps({"at": now_utc().strftime("%Y-%m-%dT%H:%M:%SZ"), "who": who, "text": text}, ensure_ascii=False) + "\n")
def recent_events(root, n=12):
    out = []
    for line in read(events_path(root)).splitlines()[-n:]:
        try: o = json.loads(line)
        except json.JSONDecodeError: continue
        ts = parse_ts(o.get("at"))
        out.append({"time": ts.astimezone().strftime("%H:%M") if ts else "", "who": o.get("who", ""), "text": o.get("text", "")})
    return list(reversed(out))

# ---------------------------------------------------------------- main
def build(root, a):
    fw = load_json(os.path.join(root, "ocpfFramework", "framework.json"), {})
    usage = load_json(os.path.join(root, STATE, "usage.json"), {})
    pricing = load_json(os.path.join(root, STATE, "pricing.json"), {})
    tool = usage.get("aiTool") or ("copilot-chat" if ".github/copilot-instructions.md" in str(fw.get("placedAs")) else "claude-code")
    copilot = tool.startswith("copilot")
    edition = (fw.get("edition") or ("lite" if os.path.isfile(os.path.join(root, "ocpfFramework", "runbookSteps", "STEP-1.md")) else "full")).lower()
    catalog = step_catalog(root, edition)
    status = progress_status(root, catalog)
    wins = windows(usage); el = elapsed_by_step(wins)
    notes = []
    uj, err = usage_rows(root, tool) if wins else (None, "no step windows yet")
    if err: notes.append(f"usage: {err}")
    rows = (uj or {}).get("rows", [])
    def rows_for(sid): return [r for r in rows if r.get("step", "").replace(" (open)", "") == sid]
    live = claude_live(root, usage, wins, None) if (not copilot and wins) else None
    steps = []
    for c in catalog:
        sid = c["id"]; rs = rows_for(sid)
        st = status.get(sid) or ("done" if any(w[0] == sid and w[2] for w in wins) and not any(w[0] == sid and w[2] is None for w in wins) else ("now" if any(w[0] == sid for w in wins) else "todo"))
        if sid in el and st == "todo": st = "now" if any(w[0] == sid and w[2] is None for w in wins) else "done"
        steps.append({"id": sid, "title": c["title"], "short": c["short"], "phase": c["phase"], "status": st, "elapsedSeconds": el.get(sid),
                      "costUsd": sum((r.get("costUsd") or 0) for r in rs) if rs else None,
                      "tokens": sum((r.get("input") or 0) + (r.get("output") or 0) + (r.get("cacheWrite") or 0) + (r.get("cacheRead") or 0) for r in rs) if rs and not copilot else None,
                      "credits": sum((r.get("aiCredits") or 0) for r in rs) if rs and copilot else None})
    cur = next((s for s in steps if s["status"] == "now"), None)
    # totals
    tot = {"costUsd": sum((r.get("costUsd") or 0) for r in rows) if rows else None, "elapsedSeconds": sum(el.values()) if el else None,
           "decisions": sum(r.get("decisions") or 0 for r in rows if r.get("role") in (None, "main", "session", "all") or True) if rows else 0,
           "turns": sum(r.get("turns") or 0 for r in rows) if rows else 0}
    # decisions/turns are per step on the first row of each step; avoid double count
    seen = set(); d = t = 0
    for r in rows:
        k = r.get("step")
        if k in seen: continue
        seen.add(k); d += r.get("decisions") or 0; t += r.get("turns") or 0
    tot["decisions"], tot["turns"] = d, t
    if copilot:
        tot["credits"] = round(sum((r.get("aiCredits") or 0) for r in rows), 1) if rows else None
        sess = (uj or {}).get("sessions") or []
        tot["creditsOpen"] = any(not s.get("closed") for s in sess)
    else:
        tk = {k: sum((r.get(k) or 0) for r in rows) for k in ("input", "output", "cacheWrite", "cacheRead")}
        tk["total"] = sum(tk.values()); tot["tokens"] = tk if rows else None
    if live:
        ag = sum(v["agent"] for v in live["perStep"].values()); hu = sum(v["human"] for v in live["perStep"].values()); wa = sum(v["waiting"] for v in live["perStep"].values())
        tot.update({"agentSeconds": ag, "humanSeconds": hu, "waitingSeconds": wa})
    current = {}
    if cur:
        rs = rows_for(cur["id"]); ps = (live or {}).get("perStep", {}).get(cur["id"]) if live else None
        current = {"id": cur["id"], "title": cur["title"], "phase": cur["phase"], "exitGate": next(c["exitGate"] for c in catalog if c["id"] == cur["id"]),
                   "totals": {"costUsd": cur["costUsd"], "elapsedSeconds": cur["elapsedSeconds"], "agentSeconds": ps["agent"] if ps else None,
                              "humanSeconds": ps["human"] if ps else None, "waitingSeconds": ps["waiting"] if ps else None,
                              "tokens": cur["tokens"], "credits": cur["credits"]}}
    # models
    agg = {}
    for r in rows:
        k = (r.get("model") or "unknown", r.get("role") or "")
        g = agg.setdefault(k, {"model": k[0], "role": k[1], "tokens": 0, "credits": 0.0, "costUsd": 0.0})
        g["tokens"] += (r.get("input") or 0) + (r.get("output") or 0) + (r.get("cacheWrite") or 0) + (r.get("cacheRead") or 0)
        g["credits"] += r.get("aiCredits") or 0; g["costUsd"] += r.get("costUsd") or 0
    models = sorted(agg.values(), key=lambda g: -(g["credits"] if copilot else g["tokens"]))[:6]
    # roles + live status
    rl = roles(root, tool)
    main = next(r for r in rl if r["role"] == "Main"); gen = next(r for r in rl if r["role"] == "Generator")
    if not main["model"] and gen["model"]: main["model"], main["effort"] = gen["model"], gen["effort"]
    if not main["model"] and copilot:
        sess = (uj or {}).get("sessions") or []
        ms = [m for x in sess for m in (x.get("models") or [])]
        if ms: main["model"] = ms[-1]
    if not main["model"] and models: main["model"] = models[0]["model"]
    if live:
        main = next(r for r in rl if r["role"] == "Main")
        main["model"] = main["model"] or live["main"]["model"]
        main["status"] = "working" if live["main"]["state"] == "working" else "idle"
        if live["main"]["text"]: main["detail"] = live["main"]["text"][:90]
        for sub in live["subs"][:3]:
            # match a sub-agent to a role by model when the roles name different models, else label it by order
            target = next((r for r in rl if r["role"] in ("Reasoning", "Light", "Generator") and r.get("model") and sub.get("model") and (r["model"] in sub["model"] or sub["model"] in r["model"]) and r.get("status") == "idle"), None)
            if target:
                target["status"] = "running" if sub["running"] else "idle"; target["runningSeconds"] = sub["seconds"] if sub["running"] else None
                target["lastDetail"] = None if sub["running"] else f"returned {sub['last'].astimezone().strftime('%H:%M')}"
    # per-role totals from models (by model name match)
    for r in rl:
        if r.get("model"):
            m = next((g for g in models if g["model"] and (g["model"] in r["model"] or r["model"] in g["model"])), None)
            if m: r["tokens"] = m["tokens"]; r["credits"] = round(m["credits"], 1)
    gen_ = next(r for r in rl if r["role"] == "Generator"); main_ = next(r for r in rl if r["role"] == "Main")
    if gen_.get("model") and main_.get("model") and gen_["model"] == main_["model"]:
        gen_.pop("tokens", None); gen_.pop("credits", None); gen_["detail"] = "same model as Main; its usage is counted in Main's row"
    if cur is None and not wins: rl = [r for r in rl if r["model"]] or rl
    waiting = load_json(os.path.join(root, STATE, "waiting.json"), None)
    if waiting and waiting.get("clearedAt"): waiting = None
    if waiting:
        m_ = next(r for r in rl if r["role"] == "Main"); m_["status"] = "waiting on you"; m_["detail"] = (waiting.get("question") or "")[:90]
    est = estimate_for(root, cur["id"], copilot) if cur else None
    if est and est.get("estimated") is not None and cur:
        est["used"] = (cur["credits"] if copilot else cur["tokens"]) or 0
    data = {"generatedAt": now_utc().isoformat(), "refreshSeconds": a.refresh, "tool": tool, "live": bool(a.live or load_json(os.path.join(root, STATE, "dashboard.json"), {}).get("hooks")),
            "renderer": "ocpf-dashboard.py", "app": app_facts(root),
            "framework": {"edition": edition, "version": fw.get("runbookVersion"), "alMcp": "connected" if fw.get("alMcp") else "unknown"},
            "steps": steps, "current": current, "totals": tot, "estimate": est, "models": models, "roles": rl, "waiting": waiting,
            "events": recent_events(root), "pricing": {"source": (pricing.get("aiCredit") or {}).get("source") if copilot else ", ".join(sorted({v.get("source", "") for v in (pricing.get("perMillionTokens") or {}).values() if v.get("source")})),
                        "fetchedAt": pricing.get("fetchedAt"), "usdPerCredit": (pricing.get("aiCredit") or {}).get("usd")},
            "notes": notes, "toast": a.toast}
    return data

def render(root, data):
    tpl = None
    for cand in (os.path.join(HERE, "..", "templates", "dashboard.html"), os.path.join(root, "ocpfFramework", "scripts", "dashboard.html")):
        if os.path.isfile(cand): tpl = read(cand); break
    if not tpl: sys.exit("error: dashboard.html template not found beside the script (templates/dashboard.html) or in ocpfFramework/scripts/")
    payload = json.dumps(data, ensure_ascii=False, default=str).replace("</", "<\\/")
    html = tpl.replace("/*__OCPF_DATA__*/null", payload, 1)
    out = os.path.join(root, STATE, "dashboard.html")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    tmp = out + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f: f.write(html)
    os.replace(tmp, out)
    return out

def open_in_browser(path):
    try:
        if sys.platform == "darwin": subprocess.Popen(["open", path])
        elif os.name == "nt": os.startfile(path)  # type: ignore[attr-defined]
        else: subprocess.Popen(["xdg-open", path])
        return True
    except OSError: return False

def main():
    ap = argparse.ArgumentParser(description="Render the OCPF project dashboard (ocpfFramework/state/dashboard.html).")
    ap.add_argument("--project", default=".")
    ap.add_argument("--open", action="store_true", help="open the rendered page in the default browser (first creation)")
    ap.add_argument("--quiet", action="store_true")
    ap.add_argument("--refresh", type=int, default=30, help="seconds between the page's own reloads (0 = never)")
    ap.add_argument("--toast", help="a one-line notice to show on this render")
    ap.add_argument("--live", action="store_true", help="mark the page as hook-refreshed (the dashboard skill sets this once hooks are installed)")
    ap.add_argument("--waiting-json", help="hook input of an AskUserQuestion / ask_user call: record the open question and render")
    ap.add_argument("--clear-waiting", action="store_true", help="hook: the question was answered")
    ap.add_argument("--event", nargs=2, metavar=("WHO", "TEXT"), help="append a feed event and render")
    a = ap.parse_args()
    root = os.path.abspath(a.project)
    if not os.path.isdir(os.path.join(root, "ocpfFramework")):
        if a.quiet: return
        sys.exit(f"error: {root} has no ocpfFramework/ folder — not an OCPF project")
    os.makedirs(os.path.join(root, STATE), exist_ok=True)
    if a.waiting_json:
        if a.waiting_json == "-":
            try: a.waiting_json = sys.stdin.read()
            except OSError: a.waiting_json = "{}"
        try: inp = json.loads(a.waiting_json)
        except ValueError: inp = {}
        ti = inp.get("tool_input") or inp.get("toolInput") or inp
        qs = ti.get("questions") or ([ti] if ti.get("question") else [])
        if qs:
            q = qs[0]
            opts = [{"label": o.get("label") or o.get("title") or str(o), "description": o.get("description", "")} for o in (q.get("options") or [])]
            w = {"since": now_utc().strftime("%Y-%m-%dT%H:%M:%SZ"), "question": q.get("question") or q.get("header") or "A question is waiting", "options": opts, "count": len(qs)}
            with open(os.path.join(root, STATE, "waiting.json"), "w", encoding="utf-8") as f: json.dump(w, f, indent=2, ensure_ascii=False)
            append_event(root, "Agent", f"asked: {w['question'][:80]}")
    if a.clear_waiting:
        p = os.path.join(root, STATE, "waiting.json")
        if os.path.isfile(p):
            w = load_json(p, {}); w["clearedAt"] = now_utc().strftime("%Y-%m-%dT%H:%M:%SZ")
            with open(p, "w", encoding="utf-8") as f: json.dump(w, f, indent=2, ensure_ascii=False)
            append_event(root, "You", "answered")
    if a.event: append_event(root, a.event[0], a.event[1])
    if a.live:
        dj = load_json(os.path.join(root, STATE, "dashboard.json"), {}); dj["hooks"] = True; dj["theme"] = dj.get("theme", "brand")
        with open(os.path.join(root, STATE, "dashboard.json"), "w", encoding="utf-8") as f: json.dump(dj, f, indent=2)
    data = build(root, a)
    out = render(root, data)
    if a.open: open_in_browser(out)
    if not a.quiet:
        print(out)
        for n in data["notes"]: print(f"note: {n}", file=sys.stderr)

if __name__ == "__main__":
    try: main()
    except SystemExit: raise
    except Exception as e:  # a hook must never break the agent's turn
        if "--quiet" in sys.argv: sys.exit(0)
        raise
