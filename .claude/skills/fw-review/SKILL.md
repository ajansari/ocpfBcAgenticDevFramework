---
name: fw-review
description: Review changes to this framework repository itself (runbooks, Ops Guide, step files, templates, plugin skills, agents, scripts, dashboard pages, website) with the fw-reviewer agent - Fable 5.1, medium effort, read-only, in the background - then relay its ranked findings and offer to fix them. Not for Business Central apps built with the framework. Use when the user runs /fw-review, says "review this", "have Fable review it", "review the staged work", or asks for a review before a release.
---

# /fw-review — review the framework's own changes

One command instead of "review with Fable 5.1 on medium effort in the background". It scopes
the review, launches the `fw-reviewer` agent (defined in `.claude/agents/fw-reviewer.md`: model
`fable`, effort `medium`, no write tools), carries on with whatever else is in flight, and when
the report arrives relays it and offers to fix.

## 1. Scope — from the arguments

| Invocation | Scope |
|---|---|
| `/fw-review` | **Everything uncommitted**: `git diff HEAD` (staged and unstaged together) plus untracked files from `git status --porcelain`. The usual case under the no-commits-until-release rule. |
| `/fw-review since <ref>` | Commits `<ref>..HEAD` plus everything uncommitted. `<ref>` is a tag (`ocpf-bc-v5.9.4`), a commit, or a date in `git log --since` form (`"2026-10-20 17:00"`). |
| `/fw-review all` | The whole framework as it stands — runbooks, Ops Guide, step files, templates, plugin skills, agents, scripts, both dashboard templates, the website. Big: tell the reviewer to sample where it must and to say what it skipped. |
| `/fw-review files <path> [<path>…]` | Only those files or folders, read in full. |
| `/fw-review release` | Everything since the last release tag (`git describe --tags --abbrev=0 --match 'ocpf-bc-v*'`) plus uncommitted — the pre-release pass. Adds the version-bump and changelog checks explicitly to the brief. |

Anything after the scope words is passed to the reviewer verbatim as *focus* ("focus on the
PowerShell twin", "the help-site offer"). If the scope is empty (clean tree, no commits), say so
and stop — don't launch a review of nothing.

## 2. Fast checks first — no agent needed

Run these yourself before launching, and put their results in the brief so the reviewer doesn't
repeat them:

```
bash agentPlugin/tools/syncPlugin.sh --check          # bundled copies, manifests, site hero version
python3 -m py_compile agentPlugin/ocpf-bc/skills/dashboard/scripts/ocpf-dashboard.py agentPlugin/ocpf-bc/skills/usage/scripts/ocpf-usage.py
```

and, when a version bump is in scope, a grep for the previous version string outside the
changelog history headings and the generated `references/` copies. A failure here is reported
to the user at once (it is cheap to fix now) and still goes in the brief.

## 3. Launch — background, Fable 5.1, medium

Call the `Agent` tool with `subagent_type: "fw-reviewer"`. Do not pass `model` or `effort`: the
agent definition carries both (`fable`, `medium`), which is the point of having it. The agent runs
in the background; tell the user in one line that the review is running and on what scope, then
continue with other work or end the turn — never wait idle, never poll.

The brief (the prompt) is the only context the reviewer has. It contains:

- the scope as a command the reviewer can run itself (`git diff --cached`, `git diff HEAD`,
  `git log <ref>..HEAD --stat`, the file list), and the focus if any;
- what the change is *supposed* to do, in two or three sentences, with the files that carry it —
  from the changelog entry when one exists, otherwise from the conversation;
- the fast-check results from step 2;
- the scratchpad directory for fixtures (the session's scratchpad path), the reminder that `.ps1`
  files run in the foreground with `< /dev/null`, and that the review is read-only;
- the output format: ranked findings, each CONFIRMED or PLAUSIBLE with a failure scenario and a
  proposed fix, then a "checked and found correct" list.

## 4. When the report arrives

Relay it to the user in full substance, ranked, with the verdicts — never summarised down to "a
few issues". Then one options box (AskUserQuestion), recommended first:

- **Fix every CONFIRMED finding, and the PLAUSIBLE ones I agree with (recommended)** — say which
  PLAUSIBLE ones you'd take and why, in the question text.
- **Fix only the CONFIRMED findings**
- **Fix nothing — I'll decide**

After fixing: re-run the fast checks, re-run any fixture the reviewer or you built, run
`bash agentPlugin/tools/syncPlugin.sh` (twice when a step file's exit gate changed — the first run
rebuilds the runbook stubs) and `--check`, stage with `git add`, and never commit (the standing
rule: commits and pushes happen only when AJ says "release"). Offer one line: *Run `/fw-review`
again on the fixes?* — don't launch it unasked.

## What this skill never does

Review a Business Central project built with the framework (that is the plugin's
`ocpf-reviewer` and the Code Review step). Edit the agent definition's model or effort to suit a
request — change the file, not the call, if AJ wants a different pairing. Commit, tag, or push.
