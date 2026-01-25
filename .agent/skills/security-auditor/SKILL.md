---
name: security-auditor
description: Performs a comprehensive security audit on MQL4 Expert Advisors, focusing on order management, risk control, and input validation. Generates an audit report and a remediation guide.
---

# Security Auditor

## Goal
To perform a rigorous security analysis of MQL4 Expert Advisors to prevent financial loss, logic errors, and runtime crashes. It ensures the code is robust enough for real-money trading by detecting dangerous patterns and producing actionable remediation plans.

## When to use this skill
- When the user asks for a security check, audit, or review of their MQL4 project.
- Before deploying an Expert Advisor to a live trading account.
- When making significant changes to order execution or money management logic.
- When the user mentions "real money", "account safety", or "risk management".

## How to use it
1.  **Deep Code Analysis**:
    -   Recursively read all `.mq4` and `.mqh` files in the project.
    -   Analyze for specific MQL4 security patterns:
        -   **Order Execution Safety**:
            -   Are return values of `OrderSend`, `OrderModify`, `OrderClose`, `OrderDelete` checked?
            -   Is `GetLastError()` used to diagnose failures?
            -   Is there logic to handle specific errors (e.g., `ERR_REQUOTE`, `ERR_SERVER_BUSY`)?
            -   Is `RefreshRates()` called before trading actions in loops or after delays?
        -   **Risk & Money Management**:
            -   Are Lot sizes validated against `MarketInfo(MODE_MINLOT)`, `MODE_MAXLOT`, and `MODE_LOTSTEP`?
            -   Is there a check for sufficient Free Margin before opening trades?
            -   Are StopLoss and TakeProfit normalized using `Digits` or `Point`?
            -   Is there a helper to check `StopLevel` requirements?
        -   **Logic & Runtime Stability**:
            -   Are loops (especially `while`) safe from infinite execution (break conditions/timeouts)?
            -   Are there potential Division by Zero errors?
            -   Is the `MagicNumber` used for all order selection loops to avoid managing other EAs' trades?
            -   Are array bounds checked if dynamic arrays are used?
        -   **Input Validation**:
            -   Are external variables (`extern` or `input`) validated in `OnInit()` (e.g., avoiding negative Slippage, TakeProfit < 0)?

2.  **Generate Audit Report (`SECURITY_AUDIT.md`)**:
    -   Create (or overwrite) a file named `SECURITY_AUDIT.md` in the root of the project.
    -   **Structure**:
        -   **Executive Summary**: A high-level safety score (0-100%) and simple pass/fail status.
        -   **Critical Issues**: Imperative fixes (potential for immediate financial loss).
        -   **Warnings**: Dangerous practices (potential for bugs/unreliability).
        -   **Observations**: Suggestions for best practices.
    -   For each issue, include:
        -   **File**: e.g., `TradeFunctions.mqh`
        -   **Line**: e.g., `42`
        -   **Snippet**: The problematic code.
        -   **Risk**: Why this is dangerous (e.g., "Loop may send infinite orders on error").

3.  **Generate Fix Guide (`SECURITY_FIX_GUIDE.md`)**:
    -   Create (or overwrite) a file named `SECURITY_FIX_GUIDE.md` in the root of the project.
    -   This must be a "Battle Plan" or "Checklist" format.
    -   Group fixes by priority (Phase 1: Critical, Phase 2: Refactoring).
    -   For each fix, provide:
        -   **Context**: What needs to change.
        -   **Step-by-Step Instruction**: "Open file X, go to function Y..."
        -   **Corrected Code Block**: Provide the COPY-PASTE safe implementation.
    -   Example: "Replace `OrderSend(...)` with this wrapper function that handles errors..."

## Examples
**User:** "Audit my EA for safety."
**Assistant:**
1.  Reads the codebase.
2.  Identifies that `OrderSend` is called without checking the boolean return value.
3.  Identifies that LotSize is calculated as `AccountBalance()/1000` without checking min/max lots.
4.  Creates `SECURITY_AUDIT.md` flagging these as CRITICAL.
5.  Creates `SECURITY_FIX_GUIDE.md` providing a `OpenOrderSafe()` wrapper function and a `CalculateLotSizeSafe()` function.

## Constraints
-   **Methodology**: This skill is a static analysis helper. It does not run the code in a backtester.
-   **Criticality**: Treat every potential order execution flaw as CRITICAL. We deal with real money.
-   **Completeness**: Do not stop at the first error. Scan the entire project.
-   **Output**: The two report files are mandatory deliverables.

