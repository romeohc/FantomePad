---
name: security-audit
description: Performs a deep security and reliability audit of the project, focusing on mission-critical logic like trading calculations, risk management, and financial execution. It analyzes the project context, identifies high-risk areas, and generates an audit report if vulnerabilities are found.
---

# Security Audit Skill

## Goal
To ensure the integrity, safety, and reliability of the codebase, especially regarding financial transactions and trading logic. This skill aims to protect users from potential monetary losses caused by software bugs or security flaws.

## When to use this skill
- Before a major release or deployment.
- After modifying core trading or calculation logic.
- When performing a general project health check.
- When the user specifically asks for a security audit or risk assessment.

## How to use it
1.  **Project Understanding**: Start by reading the `README.md` and exploring the project structure to understand what the application does and identifies its most critical components (e.g., lot calculation, order execution).
2.  **High-Risk Area Identification**: Search for files containing logic related to:
    -   Lot size calculation and risk management (percentage of balance, fixed lot, etc.).
    -   Trade execution (opening/closing positions).
    -   User authentication or API key handling (if applicable).
    -   Input validation for trading parameters.
3.  **In-Depth Analysis**: Examine the identified files for:
    -   Logical errors (e.g., incorrect formulas, division by zero).
    -   Edge cases (e.g., very low balance, high volatility, market gaps).
    -   Stability issues (e.g., infinite loops, improper error handling from the trading server).
    -   Security vulnerabilities (e.g., hardcoded secrets, unprotected data).
4.  **Scoring**: Assign a security score out of 100 based on the findings.
5.  **Outcome Action**:
    -   **Option A (Perfect Security - 100/100)**: If no issues are found, confirm that the audit was completed, summarize the checks performed, and state that the application is secure and robust.
        -   **Do NOT create any file.**
        -   **CRITICAL**: If a `SECURITY_AUDIT.md` file already exists in the project root from a previous audit, **DELETE it** to signify that the codebase is now clean and all issues have been addressed.
    -   **Option B (Vulnerabilities Found - <100/100)**: Create or update the file named `SECURITY_AUDIT.md` in the project root. This file must include:
        -   **Summary**: Overview of the security state.
        -   **Score**: The audit score out of 100.
        -   **Findings**: A detailed list of each vulnerability found, categorized by severity (Critical, High, Medium, Low).
        -   **Impact**: Explanation of what could happen if the vulnerability is exploited or occurs (e.g., "User could lose 100% of their account balance").
        -   **Remediation**: Step-by-step instructions or code snippets on how to fix each issue.

## Decision Logic
- **Criticality Focus**: Priority must be given to logic that handles money (trading, lot calculation). A bug in the UI is a "Low" priority, whereas a bug in risk management is "Critical".
- **False Positives**: Carefully verify if a "potential" bug is actually handled elsewhere in the code before reporting it.
- **Perfect Score Threshold**: 100/100 is ONLY for codebases with NO security flaws, robust error handling, and high-quality implementation of financial logic.

## Examples
### Example 1: Perfect Audit
**User:** "Run a security audit on the project."
**Assistant:** [Analyses README, Trade_Calculations.mqh, Trade_Execution.mqh...] "I have completed a thorough security audit. I found that all calculations are properly validated and error returns from the server are correctly processed. The security score is 100/100. The project is perfect and robust. No security audit file was created (and any existing one has been removed)."

### Example 2: Vulnerabilities Found
**User:** "Check the security of my expert advisor."
**Assistant:** [Detects a division by zero risk in `LotSize.mqh`] "I have performed the security audit and identified some issues. I have created a `SECURITY_AUDIT.md` file with the details. The current security score is 85/100."

## Constraints
- **Scope**: Focus primarily on logic that can cause financial loss or system instability.
- **Accuracy**: Do not report trivial issues as critical security flaws.
- **Output**: ONLY create or maintain `SECURITY_AUDIT.md` if the score is less than 100. If the score is 100, ensure NO such file exists.

