---
name: bug-fixer
description: Diagnoses and resolves bugs, compilation warnings, and runtime errors in MQL4 projects by analyzing context, detecting root causes, and implementing precise fixes.
---

# Bug Fixer

## Goal
To autonomously identify, analyze, and correct software defects (bugs, warnings, runtime errors) in the MQL4 Expert Advisor project with minimal user input.

## When to use this skill
- When the user reports a compilation warning or error.
- When the user describes a runtime bug (e.g., "orders not closing", "wrong display").
- When the user provides an error log or a description of a visual glitch (screenshot content).
- When the user asks to "fix this specific issue" or "debug why this isn't working".

## How to use it
1. **Context Acquisition (Understand)**:
   - READ `README.md` to understand the project's purpose and high-level architecture.
   - USE `view_file_outline` on relevant main files (e.g., `FantomePad.mq4`, `Trade.mqh`, or files mentioned in the error) to grasp the structure.
   - IDENTIFY dependencies related to the issue.

2. **Issue Detection (Detect)**:
   - ANALYZE the error message, warning log, or user description.
   - SEARCH for relevant code sections using `grep_search` if the file location is not explicit.
   - FORMULATE a hypothesis for the bug (e.g., "Uninitialized variable", "OrderSend error 130", "Logic error in trailing stop", "Array out of range").
   - VERIFY the hypothesis by inspecting the code logic (using `view_file` around the suspected area).

3. **Remediation (Fix)**:
   - PLAN the fix. Ensure it adheres to MQL4 syntax and project style.
   - APPLY the fix using `replace_file_content` or `multi_replace_file_content`.
   - IMPLICITLY CHECK for side effects (e.g., changing a global variable that affects other modules).

4. **Verification**:
   - EXPLAIN to the user what caused the bug (the "root cause") and how it was fixed.
   - SUGGEST verifying the fix by compiling or re-running the test.

## Examples
**Example 1: Compilation Warning**
- **Trigger**: "I have a warning: 'possible loss of data due to type conversion' in Signal.mqh line 45."
- **Action**: Read `Signal.mqh`, go to line 45. See `int i = someDouble;`. Change to `int i = (int)someDouble;` or `double i = someDouble;` to resolve warning.

**Example 2: Logic Error**
- **Trigger**: "The bot is not taking Sell orders but Buy orders work fine."
- **Action**: Check `Trade.mqh` or `Signal.mqh`. Look for `OrderSend` with `OP_SELL`. debug valid price (Bid for sell). If `Ask` was used for Sell open, fix to `Bid`.

## Constraints
- **Scope**: Focus ONLY on the reported bug. Do not refactor unrelated code unless it's directly causing the bug.
- **Safety**: Do not delete large blocks of code without understanding. Use comments if uncertain but need to disable code.
- **MQL4 Specifics**: Respect MQL4 limitations (e.g., `Start` vs `OnTick`, strict type checking).
