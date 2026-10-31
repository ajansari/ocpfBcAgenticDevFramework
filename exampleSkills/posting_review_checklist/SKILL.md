---
name: posting-review-checklist
description: Reference material for Business Central posting routines in a project that follows the OCPF BC Agentic Development Framework. Supplies a patterns note the agent reads before it writes a posting codeunit (Full Step 06, Lite Step 4, Build-a-Feature Part 4) and a twelve-point checklist the pre-review (Full Step 07, Lite Step 5) and the Code Review (Full Step 09, Lite Step 6, Build-a-Feature Part 5) run on every posting routine. Read it when the project contains, or is about to contain, a codeunit that posts a document or a journal.
---

# Posting Review Checklist

This skill is reference text. It adds to what the framework already reads; it never relaxes a rule of the Standards Guide, and the Standards Guide wins on any conflict.

## Files

| File | Extension point | Read at |
|---|---|---|
| `references/PostingPatterns.md` | `extends.referenceSources` | the generation brief, before any posting codeunit is written |
| `references/PostingReviewChecklist.md` | `extends.preReviewChecks`, `extends.codeReviewChecks` | the pre-review brief and the Code Review |

## Procedure

1. When the design (TDD, Design Doc, or a Build-a-Feature window) names a codeunit that posts a document or a journal, read `references/PostingPatterns.md` before writing it. Follow the Standards Guide first, then this note.
2. At the pre-review and at the Code Review, run every item of `references/PostingReviewChecklist.md` against each posting codeunit. Report each failed item as a finding that names this skill and the item number.
3. A posting codeunit that passes every item is not thereby approved; the Standards Guide sections and the framework's own review still apply.
