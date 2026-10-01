#!/usr/bin/env python3
"""OCPF BC Agentic Development Framework — usage and cost per step.

Two sources, chosen by "aiTool" in ocpfFramework/state/usage.json (or --tool):

  claude-code   tokens by type, per model, from Claude Code's session transcripts (below).
  copilot-chat  AI credits, per model, from the chat session files GitHub Copilot Chat in VS Code
                keeps in the workspace storage folder — sub-agents included, 1 AI credit priced
                from pricing.json's "aiCredit" entry. Copilot Chat records no token totals by
                type, so the Copilot table has credit columns, not token columns. See COPILOT.

Claude Code: reads Claude Code's session transcripts for a project, dedupes API responses by requestId,
includes sub-agent sidechains, attributes each response to the framework step whose window in
ocpfFramework/state/usage.json contains its timestamp, prices it from
ocpfFramework/state/pricing.json, and prints the usage table (Markdown) or JSON — one row per
(step, model), never one row per step. Nothing here is estimated: a missing transcript, window, or
price is reported as such. Ops § Usage & Cost in the Operations Guide is the specification.

    python3 ocpf-usage.py --project /path/to/project [--json] [--step 03]
                          [--usage ocpfFramework/state/usage.json]
                          [--pricing ocpfFramework/state/pricing.json]
                          [--transcripts <dir>]
    python3 ocpf-usage.py --project /path/to/project --calibrate
    python3 ocpf-usage.py --project /path/to/project --step 03 [--tool copilot-chat]
                          [--sessions <chatSessions dir>] [--session-credits 3714.7]

COPILOT. VS Code writes each chat session as an operation log,
<user data>/User/workspaceStorage/<hash>/chatSessions/<id>.jsonl; every turn carries its model,
its start time, and "copilotCredits" — the turn's running total, the sub-agents' credits folded in
(each sub-agent call also carries its own model and credits). The sum over a session's turns is the
"Session Cost" of the Session Info popover. The format is VS Code's own, not a documented
interface: when it can't be read, pass the popover's figure with --session-credits and the row is
recorded from that. A turn can run across several steps, so steps are separated by CHECKPOINTS, not
by turn start times: closing a step (--step <id>) stores the cumulative totals in usage.json, and a
step's row is the difference between its checkpoint and the one before.

--calibrate (project close, Full Step 12 / Lite Step 7) writes the calibration export the
AI Effort Estimate reads on the next project: ~/.ocpf/calibration/<project>-<date>.json with,
per step and per model, tokens by type, elapsed time, turns, decisions, sub-agent calls, and the
object counts by type read from docs/1-define/ObjectRegister.md (Full) or the object table in
docs/2-design/DesignDoc.md (Lite). It prints the path it wrote.
"""
import argparse, glob, json, os, re, sys
from collections import defaultdict
from datetime import datetime, timezone

STATE = os.path.join("ocpfFramework", "state")

def parse_ts(s):
    if not s: return None
    try:
        return datetime.fromisoformat(s.replace("Z", "+00:00")).astimezone(timezone.utc)
    except ValueError:
        return None

def project_key(path):
    path = os.path.abspath(path)
    return path.replace("\\", "-").replace("/", "-").replace(":", "-")

def load_json(path, default):
    try:
        with open(path, encoding="utf-8") as f: return json.load(f)
    except FileNotFoundError: return default
    except json.JSONDecodeError as e:
        sys.exit(f"error: {path} is not valid JSON ({e})")

def n(v):
    """int of a possibly-null counter."""
    try: return int(v or 0)
    except (TypeError, ValueError): return 0

def windows_from(usage):
    """(step, start, end) windows in start order; an open window ends where the next one starts."""
    wins = []
    for s in usage.get("steps", []):
        a, b = parse_ts(s.get("startedAt")), parse_ts(s.get("completedAt"))
        if a and s.get("step"): wins.append([s["step"], a, b])
    wins.sort(key=lambda w: w[1])
    for i, w in enumerate(wins):
        if w[2] is None and i + 1 < len(wins): w[2] = wins[i + 1][1]
    return [tuple(w) for w in wins]

def step_for(ts, wins):
    """The latest-starting window that contains ts; closed windows end inclusive."""
    hit = None
    if ts is None: return "Unattributed"
    for step, a, b in wins:
        if ts >= a and (b is None or ts <= b): hit = step
    return hit or "Unattributed"

def price(row, rates):
    r = rates.get(row["model"])
    if not r: return None
    m = 1_000_000
    unsplit = max(0, row["cacheWrite"] - row["cache5m"] - row["cache1h"])   # no TTL breakdown: 5-minute rate
    return (row["input"] * r.get("input", 0) + row["output"] * r.get("output", 0)
            + (row["cache5m"] + unsplit) * r.get("cacheWrite5m", 0) + row["cache1h"] * r.get("cacheWrite1h", 0)
            + row["cacheRead"] * r.get("cacheRead", 0)) / m

def object_counts(root, edition):
    """Objects by type from the Object Register (Full) or the Design Doc's object table (Lite).

    Reads every Markdown table whose header has an ID column and a Type column, keyed by (type, ID)
    — BC IDs are unique per object type — so an object listed in two tables counts once. Placeholder rows (an ID starting with '<', or empty)
    are skipped. Returns {"source", "byType", "total"} plus a "note" when nothing could be read.
    """
    candidates = [("full", os.path.join("docs", "1-define", "ObjectRegister.md")),
                  ("lite", os.path.join("docs", "2-design", "DesignDoc.md"))]
    candidates.sort(key=lambda c: c[0] != (edition or "full"))
    clean = lambda cell: re.sub(r"[`*]", "", cell).strip()
    for _, rel in candidates:
        path = os.path.join(root, rel)
        if not os.path.isfile(path): continue
        by_id = {}
        lines = open(path, encoding="utf-8").read().split("\n")
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            if line.startswith("|") and i + 1 < len(lines) and re.match(r"^\|[\s:|-]+\|$", lines[i + 1].strip()):
                header = [clean(c).lower() for c in line.strip("|").split("|")]
                try:
                    id_col = header.index("id"); type_col = header.index("type")
                except ValueError:
                    i += 1; continue
                i += 2
                while i < len(lines) and lines[i].strip().startswith("|"):
                    cells = [clean(c) for c in lines[i].strip().strip("|").split("|")]
                    if len(cells) > max(id_col, type_col):
                        oid, otype = cells[id_col], cells[type_col]
                        if oid and not oid.startswith("<") and otype and not otype.startswith("<"):
                            by_id[(otype, oid)] = otype
                    i += 1
                continue
            i += 1
        if by_id:
            by_type = defaultdict(int)
            for t in by_id.values(): by_type[t] += 1
            return {"source": rel.replace(os.sep, "/"), "byType": dict(sorted(by_type.items())), "total": len(by_id)}
    return {"source": None, "byType": {}, "total": 0,
            "note": "no object table with ID and Type columns found in docs/1-define/ObjectRegister.md or docs/2-design/DesignDoc.md"}


# ───────────────────────────── GitHub Copilot Chat in VS Code ─────────────────────────────

ALL_MODELS = "all models (Session Info popover)"

def vscode_storage_roots():
    home = os.path.expanduser("~")
    if sys.platform == "darwin": bases = [os.path.join(home, "Library", "Application Support")]
    elif os.name == "nt": bases = [os.environ.get("APPDATA") or os.path.join(home, "AppData", "Roaming")]
    else: bases = [os.environ.get("XDG_CONFIG_HOME") or os.path.join(home, ".config")]
    out = []
    for b in bases:
        for product in ("Code", "Code - Insiders", "VSCodium"):
            d = os.path.join(b, product, "User", "workspaceStorage")
            if os.path.isdir(d): out.append(d)
    return out

def uri_to_path(uri):
    from urllib.parse import urlparse, unquote
    if not isinstance(uri, str): return None
    u = urlparse(uri)
    if u.scheme != "file": return None
    path = unquote(u.path)
    if re.match(r"^/[A-Za-z]:", path): path = path[1:]
    return path

def same_path(a, b):
    norm = lambda x: os.path.normcase(os.path.realpath(x)).rstrip("\\/")
    a, b = norm(a), norm(b)
    return a == b or a.lower() == b.lower()

def session_dirs_for(root):
    """chatSessions folders of every VS Code workspace that is this project folder."""
    dirs = []
    for store in vscode_storage_roots():
        for ws in sorted(glob.glob(os.path.join(store, "*", "workspace.json"))):
            try: meta = json.load(open(ws, encoding="utf-8"))
            except (OSError, json.JSONDecodeError): continue
            folders = [uri_to_path(meta.get("folder"))]
            wsfile = uri_to_path(meta.get("workspace"))
            if wsfile and os.path.isfile(wsfile):
                try:
                    for f in json.load(open(wsfile, encoding="utf-8")).get("folders", []):
                        fp = f.get("path")
                        if fp: folders.append(fp if os.path.isabs(fp) else os.path.join(os.path.dirname(wsfile), fp))
                except (OSError, json.JSONDecodeError): pass
            if any(f and same_path(f, root) for f in folders):
                d = os.path.join(os.path.dirname(ws), "chatSessions")
                if os.path.isdir(d): dirs.append(d)
    return dirs

def replay(path):
    """The session's state, rebuilt from VS Code's operation log (kind 0 = initial, 1 = set, 2 = append)."""
    if path.endswith(".json"):
        with open(path, encoding="utf-8", errors="replace") as f: return json.load(f)
    state = None
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            try: o = json.loads(line)
            except json.JSONDecodeError: continue
            kind, k, v = o.get("kind"), o.get("k") or [], o.get("v")
            if kind == 0: state = v; continue
            if state is None or not k: continue
            cur = state
            try:
                for key in k[:-1]:
                    if isinstance(cur, list):
                        while len(cur) <= key: cur.append({})
                        if cur[key] is None: cur[key] = {}
                        cur = cur[key]
                    else:
                        if cur.get(key) is None: cur[key] = {}
                        cur = cur[key]
                last = k[-1]
                if kind == 1:
                    if isinstance(cur, list):
                        while len(cur) <= last: cur.append(None)
                    cur[last] = v
                elif kind == 2:
                    if isinstance(cur, list):
                        while len(cur) <= last: cur.append(None)
                        tgt = cur[last]
                    else: tgt = cur.get(last)
                    if not isinstance(tgt, list):
                        tgt = []; cur[last] = tgt
                    if o.get("i") is not None: del tgt[o["i"]:]
                    tgt.extend(v if isinstance(v, list) else [v])
            except (TypeError, KeyError, IndexError):
                continue
    return state

def num(v):
    try:
        f = float(v)
        return f if f == f and f not in (float("inf"), float("-inf")) else 0.0
    except (TypeError, ValueError): return 0.0

def copilot_turns(files, since, notes):
    """One fact sheet per turn: start time, model, the turn's own credits, its sub-agent calls, its questions."""
    turns = []; unread = 0; session_reported = 0.0; summed = 0.0
    for f in files:
        try: state = replay(f)
        except (OSError, json.JSONDecodeError): state = None
        if not isinstance(state, dict) or not isinstance(state.get("requests"), list):
            unread += 1; continue
        reported = 0.0; total = 0.0
        for r in state["requests"]:
            if not isinstance(r, dict): continue
            ms = r.get("timestamp")
            ts = datetime.fromtimestamp(ms / 1000, timezone.utc) if isinstance(ms, (int, float)) else None
            credits = num(r.get("copilotCredits")); total += credits
            reported = max(reported, num(r.get("sessionCopilotCredits")))
            subs = []; asks = 0
            for part in r.get("response") or []:
                if not isinstance(part, dict) or part.get("kind") != "toolInvocationSerialized": continue
                if "askQuestions" in str(part.get("toolId") or ""): asks += 1
                t = part.get("toolSpecificData")
                if isinstance(t, dict) and t.get("kind") == "subagent":
                    subs.append((t.get("modelId") or t.get("modelName") or "unknown", num(t.get("credits"))))
            if since and ts and ts < since: continue
            sub_total = sum(c for _, c in subs)
            own = credits - sub_total
            if own < -0.005:          # a VS Code that doesn't fold sub-agents into the turn
                own = credits
            turns.append({"ts": ts, "model": r.get("modelId") or "unknown", "own": max(0.0, own), "subs": subs,
                          "asks": asks, "hidden": bool(r.get("hiddenFromTranscript"))})
        summed += total
        if reported > total + 0.05: session_reported += reported - total
    if unread: notes.append(f"{unread} session file(s) could not be read and were skipped")
    return turns, session_reported

def snapshot(turns, overhead=0.0):
    """Cumulative totals: credits and calls per (model, role), plus the step counters."""
    by = defaultdict(lambda: {"credits": 0.0, "calls": 0})
    for t in turns:
        g = by[t["model"] + "|main"]; g["credits"] += t["own"]; g["calls"] += 1
        for m, c in t["subs"]:
            g = by[m + "|sub-agent"]; g["credits"] += c; g["calls"] += 1
    if overhead > 0.05:
        by["between turns (compaction)|session"]["credits"] += overhead
    return {"byModel": {k: {"credits": round(v["credits"], 4), "calls": v["calls"]} for k, v in by.items()},
            "turns": sum(1 for t in turns if not t["hidden"]),
            "decisions": sum(t["asks"] for t in turns),
            "subAgentCalls": sum(len(t["subs"]) for t in turns)}

def snap_total(s):
    return sum(v["credits"] for v in s["byModel"].values())

def diff(cur, prev, notes, label):
    """cur − prev. A change of source (session files ↔ popover reading) is compared on totals only."""
    if (cur.get("source") or "sessions") != (prev.get("source") or "sessions") and prev["byModel"]:
        d = snap_total(cur) - snap_total(prev)
        by = {ALL_MODELS + "|all": {"credits": d, "calls": 0}}
    else:
        by = {}
        for k in set(cur["byModel"]) | set(prev["byModel"]):
            c = cur["byModel"].get(k, {"credits": 0, "calls": 0}); p = prev["byModel"].get(k, {"credits": 0, "calls": 0})
            by[k] = {"credits": c["credits"] - p["credits"], "calls": c["calls"] - p["calls"]}
    if any(v["credits"] < -0.05 for v in by.values()):
        notes.append(f"{label}: the recorded total went down — a chat session was deleted or cleared; negative differences are shown as 0")
    by = {k: {"credits": max(0.0, v["credits"]), "calls": max(0, v["calls"])} for k, v in by.items()
          if v["credits"] > 0.00005 or v["calls"] > 0}
    return {"byModel": by, "turns": max(0, cur["turns"] - prev["turns"]),
            "decisions": max(0, cur["decisions"] - prev["decisions"]),
            "subAgentCalls": max(0, cur["subAgentCalls"] - prev["subAgentCalls"])}

def add(a, b):
    by = {k: dict(v) for k, v in a["byModel"].items()}
    for k, v in b["byModel"].items():
        g = by.setdefault(k, {"credits": 0.0, "calls": 0}); g["credits"] += v["credits"]; g["calls"] += v["calls"]
    return {"byModel": by, "turns": a["turns"] + b["turns"], "decisions": a["decisions"] + b["decisions"],
            "subAgentCalls": a["subAgentCalls"] + b["subAgentCalls"]}

EMPTY = {"byModel": {}, "turns": 0, "decisions": 0, "subAgentCalls": 0}

def elapsed_for(step, usage, wins):
    elapsed = None
    for s in usage.get("steps", []):
        a = parse_ts(s.get("startedAt"))
        if s.get("step") == step and a:
            end = next((w[2] for w in wins if w[0] == step and w[1] == a), None) or datetime.now(timezone.utc)
            elapsed = (elapsed or 0) + max(0, (end - a).total_seconds())
    return elapsed

def copilot_main(a, root, usage, usage_path, pricing):
    notes = []
    wins = windows_from(usage)
    if not wins: notes.append(f"no step windows in {os.path.join(STATE, 'usage.json')} — everything is Unattributed")
    since = None      # every turn of the project's sessions counts, so the Total is the popover's Session Cost
    cp_state = usage.setdefault("copilot", {})
    cps = cp_state.setdefault("checkpoints", [])
    now = datetime.now(timezone.utc)

    manual = a.session_credits is not None
    dirs = [a.sessions] if a.sessions else (cp_state.get("sessionDirs") or session_dirs_for(root))
    dirs = [os.path.expanduser(d) for d in dirs if d and os.path.isdir(os.path.expanduser(d))]
    files = sorted(f for d in dirs for f in glob.glob(os.path.join(d, "*.json*")))
    turns = []; overhead = 0.0
    if manual:
        current = {"byModel": {ALL_MODELS + "|all": {"credits": round(float(a.session_credits), 4), "calls": 0}},
                   "turns": 0, "decisions": 0, "subAgentCalls": 0, "source": "popover"}
    else:
        if not files:
            sys.exit("error: no Copilot Chat session files found for this project folder"
                     + (f" in {', '.join(dirs)}" if dirs else " in VS Code's workspace storage")
                     + " — pass --sessions <chatSessions folder>, or read Session Cost in the Session Info popover"
                       " (the context window control in the chat input) and pass it with --session-credits <n>")
        turns, overhead = copilot_turns(files, since, notes)
        current = snapshot(turns, overhead); current["source"] = "sessions"
        cp_state["sessionDirs"] = dirs

    def before(t):
        """What the session files hold for turns that started before t (complete by now, so stable)."""
        return snapshot([x for x in turns if x["ts"] and x["ts"] < t])

    # closing (or refreshing) a step: store the cumulative totals
    if a.step and not a.calibrate:
        win = [w for w in wins if w[0] == a.step]
        if not win:
            sys.exit(f"error: step {a.step} has no startedAt in {os.path.join(STATE, 'usage.json')} — write the window first")
        cp = dict(current); cp["step"] = a.step; cp["at"] = now.strftime("%Y-%m-%dT%H:%M:%SZ")
        if cps and cps[-1].get("step") == a.step and parse_ts(cps[-1].get("at")) and parse_ts(cps[-1]["at"]) >= win[-1][1]:
            cps[-1] = cp
        else:
            cps.append(cp)
        with open(usage_path, "w", encoding="utf-8") as f:
            json.dump(usage, f, indent=2, ensure_ascii=False); f.write("\n")

    # per-step totals
    per = {}; order = []
    def credit(step, d):
        if not d["byModel"] and not d["turns"]: return
        if step not in per: per[step] = dict(EMPTY, byModel={}); order.append(step)
        per[step] = add(per[step], d)
    if not cps:
        notes.append("no checkpoints yet — attributed by each turn's start time; a turn that ran across steps counts in the step it started in")
        for step in dict.fromkeys([w[0] for w in wins] + ["Unattributed"]):
            credit(step, snapshot([x for x in turns if step_for(x["ts"], wins) == step]))
        credit("between turns", snapshot([], overhead))
    else:
        first = cps[0]
        first_start = next((w[1] for w in wins if w[0] == first.get("step")), None)
        base = dict(EMPTY, byModel={})
        if first_start and turns:
            base = before(first_start); base["source"] = "sessions"
            for step in dict.fromkeys(["Unattributed"] + [w[0] for w in wins]):
                early = [x for x in turns if x["ts"] and x["ts"] < first_start and step_for(x["ts"], wins) == step]
                if early: credit(step, snapshot(early))
            if per: notes.append(f"work before step {first.get('step')} has no checkpoint — attributed by each turn's start time; Unattributed is work that started outside every step window")
        prev = base
        for cp in cps:
            credit(cp.get("step"), diff(cp, prev, notes, f"step {cp.get('step')}")); prev = cp
        tail = diff(current, prev, notes, "since the last checkpoint")
        if tail["byModel"]:
            open_step = next((w[0] for w in reversed(wins) if w[1] >= (parse_ts(prev.get("at")) or w[1]) or w[2] is None), None)
            credit((open_step + " (open)") if open_step else "Unattributed", tail)

    usd = (pricing.get("aiCredit") or {}).get("usd")
    out = []
    for step in order:
        key = step.replace(" (open)", "")
        if a.step and key != a.step: continue
        el = elapsed_for(key, usage, wins)
        d = per[step]
        for k in sorted(d["byModel"], key=lambda k: (k.split("|")[1] != "main", -d["byModel"][k]["credits"])):
            model, role = k.rsplit("|", 1); v = d["byModel"][k]
            out.append({"step": step, "model": model, "role": role, "aiCredits": round(v["credits"], 2), "calls": v["calls"],
                        "input": None, "output": None, "cacheWrite": None, "cacheRead": None, "requests": v["calls"],
                        "costUsd": round(v["credits"] * usd, 4) if usd is not None else None,
                        "elapsedSeconds": round(el) if el is not None else None,
                        "turns": d["turns"], "decisions": d["decisions"], "subAgentCalls": d["subAgentCalls"], "webRequests": 0})
    if a.step and not out:
        notes.append(f"no credits were recorded inside step {a.step} — check its window in {os.path.join(STATE, 'usage.json')}, and that the chat session wasn't deleted")
    if usd is None:
        notes.append("pricing.json has no \"aiCredit\" entry — fetch https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing and write { \"aiCredit\": { \"usd\": <value>, \"source\": <url> } }")
    if a.calibrate:
        print(calibrate(root, usage, pricing, {}, out, notes)); return
    src = (pricing.get("aiCredit") or {}).get("source") or "none fetched"
    if a.json:
        print(json.dumps({"aiTool": "copilot-chat", "sessionDirs": dirs, "files": len(files), "usdPerAiCredit": usd,
                          "pricingSource": src, "pricingFetchedAt": pricing.get("fetchedAt"),
                          "sessionTotalCredits": round(snap_total(current), 1), "rows": out, "notes": notes}, indent=2, default=str)); return
    def hm(sec):
        if sec is None: return "n/a — no timestamps"
        h, m_ = divmod(int(sec) // 60, 60); return f"{h}h {m_:02d}m"
    print("| Step | Model(s) | AI credits | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |")
    print("|---|---|---|---|---|---|---|---|---|---|")
    tc = 0.0; tcost = 0.0; unpriced = False; shown = set()
    for r in out:
        cost = f"{r['costUsd']:.2f}" if r["costUsd"] is not None else "price unknown"
        if r["costUsd"] is None: unpriced = True
        else: tcost += r["costUsd"]
        tc += r["aiCredits"]
        first = r["step"] not in shown; shown.add(r["step"])
        el, tu, de, sa = (hm(r["elapsedSeconds"]), r["turns"], r["decisions"], r["subAgentCalls"]) if first else ("〃", "〃", "〃", "〃")
        note = {"main": f"main, {r['calls']} turn(s)", "sub-agent": f"sub-agent, {r['calls']} call(s)",
                "session": "billed between turns", "all": "read from the popover by the human — no model breakdown"}.get(r["role"], r["role"])
        print(f"| {r['step']} | {r['model']} | {r['aiCredits']:,.1f} | {cost} | {el} | {tu} | {de} | {sa} |  | {note} |")
    print(f"| **Total** |  | {tc:,.1f} | {tcost:.2f}{' + unpriced' if unpriced else ''} |  |  |  |  |  |  |")
    where = "the Session Info popover, read by the human" if manual else f"{len(files)} chat session file(s) in {', '.join(dirs)}"
    print(f"\n*AI credits as GitHub Copilot Chat recorded them, sub-agents included; Copilot Chat records no token totals by type. "
          f"1 AI credit = {('$' + format(usd, 'g')) if usd is not None else 'price unknown'}: {src}, read {pricing.get('fetchedAt', 'n/a')}. Source: {where}.*")
    for note_ in notes: print(f"*Note: {note_}*")

def main():
    ap = argparse.ArgumentParser(description="OCPF usage and cost per step: tokens from Claude Code's transcripts, AI credits from Copilot Chat's session files.")
    ap.add_argument("--project", default=".")
    ap.add_argument("--usage", help=f"override the default {os.path.join(STATE, 'usage.json')}")
    ap.add_argument("--pricing", help=f"override the default {os.path.join(STATE, 'pricing.json')}")
    ap.add_argument("--transcripts", help="override the transcript folder (default: usage.json transcriptDir, else ~/.claude/projects/<key>)")
    ap.add_argument("--json", action="store_true"); ap.add_argument("--step")
    ap.add_argument("--calibrate", action="store_true",
                    help="project close: write ~/.ocpf/calibration/<project>-<date>.json and print its path")
    ap.add_argument("--tool", choices=["claude-code", "copilot-chat"],
                    help="override usage.json's aiTool")
    ap.add_argument("--sessions", help="Copilot: the chatSessions folder (default: found from VS Code's workspace storage)")
    ap.add_argument("--session-credits", type=float, dest="session_credits",
                    help="Copilot: the cumulative Session Cost read from the Session Info popover, when the session files can't be read")
    a = ap.parse_args()
    if a.calibrate and a.step:
        sys.exit("error: --calibrate exports the whole project; run it without --step")
    root = os.path.abspath(a.project)
    usage_path = a.usage or os.path.join(root, STATE, "usage.json")
    pricing_path = a.pricing or os.path.join(root, STATE, "pricing.json")
    usage = load_json(usage_path, {})
    pricing = load_json(pricing_path, {})
    rates = pricing.get("perMillionTokens", {})
    tool = a.tool or usage.get("aiTool") or "claude-code"
    if tool == "copilot-cli":
        sys.exit("error: Copilot CLI isn't measured by this script — read the session's credits in the CLI and pass them with --tool copilot-chat --session-credits <n>")
    if tool == "copilot-chat":
        return copilot_main(a, root, usage, usage_path, pricing)
    tdir = a.transcripts or os.path.expanduser(usage.get("transcriptDir") or
            os.path.join("~", ".claude", "projects", project_key(root)))
    files = sorted(glob.glob(os.path.join(tdir, "*.jsonl")))
    notes = []
    if not files:
        sys.exit(f"error: no transcripts in {tdir} — set transcriptDir in {os.path.join(STATE, 'usage.json')} (ls ~/.claude/projects/)")
    wins = windows_from(usage)
    if not wins: notes.append(f"no step windows in {os.path.join(STATE, 'usage.json')} — everything is Unattributed")

    seen = set(); rows = []; no_rid = 0   # one row per API response
    turns = defaultdict(int); decisions = defaultdict(int); agents = defaultdict(int); web = defaultdict(int)
    for f in files:
        with open(f, encoding="utf-8") as fh:
            for line in fh:
                try: o = json.loads(line)
                except json.JSONDecodeError: continue
                ts = parse_ts(o.get("timestamp"))
                if ts is None: continue
                step = step_for(ts, wins)
                t = o.get("type"); m = o.get("message") or {}
                content = m.get("content")
                blocks = content if isinstance(content, list) else []
                if t == "user" and not o.get("isSidechain"):
                    if not any(isinstance(c, dict) and c.get("type") == "tool_result" for c in blocks):
                        turns[step] += 1
                if t != "assistant": continue
                for c in blocks:
                    if isinstance(c, dict) and c.get("type") == "tool_use":
                        name = c.get("name", "")
                        if name == "AskUserQuestion": decisions[step] += 1
                        if name in ("Agent", "Task"): agents[step] += 1
                u = m.get("usage")
                if not u: continue
                rid = o.get("requestId")
                if not rid: no_rid += 1; continue
                if rid in seen: continue
                seen.add(rid)
                cc = u.get("cache_creation") or {}
                st = u.get("server_tool_use") or {}
                web[step] += n(st.get("web_search_requests")) + n(st.get("web_fetch_requests"))
                rows.append({"step": step, "model": m.get("model") or "unknown", "ts": ts,
                             "input": n(u.get("input_tokens")), "output": n(u.get("output_tokens")),
                             "cacheWrite": n(u.get("cache_creation_input_tokens")),
                             "cache5m": n(cc.get("ephemeral_5m_input_tokens")),
                             "cache1h": n(cc.get("ephemeral_1h_input_tokens")),
                             "cacheRead": n(u.get("cache_read_input_tokens")),
                             "sidechain": bool(o.get("isSidechain"))})
    if no_rid: notes.append(f"{no_rid} assistant line(s) had no requestId and were excluded")
    # aggregate per step, per model
    agg = defaultdict(lambda: {"input": 0, "output": 0, "cacheWrite": 0, "cache5m": 0, "cache1h": 0, "cacheRead": 0,
                               "requests": 0, "cost": 0.0, "priced": True, "first": None, "last": None})
    for r in rows:
        k = (r["step"], r["model"]); g = agg[k]
        for f_ in ("input", "output", "cacheWrite", "cache5m", "cache1h", "cacheRead"): g[f_] += r[f_]
        g["requests"] += 1
        p = price(r, rates)
        if p is None: g["priced"] = False
        else: g["cost"] += p
        g["first"] = r["ts"] if g["first"] is None or r["ts"] < g["first"] else g["first"]
        g["last"] = r["ts"] if g["last"] is None or r["ts"] > g["last"] else g["last"]
    steps_order = [w[0] for w in wins] + ["Unattributed"]
    out = []
    for step in dict.fromkeys(steps_order):
        if a.step and step != a.step: continue
        models = sorted({m for (s, m) in agg if s == step})
        if not models: continue
        elapsed = None
        for s in usage.get("steps", []):
            if s.get("step") == step and parse_ts(s.get("startedAt")):
                end = next((w[2] for w in wins if w[0] == step and w[1] == parse_ts(s["startedAt"])), None) or datetime.now(timezone.utc)
                elapsed = (elapsed or 0) + max(0, (end - parse_ts(s["startedAt"])).total_seconds())
        for mdl in models:
            g = agg[(step, mdl)]
            out.append({"step": step, "model": mdl, "input": g["input"], "output": g["output"],
                        "cacheWrite": g["cacheWrite"], "cacheRead": g["cacheRead"], "requests": g["requests"],
                        "costUsd": round(g["cost"], 4) if g["priced"] else None,
                        "elapsedSeconds": round(elapsed) if elapsed is not None else None,
                        "turns": turns.get(step, 0), "decisions": decisions.get(step, 0),
                        "subAgentCalls": agents.get(step, 0), "webRequests": web.get(step, 0)})
    if a.step and not out:
        notes.append(f"no transcript lines fall inside step {a.step}'s window — check its startedAt/completedAt in {os.path.join(STATE, 'usage.json')}")
    if a.calibrate:
        print(calibrate(root, usage, pricing, rates, out, notes)); return
    if a.json:
        print(json.dumps({"transcriptDir": tdir, "files": len(files), "pricingSource": pricing.get("fetchedAt"),
                          "rows": out, "notes": notes}, indent=2, default=str)); return
    def hm(sec):
        if sec is None: return "n/a — no timestamps"
        h, m_ = divmod(int(sec) // 60, 60); return f"{h}h {m_:02d}m"
    print("| Step | Model(s) | Input | Output | Cache write | Cache read | Cost (USD) | Elapsed | Turns | Decisions | Sub-agent calls | Senior AL dev est. (h) | Notes |")
    print("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    tot = defaultdict(int); tcost = 0.0; unpriced = False; shown = set()
    for r in out:
        cost = f"{r['costUsd']:.2f}" if r["costUsd"] is not None else "price unknown"
        if r["costUsd"] is None: unpriced = True
        else: tcost += r["costUsd"]
        for f_ in ("input", "output", "cacheWrite", "cacheRead"): tot[f_] += r[f_]
        note = f"{r['requests']} requests" + (f", {r['webRequests']} web" if r["webRequests"] else "")
        first = r["step"] not in shown; shown.add(r["step"])
        el, tu, de, sa = (hm(r['elapsedSeconds']), r['turns'], r['decisions'], r['subAgentCalls']) if first else ("〃", "〃", "〃", "〃")
        print(f"| {r['step']} | {r['model']} | {r['input']:,} | {r['output']:,} | {r['cacheWrite']:,} | {r['cacheRead']:,} | {cost} | {el} | {tu} | {de} | {sa} |  | {note} |")
    print(f"| **Total** |  | {tot['input']:,} | {tot['output']:,} | {tot['cacheWrite']:,} | {tot['cacheRead']:,} | {tcost:.2f}{' + unpriced' if unpriced else ''} |  |  |  |  |  |  |")
    src = ", ".join(sorted({v.get('source','') for v in rates.values() if v.get('source')})) or "none fetched"
    print(f"\n*Prices: {src}, read {pricing.get('fetchedAt', 'n/a')}. Transcripts: {tdir} ({len(files)} files).*")
    for note_ in notes: print(f"*Note: {note_}*")

def calibrate(root, usage, pricing, rates, out, notes):
    """Write ~/.ocpf/calibration/<project>-<date>.json from the measured rows; return its path."""
    marker = load_json(os.path.join(root, "ocpfFramework", "framework.json"), {})
    app = load_json(os.path.join(root, "app.json"), {})
    name = app.get("name") or os.path.basename(root)
    edition = marker.get("edition")
    steps = {}
    for r in out:
        s = steps.setdefault(r["step"], {"step": r["step"], "elapsedSeconds": r["elapsedSeconds"], "turns": r["turns"],
                                         "decisions": r["decisions"], "subAgentCalls": r["subAgentCalls"], "models": []})
        entry = {k: r[k] for k in ("model", "input", "output", "cacheWrite", "cacheRead", "requests", "costUsd")}
        if "aiCredits" in r: entry["aiCredits"] = r["aiCredits"]; entry["role"] = r.get("role")
        s["models"].append(entry)
    tot = defaultdict(int); tcost = 0.0; unpriced = False; elapsed = 0; measured_output = 0; credits = 0.0
    has_tokens = any(m["output"] is not None for s in steps.values() for m in s["models"])
    for s in steps.values():
        if s["elapsedSeconds"]:
            elapsed += s["elapsedSeconds"]; measured_output += sum(m["output"] or 0 for m in s["models"])
        for m in s["models"]:
            credits += m.get("aiCredits") or 0
            for k in ("input", "output", "cacheWrite", "cacheRead"): tot[k] += m[k] or 0
            if m["costUsd"] is None: unpriced = True
            else: tcost += m["costUsd"]
    objects = object_counts(root, edition)
    if objects.get("note"): notes = notes + [objects["note"]]
    data = {
        "framework": "OCPF BC Agentic Development Framework", "calibrationSchema": 1,
        "project": name, "projectRoot": root, "edition": edition,
        "runbookVersion": marker.get("runbookVersion"), "pluginVersion": marker.get("pluginVersion"),
        "aiTool": usage.get("aiTool"), "writtenAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "pricing": {"fetchedAt": pricing.get("fetchedAt"),
                    "sources": sorted({v.get("source", "") for v in rates.values() if v.get("source")}
                                      | ({pricing["aiCredit"]["source"]} if (pricing.get("aiCredit") or {}).get("source") else set())),
                    "usdPerAiCredit": (pricing.get("aiCredit") or {}).get("usd")},
        "steps": [steps[k] for k in steps],
        "totals": {"input": tot["input"] if has_tokens else None, "output": tot["output"] if has_tokens else None,
                   "cacheWrite": tot["cacheWrite"] if has_tokens else None,
                   "cacheRead": tot["cacheRead"] if has_tokens else None,
                   "aiCredits": round(credits, 1) if credits else None,
                   "costUsd": round(tcost, 4), "costIncomplete": unpriced,
                   "elapsedSeconds": elapsed},
        "throughput": {"outputTokensPerSecond": round(measured_output / elapsed, 2) if elapsed and has_tokens else None,
                       "basis": "output tokens ÷ elapsed seconds over the steps that have timestamps; the AI Effort Estimate's wall-clock default is 50 when this is null"},
        "objects": objects,
        "notes": notes,
    }
    folder = os.path.expanduser(os.path.join("~", ".ocpf", "calibration"))
    os.makedirs(folder, exist_ok=True)
    slug = re.sub(r"[^A-Za-z0-9._-]+", "-", name).strip("-") or "project"
    path = os.path.join(folder, f"{slug}-{datetime.now(timezone.utc).strftime('%Y-%m-%d')}.json")
    with open(path, "w", encoding="utf-8") as f: json.dump(data, f, indent=2, ensure_ascii=False); f.write("\n")
    return path

if __name__ == "__main__":
    main()
