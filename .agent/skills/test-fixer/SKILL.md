---
name: test-fixer
description: Analyzes test results from 'FantomePad_TestRunner' and fixes failed tests. Distinct from general debugging, it focuses on logic errors revealed by the 'Include/FantomePad/Tests' suite.
---

# Test Fixer

## Goal
To autonomously resolve functional defects and logical errors detected by the `FantomePad_TestRunner` Expert Advisor. This skill bridges the gap between test failure logs and code remediation by understanding the project structure, analyzing specific test cases, and correcting the underlying implementation.

## When to use this skill
- When the USER provides output, logs, or screenshots from running `FantomePad_TestRunner`.
- When specific assertions or test cases fail in `Include/FantomePad/Tests/` (e.g., `Test_Risk.mqh`, `Test_UI.mqh`, `Test_Framework.mqh`).
- When the goal is to correct logic errors (wrong return values, incorrect state updates) rather than syntax/compilation errors.

## How to use it

### 1. Initialization & Context Analysis
1.  **Read Documentation**: ALWAYS start by reading `README.md` (if available) to ground your understanding of the project's intended behavior and architecture.
2.  **Analyze Test Runner**: Briefly review `FantomePad_TestRunner.mq4` if you need to understand the execution order or environment setup.
3.  **Analyze Test Suite**: Identify which test suite is failing (e.g., Risk, UI) and read the corresponding file in `Include/FantomePad/Tests/`.

### 2. Failure Diagnosis
1.  **Parse Output**: Look at the user-provided log. Identify the specifically failing function name (e.g., `Test_CalculateLotSize_RiskPercent`) and the failure message (e.g., "Expected X, got Y").
2.  **Trace Logic**:
    *   Open the test file (e.g., `Test_Risk.mqh`) and locate the failing test function.
    *   Identify the production functions being called by the test.
    *   Open the production code files (e.g., in `Include/FantomePad/Core/` or `Include/FantomePad/Trade/`) to examine the actual logic.

### 3. Execution & Remediation
1.  **Formulate Hypothesis**: detailed reasoning on why the code failed the test (e.g., "The stop loss calculation fails to account for JPY pairs").
2.  **Apply Fix**:
    *   If the Implementation is wrong: Correct the logic in the source code.
    *   If the Test is wrong: Update the test expectation if it was based on outdated assumptions.
3.  **Verify**: Explain to the user what was changed and, if possible, ask them to re-run `FantomePad_TestRunner` to verify the fix.

## Examples

### Example 1: Logic Error in Risk Calculation
**Trigger**: User says "The risk test failed, getting wrong lot size."
**Process**:
1.  Read `README.md`.
2.  Read `Include/FantomePad/Tests/Test_Risk.mqh`.
3.  See that `Test_Risk_Percent` expects `0.10` lots for 1% risk but got `0.01`.
4.  Trace usage to `Risk_Master.mqh`.
5.  Find bug: `double lots = accountBalance * risk / 10000;` (should be `100`).
6.  Fix `Risk_Master.mqh`.

### Example 2: UI State Mismatch
**Trigger**: User says "UI Toggle test failed."
**Process**:
1.  Read `README.md`.
2.  Read `Include/FantomePad/Tests/Test_UI.mqh`.
3.  Test expects `IsPanelVisible()` to be `true` after `TogglePanel()`.
4.  Read `Include/FantomePad/GUI/GUI_Master.mqh`.
5.  Discovery: `TogglePanel` sets an internal boolean but doesn't redraw.
6.  Fix: Add `ChartRedraw()` or update the boolean logic in `GUI_Master.mqh`.

## Constraints
- **Strict Scope**: Do not try to fix compilation errors unless they block the specific test you are fixing. Use `bug-fixer` for general compilation issues.
- **Test Integrity**: Prefer fixing the implementation over changing the test, unless the test is demonstrably incorrect.
- **Context Awareness**: Always refer to `README.md` before making architectural assumptions.
