---
name: ea-security-auditor
description: A critical security and reliability audit skill for MQL4/MQL5 Expert Advisors and their backend integration. It performs a deep static analysis with an OBSESSIVE focus on User Capital Safety (Risk Management correctness, Order Execution precision) and a secondary check on Backend Security (Supabase).
---

# Expert Advisor Security Auditor

## Goal
To perform a comprehensive, non-intrusive security and reliability audit of the PhantomPad Expert Advisor (EA).
**PRIMARY MISSION (CRITICAL)**: Ensure the absolute safety of the user's trading capital. The auditor must obsessively verify that the EA respects risk parameters (Lot Size, Stop Loss, Take Profit) and that NO bug or logic error could ever lead to unintended financial loss (e.g., account draining, massive over-leveraging, executed trades deviating from user request).
**SECONDARY MISSION**: Verify the security of the backend integration (Supabase) to ensure license validity and data privacy.

This skill produces a detailed report but **strictly avoids modifying any source code or database records**.

## When to use this skill
- When requested to audit the EA for safety, reliability, or bugs.
- When verifying the mathematical correctness of lot calculation and risk management logic.
- Before major releases to ensure "Zero Critical Failures" compliance.
- When checking backend security (Supabase) as a secondary validation.

## How to use it
1.  **Scope Definition**:
    - **Target #1 (The Core)**: MQL4/MQL5 files (`.mq4`, `.mq5`, `.mqh`) - focus on trading logic.
    - **Target #2 (The Backend)**: Supabase project 'PhantomPad' (Licence table, RLS).
    - **Exclusion**: Web frontend (JS/HTML/CSS).

2.  **Static Analysis Checklist - PRIORITY 1: CAPITAL SAFETY (MQL)**:
    - **Risk Calculation Integrity (THE MOST CRITICAL CHECK)**:
        - Verify Lot Size calculation formulas. Is it mathematically impossible to open a trade larger than the user's max risk?
        - Check for division-by-zero or overflow errors in lot calculations.
        - Validate that `StopLoss` is ALWAYS present and correctly placed relative to `OpenPrice` and `OrderType`.
    - **Execution Safety**:
        - Analyze `OrderSend` loop structures. Are there safeguards against infinite order opening (e.g., "Machine Gun" bug)?
        - Check slippage handling and market execution retries.
    - **Account Protections**:
        - Does the EA check `AccountFreeMargin()` before trading?
        - Are there "Panic Switches" or circuit breakers if equity drops too fast?
    - **Input Validation**:
        - Are inputs like `RiskPercent`, `Lots`, `StopLoss` strictly validated? (e.g., prevent Risk > 100%).

3.  **Static Analysis Checklist - PRIORITY 2: BACKEND & DATA (Supabase)**:
    - **Tools**: Use `supabase_mcp_server` tools (`list_tables`, `execute_sql` in READ-ONLY mode).
    - **License Security**: Check `Licence` table RLS policies.
    - **Data Leakage**: Ensure strict access control (though secondary to capital safety).

4.  **Reporting**:
    - Create `EA_SECURITY_AUDIT.md`.
    - **Structure**:
        - **SECURITY RATING**: A Score (0-100) based on Capital Safety.
        - **🔴 CRITICAL (CAPITAL AT RISK)**: ANY bug that could lose user money (Wrong Lots, Missing SL, Infinite Loops). MUST be fixed immediately.
        - **🟠 HIGH (FUNCTIONAL FAILURE)**: Trades not opening, License bugs, Backend issues.
        - **🟡 MEDIUM (IMPORTANT)**: Code quality, Supabase RLS policies (if not critical to app function).
        - **🟢 LOW**: Optimizations.
        - **Recommendations**: Detailed fixes for every issue.

## Examples
**User:** "Audit the EA. I don't want anyone blowing their account."
**Assistant:** [Focuses 90% of analysis on `CalculateLotSize()` and `OpenOrder()` functions in .mq4 files. Finds a potential issue where `RiskPercent` isn't capped. Marks as CRITICAL. Briefly checks Supabase RLS.]

**User:** "Check for bugs."
**Assistant:** [Scans MQL for infinite loops around `OrderSend`. Verifies that StopLoss cannot be 0. Reports findings.]

## Constraints
- **Read-Only (ABSOLUTE)**: NEVER modify code or database.
- **Hierarchy of Importance**:
  - **Tier 1 (Do or Die)**: Logic that touches Money (Orders, Lots, Risk).
  - **Tier 2**: Logic that touches Connectivity (Supabase, License).
- **Zero Tolerance**: If a "Capital at Risk" bug is found, it must be highlighted with extreme urgency.
