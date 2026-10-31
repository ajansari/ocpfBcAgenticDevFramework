# Posting Review Checklist

![Made for the OCPF BC Agentic Development Framework 6.0.0.0 or later](https://img.shields.io/badge/OCPF%20BC%20Framework-%E2%89%A5%206.0.0.0-0F6CBD)

A Custom Skill for the [OCPF BC Agentic Development Framework](https://bcdev.ai). It gives the agent a short patterns note to read before it writes a Business Central posting codeunit, and a twelve-point checklist the pre-review and the Code Review run on every posting routine.

This is the framework's example skill. Use it as it is, or copy the folder, change the slug, the author, and the two reference files, and you have a skill of your own.

## What it plugs into

| Extension point | File | Read at |
|---|---|---|
| `extends.referenceSources` | `references/PostingPatterns.md` | before a posting codeunit is written |
| `extends.preReviewChecks` | `references/PostingReviewChecklist.md` | the pre-review |
| `extends.codeReviewChecks` | `references/PostingReviewChecklist.md` | the Code Review |

It overrides nothing.

## Load it

Made for the OCPF BC Agentic Development Framework 6.0.0.0 or later. In a project that follows the framework:

```
/ocpf-bc:skill-load https://github.com/ajansari/ocpfBcAgenticDevFramework/tree/main/exampleSkills/posting_review_checklist
```

or download the zip from [bcdev.ai/skills.html](https://bcdev.ai/skills.html) and run `/ocpf-bc:skill-load <path to the zip>`. The framework shows you the files and asks before it activates anything.

## Files

```
posting_review_checklist/
  SKILL.md
  ocpf-skill.json
  README.md
  CHANGELOG.md
  LICENSE
  references/
    PostingPatterns.md
    PostingReviewChecklist.md
```

## License

MIT. See LICENSE.
