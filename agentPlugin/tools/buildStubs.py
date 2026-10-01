#!/usr/bin/env python3
"""Rebuild, or check, the step stubs in the two core runbooks from their step files.

A stub in the core runbook keeps two hand-written paragraphs (the "Read <step file> in full" line
and "**In one line:**") and carries the step file's **Role**, **Outputs**, and **Exit gate**
paragraphs VERBATIM, so the core can never drift from the step it summarizes.

    agentPlugin/tools/buildStubs.py            rewrite the stubs from the step files
    agentPlugin/tools/buildStubs.py --check    exit 1 if any stub's copied paragraphs differ
"""
import os, re, sys
root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
EDITIONS = [
    ("fullVersion/BC_App_Build_Routine_Agent.md", "fullVersion/steps", r"^## ((?:PRE-0[12])|(?:0[1-9])|(?:1[0-2])) — "),
    ("liteVersion/LITE_BC_App_Build_Routine_Agent.md", "liteVersion/steps", r"^## (STEP [1-7]) — "),
]
COPIED = ("**Role:**", "**Outputs:**", "**Exit gate:**")

def paragraphs(lines):
    out, cur = [], []
    for l in lines:
        if l.strip() == "":
            if cur: out.append(cur); cur = []
        else: cur.append(l)
    if cur: out.append(cur)
    return out

def step_paragraphs(path):
    body = open(path, encoding="utf-8").read().split("\n")
    found = {}
    for p in paragraphs(body):
        for key in COPIED:
            if p[0].startswith(key) and key not in found: found[key] = p
    return found

def run(check):
    bad = 0
    for core_rel, steps_rel, pat in EDITIONS:
        core = os.path.join(root, core_rel); lines = open(core, encoding="utf-8").read().split("\n")
        heads = [(i, m.group(1).replace("STEP ", "STEP-")) for i, l in enumerate(lines) if (m := re.match(pat, l))]
        new = []; cursor = 0
        for n, (i, sid) in enumerate(heads):
            end = next((j for j in range(i + 1, len(lines)) if re.match(r"^(## |# |---$)", lines[j])), len(lines))
            new.extend(lines[cursor:i])
            block = lines[i + 1:end]
            paras = paragraphs(block)
            kept = [p for p in paras if p[0].startswith("**Read `") or p[0].startswith("**In one line:**")]
            copied_now = {k: p for p in paras for k in COPIED if p[0].startswith(k)}
            want = step_paragraphs(os.path.join(root, steps_rel, f"{sid}.md"))
            for k in COPIED:
                if (k in want) != (k in copied_now) or (k in want and want[k] != copied_now[k]):
                    bad += 1
                    if check: print(f"STALE stub {sid} in {core_rel}: {k} differs from {steps_rel}/{sid}.md", file=sys.stderr)
            stub = [lines[i], ""]
            for p in kept: stub.extend(p); stub.append("")
            for k in COPIED:
                if k in want: stub.extend(want[k]); stub.append("")
            new.extend(stub)
            cursor = end
        new.extend(lines[cursor:])
        if not check:
            open(core, "w", encoding="utf-8").write("\n".join(new)); print(f"stubs rebuilt: {core_rel} ({len(heads)} steps)")
    if check:
        if bad: print(f"{bad} stub paragraph(s) differ from their step files. Run agentPlugin/tools/buildStubs.py.", file=sys.stderr); sys.exit(1)
        print("stubs match their step files")

if __name__ == "__main__":
    run("--check" in sys.argv)
