# <display name>

![OCPF skill](https://img.shields.io/badge/OCPF%20BC%20framework-%E2%89%A5%20<minVersion>-blue)

**Made for the OCPF BC Agentic Development Framework ≥ <minVersion> — load with
`/ocpf-bc:skill-load <folder or repository URL>`.**

<What it does, for a human: the problem it solves, where it came from, who maintains it.>

## What it adds to a project

<One line per file the manifest names, and the framework step that reads it.>

## Loading it

Three ways, all through `/ocpf-bc:skill-load` in a project that follows the framework (ideally before
`/ocpf-bc:start`, or at any time after):

- a folder on your machine: `~/.ocpf/skills/<slug>`
- this repository: `https://github.com/<owner>/<repo>` (add `#<tag>` to pin a version)
- a `skillslocation.md` in the project root listing this source, one per line

The framework validates the skill against its version (`minVersion` above, no maximum), the
project's journey (<journeys>), and the other skills loaded, shows you this README and the skill
before activating it, and records it in `ocpfFramework/customSkills.json`.

## Compatibility

Framework ≥ <minVersion>; journeys: <journeys>; harnesses: Claude Code and GitHub Copilot. Updated
with `/ocpf-bc:skill-update` from a project where it is loaded; the version history is in
`CHANGELOG.md`.

## Author and license

<name>, <organization>. <License, or "No license file — all rights reserved by the author.">
