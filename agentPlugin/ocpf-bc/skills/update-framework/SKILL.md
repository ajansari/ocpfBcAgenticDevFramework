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

1. **Read `ocpfFramework/framework.json`** for the edition, the runbook version, where copies were placed
   (`placedAs`), the changelog filename, `layout`, and `declinedUpdateVersion`. A project on the
   old layout has the marker at `.ocpf/framework.json` instead, with no `layout` field: read it
   there, and note that the Migration below applies on *Update now*.
2. **If there's no marker,** the project was set up manually. Find the runbook by looking for a
   file starting with `# BC App Build Routine` in `CLAUDE.md`, `.github/copilot-instructions.md`,
   `.github/instructions/ocpf-framework.instructions.md`, `ocpfFramework/BC_App_Build_Routine_Agent.md`,
   `ocpfFramework/LITE_BC_App_Build_Routine_Agent.md`, or the two runbook filenames in the root
   (the pre-5.0.0.0 place).
   - Read its `**Version:**` line. The title says whether it's Lite.
   - Offer to create the marker so future sessions check automatically. Create it only on a yes.
3. **If there's no runbook at all,** this project isn't using the framework. Offer the `start`
   skill instead.

## Step 2: Find the latest version

1. **Fetch the version line of the latest runbook** for the project's edition:
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
3. **Say where the project stands** (read `ProjectProgress.md`; a Lite project before v5.0.0.0 has
   none — read its ChangeLog) and whether any change touches a step already completed. Call out
   anything that would mean revisiting finished work, rather than burying it. If the project is on
   Full < 5.0.0.0 / Lite < 5.0.0.0, say that the update also **moves files** (the Migration below)
   and list the moves before asking.
4. **Ask**, through the selectable options mechanism:
   - **Update now:** replace the project's runbook copies with the new version.
   - **Not now:** ask again next session.
   - **Skip this version:** don't ask again until something newer than this one is published.

   Recommend **Update now** unless the project is mid-way through a step whose rules the new
   version changes. In that case recommend finishing the step first.

## Step 4: Apply (only after "Update now")

0. **Migrate the layout first** when the project is on Full < 5.0.0.0 / Lite < 5.0.0.0 (the
   Migration section below, in order). Everything after this step assumes the new layout.
1. **Back up** each current copy to `ocpfFramework/state/previous/<filename>.<old version>`, for example
   `ocpfFramework/state/previous/CLAUDE.md.2.7.0.0`. Never delete the old copy.
2. **Download the new runbook byte for byte** and write it to every path in `placedAs`.
   - If a path is `.github/instructions/ocpf-framework.instructions.md`, keep its `applyTo`
     frontmatter above the runbook text.
   - If `CLAUDE.md` only imports a separate runbook file (an
     `@ocpfFramework/BC_App_Build_Routine_Agent.md` line), update that runbook file and leave
     `CLAUDE.md` alone.
3. **Download and overwrite the project's changelog file** (`ocpfFramework/RunbookChangelog.md` or
   `ocpfFramework/LITE_RunbookChangeLog.md`). It's the framework's history, not the project's.
3a. **Refresh the step files and the templates** — a runbook from Full v4.0.0.0 / Lite v3.0.0.0 on
   is a core plus `ocpfFramework/runbookSteps/` and `ocpfFramework/documentTemplates/` (Ops § Fetched Companions has the file
   lists and URLs under `fullVersion/steps/`, `liteVersion/steps/`, and `ocpfFramework/documentTemplates/`).
   Replace every file in both folders, removing files that no longer exist upstream (Full 5.0.0.0
   / Lite 5.0.0.0 retired `UsageReport.md` and added `AiEffortEstimate.md`,
   `HumanEffortBaselines.md`, and `Acknowledgements.md`); a project coming from an older runbook
   gets the folders created and gitignored (`ocpfFramework/runbookSteps/`,
   `ocpfFramework/documentTemplates/`, always ignored). Check each step file's
   `**Runbook version:**` line equals the new runbook's version. Refresh
   `ocpfFramework/patterns/` and `ocpfFramework/scripts/` the same way.
3b. **Refresh both companion guides to the versions the new runbook expects** — its header names
   them. Overwrite `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md` and
   `ocpfFramework/opsGuide/ocpfOperationsGuide.md` from
   `https://raw.githubusercontent.com/ajansari/ocpfBcAgenticDevFramework/main/standardsGuide/ocpfALDevStandardsGuide.md`
   and `.../main/opsGuide/ocpfOperationsGuide.md`, updating each folder's `SNAPSHOT.json`. A runbook
   and a companion from different majors don't go together: the runbook cites **Ops §** sections by
   name.
3c. **Sub-agent definitions:** if the project has no `ocpf-generator` definition
   (`.claude/agents/ocpf-generator.md` / `.github/agents/ocpf-generator.agent.md`), run the
   `roles` skill's Step 3 for it with the Main model and effort already recorded — both editions.
   Rewrite the existing `ocpf-light` and `ocpf-reasoning` copies from the new bundled bodies,
   keeping their `model:` / `effort:` lines.
4. **Update `ocpfFramework/framework.json`:** set `runbookVersion`, `source`, `commitSha`, and `fetchedAt`,
   set `"layout": "ocpfFramework-1"` and add `"tooling": {}` if missing, and clear
   `declinedUpdateVersion`.
5. **Record the change in the project's own continuity documents,** as the runbook asks for any
   significant change:
   - **Full:** a `docs/0-project/ChangeLog.md` entry and a `docs/0-project/ProjectMemory.md` note.
   - **Lite:** a `docs/0-project/ChangeLog.md` entry.

   Include the old and new versions, every file the Migration moved, and anything that needs
   revisiting.
6. **Re-read the new runbook** before continuing, then carry on from the current step under the new
   rules.

## Migration from Full < 5.0.0.0 / Lite < 5.0.0.0 (the `ocpfFramework/` layout)

Runs once, on *Update now*, after the human has seen the list of moves (Step 3). Use `git mv` for
every path git tracks and a plain move for ignored ones (`git ls-files --error-unmatch <path>`
tells which); never copy-and-leave. Do it in this order, and stop on the first failure rather than
leaving the project half-moved.

1. **Create `ocpfFramework/` and `ocpfFramework/state/`.**
2. **The old marker folder:** `.ocpf/framework.json` → `ocpfFramework/framework.json`; everything
   else in `.ocpf/` (`usage.json`, `pricing.json`, `notifications.json`, `copilot.json`,
   `previous/`) → `ocpfFramework/state/<same name>`. Remove the empty `.ocpf/`.
3. **The fetched folders**, each as a whole: `standardsGuide/`, `opsGuide/`, `runbookSteps/`,
   `documentTemplates/`, `patterns/`, `scripts/` → `ocpfFramework/<same name>` (the ones that exist;
   the rest are fetched in Step 4.3a–3b). Their `SNAPSHOT.json` files move with them.
4. **The changelog and schematics:** `RunbookChangelog.md` (either spelling) or
   `LITE_RunbookChangeLog.md`, and `RunbookSchematics.md` / `LITE_RunbookSchematics.md` →
   `ocpfFramework/`. A root `BC_App_Build_Routine_Agent.md` or `LITE_…` that an existing `CLAUDE.md`
   imports → `ocpfFramework/`, and the import line in `CLAUDE.md` becomes
   `@ocpfFramework/BC_App_Build_Routine_Agent.md` (or the Lite name).
5. **`docs/` by phase** — `git mv` every document into its subfolder (create the folders):
   - `docs/0-project/`: `ChangeLog.md`, `ProjectMemory.md`, `Roadmap.md`, `TestingFeedback.md`
   - `docs/1-define/`: `ProblemStatement.md`, `ProjectParameters.md`, `ObjectRegister.md`,
     `TranslationGlossary.md`
   - `docs/2-design/`: `FRD.md`, `TDD.md`, `SanityCheck.md`, `DesignDoc.md`, `HumanEffortEstimate.md`
   - `docs/3-build/`: `BuildPlan.md`
   - `docs/4-prove/`: `GapAnalysis.md`, `CodeReview.md`, `PostDevTDD.md`, `Documentation.md`,
     `UserGuide.md`, `HumanUnitTestScript.md`, `AutomatedTestScripts.md`, `Deployment.md`,
     `ReleaseTestResults.md`, `Docs.md`, `TestScript.md`, and every translated copy
     (`UserGuide.fr-CA.md` and the like) beside its source
   A project older than Full v3.4.0.0 / Lite v2.3.0.0 may still have these in the root: move them
   from there. `ProjectProgress.md` stays in the root. Then fix every relative link inside the moved
   documents that pointed at a sibling (`grep -rn '](\.\|docs/' docs/`).
6. **Lite only — `ProjectProgress.md`:** create it from
   `ocpfFramework/documentTemplates/ProjectProgress.md` (keep the Lite step table, delete the Full
   one), mark the completed steps `Completed` and the current one `In Progress` from the ChangeLog,
   and **carry the usage table over from `docs/UsageReport.md`** row for row into the second
   table, footnote included. Then remove `docs/UsageReport.md` (`git rm`). Every later step updates
   its row at start and close, like Full.
7. **Rewrite the `.gitignore` block** to the new one (Ops § Repository Hygiene): the always-ignored
   group is `.claude/settings.local.json`, `ocpfFramework/state/`, `ocpfFramework/standardsGuide/`,
   `ocpfFramework/opsGuide/`, `ocpfFramework/runbookSteps/`, `ocpfFramework/documentTemplates/`,
   `ocpfFramework/patterns/`, `ocpfFramework/scripts/`, `.alpackages/`, `*.g.xlf`; with the intake
   answer *not tracked*, the second group is `ocpfFramework/`, `CLAUDE.md`,
   `.github/copilot-instructions.md`, `.github/instructions/ocpf-framework.instructions.md`, and the
   six project-local agent files (`ocpf-light`, `ocpf-reasoning`, `ocpf-generator` under
   `.claude/agents/` and `.github/agents/`). Delete the old `.ocpf/`, `standardsGuide/`,
   `opsGuide/`, `runbookSteps/`, `documentTemplates/`, `patterns/`, `scripts/`, root-runbook, and
   root-changelog entries. Verify with `git check-ignore -v` on every framework file that exists and
   `git status --porcelain`; if a framework file was tracked under the old answer, `git rm --cached`
   it only when the recorded intake answer says not tracked.
8. **Rewrite every path that pointed into the old places:**
   - `.mcp.json`: the `al` server's args become `["ocpfFramework/scripts/al-mcp.sh"]` (Windows:
     `["/c", "ocpfFramework\\scripts\\al-mcp.cmd"]`).
   - Hooks in `.claude/settings.json` and `.claude/settings.local.json`:
     `${CLAUDE_PROJECT_DIR}/ocpfFramework/scripts/ocpf-notify.sh` (or `…\ocpf-notify.ps1`).
   - `.vscode/settings.json`: any Copilot approval pattern or task that named `scripts/` or
     `.ocpf/` now names `ocpfFramework/scripts/` (the approval regex is
     `ocpfFramework[\/\\]scripts[\/\\]`); user-level `~/.copilot/hooks/` entries likewise, after
     saying they apply to every project on the machine.
   - `ocpfFramework/state/usage.json` needs no change (`transcriptDir` is outside the project).
9. **Write `ocpfFramework/README.md`** — the six lines the `start` skill's Step 6.2b gives.
10. **ChangeLog entry** (`docs/0-project/ChangeLog.md`, its own new location): one entry listing
    **every** move, old path → new path, the `.gitignore` rewrite, the `.mcp.json` and hook
    rewrites, and, for Lite, the creation of `ProjectProgress.md` and the removal of
    `docs/UsageReport.md`. Full: a `docs/0-project/ProjectMemory.md` note too.

Then continue with Step 4.1: the backups now go to `ocpfFramework/state/previous/`, and the new
runbook, changelog, step files, templates, and guides land in the new places.

**After "Skip this version":** set `declinedUpdateVersion` to the new version in
`ocpfFramework/framework.json`.

**After "Not now":** change nothing.
