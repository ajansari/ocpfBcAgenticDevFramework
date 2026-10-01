# BC App Build Routine — STEP 2 — Write the Design Doc & Self-Check

**Runbook version:** 5.0.0.0 · Lite edition · Phase: DESIGN

> One step of the OCPF BC Agentic Development Framework runbook, fetched into `ocpfFramework/runbookSteps/` at the
> routine's first step and read **in full** the moment this step starts. The core runbook
> (`CLAUDE.md` or `.github/copilot-instructions.md`) carries only this step's stub; its Operating
> Rules and ALL ALONG sections apply throughout. **Standards §** is
> `ocpfFramework/standardsGuide/ocpfALDevStandardsGuide.md`; **Ops §** is `ocpfFramework/opsGuide/ocpfOperationsGuide.md`.

---


**Inputs:** `docs/1-define/ProblemStatement.md`, `docs/1-define/ProjectParameters.md`, BC symbol file,
`ocpfFramework/documentTemplates/DesignDoc.md`, `ocpfFramework/documentTemplates/HumanEffortEstimate.md`,
`ocpfFramework/documentTemplates/HumanEffortBaselines.md` (or `~/.ocpf/HumanEffortBaselines.md` when
it exists), `ocpfFramework/documentTemplates/AiEffortEstimate.md`, `ocpfFramework/state/pricing.json`,
and `~/.ocpf/calibration/*.json` when any exist.

**Actions:** Write **one** document — `docs/2-design/DesignDoc.md`, from its template — that does the job the full framework splits
across an FRD and a TDD. It must be self-sufficient: someone who's never seen the project should
be able to produce every object correctly from this document alone. Two halves, one file:

**Part A — What & Why (business language):**
- Purpose, scope, explicit out-of-scope list; business objectives; target consumers.
- Platform requirements (BC version, deployment model) from the Parameters.
- Entity/object inventory: every object, its source table, and read vs. read/write designation —
  set read vs. read/write from actual data mutability, not preference (**Standards §2.2** has the
  category-by-category table: master data and open documents editable, posted entries and
  registers read-only).
- Non-functional requirements: compilation cleanliness, performance, compliance.
- Languages and markets: every target language, what's required at first release,
  customer-language documents, translatable data.

**Part B — How (technical):**
- System identity: Publisher, namespace, prefix, APIPublisher/APIGroup/APIVersion, AL runtime, BC
  minimum, object ID range(s) — all copied from the Step 1 Parameters, not restated by memory.
  Assign IDs sequentially and **leave a handful unallocated at the end of the range** rather than
  spending it all — those are what gap-fill work at Step 6 draws on (**Standards §5.2**; Lite
  skips the full framework's module sub-blocks, but not the buffer).
- **Per-object spec** — for every object: ID, type, source table name *and* verified source table
  number, `PageType`, `APIGroup`, `EntityName`, `EntitySetName`, `ODataKeyFields = SystemId`, and
  exactly one of `DelayedInsert = true` / `Editable = false`.
- **Per-field spec** — source name and camelCase identifier for every field (conversion rules:
  **Standards §4.1**); which fields are excluded and why (**Standards Part 3**, driven by the
  Localization parameter, and **§3.2** for obsolete fields); abbreviations applied (**§4.2**); reserved-keyword resolutions (**§4.3** — `area` →
  `areaCode`, and the rest).
- **Computed-field pattern, decided per field:** state for each calculated-looking field whether
  it's a `FlowField` or a stored field seeded by a trigger that never overwrites a user's value
  (**Standards Part 7**).
- `SourceTableView` filters for any document-type-filtered page, with correct `const()` quoting —
  quote multi-word enum values, never single-word ones; either mistake is a parser error
  (**Standards §2.3**).
- `using` directives — exact namespace per object, copied from the symbol file (**Standards §1.1**,
  **§3.4**).
- **Parent–child pages, per child table** (**Standards §11.1**): the link field; every page that
  shows the table in a parent's context and how each is opened (`SubPageLink` part or `RunPageLink`
  action, never a hand-set filter); the hidden link control, the two-group `OnNewRecord` read, the
  `TestField` in `OnInsert`, and `DelayedInsert = true` — named in the object's spec, not left to
  the generator.
- **Number series, per numbered table** (**Standards §11.2**): the setup-table field (`Code[20]`,
  `TableRelation = "No. Series"`), every page it appears on and how it is bound (wizard bound to a
  temporary copy of the setup table), the table's `"No. Series"` field, `OnInsert`, and
  `AssistEdit`, all on codeunit `"No. Series"` from Business Foundation.
- Design patterns the Standards Guide doesn't cover (error handling, facades, and similar):
  consult AL Guidelines (ALL ALONG → Reference Sources) and cite the guideline used,
  rather than inventing a pattern.
- Permission sets, if required (see Step 1): a read-only set and a read/write set (which includes
  the read-only set), with every table's `tabledata` grant enumerated per set — not just "sets
  exist" — named from `docs/1-define/ProjectParameters.md`, each ≤ 20 characters with a caption ≤ 30
  (**Standards §5.3–§5.4**).
- **Upgrade and data migration** — needed from the second version onward, and whenever this version
  changes what existing data must look like: the upgrade codeunits, the trigger each uses, and the
  upgrade tag guarding each one; the two-version obsolete cycle for any field being replaced
  (**Standards Part 9**). **"No upgrade code needed" is written down with its reason**, not left
  silent.
- **Events** — which events this extension publishes (its extension points) and which Microsoft
  events it subscribes to, each verified in the symbol file (**Standards Part 10**).
- Special notes: singletons, header/line pairs, naming conflicts, deletion behavior for each
  entity (block-if-referenced / cascade / allow) — including any *other* table (standard BC
  included) that references this entity by `TableRelation`.
- **Translatable text** (**Standards §8.3**): every message a `Label` with an AA0074 suffix and a
  `Comment` for each placeholder; which labels are `Locked`; translation file names
  (`Translations/<ExtensionName>.<culture>.xlf`).
- **Translation glossary** — a table in `docs/2-design/DesignDoc.md` (skip if the project chose *US wording, no
  translation files*): BC concept · W1 source term · one column per target language · where each
  term came from · status (`verified` / `reviewer attention`). Fill every row with **Standards
  Appendix D** — Microsoft's own translations first — never from model memory.
- **API caption locking — decided interactively** (**Standards §8.6**; skip if there are no API
  pages or queries):
  1. Classify every API page and API query as **Business**, **Technical — admin**, or **Technical
     — internal plumbing**, each with a one-line reason. List anything that could go more than one
     way as **Unsure**.
  2. Ask about each Unsure object first (*Business* / *Technical — admin* / *Technical — internal
     plumbing*).
  3. Ask about Business: *Translatable (recommended)* / *Locked*.
  4. Ask about Technical: *Admin translatable, plumbing locked (recommended)* / *All translatable* /
     *All locked*.

  Each recommendation cites Microsoft's precedent from §8.6. Skip empty groups. Record the group,
  the locked decision, and who decided, per object in Part B. Repeat for any API object added
  later.

**Self-check, before calling this step done** (same agent, same pass — no separate reviewer role
in Lite, but don't skip the checklist just because there's no one else to hand it to):
- [ ] Every entity from Step 1 maps to at least one object here (or is explicitly deferred).
- [ ] Every object has a valid ID inside the allocated range.
- [ ] Every source table number is verified against the symbol file — not estimated.
- [ ] Every field complies with the Localization parameter; every obsolete/pending field excluded.
- [ ] Every `using` namespace is sourced from the symbol file.
- [ ] All entity/field names ≤ 30 characters.
- [ ] Read vs. read/write designations match actual data mutability.
- [ ] Permission sets are fully enumerated if required, and named with this extension's App Code
      (**Standards §5.4**).
- [ ] Every entity's deletion behavior is explicitly decided, not left to a template default.
- [ ] Every target language has a named reviewer; every regional term is in the glossary, verified
      or marked for reviewer attention.
- [ ] Every API page and query has a recorded group and caption-locking decision.

**Then, in the same pass, the two effort estimates** (both written by this agent, from their
templates; Ops § Documents):

- **`docs/2-design/HumanEffortEstimate.md`** — from Part B's object inventory, the billable hours an
  **experienced senior AL developer** would need for the same scope, by task — design, each object
  by type and complexity, permission sets, upgrade code, translations, testing, documentation,
  deployment. The hours per task come from the baselines table, never from memory: the framework
  default in `ocpfFramework/documentTemplates/HumanEffortBaselines.md`, replaced by the partner's own
  `~/.ocpf/HumanEffortBaselines.md` when that file exists (same shape, outside every project) — §1
  of the estimate says which applied. Every assumption stated so the human can adjust it; the
  sanity anchor in the baselines file (a typical 10-object PTE lands at 15–30 hours) is checked,
  and an estimate outside 0.5×–2× of the anchor scaled by object count says why. An estimate to
  read next to the measured AI cost (ALL ALONG → Usage & Cost Tracking), not a quote; say so.
- **`docs/2-design/AiEffortEstimate.md`** — what this routine itself is expected to consume:
  **Inputs** (objects by type and complexity, batches, languages, the recorded model and effort,
  the AI tool); **tokens per step × model × token type** from the template's baselines (a fixed
  per-step carry plus a variable part per object; placeholders until calibrated); **cost** at the
  prices in `ocpfFramework/state/pricing.json` (fetched, dated — Copilot: priced at GitHub's
  per-model rates and shown in AI credits as well, the unit the usage table will measure); **wall-clock from Step 3 onward** — generation time at the calibrated throughput,
  sub-agent waits, compile-and-test rounds, and **approvals × 30 minutes** (count the Rule 6 gates
  and Rule 6a decisions the plan will raise), carrying the sentence *"This assumes every approval
  is answered within 30 minutes. Slower approvals extend the elapsed time by exactly the extra
  wait."*; the **margin** (±30 % until calibrated; ±10 % once three or more measured projects
  exist in `~/.ocpf/calibration/`, which the estimate reads and says so). The measured figures land
  in `ProjectProgress.md`'s usage table, step by step, next to this estimate.

**Outputs:** `docs/2-design/DesignDoc.md`; an **Object Register** table (inside `docs/2-design/DesignDoc.md` is fine at this
scale — every planned object with its ID, source table, and R/W status); `docs/2-design/HumanEffortEstimate.md`;
`docs/2-design/AiEffortEstimate.md`.

**Exit gate:** Human sign-off. Self-check passes with 0 blocking issues. No rule requires
knowledge outside the document. `docs/2-design/HumanEffortEstimate.md` exists, covers every object, names
its baselines source, and states its assumptions. `docs/2-design/AiEffortEstimate.md` exists, covers every step
from Step 3 on, states its margin and the 30-minute approval assumption. This step's usage rows, one per model, are written before this message (Operating Rule 9).
