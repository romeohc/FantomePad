# Security Audit Report for FantomePad

**Date**: 2026-01-25
**Auditor**: Antigravity (Security Auditor Skill)
**Target**: FantomePad MQL4 Expert Advisor

## Executive Summary
**Safety Score**: 85% (PASS with WARNINGS)

The `FantomePad` Expert Advisor demonstrates a solid foundation for trade execution safety. The `SafeOrderSend` wrapper correctly implements retries, error handling, and `RefreshRates`. Risk calculations are centralized and generally robust against division-by-zero errors.

However, a **CRITICAL** omission was found regarding pre-trade margin checks, which could lead to execution failures (`ERR_NOT_ENOUGH_MONEY`) that are not currently handled by the retry logic. Additionally, the risk calculation logic forces a minimum lot size even if the calculated risk is lower, potentially exposing small accounts to higher-than-intended risk.

## Critical Issues (Immediate Fix Required)
### 1. Missing Pre-Trade Margin Check
-   **File**: `Include/FantomePad/Trade/Trade.mqh`
-   **Functions**: `SafeOrderSend` (lines 36-37 commented out)
-   **Risk**: High. If the account does not have enough free margin, `OrderSend` will fail with Error 134. This error is not in the "retryable" list, causing the trade to fail immediately without user feedback on *why* (other than a generic error toast).
-   **Snippet**:
    ```cpp
    // Check Free Margin (Optional but good)
    // ...
    ```

## Warnings (Potential Logic/Safety Flaws)
### 1. Risk Floor (MinLot Clamping)
-   **File**: `Include/FantomePad/Trade/Trade.mqh`
-   **Function**: `CalculateLotSize` (lines 388-389)
-   **Risk**: Moderate. If the user wants to risk $10, but the stop loss distance requires a lot size of 0.005 (where `MinLot` is 0.01), the code forces `lotSize = 0.01`. This effectively doubles the intended risk without warning the user.
-   **Snippet**:
    ```cpp
    if(lotSize < minLot) lotSize = minLot; 
    ```

### 2. Unvalidated External Inputs
-   **File**: `Include/FantomePad/Core/Defines.mqh` & `Include/FantomePad/Trade/Trade.mqh`
-   **Variable**: `MaxSlippage`
-   **Risk**: Low. `MaxSlippage` is taken directly from user input without validation. A negative value could cause `OrderSend` to fail or behave unpredictably.
-   **Snippet**:
    ```cpp
    int slippagePoints = GetSlippagePoints(MaxSlippage);
    ```

## Observations
-   **Good Practice**: `SafeOrderSend` correctly refreshes rates inside the retry loop.
-   **Good Practice**: Division by zero is prevented in `CalculateLotSize` by checking `MathAbs(entry - sl) <= Point`.
-   **Good Practice**: Error handling uses `GetLastError()` and provides user feedback (Toasts).
