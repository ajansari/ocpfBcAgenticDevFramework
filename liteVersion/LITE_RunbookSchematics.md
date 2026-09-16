# Agentic Development Framework — Lite Schematics

Visual companion to the Lite runbook (see `LITE_BC_App_Build_Routine_Agent.md` for the
authoritative text, `LITE_RunbookChangeLog.md` for its version history, and
`standardsGuide/ocpfALDevStandardsGuide.md` for the AL rules it cites as **Standards §**, shared
unchanged with the full framework). These diagrams are a reading aid, not a source of truth — if a
diagram and the runbook text ever disagree, the runbook wins and this file is stale and needs
updating.

Every diagram below was extracted and rendered through `@mermaid-js/mermaid-cli` before being
committed here, per the same discipline the runbook itself requires at Step 6 for `Docs.md`'s own
ER diagram ("render it before shipping it"), applied here to every diagram in this file too.
Markdown can store a syntactically invalid Mermaid diagram that looks fine in the source and
simply fails to draw wherever it's viewed — that check is what catches it before a reader does.

**Shape legend, used consistently across every diagram below:**

| Shape | Meaning |
|---|---|
| `(( stadium ))` | Start / end point of a flow |
| `[ rectangle ]` | An action, step, or process |
| `[/ parallelogram /]` | Input or output (data, a document) |
| `{{ hexagon }}` | An exit gate / checkpoint |
| `{ diamond }` | A decision point |
| `[[ subroutine ]]` / dashed box | A cross-cutting concern (ALL ALONG) |

**No color legend here.** The full framework's schematics colors BUILD/PROVE steps by which of
its three optional roles (Main / Light / Reasoning) performs them. Lite has no such split —
Operating Rule set states it plainly: "one model does everything" — so there is no role-color
legend, and no diagram in this file corresponding to the full framework's §4.2 (Model & Effort
Assignment). Every action box below is performed by whichever single model is running the routine.

---

## 1. High-Level Overview

The whole Lite routine in one picture: four phases in sequence, with ALL ALONG's continuous
discipline running underneath every one of them — the same shape as the full framework's overview,
compressed from 14 steps to 7.

```mermaid
flowchart LR
    Problem(["Business Problem<br/>(10 AL files or fewer)"]) --> DEFINE["DEFINE<br/>Step 1 — scope the problem,<br/>lock parameters"]
    DEFINE --> DESIGN["DESIGN<br/>Step 2 — one self-sufficient<br/>Design Doc"]
    DESIGN --> BUILD["BUILD<br/>Steps 3-5 — generate AL, lint,<br/>then compile+package+test+fix,<br/>on repeat"]
    BUILD --> PROVE["PROVE<br/>Steps 6-7 — review, gap-check,<br/>document, then a human-run<br/>release test"]
    PROVE --> Deployed(["Deployed, Documented App"])

    AllAlong[["ALL ALONG<br/>Continuous Discipline"]]
    AllAlong -.-> DEFINE
    AllAlong -.-> DESIGN
    AllAlong -.-> BUILD
    AllAlong -.-> PROVE

    classDef phase fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    classDef allalong fill:#fdf0d5,stroke:#c99a3a,stroke-width:1px;
    class DEFINE,DESIGN,BUILD,PROVE phase;
    class Problem,Deployed endpoint;
    class AllAlong allalong;
```

---

## 2. Deeper Level — Full Step & Gate Flow

Every step across all four phases, in order, with the exit gate that must be met before the next
one can start (the runbook's own rule: don't start a step until its predecessor's exit gate is
met).

```mermaid
flowchart TD
    subgraph DEFINE["PHASE: DEFINE"]
        direction TB
        S1["Step 1<br/>Define the Problem<br/>& Lock Parameters"] --> G_S1{{"Both companion guides<br/>present + gitignored; notifications<br/>chosen and tested; no placeholder<br/>remains; ProjectParameters.md<br/>+ onboarding Qs answered;<br/>app.json + symbols ready;<br/>human confirms sheet"}}
    end

    subgraph DESIGN["PHASE: DESIGN"]
        direction TB
        S2["Step 2<br/>Design Doc & Self-Check"] --> G_S2{{"Human sign-off;<br/>self-check 0 blocking issues;<br/>no rule needs outside knowledge"}}
    end

    subgraph BUILD["PHASE: BUILD"]
        direction TB
        S3["Step 3<br/>Plan & Scaffold"] --> G_S3{{"Batch plan approved once;<br/>scaffold structurally<br/>complete (not compiled)"}}
        G_S3 --> S4["Step 4<br/>Generate the Code<br/>(per-object loop, no compile)"]
        S4 --> G_S4{{"Every object pre-flight clean;<br/>permission-set coverage verified"}}
        G_S4 --> S5["Step 5<br/>Compile, Package,<br/>Test & Iterate<br/>(mandatory compile-and-package,<br/>then a sandbox test/fix/repackage cycle)"]
        S5 --> G_S5{{"0 errors / 0 warnings;<br/>sandbox testing clean"}}
    end

    subgraph PROVE["PHASE: PROVE"]
        direction TB
        S6["Step 6<br/>Review, Gap-Check<br/>& Finalize Docs"] --> G_S6{{"Gaps resolved/deferred;<br/>dead-code clean; Docs.md<br/>diagram renders; TestScript.md<br/>executable by a non-developer"}}
        G_S6 --> HandOff{{"Formal hand-off message —<br/>replaces the generic Rule 6c<br/>check-in for this boundary"}}
        HandOff --> S7["Step 7<br/>Release for Testing"]
        S7 --> G_S7{{"Green tests pass,<br/>red tests fail gracefully,<br/>translations approved →<br/>same package ships to Production"}}
    end

    G_S1 --> S2
    G_S2 --> S3
    G_S5 --> S6

    classDef step fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    class S1,S2,S3,S4,S5,S6,S7 step;
    class G_S1,G_S2,G_S3,G_S4,G_S5,G_S6,G_S7,HandOff gate;
```

---

## 3. Phase Schematics

### 3.1 DEFINE

```mermaid
flowchart TD
    Start(["Stakeholder conversation,<br/>business need in plain language"]) --> S1

    subgraph S1["STEP 1 — Define the Problem & Lock Parameters"]
        direction LR
        In1[/"Inputs:<br/>Stakeholder notes"/] --> Act1["Actions:<br/>Ask working language; fetch both<br/>companion guides (Standards + Ops)<br/>+ gitignore; ask how to be notified<br/>(recorded in .ocpf/notifications.json);<br/>capture raw requirements<br/>verbatim; write problem<br/>statement + quick gap check<br/>(Standards Part 6); ask every<br/>intake question in grouped<br/>option boxes (up to 4 each),<br/>never inferred, then one confirm; persist<br/>ProjectParameters.md; then the<br/>agent writes app.json, connects<br/>AL tools, downloads symbols,<br/>checks the editor"] --> Out1[/"Output:<br/>standardsGuide/ + opsGuide/<br/>(gitignored),<br/>requirements/ (if any),<br/>ProblemStatement.md,<br/>ProjectParameters.md,<br/>app.json, .alpackages/"/]
    end
    S1 --> Gate1{{"Exit gate:<br/>Both companion guides present + gitignored,<br/>notification choice recorded,<br/>applied, and tested,<br/>no placeholder remains,<br/>onboarding questions answered,<br/>app.json matches sheet,<br/>symbols in .alpackages/,<br/>human confirms sheet"}}

    Gate1 --> Next(["to DESIGN, Step 2"])

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    class In1,Out1 io;
    class Act1 act;
    class Gate1 gate;
    class Start,Next endpoint;
```

### 3.2 DESIGN

```mermaid
flowchart TD
    Start(["from DEFINE,<br/>Step 1 confirmed"]) --> S2

    subgraph S2["STEP 2 — Write the Design Doc & Self-Check"]
        direction LR
        In1[/"Inputs:<br/>ProblemStatement.md,<br/>ProjectParameters.md,<br/>symbol file"/] --> Act1["Actions:<br/>Write DesignDoc.md — Part A<br/>(what/why) + Part B (how):<br/>system identity, per-object spec,<br/>per-field spec, computed-field<br/>pattern, SourceTableView filters,<br/>using directives, permission sets,<br/>deletion behavior — then<br/>self-check against a 9-item list"] --> Out1[/"Output:<br/>DesignDoc.md,<br/>Object Register (inside it)"/]
    end
    S2 --> Gate1{{"Exit gate:<br/>Human sign-off, self-check<br/>0 blocking issues, no rule<br/>needs knowledge outside the document"}}

    Gate1 --> Next(["to BUILD, Step 3"])

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    class In1,Out1 io;
    class Act1 act;
    class Gate1 gate;
    class Start,Next endpoint;
```

### 3.3 BUILD

The phase Lite compresses hardest: one batch (two only on a natural split), symbol-verified lint
with no per-object compile, one mandatory compile-and-package once every planned object exists,
then a continuous sandbox test/fix/repackage cycle — the same discipline as the full framework's
BUILD, run by one model instead of three.

```mermaid
flowchart TD
    Start(["from DESIGN,<br/>Design Doc signed off"]) --> S3

    subgraph S3["STEP 3 — Plan & Scaffold"]
        direction LR
        In1[/"Inputs:<br/>DesignDoc.md,<br/>Object Register"/] --> Act1["Actions:<br/>Confirm batch plan (1, or 2 on<br/>a natural split) — the one approval<br/>to generate code; prepare scaffold (confirm<br/>app.json, AL tools, symbols;<br/>analyzer settings),<br/>fetch BCQuality snapshot<br/>+ OCPF Patterns library,<br/>write pre-flight checklist<br/>(pre-gen + post-gen — one model<br/>runs both passes)"] --> Out1[/"Output:<br/>Batch plan, scaffold,<br/>pre-flight checklist"/]
    end
    S3 --> Gate1{{"Exit gate:<br/>Batch plan approved (with 2 batches,<br/>run-through choice recorded),<br/>scaffold structurally complete<br/>(not compiled)"}}

    Gate1 --> S4
    subgraph S4["STEP 4 — Generate the Code (repeats per object)"]
        direction TB
        B1["Next object — no per-object<br/>approval; stop on a pre-flight<br/>failure or Design Doc deviation"]
        B1 --> PreGen["Pre-generation pre-flight:<br/>identifier length, reserved<br/>keywords, localization,<br/>ObsoleteState — on planned<br/>names/fields; fix Design Doc<br/>first if anything fails"]
        PreGen --> Gen["Generate the AL file from<br/>the Standards §1.3 template"]
        Gen --> PostGen["Post-generation pre-flight:<br/>required props, file name,<br/>Rec.-qualification, dead code,<br/>indentation, permission-set<br/>coverage, symbol verification"]
        PostGen --> MoreObjects{"More objects<br/>in the batch plan?"}
        MoreObjects -- "Yes" --> B1
    end
    MoreObjects -- "No — every planned<br/>object generated" --> PermVerify["Verify permission-set coverage<br/>across every table generated —<br/>design-time check, independent<br/>of compiling"]
    PermVerify --> Gate2{{"Exit gate:<br/>Every object pre-flight clean,<br/>permission-set coverage verified<br/>— NO compile required here"}}

    Gate2 --> S5
    subgraph S5["STEP 5 — Compile, Package, Test & Iterate"]
        direction LR
        Compile["FIRST: compile the whole<br/>extension once with the analyzers,<br/>then package it — the one<br/>mandatory compile-and-package<br/>(Op. Rule 4)"] --> Deploy["Publish package<br/>to BC sandbox"]
        Deploy --> Test["Test — by hand (the default:<br/>Postman, Power Automate, Power<br/>Apps, Copilot Studio), or agent-run<br/>if round 1's offer was accepted<br/>AND an HTTP route exists —<br/>the AL MCP Server is not one"]
        Test --> Q{"Errors, warnings,<br/>or issues found?"}
        Q -- "Yes" --> Diag["Check patterns/ first, then:<br/>one-off or pattern? where<br/>from? what rule missed it?"]
        Diag --> Approve["Human approves the round's<br/>fixes together: apply all /<br/>selected / discuss"]
        Approve --> Fix["Fix root cause, regenerate<br/>files, log ChangeLog.md,<br/>update Design Doc"]
        Fix --> Repackage["Compile AND package again<br/>(not just recompile)"]
        Repackage --> Deploy
        Q -- "No" --> Clean["0 errors / 0 warnings,<br/>sandbox testing clean —<br/>source text stable: draft and<br/>test each language"]
    end
    Clean --> Gate3{{"Exit gate:<br/>Full extension compiles clean,<br/>human confirms sandbox testing<br/>clean, no known systemic issue"}}

    Gate3 --> Next(["to PROVE, Step 6"])

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    classDef decision fill:#fde2e2,stroke:#c0504d,stroke-width:1px;
    class In1,Out1 io;
    class Act1,B1,PreGen,Gen,PostGen,PermVerify,Fix,Compile,Deploy,Test,Repackage,Diag act;
    class Gate1,Gate2,Gate3,Approve gate;
    class Start,Next,Clean endpoint;
    class MoreObjects,Q decision;
```

### 3.4 PROVE

Step 6 merges what the full framework splits across four steps (Gap-Fit Test, Code Review, Update
Design Documents, Document the Code) into one review-and-finalize pass; Step 7 is Lite's own
version of the full framework's Step 12 — a human-run release test, with the same formal hand-off
moment marking where the agent's own work ends.

```mermaid
flowchart TD
    Start(["from Step 5,<br/>extension compiles/packages 0/0,<br/>at least one sandbox test done"]) --> S6

    subgraph S6["STEP 6 — Review, Gap-Check & Finalize Docs"]
        direction LR
        In1[/"Inputs:<br/>Built extension,<br/>DesignDoc.md, ChangeLog.md"/] --> Act1["Actions:<br/>Gap-check DesignDoc vs. as-built<br/>(classify: Intentional / Oversight /<br/>Spec stale); code review + full<br/>Anti-Patterns table (Standards<br/>Part 7) + BCQuality pass; update<br/>DesignDoc.md in place; write<br/>Docs.md (+ render ER diagram)<br/>and TestScript.md"] --> Out1[/"Output:<br/>DesignDoc.md (updated),<br/>Docs.md, TestScript.md"/]
    end
    S6 --> GapFill{"Any Oversight gap or<br/>finding needs a code fix?"}
    GapFill -- "Yes" --> GapCycle["Fixes approved together,<br/>then Step 5 cycle again —<br/>fix, compile, package,<br/>redeploy, retest"]
    GapCycle --> Gate1
    GapFill -- "No (doc-only)" --> Gate1
    Gate1{{"Exit gate:<br/>Gaps resolved/deferred, dead-code<br/>clean, Docs.md diagram renders,<br/>TestScript.md executable"}}

    Gate1 --> HandOff{{"Hand-off message (Rule 6a) —<br/>replaces Rule 6c's generic<br/>check-in at this boundary:<br/>'Perfect, I understand!' /<br/>'I have some questions'"}}
    HandOff --> S7
    subgraph S7["STEP 7 — Release for Testing"]
        direction LR
        In2[/"Inputs:<br/>Latest package,<br/>TestScript.md, Docs.md"/] --> Act2["Actions:<br/>Real users run TestScript.md<br/>by hand on the sandbox —<br/>green + red team, permission-set<br/>verification; translated docs once<br/>that pass is green, then language<br/>passes and translation approval;<br/>record findings in ChangeLog.md<br/>(implement / defer / reject)"] --> Out2[/"Output:<br/>ChangeLog.md updated with<br/>every test finding"/]
    end
    S7 --> ReleaseCheck{"All green pass,<br/>all red fail gracefully?"}
    ReleaseCheck -- "No" --> GapCycle2["Step 5 cycle again —<br/>fix, compile, package, redeploy;<br/>re-run whatever Step 6 parts<br/>the fix touches"]
    GapCycle2 --> S7
    ReleaseCheck -- "Yes" --> Gate2

    Gate2{{"Exit gate:<br/>Bump the Build segment (or copy to<br/>an immutable name) on the package<br/>that passed; restate Schema Sync<br/>Mode; that package ships to Production"}}

    Gate2 --> Done(["Deployed, Documented App"])

    classDef io fill:#eef2f7,stroke:#4a7ab5,stroke-width:1px;
    classDef act fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef gate fill:#fff3cd,stroke:#c99a3a,stroke-width:1px;
    classDef endpoint fill:#f2f2f2,stroke:#888,stroke-width:1px;
    classDef decision fill:#fde2e2,stroke:#c0504d,stroke-width:1px;
    class In1,Out1,In2,Out2 io;
    class Act1,Act2,GapCycle,GapCycle2 act;
    class Gate1,Gate2,HandOff gate;
    class Start,Done endpoint;
    class GapFill,ReleaseCheck decision;
```

---

## 4. Cross-Cutting Schematics

Not tied to a single phase — ALL ALONG runs underneath every phase, every step, exactly as it does
in the full framework. There is no Lite equivalent of the full framework's §4.2 (Model & Effort
Assignment): Lite drops the Main/Light/Reasoning role split entirely, so there is no role
configuration to diagram.

### 4.1 ALL ALONG — Continuous Discipline

```mermaid
flowchart LR
    subgraph Phases["The four phases, running in sequence"]
        direction LR
        DEFINE["DEFINE"] --> DESIGN["DESIGN"] --> BUILD["BUILD"] --> PROVE["PROVE"]
    end

    subgraph Continuous["ALL ALONG — every phase, every step"]
        direction TB
        Change["ChangeLog.md — the single log<br/>merges ChangeLog + Testing<br/>Feedback + Roadmap into one file"]
        Pack["Packaging & Versioning<br/>never delete a package;<br/>propose bumps, don't apply silently"]
        Std["Companion guides<br/>Standards Guide (Standards §) and<br/>Operations Guide (Ops §) — fetched<br/>at Step 1, gitignored, not optional"]
        Hygiene["Repository Hygiene<br/>standardsGuide/, patterns/,<br/>.alpackages/ always gitignored;<br/>BCQuality outside the project;<br/>packages tracked"]
        Notif["Notifications<br/>on every turn end, question,<br/>and approval — Claude app, sound,<br/>and/or desktop, chosen at Step 1,<br/>read every session"]
        MCP["AL MCP Server, Symbols &<br/>Editor Sync — agent sets up at<br/>Step 1, human only approves;<br/>check editor after clean compiles"]
        Ana["Analyzers<br/>CodeCop, UICop, and PerTenantExtensionCop<br/>or AppSourceCop on every<br/>mandatory compile"]
        Ref["Reference Sources<br/>MS Learn Base App + System App,<br/>translation files, AL Guidelines —<br/>consulted online, not fetched"]
        Tr["Translations & Terminology<br/>glossary in DesignDoc.md;<br/>agent drafts, named reviewer approves;<br/>release gate: all units signed-off"]
        BCQ["BCQuality Knowledge Snapshot<br/>fetch once at Step 3, refresh<br/>only on explicit request"]
        Pat["OCPF BC AL Patterns Library<br/>fetch once into patterns/,<br/>check before diagnosing from scratch"]
        Perm["Permission Sets<br/>Yes the moment 1 table exists;<br/>named with the App Code;<br/>verified at Steps 3 and 4,<br/>proven by PTE0004 at compile"]
        Plug["OCPF Plugin (optional)<br/>only if .ocpf/framework.json exists:<br/>per-session update check (apply on yes),<br/>Standards fallback, zero-install AL tools"]
    end

    Continuous -.-> DEFINE
    Continuous -.-> DESIGN
    Continuous -.-> BUILD
    Continuous -.-> PROVE

    classDef phase fill:#d4e6f7,stroke:#4a7ab5,stroke-width:1px;
    classDef discipline fill:#fdf0d5,stroke:#c99a3a,stroke-width:1px;
    class DEFINE,DESIGN,BUILD,PROVE phase;
    class Change,Pack,Std,Hygiene,Notif,MCP,Ana,Ref,Tr,BCQ,Pat,Perm,Plug discipline;
```

---

*Generated from `LITE_BC_App_Build_Routine_Agent.md` v2.1.0.0; all 7 diagrams re-rendered clean.
Version history is in `LITE_RunbookChangeLog.md`. If the Lite runbook changes in a way that
affects the phase/step structure, regenerate the affected diagram(s) here and re-render before
committing — don't hand-edit a diagram without checking it still parses.*
