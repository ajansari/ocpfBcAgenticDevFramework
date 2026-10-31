#!/usr/bin/env python3
"""OCPF BC Agentic Development Framework — the live dashboard renderer.

Renders ProjectDashboard.html (project root, tracked in git — never under the ignored ocpfFramework/state/)
for one project from state the framework already keeps:

  app.json                               name, publisher, version, BC version, logo (embedded as a data URI)
  ocpfFramework/framework.json           edition, runbook version, AL MCP state
  ocpfFramework/state/usage.json         aiTool, step windows (startedAt / completedAt), projectClosedAt once the project is closed
  ProjectProgress.md                     the step table (status per step); Build-a-Feature: the feature table (one row per object)
  ocpfFramework/runbookSteps/<step>.md   the current step's Exit gate text, each step's phase and title (Full, Lite)
  ocpfFramework/state/pricing.json       price source and date, credit price
  ocpfFramework/state/waiting.json       the open question, written by the hooks (see the dashboard skill)
  ocpfFramework/state/dashboard-events.jsonl   recent events, appended by this script and the hooks
  docs/2-design/AiEffortEstimate.md      the current step's estimate (tokens or credits)
  .claude/agents/ocpf-*.md or .github/agents/ocpf-*.agent.md   each role's model and effort
  the usage script (ocpf-usage.py, same folder) with --json   tokens / credits / cost per step and model
  Claude Code transcripts (~/.claude/projects/<key>/*.jsonl)   the agent / you / waiting time split and who is working now
  docs/** and requirements/**           every document, by folder — converted to HTML into ocpfFramework/state/docs/<slug>.js for the View Project Documents popup
  the sign-off / Approved-by lines       the approval line shown above a document in the popup (read only; the documents stay the record)
  docs/index.html                        the Documentation website button, once the html-docs skill built the help site
  outputAppPackage/                      the newest .app, for the Download latest .app link in the Project completed box

Nothing here is estimated by the model: the page shows what is on disk and says what it cannot know.

    python3 ocpf-dashboard.py --project <root> [--open] [--quiet] [--refresh 30] [--toast "text"]
    python3 ocpf-dashboard.py --project <root> --waiting-json '<AskUserQuestion tool input>'   # hook: a question opened
    python3 ocpf-dashboard.py --project <root> --clear-waiting                                  # hook: it was answered
    python3 ocpf-dashboard.py --project <root> --waiting-json - --throttle 45                   # Copilot preToolUse (every tool): stdin
    python3 ocpf-dashboard.py --project <root> --clear-waiting - --throttle 45                  # Copilot postToolUse (every tool): stdin
      Copilot's hooks have no matcher: the hook input carries toolName and toolArgs, and the script acts only when toolName
      matches ask_user|askQuestions; any other tool is an ordinary render, throttled.
    python3 ocpf-dashboard.py --project <root> --close-project                                  # the human said Done: completed state, clocks stopped
    python3 ocpf-dashboard.py --project <root> --event "who" "text"                             # append a feed event
"""
import argparse, time, base64, glob, hashlib, json, os, re, subprocess, sys
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
PHASES = ["DEFINE", "DESIGN", "BUILD", "PROVE"]
# Build-a-Feature (edition "feature"): no step files; one row per object, read from usage.json's windows and the feature table
FEATURE_PHASES = ["INTAKE", "BUILD", "REVIEW", "PACKAGE"]  # the review is offered before the package
FEATURE_GATES = {
    "INTAKE": ["The one intake question answered and the plan said back, object by object.", "The F00 window closed with its usage rows."],
    "BUILD": ["Asked: what the object is and what it holds.", "Confirmed: fields, types, and the key confirmed in one box.",
              "Built: the file written whole from the Standards Guide and the patterns library.", "Compiled: 0 errors / 0 warnings with the analyzers.",
              "Documented: its section in docs/Documentation.md, its row in docs/FeatureRegister.md and docs/DataModel.md, its ChangeLog line.",
              "Closed: usage rows written and pasted; the companion box answered."],
    "PACKAGE": ["Version moved per Ops § Packaging → Version numbers; the package in outputAppPackage/; Shipped in filled on every row it holds."],
    "REVIEW": ["Standards Guide, BCQuality, and the AL Guidelines read against this session's files; findings presented once; approved fixes compiled clean."]}

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

def feature_phase(sid): return "INTAKE" if sid == "F00" else "PACKAGE" if sid == "FPK" else "REVIEW" if sid == "FRV" else "BUILD"

def feature_rows(root):
    """The feature table of ProjectProgress.md: {row id: {object, kind, oid, stage, status, shipped}} in file order."""
    out = {}
    for line in read(os.path.join(root, "ProjectProgress.md")).splitlines():
        if re.match(r"^##\s+Usage and cost", line): break  # the usage table's rows start with the same ids and have 13 or 10 cells
        m = re.match(r"^\|\s*(F\d{2}|FPK|FRV)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|\s*$", line)
        if not m: continue
        c = [x.strip() for x in m.groups()]
        out[c[0]] = {"object": c[1], "kind": c[2], "oid": c[3], "stage": c[4], "status": c[5], "shipped": c[6]}
    return out

def feature_catalog(root, usage, wins):
    """Rows in window-start order, then table rows that have no window yet; status from the table."""
    rows = feature_rows(root)
    ids = []
    for w in wins:
        if w[0] not in ids: ids.append(w[0])
    for rid in rows:
        if rid not in ids: ids.append(rid)
    titles = {s.get("step"): s.get("title") for s in usage.get("steps", []) if s.get("title")}
    cat = []; status = {}
    for sid in ids:
        r = rows.get(sid, {}); ph = feature_phase(sid)
        kind = r.get("kind") if r.get("kind") not in (None, "", "—", "-") else None
        obj = r.get("object") or titles.get(sid) or sid
        title = f"{kind} {obj}" if kind else obj
        st = (r.get("status") or "").lower()
        if st: status[sid] = "now" if "in progress" in st else ("done" if st.startswith("complet") or st.startswith("done") else "todo")
        cat.append({"id": sid, "phase": ph, "title": title, "short": obj, "exitGate": FEATURE_GATES[ph], "stage": r.get("stage") or None,
                    "kind": kind, "objectId": r.get("oid") if r.get("oid") not in (None, "", "—", "-") else None,
                    "shippedIn": r.get("shipped") if r.get("shipped") not in (None, "", "—", "-") else None})
    return cat, status

REMEDIATION_RE = re.compile(r"^(PRE-0[12]|[0-9]{2}|STEP-[0-9])([a-z])$")
REMEDIATION_GATE = ["The changed requirement is in the FRD and the TDD (Lite: the Design Doc), each updated in place with a ChangeLog entry naming this remediation.",
                    "Every affected object regenerated and the whole extension compiled and packaged clean again, as the base step requires.",
                    "The remediation's usage rows written and pasted; the base step's exit gate met again."]

def with_remediations(catalog, usage, wins, status):
    """Insert 07a, 07b, STEP-5a … after their base step: a Remediation window or row (Ops § Usage & Cost → 7)."""
    titles = {s.get("step"): s.get("title") for s in usage.get("steps", []) if s.get("title")}
    ids = []
    for sid in [w[0] for w in wins] + list(status.keys()):
        if REMEDIATION_RE.match(sid) and sid not in ids: ids.append(sid)
    for sid in sorted(ids):
        base = REMEDIATION_RE.match(sid).group(1)
        anchor = max((i for i, c in enumerate(catalog) if c["id"] == base or (REMEDIATION_RE.match(c["id"]) and REMEDIATION_RE.match(c["id"]).group(1) == base and c["id"] < sid)), default=None)
        if anchor is None: continue
        b = catalog[anchor if catalog[anchor]["id"] == base else next(i for i, c in enumerate(catalog) if c["id"] == base)]
        catalog.insert(anchor + 1, {"id": sid, "phase": b["phase"], "title": titles.get(sid) or "Remediation", "short": "Remediation", "exitGate": REMEDIATION_GATE, "remediation": True})
    return catalog

def progress_status(root, catalog):
    txt = read(os.path.join(root, "ProjectProgress.md"))
    status = {}
    for line in txt.splitlines():
        m = re.match(r"^\|\s*(DEFINE|DESIGN|BUILD|PROVE)\s*\|\s*([A-Za-z0-9-]+)\s*[—-]\s*[^|]*\|\s*([^|]*)\|", line)
        if m:
            sid = m.group(2).strip(); st = m.group(3).strip().lower()
            status[sid] = "now" if "in progress" in st else ("done" if st.startswith("complete") or st.startswith("done") else ("todo" if not st or st in ("", "pending", "not started") else "done" if "complet" in st else "todo"))
    return status

def windows(usage):
    wins = []
    closed = parse_ts(usage.get("projectClosedAt"))  # the project was closed (v5.9.5.0): a window still open then ends there, so the clock stops
    for s in usage.get("steps", []):
        a = parse_ts(s.get("startedAt"))
        if a and s.get("step"):
            b = parse_ts(s.get("completedAt"))
            if b is None and closed and a <= closed: b = closed
            wins.append([s["step"], a, b])
    wins.sort(key=lambda w: w[1])
    for i, w in enumerate(wins):
        if w[2] is None and i + 1 < len(wins): w[2] = wins[i + 1][1]
    return wins

def transcript_spans(root, usage):
    """(first, last) timestamp of each top-level Claude Code session file in the project's transcript folder."""
    spans = []
    for f in glob.glob(os.path.join(transcript_dir(root, usage), "*.jsonl")):
        lo = hi = None
        try:
            with open(f, encoding="utf-8", errors="replace") as fh:
                for line in fh:
                    i = line.find('"timestamp":"')
                    if i < 0: continue
                    ts = parse_ts(line[i + 13:i + 13 + 24].split('"')[0])
                    if not ts: continue
                    lo = ts if lo is None or ts < lo else lo; hi = ts if hi is None or ts > hi else hi
        except OSError: continue
        if lo and hi: spans.append((lo, hi))
    return spans

def anchor_first_window(wins, spans, notes):
    """The first window starts where the session that opened it started (v5.8.0.0) — the same rule the usage script
    applies, so the clock and the tokens begin together. Only a session that contains the recorded startedAt counts;
    an earlier, separate session in the same folder never does."""
    if not wins or not spans: return wins
    step, a, b = wins[0]
    hit = [s for s, e in spans if s and e and s <= a <= e and s < a]
    if not hit: return wins
    s0 = min(hit)
    notes.append(f"{step} starts at the session's first event ({s0.astimezone().strftime('%H:%M')}), before its recorded startedAt")
    return [[step, s0, b]] + list(wins[1:])

def union_seconds(wins):
    """Elapsed time of the whole project: the union of every window, so two windows open at once count once."""
    iv = sorted((a, b or now_utc()) for _, a, b in wins)
    total = 0.0; cur_a = cur_b = None
    for a, b in iv:
        if cur_b is None or a > cur_b:
            if cur_b is not None: total += (cur_b - cur_a).total_seconds()
            cur_a, cur_b = a, b
        elif b > cur_b: cur_b = b
    if cur_b is not None: total += (cur_b - cur_a).total_seconds()
    return max(0.0, total)

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
    # a session is <id>.jsonl; its sub-agents (Agent tool) are journaled beside it in <id>/subagents/agent-*.jsonl
    files = sorted(glob.glob(os.path.join(tdir, "*.jsonl")) + glob.glob(os.path.join(tdir, "*", "subagents", "*.jsonl")), key=os.path.getmtime)
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
            elif prev[1] == "ask":
                add(sid, "waiting", gap); pending = False  # an options box was open; its answer comes back as a tool result, not a prompt (v5.8.0.0 — before, this read as agent time and the box stayed 'pending')
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
        if running and main_state == "idle": main_state = "working"  # Main is waiting on its sub-agent, not idle
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
def close_project(root):
    """The human said the project is done (Build-a-Feature's *Done*; Full Step 12 / Lite Step 7 at project close, where the
    usage script's --calibrate does the same): stamp projectClosedAt, close every open window there, and log it (v5.9.5.0)."""
    fw = load_json(os.path.join(root, "ocpfFramework", "framework.json"), {})
    if (fw.get("edition") or "").lower() != "feature":
        append_event(root, "Agent", "--close-project ignored — a Full or Lite project closes at its last step (Ops § Dashboard → 6)"); return  # a Build-a-Feature run inside a Full or Lite project never closes the host (Ops § Build-a-Feature → Where it runs)
    p = os.path.join(root, STATE, "usage.json"); u = load_json(p, {})
    if not u.get("projectClosedAt"): u["projectClosedAt"] = now_utc().strftime("%Y-%m-%dT%H:%M:%SZ")
    for s in u.get("steps", []):
        if s.get("startedAt") and not s.get("completedAt"): s["completedAt"] = u["projectClosedAt"]
    with open(p, "w", encoding="utf-8") as f: json.dump(u, f, indent=2, ensure_ascii=False)
    append_event(root, "You", "closed the project — completed")

def hand_closed(root, usage, edition):
    """A Full or Lite project closed by hand — the last step's row set to Completed in ProjectProgress.md with no
    --close-project / --calibrate behind it: stamp projectClosedAt on first sight, so the clock stops there instead
    of running on in the last step's open window (v5.9.5.0; Ops § Dashboard → 6)."""
    if edition == "feature" or usage.get("projectClosedAt"): return
    cat = step_catalog(root, edition)
    if not cat or progress_status(root, cat).get(cat[-1]["id"]) != "done": return
    ids = {c["id"] for c in cat}
    if any(s.get("startedAt") and not s.get("completedAt") and s.get("step") not in ids for s in usage.get("steps", [])): return  # a feature session's window is open in this host (Case A): not closed, and never cut short
    usage["projectClosedAt"] = now_utc().strftime("%Y-%m-%dT%H:%M:%SZ")
    for s in usage.get("steps", []):
        if s.get("startedAt") and not s.get("completedAt"): s["completedAt"] = usage["projectClosedAt"]
    with open(os.path.join(root, STATE, "usage.json"), "w", encoding="utf-8") as f: json.dump(usage, f, indent=2, ensure_ascii=False)
    append_event(root, "Agent", f"{cat[-1]['id']} is Completed in ProjectProgress.md — project closed, clocks stopped")

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

# ---------------------------------------------------------------- documents, approvals, package
# Every document under docs/ and requirements/ is converted to HTML by the small stdlib converter below and written as a
# per-document sidecar script, ocpfFramework/state/docs/<slug>.js (window.__ocpfDoc = {...}), which the page loads through a
# <script> tag — the one load that works on file:// in every browser. The main sidecar carries only the index. A sidecar is
# rewritten only when its source is newer (or the converter changed), so a hook render stays fast. The PowerShell twin
# carries the same regexes in the same order: the two must produce the same HTML for the same file.
CONV = 4  # converter version; bump when md_to_html or the slug changes so every sidecar is rewritten once (4: injective slugs, URL-safe link paths that keep an author's %XX)
DOC_EXT = (".md", ".txt", ".docx", ".xlsx", ".pdf", ".png", ".jpg", ".jpeg", ".svg")
DOC_SKIP = {"index.html", "build.py", "site.json", "template.html"}  # html-docs' own files in docs/
DOC_SKIP_DIRS = {"images", "assets", "screenshots"}
FOLDER_LABELS = {"0-project": "Project", "1-define": "Define", "2-design": "Design", "3-build": "Build", "4-prove": "Prove",
                 "docs": "Documents", "requirements": "Requirements", "requirements/existing": "Existing app"}
PHASE_FOLDERS = ["0-project", "1-define", "2-design", "3-build", "4-prove"]
DOC_NAMES = {"FRD": "FRD", "TDD": "TDD", "SanityCheck": "Sanity Check", "BuildPlan": "Build Plan", "DesignDoc": "Design Doc",
             "CodeReview": "Code Review", "PostDevTDD": "Post-dev TDD"}
STEP_DOC = {"02": "docs/2-design/FRD.md", "03": "docs/2-design/TDD.md", "04": "docs/2-design/SanityCheck.md", "05": "docs/3-build/BuildPlan.md",
            "09": "docs/4-prove/CodeReview.md", "STEP-2": "docs/2-design/DesignDoc.md"}
FEATURE_STAGES = ["Asked", "Confirmed", "Built", "Compiled", "Documented", "Reviewed", "Packaged"]

def doc_slug(path):
    """The sidecar name: the path with every run of characters outside [A-Za-z0-9_-] turned into one '-', plus the first six hex
    digits of the path's SHA-256 — injective (a.b.md and a-b.md, docs/a/b.md and docs/a-b.md never share a sidecar), URL-safe,
    and a safe file name on every OS. The twin computes the same string."""
    return re.sub(r"[^A-Za-z0-9_-]+", "-", path) + "-" + hashlib.sha256(path.encode("utf-8")).hexdigest()[:6]
def href_path(p):
    """A project-relative path as a URL path: the four characters that would break a relative link are percent-encoded; the text
    is already HTML-escaped, so entities stay as they are (a browser decodes them before resolving the URL)."""
    return re.sub(r"%(?![0-9A-Fa-f]{2})", "%25", p).replace("#", "%23").replace("?", "%3F").replace(" ", "%20")  # a valid %XX written by the author stays
def read_doc(p): return read(p).lstrip("\ufeff")  # a BOM would hide the first heading
def iso_mtime(p): return datetime.fromtimestamp(os.path.getmtime(p), timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
def _esc(s): return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
def _attr(s): return s.replace('"', "&quot;")

def _norm_path(base_dir, url):
    """Resolve a relative link against the document's folder, project-root relative, '/'-separated (same rules as the twin)."""
    parts = []
    for seg in (base_dir + "/" + url).split("/"):
        if seg in ("", "."): continue
        if seg == "..":
            if parts: parts.pop()
            continue
        parts.append(seg)
    return "/".join(parts)

def _heading_id(text, ids):
    t = re.sub(r"<[^>]*>", "", text); t = re.sub(r"&[a-z]+;|&#\d+;", "", t)
    t = re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-") or "section"
    n = ids.get(t, 0); ids[t] = n + 1
    return t if n == 0 else f"{t}-{n + 1}"

def _inline(s, doc_dir):
    """Inline Markdown on an HTML-escaped run: code spans, images, links, bold, italic, strikethrough."""
    codes = []
    def _code(m): codes.append(m.group(1)); return "\x01I%d\x01" % (len(codes) - 1)
    s = re.sub(r"`([^`\n]+)`", _code, s)
    def _img(m):  # a relative source resolves from the document's folder to the project root, like a link (the page lives at the root)
        src = m.group(2)
        if not re.match(r"^(?:https?:|data:|/)", src): src = _norm_path(doc_dir, src)
        if not re.match(r"^(?:https?:|data:|/)", src): src = href_path(src)
        return '<img alt="%s" src="%s">' % (_attr(m.group(1)), _attr(src))
    s = re.sub(r"!\[([^\]]*)\]\(([^)\s]+)\)", _img, s)
    def _link(m):
        text, url = m.group(1), m.group(2)
        if re.match(r"^https?://", url): return '<a href="%s" target="_blank" rel="noopener">%s</a>' % (_attr(url), text)
        if url.startswith("#") or url.startswith("mailto:") or url.startswith("/"): return '<a href="%s">%s</a>' % (_attr(url), text)
        anchor = ""
        if "#" in url: url, anchor = url.split("#", 1)
        rel = _norm_path(doc_dir, url)
        if (rel.startswith("docs/") or rel.startswith("requirements/")) and rel.lower().endswith(".md"):
            return '<a href="#doc=%s%s">%s</a>' % (doc_slug(rel), ("&amp;h=" + _attr(anchor)) if anchor else "", text)
        return '<a href="%s" target="_blank">%s</a>' % (_attr(href_path(rel) + (("#" + anchor) if anchor else "")), text)
    s = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", _link, s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", s)
    s = re.sub(r"(?<![\w*])\*([^*\n]+?)\*(?![\w*])", r"<em>\1</em>", s)
    s = re.sub(r"~~(.+?)~~", r"<del>\1</del>", s)
    s = re.sub(r"\x01I(\d+)\x01", lambda m: "<code>%s</code>" % codes[int(m.group(1))], s)
    return s

RE_FENCE = re.compile(r"(?ms)^[ \t]*```[ \t]*([\w+-]*)[^\n]*\n(.*?)^[ \t]*```[ \t]*$")
RE_HEADING = re.compile(r"^(#{1,6})[ \t]+(.*?)[ \t]*#*[ \t]*$")
RE_HR = re.compile(r"^[ \t]*(?:-[ \t]*){3,}$|^[ \t]*(?:\*[ \t]*){3,}$|^[ \t]*(?:_[ \t]*){3,}$")
RE_LIST = re.compile(r"^([ \t]*)(?:[-*+]|\d+[.)])[ \t]+(.*)$")
RE_TASK = re.compile(r"^\[([ xX])\][ \t]+")
RE_BQ = re.compile(r"^[ \t]*&gt;[ \t]?(.*)$")
RE_TSEP = re.compile(r"^[ \t]*\|?[ \t]*:?-{3,}:?[ \t]*(?:\|[ \t]*:?-{3,}:?[ \t]*)*\|?[ \t]*$")
RE_CELL = re.compile(r"(?<!\\)\|")

def _cells(line):
    s = line.strip()
    if s.startswith("|"): s = s[1:]
    if s.endswith("|") and not s.endswith("\\|"): s = s[:-1]
    return [c.strip().replace("\\|", "|") for c in RE_CELL.split(s)]

def md_to_html(text, doc_path):
    """Markdown → HTML, stdlib only: headings (with ids), paragraphs, bold / italic / code, fenced code (Mermaid shown as source),
    lists one level deep with checkboxes, GFM tables, links (docs/ links become #doc= routes), blockquotes, rules, images.
    The whole text is HTML-escaped first: a document is untrusted text, never passthrough HTML."""
    doc_dir = doc_path.rsplit("/", 1)[0] if "/" in doc_path else ""
    text = _esc(text.replace("\r\n", "\n").replace("\r", "\n"))
    fences = []
    def _fence(m): fences.append((m.group(1).strip().lower(), m.group(2))); return "\x01F%d\x01" % (len(fences) - 1)
    text = RE_FENCE.sub(_fence, text)
    lines = text.split("\n"); n = len(lines)
    out = []; para = []; bq = []; lists = []; ids = {}
    def flush_para():
        if para:
            s = "\n".join(l.lstrip() for l in para); s = re.sub(r" {2,}\n", "<br>\n", s).strip()
            out.append("<p>" + _inline(s, doc_dir) + "</p>"); del para[:]
    def flush_bq():
        if bq:
            out.append("<blockquote>" + "".join("<p>" + _inline(p.strip(), doc_dir) + "</p>" for p in re.split(r"\n[ \t]*\n", "\n".join(bq)) if p.strip()) + "</blockquote>"); del bq[:]
    def close_lists(to=0):
        while len(lists) > to: out.append("</li></%s>" % lists.pop())
    i = 0
    while i < n:
        line = lines[i]
        if not line.strip():
            flush_para(); flush_bq()
            j = i + 1
            while j < n and not lines[j].strip(): j += 1
            if not (j < n and RE_LIST.match(lines[j])): close_lists()
            i += 1; continue
        m = re.match(r"^\x01F(\d+)\x01$", line.strip())
        if m:
            flush_para(); flush_bq(); close_lists()
            lang, body = fences[int(m.group(1))]
            if body.endswith("\n"): body = body[:-1]
            out.append('<pre class="code"%s><code>%s</code></pre>' % ((' data-lang="%s"' % lang) if lang else "", body)); i += 1; continue
        m = RE_HEADING.match(line)
        if m:
            flush_para(); flush_bq(); close_lists()
            h = _inline(m.group(2), doc_dir)
            out.append('<h%d id="%s">%s</h%d>' % (len(m.group(1)), _heading_id(h, ids), h, len(m.group(1)))); i += 1; continue
        if RE_HR.match(line):
            flush_para(); flush_bq(); close_lists(); out.append("<hr>"); i += 1; continue
        if line.lstrip().startswith("|") and i + 1 < n and RE_TSEP.match(lines[i + 1]):
            flush_para(); flush_bq(); close_lists()
            out.append("<table><thead><tr>" + "".join("<th>%s</th>" % _inline(c, doc_dir) for c in _cells(line)) + "</tr></thead><tbody>")
            i += 2
            while i < n and lines[i].lstrip().startswith("|"):
                out.append("<tr>" + "".join("<td>%s</td>" % _inline(c, doc_dir) for c in _cells(lines[i])) + "</tr>"); i += 1
            out.append("</tbody></table>"); continue
        m = RE_BQ.match(line)
        if m:
            flush_para(); close_lists(); bq.append(m.group(1)); i += 1; continue
        m = RE_LIST.match(line)
        if m:
            flush_para(); flush_bq()
            indent = len(m.group(1).replace("\t", "    ")); level = 1 if indent >= 2 else 0
            tag = "ol" if re.match(r"^[ \t]*\d", line) else "ul"
            if level > len(lists): level = len(lists)
            if len(lists) > level + 1: close_lists(level + 1)
            if len(lists) == level + 1:
                if lists[-1] != tag: close_lists(level)
                else: out.append("</li>")
            if len(lists) == level: out.append("<%s>" % tag); lists.append(tag)
            body = m.group(2); t = RE_TASK.match(body)
            if t: body = '<input type="checkbox" disabled%s> ' % (" checked" if t.group(1) != " " else "") + body[t.end():]
            out.append("<li>" + _inline(body, doc_dir)); i += 1; continue
        if lists and not para and not bq:
            out[-1] += " " + _inline(line.strip(), doc_dir); i += 1; continue  # lazy continuation of the last item
        if bq:
            bq.append(line.strip()); i += 1; continue
        para.append(line); i += 1
    flush_para(); flush_bq(); close_lists()
    return "\n".join(out)

TEXT_CAP = 200_000  # characters of source text a sidecar carries (Markdown, plain text, extracted office text alike)
TRUNC_LINE = "<p><em>Text truncated at 200 KB — open the file itself for the rest.</em></p>"

def xml_text(s):
    return s.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", '"').replace("&apos;", "'").replace("&amp;", "&")

def office_html(path):
    """docx / xlsx → HTML by zipfile + regex over the XML parts (stdlib), capped at 200 KB of text."""
    import zipfile
    out = []; size = 0; cap = TEXT_CAP; cut = False
    def add(s):
        nonlocal size, cut
        if cut: return
        size += len(s)
        if size > cap: cut = True; return
        out.append(s)
    try:
        with zipfile.ZipFile(path) as z:
            names = sorted(z.namelist())
            if "word/document.xml" in names:
                xml = z.read("word/document.xml").decode("utf-8", "replace")
                for p in re.findall(r"(?s)<w:p[ >].*?</w:p>", xml):
                    t = "".join(re.findall(r"(?s)<w:t(?: [^>]*)?>(.*?)</w:t>", p))
                    if t.strip(): add("<p>" + _esc(xml_text(t)) + "</p>")
            else:
                shared = []
                if "xl/sharedStrings.xml" in names:
                    for si in re.findall(r"(?s)<si>(.*?)</si>", z.read("xl/sharedStrings.xml").decode("utf-8", "replace")):
                        shared.append(xml_text("".join(re.findall(r"(?s)<t(?: [^>]*)?>(.*?)</t>", si))))
                sheets = [x for x in names if re.match(r"^xl/worksheets/sheet\d+\.xml$", x)]
                for k, sh in enumerate(sheets):
                    add("<h2>Sheet %d</h2><table><tbody>" % (k + 1))
                    for row in re.findall(r"(?s)<row[ >].*?</row>", z.read(sh).decode("utf-8", "replace")):
                        row = re.sub(r"<c( [^>]*)?/>", r"<c\1></c>", row); cells = []
                        for attrs, inner in re.findall(r'(?s)<c( [^>]*)?>(.*?)</c>', row):
                            v = re.search(r"(?s)<v>(.*?)</v>", inner); v = xml_text(v.group(1)) if v else ""
                            if 't="s"' in attrs and v.isdigit() and int(v) < len(shared): v = shared[int(v)]
                            elif 't="inlineStr"' in attrs:
                                v = xml_text("".join(re.findall(r"(?s)<t(?: [^>]*)?>(.*?)</t>", inner)))
                            cells.append("<td>" + _esc(v) + "</td>")
                        if cells: add("<tr>" + "".join(cells) + "</tr>")
                    add("</tbody></table>")
    except Exception as e:  # a damaged or unknown file: say so in the popup instead of failing the render
        return "<p><em>Could not extract text: %s</em></p>" % _esc(str(e))
    if cut: out.append(TRUNC_LINE)
    return "\n".join(out)

def doc_kind(name):
    ext = os.path.splitext(name)[1].lower()
    return "markdown" if ext == ".md" else "text" if ext == ".txt" else "extracted" if ext in (".docx", ".xlsx") else "pdf" if ext == ".pdf" else "image"

def doc_title(path, kind, name):
    if kind == "markdown":
        for line in read_doc(path).splitlines()[:40]:
            m = re.match(r"^#[ \t]+(.+?)[ \t]*#*[ \t]*$", line)
            if m: return re.sub(r"[`*_]", "", m.group(1)).strip() or name
    return name

def write_doc_sidecar(root, rel, kind):
    """ocpfFramework/state/docs/<slug>.js, rewritten only when the source is newer or the converter changed. Returns the slug."""
    src = os.path.join(root, rel); slug = doc_slug(rel); ddir = os.path.join(root, STATE, "docs"); out = os.path.join(ddir, slug + ".js")
    os.makedirs(ddir, exist_ok=True)
    try:
        if os.path.isfile(out) and os.path.getmtime(out) >= os.path.getmtime(src):
            with open(out, encoding="utf-8", errors="replace") as f: head = f.read(80)
            if '"conv":%d,' % CONV in head: return slug
    except OSError: pass
    name = os.path.basename(rel)
    if kind in ("markdown", "text"):
        text = read_doc(src); cut = len(text) > TEXT_CAP; text = text[:TEXT_CAP]
        html = md_to_html(text, rel) if kind == "markdown" else '<pre class="plain">' + _esc(text.replace("\r\n", "\n").replace("\r", "\n")) + "</pre>"
        if cut: html += "\n" + TRUNC_LINE
    else: html = office_html(src)
    doc = {"conv": CONV, "slug": slug, "path": rel, "title": doc_title(src, kind, name), "kind": kind, "html": html,
           "renderedAt": now_utc().strftime("%Y-%m-%dT%H:%M:%SZ"), "bytes": os.path.getsize(src)}
    with open(out + ".tmp", "w", encoding="utf-8") as f: f.write("window.__ocpfDoc=" + json.dumps(doc, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/") + ";")
    os.replace(out + ".tmp", out)
    return slug

def docs_index(root):
    """Every document under docs/ (by phase folder, then other subfolders, then the flat files) and requirements/ (depth 2)."""
    groups = []  # (name, dir rel, files)
    def files_in(d):
        full = os.path.join(root, d)
        if not os.path.isdir(full): return []
        names = sorted(x for x in os.listdir(full) if os.path.isfile(os.path.join(full, x)) and not x.startswith(".") and x not in DOC_SKIP and x.lower().endswith(DOC_EXT))
        return names
    def subdirs(d):
        full = os.path.join(root, d)
        if not os.path.isdir(full): return []
        return sorted(x for x in os.listdir(full) if os.path.isdir(os.path.join(full, x)) and not x.startswith(".") and x not in DOC_SKIP_DIRS)
    docs_subs = subdirs("docs")
    for ph in PHASE_FOLDERS:
        if ph in docs_subs: groups.append((ph, "docs/" + ph))
    for d in docs_subs:
        if d not in PHASE_FOLDERS: groups.append((d, "docs/" + d))
    groups.append(("docs", "docs"))
    groups.append(("requirements", "requirements"))
    for d in subdirs("requirements"): groups.append(("requirements/" + d, "requirements/" + d))
    folders = []; count = 0; keep = set(); skipped = []; seen = {}
    for name, d in groups:
        files = []
        for fn in files_in(d):
            rel = d + "/" + fn; kind = doc_kind(fn); full = os.path.join(root, rel)
            slug = doc_slug(rel); sidecar = None
            if slug in seen: skipped.append("%s (slug collides with %s)" % (rel, seen[slug])); continue  # cannot happen with the hashed slug; said, never silent
            seen[slug] = rel
            try:  # one unreadable or malformed file is skipped and named in docs.note — it never stops the render
                if kind in ("markdown", "text", "extracted"):
                    keep.add(slug + ".js"); write_doc_sidecar(root, rel, kind); sidecar = STATE.replace(os.sep, "/") + "/docs/" + slug + ".js"  # kept even when this write fails: the last good sidecar still reads
                files.append({"path": rel, "title": doc_title(full, kind, fn), "slug": slug, "kind": kind, "bytes": os.path.getsize(full),
                              "modifiedAt": iso_mtime(full), "sidecar": sidecar})
            except Exception as e:
                skipped.append("%s (%s)" % (rel, str(e).splitlines()[0][:80] if str(e) else type(e).__name__))
        if files:
            label = FOLDER_LABELS.get(name) or (re.sub(r"^\d+-", "", name.split("/")[-1])[:1].upper() + re.sub(r"^\d+-", "", name.split("/")[-1])[1:])
            folders.append({"name": name, "label": label, "files": files}); count += len(files)
    ddir = os.path.join(root, STATE, "docs")
    if os.path.isdir(ddir):  # a sidecar whose source is gone
        for fn in os.listdir(ddir):
            if fn.endswith(".js") and fn not in keep:
                try: os.remove(os.path.join(ddir, fn))
                except OSError: pass
    note = ("Skipped %d file%s the renderer could not read: %s" % (len(skipped), "" if len(skipped) == 1 else "s", "; ".join(skipped))) if skipped else None
    return {"folders": folders, "count": count, "renderedAt": now_utc().strftime("%Y-%m-%dT%H:%M:%SZ"), "note": note}

RE_SIGNOFF = re.compile(r"\*\*Sign-off:\*\*\s*(?:([^—\n]+?)\s*—\s*)?([^,\n·]+?),\s*([^·\n]+?)(?=\s*(?:·|\*\*|$))")
RE_SIGNOFF_ANY = re.compile(r"\*\*Sign-off:\*\*\s*([^·\n]+?)(?=\s*(?:·|\*\*|$))")
RE_APPROVED = re.compile(r"\*\*Approved by:\*\*\s*([^,\n(]+?),\s*([^(\n·]+?)(?=\s*(?:\(|·|\*\*|$))")
def approval_status(name, date):
    return "pending" if (re.search(r"(?i)pending", date or "") or re.match(r"^<.*>$", (date or "").strip()) or not (date or "").strip() or re.match(r"^<.*>$", (name or "").strip())) else "approved"

def approvals(root):
    """Sign-off and Approved-by lines in the first 12 lines of every .md under docs/, plus the Code Review §3 table. Read only —
    the documents stay the record; the popup only shows what they say."""
    out = []; paths = []
    for d, dirs, files in os.walk(os.path.join(root, "docs")):
        dirs[:] = [x for x in dirs if x not in DOC_SKIP_DIRS]
        paths += [os.path.relpath(os.path.join(d, fn), root).replace(os.sep, "/") for fn in files if fn.lower().endswith(".md")]
    for rel in sorted(paths):  # code-point order, the twin sorts ordinal
            full = os.path.join(root, rel); fn = os.path.basename(rel)
            stem = os.path.splitext(fn)[0]; label = DOC_NAMES.get(stem, stem)
            text = read_doc(full); lines = text.splitlines()
            for ln, line in enumerate(lines[:12], 1):
                m = RE_SIGNOFF.search(line)
                if m:
                    role, name, date = (m.group(1) or "").strip() or None, m.group(2).strip(), m.group(3).strip()
                    out.append({"document": label, "path": rel, "role": role, "name": name, "date": date, "status": approval_status(name, date), "source": "Sign-off", "line": ln})
                elif "**Sign-off:**" in line:
                    m = RE_SIGNOFF_ANY.search(line); txt = m.group(1).strip() if m else ""
                    out.append({"document": label, "path": rel, "role": None, "name": txt or None, "date": None, "status": "pending", "source": "Sign-off", "line": ln})
                m = RE_APPROVED.search(line)
                if m:
                    name, date = m.group(1).strip(), m.group(2).strip()
                    out.append({"document": label, "path": rel, "role": None, "name": name, "date": date, "status": approval_status(name, date), "source": "Approved by", "line": ln})
            if stem == "CodeReview":
                k = next((i for i, l in enumerate(lines) if re.match(r"^##\s+3\.\s+Fix batch", l)), None)
                if k is not None:
                    i = k + 1; seen = 0
                    while i < len(lines) and not lines[i].startswith("## "):
                        l = lines[i]
                        if l.lstrip().startswith("|"):
                            seen += 1
                            if seen > 2:
                                c = _cells(l)
                                if len(c) >= 4 and any(x for x in c[:3]):
                                    name, date = re.sub(r"[*_]", "", c[1]).strip(), re.sub(r"[*_]", "", c[2]).strip()
                                    out.append({"document": "Code Review — fix batch", "path": rel, "role": None, "name": name, "date": date, "status": approval_status(name, date), "source": "Code Review §3", "line": i + 1})
                        i += 1
    return out


def newest_mtime(d, ext):
    best = None
    for dd, _, files in os.walk(d):
        for f in files:
            if f.lower().endswith(ext):
                try: t = os.path.getmtime(os.path.join(dd, f))
                except OSError: continue
                best = t if best is None or t > best else best
    return best

def usage_row_present(root, sid):
    txt = read(os.path.join(root, "ProjectProgress.md")); hit = False
    for line in txt.splitlines():
        if re.match(r"^##\s+Usage and cost", line): hit = True; continue
        if hit and re.match(r"^\|\s*\**" + re.escape(sid) + r"\**(?:\s*\(open\))?\s*\|", line): return True
    return False

# The gate rules (the twin carries the same three patterns): a path the item names; the item *is* an existence claim about it
# (the path is the subject of the first sentence, up to three words before it); the compile / package verbs (never the noun).
GATE_PATH = r"(docs/[\w./-]+\.\w+|requirements/[\w./-]+\.\w+|app\.json|outputAppPackage/)"
RE_GATE_PATH = re.compile(GATE_PATH)
RE_GATE_EXISTS = re.compile(r"^(?:[\w'-]+\s+){0,3}?" + GATE_PATH + r"\s*(?:\([^)]*\)\s*)?(?:exists|is written|is in\b|in place|holds)\b")
RE_GATE_WRITTEN = re.compile(r"^(?:[\w'-]+\s+){0,5}?written to\s+" + GATE_PATH)
RE_GATE_COMPILE = re.compile(r"(?i)\b(compiles?|compiled|0 errors|packaged|packages)\b")

def progress(root, cur, edition, appr, pkg):
    """The within-step progress bar's data (6.0.0.0; Ops § Dashboard → 7, the honesty rule): the current step's exit-gate items,
    each verified from disk where a literal rule exists — done / open — else unknown. Build-a-Feature: the row's stage ladder,
    exact. No timer, no interpolation; the page fills the bar by done / total and says how many items it could not read."""
    if not cur: return None
    items = []
    if edition == "feature":
        stage = (cur.get("stage") or "").strip(); idx = next((i for i, s in enumerate(FEATURE_STAGES) if s.lower() == stage.lower()), -1)
        for i, s in enumerate(FEATURE_STAGES): items.append({"text": s, "state": "done" if i <= idx else "open", "why": "stage column of the feature table"})
        source = "ProjectProgress.md"
    else:
        doc = STEP_DOC.get(cur["id"]); doc_appr = [a for a in appr if doc and a["path"] == doc]
        app_t = newest_mtime(os.path.join(root, "outputAppPackage"), ".app") if pkg.get("count") else None
        src_t = newest_mtime(os.path.join(root, "src"), ".al")
        for text in cur.get("exitGate") or []:
            st = "unknown"; why = "no on-disk signal"
            paths = RE_GATE_PATH.findall(text)
            if re.search(r"(?i)sign-off", text):  # first: a sign-off item is about the approval, whatever paths it names
                if doc is None: why = "no document mapped to this step"
                elif not doc_appr: st = "open"; why = doc + " has no sign-off line yet"
                elif any(a["status"] == "approved" for a in doc_appr): st = "done"; why = doc + " sign-off line not pending"
                else: st = "open"; why = doc + " sign-off pending"
            elif paths:  # a path proves only an existence claim whose subject is the path ("<path> exists / is written / is in / in place", "written to <path>")
                if RE_GATE_EXISTS.match(text) or RE_GATE_WRITTEN.match(text):
                    missing = [p for p in paths if not (pkg.get("count") if p == "outputAppPackage/" else os.path.exists(os.path.join(root, p)))]
                    st = "open" if missing else "done"; why = (missing[0] + (" holds no package yet" if missing[0] == "outputAppPackage/" else " not found")) if missing else (", ".join(paths) + (" exists" if len(paths) == 1 else " exist"))
                else: why = "names " + paths[0] + " but claims more than its existence"
            elif re.search(r"(?i)usage rows", text):
                st = "done" if usage_row_present(root, cur["id"]) else "open"; why = "ProjectProgress.md usage table " + ("has" if st == "done" else "has no") + " row " + cur["id"]
            elif RE_GATE_COMPILE.search(text) and not re.search(r"(?i)\.alpackages|not required|no compile", text):
                if app_t and (src_t is None or app_t >= src_t): st = "done"; why = "newest .app is newer than every src/**/*.al"
                else: st = "open"; why = "no package newer than src/" if app_t else "no package yet"
            items.append({"text": text, "state": st, "why": why})
        source = "runbookSteps/%s.md" % cur["id"]
    done = sum(1 for x in items if x["state"] == "done"); verifiable = sum(1 for x in items if x["state"] != "unknown")
    return {"stepId": cur["id"], "items": items, "done": done, "verifiable": verifiable, "total": len(items), "source": source}

def help_site(root):
    """docs/index.html (the html-docs skill) — the Documentation website button appears once it exists."""
    p = os.path.join(root, "docs", "index.html")
    if not os.path.isfile(p): return {"path": "docs/index.html", "exists": False, "builtAt": None, "staleAgainst": []}
    built = os.path.getmtime(p); stale = []
    for tab in (load_json(os.path.join(root, "docs", "site.json"), {}).get("tabs") or []):
        src = tab.get("source") if isinstance(tab, dict) else None
        if src and os.path.isfile(os.path.join(root, src)) and os.path.getmtime(os.path.join(root, src)) > built: stale.append(src)
    return {"path": "docs/index.html", "exists": True, "builtAt": iso_mtime(p), "staleAgainst": stale}

def package_info(root):
    """The newest .app in outputAppPackage/ (Ops § Packaging) by the version in <Name>_<a.b.c.d>.app, mtime as the fallback;
    when that folder holds none, a shallow search of the project root (never .alpackages, node_modules, .git, ocpfFramework)."""
    def vkey(f):
        m = re.search(r"_(\d+)\.(\d+)\.(\d+)\.(\d+)\.app$", f)
        return tuple(int(x) for x in m.groups()) if m else None
    cands = []
    pdir = os.path.join(root, "outputAppPackage")
    if os.path.isdir(pdir): cands = ["outputAppPackage/" + f for f in os.listdir(pdir) if f.lower().endswith(".app") and os.path.isfile(os.path.join(pdir, f))]
    if not cands:
        cands = [f for f in os.listdir(root) if f.lower().endswith(".app") and os.path.isfile(os.path.join(root, f))]
        for d in os.listdir(root):
            if d in (".alpackages", "node_modules", ".git", "ocpfFramework") or d.startswith(".") or not os.path.isdir(os.path.join(root, d)): continue
            cands += [d + "/" + f for f in os.listdir(os.path.join(root, d)) if f.lower().endswith(".app") and os.path.isfile(os.path.join(root, d, f))]
    if not cands: return {"path": None, "file": None, "version": None, "bytes": None, "builtAt": None, "count": 0}
    best = None; best_v = None; best_t = None
    for c in cands:  # a versioned name beats an unversioned one; then the higher version; unversioned: the newer file; ties: the later name
        v = vkey(c); t = os.path.getmtime(os.path.join(root, c)); take = False
        if best is None: take = True
        elif v and not best_v: take = True
        elif v and best_v: take = v > best_v or (v == best_v and c > best)
        elif not v and not best_v: take = t > best_t or (t == best_t and c > best)
        if take: best, best_v, best_t = c, v, t
    v = best_v
    return {"path": best, "file": os.path.basename(best), "version": ".".join(str(x) for x in v) if v else None, "bytes": os.path.getsize(os.path.join(root, best)),
            "builtAt": iso_mtime(os.path.join(root, best)), "count": len(cands)}

# ---------------------------------------------------------------- main
def build(root, a):
    fw = load_json(os.path.join(root, "ocpfFramework", "framework.json"), {})
    usage = load_json(os.path.join(root, STATE, "usage.json"), {})
    tool = usage.get("aiTool") or ("copilot-chat" if ".github/copilot-instructions.md" in str(fw.get("placedAs")) else "claude-code")
    copilot = tool.startswith("copilot")
    edition = (fw.get("edition") or ("lite" if os.path.isfile(os.path.join(root, "ocpfFramework", "runbookSteps", "STEP-1.md")) else "full")).lower()
    notes = []
    hand_closed(root, usage, edition)  # the last step's row Completed with nothing stamped: close it now, before the windows are read
    wins = windows(usage)
    uj, err = usage_rows(root, tool) if wins else (None, "no step windows yet")
    if err: notes.append(f"usage: {err}")
    rows = (uj or {}).get("rows", [])
    pricing = load_json(os.path.join(root, STATE, "pricing.json"), {})  # the usage script may just have fetched the prices (v5.8.0.0)
    # The first window begins where its session began (Claude Code: the transcript file; Copilot: the journaled
    # session the usage script summarises) — otherwise the tokens start before the clock does (v5.8.0.0).
    if copilot:
        spans = [(parse_ts(x.get("start")), parse_ts(x.get("lastKnownAt")) or now_utc()) for x in ((uj or {}).get("sessions") or []) if x.get("start")]
    else:
        spans = transcript_spans(root, usage)
    wins = anchor_first_window(wins, spans, notes); el = elapsed_by_step(wins)
    if edition == "feature":
        catalog, status = feature_catalog(root, usage, wins); phases = FEATURE_PHASES
    else:
        catalog = step_catalog(root, edition); status = progress_status(root, catalog); phases = PHASES
        catalog = with_remediations(catalog, usage, wins, status)
    def rows_for(sid): return [r for r in rows if r.get("step", "").replace(" (open)", "") == sid]
    live = claude_live(root, usage, wins, None) if (not copilot and wins) else None
    if live:
        # The split comes from gaps between transcript events, the elapsed from the step windows; the two never
        # agreed to the second (events outside every window, a capped gap, time before the first event). Scale
        # each step's split to its window so agent + you + waiting == elapsed, exactly (v5.6.0.0).
        per = {}
        for sid, sec in el.items():
            v = live["perStep"].get(sid) or {"agent": 0.0, "human": 0.0, "waiting": 0.0}
            tot = v["agent"] + v["human"] + v["waiting"]
            if tot > 0: per[sid] = {k: v[k] * sec / tot for k in v}
            else: per[sid] = {"agent": 0.0, "human": sec, "waiting": 0.0}  # a window with no transcript event: nobody was in the chat — the human's time (v5.8.0.0; before, the step was left out and the three never added up to Elapsed)
        live["perStep"] = per
    steps = []
    for c in catalog:
        sid = c["id"]; rs = rows_for(sid)
        st = status.get(sid) or ("done" if any(w[0] == sid and w[2] for w in wins) and not any(w[0] == sid and w[2] is None for w in wins) else ("now" if any(w[0] == sid for w in wins) else "todo"))
        if sid in el and st == "todo": st = "now" if any(w[0] == sid and w[2] is None for w in wins) else "done"
        steps.append({"id": sid, "title": c["title"], "short": c["short"], "phase": c["phase"], "status": st, "elapsedSeconds": el.get(sid),
                      "costUsd": sum((r.get("costUsd") or 0) for r in rs) if rs else None,
                      "tokens": sum((r.get("input") or 0) + (r.get("output") or 0) + (r.get("cacheWrite") or 0) + (r.get("cacheRead") or 0) for r in rs) if rs and not copilot else None,
                      "credits": sum((r.get("aiCredits") or 0) for r in rs) if rs and copilot else None,
                      **{k: c[k] for k in ("stage", "kind", "objectId", "shippedIn", "remediation") if c.get(k)}})
    cur = next((s for s in steps if s["status"] == "now"), None)
    # totals
    # Elapsed is the union of the windows (a reopened step or a remediation open beside another step counts once), so
    # the headline figure is wall-clock from the first session's first event to now (v5.8.0.0).
    tot = {"costUsd": sum((r.get("costUsd") or 0) for r in rows) if rows else None, "elapsedSeconds": union_seconds(wins) if el else None,
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
    # a row the usage script could not price (no rate for its model in pricing.json) must never read as $0
    unpriced = sorted({r.get("model") or "unknown" for r in rows if r.get("costUsd") is None and ((r.get("input") or 0) + (r.get("output") or 0) + (r.get("aiCredits") or 0)) > 0})
    outside = [r for r in rows if (r.get("step") or "").startswith("Unattributed")]
    oc = sum((r.get("costUsd") or 0) for r in outside)
    if outside and oc > 0:
        notes.append(f"${oc:.2f} of the cost fell outside every step window — before the first window's session or after the last window closed — and is in the total but on no row")
    if unpriced:
        tot["costUnpriced"] = unpriced
        notes.append("price unknown for " + ", ".join(unpriced) + " — the usage script fetches Anthropic's published rates itself at each measurement; if this stays, the machine is offline or the model's publisher is not covered (Ops § Usage & Cost → 3)")
    if live:
        ag = sum(v["agent"] for v in live["perStep"].values()); hu = sum(v["human"] for v in live["perStep"].values()); wa = sum(v["waiting"] for v in live["perStep"].values())
        # the per-step splits are scaled to each step's window; the headline is the union of the windows, so scale once more
        # and the three figures add up to Elapsed exactly
        ssum = ag + hu + wa; k = (tot["elapsedSeconds"] / ssum) if ssum > 0 and tot.get("elapsedSeconds") else 1.0
        tot.update({"agentSeconds": ag * k, "humanSeconds": hu * k, "waitingSeconds": wa * k})
    current = {}
    if cur:
        rs = rows_for(cur["id"]); ps = (live or {}).get("perStep", {}).get(cur["id"]) if live else None
        current = {"id": cur["id"], "title": cur["title"], "phase": cur["phase"], "exitGate": next(c["exitGate"] for c in catalog if c["id"] == cur["id"]), "stage": cur.get("stage"),
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
        # every sub-agent is matched to a role by model; a role shows how many of its sub-agents run right now (runningCount)
        for r in rl:
            if r["role"] not in ("Reasoning", "Light", "Generator") or not r.get("model"): continue
            ms = [s for s in live["subs"] if s.get("model") and (r["model"] in s["model"] or s["model"] in r["model"])]
            run = [s for s in ms if s["running"]]
            if run:
                r["status"] = "running"; r["runningSeconds"] = max(s["seconds"] for s in run); r["runningCount"] = len(run); r["lastDetail"] = None
            elif ms:
                r["lastDetail"] = f"returned {max(s['last'] for s in ms).astimezone().strftime('%H:%M')}"
    # per-role totals from models (by model name match)
    for r in rl:
        if r.get("model"):
            m = next((g for g in models if g["model"] and (g["model"] in r["model"] or r["model"] in g["model"])), None)
            if m: r["tokens"] = m["tokens"]; r["credits"] = round(m["credits"], 1)
    gen_ = next(r for r in rl if r["role"] == "Generator"); main_ = next(r for r in rl if r["role"] == "Main")
    if gen_.get("model") and main_.get("model") and gen_["model"] == main_["model"]:
        gen_.pop("tokens", None); gen_.pop("credits", None); gen_["detail"] = "same model as Main; its usage is counted in Main's row"
    if cur is None and not wins: rl = [r for r in rl if r["model"]] or rl
    if edition == "feature": rl = [r for r in rl if r["role"] == "Main"]  # one model does everything on this journey
    waiting = load_json(os.path.join(root, STATE, "waiting.json"), None)
    if waiting and waiting.get("clearedAt"): waiting = None
    if waiting:
        m_ = next(r for r in rl if r["role"] == "Main"); m_["status"] = "waiting on you"; m_["detail"] = (waiting.get("question") or "")[:90]
    # The project's state (v5.9.5.0): completed / waiting / testing / working / idle. Before this, a finished project showed
    # Main "working" forever — the last hook rendered the page inside the 180 s window and nothing rendered it again — and
    # the Build-a-Feature "Done" answer left every window open, so Elapsed kept growing. The page also ages "working" itself
    # from Main's lastAt, so a stale render can't keep the light green.
    main_ = next((r for r in rl if r["role"] == "Main"), None) or {"status": "idle"}  # Main may have been filtered out before any window
    if live: main_["lastAt"] = live["main"]["lastAt"]
    closed_at = parse_ts(usage.get("projectClosedAt"))
    starts = [parse_ts(s.get("startedAt")) for s in usage.get("steps", []) if parse_ts(s.get("startedAt"))]
    if closed_at and any(t > closed_at for t in starts): closed_at = None  # a window opened after the close: the project is back in work
    cat_ids = {c["id"] for c in catalog}
    reopened = (usage.get("projectClosedAt") and closed_at is None) or any(w[2] is None and w[0] not in cat_ids for w in wins)  # …or a feature session's window open in a finished host (Case A): the last row stays Completed, the project is still back in work
    base = [c["id"] for c in catalog if not c.get("remediation")]  # a remediation row (07a, STEP-5a) opened from the release test must not displace the last step
    last_id = base[-1] if (base and edition != "feature") else None
    last_done = bool(last_id) and not reopened and next((s["status"] for s in steps if s["id"] == last_id), None) == "done"
    since = None
    if closed_at or last_done:
        state = "completed"; since = closed_at or max((w[2] for w in wins if w[2]), default=None)
        for s in steps:
            if s["status"] == "now": s["status"] = "done"  # a row the tracker still calls In Progress was closed by the close itself
        cur = None; current = {}
        for r in rl:
            r["status"] = "finished" if r["role"] == "Main" else "idle"
            for k in ("runningCount", "runningSeconds", "lastDetail", "detail", "lastAt"): r.pop(k, None)
    elif waiting:
        state = "waiting"; since = parse_ts(waiting.get("since"))
    elif cur and last_id and cur["id"] == last_id and main_["status"] != "working":
        state = "testing"; since = max((w[1] for w in wins if w[0] == cur["id"]), default=None)
        main_["status"] = "waiting on you"; main_["detail"] = "release testing — tell the agent how it went"
    elif main_["status"] == "working": state = "working"
    else: state = "idle"
    project = {"state": state, "since": since.isoformat() if since else None, "closedAt": closed_at.isoformat() if closed_at else None, "lastStep": last_id}
    est = estimate_for(root, cur["id"], copilot) if (cur and edition != "feature") else None
    if est and est.get("estimated") is not None and cur:
        est["used"] = (cur["credits"] if copilot else cur["tokens"]) or 0
    data = {"generatedAt": now_utc().isoformat(), "refreshSeconds": a.refresh, "tool": tool, "live": bool(a.live or load_json(os.path.join(root, STATE, "dashboard.json"), {}).get("hooks")),
            "renderer": "ocpf-dashboard.py", "app": app_facts(root),
            "framework": {"edition": edition, "version": fw.get("runbookVersion"), "alMcp": "connected" if fw.get("alMcp") else "unknown"},
            "phases": phases, "steps": steps, "current": current, "totals": tot, "estimate": est, "models": models, "roles": rl, "waiting": waiting, "project": project,
            "events": recent_events(root), "pricing": {"source": (pricing.get("aiCredit") or {}).get("source") if copilot else ", ".join(sorted({v.get("source", "") for v in (pricing.get("perMillionTokens") or {}).values() if v.get("source")})),
                        "fetchedAt": pricing.get("fetchedAt"), "usdPerCredit": (pricing.get("aiCredit") or {}).get("usd")},
            "notes": notes, "toast": a.toast}
    # View Project Documents: the documents by folder (per-document sidecars) and the approval lines read from them; the newest
    # package for the Download latest .app link in the Project completed box
    data["docs"] = docs_index(root)
    appr = approvals(root); data["approvals"] = appr
    data["helpSite"] = help_site(root)
    pkg = package_info(root); data["package"] = pkg
    data["progress"] = progress(root, current if current else None, edition, appr, pkg)  # the within-step progress bar (Ops § Dashboard → 7)
    return data

# Every theme is rendered on every run (one data build, one extra file write), so the human switches by opening the
# other page; the footer selector on each page just navigates. `theme` in dashboard.json only says which page --open opens.
THEMES = {"brand": ("dashboard.html", "ProjectDashboard.html"), "f1": ("dashboard-f1.html", "ProjectDashboard-f1.html")}

def render(root, data):
    data["dataUrl"] = "ocpfFramework/state/dashboard-data.js"  # the pages pull this sidecar and repaint in place (no full reload)
    outs = {}; first_payload = None
    for theme, (fname, outname) in THEMES.items():
        tpl = None
        for cand in (os.path.join(HERE, "..", "templates", fname), os.path.join(root, "ocpfFramework", "scripts", fname)):
            if os.path.isfile(cand): tpl = read(cand); break
        if not tpl:
            if theme == "brand": sys.exit("error: dashboard.html template not found beside the script (templates/dashboard.html) or in ocpfFramework/scripts/")
            continue  # an older scripts/ folder without this theme's template: skip it
        data["theme"] = theme
        payload = json.dumps(data, ensure_ascii=False, default=str).replace("</", "<\\/")
        if first_payload is None: first_payload = payload
        out = os.path.join(root, outname)  # project root: tracked, beside ProjectProgress.md
        with open(out + ".tmp", "w", encoding="utf-8") as f: f.write(tpl.replace("/*__OCPF_DATA__*/null", payload, 1))
        os.replace(out + ".tmp", out); outs[theme] = out
    side = os.path.join(root, STATE, "dashboard-data.js")  # per developer, gitignored with the rest of state/
    with open(side + ".tmp", "w", encoding="utf-8") as f: f.write("window.__ocpfData=" + first_payload + ";")
    os.replace(side + ".tmp", side)
    return outs

def open_in_browser(path):
    try:
        if sys.platform == "darwin": subprocess.Popen(["open", path])
        elif os.name == "nt": os.startfile(path)  # type: ignore[attr-defined]
        else: subprocess.Popen(["xdg-open", path])
        return True
    except OSError: return False

def main():
    ap = argparse.ArgumentParser(description="Render the OCPF project dashboard (ProjectDashboard.html at the project root).")
    ap.add_argument("--project", default=".")
    ap.add_argument("--open", action="store_true", help="open the rendered page in the default browser (first creation)")
    ap.add_argument("--quiet", action="store_true")
    ap.add_argument("--refresh", type=int, default=30, help="seconds between the page's own reloads (0 = never)")
    ap.add_argument("--toast", help="a one-line notice to show on this render")
    ap.add_argument("--live", action="store_true", help="mark the page as hook-refreshed (the dashboard skill sets this once hooks are installed)")
    ap.add_argument("--waiting-json", help="hook input of an AskUserQuestion / askQuestions / ask_user call ('-' = stdin): record the open question and render; a Copilot hook input whose toolName is another tool records nothing")
    ap.add_argument("--clear-waiting", nargs="?", const="1", metavar="JSON", help="hook: the question was answered; with a Copilot hook input ('-' = stdin) only when its toolName is ask_user or askQuestions")
    ap.add_argument("--close-project", action="store_true", help="the human said the project is done: stamp projectClosedAt in usage.json, close any open window, and render the completed state")
    ap.add_argument("--event", nargs=2, metavar=("WHO", "TEXT"), help="append a feed event and render")
    ap.add_argument("--theme", choices=sorted(THEMES), help="open this theme's page on THIS call only (--open), and record it as the human's stated preference in ocpfFramework/state/dashboard.json; without it --open always opens the OnlyBCFans page; every theme is rendered on every run")
    ap.add_argument("--throttle", type=int, default=0, metavar="SECONDS", help="hook on every tool call: skip the render when the page is younger than this (unless a question, answer, or event is being recorded)")
    a = ap.parse_args()
    root = os.path.abspath(a.project)
    if not os.path.isdir(os.path.join(root, "ocpfFramework")):
        if a.quiet: return
        sys.exit(f"error: {root} has no ocpfFramework/ folder — not an OCPF project")
    os.makedirs(os.path.join(root, STATE), exist_ok=True)
    # Hook input. Claude Code's hooks are matched on the tool name by the harness (matcher AskUserQuestion), so the input is the
    # question itself. Copilot's hooks (CLI and Chat) have no matcher: every tool call arrives, as {"toolName", "toolArgs", ...},
    # and the script decides — ask_user / askQuestions record or clear the question; any other tool is a plain render, throttled.
    def hook_input(v):
        if v == "-":
            try: v = sys.stdin.read()
            except OSError: v = "{}"
        try: inp = json.loads(v) if isinstance(v, str) else {}
        except ValueError: inp = {}
        return inp if isinstance(inp, dict) else {}
    def tool_matches(inp):  # None = no Copilot toolName (Claude Code's input carries tool_name, already matched by the harness); True / False = Copilot's toolName
        name = inp.get("toolName")
        if not isinstance(name, str): return None
        return bool(re.search(r"ask_user|askQuestions|AskUserQuestion", name))
    w_inp = hook_input(a.waiting_json) if a.waiting_json else None
    if w_inp is not None and tool_matches(w_inp) is False: a.waiting_json = None; w_inp = None
    c_inp = hook_input(a.clear_waiting) if a.clear_waiting and a.clear_waiting != "1" else None
    if c_inp is not None and tool_matches(c_inp) is False: a.clear_waiting = None
    if a.throttle and not (a.waiting_json or a.clear_waiting or a.event or a.open or a.close_project):
        out_ = os.path.join(root, "ProjectDashboard.html")
        try:
            if os.path.isfile(out_) and (time.time() - os.path.getmtime(out_)) < a.throttle: return
            if os.path.isfile(out_ + ".tmp") and (time.time() - os.path.getmtime(out_ + ".tmp")) < 120: return  # a render is in progress
        except OSError: pass
    if w_inp is not None:
        inp = w_inp
        ti = inp.get("tool_input") or inp.get("toolInput") or inp.get("toolArgs") or inp
        if isinstance(ti, str):  # Copilot may pass toolArgs as a JSON string
            try: ti = json.loads(ti)
            except ValueError: ti = {}
        if not isinstance(ti, dict): ti = {}
        qs = ti.get("questions") or ([ti] if ti.get("question") else [])
        if not qs and (ti.get("message") or ti.get("requestedSchema")):  # Copilot CLI ask_user: one question, its options the enum of the first property
            props = ((ti.get("requestedSchema") or {}).get("properties") or {}) if isinstance(ti.get("requestedSchema"), dict) else {}
            first = next((v for v in props.values() if isinstance(v, dict)), {})
            qs = [{"question": ti.get("message") or first.get("title") or first.get("description"), "options": [{"label": str(e)} for e in (first.get("enum") or [])]}]
        if qs:
            q = qs[0]
            opts = [{"label": o.get("label") or o.get("title") or str(o), "description": o.get("description", "")} if isinstance(o, dict) else {"label": str(o), "description": ""} for o in (q.get("options") or [])]
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
    if a.close_project: close_project(root)
    dj = load_json(os.path.join(root, STATE, "dashboard.json"), {})
    if a.live or a.theme:
        if a.live: dj["hooks"] = True
        if a.theme: dj["theme"] = a.theme
        dj["theme"] = dj.get("theme") or "brand"
        with open(os.path.join(root, STATE, "dashboard.json"), "w", encoding="utf-8") as f: json.dump(dj, f, indent=2)
    data = build(root, a)
    data["theme"] = (dj.get("theme") or "brand")  # recorded preference, informational; every theme is rendered regardless
    outs = render(root, data)
    # --open always opens the OnlyBCFans page. The F1 page opens only when --theme f1 is passed on this very
    # call, i.e. when the human asked for it by name now; a remembered preference never decides it (v5.6.0.0).
    out = outs.get(a.theme) if a.theme in THEMES else outs["brand"]
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
