---
name: expert-developer
description: A high-level skill for implementing new features, modifying existing logic, and refactoring code in MQL4 projects. It ensures deep context understanding and strictly adheres to project architecture and best practices.
---

# Expert Developer

## Goal
To act as a senior MQL4 developer who can perfectly implement new features or modify existing ones by fully understanding the project's context, structure, and design patterns before writing any code.

## When to use this skill
- When the user asks to **add a new feature** (e.g., "Add a trailing stop", "Create a dashboard").
- When the user asks to **modify existing behavior** (e.g., "Change how the grid is calculated").
- When the user wants a **complex refactor** or **logic update**.
- When the user simply says "Implement this" or "Fix this logic" without specifying file modifications.

## How to use it

### Phase 1: Context & Architecture Analysis (CRITICAL)
1.  **Map the Terrain**: Run `list_dir` to see the current file structure.
2.  **Understand the Core**: Read `README.md` (if available) and the main `.mq4` file to grasp the global architecture and entry points (`OnInit`, `OnTick`).
3.  **Identify Dependencies**: If the request involves specific components (e.g., "Trade Manager"), locate the relevant `.mqh` files in `Include/`.
4.  **Style Check**: Briefly read a related file to understand the coding style (indentation, naming conventions, class structure).

### Phase 2: Implementation Planning
1.  **Decompose the Request**: Break down the user's request into technical steps.
    *   *Example*: "Add a dashboard" -> Create `Dashboard.mqh`, add `Draw()` method, call it in `OnTick`, handle object cleanup in `OnDeinit`.
2.  **Impact Analysis**: Determine which existing files need to be modified and which new files need to be created.
3.  **Drafting**: (Internal Thought) Outline the changes. Ensure hooks are placed in the right events (`OnTick`, `OnTimer`).

### Phase 3: Execution
1.  **Create New Components**: If a new feature requires a new class/module, create it in the appropriate `Include/` subdirectory (e.g., `Include/FantomePad/UI/`).
2.  **Integrate**: Modify the main `.mq4` or parent `.mqh` files to include and instantiate the new component.
3.  **Logic Implementation**: Write the logic.
    *   **Strict MQL4 Compliance**: No pointers to classes unless strictly managed. Use references (`&`) where appropriate.
    *   **Memory Management**: Always clean up Graphical Objects in `OnDeinit`.
    *   **Safety**: Check for `IsStopped()` loops using `Sleep()`.
4.  **Refine**: Ensure variable names and comments explain *why*, not just *what*.

### Phase 4: Verification
1.  **Review Changes**: Check if the implemented code respects the initial constraints.
2.  **Compilation Check**: (If enabled) Run a compile check or verify syntax validity mentally (brackets, semicolons).
3.  **User Feedback**: Present the changes and explain *how* they integrate with the existing structure.

## Examples

### Example 1: Adding a News Filter
1.  **User**: "Add a news filter that stops trading 30 mins before high impact news."
2.  **Agent**:
    *   Reads `README.md` to see where "Filters" are stored.
    *   Creates `Include/FantomePad/Filters/NewsFilter.mqh`.
    *   Modifies `FantomePad.mq4` to include `NewsFilter.mqh`.
    *   Updates the `OnTick` logic to check `NewsFilter.CanTrade()` before opening orders.

### Example 2: Modifying Lot Calculation
1.  **User**: "Change the lot sizing to be based on free margin instead of balance."
2.  **Agent**:
    *   Locates `MoneyManagement.mqh`.
    *   Finds `CalculateLotSize()` function.
    *   Changes `AccountBalance()` to `AccountFreeMargin()`.
    *   Adjusts any risk formulas accordingly.

## Constraints
- **Preserve Structure**: Do not move files unless explicitly asked.
- **MQL4 Limits**: Remember MQL4 specificities (no multiple inheritance, limited standard library).
- **Clean Code**: Use functions instead of massive code blocks in `OnTick`.
- **Safety**: Always double-check logic that executes orders (`OrderSend`, `OrderClose`).
