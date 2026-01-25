---
name: structure-fixer
description: Executes a structural refactoring of the project by strictly following a provided plan. Reads STRUCTURE_AUDIT.md for context and STRUCTURE_PLAN.md for execution steps. Deletes these files upon completion.
---

# Structure Fixer

## Goal
To automate the restructuring of the project by executing a pre-defined plan found in `STRUCTURE_PLAN.md`, using `STRUCTURE_AUDIT.md` for context. The skill acts as an executor, not a decision maker regarding the new structure.

## When to use this skill
- When the files `STRUCTURE_AUDIT.md` and `STRUCTURE_PLAN.md` exist in the project root.
- When the user requests to apply structural changes or fix the project structure based on a generated plan.

## How to use it
1.  **Context Acquisition**:
    -   Read `STRUCTURE_AUDIT.md` to understand the current state and the reasons for the change.
    -   Read `STRUCTURE_PLAN.md` to understand the specific steps required for the restructuring.

2.  **Execution**:
    -   Follow the steps in `STRUCTURE_PLAN.md` meticulously.
    -   Do not deviate from the plan unless a critical error prevents execution (in which case, stop and ask the user).
    -   **Iterative Approach**: If the plan is complex (many steps, large file changes), execute it in multiple logical chunks (e.g., move files first, then update includes, then fix broken references). It is not required to complete everything in a single turn if the risk of error is high.

3.  **Documentation Update**:
    -   Once the restructuring is complete, read the `README.md` file.
    -   Check if there is a section describing the project structure.
    -   **Update**: If the structure description in `README.md` is outdated due to the changes made, update it to reflect the new reality.
    -   **No Action**: If the `README.md` is accurate or does not describe the structure, do NOT modify it.

4.  **Completion & Cleanup**:
    -   Once all steps are executed and documentation is verified:
    -   **DELETE** `STRUCTURE_AUDIT.md`.
    -   **DELETE** `STRUCTURE_PLAN.md`.

## Constraints
-   **Strict Adherence**: Do not invent new structural patterns. Follow `STRUCTURE_PLAN.md`.
-   **Cleanup Mandatory**: The skill is NOT finished until the two source files are deleted.
-   **Safety**: If a step involves deleting code (other than the plan files), ensure it's part of the plan.
