# 🏗️ STRUCTURE_AUDIT.md - FantomePad Architectural Audit

> **Generated**: 2026-01-27
> **Project**: FantomePad V2.0
> **Verdict**: ⚠️ **NEEDS MAJOR REFACTORING**

---

## 📂 Current Structure

```text
MQL4/Experts/FantomePad/
├── fantomepad.mq4             [107 lines | 4 KB] ✅ ENTRY POINT
├── fantomepad.ex4             [Compiled binary]
├── FantomePad_TestRunner.mq4  [~2 KB] TEST RUNNER
├── README.md                  [5.6 KB] ✅ DOCUMENTATION
├── Include/
│   └── FantomePad/
│       ├── Core/
│       │   ├── Defines.mqh    [223 lines | 8 KB]
│       │   └── Config.mqh     [Persistence Logic]
│       ├── GUI/
│       │   ├── GUI_Master.mqh     [1690 lines | 67 KB] ❌ GOD FILE
│       │   ├── Panel_Main.mqh     [890 lines | 33 KB]  ⚠️ LARGE
│       │   ├── Panel_Positions.mqh[831 lines | 35 KB]  ⚠️ LARGE
│       │   ├── Panel_Settings.mqh [607 lines | 22 KB]
│       │   ├── Panel_Info.mqh
│       │   ├── Panel_Manager.mqh
│       │   ├── Panel_History.mqh
│       │   └── Components/
│       │       └── Components.mqh [8 KB] (Primitives)
│       ├── Trade/
│       │   └── Trade.mqh      [583 lines | 20 KB]
│       └── Tests/
│           ├── Test_Framework.mqh
│           ├── Test_Risk.mqh
│           ├── Test_UI.mqh
│           └── Mocks/
└── .agent/
    └── skills/                [Agent Skills]
```

---

## ✅ PROS (What is Good)

### 1. **Modular Monolith Intent** ✅
- The project *attempts* a clean separation with `Core/`, `GUI/`, `Trade/`, and `Tests/` directories.
- The README.md clearly articulates the architecture intent.

### 2. **Entry Point is Clean** ✅
- `fantomepad.mq4` (107 lines) is a proper thin entry point.
- It delegates all logic to the modules: `OnInit()` → `GUI_OnInit()`, `OnChartEvent()` → `GUI_OnChartEvent()`.

### 3. **Configuration Centralization** ✅
- Global state and theming are centralized in `Core/Defines.mqh`.
- User inputs are declared with proper types.

### 4. **Test Infrastructure Exists** ✅
- A dedicated `Tests/` folder with mock support shows professional intent.
- Custom test runner (`FantomePad_TestRunner.mq4`) is present.

### 5. **Components Directory** ✅
- `GUI/Components/Components.mqh` abstracts primitive creation (buttons, labels, rects).

---

## ❌ CONS (Critical Issues)

### 🚨 **Issue #1: GOD FILE - `GUI_Master.mqh`** (CRITICAL)
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Lines of Code | **1690** | <400 | ❌ **4.2x over** |
| File Size | **67 KB** | <20 KB | ❌ **3.3x over** |
| Outline Items | **91** | <30 | ❌ **3x over** |

**Impact:**
- Extremely difficult to maintain.
- High cognitive load for any developer/AI agent.
- Violates Single Responsibility Principle (SRP).
- Contains: Event Dispatching, Panel Coordination, Color Picker Logic, Toast System, Dragging Logic, Scroll Logic, Order Line Updates, AutoTrading Warning, etc.

---

### 🚨 **Issue #2: Large Panel Files** (HIGH)
| File | Lines | Verdict |
|------|-------|---------|
| `Panel_Main.mqh` | 890 | ⚠️ Should be split |
| `Panel_Positions.mqh` | 831 | ⚠️ Should be split |

**Analysis:**
- Each Panel file mixes **Layout Logic**, **Rendering**, **Event Handling**, and **Business Logic**.
- A single panel should ideally be <300 lines if focused.

---

### 🚨 **Issue #3: Missing Component Abstraction** (MEDIUM)
- `Components.mqh` exists but is underutilized.
- Many panels directly call `ObjectCreate()`, `ObjectSetInteger()` instead of using reusable component wrappers.
- No component for: `ColorPicker`, `Scrollbar`, `SymbolDropdown`, `PositionRow`.

---

### 🚨 **Issue #4: Event Routing Bloat** (HIGH)
- `GUI_OnChartEvent()` in `GUI_Master.mqh` is a **massive if/else chain** spanning hundreds of lines.
- Each panel should own its own `HandleEvent()` dispatcher.

---

### 🚨 **Issue #5: Scattered State Management** (MEDIUM)
- `Defines.mqh` contains **global mutable state** (e.g., `CurrentTypeIndex`, `SelectedPositionTicket`, `g_IsColorPickerOpen`, `g_ToastMsg`).
- These should be encapsulated into state structs or a state manager.

---

### ⚠️ **Issue #6: No Utility Module** (LOW)
- Common helper functions (e.g., `SetObjPosition`, `SetObjVisible`, `IsItemVisible`) are scattered.
- Should be in a dedicated `Utils/Helpers.mqh`.

---

### ⚠️ **Issue #7: Inline Macros in Panel_Settings** (LOW)
```mql4
#define CHECK_VIS(h) IsItemVisible(relY, h)
#define SCREEN_Y (contentStartScreenY + relY - g_ScrollSettings.ScrollY)
```
- Macros inside function scope are dangerous and non-standard.
- Should be converted to inline functions.

---

## 📊 Scalability Score

| Criteria | Score (1-5) | Notes |
|----------|-------------|-------|
| Modularity | 2/5 | Good folders, but giant files |
| Separation of Concerns | 2/5 | Mixed logic in panels |
| Reusability | 2/5 | Components underused |
| Testability | 3/5 | Tests exist but UI logic hard to test |
| Maintainability | 1/5 | `GUI_Master.mqh` is a blocker |
| **Overall** | **2/5** | **Not Production-Ready** |

---

## 🎯 Verdict: **NEEDS MAJOR REFACTORING**

The project has **good architectural intent** as documented in `README.md`, but the implementation has drifted into an anti-pattern:

> **"Modular Monolith" has become "Modular Monster"**

The `GUI_Master.mqh` file alone contains **more lines than the next 3 largest files combined**. This must be addressed before adding new features to avoid technical debt spiral.

---

## 📋 Recommended Next Steps

1. **Read `STRUCTURE_PLAN.md`** for the detailed refactoring roadmap.
2. Prioritize decomposing `GUI_Master.mqh` into focused modules.
3. Extract reusable components into `GUI/Components/`.
4. Introduce a `Utils/` module for helpers.
5. Create per-panel event handlers to reduce central routing bloat.

---

*This audit was generated following the `project-architect` skill protocol.*
