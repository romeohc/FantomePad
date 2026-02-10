---
name: ea-feature-architect
description: Comprehensive architect for implementing ANY new feature in the FantomePad Expert Advisor. Ensures one-shot delivery with perfect structural integrity.
---

# EA Feature Architect

## Goal
To perfectly implement any request for a new feature, panel, or logic within the FantomePad Expert Advisor on the first attempt.

## When to use this skill
- Use this skill when the user asks to add, create, or implement a new feature or functionality specifically for the Expert Advisor (MQL4).
- Use this as the default framework for any EA-related development to ensure consistency with the existing project DNA.

## How to use it (Architectural Protocol)

### 1. Intelligence Pre-flight (Automated)
Before writing any code, the agent MUST internally map the feature against these 5 pillars:
- **Identifier**: Define a unique 3-4 letter Trigram (e.g., `SYM_` for Symbol, `ACC_` for Account).
- **State Registry**: Define a `TPanelState` instance in `Include/FantomePad/Core/Defines.mqh`.
- **Event Flow**: Map the hook chain: `GUI_Master.mqh` -> `GUI_Event_*.mqh` -> `Handler_*.mqh`.
- **Z-Order Layer**: Assign a priority (1-9: Background, 10-50: Content, 60-99: Popups/Lists, 100+: Alerts).
- **Persistence**: Add the state to `SaveConfig/LoadConfig` in `Include/FantomePad/Core/Config.mqh`.

### 2. Implementation Methodology
1. **Model & State**: Update `Defines.mqh` with the required globals and structs. Initialize them in `InitGlobals()`.
2. **UI Framework**: Create the module in `Include/FantomePad/GUI/[Module]/`.
   - Use `Components.mqh` primitives exclusively.
   - Use `g_Color*` tokens for all colors (NEVER hardcode hex or `clr*`).
   - Implement an idempotent `Create[Name]Panel()` function (checks `ObjectFind` first).
3. **Logic & Handlers**:
   - Create/Update a file in `Include/FantomePad/GUI/Events/Handlers/`.
   - Ensure the handler returns `true` if the event was consumed to prevent event bubbling.
4. **Integration (The Master Connect)**:
   - Include the new panel in `GUI_Master.mqh`.
   - Register the handler in the `GUI_OnChartEvent` dispatcher.
   - Add the panel's redraw call to `RefreshAllPanels()`.

### 3. Verification Checklist (Internal Audit)
- **Modularity**: Is every file under 300 lines? (Refactor into `_Layout.mqh` or `_Logic.mqh` if needed).
- **Prefix Safety**: Does every object start with `PREFIX + Trigram`?
- **Responsiveness**: Does the feature handle `OnEvent_Resize` correctly?
- **Multi-Instance**: Does every order scan (`OrderSelect`) filter by `MagicNumber`?
- **Bidirectional UI**: If risk or lot changes, is the corresponding recalculation hook called?

## Decision Logic
- **If UI is complex**: Split into `Panel_Name_UI.mqh` (rendering) and `Panel_Name_Logic.mqh` (calculations).
- **If feature is an Overlay**: Use Z-Order 150+ and block background clicks via `g_BlockClick`.
- **If feature needs data**: Use `OnTick` with a 500ms throttle (via `GUI_OnTick`).

## Constraints
- **Zero Hardcoding**: All aesthetics MUST follow the `Defines.mqh` tokens.
- **No Direct Object Creation**: Use the `Components.mqh` wrapper functions (CreateRect, CreateButton, etc.).
- **Atomic Commits**: If multiple files are touched, ensure they are functionally linked.
- **No Pad Overlap**: Do not add keyboard shortcuts unless explicitly requested; check existing Pad sequences in `GUI_Event_Key.mqh` for safety.

## Examples

### Example 1: Adding a "Performance Stats" Panel
**Agent Process**:
1. Adds `STAT_` prefix and `g_PanelStats` (TPanelState) to `Defines.mqh`.
2. Creates `GUI/Stats/Panel_Stats.mqh` with `CreateStatsPanel()`.
3. Adds `Handler_Stats.mqh` for click events.
4. Updates `GUI_Master.mqh` to show/hide the panel.
5. Updates `Config.mqh` to save X/Y positions.

### Example 2: Implementing a "Quick Risk Toggle"
**Agent Process**:
1. Checks `Handler_Trading.mqh` for existing risk logic.
2. Implements a toggle in the UI that cycles `RiskMode`.
3. Calls `UpdateCalculatedLot()` immediately after the toggle to refresh the UI.
4. Ensures the button color updates based on validity (`g_ColorBtnActive` vs `g_ColorBtnInvalid`).
