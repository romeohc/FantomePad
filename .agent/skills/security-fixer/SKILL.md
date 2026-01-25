---
name: security-fixer
description: Applies security remediation fixes based on an audit report and a fix guide. It reads the audit context and the specific fix instructions to patch vulnerabilities efficiently.
---

# Security Fixer

## Goal
To apply security patches and improvements to the codebase by strictly following a generated audit report and a detailed remediation guide.

## When to use this skill
- When `SECURITY_AUDIT.md` and `SECURITY_FIX_GUIDE.md` files are present.
- After a security audit has been performed and fixes need to be implemented.
- When the user explicitly asks to "fix security bugs" or "apply the security guide".

## How to use it
1. **Context Acquisition**:
   - Locate and read `SECURITY_AUDIT.md` to understand the high-level security issues and vulnerabilities found.
   - Locate and read `SECURITY_FIX_GUIDE.md` to understand the specific implementation steps required.

2. **Assessment & Planning**:
   - Evaluate the complexity of the fixes described in `SECURITY_FIX_GUIDE.md`.
   - Determine if the fixes can be applied in a single pass (one-shot) or if they require a multi-step approach due to volume or complexity.
   - If splitting is needed, identify logical break points (e.g., by file, by module, or by vulnerability type).

3. **Implementation**:
   - Apply the code changes as specified in `SECURITY_FIX_GUIDE.md`.
   - Ensure you are strictly following the guide's recommendations.
   - Use the appropriate file editing tools (`replace_file_content` or `multi_replace_file_content`).

4. **Verification (Manual)**:
   - After applying fixes, verify that the changes match the instructions.
   - Ensure no syntax errors were introduced.

5. **Cleanup**:
   - Once ALL fixes are successfully applied and verified, DELETE the `SECURITY_AUDIT.md` and `SECURITY_FIX_GUIDE.md` files.
   - Do NOT delete them if the process was split into multiple turns and is not yet fully complete.

## Decision Logic
- **Complexity Check**:
  - IF the `SECURITY_FIX_GUIDE.md` contains > 4 major sections OR involves > 10 files:
    - Plan to execute in multiple turns.
    - Inform the user you will start with Part 1 and ask for confirmation to proceed to the next parts.
  - ELSE:
    - Execute all fixes in a single turn (one-shot).

## Examples
**User:** "Fix the security issues found."
**Agent:** Reads `SECURITY_AUDIT.md` and `SECURITY_FIX_GUIDE.md`, sees 3 minor fixes, and applies them all immediately.

**User:** "Apply the security patches."
**Agent:** Reads the files, sees a complex refactor required across 20 files. Decides to split it: "I will start by fixing the Input Validation vulnerabilities (Part 1). Shall I proceed?"

## Constraints
- **Strict Adherence**: Do not deviate from `SECURITY_FIX_GUIDE.md` unless there is a clear syntax error or logical impossibility.
- **Safety**: Only delete the audit and guide files after ALL fixes have been fully implemented and verified.
