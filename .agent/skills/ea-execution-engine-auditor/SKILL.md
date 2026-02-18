---
name: ea-execution-engine-auditor
description: Performs an obsessive, read-only security audit of the PhantomPad Expert Advisor's trade execution pipeline. Its single mission is to guarantee that order execution (open, close, modify, delete) is atomic, retry-safe, and free of dangerous bugs like infinite order loops ('Machine Gun' bug), stale prices, or unchecked error codes. Covers MT4 and MT5 engines, the Orchestrator dispatch, error handling, and GUI trading handlers. Produces a detailed audit report with a score out of 100. Does NOT modify any file.
---

# Expert Advisor — Execution Engine Auditor ⚙️🔒

## Goal

To perform an **exhaustive, read-only** static analysis of the entire trade execution pipeline — from the moment the user clicks "Buy/Sell" to the moment the broker confirms (or rejects) the order. This includes **retry logic**, **error handling**, **partial close mechanics**, **position modification**, and **platform-specific engine implementations** (MT4 and MT5).

The output is a single `.md` audit report. **No code is modified. Ever.**

After this audit passes with no CRITICAL findings, we can guarantee:
- It is **impossible for the EA to open infinite orders** (no Machine Gun bug).
- **Prices are always refreshed** before execution (no stale price sends).
- **All NormalizeDouble() calls** are applied to price, SL, and TP.
- **Retry logic is bounded** with a hard cap, and only retries on safe errors.
- **Partial close** calculates the correct volume and handles MT4 successor tickets.
- **Error codes are properly mapped** and user-facing messages are accurate.
- **The g_TradeEngine pointer** is always null-checked before use.

---

## When to use this skill

- When user ask to use the "ea execution engine auditor" skill.
- When user ask an audit security for the execution egine logic.

---

## How to use it

### PHASE 1 — FILE COLLECTION (Mandatory Reading List)

Read **ALL** of these files in full before starting any analysis. Do not skip any file.

| Priority | File | Why |
|----------|------|-----|
| 🔴 P0 | `MT4/Engine/TradeEngineMT4.mqh` | MT4 implementation: `OrderSend()`, `OrderClose()`, `OrderModify()`, `OrderDelete()` with retry loops |
| 🔴 P0 | `MT5/Engine/TradeEngineMT5.mqh` | MT5 implementation: `CTrade`, `PositionOpen()`, `OrderOpen()`, `PositionClose()`, `PositionModify()`, partial close via raw `MqlTradeRequest` |
| 🔴 P0 | `Common/Core/Engine/TradeOrchestrator.mqh` | Central dispatch: Validate → Engine → Result. `Execute()`, `ClosePosition()`, `ModifyPosition()`, `DeleteOrder()` |
| 🔴 P0 | `Common/Core/Engine/TradeErrorHandler.mqh` | Error mapping: broker error codes → user messages. MT4 `ErrorDescription` → `TradeResult`. MT5 retcodes. Toast display |
| 🔴 P0 | `Common/Core/Engine/ITradeEngine.mqh` | Interface contract: `OpenMarket`, `OpenPending`, `Modify`, `Close`, `Delete` |
| 🟠 P1 | `GUI/Events/Handlers/Handler_Trading.mqh` | UI→TradeRequest construction for Buy, Sell, Pending. License guard. Reset after success |
| 🟠 P1 | `GUI/Events/Handlers/Handler_PositionActions.mqh` | `ExecutePartialClose()`, `ExecuteModifySLTP()`, Validate button, BE logic, MT4 successor ticket search |
| 🟡 P2 | `Common/Core/DataTypes.mqh` | `TradeRequest`, `TradeResult`, `MakeSuccessResult()`, `MakeErrorResult()` |
| 🟡 P2 | `Common/Core/TradeLogic/TradeCalc.mqh` | `GetOriginalLotSize()` — used for partial close calculation |
| 🟡 P2 | `GUI/Positions/Panel_Positions_Logic.mqh` | `FindMT4SuccessorTicket()`, `CheckAndSelectFirstPosition()` |

### PHASE 2 — SYSTEMATIC ANALYSIS (Ordered Checklist)

For each check, provide one verdict:
- ✅ **PASS** — Logic is correct. Briefly explain why.
- ❌ **FAIL (CRITICAL)** — A bug exists that can cause duplicate trades, money loss, or platform crash.
- ⚠️ **WARN** — Not a bug, but an edge case or improvement opportunity.

#### Block A — Machine Gun Protection (Retry Loops)

| # | Check | What to verify |
|---|-------|----------------|
| A1 | **MT4 OpenMarket retry loop** | Is `m_maxRetries` a hard constant (not user-configurable)? What is its value? Is the loop `for(i < maxRetries)` (bounded)? |
| A2 | **MT4 OpenPending retry loop** | Same checks as A1 |
| A3 | **MT4 Modify retry loop** | Same. Also: Error 1 (ERR_NO_RESULT) treated as success? |
| A4 | **MT4 Close retry loop** | Does it check `OrderCloseTime() > 0` (already closed) before retrying? |
| A5 | **MT4 Delete retry loop** | Does it check existence before deleting? Error 4108 (invalid ticket) handled? |
| A6 | **MT5 Engine — any retry mechanism?** | MT5 uses `CTrade` — does it have internal retries? Are they bounded? |
| A7 | **Orchestrator — double execution guard** | Can `TradeOrchestrator::Execute()` be called twice for the same click? (UI debounce) |

#### Block B — Price Freshness & Normalization

| # | Check | What to verify |
|---|-------|----------------|
| B1 | **MT4 Market: fresh price** | Is `RefreshRates()` called before `OrderSend()`? Is `MarketInfo(symbol, MODE_ASK/BID)` used instead of stale `price` param? |
| B2 | **MT4 Market: NormalizeDouble** | Are `sendPrice`, `normSL`, `normTP` all normalized to `digits`? |
| B3 | **MT4 Pending: NormalizeDouble** | Same for pending orders? |
| B4 | **MT4 Modify: openPrice preservation** | Is `OrderOpenPrice()` re-fetched before `OrderModify()`? Normalized? |
| B5 | **MT4 Close: close price** | Is `MarketInfo(symbol, MODE_BID/ASK)` used for close price (not stale)? Normalized? |
| B6 | **MT5 Market: price** | What price does `PositionOpen()` receive? Is it current? |
| B7 | **MT5 Partial Close: price** | For raw `MqlTradeRequest`, is `SymbolInfoDouble(SYMBOL_ASK/BID)` used? |

#### Block C — Error Classification & Handling

| # | Check | What to verify |
|---|-------|----------------|
| C1 | **Retryable errors (MT4)** | Are only SAFE errors retried (135,136,137,138,146,141)? No fatal errors (134=margin, 130=invalid stops) in retry list? |
| C2 | **Fatal errors (MT4)** | Do non-retryable errors break immediately (no more attempts)? |
| C3 | **MT5 retcode mapping** | Are 10009/10008 correctly identified as success? Are 10019 (no money), 10016 (invalid stops) correctly classified? |
| C4 | **Error 0 handling** | If error code is 0, is it treated as success (not re-retried)? |
| C5 | **Toast feedback** | Does `ShowTradeToast()` set correct colors (green/red)? Does it clear previous error on success? |

#### Block D — Partial Close Logic

| # | Check | What to verify |
|---|-------|----------------|
| D1 | **Original lot retrieval** | Does `GetOriginalLotSize()` correctly trace MT4 `"from #"` comment chain? Safety counter (max 50 iterations)? |
| D2 | **Percentage calculation** | `toClose = originLots * (pct / 100.0)` — is this correct for 25%, 50%, 100%? |
| D3 | **Lot normalization** | MathFloor to lotStep? Min lot enforced? If toClose > currentLots, capped? |
| D4 | **100% close** | If `pct >= 99.9`, is `toClose = currentLots` (full close)? |
| D5 | **Pending vs Market** | If `type > 1` (pending), does it call `DeleteOrder()` instead of `ClosePosition()`? |
| D6 | **MT4 successor ticket** | After partial close, does `FindMT4SuccessorTicket()` find the new ticket via `"from #"` comment? |

#### Block E — Position Modification Logic

| # | Check | What to verify |
|---|-------|----------------|
| E1 | **SL/TP change detection** | Is `MathAbs(inputSL - trade.StopLoss) > Point` used to detect real changes? |
| E2 | **BE logic** | When `g_PosBE_Active`, is SL set to `trade.OpenPrice`? Is it only allowed when position is in profit? |
| E3 | **No-change handling** | If nothing changed, does it return `MakeSuccessResult(0, "No changes")` without calling the broker? |
| E4 | **MT5 Modify: Position vs Pending** | Does `Modify()` correctly try `PositionSelectByTicket()` first, then fall back to `OrderSelect()`? |
| E5 | **MT5 OrderModify: price/expiration preservation** | When modifying a pending order's SL/TP, are `ORDER_PRICE_OPEN` and `ORDER_TIME_EXPIRATION` preserved? |

#### Block F — Handler Pipeline Safety

| # | Check | What to verify |
|---|-------|----------------|
| F1 | **License guard** | Is `g_LicenseState != LICENSE_OK` checked at the TOP of `Handle_Trading_Events()`? |
| F2 | **UX validation before engine** | Are SL <= 0 and Risk <= 0 caught BEFORE constructing TradeRequest? |
| F3 | **Symbol fallback** | If symbol from UI is empty, does it fall back to `Symbol()`? |
| F4 | **Magic number** | Is `MagicNumber` (global input) correctly passed to `req.Magic`? |
| F5 | **RiskPercent in request** | Is `GetRiskPercentage(risk)` called and put into `req.RiskPercent` for Validator check? |
| F6 | **Success cleanup** | After successful trade: is UI reset, chart lines updated, lot recalculated? |
| F7 | **Validate button — combined ops** | When partial close + modify happen together, is the sequence correct? (Close first, then modify) |

#### Block G — Engine Lifecycle & Pointer Safety

| # | Check | What to verify |
|---|-------|----------------|
| G1 | **Bridge_InitEngine()** | Is it called in `OnInit()` before any trade logic? Is double-init prevented? |
| G2 | **Bridge_DeinitEngine()** | Is `delete g_TradeEngine` called in `OnDeinit()`? Is pointer nulled after? |
| G3 | **Null pointer checks** | Does every method in `TradeOrchestrator` check `CheckPointer(g_TradeEngine) == POINTER_INVALID`? |
| G4 | **MT5 #undef/#define OrderSelect** | After TradeEngineMT5, is `#define OrderSelect FP_OrderSelect` restored? Could this break if include order changes? |

### PHASE 3 — SCORING

```
Score = 100 - (CRITICAL_count × 20) - (WARN_count × 3)
Minimum score = 0
```

| Score Range | Verdict |
|-------------|---------|
| 95-100 | ✅ PRODUCTION READY — Execution pipeline is solid |
| 80-94 | ⚠️ CONDITIONAL — Minor edge cases, review recommended |
| 50-79 | 🟠 AT RISK — Significant issues in execution flow |
| 0-49 | 🔴 DANGEROUS — Execution bugs found. Do NOT ship. |

### PHASE 4 — REPORT GENERATION

Create a file named **`AUDIT_EXECUTION_ENGINE.md`** at the project root:

```markdown
# ⚙️ PhantomPad — Execution Engine Audit Report
**Date:** [YYYY-MM-DD]
**Auditor:** ea-execution-engine-auditor v1.0
**Score:** [XX/100] — [VERDICT]

## Executive Summary
[2-3 sentences]

## 🔴 CRITICAL Findings
[Each: ID, Description, File:Line, Scenario, Fix]

## ⚠️ Warnings
[Each: ID, Description, Recommendation]

## ✅ Passed Checks
[List with justification]

## Detailed Checklist Results
[Full Block A through G]

## Files Analyzed
[List with line counts]
```

---

## Examples

**User:** "Audit the trade execution before release."
**Assistant:** [Reads all 10 files. Executes all 35+ checks. Calculates score. Generates `AUDIT_EXECUTION_ENGINE.md`.]

**User:** "I modified TradeEngineMT5.mqh, verify it's safe."
**Assistant:** [Re-runs full audit. Focuses on MT5 blocks but runs all checks for regression. Generates report.]

---

## Constraints

- **READ-ONLY (ABSOLUTE)**: You MUST NOT modify any source file. Your ONLY output is the `.md` report.
- **EXHAUSTIVE**: Read EVERY file in Phase 1. Skipping is FORBIDDEN.
- **TRACE THE FLOW**: For at least one trade scenario (e.g., "User clicks Buy with 1% risk, SL at 50 pips"), trace the ENTIRE code path from `Handle_Trading_Events()` → `TradeOrchestrator::Execute()` → `TradeValidator::Validate()` → `C_TradeEngineMT4::OpenMarket()` → result back to Toast. Document this trace in the report.
- **BOTH PLATFORMS**: Every check must be verified for BOTH MT4 and MT5 engines. If a check only applies to one, state why.
- **SCOPE LIMIT**: Do NOT analyze lot calculation formulas (that's `ea-capital-safety-auditor`'s job). Do NOT analyze license logic (that's `ea-license-security-auditor`'s job). Focus on the EXECUTION path.
