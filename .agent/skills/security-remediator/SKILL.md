---
name: security-remediator
description: Automatically implements security fixes and remediation steps based on the findings from a previously generated SECURITY_AUDIT.md report. It reads the audit file, locates the vulnerable code, and applies the recommended improvements to ensure the codebase meets security standards.
---

# Security Remediation Skill

## Goal
To automate the implementation of security fixes identified during a security audit. This skill ensures that vulnerabilities found by the `security-audit` skill are correctly and promptly addressed, reducing the risk of financial loss or system instability in the MetaTrader 4 expert advisor.

## When to use this skill
- Immediately after a `security-audit` has been performed and a `SECURITY_AUDIT.md` file has been created.
- When the user explicitly asks to "fix security issues" or "apply audit recommendations".
- During a maintenance phase where existing vulnerabilities need to be resolved.

## How to use it
1.  **Locate Audit Report**: Check the project root for a file named `SECURITY_AUDIT.md`. If it doesn't exist, inform the user that no pending security issues were found or that an audit needs to be run first.
2.  **Parse Findings**: Read the `SECURITY_AUDIT.md` file. Identify each finding, its severity, the affected files, and the suggested remediation steps.
3.  **Implement Fixes**: For each vulnerability:
    -   Navigate to the affected file(s).
    -   Locate the vulnerable code block described in the audit.
    -   Apply the recommended fix. Ensure that the fix adheres to the project's coding standards and logic (e.g., proper lot size normalization, error handling).
    -   If the remediation includes multiple steps, follow them sequentially.
4.  **Verification**: After applying fixes, verify that the code still makes sense and that no obvious regressions were introduced.
5.  **Audit Update**: Once all fixes are applied:
    -   Inform the user which issues have been resolved.
    -   Either delete the `SECURITY_AUDIT.md` file (if all issues are fixed) or update it to reflect the remaining issues.
    -   Optionally suggest running another `security-audit` to confirm the code score is now 100/100.

## Decision Logic
- **Complexity of Fix**: If a remediation step is vague or potentially destructive, ask the user for clarification before proceeding.
- **Dependency Awareness**: If fixing one issue affects other parts of the system (e.g., changing a function signature), ensure those call sites are also updated.
- **Priority**: Always address "Critical" and "High" severity issues first.

## Examples
### Example 1: Fixing a Division by Zero
**User:** "Fix the security issues found in the audit."
**Assistant:** [Reads SECURITY_AUDIT.md, finds a 'Critical' issue in `LotSize.mqh` regarding potential division by zero]. "I am applying the security fix for the division by zero risk in `LotSize.mqh`. I've added a check to ensure the denominator is greater than zero before the calculation." [Applies fix, deletes SECURITY_AUDIT.md]. "All security issues have been resolved."

### Example 2: Multiple Vulnerabilities
**User:** "Apply the remediation steps from the audit report."
**Assistant:** [Reads SECURITY_AUDIT.md, finds 3 issues: missing SL validation (High), hardcoded magic number (Low), and improper error handling (Medium)]. "I am starting the remediation process. I'll begin with the High severity issue: SL validation in `OrderManager.mqh`..." [Applies fixes one by one].

## Constraints
- **File Integrity**: Never delete `SECURITY_AUDIT.md` until you are certain the fixes have been correctly applied and saved.
- **Scope**: Only fix issues explicitly mentioned in the audit report or directly related to the fix (logical dependencies).
- **Safety**: Do not introduce new trading logic; stick to fixing the security/stability flaws identified.
