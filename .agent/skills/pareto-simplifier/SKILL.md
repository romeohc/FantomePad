---
name: pareto-simplifier
description: Applies the Pareto principle (80/20) to drastically reduce project size and complexity without altering user functionality. ANALYZES the project to identify the most impactful simplifications and generates an audit and an implementation plan. DOES NOT MODIFY CODE directly.
---

# Pareto Simplifier

## Goal
To drastically reduce the codebase size and complexity by identifying the critical 20% of files and logic that contribute to 80% of the bloat or maintenance burden.
**CRITICAL:** This skill is **READ-ONLY** regarding code modification. Its sole purpose is to ANALYZE and generate two specific documents (`PARETO_AUDIT.md` and `PARETO_PLAN.md`) that another agent will use to execute the changes.

## When to use this skill
- When the user asks to "simplify the project", "clean up the code", "use the 80/20 rule", "use pareto principle" or "remove bloat".
- When the project has accumulated technical debt, unused files, or duplicate logic.
- When the goal is to identify *what* to cut to achieve maximum simplification with minimum effort.

## How to use it
1.  **Deep Scan & Pareto Analysis**:
    -   Identify the largest files and most complex directories.
    -   Detect global duplications, unused functions, dead code, and over-engineered abstractions.
    -   Focus on the "Vital Few": Which 20% of the code causes 80% of the complexity?

2.  **Generate `PARETO_AUDIT.md`**:
    -   Create this file to document the *findings*.
    -   List specific opportunities for reduction (e.g., "Merge Handler A and B", "Delete unused Class C").
    -   Explain *why* each item is a target (e.g., "Reduces LOC by 200", "Removes cyclic dependency").
    -   Classify findings by impact (High/Medium/Low).

3.  **Generate `PARETO_PLAN.md`**:
    -   Create this file to provide the *instructions*.
    -   Write a step-by-step guide for another agent (e.g., `structure-fixer` or `expert-developer`) to execute.
    -   Steps must be actionable and atomic (e.g., "1. Delete file X", "2. Move function Y from file A to B").
    -   Include verification steps for the executor to ensure iso-functionality.

4.  **Completion**:
    -   Once the two files are created/updated, notify the user.
    -   **DO NOT** apply the fixes yourself.

## Decision Logic
-   **Found dead code?** -> Log it in the Audit. Add usage evidence.
-   **Found duplicate logic?** -> Log it in the Audit. Propose a unification strategy in the Plan.
-   **Found complex/bloated file?** -> detailed analysis in Audit on how to decompose or simplify.

## Outputs
1.  **PARETO_AUDIT.md**: The "Why" and "What". The diagnostic report.
2.  **PARETO_PLAN.md**: The "How". The execution script for the next agent.

## Examples
**User:** "Analyze the project for simplification."
**Agent:** Scans project. Finds `OldLibrary.mqh` is unused and `GridLogic.mqh` is duplicated.
*Generates PARETO_AUDIT.md*: Lists these findings with impact analysis.
*Generates PARETO_PLAN.md*:
1. Delete `OldLibrary.mqh`.
2. Delete `GridLogic.mqh` and update references to `NewGridLogic.mqh`.
*Responds*: "I have generated the audit and plan. You can now use an execution skill."

## Constraints
-   **NO CODE MODIFICATION**: Do not delete or change existing code files (except to create the audit/plan files).
-   **Strict Iso-functionality Goal**: The plan must ensure the end result changes NOTHING for the user.
-   **High Impact Only**: Do not list trivial changes (like formatting) unless they are part of a massive cleanup. Focus on the 80/20.
