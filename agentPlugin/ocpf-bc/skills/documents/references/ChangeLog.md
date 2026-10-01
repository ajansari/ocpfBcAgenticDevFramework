> **Template** for `docs/0-project/ChangeLog.md` — OCPF BC Agentic Development Framework, written at the first deviation, fix, or decision — both editions. Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# ChangeLog — <Extension Name>

Ground truth for what was actually built and why. Every deviation from the design, every root-cause
fix, every decision — logged **before the next batch begins**, newest first within a step. Name the
person, never a role. Superseded decisions stay, marked superseded.

**Full entry format:**
```
## Issue <BatchID>-<SeqNo> — <Short Description>
**Problem:** What was wrong or missing.
**Root cause:** Why it happened.
**Resolution:** What was changed.
**Files affected:** List of changed files or template rules.
**Updated:** TDD, FRD, or both — yes/no.
**Model:** <model that ran a delegated step, from its Model: line> (delegated steps only)
```

**Lite entry format** (Issue / Feedback / Deferred in one log):
```
## <Type> <SeqNo> — <Short Description>
**Problem:** What was wrong, missing, or requested.
**Root cause:** Why it happened (Issue/Feedback only).
**Resolution:** What was changed, or why it was deferred/rejected.
**Files affected:** List of changed files.
**Design Doc updated:** yes/no.
```

**Before adding an entry**
- [ ] It names the person who decided, never a role.
- [ ] Every affected file is listed, and the design-document update is answered yes or no.
- [ ] A delegated step's entry names the model that ran, from the report's `Model:` line.

---

## <first entry>
