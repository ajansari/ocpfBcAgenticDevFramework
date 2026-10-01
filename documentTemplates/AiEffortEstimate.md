> **Template** for `docs/2-design/AiEffortEstimate.md` — OCPF BC Agentic Development Framework, written at Full Step 03 / Lite Step 2, in the same pass as the Human Effort Estimate (main role, not delegated). Keep every
> heading in this order; replace every `<placeholder>`; a section that doesn't apply keeps its heading
> with *N/A — reason* beneath it; work the closing checklist and leave it ticked; delete this note.
> The step file in `ocpfFramework/runbookSteps/` says what goes in each section; this template only fixes the shape.

# AI Effort Estimate — <Extension Name>

**Date:** <date> · **Estimated by:** <main role, model> · **Basis:** `docs/2-design/TDD.md` v<n> (Full) or `docs/2-design/DesignDoc.md` v<n> (Lite) · **AI tool:** <Claude Code / GitHub Copilot> · **Reviewed by:** <name>

> **What this is.** The tokens, cost, and elapsed time the framework expects to spend finishing this
> project with the recorded models, for reading next to the Human Effort Estimate
> (`docs/2-design/HumanEffortEstimate.md`) before the build starts, and against the measured usage
> table in `ProjectProgress.md` after it. Every number in §2 is a **baseline placeholder until
> calibrated** (§6); the margin in §5 says how far to trust the totals.

## 1. Inputs
| Input | Value | Source |
|---|---|---|
| Objects by type and complexity | <n tables (s/m/c), n pages, n codeunits, n reports, n API pages, n enums, n permission sets …> | TDD §3 / Design Doc Part B |
| Batches | <n> | TDD batch plan / Design Doc |
| Languages | <source + n target> | `docs/1-define/ProjectParameters.md` |
| Main model and effort | <model, effort> | `ocpfFramework/framework.json` (Ops § Roles) |
| Light model and effort (Full) | <model, effort> | same |
| Reasoning model and effort (Full) | <model, effort> | same |
| Generator (parallel batches) | inherits Main | Ops § Roles → Parallel batches |
| AI tool | <Claude Code / GitHub Copilot> | intake |
| Approvals the plan will raise | <n> (Rule 6 gates + Rule 6a decisions expected from BUILD on) | counted in §4 |

## 2. Token estimate per step × model × token type
Built from the baselines below: a **fixed per-step carry** (the runbook core plus the step file, re-read per turn at cache-read rate) plus a **variable part per object**. These baselines are the framework's starting numbers; they are placeholders until the calibration store (§6) holds measured projects, and this document says which it used.

| Baseline | Value |
|---|---|
| Generation output per object | simple 1,500 · medium 3,000 · complex 6,000 output tokens |
| Object-type multiplier | pages ×1 · tables ×1 · codeunits ×1.5 · reports ×2 |
| Pre-flight per object | light role, input-heavy: <input tokens> in, <output tokens> out |
| Compile-and-fix round | one per batch: <input / output tokens> |
| Reasoning-role document | 25,000 input / 8,000 output each (FRD, TDD, Sanity Check, Gap-Fit, Code Review) |
| Fixed per-step carry | runbook core + step file ≈ <tokens>, re-read per turn at cache-read rate × <expected turns> |

One row per step per model. **GitHub Copilot:** the same token estimate, plus the last column —
the row's tokens priced at the model's Copilot rates (§3) and converted to **AI credits**, the unit
Copilot bills in and the unit the usage table will measure. Claude Code: leave the last column `—`.
| Step | Model | Input | Output | Cache write | Cache read | Basis (objects × baseline, documents, rounds) | AI credits (Copilot) |
|---|---|---|---|---|---|---|---|
| <next step> | <Main> | | | | | | |
| <next step> | <Light> | | | | | | |
| … | | | | | | | |
| **Total** | | | | | | | |

## 3. Cost
At the prices in `ocpfFramework/state/pricing.json` (fetched from the publisher, dated) — the same rules as the usage table. **Copilot:** use GitHub's per-model rates for input, cached input, cache write, and output (`https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing`, fetched and dated like any other price) and the value of one AI credit from the same page; the Total in USD is the Total in credits × that value. When the calibration store (§6) holds Copilot projects, prefer their measured **credits per step and per model** to a token-built figure — it is what Copilot actually charged.
| Model | Input (USD) | Output (USD) | Cache write (USD) | Cache read (USD) | Total (USD) |
|---|---|---|---|---|---|
| <model> | | | | | |
| **Total** | | | | | |

*Prices: <source URL>, read <date>.*

## 4. Wall-clock estimate from BUILD on
Covers Full Step 05 / Lite Step 3 onward. Per step: generation time (output tokens ÷ the throughput recorded in calibration, default **50 tokens/s**) + sub-agent waits + compile-and-test rounds (default **3 rounds × 20 min agent time + 30 min human sandbox test each**) + **approvals × 30 minutes** (every Rule 6 gate and Rule 6a decision the plan will raise, counted in §1).
| Step | Generation | Sub-agent waits | Compile-and-test rounds | Approvals × 30 min | Step total |
|---|---|---|---|---|---|
| <05 / Lite 3> | | | | <n> × 30 min | |
| … | | | | | |
| **Total** | | | | <n> approvals | |

This assumes every approval is answered within 30 minutes. Slower approvals extend the elapsed time by exactly the extra wait.

## 5. Margin
**±30 %** applies until calibrated; the framework's target is **±10 %**, reached when three or more measured projects exist in the calibration store. **This estimate carries:** <±30 % — uncalibrated, <n> project(s) in the store / ±10 % — calibrated on <n> projects>.

## 6. Calibration store
`~/.ocpf/calibration/<project>-<date>.json`, one file per finished project, written by the `usage` skill at project close (Full Step 12 / Lite Step 7): per step, per model tokens by type (Claude Code) or AI credits (Copilot), elapsed, turns, decisions, plus the object counts by type. The estimator reads every file there and derives per-object and per-step averages when present. Fields the `usage` skill writes (`calibrationSchema: 1`): `steps[]` with `step`, `elapsedSeconds`, `turns`, `decisions`, `subAgentCalls`, and `models[]` (`model`, `input`, `output`, `cacheWrite`, `cacheRead`, `requests`, `costUsd` — and, in a Copilot project, `aiCredits` and `role`, with the four token fields `null`); `totals` (with `aiCredits`); `pricing.usdPerAiCredit`; `throughput.outputTokensPerSecond`; `objects.byType` and `objects.total`.
| Files read | Projects | Averages derived (per-object output, per-step carry, throughput) | Used in §2 / §4? |
|---|---|---|---|
| <n, or none> | <names, dates> | <values, or "none — §2 baselines used"> | |

## Before calling this done
- [ ] Every step from here to the last one has a row in §2 per model that will run in it.
- [ ] The approvals count is listed in §1 and carried into §4.
- [ ] §5 names which margin applies (±30 % uncalibrated or ±10 % calibrated) and why.
- [ ] §4 carries the slower-approvals sentence unchanged.
- [ ] §6 says whether calibration data was found and used, or the baselines stood in.
