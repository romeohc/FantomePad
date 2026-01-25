---
name: project-architect
description: Analyzes the global project structure of PhantomPad to determine if it is optimal, scalable, and professional. Reads README.md for context and generates audit and correction reports.
---

# Project Architect

## Goal
To perform a comprehensive architectural review of the PhantomPad project, assessing its structure against professional standards for scalability and maintainability, ensuring alignment with the project's goals as defined in README.md.

## When to use this skill
- When the user asks for a project structure analysis or audit.
- When the user questions the scalability or professional quality of the project organization.
- When starting a refactoring phase centered on architectural improvements.

## How to use it
1.  **Context Gathering**:
    -   Read `README.md` to understand the project's purpose, goals, and intended architecture.
    -   List all files and directories recursively (using `list_dir` or `find_by_name`) to build a complete map of the project structure.

2.  **Analysis**:
    -   Evaluate the folder hierarchy: Is it modular? Are concerns separated (e.g., Logic vs UI vs Data)?
    -   Check for "God files" or cluttered root directories.
    -   Determine if the structure supports future growth (scalability).
    -   Compare against industry best practices for the specific language/framework (MQL4/C++).

3.  **Report Generation**:
    -   **Step 3.1**: Create `STRUCTURE_AUDIT.md`.
        -   List current structure.
        -   Highlight specific pros (what is good).
        -   Highlight specific cons (what is bad/unprofessional/unscalable).
        -   Provide a verdict: "Optimal", "Needs Minor Refactoring", or "Needs Major Overhaul".
    -   **Step 3.2**: Create `STRUCTURE_PLAN.md`.
        -   Propose the ideal directory tree.
        -   List specific actions to move/rename/refactor files.
        -   Explain *why* each change improves the project (e.g., "Moving .mqh files to include/ improves reusability").

## Examples
**User**: "Check if my project structure is good."
**Assistant**:
1. Reads `README.md`.
2. Maps file tree.
3. Critiques the flat folder structure.
4. Generates `STRUCTURE_AUDIT.md` (identifying lack of modules) and `STRUCTURE_PLAN.md` (proposing a `src/`, `include/`, `tests/` hierarchy).

## Constraints
-   Must always read `README.md` first to understand intent.
-   Must always generate the two specific output files: `STRUCTURE_AUDIT.md` and `STRUCTURE_PLAN.md`.
-   Do not apply the changes automatically; only propose them in the plan unless explicitly told to refactor.
