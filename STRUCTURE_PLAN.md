# 🛠️ STRUCTURE_PLAN.md - FantomePad Refactoring Roadmap

> **Generated**: 2026-01-27
> **Priority**: HIGH - Address before adding new features
> **Estimated Effort**: 4-6 development sessions

---

## 🎯 Target Structure (After Refactoring)

```text
MQL4/Experts/FantomePad/
├── fantomepad.mq4                 [ENTRY - Unchanged]
├── README.md                       [DOCUMENTATION]
├── Include/
│   └── FantomePad/
│       ├── Core/
│       │   ├── Defines.mqh         [Constants, Colors, Inputs]
│       │   ├── State.mqh           [NEW: State structs & managers]
│       │   └── Config.mqh          [Persistence Logic]
│       │
│       ├── Utils/                  [NEW DIRECTORY]
│       │   ├── Helpers.mqh         [SetObjPosition, SetObjVisible, etc.]
│       │   └── Formatters.mqh      [Price formatting, Time helpers]
│       │
│       ├── GUI/
│       │   ├── GUI_Master.mqh      [SLIM: Init, Timer, Event Router ONLY]
│       │   │
│       │   ├── Controllers/        [NEW DIRECTORY]
│       │   │   ├── DragController.mqh    [Panel dragging logic]
│       │   │   ├── ScrollController.mqh  [Scroll wheel & scrollbar]
│       │   │   └── ColorPickerController.mqh [Color picker popup]
│       │   │
│       │   ├── Components/         [EXPANDED]
│       │   │   ├── Primitives.mqh       [CreateButton, CreateLabel, etc.]
│       │   │   ├── ColorPicker.mqh      [Self-contained color picker]
│       │   │   ├── Scrollbar.mqh        [Reusable scrollbar]
│       │   │   ├── PositionRow.mqh      [Single position row widget]
│       │   │   ├── HistoryRow.mqh       [Single history row widget]
│       │   │   └── SymbolDropdown.mqh   [Symbol selector dropdown]
│       │   │
│       │   ├── Panels/             [NEW: Dedicated folder for panels]
│       │   │   ├── Panel_Main/
│       │   │   │   ├── Main_Layout.mqh    [Positioning & sizing]
│       │   │   │   ├── Main_Render.mqh    [Object creation]
│       │   │   │   ├── Main_Events.mqh    [Click & edit handlers]
│       │   │   │   └── Main_Logic.mqh     [Order type switching, lot calc]
│       │   │   │
│       │   │   ├── Panel_Positions/
│       │   │   │   ├── Positions_Layout.mqh
│       │   │   │   ├── Positions_Render.mqh
│       │   │   │   ├── Positions_Events.mqh
│       │   │   │   └── Positions_Logic.mqh
│       │   │   │
│       │   │   ├── Panel_Settings/
│       │   │   │   ├── Settings_Layout.mqh
│       │   │   │   ├── Settings_Render.mqh
│       │   │   │   └── Settings_Events.mqh
│       │   │   │
│       │   │   ├── Panel_History.mqh    [Simpler, keep as-is or split later]
│       │   │   ├── Panel_Manager.mqh    [Simpler, keep as-is]
│       │   │   └── Panel_Info.mqh       [Simpler, keep as-is]
│       │   │
│       │   └── Systems/            [NEW DIRECTORY]
│       │       ├── ToastNotification.mqh  [Extracted from GUI_Master]
│       │       ├── AutoTradingWarning.mqh [Extracted from GUI_Master]
│       │       └── OrderLines.mqh         [Chart line management]
│       │
│       ├── Trade/
│       │   ├── Trade.mqh          [Order execution - keep as-is]
│       │   └── RiskCalculator.mqh [NEW: Extract risk calc logic]
│       │
│       └── Tests/
│           └── ... [Unchanged]
```

---

## 📋 Action Plan (Step by Step)

### Phase 1: Foundation (Prepare Infrastructure)

#### Step 1.1: Create `Utils/Helpers.mqh`
**What to extract:**
- `SetObjPosition()` (currently in Panel files)
- `SetObjVisible()` (duplicated across files)
- `IsItemVisible()` (from Panel_Settings)
- Any other shared helper functions

**Why:**
- Reduces code duplication
- Single source of truth for utilities
- Makes panels cleaner

---

#### Step 1.2: Create `Core/State.mqh`
**What to extract from `Defines.mqh`:**
```mql4
// Move these structs and instances:
struct TScrollState { ... };
struct TPanelState { ... };

// Move these global state variables:
int    SelectedPositionTicket;
bool   IsPosListOpen;
int    g_PosListOffset;
bool   g_IsColorPickerOpen;
string g_ColorPickerTarget;
// etc.
```

**Why:**
- `Defines.mqh` should only contain **constants and inputs**
- Mutable state belongs in its own module

---

### Phase 2: Decompose GUI_Master.mqh (Critical)

This is the most important phase. `GUI_Master.mqh` (1690 lines) must be broken into focused modules.

#### Step 2.1: Extract `GUI/Systems/ToastNotification.mqh`
**What to move:**
```mql4
void UpdateToastNotification() { ... }
// Related object creation/cleanup
```
**Target Size:** ~50 lines

---

#### Step 2.2: Extract `GUI/Systems/AutoTradingWarning.mqh`
**What to move:**
```mql4
void UpdateAutoTradingWarning() { ... }
```
**Target Size:** ~30 lines

---

#### Step 2.3: Extract `GUI/Controllers/DragController.mqh`
**What to move:**
- Panel dragging logic from `CHARTEVENT_MOUSE_MOVE` handler
- `ApplyPanelSafety()` function
- All `IsDragging`, `DragOffsetX`, `DragOffsetY` handling

**Target Size:** ~150 lines

---

#### Step 2.4: Extract `GUI/Controllers/ScrollController.mqh`
**What to move:**
- Symbol list scroll logic (`IsScrollDragging`)
- Settings scrollbar dragging
- Scroll wheel handling (`CHARTEVENT_MOUSE_WHEEL`)
- `DrawSymbolList()` related scroll calculations

**Target Size:** ~100 lines

---

#### Step 2.5: Extract `GUI/Controllers/ColorPickerController.mqh`
**What to move:**
```mql4
void ApplyColorChange(color pickedCol) { ... }
void OpenColorPicker(...) { ... }  // If exists
void CloseColorPicker() { ... }
// Related grid creation for color palette
```
**Target Size:** ~100 lines

---

#### Step 2.6: Slim Down `GUI_Master.mqh`
**After extractions, it should ONLY contain:**
```mql4
// GUI_Master.mqh - Coordinator Only (~200 lines max)

#include "Controllers/DragController.mqh"
#include "Controllers/ScrollController.mqh"
#include "Controllers/ColorPickerController.mqh"
#include "Systems/ToastNotification.mqh"
#include "Systems/AutoTradingWarning.mqh"
#include "Panels/Panel_Main/Main_Layout.mqh"
// ... other includes

void GUI_OnInit() {
    // Init calls only
}

void GUI_OnTick() {
    // Tick-based updates only
}

void GUI_OnTimer() {
    // Timer-based updates
}

void GUI_OnChartEvent(...) {
    // THIN dispatcher - routes to panel handlers
    switch(GetPanelFromObject(sparam)) {
        case PANEL_MAIN: HandleMainPanelEvent(...); break;
        case PANEL_POSITIONS: HandlePositionsPanelEvent(...); break;
        // etc.
    }
}

void RefreshAllPanels() {
    // Panel refresh coordination
}
```

---

### Phase 3: Split Large Panels

#### Step 3.1: Split `Panel_Main.mqh` (890 lines → ~4 files)

| New File | Content | Est. Lines |
|----------|---------|------------|
| `Main_Layout.mqh` | `UpdateUIMode()`, positioning logic | ~200 |
| `Main_Render.mqh` | `CreatePanel()`, object creation | ~150 |
| `Main_Events.mqh` | Click handlers, edit field events | ~250 |
| `Main_Logic.mqh` | `AutoSwitchOrderType()`, `UpdateCalculatedLot()` | ~200 |

---

#### Step 3.2: Split `Panel_Positions.mqh` (831 lines → ~4 files)

| New File | Content | Est. Lines |
|----------|---------|------------|
| `Positions_Layout.mqh` | `UpdatePositionsLayout()` | ~150 |
| `Positions_Render.mqh` | `CreatePositionsPanel()` | ~200 |
| `Positions_Events.mqh` | Button clicks, partial close, modify | ~250 |
| `Positions_Logic.mqh` | `UpdatePositionsValues()`, profit calc | ~200 |

---

### Phase 4: Component Library Expansion

#### Step 4.1: Create `Components/ColorPicker.mqh`
Self-contained color picker widget that can be reused anywhere.

#### Step 4.2: Create `Components/PositionRow.mqh`
Single position row in the Manager panel - makes list rendering cleaner.

#### Step 4.3: Create `Components/Scrollbar.mqh`
Generic scrollbar component used by Settings and Manager panels.

---

### Phase 5: Trade Module Cleanup

#### Step 5.1: Extract `Trade/RiskCalculator.mqh`
**What to move:**
- Lot size calculation based on risk %
- Lot size calculation based on fixed money
- Risk R calculations
- `CalculatePipValue()` if it exists

**Why:**
- Makes `Trade.mqh` focused on order execution only
- Risk logic can be tested independently

---

## 🔧 Migration Strategy

### Recommended Approach: **Progressive Refactoring**

1. **Do NOT refactor everything at once.**
2. Extract one module at a time.
3. After each extraction:
   - Compile and test
   - Ensure no regressions
   - Commit to version control

### Order of Operations (Priority)

| Priority | Action | Effort | Impact |
|----------|--------|--------|--------|
| 1 | Create `Utils/Helpers.mqh` | Low | Medium |
| 2 | Create `Core/State.mqh` | Low | Medium |
| 3 | Extract `Controllers/DragController.mqh` | Medium | High |
| 4 | Extract `Systems/ToastNotification.mqh` | Low | Medium |
| 5 | Extract `Controllers/ColorPickerController.mqh` | Medium | High |
| 6 | Split `Panel_Main.mqh` | High | Very High |
| 7 | Split `Panel_Positions.mqh` | High | Very High |
| 8 | Component library expansion | Medium | Medium |

---

## ✅ Success Criteria

After refactoring, the codebase should meet these metrics:

| Metric | Current | Target |
|--------|---------|--------|
| Max file size | 1690 lines | **<400 lines** |
| `GUI_Master.mqh` | 1690 lines | **<250 lines** |
| `Panel_*.mqh` files | 600-900 lines | **<300 lines each** |
| Components count | 1 | **6+** |
| Compilation | ✅ | ✅ (No regressions) |

---

## ⚠️ Important Notes

1. **MQL4 Include Limitations**: MQL4 doesn't support true namespaces or classes cleanly. Use `#include` guards and clear prefixes.

2. **Circular Dependencies**: Be careful when extracting. Use forward declarations or reorganize includes.

3. **Testing**: Run `FantomePad_TestRunner.mq4` after each phase to catch regressions early.

4. **Backup**: Before starting, ensure you have a git commit or backup of the current working state.

---

## 🚀 Getting Started

To begin refactoring, you can invoke the **`structure-fixer`** skill which will:
1. Read this `STRUCTURE_PLAN.md`
2. Execute the refactoring steps systematically
3. Verify compilation after each change
4. Delete audit files upon successful completion

**Command:** *"Execute the structure fix plan"*

---

*This plan was generated following the `project-architect` skill protocol.*
