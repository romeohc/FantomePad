---
name: code-optimizer
description: Analyzes large files to decompose them into smaller, modular components and remove redundancy while strictly preserving logic and integrity.
---

# Code Optimizer

## Goal
To refactor and "compress" large, monolithic source files into cleaner, distributed architectures without altering compile-time or run-time logic. The aim is to improve maintainability and developer experience while keeping the end-user behavior identical.

## When to use this skill
- **ONLY when explicitly requested by the user.**
- When the user specifically tags a file and asks to "reduce", "decompose", "compress", or "optimize" it.
- Do **NOT** use this skill autonomously just because a file appears large. It requires a clear user trigger identifying the specific file to process.

## How to use it
1.  **Input Identification**:
    - Ask the user to tag or specify the target file(s) to optimize if not already provided.
    - Confirm the file path.

2.  **Contextual Analysis**:
    - Read the target file content (use `view_file` or `view_file_outline`).
    - Read `README.md` to understand the global project architecture.
    - Read connected files (dependencies, includes) to understand the dependency graph.

3.  **Refactoring Strategy**:
    - **Decomposition**: Identify logical blocks (classes, distinct functional groups) that can be moved to separate files.
    - **Optimization**: Identify redundant code or unused variables that can be safely removed.
    - **Safety Check**: Ensure that moving code does not break privacy (private/protected members) or scope.

4.  **Proposal**:
    - Present a plan to the user: "I will move Class X to `Include/NewFile.mqh`, extract Function Y to `Utils/Y.mqh`..."
    - Explain *why* this benefits the structure.

5.  **Execution (Iterative)**:
    - Create the new destination files with `write_to_file`.
    - Update the original file to `#include` the new files or remove the moved logic.
    - **CRITICAL**: Do NOT change logic. `if (a > b)` must remain `if (a > b)`.
    - **CRITICAL**: Maintain the global structure described in `README.md`.

6.  **Verification**:
    - Review the changes.
    - Verify that all dependencies are correctly included.
    - Ensure no functionality is lost.

## Examples
**User:** "This `Main.mq4` is too big, compress it."
**Assistant:**
1.  Reads `Main.mq4`.
2.  Notices `SignalStrategy` class and `RiskManager` class are defined inline.
3.  Creates `Include/Strategy/SignalStrategy.mqh` and `Include/Risk/RiskManager.mqh`.
4.  Moves code to new files.
5.  Modifies `Main.mq4` to `#include <Strategy/SignalStrategy.mqh>` and `#include <Risk/RiskManager.mqh>`.

## Constraints
- **Zero Logic Change**: The runtime behavior must be 100% identical.
- **Project Structure**: Respect the existing folder hierarchy found in `README.md`.
- **Prudence**: If a specialized logic is unclear, ask before moving.
- **Language**: This skill is optimized for MQL4/C++ like languages but applies generally.
