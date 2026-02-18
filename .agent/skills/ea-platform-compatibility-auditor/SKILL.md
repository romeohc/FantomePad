---
name: ea-platform-compatibility-auditor
description: Performs an obsessive, read-only audit of the PhantomPad Expert Advisor's cross-platform compatibility layer between MT4 and MT5. Its single mission is to guarantee that the EA behaves identically on both platforms with zero silent regressions. Audits the Compatibility abstraction, Bridge pattern, platform-specific wrappers, macro safety (#define/#undef), data type mappings (int vs long tickets), and entry point parity. Produces a detailed audit report with a score out of 100. Does NOT modify any file.
---

# Expert Advisor — Platform Compatibility Auditor 🔀✅

## Goal

To perform an **exhaustive, read-only** audit of the cross-platform abstraction layer that allows PhantomPad to run on **both MT4 and MT5** from a shared codebase. This covers the `Compatibility.mqh` macros, `Bridge.mqh` engine factory, platform-specific wrappers, and the two entry point files.

The output is a single `.md` audit report. **No code is modified. Ever.**

After this audit passes with no CRITICAL findings, we can guarantee:
- Every **wrapper function** (`FP_OrderSelect`, `FP_GetTrade`, `MarketInfo` macros, etc.) produces **identical results** on MT4 and MT5.
- The **`#define` / `#undef` macro chain** for `OrderSelect` is safe and doesn't corrupt subsequent includes.
- **Ticket types** (`int` on MT4, `long` on MT5) are handled correctly everywhere.
- **`fantomepad.mq4` and `fantomepad.mq5`** are functionally equivalent (no missing logic on either side).
- **Data wrapper functions** fill `FantomeTrade` and `FantomeAccount` structs consistently across platforms.

---

## When to use this skill

- When user ask to use the "ea platform compatibility auditor" skill.
- When user ask an audit of the platform compatibility of the EA.

---

## How to use it

### PHASE 1 — FILE COLLECTION (Mandatory Reading List)

Read **ALL** of these files in full before starting any analysis.

| Priority | File | Why |
|----------|------|-----|
| 🔴 P0 | `Common/Compatibility.mqh` | The ENTIRE abstraction layer: all `#define` macros, `FP_OrderSelect()`, `FP_GetTrade()`, `FP_GetAccount()`, all `MarketInfo` wrappers for MT5 |
| 🔴 P0 | `Platform/Bridge.mqh` | Engine factory: `g_TradeEngine` pointer, `Bridge_InitEngine()`, `Bridge_DeinitEngine()` |
| 🔴 P0 | `MT4/Wrappers/Data_Wrapper.mqh` | MT4 data access helpers |
| 🔴 P0 | `MT5/Wrappers/Data_Wrapper.mqh` | MT5 data access helpers — must produce SAME results as MT4 |
| 🟠 P1 | `MT4/Wrappers/Graphic_Wrapper.mqh` | MT4 GUI object helpers |
| 🟠 P1 | `MT5/Wrappers/Graphic_Wrapper.mqh` | MT5 GUI object helpers — must produce SAME results |
| 🟠 P1 | `MT4/Engine/TradeEngineMT4.mqh` | Specifically the `#define`/`#undef` at the end |
| 🟠 P1 | `MT5/Engine/TradeEngineMT5.mqh` | Specifically `#undef OrderSelect` at top and `#define OrderSelect FP_OrderSelect` at bottom |
| 🟠 P1 | `fantomepad.mq4` | Entry point — full `OnInit()`, `OnTick()`, `OnDeinit()`, `OnChartEvent()`, `CheckAndSetNewAccount()` |
| 🟠 P1 | `fantomepad.mq5` | Entry point — same functions. Compare line by line with .mq4 |
| 🟡 P2 | `Common/Core/DataTypes.mqh` | `FantomeTrade`, `FantomeAccount` structs — the common data contract |
| 🟡 P2 | `Common/Core/Defines.mqh` | Platform detection macros |

### PHASE 2 — SYSTEMATIC ANALYSIS (Ordered Checklist)

Verdicts: ✅ **PASS**, ❌ **FAIL (CRITICAL)**, ⚠️ **WARN**

#### Block A — Compatibility.mqh Macro Safety

| # | Check | What to verify |
|---|-------|----------------|
| A1 | **`#ifdef __MQL4__` / `#else` branching** | Is every platform-specific section properly guarded? No dangling `#else` or `#endif`? |
| A2 | **`FP_OrderSelect()` (MT5 side)** | Does it correctly map MT4's `OrderSelect(ticket, SELECT_BY_TICKET)` to MT5's `PositionSelectByTicket()` / `HOrderSelect()`? |
| A3 | **`FP_GetTrade()` (MT5 side)** | Does it fill ALL fields of `FantomeTrade` correctly? Especially: `Ticket`, `Type`, `Lots`, `OpenPrice`, `SL`, `TP`, `Profit`, `Commission`, `Swap`, `Comment`, `Magic`, `TradeDigits`, `TradePoint`? |
| A4 | **`FP_GetAccount()` (MT5 side)** | Does it fill ALL fields of `FantomeAccount`? Especially: `Login`, `Leverage`, `Balance`, `Equity`, `FreeMargin`, `Margin`, `MarginLevel`, `IsTradeAllowed`, `IsExpertAllowed`? |
| A5 | **`MarketInfo()` macro (MT5 side)** | Is every `MODE_*` constant correctly mapped to MT5's `SymbolInfoDouble()` / `SymbolInfoInteger()`? Check: `MODE_BID`, `MODE_ASK`, `MODE_POINT`, `MODE_DIGITS`, `MODE_SPREAD`, `MODE_STOPLEVEL`, `MODE_LOTSIZE`, `MODE_TICKVALUE`, `MODE_TICKSIZE`, `MODE_MINLOT`, `MODE_MAXLOT`, `MODE_LOTSTEP`, `MODE_MARGINREQUIRED` |
| A6 | **`AccountFreeMargin()` macro (MT5)** | Does it map to `AccountInfoDouble(ACCOUNT_MARGIN_FREE)`? |
| A7 | **`AccountEquity()` macro (MT5)** | Does it map to `AccountInfoDouble(ACCOUNT_EQUITY)`? |
| A8 | **`AccountBalance()` macro (MT5)** | Does it map to `AccountInfoDouble(ACCOUNT_BALANCE)`? |
| A9 | **`AccountNumber()` macro (MT5)** | Does it map to `AccountInfoInteger(ACCOUNT_LOGIN)`? |
| A10 | **`IsTradeAllowed()` macro (MT5)** | Does it check `TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && MQLInfoInteger(MQL_TRADE_ALLOWED)`? |
| A11 | **`IsExpertEnabled()` macro (MT5)** | Does it check `TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)`? |
| A12 | **`IsTesting()` macro (MT5)** | Does it map to `MQLInfoInteger(MQL_TESTER)`? |

#### Block B — Macro Chain Safety (#define / #undef)

| # | Check | What to verify |
|---|-------|----------------|
| B1 | **MT5 TradeEngine: #undef OrderSelect** | Is `OrderSelect` undefined BEFORE `#include <Trade/Trade.mqh>`? (Required because CTrade uses native OrderSelect) |
| B2 | **MT5 TradeEngine: #define restore** | Is `#define OrderSelect FP_OrderSelect` written AFTER the class definition? Does this restore the macro for ALL subsequent includes? |
| B3 | **Include order in Bridge.mqh** | Is `TradeEngineMT5.mqh` included at the right position? Could changing include order break the macro chain? |
| B4 | **Double-define risk** | If `Compatibility.mqh` defines `OrderSelect` as `FP_OrderSelect`, then `TradeEngineMT5.mqh` undefs it, then redefines it — is this safe in all compile scenarios? |

#### Block C — Data Wrapper Parity

| # | Check | What to verify |
|---|-------|----------------|
| C1 | **MT4 Data_Wrapper vs MT5 Data_Wrapper** | Do both files provide the same set of helper functions? Are signatures identical? |
| C2 | **MT4 Graphic_Wrapper vs MT5 Graphic_Wrapper** | Same check for GUI object helpers |
| C3 | **OrdersTotal() on MT5** | Is there a wrapper that combines `PositionsTotal()` + `OrdersTotal()` for MT5 to match MT4's `OrdersTotal()` behavior? |
| C4 | **OrderType() on MT5** | When a position is selected, does `FP_GetTrade()` correctly map `POSITION_TYPE_BUY` → `OP_BUY(0)`, `POSITION_TYPE_SELL` → `OP_SELL(1)`? |
| C5 | **Pending order types on MT5** | Are `OP_BUYLIMIT(2)`, `OP_SELLLIMIT(3)`, `OP_BUYSTOP(4)`, `OP_SELLSTOP(5)` correctly mapped to `ORDER_TYPE_BUY_LIMIT`, etc.? |

#### Block D — Entry Point Parity (mq4 vs mq5)

| # | Check | What to verify |
|---|-------|----------------|
| D1 | **OnInit() parity** | List every action in `.mq4 OnInit()` and verify it exists in `.mq5 OnInit()`. Note any differences. |
| D2 | **OnDeinit() parity** | Same comparison |
| D3 | **OnTick() parity** | Same comparison |
| D4 | **OnTimer() parity** | Same comparison |
| D5 | **OnChartEvent() parity** | Same comparison |
| D6 | **CheckAndSetNewAccount()** | Compare MT4 version (returns bool) vs MT5 version (returns bool, takes `bool &accountChanged` by reference). Are both correct? |
| D7 | **MT5 early return on symbol switch** | In MT5 `OnInit()`, if `CheckAndSetNewAccount()` triggers a symbol switch, it returns `INIT_SUCCEEDED` early. Is this correct? Does MT4 handle this case? |

#### Block E — Type Safety Across Platforms

| # | Check | What to verify |
|---|-------|----------------|
| E1 | **Ticket type: int vs long** | MT4 tickets are `int`, MT5 are `ulong`. Is `long` used everywhere in shared code? Are casts safe? |
| E2 | **OP_* constants** | Are `OP_BUY=0`, `OP_SELL=1`, etc. defined identically on both platforms (or correctly mapped)? |
| E3 | **ENUM_ORDER_TYPE casting** | In `TradeEngineMT5`, is `(ENUM_ORDER_TYPE)type` safe given that `type` comes from the MT4-style int? |
| E4 | **datetime/uint overflow** | Are `GetTickCount()` comparisons safe on both platforms (32-bit wrap-around after ~49 days)? |
| E5 | **String functions** | Are `StringFind`, `StringSubstr`, `StringReplace` identical on both platforms? |

#### Block F — Edge Cases & Regression Risks

| # | Check | What to verify |
|---|-------|----------------|
| F1 | **Hedging mode (MT5)** | Is the MT5 account assumed to be in hedging mode? What happens in netting mode? |
| F2 | **Multi-currency account** | Does `AccountCurrency()` work on both platforms? |
| F3 | **Symbol suffix handling** | If broker uses `EURUSDm` or `EURUSD.c`, does the code handle this on both platforms? |
| F4 | **Weekend/market closed** | Does `MarketInfo()` return 0 for ASK/BID when market is closed? How does each platform wrapper handle this? |

### PHASE 3 — SCORING

```
Score = 100 - (CRITICAL_count × 20) - (WARN_count × 3)
Minimum score = 0
```

| Score Range | Verdict |
|-------------|---------|
| 95-100 | ✅ PRODUCTION READY — Cross-platform parity confirmed |
| 80-94 | ⚠️ CONDITIONAL — Minor differences, likely non-breaking |
| 50-79 | 🟠 AT RISK — Behavioral differences between MT4 and MT5 |
| 0-49 | 🔴 DANGEROUS — Critical parity failures. One platform is broken. |

### PHASE 4 — REPORT GENERATION

Create a file named **`AUDIT_PLATFORM_COMPATIBILITY.md`** at the project root:

```markdown
# 🔀 PhantomPad — Platform Compatibility Audit Report
**Date:** [YYYY-MM-DD]
**Auditor:** ea-platform-compatibility-auditor v1.0
**Score:** [XX/100] — [VERDICT]

## Executive Summary
[2-3 sentences]

## 🔴 CRITICAL Findings (Platform Parity Broken)
[Each: ID, Description, MT4 Behavior, MT5 Behavior, Impact, Fix]

## ⚠️ Warnings
[Each: ID, Description, Recommendation]

## ✅ Passed Checks
[List with justification]

## Entry Point Diff Table
[Side-by-side comparison of mq4 vs mq5 OnInit/OnTick/etc.]

## Macro Chain Diagram
[Show the #define → #undef → #define flow for OrderSelect]

## Detailed Checklist Results
[Full Block A through F]

## Files Analyzed
[List with line counts]
```

---

## Examples

**User:** "Does PhantomPad work correctly on MT5?"
**Assistant:** [Reads all files. Runs all compatibility checks. Identifies any behavioral difference. Generates `AUDIT_PLATFORM_COMPATIBILITY.md`.]

**User:** "I added a new feature, check it works on both platforms."
**Assistant:** [Re-runs full audit. Highlights any new incompatibility. Reports findings.]

---

## Constraints

- **READ-ONLY (ABSOLUTE)**: NEVER modify any source file. ONLY output is the `.md` report.
- **EXHAUSTIVE**: Read EVERY file in Phase 1. Skipping is FORBIDDEN.
- **SIDE-BY-SIDE COMPARISON**: When comparing MT4 vs MT5 implementations, create actual side-by-side comparisons (not just "they look similar"). Show concrete differences.
- **COMPILE-TIME THINKING**: Remember that MQL uses preprocessor macros. Think about what the compiler sees after macro expansion, not just what the source code looks like.
- **SCOPE LIMIT**: Do NOT deeply analyze capital safety or license logic (those are other skills). Focus ONLY on whether the SAME logic produces the SAME result on BOTH platforms.
