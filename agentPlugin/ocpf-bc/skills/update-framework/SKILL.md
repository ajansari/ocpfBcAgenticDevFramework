---
name: update-framework
description: Check whether a newer version of the OCPF BC Agentic Development Framework runbook (Full or Lite) has been published, show what changed, and update the project's copy only with the human's approval. Use when the user asks to "update the framework", "check for framework updates", "is there a newer runbook", "refresh the runbook", or when the runbook's once-per-session update check finds a newer version.
---

# Update the framework in this project

A project keeps its own pinned copy of the runbook. That keeps the rules stable mid-project, so a
newer version replaces the project's copy **only after the human says yes**. This follows the
runbook's own human-in-the-loop rules.

Repository: `https://github.com/ajansari/ocpfBcAgenticDevFramework` (default branch `main`).

## Step 1: Read the project's setup

1. **Read `.ocpf/framework.json`** for the edition, the runbook version, where copies were placed
   (`placedAs`), the changelog filename, and `declinedUpdateVersion`.
2. **If there's no marker,** the project was set up manually. Find the runbook by looking for a
   file starting with `# BC App Build Routine` in `CLAUDE.md`, `.github/copilot-instructions.md`,
   `.github/instructions/ocpf-framework.instructions.md`, `BC_App_Build_Routine_Agent.md`, or
   `LITE_BC_App_Build_Routine_Agent.md`.
   - Read its `**Version:**` line. The title says whether it's Lite.
   - Offer to create the marker so future sessions check automatically. Create it only on a yes.
3. **If there's no runbook at all,** this project isn't using the framework. Offer the `start`
   skill instead.

## Step 2: Find the latest version

1. **Fetch the latest runbook** for the project's edition:
   - Full: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/BC_App_Build_Routine_Agent.md`
   - Lite: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_BC_App_Build_Routine_Agent.md`

   To check the version alone, fetch only the first kilobyte — `curl -fsSL -r 0-1023 <url>` — which
   contains the `**Version:**` line. Download the whole file only when the human says "Update now".
   If a host ignores the range, read the line and discard the rest.
2. **If GitHub is unreachable,** compare against the bundled copy in the `start` skill's
   `references/` folder instead, if your environment exposes it, and say that's what you compared
   against.
3. **Compare the version numbers numerically,** part by part (for example `2.10.0.0` is newer than
   `2.9.0.0`).

## Step 3: Report

**If the project is current:** say so in one line, naming the version.

**Also compare the companions.** The runbook's header names the Standards Guide and Operations
Guide versions it expects. If a local copy's major version differs, say so: the runbook's
**Standards §** and **Ops §** citations point at sections that may have moved.

**If a newer version exists:**
1. **Fetch the matching changelog:**
   - Full: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/fullVersion/RunbookChangelog.md`
   - Lite: `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/liteVersion/LITE_RunbookChangeLog.md`
2. **Summarize every entry newer than the project's version,** newest first. For each version, give
   its one-paragraph summary and the changes that affect a project already in progress.
3. **Say where the project stands** (read `ProjectProgress.md`) and whether any change touches a
   step already completed. Call out anything that would mean revisiting finished work, rather than
   burying it.
4. **Ask**, through the selectable options mechanism:
   - **Update now:** replace the project's runbook copies with the new version.
   - **Not now:** ask again next session.
   - **Skip this version:** don't ask again until something newer than this one is published.

   Recommend **Update now** unless the project is mid-way through a step whose rules the new
   version changes. In that case recommend finishing the step first.

## Step 4: Apply (only after "Update now")

1. **Back up** each current copy to `.ocpf/previous/<filename>.<old version>`, for example
   `.ocpf/previous/CLAUDE.md.2.7.0.0`. Never delete the old copy.
2. **Download the new runbook byte for byte** and write it to every path in `placedAs`.
   - If a path is `.github/instructions/ocpf-framework.instructions.md`, keep its `applyTo`
     frontmatter above the runbook text.
   - If `CLAUDE.md` only imports a separate runbook file (an `@BC_App_Build_Routine_Agent.md`
     line), update that runbook file and leave `CLAUDE.md` alone.
3. **Download and overwrite the project's changelog file** (`RunbookChangelog.md` or
   `LITE_RunbookChangeLog.md`). It's the framework's history, not the project's.
3a. **Refresh both companion guides to the versions the new runbook expects** — its header names
   them. Overwrite `standardsGuide/ocpfALDevStandardsGuide.md` and
   `opsGuide/ocpfOperationsGuide.md` from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/standardsGuide/ocpfALDevStandardsGuide.md`
   and `.../main/opsGuide/ocpfOperationsGuide.md`, updating each folder's `SNAPSHOT.json`. A runbook
   and a companion from different majors don't go together: the runbook cites **Ops §** sections by
   name.
4. **Update `.ocpf/framework.json`:** set `runbookVersion`, `source`, `commitSha`, and `fetchedAt`,
   and clear `declinedUpdateVersion`.
5. **Record the change in the project's own continuity documents,** as the runbook asks for any
   significant change:
   - **Full:** a `ChangeLog.md` entry and a `docs/ProjectMemory.md` note.
   - **Lite:** a `ChangeLog.md` entry.

   Include the old and new versions and anything that needs revisiting.
6. **Re-read the new runbook** before continuing, then carry on from the current step under the new
   rules.

**After "Skip this version":** set `declinedUpdateVersion` to the new version in
`.ocpf/framework.json`.

**After "Not now":** change nothing.
