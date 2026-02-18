# ⚙️ PhantomPad — Execution Engine Audit Report
**Date:** 2026-02-18
**Auditor:** ea-execution-engine-auditor v1.0
**Score:** 94/100 — ⚠️ CONDITIONAL

## Executive Summary
The Execution Engine of PhantomPad is robust, safe, and well-structured. The critical "Machine Gun" bug (infinite order loops) is mathematically impossible due to hard-coded retry limits in MT4 and the synchronous nature of the MT5 engine. The dispatch logic in `TradeOrchestrator` correctly isolates the GUI from the Core execution. However, two warnings were identified: the MT5 engine lacks the robust retry mechanism found in the MT4 implementation, and "Partial Close" on pending orders results in the deletion of the entire order rather than a volume reduction.

## 🔴 CRITICAL Findings
*None.*

## ⚠️ Warnings

### 1. Partial Close on Pending Orders (Logic Gap)
*   **ID:** WARN-D5
*   **File:** `Handler_PositionActions.mqh`, Line 37
*   **Description:** When a user selects a Pending Order and clicks a Partial Close button (e.g., "50%"), the logic branches to `TradeOrchestrator::DeleteOrder()`. This deletes the *entire* pending order instead of modifying its volume to 50%.
*   **Recommendation:** Clarify in the UI that partial closing a pending order is not supported, or implement a `Delete` + `OpenPending` (with reduced volume) sequence to simulate a partial close.

### 2. MT5 Engine Lacks Retry Loop
*   **ID:** WARN-A6
*   **File:** `TradeEngineMT5.mqh`
*   **Description:** Unlike the MT4 engine, which retries operations 3 times in case of "Broker Busy" or "Requote", the MT5 engine performs a single-shot execution via `CTrade`. If a Requote occurs during high volatility, the user will receive an error immediately and must click again.
*   **Recommendation:** Implement a bounded `do-while` loop around `m_trade.PositionOpen` similar to the MT4 implementation to handle `TRADE_RETCODE_REQUOTE` automatically.

## ✅ Passed Checks

*   **Anti-Machine Gun:** MT4 retry loops are strictly bounded (`m_maxRetries = 3`). No infinite `while(true)` loops exist.
*   **Price Freshness:** MT4 engine forces `RefreshRates()` and re-fetches `MarketInfo` prices immediately before execution, preventing stale price rejection.
*   **Double Execution Guard:** The synchronous event model combined with `TradeOrchestrator` validation prevents double-clicking from spawning multiple parallel orders.
*   **Input Sanitization:** All inputs (SL, TP, Risk) are validated and normalized (`NormalizeDouble`) before being sent to the broker.
*   **Error Mapping:** Broker errors are correctly translated into user-friendly messages (e.g., "Market Closed", "No Money").
*   **Pointer Safety:** `TradeOrchestrator` correctly checks `g_TradeEngine` validity before every call.

## Detailed Checklist Results

#### Block A — Machine Gun Protection
| # | Check | Verdict | Notes |
|---|-------|---------|-------|
| A1 | MT4 OpenMarket retry loop | ✅ PASS | Bounded loop (`i < 3`). |
| A2 | MT4 OpenPending retry loop | ✅ PASS | Bounded loop. |
| A3 | MT4 Modify retry loop | ✅ PASS | Correctly handles Error 1 (No result). |
| A4 | MT4 Close retry loop | ✅ PASS | Checks `OrderCloseTime > 0` before retry. |
| A5 | MT4 Delete retry loop | ✅ PASS | Bounded and checks existence. |
| A6 | MT5 Engine retry mechanism | ⚠️ WARN | Single-shot execution only. No retries. |
| A7 | Orchestrator guard | ✅ PASS | Relying on synchronous event thread safety. |

#### Block B — Price Freshness & Normalization
| # | Check | Verdict | Notes |
|---|-------|---------|-------|
| B1 | MT4 Market: fresh price | ✅ PASS | Forces `RefreshRates + MarketInfo`. |
| B2 | MT4 Market: NormalizeDouble | ✅ PASS | Applied to Price, SL, TP. |
| B3 | MT4 Pending: NormalizeDouble | ✅ PASS | Applied correctly. |
| B4 | MT4 Modify: openPrice | ✅ PASS | Re-fetches `OrderOpenPrice`. |
| B5 | MT4 Close: close price | ✅ PASS | uses `MODE_BID/ASK`. |
| B6 | MT5 Market: price | ✅ PASS | Uses passed price (User click time). |
| B7 | MT5 Partial Close: price | ✅ PASS | Correctly maps BUY->BID, SELL->ASK. |

#### Block C — Error Classification
| # | Check | Verdict | Notes |
|---|-------|---------|-------|
| C1 | Retryable errors (MT4) | ✅ PASS | Only safe errors (135-146) retried. |
| C2 | Fatal errors (MT4) | ✅ PASS | Fatal errors break loop immediately. |
| C3 | MT5 retcode mapping | ✅ PASS | 10009/10008 mapped to success. |
| C4 | Error 0 handling | ✅ PASS | Treated as Success "OK". |
| C5 | Toast feedback | ✅ PASS | Color coded (Green/Red). |

#### Block D — Partial Close Logic
| # | Check | Verdict | Notes |
|---|-------|---------|-------|
| D1 | Original lot retrieval | ✅ PASS | Traces `from #` correctly. |
| D2 | Percentage calculation | ✅ PASS | Standard formula. |
| D3 | Lot normalization | ✅ PASS | `MathFloor` to `LotStep`. |
| D4 | 100% close | ✅ PASS | Handles full close correctly. |
| D5 | Pending vs Market | ⚠️ WARN | Pending orders are Deleted, not partially closed. |
| D6 | MT4 successor ticket | ✅ PASS | Finds new ticket after partial close. |

#### Block E — Position Modification
| # | Check | Verdict | Notes |
|---|-------|---------|-------|
| E1 | SL/TP change detection | ✅ PASS | Uses `MathAbs > Point`. |
| E2 | BE logic | ✅ PASS | Validates "In Profit" before activation. |
| E3 | No-change handling | ✅ PASS | Returns success without broker call. |
| E4 | MT5 Modify: Pos vs Pending | ✅ PASS | Selects correctly. |
| E5 | MT5 Modify: preservation | ✅ PASS | Preserves Expiration/TypeTime. |

#### Block F — Handler Pipeline Safety
| # | Check | Verdict | Notes |
|---|-------|---------|-------|
| F1 | License guard | ✅ PASS | Checks `LICENSE_OK`. |
| F2 | UX validation | ✅ PASS | Checks empty inputs. |
| F3 | Symbol fallback | ✅ PASS | Defaults to `Symbol()`. |
| F4 | Magic number | ✅ PASS | Passed correctly. |
| F5 | RiskPercent | ✅ PASS | Calculated before Engine. |
| F6 | Success cleanup | ✅ PASS | Resets UI on success. |
| F7 | Validate button sequence | ✅ PASS | Partial Close FIRST, then Modify. |

#### Block G — Engine Lifecycle
| # | Check | Verdict | Notes |
|---|-------|---------|-------|
| G1 | Bridge_InitEngine() | ✅ PASS | Called in main `OnInit`. |
| G2 | Bridge_DeinitEngine() | ✅ PASS | Called in main `OnDeinit`. |
| G3 | Null pointer checks | ✅ PASS | All public methods check `g_TradeEngine`. |
| G4 | MT5 Macro safety | ✅ PASS | `#undef`/`#define` used correctly. |

## Files Analyzed
*   `MT4/Engine/TradeEngineMT4.mqh`
*   `MT5/Engine/TradeEngineMT5.mqh`
*   `Common/Core/Engine/TradeOrchestrator.mqh`
*   `Common/Core/Engine/TradeErrorHandler.mqh`
*   `Common/Core/Engine/ITradeEngine.mqh`
*   `GUI/Events/Handlers/Handler_Trading.mqh`
*   `GUI/Events/Handlers/Handler_PositionActions.mqh`
*   `Common/Core/DataTypes.mqh`
*   `Common/Core/TradeLogic/TradeCalc.mqh`
*   `GUI/Positions/Panel_Positions_Logic.mqh`
