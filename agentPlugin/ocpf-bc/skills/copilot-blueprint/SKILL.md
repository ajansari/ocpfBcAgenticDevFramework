---
name: copilot-blueprint
description: Build a Business Central Copilot feature in AL the verified way - from the OnlyBCFans BC Copilot Blueprint (ajansari/obcfBCCopilotBlueprint), whatever journey is active or none. Use whenever the user asks for a Copilot feature, a "Suggest with Copilot" action, a PromptDialog page, a Copilot Capability registration, Azure OpenAI or System.AI in an extension, or a Copilot-assisted anything in Business Central; and before the agent says any BC Copilot thing is impossible, unsupported for a per-tenant extension, or needs an Azure subscription. Fetches the Blueprint at the framework's pinned tag into a sibling folder outside the project, follows its procedure for the objects, and cites its false-assumptions table. Full and Lite reach it through their intake; this skill makes it fire from Build-a-Feature and from plain chat too.
---

# BC Copilot feature → the Blueprint, every time

A Business Central Copilot feature — a registered `Copilot Capability`, a `PromptDialog` page, a
*Suggest with Copilot* action on a host page, the System.AI codeunits behind it — is the one thing
AI coding tools get wrong most consistently: the obsolete three-parameter `RegisterCapability`, a
dialog closed with `LookupOK`, "a PTE cannot register a capability", "Copilot needs an Azure
subscription". The **OnlyBCFans BC Copilot Blueprint** is a shipped, symbol-verified reference that
proves each of those wrong and gives the build order and nine compilable templates. **Never write a
Copilot feature from memory. Fetch the Blueprint and build from it.**

This skill exists so that rule holds in every journey. Full and Lite fetch the Blueprint when the
intake records a Copilot feature (Ops § Fetched Companions). Build-a-Feature has no Copilot entry in
its catalogue, and a plain chat has no intake — this skill is what fires there.

## 1. Fetch it — once per project, outside the project root

Exactly as Ops § Fetched Companions → *OnlyBCFans BC Copilot Blueprint* says. In short:

1. **Where:** a sibling folder **outside** the AL project's root — `../<ProjectName>.copilotBlueprint/`
   — never under the tree that holds `app.json`: `templates/` holds nine real `.al` objects (prefix
   `PFX`, IDs 50100–50199) that `alc` would otherwise compile into the project. If the folder
   already exists with a `SNAPSHOT.json`, use it; don't fetch again.
2. **How:** a shallow clone at the tag the framework pins — **`v1.0.0.0`** (Ops § Fetched
   Companions names the current pin) — `.git` stripped, `LICENSE` kept (MIT), and a `SNAPSHOT.json`
   with repo, tag, commit SHA, and fetch time:
   ```
   git clone --depth 1 --branch v1.0.0.0 https://github.com/ajansari/obcfBCCopilotBlueprint "../<ProjectName>.copilotBlueprint"
   rm -rf "../<ProjectName>.copilotBlueprint/.git"
   ```
   Nothing to gitignore: it isn't in the tracked tree.
3. **In Claude Code, also copy the folder to `.claude/skills/obcf-bc-copilot-blueprint/`** inside
   the project (gitignored with the framework's other files), so the Blueprint's own skill triggers
   on *Copilot*, *PromptDialog*, and *Azure OpenAI* in later sessions without this one.
4. **If GitHub is unreachable, say so and stop** — do not build the feature from memory and call it
   verified. Offer to continue when the repository is reachable.
5. **Say what was fetched:** the tag, the commit, and that its claims are pinned to BC 27.5 (its
   `references/08-api-reference-bc27.md` says how to re-extract the API from newer symbols when the
   project targets a newer platform).

## 2. Build from it

- **Read `SKILL.md` in the fetched folder first.** Its **15-step procedure is the build order**;
  each step names the reference file and the template to copy from. Follow it inside whatever
  journey is active:
  - **Full / Lite:** the FRD and TDD name the capability, the host page, the billing path(s), and
    what the AI suggests, citing the Blueprint; generation starts from `templates/`; the step files
    say the rest (Ops § Fetched Companions).
  - **Build-a-Feature:** the feature is "a few objects" — the `Copilot Capability` enum extension,
    the `PromptDialog` page, the host page's `Prompting` action (a page extension), the AI engine
    codeunit, the setup table and its page, the install codeunit, the permission set entries. Each
    becomes a row of the session, in the Blueprint's order, generated from its template renamed and
    renumbered to the project's prefix and ID range — never from a blank file. The journey's own
    rules (confirm before writing, compile clean with the analyzers, the step-close box, usage rows)
    apply unchanged.
  - **Plain chat, no project:** explain the design from `references/01-architecture.md` and name
    the objects; offer to start a journey (`/ocpf-bc:start`) to build them.
- **Ask the billing path early** (Rule 6a): **Microsoft-billed** (Microsoft-managed Azure OpenAI —
  no Azure subscription, no endpoint, no key; `references/03`) / **Partner-billed** (the customer's
  own Azure OpenAI deployment; `references/04`) / **both, switchable in setup**. Don't assume.
- **On any compile or runtime failure that mentions System.AI, a capability, the dialog, or a
  deployment getter**, check `references/08-api-reference-bc27.md` and
  `references/09-false-assumptions.md` **before memory** — an obsolete `RegisterCapability` overload,
  a GPT-4o getter, "Copilot capability has not been set", AL0223 on the dialog are all in there.
- **Before saying anything is impossible, unsupported for PTEs, or needs an Azure subscription,
  read `references/09-false-assumptions.md` and cite the row** — or drop the claim.
- **Where the Blueprint and the Standards Guide seem to disagree, the Standards Guide wins** and
  the Blueprint has a bug (its own README says so); report it to the human as a candidate fix.
- **Code review** (Full Step 09 / Lite Step 6 / Build-a-Feature Part 5): walk the Blueprint's
  `SKILL.md` section 3 done-checklist and section 2 non-negotiable rules as a review dimension.

## 3. What this skill never does

- Never writes a Copilot feature without the Blueprint on disk.
- Never fetches it into the project root, and never refreshes it unasked (moving to a newer
  Blueprint tag is a framework decision, recorded in the framework changelog like the Standards pin).
- Never publishes, runs tests, or touches a tenant — the journey's rules on that stand (Ops §
  Packaging, Ops § Automated Tests).
