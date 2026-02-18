---
name: ea-capital-safety-auditor
description: Performs an obsessive, read-only security audit of the PhantomPad Expert Advisor's risk management and lot size calculation logic. Its single mission is to mathematically guarantee that NO bug can ever cause unintended financial loss (wrong lot size, missing stop loss, uncapped risk, division by zero). Produces a detailed audit report with a score out of 100. Covers MQL4 and MQL5 trade calculation, input validation, and risk enforcement. Does NOT modify any file.
---

# Expert Advisor — Capital Safety Auditor 🛡️💰

## Goal

To perform an **exhaustive, read-only** static analysis of all code paths that touch the user's money — specifically **lot size calculation**, **risk percentage enforcement**, **stop loss validation**, and **input parameter sanitization**. 

The output is a single `.md` audit report. **No code is modified. Ever.**

After this audit passes with no CRITICAL findings, we can guarantee with very high confidence that:
- It is **mathematically impossible** for a trade to open with a lot size larger than the user's configured max risk.
- A **StopLoss is always mandatory** and correctly placed relative to entry price and direction.
- **No division by zero, overflow, or negative value** can corrupt the lot calculation.
- **All user inputs are validated and bounded** at initialization.

---

## When to use this skill

- When user ask to use the "ea capital safety auditor" skill.
- When user ask an audit of the capital safety of the EA.

---

## How to use it

### PHASE 1 — FILE COLLECTION (Mandatory Reading List)

Read **ALL** of these files in full before starting any analysis. Do not skip any file. Do not summarize — read every line.

| Priority | File | Why |
|----------|------|-----|
| 🔴 P0 | `Common/Core/TradeLogic/TradeCalc.mqh` | Core lot calculation formula (`CalculateLotSize`), risk conversion (`GetRiskPercentage`), SL direction validation (`ValidateSlDirection`) |
| 🔴 P0 | `Common/Core/Engine/TradeValidator.mqh` | 6-level pre-trade validation gate (inputs → SL → risk → volume → market → permissions) |
| 🔴 P0 | `Common/Core/TradeLogic/TradeUIInteraction.mqh` | `UpdateCalculatedLot()` — reads UI fields and feeds them to `CalculateLotSize()`. `AutoSwitchOrderType()` — auto-direction logic |
| 🟠 P1 | `Common/Core/Inputs.mqh` | All `input` parameters with their default values |
| 🟠 P1 | `Common/Core/Init.mqh` | `InitGlobals()` — copies inputs to globals, sets defaults and caps |
| 🟠 P1 | `Common/Core/Globals.mqh` | All global state variables (g_MaxRiskPercent, g_MaxSpread, g_OneRPercent, etc.) |
| 🟠 P1 | `fantomepad.mq4` | `OnInit()` — input validation, config loading, sanity checks |
| 🟠 P1 | `fantomepad.mq5` | Same as above for MT5 |
| 🟡 P2 | `Common/Core/Config.mqh` | `LoadConfig()` / `SaveConfigToFile()` — can override g_MaxRiskPercent from file |
| 🟡 P2 | `Common/Core/DataTypes.mqh` | `TradeRequest` struct — what fields are expected |

### PHASE 2 — SYSTEMATIC ANALYSIS (Ordered Checklist)

For each check below, you MUST provide one of three verdicts:
- ✅ **PASS** — Logic is correct. Briefly explain why.
- ❌ **FAIL (CRITICAL)** — A bug exists that can cause financial loss. Detail the exact scenario.
- ⚠️ **WARN** — Not a bug, but a potential improvement or edge case worth noting.

#### Block A — Lot Size Calculation (`CalculateLotSize`)

| # | Check | What to verify |
|---|-------|----------------|
| A1 | **Division-by-zero protection** | Is `tickSize`, `tickValue`, `lotStep` checked for `<= 0` before use? What about `AccountEquity()`? |
| A2 | **Distance calculation** | Is `MathAbs(entryPrice - slPrice)` checked for `<= 0` or `<= point` before division? |
| A3 | **Risk money calculation** | For each `RiskMode` (0=%, 1=Currency, 2=R): is `riskMoney` correctly computed? Can it ever be negative? |
| A4 | **Lot normalization** | Is `MathFloor(lotSize / lotStep) * lotStep` applied? (Must round DOWN, never UP) |
| A5 | **Min/Max lot enforcement** | Is lot capped by `minLot` (return 0 if below) and `maxLot`? |
| A6 | **Return value safety** | If any precondition fails, does the function return `0.0` (safe) and not a garbage/corrupted value? |
| A7 | **Negative equity handling** | What happens if `AccountEquity() <= 0`? |

#### Block B — Risk Percentage Conversion (`GetRiskPercentage`)

| # | Check | What to verify |
|---|-------|----------------|
| B1 | **Mode 0 (%)** | Is the percentage returned as-is? |
| B2 | **Mode 1 (Currency)** | Is `(riskValue / equity) * 100` correct? Is equity checked for `<= 0`? |
| B3 | **Mode 2 (R)** | Is `riskValue * g_OneRPercent` correct? Can `g_OneRPercent` ever be 0 or negative? |
| B4 | **Fallback** | If `RiskMode` is an unexpected value, what happens? |

#### Block C — Stop Loss Direction (`ValidateSlDirection`)

| # | Check | What to verify |
|---|-------|----------------|
| C1 | **Buy orders** | SL must be BELOW entry. Is `sl < entry` checked for OP_BUY, OP_BUYLIMIT, OP_BUYSTOP? |
| C2 | **Sell orders** | SL must be ABOVE entry. Is `sl > entry` checked for OP_SELL, OP_SELLLIMIT, OP_SELLSTOP? |
| C3 | **Zero handling** | If entry=0 or sl=0, does it return `true` (deferred to other validation) without crash? |

#### Block D — TradeValidator 6-Level Gate

| # | Check | What to verify |
|---|-------|----------------|
| D1 | **Level 1: Input Check** | Symbol non-empty, Lots > 0, Price > 0 for pending orders? |
| D2 | **Level 2: SL Logic** | SL > 0 mandatory? Direction validated via `ValidateSlDirection()`? |
| D3 | **Level 3: Risk Management** | `req.RiskPercent > g_MaxRiskPercent` blocked? What if `g_MaxRiskPercent` is 0? |
| D4 | **Level 4: Broker Rules** | `lotStep` fallback if 0? Lots normalized via MathFloor? Lots < minLot rejected? Lots > maxLot capped? |
| D5 | **Level 5: Market Conditions** | Spread check against `g_MaxSpread`? StopLevel distance for SL/TP/Entry? Margin check with 10% safety buffer? |
| D6 | **Level 6: Permissions** | `IsTradeAllowed()`, license state, account login all checked? |

#### Block E — Input Validation at Init

| # | Check | What to verify |
|---|-------|----------------|
| E1 | **MaxSlippage** | Is negative/zero value sanitized or silently corrected (e.g., to a high tolerance like 1000) to prioritize execution freedom? |
| E2 | **OneRPercent** | Is `<= 0` caught? Does it block init or just warn? |
| E3 | **MaxRiskPercent** | Is `> 100` or `<= 0` caught? Is it corrected after LoadConfig too? |
| E4 | **MagicNumber** | Is `<=` 0 silently corrected to a safe default (e.g. 123456) to prevent conflict with manual trades? |
| E5 | **Config override safety** | After `LoadConfig()`, is `g_MaxRiskPercent` re-validated (capped at 100, floor at 0)? |

#### Block F — UI-to-Trade Pipeline

| # | Check | What to verify |
|---|-------|----------------|
| F1 | **UpdateCalculatedLot()** | Does it correctly read SL, Risk, Entry from UI fields and call `CalculateLotSize()`? |
| F2 | **Button state** | Is the Buy/Sell button disabled (visually) when `lots == 0` or `risk > maxRisk`? |
| F3 | **AutoSwitchOrderType()** | When SL direction auto-corrects the order type, is lot recalculated afterwards? |
| F4 | **TP auto-adjust** | When TP becomes invalid (wrong side of SL), is it corrected without breaking anything? |

### PHASE 3 — SCORING

Calculate a **Capital Safety Score** out of 100 using this formula:

```
Score = 100 - (CRITICAL_count × 25) - (WARN_count × 3)
Minimum score = 0
```

| Score Range | Verdict |
|-------------|---------|
| 95-100 | ✅ PRODUCTION READY — Capital is safe |
| 80-94 | ⚠️ CONDITIONAL — Minor concerns, review recommended |
| 50-79 | 🟠 AT RISK — Significant issues found |
| 0-49 | 🔴 DANGEROUS — Do NOT ship. Critical flaws. |

### PHASE 4 — REPORT GENERATION

Create a file named **`AUDIT_CAPITAL_SAFETY.md`** at the project root with this exact structure:

```markdown
# 🛡️ PhantomPad — Capital Safety Audit Report
**Date:** [YYYY-MM-DD]
**Auditor:** ea-capital-safety-auditor v1.0
**Score:** [XX/100] — [VERDICT]

## Executive Summary
[2-3 sentences: overall assessment]

## 🔴 CRITICAL Findings (Capital at Risk)
[Each finding with: ID, Description, Affected File:Line, Exact Scenario, Recommended Fix]

## ⚠️ Warnings
[Each warning with: ID, Description, Recommendation]

## ✅ Passed Checks
[List all passed checks with brief justification]

## Detailed Checklist Results
[Full Block A through F results table]

## Files Analyzed
[List of all files read with line counts]
```

---

## Examples

**User:** "Audit the EA capital safety before release."
**Assistant:** [Reads all 10 files in Phase 1. Executes all 25+ checks in Phase 2. Calculates score. Generates `AUDIT_CAPITAL_SAFETY.md` at project root. Reports summary to user.]

**User:** "I changed TradeCalc.mqh, make sure I didn't break anything."
**Assistant:** [Re-runs full Phase 1-4 audit. Compares with any previous report. Highlights new findings.]

---

## Constraints

- **READ-ONLY (ABSOLUTE)**: You MUST NOT modify any `.mq4`, `.mq5`, `.mqh`, or database record. Your ONLY output is the `.md` report file.
- **EXHAUSTIVE**: You must read EVERY file in the Phase 1 list. Skipping a file is FORBIDDEN.
- **NO ASSUMPTIONS**: If a value could theoretically be 0, negative, or null, TEST that scenario mentally. Don't assume "it will never happen".
- **MATHEMATICAL RIGOR**: For lot calculation, trace the formula with concrete numbers (e.g., "If equity=10000, risk=2%, SL=50 pips, tickValue=10, then lots = ..."). Show your work.
- **SCOPE LIMIT**: Do NOT analyze execution engines (TradeEngineMT4/MT5), license logic, or GUI layout. Those are other skills' responsibility.
